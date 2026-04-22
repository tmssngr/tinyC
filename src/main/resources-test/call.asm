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
        call @main
        mov rcx, 0
        sub rsp, 0x20
        call [ExitProcess]

        ; void printChar@u8
        ;   rsp+48: arg chr
@printChar@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; addrof t.1{r6}, chr
        lea rbx, [rsp+48]
        ; const t.2{r2}, 1
        mov dl, 1
        ; move chr, tmp.chr{r1}
        lea r11, [rsp+48]
        mov [r11], cl
        ; move t.1{r1}, t.1{r6}
        mov rcx, rbx
        ; call printStringLength@@u8@u8[t.1{r1}, t.2{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printUint@i64
        ;   rsp+96: arg number
        ;   rsp+60: var buffer
@printUint@i64:
        sub rsp, 40
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const pos{r6}, 20
        mov bl, 20
        ; 25:2 while true
@while_1:
        ; dec pos{r6}
        dec bl
        ; const t.5{r7}, 10
        mov r12, 10
        ; move remainder{r3}, number{r1}
        mov r8, rcx
        ; move remainder{r0}, remainder{r3}
        mov rax, r8
        ; mod remainder{r2}, remainder{r0}, t.5{r7}
        cqo
        idiv r12
        ; move remainder{r3}, remainder{r2}
        mov r8, rdx
        ; const t.6{r7}, 10
        mov r12, 10
        ; move number{r0}, number{r1}
        mov rax, rcx
        ; div number{r0}, number{r0}, t.6{r7}
        cqo
        idiv r12
        ; move number{r1}, number{r0}
        mov rcx, rax
        ; cast t.7{r7}(u8), remainder{r3}(i64)
        mov r12b, r8b
        ; const t.8{r0}, 48
        mov al, 48
        ; add digit{r7}, digit{r7}, t.8{r0}
        add r12b, al
        ; cast t.10{r0}(i64), pos{r6}(u8)
        movzx rax, bl
        ; cast t.11{r0}(u8*), t.10{r0}(i64)
        ; addrof t.9{r3}, [buffer]
        lea r8, [rsp+60]
        ; add t.9{r3}, t.9{r3}, t.11{r0}
        add r8, rax
        ; store [t.9{r3}], digit{r7}
        mov [r8], r12b
        ; 31:3 if number == 0
        ; equals t.12{r7}, number{r1}, 0
        cmp rcx, 0
        sete r12b
        ; branch t.12{r7}, false, @while_1
        or r12b, r12b
        jz @while_1
        ; cast t.14{r7}(i64), pos{r6}(u8)
        movzx r12, bl
        ; cast t.15{r7}(u8*), t.14{r7}(i64)
        ; addrof t.13{r1}, [buffer]
        lea rcx, [rsp+60]
        ; add t.13{r1}, t.13{r1}, t.15{r7}
        add rcx, r12
        ; const t.17{r7}, 20
        mov r12b, 20
        ; move t.16{r2}, t.17{r7}
        mov dl, r12b
        ; sub t.16{r2}, t.16{r2}, pos{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.13{r1}, t.16{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 40
        ret

        ; void printIntLf@u8
        ;   rsp+48: arg number
@printIntLf@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1{r1}(i64), number{r1}(u8)
        movzx rcx, cl
        ; call printIntLf@i64[t.1{r1}]
        call @printIntLf@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printIntLf@i64
        ;   rsp+64: arg number
@printIntLf@i64:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; 51:2 if number < 0
        ; lt t.1{r7}, number{r6}, 0
        cmp rbx, 0
        setl r12b
        ; branch t.1{r7}, false, @if_3_end
        or r12b, r12b
        jz @if_3_end
        ; const t.2{r1}, 45
        mov cl, 45
        ; call printChar@u8[t.2{r1}]
        call @printChar@u8
        ; neg number{r6}, number{r6}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r6}
        mov rcx, rbx
        ; call printUint@i64[number{r1}]
        call @printUint@i64
        ; const t.3{r1}, 10
        mov cl, 10
        ; call printChar@u8[t.3{r1}]
        call @printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
@printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call @printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void main
        ;   rsp+56: var t.2
        ;   rsp+57: var t.3
        ;   rsp+32: var arg.0.4
@main:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 40
        ; begin initialize global variables
        ; const tmp.i{r6}, 0
        mov bl, 0
        ; end initialize global variables
        ; move i, tmp.i{r6}
        lea r11, [var_0]
        mov [r11], bl
        ; call t.0{r0} = next[] -> u8
        call @next
        ; move t.0{r6}, t.0{r0}
        mov bl, al
        ; call t.1{r0} = next[] -> u8
        call @next
        ; move t.1{r7}, t.1{r0}
        mov r12b, al
        ; call t.2{r0} = next[] -> u8
        call @next
        ; move t.2, t.2{r0}
        lea r11, [rsp+56]
        mov [r11], al
        ; call t.3{r0} = next[] -> u8
        call @next
        ; move t.3, t.3{r0}
        lea r11, [rsp+57]
        mov [r11], al
        ; call t.4{r0} = next[] -> u8
        call @next
        ; move arg.0.4, t.4{r0}
        lea r11, [rsp+32]
        mov [r11], al
        ; move t.0{r1}, t.0{r6}
        mov cl, bl
        ; move t.1{r2}, t.1{r7}
        mov dl, r12b
        ; move t.2{r3}, t.2
        lea r11, [rsp+56]
        mov r8b, [r11]
        ; move t.3{r4}, t.3
        lea r11, [rsp+57]
        mov r9b, [r11]
        ; call doPrint@u8@u8@u8@u8@u8[t.0{r1}, t.1{r2}, t.2{r3}, t.3{r4}, arg.0.4]
        call @doPrint@u8@u8@u8@u8@u8
        add rsp, 40
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 16
        ret

        ; u8 next
@next:
        sub rsp, 8
        ; move tmp.i{r0}, i
        lea r11, [var_0]
        mov al, [r11]
        ; inc tmp.i{r0}
        inc al
        ; 11:9 return i
        ; move i, tmp.i{r0}
        lea r11, [var_0]
        mov [r11], al
        add rsp, 8
        ret

        ; void doPrint@u8@u8@u8@u8@u8
        ;   rsp+64: arg a
        ;   rsp+72: arg b
        ;   rsp+80: arg c
        ;   rsp+88: arg d
        ;   rsp+96: arg e
@doPrint@u8@u8@u8@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move e{r6}, e
        lea r11, [rsp+96]
        mov bl, [r11]
        ; move b{r7}, b{r2}
        mov r12b, dl
        ; move c, c{r3}
        lea r11, [rsp+80]
        mov [r11], r8b
        ; move d, d{r4}
        lea r11, [rsp+88]
        mov [r11], r9b
        ; call printIntLf@u8[a{r1}]
        call @printIntLf@u8
        ; move b{r1}, b{r7}
        mov cl, r12b
        ; call printIntLf@u8[b{r1}]
        call @printIntLf@u8
        ; move c{r1}, c
        lea r11, [rsp+80]
        mov cl, [r11]
        ; call printIntLf@u8[c{r1}]
        call @printIntLf@u8
        ; move d{r1}, d
        lea r11, [rsp+88]
        mov cl, [r11]
        ; call printIntLf@u8[d{r1}]
        call @printIntLf@u8
        ; move e{r1}, e{r6}
        mov cl, bl
        ; call printIntLf@u8[e{r1}]
        call @printIntLf@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength@@u8@i64
@printStringLength@@u8@i64:
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
        ; variable 0: i (u8/1)
        var_0 rb 1

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
