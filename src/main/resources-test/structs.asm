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

        ; void printChar
        ;   rsp+16: arg chr
@printChar:
        ; save clobbered non-volatile registers
        push rbx
        ; addrof t.1{r6}, chr
        lea rbx, [rsp+16]
        ; const t.2{r2}, 1
        mov rdx, 1
        ; move chr, tmp.chr{r1}
        lea r11, [rsp+16]
        mov [r11], cl
        ; move t.1{r1}, t.1{r6}
        mov rcx, rbx
        ; call printStringLength[t.1{r1}, t.2{r2}]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printUint
        ;   rsp+48: arg number
        ;   rsp+20: var buffer
@printUint:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; const pos{r7}, 20
        mov r12b, 20
        ; 13:2 while true
@while_1:
        ; dec pos{r7}
        dec r12b
        ; const t.5{r3}, 10
        mov r8, 10
        ; move remainder{r4}, number{r6}
        mov r9, rbx
        ; move remainder{r0}, remainder{r4}
        mov rax, r9
        ; mod remainder{r2}, remainder{r0}, t.5{r3}
        cqo
        idiv r8
        ; move remainder{r4}, remainder{r2}
        mov r9, rdx
        ; const t.6{r3}, 10
        mov r8, 10
        ; move number{r0}, number{r6}
        mov rax, rbx
        ; div number{r0}, number{r0}, t.6{r3}
        cqo
        idiv r8
        ; move number{r6}, number{r0}
        mov rbx, rax
        ; cast t.7{r0}(u8), remainder{r4}(i64)
        mov al, r9b
        ; const t.8{r3}, 48
        mov r8b, 48
        ; add digit{r0}, digit{r0}, t.8{r3}
        add al, r8b
        ; cast t.10{r3}(i64), pos{r7}(u8)
        movzx r8, r12b
        ; cast t.11{r3}(u8*), t.10{r3}(i64)
        ; addrof t.9{r4}, [buffer]
        lea r9, [rsp+20]
        ; add t.9{r4}, t.9{r4}, t.11{r3}
        add r9, r8
        ; store [t.9{r4}], digit{r0}
        mov [r9], al
        ; 19:3 if number == 0
        ; equals t.12{r0}, number{r6}, 0
        cmp rbx, 0
        sete al
        ; branch t.12{r0}, false, @while_1
        or al, al
        jz @while_1
        ; cast t.14{r6}(i64), pos{r7}(u8)
        movzx rbx, r12b
        ; cast t.15{r6}(u8*), t.14{r6}(i64)
        ; addrof t.13{r1}, [buffer]
        lea rcx, [rsp+20]
        ; add t.13{r1}, t.13{r1}, t.15{r6}
        add rcx, rbx
        ; const t.18{r6}, 20
        mov bl, 20
        ; sub t.17{r6}, t.17{r6}, pos{r7}
        sub bl, r12b
        ; cast t.16{r2}(i64), t.17{r6}(u8)
        movzx rdx, bl
        ; call printStringLength[t.13{r1}, t.16{r2}]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void printIntLf
        ;   rsp+32: arg number
@printIntLf:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; 27:2 if number < 0
        ; lt t.1{r7}, number{r6}, 0
        cmp rbx, 0
        setl r12b
        ; branch t.1{r7}, false, @if_3_end
        or r12b, r12b
        jz @if_3_end
        ; const t.2{r1}, 45
        mov cl, 45
        ; call printChar[t.2{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; neg number{r6}, number{r6}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r6}
        mov rcx, rbx
        ; call printUint[number{r1}]
        sub rsp, 20h; shadow space
        call @printUint
        add rsp, 20h
        ; const t.3{r1}, 10
        mov cl, 10
        ; call printChar[t.3{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void main
        ;   rsp+16: var pos
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.2{r7}, 1
        mov r12b, 1
        ; 9:6 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=9:2].x
        ; addrof t.3{r0}, pos
        lea rax, [rsp+16]
        ; store [t.3{r0}], t.2{r7}
        mov [rax], r12b
        ; 10:14 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=10:10].x
        ; addrof t.6{r7}, pos
        lea r12, [rsp+16]
        ; load t.5{r7}, [t.6{r7}]
        mov r12b, [r12]
        ; const t.7{r0}, 1
        mov al, 1
        ; add t.4{r7}, t.4{r7}, t.7{r0}
        add r12b, al
        ; 10:6 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=10:2].y
        ; addrof t.8{r0}, pos
        lea rax, [rsp+16]
        ; inc t.8{r0}
        inc rax
        ; store [t.8{r0}], t.4{r7}
        mov [rax], r12b
        ; 11:17 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=11:13].x
        ; addrof t.11{r7}, pos
        lea r12, [rsp+16]
        ; load t.10{r7}, [t.11{r7}]
        mov r12b, [r12]
        ; cast t.9{r1}(i64), t.10{r7}(u8)
        movzx rcx, r12b
        ; call printIntLf[t.9{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 12:17 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=12:13].y
        ; addrof t.14{r7}, pos
        lea r12, [rsp+16]
        ; inc t.14{r7}
        inc r12
        ; load t.13{r7}, [t.14{r7}]
        mov r12b, [r12]
        ; cast t.12{r1}(i64), t.13{r7}(u8)
        movzx rcx, r12b
        ; call printIntLf[t.12{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 13:15 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=13:11].x
        ; addrof x{r6}, pos
        lea rbx, [rsp+16]
        ; load t.16{r6}, [x{r6}]
        mov bl, [rbx]
        ; cast t.15{r1}(i64), t.16{r6}(u8)
        movzx rcx, bl
        ; call printIntLf[t.15{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength
@printStringLength:
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
