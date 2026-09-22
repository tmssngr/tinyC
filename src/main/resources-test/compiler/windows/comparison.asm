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

        ; void printString@@u8
        ;   rsp+48: arg str
_printString@@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move str{r6}, str{r1}
        mov rbx, rcx
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; call length.1{r0} = strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length.1{r2}, length.1{r0}
        mov rdx, rax
        ; call printStringLength@@u8@i64[str{r1}, length.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

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

        ; void printIntLf@bool
        ;   rsp+48: arg number
_printIntLf@bool:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1.1{r1}(i64), number{r1}(bool)
        movsx rcx, cl
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

        ; i64 strlen@@u8
        ;   rsp+16: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length.1{r2}, 0
        mov rdx, 0
        ; 64:2 for *str != 0
        ; move length.2{r0}, length.1{r2}
        mov rax, rdx
        jmp _for_4
_for_4_body:
        ; move length.3{r2}, length.2{r0}
        mov rdx, rax
        ; add length.3{r2}, length.3{r2}, 1
        add rdx, 1
        ; add str.2{r1}, str.2{r1}, 1
        add rcx, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rdx
_for_4:
        ; load t.2.1{r2}, [str.1{r1}]
        mov dl, [rcx]
        ; branch t.2.1{r2} notequals 0: for_4_body, for_4_break
        cmp dl, 0
        jne _for_4_body
        ; 67:9 return length
        add rsp, 8
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

        ; void main
        ;   rsp+48: var c.1
        ;   rsp+49: var d.1
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const t.4.1{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.4.1{r1}]
        call _printString@@u8
        ; const a.1{r6}, 1
        mov bx, 1
        ; const b.1{r7}, 2
        mov r12w, 2
        ; lt t.5.1{r1}, a.1{r6}, b.1{r7}
        cmp bx, r12w
        setl cl
        ; call printIntLf@bool[t.5.1{r1}]
        call _printIntLf@bool
        ; lt t.6.1{r1}, b.1{r7}, a.1{r6}
        cmp r12w, bx
        setl cl
        ; call printIntLf@bool[t.6.1{r1}]
        call _printIntLf@bool
        ; const t.7.1{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[t.7.1{r1}]
        call _printString@@u8
        ; const c.1{r0}, 0
        mov al, 0
        ; const d.1{r2}, 128
        mov dl, 128
        ; lt t.8.1{r1}, c.1{r0}, d.1{r2}
        cmp al, dl
        setb cl
        ; move c.1, c.1{r0}
        lea r11, [rsp+48]
        mov [r11], al
        ; move d.1, d.1{r2}
        lea r11, [rsp+49]
        mov [r11], dl
        ; call printIntLf@bool[t.8.1{r1}]
        call _printIntLf@bool
        ; move c.1{r2}, c.1
        lea r11, [rsp+48]
        mov dl, [r11]
        ; move d.1{r0}, d.1
        lea r11, [rsp+49]
        mov al, [r11]
        ; lt t.9.1{r1}, d.1{r0}, c.1{r2}
        cmp al, dl
        setb cl
        ; move c.1, c.1{r2}
        lea r11, [rsp+48]
        mov [r11], dl
        ; move d.1, d.1{r0}
        lea r11, [rsp+49]
        mov [r11], al
        ; call printIntLf@bool[t.9.1{r1}]
        call _printIntLf@bool
        ; const t.10.1{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString@@u8[t.10.1{r1}]
        call _printString@@u8
        ; lteq t.11.1{r1}, a.1{r6}, b.1{r7}
        cmp bx, r12w
        setle cl
        ; call printIntLf@bool[t.11.1{r1}]
        call _printIntLf@bool
        ; lteq t.12.1{r1}, b.1{r7}, a.1{r6}
        cmp r12w, bx
        setle cl
        ; call printIntLf@bool[t.12.1{r1}]
        call _printIntLf@bool
        ; const t.13.1{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString@@u8[t.13.1{r1}]
        call _printString@@u8
        ; move c.1{r0}, c.1
        lea r11, [rsp+48]
        mov al, [r11]
        ; move d.1{r2}, d.1
        lea r11, [rsp+49]
        mov dl, [r11]
        ; lteq t.14.1{r1}, c.1{r0}, d.1{r2}
        cmp al, dl
        setbe cl
        ; move c.1, c.1{r0}
        lea r11, [rsp+48]
        mov [r11], al
        ; move d.1, d.1{r2}
        lea r11, [rsp+49]
        mov [r11], dl
        ; call printIntLf@bool[t.14.1{r1}]
        call _printIntLf@bool
        ; move c.1{r2}, c.1
        lea r11, [rsp+48]
        mov dl, [r11]
        ; move d.1{r0}, d.1
        lea r11, [rsp+49]
        mov al, [r11]
        ; lteq t.15.1{r1}, d.1{r0}, c.1{r2}
        cmp al, dl
        setbe cl
        ; move c.1, c.1{r2}
        lea r11, [rsp+48]
        mov [r11], dl
        ; move d.1, d.1{r0}
        lea r11, [rsp+49]
        mov [r11], al
        ; call printIntLf@bool[t.15.1{r1}]
        call _printIntLf@bool
        ; const t.16.1{r1}, [string-4]
        lea rcx, [string_4]
        ; call printString@@u8[t.16.1{r1}]
        call _printString@@u8
        ; equals t.17.1{r1}, a.1{r6}, b.1{r7}
        cmp bx, r12w
        sete cl
        ; call printIntLf@bool[t.17.1{r1}]
        call _printIntLf@bool
        ; equals t.18.1{r1}, b.1{r7}, a.1{r6}
        cmp r12w, bx
        sete cl
        ; call printIntLf@bool[t.18.1{r1}]
        call _printIntLf@bool
        ; const t.19.1{r1}, [string-5]
        lea rcx, [string_5]
        ; call printString@@u8[t.19.1{r1}]
        call _printString@@u8
        ; notequals t.20.1{r1}, a.1{r6}, b.1{r7}
        cmp bx, r12w
        setne cl
        ; call printIntLf@bool[t.20.1{r1}]
        call _printIntLf@bool
        ; notequals t.21.1{r1}, b.1{r7}, a.1{r6}
        cmp r12w, bx
        setne cl
        ; call printIntLf@bool[t.21.1{r1}]
        call _printIntLf@bool
        ; const t.22.1{r1}, [string-6]
        lea rcx, [string_6]
        ; call printString@@u8[t.22.1{r1}]
        call _printString@@u8
        ; gteq t.23.1{r1}, a.1{r6}, b.1{r7}
        cmp bx, r12w
        setge cl
        ; call printIntLf@bool[t.23.1{r1}]
        call _printIntLf@bool
        ; gteq t.24.1{r1}, b.1{r7}, a.1{r6}
        cmp r12w, bx
        setge cl
        ; call printIntLf@bool[t.24.1{r1}]
        call _printIntLf@bool
        ; const t.25.1{r1}, [string-7]
        lea rcx, [string_7]
        ; call printString@@u8[t.25.1{r1}]
        call _printString@@u8
        ; move c.1{r0}, c.1
        lea r11, [rsp+48]
        mov al, [r11]
        ; move d.1{r2}, d.1
        lea r11, [rsp+49]
        mov dl, [r11]
        ; gteq t.26.1{r1}, c.1{r0}, d.1{r2}
        cmp al, dl
        setae cl
        ; move c.1, c.1{r0}
        lea r11, [rsp+48]
        mov [r11], al
        ; move d.1, d.1{r2}
        lea r11, [rsp+49]
        mov [r11], dl
        ; call printIntLf@bool[t.26.1{r1}]
        call _printIntLf@bool
        ; move c.1{r2}, c.1
        lea r11, [rsp+48]
        mov dl, [r11]
        ; move d.1{r0}, d.1
        lea r11, [rsp+49]
        mov al, [r11]
        ; gteq t.27.1{r1}, d.1{r0}, c.1{r2}
        cmp al, dl
        setae cl
        ; move c.1, c.1{r2}
        lea r11, [rsp+48]
        mov [r11], dl
        ; move d.1, d.1{r0}
        lea r11, [rsp+49]
        mov [r11], al
        ; call printIntLf@bool[t.27.1{r1}]
        call _printIntLf@bool
        ; const t.28.1{r1}, [string-8]
        lea rcx, [string_8]
        ; call printString@@u8[t.28.1{r1}]
        call _printString@@u8
        ; gt t.29.1{r1}, a.1{r6}, b.1{r7}
        cmp bx, r12w
        setg cl
        ; call printIntLf@bool[t.29.1{r1}]
        call _printIntLf@bool
        ; gt t.30.1{r1}, b.1{r7}, a.1{r6}
        cmp r12w, bx
        setg cl
        ; call printIntLf@bool[t.30.1{r1}]
        call _printIntLf@bool
        ; const t.31.1{r1}, [string-9]
        lea rcx, [string_9]
        ; call printString@@u8[t.31.1{r1}]
        call _printString@@u8
        ; move c.1{r6}, c.1
        lea r11, [rsp+48]
        mov bl, [r11]
        ; move d.1{r7}, d.1
        lea r11, [rsp+49]
        mov r12b, [r11]
        ; gt t.32.1{r1}, c.1{r6}, d.1{r7}
        cmp bl, r12b
        seta cl
        ; call printIntLf@bool[t.32.1{r1}]
        call _printIntLf@bool
        ; gt t.33.1{r1}, d.1{r7}, c.1{r6}
        cmp r12b, bl
        seta cl
        ; call printIntLf@bool[t.33.1{r1}]
        call _printIntLf@bool
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
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

section '.data' data readable
        string_0 db '< (signed)', 0x0a, 0x00
        string_1 db '< (unsigned)', 0x0a, 0x00
        string_2 db '<= (signed)', 0x0a, 0x00
        string_3 db '<= (unsigned)', 0x0a, 0x00
        string_4 db '==', 0x0a, 0x00
        string_5 db '!=', 0x0a, 0x00
        string_6 db '>= (signed)', 0x0a, 0x00
        string_7 db '>= (unsigned)', 0x0a, 0x00
        string_8 db '> (signed)', 0x0a, 0x00
        string_9 db '> (unsigned)', 0x0a, 0x00

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
