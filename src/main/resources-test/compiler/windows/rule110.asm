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
          call _main
        mov rcx, 0
        sub rsp, 0x20
          call [ExitProcess]

        ; void printString@@u8
        ;   rsp+24: arg str
        ;   rsp+0: var length.1
_printString@@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; call length.1 = strlen@@u8[str] -> i64
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call _strlen@@u8
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@i64[str, length.1]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call _printStringLength@@u8@i64
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printChar@u8
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1.1
_printChar@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof t.1.1, chr
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@u8[t.1.1, 1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
        mov  rax, 1
        push rax
        sub rsp, 8
          call _printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; i64 strlen@@u8
        ;   rsp+56: arg str
        ;   rsp+0: var length.1
        ;   rsp+8: var str.1
        ;   rsp+16: var length.2
        ;   rsp+24: var t.2.1
        ;   rsp+32: var length.3
        ;   rsp+40: var str.2
_strlen@@u8:
        ; reserve space for local variables
        sub rsp, 48
        ; const length.1, 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 64:2 for *str != 0
        ; move str.1, str
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov [rax], rbx
        ; move length.2, length.1
        lea rax, [rsp+0]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov [rax], rbx
        jmp _for_1
_for_1_body:
        ; move length.3, length.2
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov [rax], rbx
        ; add length.3, length.3, 1
        lea rax, [rsp+32]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+32]
        mov [rax], rbx
        ; move str.2, str.1
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov [rax], rbx
        ; add str.2, str.2, 1
        lea rax, [rsp+40]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+40]
        mov [rax], rbx
        ; move str.1, str.2
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov [rax], rbx
        ; move length.2, length.3
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov [rax], rbx
_for_1:
        ; load t.2.1, [str.1]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+24]
        mov [rbx], al
        ; branch t.2.1 notequals 0: for_1_body, for_1_break
        lea rax, [rsp+24]
        mov bl, [rax]
        cmp bl, 0
        jne _for_1_body
        ; 67:9 return length
        ; ret length.2
        lea rax, [rsp+16]
        mov rbx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 48
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+40: arg str
        ;   rsp+32: arg length
        ;   rsp+0: var t.2.1
_printStringLength@@u8@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.2.1(i64), length(u8)
        lea rax, [rsp+32]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printStringLength@@u8@i64[str, t.2.1]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call _printStringLength@@u8@i64
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printBoard
        ;   rsp+0: var i.1
        ;   rsp+1: var i.2
        ;   rsp+8: var t.4.1
        ;   rsp+16: var t.3.1
        ;   rsp+24: var t.2.1
        ;   rsp+32: var t.2.2
        ;   rsp+40: var t.1.1
        ;   rsp+41: var i.4
_printBoard:
        ; reserve space for local variables
        sub rsp, 48
        ; call printChar@u8[124]
        mov  rax, 124
        push rax
          call _printChar@u8
        add rsp, 8
        ; const i.1, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 11:2 for i < 30
        ; move i.2, i.1
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
        jmp _for_2
_for_2_body:
        ; 12:3 if [...] == 0
        ; cast t.3.1(i64), i.2(u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+16]
        mov [rax], rbx
        ; addrof t.2.1, [board]
        lea rax, [var_0]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; move t.2.2, t.2.1
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov [rax], rbx
        ; add t.2.2, t.2.2, t.3.1
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+32]
        mov [rax], rbx
        ; load t.1.1, [t.2.2]
        lea rax, [rsp+32]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+40]
        mov [rbx], al
        ; branch t.1.1 equals 0: if_3_then, if_3_else
        lea rax, [rsp+40]
        mov bl, [rax]
        cmp bl, 0
        je _if_3_then
        ; call printChar@u8[42]
        mov  rax, 42
        push rax
          call _printChar@u8
        add rsp, 8
        jmp _for_2_continue
_if_3_then:
        ; call printChar@u8[32]
        mov  rax, 32
        push rax
          call _printChar@u8
        add rsp, 8
