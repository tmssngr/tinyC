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

        ; void printString
        ;   rsp+24: arg str
        ;   rsp+0: var length
@printString:
        ; reserve space for local variables
        sub rsp, 16
        ; call length(1@function,i64), strlen, [str(0@argument,u8*)]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @strlen
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call _, printStringLength [str(0@argument,u8*), length(1@function,i64)]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printString_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printChar
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
@printChar:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof t.1(1@function,u8*), chr(0@argument,u8)
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; const t.2(2@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call _, printStringLength [t.1(1@function,u8*), t.2(2@function,i64)]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printChar_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; i64 strlen
        ;   rsp+56: arg str
        ;   rsp+0: var length
        ;   rsp+8: var t.2
        ;   rsp+9: var t.3
        ;   rsp+10: var t.4
        ;   rsp+16: var t.5
        ;   rsp+24: var t.6
        ;   rsp+32: var t.7
        ;   rsp+40: var t.8
@strlen:
        ; reserve space for local variables
        sub rsp, 48
        ; const length(1@function,i64), 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 37:2 for *str != 0
@for_1:
        ; load t.3(3@function,u8), [str(0@argument,u8*)]
        lea rax, [rsp+56]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+9]
        mov [rbx], al
        ; const t.4(4@function,u8), 0
        mov al, 0
        lea rbx, [rsp+10]
        mov [rbx], al
        ; notequals t.2(2@function,bool), t.3(3@function,u8), t.4(4@function,u8)
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+10]
        mov cl, [rax]
        cmp bl, cl
        setne bl
        lea rax, [rsp+8]
        mov [rax], bl
        ; branch t.2(2@function,bool), false, @for_1_break
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jz @for_1_break
        ; @for_1_body
        ; const t.5(5@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; add length(1@function,i64), length(1@function,i64), t.5(5@function,i64)
        lea rax, [rsp+0]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+0]
        mov [rax], rbx
@for_1_continue:
        ; cast t.7(7@function,i64), str(0@argument,u8*)
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov [rax], rbx
        ; const t.8(8@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; add t.6(6@function,i64), t.7(7@function,i64), t.8(8@function,i64)
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+24]
        mov [rax], rbx
        ; cast str(0@argument,u8*), t.6(6@function,i64)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], rbx
        ; jump @for_1
        jmp @for_1
@for_1_break:
        ; 40:9 return length
        ; ret length(1@function,i64)
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        ; jump @strlen_ret
        jmp @strlen_ret
@strlen_ret:
        ; release space for local variables
        add rsp, 48
        ret

        ; void printStringLength
@printStringLength:
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

        ; void printBoard
        ;   rsp+0: var i
        ;   rsp+1: var t.1
        ;   rsp+2: var t.2
        ;   rsp+3: var t.3
        ;   rsp+4: var t.4
        ;   rsp+5: var t.5
        ;   rsp+8: var t.6
        ;   rsp+16: var t.7
        ;   rsp+24: var t.8
        ;   rsp+25: var t.9
        ;   rsp+26: var t.10
        ;   rsp+27: var t.11
        ;   rsp+32: var t.12
@printBoard:
        ; reserve space for local variables
        sub rsp, 48
        ; const t.1(1@function,u8), 124
        mov al, 124
        lea rbx, [rsp+1]
        mov [rbx], al
        ; call _, printChar [t.1(1@function,u8)]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; const i(0@function,u8), 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 11:2 for i < 30
