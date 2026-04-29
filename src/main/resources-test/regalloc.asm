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
        sub rsp, 8
          call init
        add rsp, 8
          call @main
        mov rcx, 0
        sub rsp, 0x20
          call [ExitProcess]

        ; u8 simple
        ;   rsp+0: var four
        ;   rsp+1: var three
        ;   rsp+2: var one
@simple:
        ; reserve space for local variables
        sub rsp, 16
        ; const four, 4
        mov al, 4
        lea rbx, [rsp+0]
        mov [rbx], al
        ; const three, 3
        mov al, 3
        lea rbx, [rsp+1]
        mov [rbx], al
        ; move one, four
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov [rax], bl
        ; sub one, one, three
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+2]
        mov [rax], bl
        ; 5:9 return one
        ; ret one
        lea rax, [rsp+2]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; u8 registerHint@u8@u8
        ;   rsp+40: arg a
        ;   rsp+32: arg b
        ;   rsp+0: var t.2
@registerHint@u8@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; 9:11 return a + b
        ; move t.2, a
        lea rax, [rsp+40]
        mov bl, [rax]
        lea rax, [rsp+0]
        mov [rax], bl
        ; add t.2, t.2, b
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+0]
        mov [rax], bl
        ; ret t.2
        lea rax, [rsp+0]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; u8 max@u8@u8
        ;   rsp+40: arg a
        ;   rsp+32: arg b
        ;   rsp+0: var t.2
@max@u8@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; 13:2 if a < b
        ; lt t.2, a, b
        lea rax, [rsp+40]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.2, true, @if_1_then, @if_1_end
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jnz @if_1_then
        ; 16:9 return a
        ; ret a
        lea rax, [rsp+40]
        mov bl, [rax]
        mov rax, rbx
        jmp @max@u8@u8_ret
@if_1_then:
        ; 14:10 return b
        ; ret b
        lea rax, [rsp+32]
        mov bl, [rax]
        mov rax, rbx
@max@u8@u8_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; i16 fibonacci@u8
        ;   rsp+24: arg i
        ;   rsp+0: var a
        ;   rsp+2: var b
        ;   rsp+4: var c
        ;   rsp+6: var t.4
@fibonacci@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; const a, 0
        mov ax, 0
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; const b, 1
        mov ax, 1
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; 22:2 while i > 0
        jmp @while_2
@while_2_body:
        ; dec i
        lea rax, [rsp+24]
        mov bl, [rax]
        dec bl
        lea rax, [rsp+24]
        mov [rax], bl
        ; move c, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
        ; add c, c, b
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+4]
        mov [rax], bx
        ; move a, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov [rax], bx
        ; move b, c
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
@while_2:
        ; gt t.4, i, 0
        lea rax, [rsp+24]
        mov bl, [rax]
        cmp bl, 0
        seta bl
        lea rax, [rsp+6]
        mov [rax], bl
        ; branch t.4, true, @while_2_body, @while_2_break
        lea rax, [rsp+6]
        mov bl, [rax]
        or bl, bl
        jnz @while_2_body
        ; 28:9 return a
        ; ret a
        lea rax, [rsp+0]
        mov bx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
        ;   rsp+0: var one
        ;   rsp+1: var two
        ;   rsp+2: var oneOrTwo
        ;   rsp+4: var f5
        ;   rsp+6: var t.4
@main:
        ; reserve space for local variables
        sub rsp, 16
        ; call one = simple[] -> u8
        sub rsp, 8
          call @simple
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], al
        ; const two, 2
        mov al, 2
        lea rbx, [rsp+1]
        mov [rbx], al
        ; call _ = registerHint@u8@u8[one, two] -> u8
        lea rax, [rsp+0]
        mov bl, [rax]
        push rbx
        lea rax, [rsp+9]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call @registerHint@u8@u8
        add rsp, 24
        ; call _ = max@u8@u8[one, two] -> u8
        lea rax, [rsp+0]
        mov bl, [rax]
        push rbx
        lea rax, [rsp+9]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call @max@u8@u8
        add rsp, 24
        ; const t.4, 5
        mov al, 5
        lea rbx, [rsp+6]
        mov [rbx], al
        ; call _ = fibonacci@u8[t.4] -> i16
        lea rax, [rsp+6]
        mov bl, [rax]
        push rbx
          call @fibonacci@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret
init:
        sub rsp, 20h
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
        add rsp, 20h
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