_for_2_continue:
        ; move i.4, i.2
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+41]
        mov [rax], bl
        ; add i.4, i.4, 1
        lea rax, [rsp+41]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+41]
        mov [rax], bl
        ; move i.2, i.4
        lea rax, [rsp+41]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
_for_2:
        ; branch i.2 lt 30: for_2_body, for_2_break
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 30
        jb _for_2_body
        ; const t.4.1, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call printString@@u8[t.4.1]
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 48
        ret

        ; void main
        ;   rsp+0: var i.1
        ;   rsp+1: var i.2
        ;   rsp+2: var t.7.1
        ;   rsp+8: var t.9.1
        ;   rsp+16: var t.8.1
        ;   rsp+24: var t.8.2
        ;   rsp+32: var i.3
        ;   rsp+33: var i.4
        ;   rsp+34: var t.4.1
        ;   rsp+40: var t.6.1
        ;   rsp+48: var t.5.1
        ;   rsp+56: var t.5.2
        ;   rsp+64: var i.5
        ;   rsp+72: var t.13.1
        ;   rsp+80: var t.12.1
        ;   rsp+88: var t.12.2
        ;   rsp+96: var t.11.1
        ;   rsp+97: var t.10.1
        ;   rsp+104: var t.16.1
        ;   rsp+112: var t.15.1
        ;   rsp+120: var t.15.2
        ;   rsp+128: var t.14.1
        ;   rsp+129: var pattern.1
        ;   rsp+130: var j.1
        ;   rsp+131: var pattern.2
        ;   rsp+132: var j.2
        ;   rsp+133: var i.7
        ;   rsp+134: var t.18.1
        ;   rsp+135: var t.17.1
        ;   rsp+136: var t.22.1
        ;   rsp+144: var t.21.1
        ;   rsp+152: var t.20.1
        ;   rsp+160: var t.20.2
        ;   rsp+168: var t.19.1
        ;   rsp+169: var pattern.3
        ;   rsp+170: var t.25.1
        ;   rsp+171: var t.24.1
        ;   rsp+172: var t.23.1
        ;   rsp+176: var t.27.1
        ;   rsp+184: var t.26.1
        ;   rsp+192: var t.26.2
        ;   rsp+200: var j.3
_main:
        ; reserve space for local variables
        sub rsp, 208
        ; const i.1, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 23:2 for i < 30
        ; move i.2, i.1
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
        jmp _for_4
_for_4_body:
        ; const t.4.1, 0
        mov al, 0
        lea rbx, [rsp+34]
        mov [rbx], al
        ; cast t.6.1(i64), i.2(u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+40]
        mov [rax], rbx
        ; addrof t.5.1, [board]
        lea rax, [var_0]
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; move t.5.2, t.5.1
        lea rax, [rsp+48]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], rbx
        ; add t.5.2, t.5.2, t.6.1
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+56]
        mov [rax], rbx
        ; store [t.5.2], t.4.1
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+34]
        mov cl, [rax]
        mov [rbx], cl
        ; move i.5, i.2
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+64]
        mov [rax], bl
        ; add i.5, i.5, 1
        lea rax, [rsp+64]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+64]
        mov [rax], bl
        ; move i.2, i.5
        lea rax, [rsp+64]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
_for_4:
        ; branch i.2 lt 30: for_4_body, for_4_break
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 30
        jb _for_4_body
        ; const t.7.1, 1
        mov al, 1
        lea rbx, [rsp+2]
        mov [rbx], al
        ; const t.9.1, 29
        mov rax, 29
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; addrof t.8.1, [board]
        lea rax, [var_0]
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; move t.8.2, t.8.1
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; add t.8.2, t.8.2, t.9.1
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+24]
        mov [rax], rbx
        ; store [t.8.2], t.7.1
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+2]
        mov cl, [rax]
        mov [rbx], cl
        ; call printBoard[]
        sub rsp, 8
          call _printBoard
        add rsp, 8
        ; const i.3, 0
        mov al, 0
        lea rbx, [rsp+32]
        mov [rbx], al
        ; 30:2 for i < 28
        ; move i.4, i.3
        lea rax, [rsp+32]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov [rax], bl
        jmp _for_5
