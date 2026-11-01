"""Linux getChar syscall/terminal regression tests; requires fasm in PATH."""

import ast
import os
from pathlib import Path
import platform
import pty
import re
import select
import subprocess
import tempfile
import termios
import time
import unittest


@unittest.skipUnless(platform.system() == "Linux" and platform.machine() == "x86_64",
                     "requires Linux x86_64")
class GetCharTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.directory = tempfile.TemporaryDirectory()
        cls.addClassCleanup(cls.directory.cleanup)
        header = (Path(__file__).resolve().parents[1]
                  / "main/resources-test/compiler/linux_x86_64.h").read_text()
        body = header.split("i16 getChar() asm {", 1)[1].split("\n}", 1)[0]
        instructions = "\n".join(ast.literal_eval(line) for line in re.findall(
            r'^\s*("(?:[^"\\]|\\.)*")', body, re.MULTILINE))
        # Verify the callee-saved registers and stack as well as the return value.
        harness = """format ELF64 executable 3
segment readable executable
entry _start
_start:
mov ebx, 11111111h
mov ebp, 22222222h
mov r12d, 33333333h
mov r13d, 44444444h
mov r14d, 55555555h
mov r15, rsp
call getChar
mov [result], ax
cmp rbx, 11111111h
jne .fail
cmp rbp, 22222222h
jne .fail
cmp r12, 33333333h
jne .fail
cmp r13, 44444444h
jne .fail
cmp r14, 55555555h
jne .fail
cmp rsp, r15
jne .fail
mov eax, 1
mov edi, 1
lea rsi, [result]
mov edx, 2
syscall
xor edi, edi
jmp .exit
.fail:
mov edi, 1
.exit:
mov eax, 60
syscall
getChar:
""" + instructions + "\nsegment readable writable\nresult dw 0\n"
        source = Path(cls.directory.name) / "getchar.asm"
        cls.executable = source.with_suffix(".bin")
        source.write_text(harness)
        subprocess.run(["fasm", str(source), str(cls.executable)], check=True,
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        cls.executable.chmod(0o700)

    def test_bytes(self):
        for key in b"A\x00\n\x7f\x80\xe0\xff":
            with self.subTest(key=key):
                self.read_terminal(bytes([key]), key)

    def test_escape_sequence_is_not_decoded(self):
        self.read_terminal(b"\x1b[A", 0x1B)

    def test_escape(self):
        self.read_terminal(b"\x1b", 0x1B)

    def read_terminal(self, data, expected):
        master, slave = pty.openpty()
        try:
            original = termios.tcgetattr(slave)
            original[3] |= termios.ICANON | termios.ECHO | termios.ECHONL
            original[6][termios.VMIN] = 7
            original[6][termios.VTIME] = 3
            termios.tcsetattr(slave, termios.TCSANOW, original)
            original = termios.tcgetattr(slave)
            with subprocess.Popen([str(self.executable)], stdin=slave,
                                  stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:
                try:
                    deadline = time.monotonic() + 2
                    while termios.tcgetattr(slave)[3] & termios.ICANON:
                        self.assertIsNone(process.poll())
                        self.assertLess(time.monotonic(), deadline)
                        time.sleep(0.005)
                    self.assertFalse(termios.tcgetattr(slave)[3] & (termios.ECHO | termios.ECHONL))
                    os.write(master, data)
                    output, error = process.communicate(timeout=2)
                    self.assertEqual(process.returncode, 0, error)
                    self.assertEqual(output, expected.to_bytes(2, "little", signed=True))
                    self.assertEqual(termios.tcgetattr(slave), original)
                    self.assertFalse(select.select([master], [], [], 0)[0], "input was echoed")
                    if len(data) > 1:
                        # Verify that getChar left the following bytes unread.
                        remaining = termios.tcgetattr(slave)
                        remaining[3] &= ~termios.ICANON
                        remaining[6][termios.VMIN] = 0
                        remaining[6][termios.VTIME] = 0
                        termios.tcsetattr(slave, termios.TCSANOW, remaining)
                        self.assertEqual(os.read(slave, len(data)), data[1:])
                finally:
                    if process.poll() is None:
                        process.kill()
                        process.wait()
        finally:
            os.close(master)
            os.close(slave)


if __name__ == "__main__":
    unittest.main()