@for_2:
        ; const t.3(3@function,u8), 30
        mov al, 30
        lea rbx, [rsp+3]
        mov [rbx], al
        ; lt t.2(2@function,bool), i(0@function,u8), t.3(3@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+3]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+2]
        mov [rax], bl
        ; branch t.2(2@function,bool), false, @for_2_break
        lea rax, [rsp+2]
        mov bl, [rax]
        or bl, bl
        jz @for_2_break
        ; @for_2_body
        ; 12:3 if [...] == 0
        ; cast t.6(6@function,i64), i(0@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+8]
        mov [rax], rbx
        ; array t.7(7@function,u8*), board(0@global,u8*) + t.6(6@function,i64)
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; load t.5(5@function,u8), [t.7(7@function,u8*)]
        lea rax, [rsp+16]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+5]
        mov [rbx], al
        ; const t.8(8@function,u8), 0
        mov al, 0
        lea rbx, [rsp+24]
        mov [rbx], al
        ; equals t.4(4@function,bool), t.5(5@function,u8), t.8(8@function,u8)
        lea rax, [rsp+5]
        mov bl, [rax]
        lea rax, [rsp+24]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+4]
        mov [rax], bl
        ; branch t.4(4@function,bool), false, @if_3_else
        lea rax, [rsp+4]
        mov bl, [rax]
        or bl, bl
        jz @if_3_else
        ; @if_3_then
        ; const t.9(9@function,u8), 32
        mov al, 32
        lea rbx, [rsp+25]
        mov [rbx], al
        ; call _, printChar [t.9(9@function,u8)]
        lea rax, [rsp+25]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; jump @if_3_end
        jmp @if_3_end
@if_3_else:
        ; const t.10(10@function,u8), 42
        mov al, 42
        lea rbx, [rsp+26]
        mov [rbx], al
        ; call _, printChar [t.10(10@function,u8)]
        lea rax, [rsp+26]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
@if_3_end:
@for_2_continue:
        ; const t.11(11@function,u8), 1
        mov al, 1
        lea rbx, [rsp+27]
        mov [rbx], al
        ; add i(0@function,u8), i(0@function,u8), t.11(11@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+27]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+0]
        mov [rax], bl
        ; jump @for_2
        jmp @for_2
@for_2_break:
        ; const t.12(12@function,u8*), [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; call _, printString [t.12(12@function,u8*)]
        lea rax, [rsp+32]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
@printBoard_ret:
        ; release space for local variables
        add rsp, 48
        ret

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var i
        ;   rsp+2: var pattern
        ;   rsp+3: var j
        ;   rsp+4: var t.4
        ;   rsp+5: var t.5
        ;   rsp+6: var t.6
        ;   rsp+8: var t.7
        ;   rsp+16: var t.8
        ;   rsp+24: var t.9
        ;   rsp+25: var t.10
        ;   rsp+32: var t.11
        ;   rsp+40: var t.12
        ;   rsp+48: var t.13
        ;   rsp+56: var t.14
        ;   rsp+57: var t.15
        ;   rsp+58: var t.16
        ;   rsp+59: var t.17
        ;   rsp+64: var t.18
        ;   rsp+72: var t.19
        ;   rsp+80: var t.20
        ;   rsp+81: var t.21
        ;   rsp+88: var t.22
        ;   rsp+96: var t.23
        ;   rsp+104: var t.24
        ;   rsp+105: var t.25
        ;   rsp+106: var t.26
        ;   rsp+107: var t.27
        ;   rsp+108: var t.28
        ;   rsp+109: var t.29
        ;   rsp+110: var t.30
        ;   rsp+112: var t.31
        ;   rsp+120: var t.32
        ;   rsp+121: var t.33
        ;   rsp+128: var t.34
        ;   rsp+136: var t.35
        ;   rsp+137: var t.36
        ;   rsp+138: var t.37
        ;   rsp+139: var t.38
        ;   rsp+144: var t.39
        ;   rsp+152: var t.40
        ;   rsp+160: var t.41
        ;   rsp+161: var t.42
@main:
        ; reserve space for local variables
        sub rsp, 176
        ; const i(0@function,u8), 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 23:2 for i < 30
@for_4:
        ; const t.5(5@function,u8), 30
        mov al, 30
        lea rbx, [rsp+5]
        mov [rbx], al
        ; lt t.4(4@function,bool), i(0@function,u8), t.5(5@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+5]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+4]
        mov [rax], bl
        ; branch t.4(4@function,bool), false, @for_4_break
        lea rax, [rsp+4]
        mov bl, [rax]
        or bl, bl
        jz @for_4_break
        ; @for_4_body
        ; const t.6(6@function,u8), 0
        mov al, 0
        lea rbx, [rsp+6]
        mov [rbx], al
        ; cast t.7(7@function,i64), i(0@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+8]
        mov [rax], rbx
        ; array t.8(8@function,u8*), board(0@global,u8*) + t.7(7@function,i64)
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; store [t.8(8@function,u8*)], t.6(6@function,u8)
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+6]
        mov cl, [rax]
        mov [rbx], cl
