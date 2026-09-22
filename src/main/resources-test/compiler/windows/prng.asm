format pe64 console
include 'win64ax.inc'

STD_IN_HANDLE = -10
STD_OUT_HANDLE = -11
STD_ERR_HANDLE = -12

entry start

section '.text' code readable executable

start:
        ; alignment
        and rsp, -16
        call init
        call _main
        mov rcx, 0
        sub rsp, 0x20
        call [ExitProcess]

        ; void printChar@u8
        ;   rsp+48: arg chr
_printChar@u8:
        sub rsp, 8
        sub rsp, 32
        ; move chr, chr{r1}
        lea r11, [rsp+48]
        mov [r11], cl
        ; addrof t.1.1{r1}, chr
        lea rcx, [rsp+48]
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+96: arg number
        ;   rsp+60: var buffer
_printUint@i64:
        sub rsp, 40
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const pos.1{r6}, 20
        mov bl, 20
        ; 28:2 while true
        ; move number.1{r7}, number{r1}
        mov r12, rcx
_while_1:
        ; sub pos.3{r6}, pos.3{r6}, 1
        sub bl, 1
        ; move remainder.1{r3}, number.1{r7}
        mov r8, r12
        ; move remainder.1{r0}, remainder.1{r3}
        mov rax, r8
        ; mod remainder.1{r2}, remainder.1{r0}, 10
        mov cx, 10
        cqo
        idiv cx
        ; move remainder.1{r3}, remainder.1{r2}
        mov r8, rdx
        ; move number.2{r0}, number.2{r7}
        mov rax, r12
        ; div number.2{r0}, number.2{r0}, 10
        mov cx, 10
        cqo
        idiv cx
        ; move number.2{r7}, number.2{r0}
        mov r12, rax
        ; cast t.5.1{r0}(u8), remainder.1{r3}(i64)
        mov al, r8b
        ; add digit.1{r0}, digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r3}(i64), pos.3{r6}(u8)
        movzx r8, bl
        ; addrof t.6.1{r4}, [buffer]
        lea r9, [rsp+60]
        ; add t.6.2{r4}, t.6.2{r4}, t.7.1{r3}
        add r9, r8
        ; store [t.6.2{r4}], digit.1{r0}
        mov [r9], al
        ; 34:3 if number == 0
        ; branch number.2{r7} notequals 0: while_1, while_1_break
        cmp r12, 0
        jne _while_1
        ; cast t.9.1{r7}(i64), pos.3{r6}(u8)
        movzx r12, bl
        ; addrof t.8.1{r0}, [buffer]
        lea rax, [rsp+60]
        ; move t.8.2{r1}, t.8.1{r0}
        mov rcx, rax
        ; add t.8.2{r1}, t.8.2{r1}, t.9.1{r7}
        add rcx, r12
        ; const t.11.1{r7}, 20
        mov r12b, 20
        ; move t.10.1{r2}, t.11.1{r7}
        mov dl, r12b
        ; sub t.10.1{r2}, t.10.1{r2}, pos.3{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 40
        ret

        ; void printIntLf@u8
        ;   rsp+48: arg number
_printIntLf@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1.1{r1}(i64), number{r1}(u8)
        movzx rcx, cl
        ; call printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printIntLf@i64
        ;   rsp+48: arg number
_printIntLf@i64:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; branch number{r6} gteq 0: if_3_end, if_3_then
        cmp rbx, 0
        jge _if_3_end
        ; const arg.0.0{r1}, 45
        mov cl, 45
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; neg number.2{r6}, number{r6}
        neg rbx
_if_3_end:
        ; move number.1{r1}, number.1{r6}
        mov rcx, rbx
        ; call printUint@i64[number.1{r1}]
        call _printUint@i64
        ; const arg.2.0{r1}, 10
        mov cl, 10
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
_printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void initRandom@i32
        ;   rsp+16: arg salt
_initRandom@i32:
        sub rsp, 8
        ; move tmp.__random__{r0}, salt{r1}
        mov eax, ecx
        ; move __random__, tmp.__random__{r0}
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; i32 random
_random:
        sub rsp, 8
        ; move tmp.__random__{r0}, __random__
        lea r11, [var_0]
        mov eax, [r11]
        ; move r.1{r1}, tmp.__random__{r0}
        mov ecx, eax
        ; move t.5.1{r2}, r.1{r1}
        mov edx, ecx
        ; and t.5.1{r2}, t.5.1{r2}, 524287
        and edx, 524287
        ; mul b.1{r2}, b.1{r2}, 48271
        movsxd rdx, edx
        imul  rdx, 48271
        ; shiftright t.6.1{r1}, t.6.1{r1}, 15
        sar ecx, 15
        ; mul c.1{r1}, c.1{r1}, 48271
        movsxd rcx, ecx
        imul  rcx, 48271
        ; move t.7.1{r3}, c.1{r1}
        mov r8d, ecx
        ; and t.7.1{r3}, t.7.1{r3}, 65535
        and r8d, 65535
        ; shiftleft d.1{r3}, d.1{r3}, 15
        sal r8d, 15
        ; shiftright t.9.1{r1}, t.9.1{r1}, 16
        sar ecx, 16
        ; add t.8.1{r1}, t.8.1{r1}, b.1{r2}
        add ecx, edx
        ; add e.1{r1}, e.1{r1}, d.1{r3}
        add ecx, r8d
        ; move t.10.1{r2}, e.1{r1}
        mov edx, ecx
        ; and t.10.1{r2}, t.10.1{r2}, 2147483647
        and edx, 2147483647
        ; shiftright t.11.1{r1}, t.11.1{r1}, 31
        sar ecx, 31
        ; move tmp.__random__{r0}, t.10.1{r2}
        mov eax, edx
        ; add tmp.__random__{r0}, tmp.__random__{r0}, t.11.1{r1}
        add eax, ecx
        ; 15:9 return __random__
        ; move __random__, tmp.__random__{r0}
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; u8 randomU8
_randomU8:
        sub rsp, 8
        sub rsp, 32
        ; 19:10 return (u8)
        ; call t.1.1{r0} = random[] -> i32
        call _random
        ; cast t.0.1{r0}(u8), t.1.1{r0}(i32)
        add rsp, 32
        add rsp, 8
        ret

        ; void main
_main:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; begin initialize global variables
        ; const tmp.__random__{r6}, 0
        mov ebx, 0
        ; end initialize global variables
        ; move __random__, tmp.__random__{r6}
        lea r11, [var_0]
        mov [r11], ebx
        ; const arg.0.0{r1}, 7439742
        mov ecx, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; const i.1{r6}, 0
        mov bl, 0
        ; 6:2 for i < 50
        jmp _for_4
_for_4_body:
        ; call r.1{r0} = randomU8[] -> u8
        call _randomU8
        ; move r.1{r1}, r.1{r0}
        mov cl, al
        ; call printIntLf@u8[r.1{r1}]
        call _printIntLf@u8
        ; move i.3{r0}, i.2{r6}
        mov al, bl
        ; add i.3{r0}, i.3{r0}, 1
        add al, 1
        ; move i.2{r6}, i.3{r0}
        mov bl, al
_for_4:
        ; branch i.2{r6} lt 50: for_4_body, main_ret
        cmp bl, 50
        jb _for_4_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
        mov     rdi, rsp

        mov     r8, rdx
        mov     rdx, rcx
        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        xor     r9, r9
        push    0
        sub     rsp, 20h
          call    [WriteFile]
        mov     rsp, rdi
        ret

init:
        sub rsp, 28h
          mov rcx, STD_IN_HANDLE
          call [GetStdHandle]
          ; handle in rax, 0 if invalid
          lea rcx, [hStdIn]
          mov qword [rcx], rax

          mov rcx, STD_OUT_HANDLE
          call [GetStdHandle]
          ; handle in rax, 0 if invalid
          lea rcx, [hStdOut]
          mov qword [rcx], rax

          mov rcx, STD_ERR_HANDLE
          call [GetStdHandle]
          ; handle in rax, 0 if invalid
          lea rcx, [hStdErr]
          mov qword [rcx], rax
        add rsp, 28h
        ret

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8
        ; variable 0: __random__ (i32/4)
        var_0 rb 4

section '.idata' import data readable writeable

library kernel32,'KERNEL32.DLL',\
        msvcrt,'MSVCRT.DLL'

import kernel32,\
       ExitProcess,'ExitProcess',\
       GetStdHandle,'GetStdHandle',\
       SetConsoleCursorPosition,'SetConsoleCursorPosition',\
       WriteFile,'WriteFile'

import msvcrt,\
       _getch,'_getch'
