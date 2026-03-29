section .data
    TCGETS equ 0x5401
    TCSETS equ 0x5402
    ICANON equ 0x0002
    ECHO   equ 0x0008
    termios_orig: times 36 db 0  ; ~36 bytes for termios (iflag,oflag,cflag,lflag,cc[32])
    termios_new:  times 36 db 0

section .text
    global _start

_start:
    ; Get original termios: ioctl(0, TCGETS, &orig)
    mov rax, 16          ; SYS_ioctl
    mov rdi, 0           ; stdin
    mov rsi, TCGETS
    mov rdx, termios_orig
    syscall

    ; Copy orig to new
    mov rcx, 36
    mov rsi, termios_orig
    mov rdi, termios_new
    rep movsb

    ; Modify new: clear ICANON & ECHO in lflag (offset 12)
    mov rax, [termios_new + 12]
    and rax, ~(ICANON | ECHO)
    mov [termios_new + 12], rax

    ; Set new termios: ioctl(0, TCSETS, &new)
    mov rax, 16
    mov rdi, 0
    mov rsi, TCSETS
    mov rdx, termios_new
    syscall

    ; Read 1 byte
    mov rax, 0           ; SYS_read
    mov rdi, 0
    mov rsi, keybuf
    mov rdx, 1
    syscall

    ; Print key code (simple write to stdout)
    add al, -'0'         ; Crude print (for demo; use full write for char)
    mov [keybuf], al
    mov rax, 1           ; SYS_write
    mov rdi, 1
    mov rsi, keybuf
    mov rdx, 1
    syscall

    ; Restore orig termios
    mov rax, 16
    mov rdi, 0
    mov rsi, TCSETS
    mov rdx, termios_orig
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

section .bss
    keybuf resb 1