_for_5_body:
        ; const t.13.1, 0
        mov rax, 0
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; addrof t.12.1, [board]
        lea rax, [var_0]
        lea rbx, [rsp+80]
        mov [rbx], rax
        ; move t.12.2, t.12.1
        lea rax, [rsp+80]
        mov rbx, [rax]
        lea rax, [rsp+88]
        mov [rax], rbx
        ; add t.12.2, t.12.2, t.13.1
        lea rax, [rsp+88]
        mov rbx, [rax]
        lea rax, [rsp+72]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+88]
        mov [rax], rbx
        ; load t.11.1, [t.12.2]
        lea rax, [rsp+88]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+96]
        mov [rbx], al
        ; move t.10.1, t.11.1
        lea rax, [rsp+96]
        mov bl, [rax]
        lea rax, [rsp+97]
        mov [rax], bl
        ; shiftleft t.10.1, t.10.1, 1
        lea rax, [rsp+97]
        mov bl, [rax]
        shl bl, 1
        lea rax, [rsp+97]
        mov [rax], bl
        ; const t.16.1, 1
        mov rax, 1
        lea rbx, [rsp+104]
        mov [rbx], rax
        ; addrof t.15.1, [board]
        lea rax, [var_0]
        lea rbx, [rsp+112]
        mov [rbx], rax
        ; move t.15.2, t.15.1
        lea rax, [rsp+112]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov [rax], rbx
        ; add t.15.2, t.15.2, t.16.1
        lea rax, [rsp+120]
        mov rbx, [rax]
        lea rax, [rsp+104]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+120]
        mov [rax], rbx
        ; load t.14.1, [t.15.2]
        lea rax, [rsp+120]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+128]
        mov [rbx], al
        ; move pattern.1, t.10.1
        lea rax, [rsp+97]
        mov bl, [rax]
        lea rax, [rsp+129]
        mov [rax], bl
        ; or pattern.1, pattern.1, t.14.1
        lea rax, [rsp+129]
        mov bl, [rax]
        lea rax, [rsp+128]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+129]
        mov [rax], bl
        ; const j.1, 1
        mov al, 1
        lea rbx, [rsp+130]
        mov [rbx], al
        ; 32:3 for j < 29
        ; move pattern.2, pattern.1
        lea rax, [rsp+129]
        mov bl, [rax]
        lea rax, [rsp+131]
        mov [rax], bl
        ; move j.2, j.1
        lea rax, [rsp+130]
        mov bl, [rax]
        lea rax, [rsp+132]
        mov [rax], bl
        jmp _for_6