@for_4_continue:
        ; const t.9(9@function,u8), 1
        mov al, 1
        lea rbx, [rsp+24]
        mov [rbx], al
        ; add i(0@function,u8), i(0@function,u8), t.9(9@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+24]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+0]
        mov [rax], bl
        ; jump @for_4
        jmp @for_4
@for_4_break:
        ; const t.10(10@function,u8), 1
        mov al, 1
        lea rbx, [rsp+25]
        mov [rbx], al
        ; const t.12(12@function,u8), 29
        mov al, 29
        lea rbx, [rsp+40]
        mov [rbx], al
        ; cast t.11(11@function,i64), t.12(12@function,u8)
        lea rax, [rsp+40]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+32]
        mov [rax], rbx
        ; array t.13(13@function,u8*), board(0@global,u8*) + t.11(11@function,i64)
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; store [t.13(13@function,u8*)], t.10(10@function,u8)
        lea rax, [rsp+48]
        mov rbx, [rax]
        lea rax, [rsp+25]
        mov cl, [rax]
        mov [rbx], cl
        ; call _, printBoard []
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; const i(1@function,u8), 0
        mov al, 0
        lea rbx, [rsp+1]
        mov [rbx], al
        ; 30:2 for i < 28
@for_5:
        ; const t.15(15@function,u8), 28
        mov al, 28
        lea rbx, [rsp+57]
        mov [rbx], al
        ; lt t.14(14@function,bool), i(1@function,u8), t.15(15@function,u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+56]
        mov [rax], bl
        ; branch t.14(14@function,bool), false, @for_5_break
        lea rax, [rsp+56]
        mov bl, [rax]
        or bl, bl
        jz @for_5_break
        ; @for_5_body
        ; const t.18(18@function,i64), 0
        mov rax, 0
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; array t.19(19@function,u8*), board(0@global,u8*) + t.18(18@function,i64)
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; load t.17(17@function,u8), [t.19(19@function,u8*)]
        lea rax, [rsp+72]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+59]
        mov [rbx], al
        ; const t.20(20@function,u8), 1
        mov al, 1
        lea rbx, [rsp+80]
        mov [rbx], al
        ; shiftleft t.16(16@function,u8), t.17(17@function,u8), t.20(20@function,u8)
        lea rax, [rsp+59]
        mov bl, [rax]
        lea rax, [rsp+80]
        mov cl, [rax]
        shl bl, cl
        lea rax, [rsp+58]
        mov [rax], bl
        ; const t.22(22@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+88]
        mov [rbx], rax
        ; array t.23(23@function,u8*), board(0@global,u8*) + t.22(22@function,i64)
        lea rax, [rsp+88]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; load t.21(21@function,u8), [t.23(23@function,u8*)]
        lea rax, [rsp+96]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+81]
        mov [rbx], al
        ; or pattern(2@function,u8), t.16(16@function,u8), t.21(21@function,u8)
        lea rax, [rsp+58]
        mov bl, [rax]
        lea rax, [rsp+81]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+2]
        mov [rax], bl
        ; const j(3@function,u8), 1
        mov al, 1
        lea rbx, [rsp+3]
        mov [rbx], al
        ; 32:3 for j < 29
