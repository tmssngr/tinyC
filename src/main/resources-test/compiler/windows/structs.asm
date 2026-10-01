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
        ;   rsp+64: arg chr
_printChar@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], chr{r1}
        mov [r12], cl
        ; move t.1.1{r1}, t.1.1{r7}
        mov rcx, r12
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+80: arg number
        ;   rsp+40: var buffer
_printUint@i64:
        sub rsp, 32
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const pos.1{r6}, 20
        mov bl, 20
        ; 28:2 while true
        ; move number.1{r3}, number{r1}
        mov r8, rcx
_while_1:
        ; sub pos.3{r6}, 1
        sub bl, 1
        ; move remainder.1{r4}, number.1{r3}
        mov r9, r8
        ; move remainder.1{r0}, remainder.1{r4}
        mov rax, r9
        ; mod remainder.1{r2}, remainder.1{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder.1{r4}, remainder.1{r2}
        mov r9, rdx
        ; move number.2{r0}, number.2{r3}
        mov rax, r8
        ; div number.2{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number.2{r3}, number.2{r0}
        mov r8, rax
        ; cast t.5.1{r0}(u8), remainder.1{r4}(i64)
        mov al, r9b
        ; add digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r4}(i64), pos.3{r6}(u8)
        movzx r9, bl
        ; addrof t.6.1{r5}, buffer
        lea r10, [rsp+40]
        ; add t.6.2{r5}, t.7.1{r4}
        add r10, r9
        ; store [t.6.2{r5}], digit.1{r0}
        mov [r10], al
        ; 34:3 if number == 0
        ; branch number.2{r3} notequals 0: while_1
        cmp r8, 0
        jne _while_1
        ; move t.9.1{r0}, t.9.1{r4}
        mov rax, r9
        ; addrof t.8.1{r3}, buffer
        lea r8, [rsp+40]
        ; move t.8.2{r1}, t.8.1{r3}
        mov rcx, r8
        ; move t.8.2{r1}, t.8.2{r5}
        mov rcx, r10
        ; const t.11.1{r0}, 20
        mov al, 20
        ; move t.10.1{r2}, t.11.1{r0}
        mov dl, al
        ; sub t.10.1{r2}, pos.3{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        add rsp, 32
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
        ; branch number{r6} gteq 0: printIntLf@i64.no_critical_edge_4
        cmp rbx, 0
        jge _printIntLf@i64.no_critical_edge_4
        ; const arg.0.0{r1}, 45
        mov cl, 45
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; neg number.2{r6}, number{r6}
        neg rbx
        ; move number.1{r1}, number.2{r6}
        mov rcx, rbx
        jmp _if_3_end
_printIntLf@i64.no_critical_edge_4:
        ; move number.1{r1}, number{r6}
        mov rcx, rbx
_if_3_end:
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

        ; void main
        ;   rsp+40: var pos
_main:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const t.2.1{r6}, 1
        mov bl, 1
        ; 9:6 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=9:2].x
        ; addrof t.3.1{r0}, pos
        lea rax, [rsp+40]
        ; store [t.3.1{r0}], t.2.1{r6}
        mov [rax], bl
        ; 10:14 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=10:10].x
        ; move t.6.1{r6}, t.6.1{r0}
        mov rbx, rax
        ; load t.5.1{r6}, [t.6.1{r6}]
        mov bl, [rbx]
        ; add t.4.1{r6}, 1
        add bl, 1
        ; 10:6 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=10:2].y
        ; add t.7.2{r0}, 1
        add rax, 1
        ; store [t.7.2{r0}], t.4.1{r6}
        mov [rax], bl
        ; 11:17 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=11:13].x
        ; addrof t.9.1{r6}, pos
        lea rbx, [rsp+40]
        ; load t.8.1{r1}, [t.9.1{r6}]
        mov cl, [rbx]
        ; call printIntLf@u8[t.8.1{r1}]
        call _printIntLf@u8
        ; 12:17 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=12:13].y
        ; add t.11.2{r6}, 1
        add rbx, 1
        ; load t.10.1{r1}, [t.11.2{r6}]
        mov cl, [rbx]
        ; call printIntLf@u8[t.10.1{r1}]
        call _printIntLf@u8
        ; 13:15 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=13:11].x
        ; addrof x.1{r6}, pos
        lea rbx, [rsp+40]
        ; load t.12.1{r1}, [x.1{r6}]
        mov cl, [rbx]
        ; call printIntLf@u8[t.12.1{r1}]
        call _printIntLf@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        add rsp, 16
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