_for_6_body:
        ; move t.18.1, pattern.2
        lea rax, [rsp+131]
        mov bl, [rax]
        lea rax, [rsp+134]
        mov [rax], bl
        ; shiftleft t.18.1, t.18.1, 1
        lea rax, [rsp+134]
        mov bl, [rax]
        shl bl, 1
        lea rax, [rsp+134]
        mov [rax], bl
        ; move t.17.1, t.18.1
        lea rax, [rsp+134]
        mov bl, [rax]
        lea rax, [rsp+135]
        mov [rax], bl
        ; and t.17.1, t.17.1, 7
        lea rax, [rsp+135]
        mov bl, [rax]
        and bl, 7
        lea rax, [rsp+135]
        mov [rax], bl
        ; move t.22.1, j.2
        lea rax, [rsp+132]
        mov bl, [rax]
        lea rax, [rsp+136]
        mov [rax], bl
        ; add t.22.1, t.22.1, 1
        lea rax, [rsp+136]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+136]
        mov [rax], bl
        ; cast t.21.1(i64), t.22.1(u8)
        lea rax, [rsp+136]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+144]
        mov [rax], rbx
        ; addrof t.20.1, [board]
        lea rax, [var_0]
        lea rbx, [rsp+152]
        mov [rbx], rax
        ; move t.20.2, t.20.1
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+160]
        mov [rax], rbx
        ; add t.20.2, t.20.2, t.21.1
        lea rax, [rsp+160]
        mov rbx, [rax]
        lea rax, [rsp+144]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+160]
        mov [rax], rbx
        ; load t.19.1, [t.20.2]
        lea rax, [rsp+160]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+168]
        mov [rbx], al
        ; move pattern.3, t.17.1
        lea rax, [rsp+135]
        mov bl, [rax]
        lea rax, [rsp+169]
        mov [rax], bl
        ; or pattern.3, pattern.3, t.19.1
        lea rax, [rsp+169]
        mov bl, [rax]
        lea rax, [rsp+168]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+169]
        mov [rax], bl
        ; const t.25.1, 110
        mov al, 110
        lea rbx, [rsp+170]
        mov [rbx], al
        ; move t.24.1, t.25.1
        lea rax, [rsp+170]
        mov bl, [rax]
        lea rax, [rsp+171]
        mov [rax], bl
        ; shiftright t.24.1, t.24.1, pattern.3
        lea rax, [rsp+171]
        mov bl, [rax]
        lea rax, [rsp+169]
        mov cl, [rax]
        shr bl, cl
        lea rax, [rsp+171]
        mov [rax], bl
        ; move t.23.1, t.24.1
        lea rax, [rsp+171]
        mov bl, [rax]
        lea rax, [rsp+172]
        mov [rax], bl
        ; and t.23.1, t.23.1, 1
        lea rax, [rsp+172]
        mov bl, [rax]
        and bl, 1
        lea rax, [rsp+172]
        mov [rax], bl
        ; cast t.27.1(i64), j.2(u8)
        lea rax, [rsp+132]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+176]
        mov [rax], rbx
        ; addrof t.26.1, [board]
        lea rax, [var_0]
        lea rbx, [rsp+184]
        mov [rbx], rax
        ; move t.26.2, t.26.1
        lea rax, [rsp+184]
        mov rbx, [rax]
        lea rax, [rsp+192]
        mov [rax], rbx
        ; add t.26.2, t.26.2, t.27.1
        lea rax, [rsp+192]
        mov rbx, [rax]
        lea rax, [rsp+176]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+192]
        mov [rax], rbx
        ; store [t.26.2], t.23.1
        lea rax, [rsp+192]
        mov rbx, [rax]
        lea rax, [rsp+172]
        mov cl, [rax]
        mov [rbx], cl
        ; move j.3, j.2
        lea rax, [rsp+132]
        mov bl, [rax]
        lea rax, [rsp+200]
        mov [rax], bl
        ; add j.3, j.3, 1
        lea rax, [rsp+200]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+200]
        mov [rax], bl
        ; move pattern.2, pattern.3
        lea rax, [rsp+169]
        mov bl, [rax]
        lea rax, [rsp+131]
        mov [rax], bl
        ; move j.2, j.3
        lea rax, [rsp+200]
        mov bl, [rax]
        lea rax, [rsp+132]
        mov [rax], bl
_for_6:
        ; branch j.2 lt 29: for_6_body, for_6_break
        lea rax, [rsp+132]
        mov bl, [rax]
        cmp bl, 29
        jb _for_6_body
        ; call printBoard[]
        sub rsp, 8
          call _printBoard
        add rsp, 8
        ; move i.7, i.4
        lea rax, [rsp+33]
        mov bl, [rax]
        lea rax, [rsp+133]
        mov [rax], bl
        ; add i.7, i.7, 1
        lea rax, [rsp+133]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+133]
        mov [rax], bl
        ; move i.4, i.7
        lea rax, [rsp+133]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov [rax], bl
_for_5:
        ; branch i.4 lt 28: for_5_body, main_ret
        lea rax, [rsp+33]
        mov bl, [rax]
        cmp bl, 28
        jb _for_5_body
        ; release space for local variables
        add rsp, 208
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
        mov     rdi, rsp

        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        mov     rdx, [rdi+18h]
        mov     r8, [rdi+10h]
        xor     r9, r9
        push    0
        sub     rsp, 20h
          call    [WriteFile]
        mov     rsp, rdi
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
        ; variable 0: board[] (u8*/240)
        var_0 rb 240

section '.data' data readable
        string_0 db '|', 0x0a, 0x00

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