@for_6:
        ; const t.25(25@function,u8), 29
        mov al, 29
        lea rbx, [rsp+105]
        mov [rbx], al
        ; lt t.24(24@function,bool), j(3@function,u8), t.25(25@function,u8)
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+105]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+104]
        mov [rax], bl
        ; branch t.24(24@function,bool), false, @for_6_break
        lea rax, [rsp+104]
        mov bl, [rax]
        or bl, bl
        jz @for_6_break
        ; @for_6_body
        ; const t.28(28@function,u8), 1
        mov al, 1
        lea rbx, [rsp+108]
        mov [rbx], al
        ; shiftleft t.27(27@function,u8), pattern(2@function,u8), t.28(28@function,u8)
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+108]
        mov cl, [rax]
        shl bl, cl
        lea rax, [rsp+107]
        mov [rax], bl
        ; const t.29(29@function,u8), 7
        mov al, 7
        lea rbx, [rsp+109]
        mov [rbx], al
        ; and t.26(26@function,u8), t.27(27@function,u8), t.29(29@function,u8)
        lea rax, [rsp+107]
        mov bl, [rax]
        lea rax, [rsp+109]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+106]
        mov [rax], bl
        ; const t.33(33@function,u8), 1
        mov al, 1
        lea rbx, [rsp+121]
        mov [rbx], al
        ; add t.32(32@function,u8), j(3@function,u8), t.33(33@function,u8)
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+121]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+120]
        mov [rax], bl
        ; cast t.31(31@function,i64), t.32(32@function,u8)
        lea rax, [rsp+120]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+112]
        mov [rax], rbx
        ; array t.34(34@function,u8*), board(0@global,u8*) + t.31(31@function,i64)
        lea rax, [rsp+112]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+128]
        mov [rbx], rax
        ; load t.30(30@function,u8), [t.34(34@function,u8*)]
        lea rax, [rsp+128]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+110]
        mov [rbx], al
        ; or pattern(2@function,u8), t.26(26@function,u8), t.30(30@function,u8)
        lea rax, [rsp+106]
        mov bl, [rax]
        lea rax, [rsp+110]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+2]
        mov [rax], bl
        ; const t.37(37@function,u8), 110
        mov al, 110
        lea rbx, [rsp+138]
        mov [rbx], al
        ; shiftright t.36(36@function,u8), t.37(37@function,u8), pattern(2@function,u8)
        lea rax, [rsp+138]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov cl, [rax]
        shr bl, cl
        lea rax, [rsp+137]
        mov [rax], bl
        ; const t.38(38@function,u8), 1
        mov al, 1
        lea rbx, [rsp+139]
        mov [rbx], al
        ; and t.35(35@function,u8), t.36(36@function,u8), t.38(38@function,u8)
        lea rax, [rsp+137]
        mov bl, [rax]
        lea rax, [rsp+139]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+136]
        mov [rax], bl
        ; cast t.39(39@function,i64), j(3@function,u8)
        lea rax, [rsp+3]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+144]
        mov [rax], rbx
        ; array t.40(40@function,u8*), board(0@global,u8*) + t.39(39@function,i64)
        lea rax, [rsp+144]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+152]
        mov [rbx], rax
        ; store [t.40(40@function,u8*)], t.35(35@function,u8)
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+136]
        mov cl, [rax]
        mov [rbx], cl
@for_6_continue:
        ; const t.41(41@function,u8), 1
        mov al, 1
        lea rbx, [rsp+160]
        mov [rbx], al
        ; add j(3@function,u8), j(3@function,u8), t.41(41@function,u8)
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+160]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+3]
        mov [rax], bl
        ; jump @for_6
        jmp @for_6
@for_6_break:
        ; call _, printBoard []
        sub rsp, 8
          call @printBoard
        add rsp, 8
@for_5_continue:
        ; const t.42(42@function,u8), 1
        mov al, 1
        lea rbx, [rsp+161]
        mov [rbx], al
        ; add i(1@function,u8), i(1@function,u8), t.42(42@function,u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+161]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+1]
        mov [rax], bl
        ; jump @for_5
        jmp @for_5
@for_5_break:
@main_ret:
        ; release space for local variables
        add rsp, 176
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
        ; variable 0: board (240)
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
