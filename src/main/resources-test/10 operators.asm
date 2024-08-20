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
        ; @printString_ret:
@printString_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printChar
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
        ; @printChar_ret:
@printChar_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint
@printUint:
        ; reserve space for local variables
        sub rsp, 128
        ; const pos(2@function,u8), 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 13:2 while true
        ; @while_1:
@while_1:
        ; const t.5(5@function,u8), 1
        mov al, 1
        lea rbx, [rsp+33]
        mov [rbx], al
        ; sub pos(2@function,u8), pos(2@function,u8), t.5(5@function,u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+20]
        mov [rax], bl
        ; const t.6(6@function,i64), 10
        mov rax, 10
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; mod remainder(3@function,i64), number(0@argument,i64), t.6(6@function,i64)
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+24]
        mov [rdx], rbx
        ; const t.7(7@function,i64), 10
        mov rax, 10
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; div number(0@argument,i64), number(0@argument,i64), t.7(7@function,i64)
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+48]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rax
        lea rdx, [rsp+136]
        mov [rdx], rbx
        ; cast t.8(8@function,u8), remainder(3@function,i64)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], bl
        ; const t.9(9@function,u8), 48
        mov al, 48
        lea rbx, [rsp+57]
        mov [rbx], al
        ; add digit(4@function,u8), t.8(8@function,u8), t.9(9@function,u8)
        lea rax, [rsp+56]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.10(10@function,i64), pos(2@function,u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+64]
        mov [rax], rbx
        ; array t.11(11@function,u8*), buffer(1@function,u8*) + t.10(10@function,i64)
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+0]
        add rax, rbx
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; store [t.11(11@function,u8*)], digit(4@function,u8)
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; 19:3 if number == 0
        ; const t.13(13@function,i64), 0
        mov rax, 0
        lea rbx, [rsp+88]
        mov [rbx], rax
        ; equals t.12(12@function,bool), number(0@argument,i64), t.13(13@function,i64)
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+88]
        mov rcx, [rax]
        cmp rbx, rcx
        sete bl
        lea rax, [rsp+80]
        mov [rax], bl
        ; branch t.12(12@function,bool), false, @if_2_end
        lea rax, [rsp+80]
        mov bl, [rax]
        or bl, bl
        jz @if_2_end
        ; @if_2_then
        ; jump @while_1_break
        jmp @while_1_break
        ; @if_2_end:
@if_2_end:
        ; jump @while_1
        jmp @while_1
        ; @while_1_break:
@while_1_break:
        ; cast t.15(15@function,i64), pos(2@function,u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+104]
        mov [rax], rbx
        ; addrof t.14(14@function,u8*), [buffer(1@function,u8*) + t.15(15@function,i64)]
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+0]
        add rax, rbx
        lea rcx, [rsp+96]
        mov [rcx], rax
        ; const t.18(18@function,u8), 20
        mov al, 20
        lea rbx, [rsp+121]
        mov [rbx], al
        ; sub t.17(17@function,u8), t.18(18@function,u8), pos(2@function,u8)
        lea rax, [rsp+121]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+120]
        mov [rax], bl
        ; cast t.16(16@function,i64), t.17(17@function,u8)
        lea rax, [rsp+120]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+112]
        mov [rax], rbx
        ; call _, printStringLength [t.14(14@function,u8*), t.16(16@function,i64)]
        lea rax, [rsp+96]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+120]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; @printUint_ret:
@printUint_ret:
        ; release space for local variables
        add rsp, 128
        ret

        ; void printIntLf
@printIntLf:
        ; reserve space for local variables
        sub rsp, 32
        ; 27:2 if number < 0
        ; const t.2(2@function,i64), 0
        mov rax, 0
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; lt t.1(1@function,bool), number(0@argument,i64), t.2(2@function,i64)
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov rcx, [rax]
        cmp rbx, rcx
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1(1@function,bool), false, @if_3_end
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_3_end
        ; @if_3_then
        ; const t.3(3@function,u8), 45
        mov al, 45
        lea rbx, [rsp+16]
        mov [rbx], al
        ; call _, printChar [t.3(3@function,u8)]
        lea rax, [rsp+16]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; neg number(0@argument,i64), number(0@argument,i64)
        lea rax, [rsp+40]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+40]
        mov [rax], rbx
        ; @if_3_end:
@if_3_end:
        ; call _, printUint [number(0@argument,i64)]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printUint
        add rsp, 8
        ; const t.4(4@function,u8), 10
        mov al, 10
        lea rbx, [rsp+17]
        mov [rbx], al
        ; call _, printChar [t.4(4@function,u8)]
        lea rax, [rsp+17]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; @printIntLf_ret:
@printIntLf_ret:
        ; release space for local variables
        add rsp, 32
        ret

        ; i64 strlen
@strlen:
        ; reserve space for local variables
        sub rsp, 48
        ; const length(1@function,i64), 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 37:2 for *str != 0
        ; @for_4:
@for_4:
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
        ; branch t.2(2@function,bool), false, @for_4_break
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jz @for_4_break
        ; @for_4_body
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
        ; @for_4_continue:
@for_4_continue:
        ; cast t.7(7@function,i64), str(0@argument,u8*)
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov [rax], rbx
        ; const t.8(8@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; add t.6(6@function,u8*), t.7(7@function,i64), t.8(8@function,i64)
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+24]
        mov [rax], rbx
        ; cast str(0@argument,u8*), t.6(6@function,u8*)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], rbx
        ; jump @for_4
        jmp @for_4
        ; @for_4_break:
@for_4_break:
        ; 40:9 return length
        ; ret length(1@function,i64)
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        ; jump @strlen_ret
        jmp @strlen_ret
        ; @strlen_ret:
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

        ; void main
@main:
        ; reserve space for local variables
        sub rsp, 496
        ; const t.0(0@function,u8*), [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call _, printString [t.0(0@function,u8*)]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.3(3@function,u8), 0
        mov al, 0
        lea rbx, [rsp+17]
        mov [rbx], al
        ; const t.4(4@function,u8), 0
        mov al, 0
        lea rbx, [rsp+18]
        mov [rbx], al
        ; and t.2(2@function,u8), t.3(3@function,u8), t.4(4@function,u8)
        lea rax, [rsp+17]
        mov bl, [rax]
        lea rax, [rsp+18]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+16]
        mov [rax], bl
        ; cast t.1(1@function,i64), t.2(2@function,u8)
        lea rax, [rsp+16]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+8]
        mov [rax], rbx
        ; call _, printIntLf [t.1(1@function,i64)]
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.7(7@function,u8), 0
        mov al, 0
        lea rbx, [rsp+33]
        mov [rbx], al
        ; const t.8(8@function,u8), 1
        mov al, 1
        lea rbx, [rsp+34]
        mov [rbx], al
        ; and t.6(6@function,u8), t.7(7@function,u8), t.8(8@function,u8)
        lea rax, [rsp+33]
        mov bl, [rax]
        lea rax, [rsp+34]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.5(5@function,i64), t.6(6@function,u8)
        lea rax, [rsp+32]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+24]
        mov [rax], rbx
        ; call _, printIntLf [t.5(5@function,i64)]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.11(11@function,u8), 1
        mov al, 1
        lea rbx, [rsp+49]
        mov [rbx], al
        ; const t.12(12@function,u8), 0
        mov al, 0
        lea rbx, [rsp+50]
        mov [rbx], al
        ; and t.10(10@function,u8), t.11(11@function,u8), t.12(12@function,u8)
        lea rax, [rsp+49]
        mov bl, [rax]
        lea rax, [rsp+50]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+48]
        mov [rax], bl
        ; cast t.9(9@function,i64), t.10(10@function,u8)
        lea rax, [rsp+48]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+40]
        mov [rax], rbx
        ; call _, printIntLf [t.9(9@function,i64)]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.15(15@function,u8), 1
        mov al, 1
        lea rbx, [rsp+65]
        mov [rbx], al
        ; const t.16(16@function,u8), 1
        mov al, 1
        lea rbx, [rsp+66]
        mov [rbx], al
        ; and t.14(14@function,u8), t.15(15@function,u8), t.16(16@function,u8)
        lea rax, [rsp+65]
        mov bl, [rax]
        lea rax, [rsp+66]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+64]
        mov [rax], bl
        ; cast t.13(13@function,i64), t.14(14@function,u8)
        lea rax, [rsp+64]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+56]
        mov [rax], rbx
        ; call _, printIntLf [t.13(13@function,i64)]
        lea rax, [rsp+56]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.17(17@function,u8*), [string-1]
        lea rax, [string_1]
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; call _, printString [t.17(17@function,u8*)]
        lea rax, [rsp+72]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.20(20@function,u8), 0
        mov al, 0
        lea rbx, [rsp+89]
        mov [rbx], al
        ; const t.21(21@function,u8), 0
        mov al, 0
        lea rbx, [rsp+90]
        mov [rbx], al
        ; or t.19(19@function,u8), t.20(20@function,u8), t.21(21@function,u8)
        lea rax, [rsp+89]
        mov bl, [rax]
        lea rax, [rsp+90]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+88]
        mov [rax], bl
        ; cast t.18(18@function,i64), t.19(19@function,u8)
        lea rax, [rsp+88]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+80]
        mov [rax], rbx
        ; call _, printIntLf [t.18(18@function,i64)]
        lea rax, [rsp+80]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.24(24@function,u8), 0
        mov al, 0
        lea rbx, [rsp+105]
        mov [rbx], al
        ; const t.25(25@function,u8), 1
        mov al, 1
        lea rbx, [rsp+106]
        mov [rbx], al
        ; or t.23(23@function,u8), t.24(24@function,u8), t.25(25@function,u8)
        lea rax, [rsp+105]
        mov bl, [rax]
        lea rax, [rsp+106]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+104]
        mov [rax], bl
        ; cast t.22(22@function,i64), t.23(23@function,u8)
        lea rax, [rsp+104]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+96]
        mov [rax], rbx
        ; call _, printIntLf [t.22(22@function,i64)]
        lea rax, [rsp+96]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.28(28@function,u8), 1
        mov al, 1
        lea rbx, [rsp+121]
        mov [rbx], al
        ; const t.29(29@function,u8), 0
        mov al, 0
        lea rbx, [rsp+122]
        mov [rbx], al
        ; or t.27(27@function,u8), t.28(28@function,u8), t.29(29@function,u8)
        lea rax, [rsp+121]
        mov bl, [rax]
        lea rax, [rsp+122]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+120]
        mov [rax], bl
        ; cast t.26(26@function,i64), t.27(27@function,u8)
        lea rax, [rsp+120]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+112]
        mov [rax], rbx
        ; call _, printIntLf [t.26(26@function,i64)]
        lea rax, [rsp+112]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.32(32@function,u8), 1
        mov al, 1
        lea rbx, [rsp+137]
        mov [rbx], al
        ; const t.33(33@function,u8), 1
        mov al, 1
        lea rbx, [rsp+138]
        mov [rbx], al
        ; or t.31(31@function,u8), t.32(32@function,u8), t.33(33@function,u8)
        lea rax, [rsp+137]
        mov bl, [rax]
        lea rax, [rsp+138]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+136]
        mov [rax], bl
        ; cast t.30(30@function,i64), t.31(31@function,u8)
        lea rax, [rsp+136]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+128]
        mov [rax], rbx
        ; call _, printIntLf [t.30(30@function,i64)]
        lea rax, [rsp+128]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.34(34@function,u8*), [string-2]
        lea rax, [string_2]
        lea rbx, [rsp+144]
        mov [rbx], rax
        ; call _, printString [t.34(34@function,u8*)]
        lea rax, [rsp+144]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.37(37@function,u8), 0
        mov al, 0
        lea rbx, [rsp+161]
        mov [rbx], al
        ; const t.38(38@function,u8), 0
        mov al, 0
        lea rbx, [rsp+162]
        mov [rbx], al
        ; xor t.36(36@function,u8), t.37(37@function,u8), t.38(38@function,u8)
        lea rax, [rsp+161]
        mov bl, [rax]
        lea rax, [rsp+162]
        mov cl, [rax]
        xor bl, cl
        lea rax, [rsp+160]
        mov [rax], bl
        ; cast t.35(35@function,i64), t.36(36@function,u8)
        lea rax, [rsp+160]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+152]
        mov [rax], rbx
        ; call _, printIntLf [t.35(35@function,i64)]
        lea rax, [rsp+152]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.41(41@function,u8), 0
        mov al, 0
        lea rbx, [rsp+177]
        mov [rbx], al
        ; const t.42(42@function,u8), 2
        mov al, 2
        lea rbx, [rsp+178]
        mov [rbx], al
        ; xor t.40(40@function,u8), t.41(41@function,u8), t.42(42@function,u8)
        lea rax, [rsp+177]
        mov bl, [rax]
        lea rax, [rsp+178]
        mov cl, [rax]
        xor bl, cl
        lea rax, [rsp+176]
        mov [rax], bl
        ; cast t.39(39@function,i64), t.40(40@function,u8)
        lea rax, [rsp+176]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+168]
        mov [rax], rbx
        ; call _, printIntLf [t.39(39@function,i64)]
        lea rax, [rsp+168]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.45(45@function,u8), 1
        mov al, 1
        lea rbx, [rsp+193]
        mov [rbx], al
        ; const t.46(46@function,u8), 0
        mov al, 0
        lea rbx, [rsp+194]
        mov [rbx], al
        ; xor t.44(44@function,u8), t.45(45@function,u8), t.46(46@function,u8)
        lea rax, [rsp+193]
        mov bl, [rax]
        lea rax, [rsp+194]
        mov cl, [rax]
        xor bl, cl
        lea rax, [rsp+192]
        mov [rax], bl
        ; cast t.43(43@function,i64), t.44(44@function,u8)
        lea rax, [rsp+192]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+184]
        mov [rax], rbx
        ; call _, printIntLf [t.43(43@function,i64)]
        lea rax, [rsp+184]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.49(49@function,u8), 1
        mov al, 1
        lea rbx, [rsp+209]
        mov [rbx], al
        ; const t.50(50@function,u8), 2
        mov al, 2
        lea rbx, [rsp+210]
        mov [rbx], al
        ; xor t.48(48@function,u8), t.49(49@function,u8), t.50(50@function,u8)
        lea rax, [rsp+209]
        mov bl, [rax]
        lea rax, [rsp+210]
        mov cl, [rax]
        xor bl, cl
        lea rax, [rsp+208]
        mov [rax], bl
        ; cast t.47(47@function,i64), t.48(48@function,u8)
        lea rax, [rsp+208]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+200]
        mov [rax], rbx
        ; call _, printIntLf [t.47(47@function,i64)]
        lea rax, [rsp+200]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.51(51@function,u8*), [string-3]
        lea rax, [string_3]
        lea rbx, [rsp+216]
        mov [rbx], rax
        ; call _, printString [t.51(51@function,u8*)]
        lea rax, [rsp+216]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; 20:19 logic and
        ; const t.53(53@function,bool), 0
        mov al, 0
        lea rbx, [rsp+232]
        mov [rbx], al
        ; branch t.53(53@function,bool), false, @and_next_5
        lea rax, [rsp+232]
        mov bl, [rax]
        or bl, bl
        jz @and_next_5
        ; @and_2nd_5
        ; const t.53(53@function,bool), 0
        mov al, 0
        lea rbx, [rsp+232]
        mov [rbx], al
        ; @and_next_5:
@and_next_5:
        ; cast t.52(52@function,i64), t.53(53@function,bool)
        lea rax, [rsp+232]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+224]
        mov [rax], rbx
        ; call _, printIntLf [t.52(52@function,i64)]
        lea rax, [rsp+224]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 21:19 logic and
        ; const t.55(55@function,bool), 0
        mov al, 0
        lea rbx, [rsp+248]
        mov [rbx], al
        ; branch t.55(55@function,bool), false, @and_next_6
        lea rax, [rsp+248]
        mov bl, [rax]
        or bl, bl
        jz @and_next_6
        ; @and_2nd_6
        ; const t.55(55@function,bool), 1
        mov al, 1
        lea rbx, [rsp+248]
        mov [rbx], al
        ; @and_next_6:
@and_next_6:
        ; cast t.54(54@function,i64), t.55(55@function,bool)
        lea rax, [rsp+248]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+240]
        mov [rax], rbx
        ; call _, printIntLf [t.54(54@function,i64)]
        lea rax, [rsp+240]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 22:18 logic and
        ; const t.57(57@function,bool), 1
        mov al, 1
        lea rbx, [rsp+264]
        mov [rbx], al
        ; branch t.57(57@function,bool), false, @and_next_7
        lea rax, [rsp+264]
        mov bl, [rax]
        or bl, bl
        jz @and_next_7
        ; @and_2nd_7
        ; const t.57(57@function,bool), 0
        mov al, 0
        lea rbx, [rsp+264]
        mov [rbx], al
        ; @and_next_7:
@and_next_7:
        ; cast t.56(56@function,i64), t.57(57@function,bool)
        lea rax, [rsp+264]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+256]
        mov [rax], rbx
        ; call _, printIntLf [t.56(56@function,i64)]
        lea rax, [rsp+256]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 23:18 logic and
        ; const t.59(59@function,bool), 1
        mov al, 1
        lea rbx, [rsp+280]
        mov [rbx], al
        ; branch t.59(59@function,bool), false, @and_next_8
        lea rax, [rsp+280]
        mov bl, [rax]
        or bl, bl
        jz @and_next_8
        ; @and_2nd_8
        ; const t.59(59@function,bool), 1
        mov al, 1
        lea rbx, [rsp+280]
        mov [rbx], al
        ; @and_next_8:
@and_next_8:
        ; cast t.58(58@function,i64), t.59(59@function,bool)
        lea rax, [rsp+280]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+272]
        mov [rax], rbx
        ; call _, printIntLf [t.58(58@function,i64)]
        lea rax, [rsp+272]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.60(60@function,u8*), [string-4]
        lea rax, [string_4]
        lea rbx, [rsp+288]
        mov [rbx], rax
        ; call _, printString [t.60(60@function,u8*)]
        lea rax, [rsp+288]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; 25:19 logic or
        ; const t.62(62@function,bool), 0
        mov al, 0
        lea rbx, [rsp+304]
        mov [rbx], al
        ; branch t.62(62@function,bool), true, @or_next_9
        lea rax, [rsp+304]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_9
        ; @or_2nd_9
        ; const t.62(62@function,bool), 0
        mov al, 0
        lea rbx, [rsp+304]
        mov [rbx], al
        ; @or_next_9:
@or_next_9:
        ; cast t.61(61@function,i64), t.62(62@function,bool)
        lea rax, [rsp+304]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+296]
        mov [rax], rbx
        ; call _, printIntLf [t.61(61@function,i64)]
        lea rax, [rsp+296]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 26:19 logic or
        ; const t.64(64@function,bool), 0
        mov al, 0
        lea rbx, [rsp+320]
        mov [rbx], al
        ; branch t.64(64@function,bool), true, @or_next_10
        lea rax, [rsp+320]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_10
        ; @or_2nd_10
        ; const t.64(64@function,bool), 1
        mov al, 1
        lea rbx, [rsp+320]
        mov [rbx], al
        ; @or_next_10:
@or_next_10:
        ; cast t.63(63@function,i64), t.64(64@function,bool)
        lea rax, [rsp+320]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+312]
        mov [rax], rbx
        ; call _, printIntLf [t.63(63@function,i64)]
        lea rax, [rsp+312]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 27:18 logic or
        ; const t.66(66@function,bool), 1
        mov al, 1
        lea rbx, [rsp+336]
        mov [rbx], al
        ; branch t.66(66@function,bool), true, @or_next_11
        lea rax, [rsp+336]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_11
        ; @or_2nd_11
        ; const t.66(66@function,bool), 0
        mov al, 0
        lea rbx, [rsp+336]
        mov [rbx], al
        ; @or_next_11:
@or_next_11:
        ; cast t.65(65@function,i64), t.66(66@function,bool)
        lea rax, [rsp+336]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+328]
        mov [rax], rbx
        ; call _, printIntLf [t.65(65@function,i64)]
        lea rax, [rsp+328]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 28:18 logic or
        ; const t.68(68@function,bool), 1
        mov al, 1
        lea rbx, [rsp+352]
        mov [rbx], al
        ; branch t.68(68@function,bool), true, @or_next_12
        lea rax, [rsp+352]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_12
        ; @or_2nd_12
        ; const t.68(68@function,bool), 1
        mov al, 1
        lea rbx, [rsp+352]
        mov [rbx], al
        ; @or_next_12:
@or_next_12:
        ; cast t.67(67@function,i64), t.68(68@function,bool)
        lea rax, [rsp+352]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+344]
        mov [rax], rbx
        ; call _, printIntLf [t.67(67@function,i64)]
        lea rax, [rsp+344]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.69(69@function,u8*), [string-5]
        lea rax, [string_5]
        lea rbx, [rsp+360]
        mov [rbx], rax
        ; call _, printString [t.69(69@function,u8*)]
        lea rax, [rsp+360]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.72(72@function,bool), 0
        mov al, 0
        lea rbx, [rsp+377]
        mov [rbx], al
        ; notlog t.71(71@function,bool), t.72(72@function,bool)
        lea rax, [rsp+377]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+376]
        mov [rax], bl
        ; cast t.70(70@function,i64), t.71(71@function,bool)
        lea rax, [rsp+376]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+368]
        mov [rax], rbx
        ; call _, printIntLf [t.70(70@function,i64)]
        lea rax, [rsp+368]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.75(75@function,bool), 1
        mov al, 1
        lea rbx, [rsp+393]
        mov [rbx], al
        ; notlog t.74(74@function,bool), t.75(75@function,bool)
        lea rax, [rsp+393]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+392]
        mov [rax], bl
        ; cast t.73(73@function,i64), t.74(74@function,bool)
        lea rax, [rsp+392]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+384]
        mov [rax], rbx
        ; call _, printIntLf [t.73(73@function,i64)]
        lea rax, [rsp+384]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.76(76@function,u8*), [string-6]
        lea rax, [string_6]
        lea rbx, [rsp+400]
        mov [rbx], rax
        ; call _, printString [t.76(76@function,u8*)]
        lea rax, [rsp+400]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.80(80@function,u8), 10
        mov al, 10
        lea rbx, [rsp+418]
        mov [rbx], al
        ; const t.81(81@function,u8), 6
        mov al, 6
        lea rbx, [rsp+419]
        mov [rbx], al
        ; and t.79(79@function,u8), t.80(80@function,u8), t.81(81@function,u8)
        lea rax, [rsp+418]
        mov bl, [rax]
        lea rax, [rsp+419]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+417]
        mov [rax], bl
        ; const t.82(82@function,u8), 1
        mov al, 1
        lea rbx, [rsp+420]
        mov [rbx], al
        ; or t.78(78@function,u8), t.79(79@function,u8), t.82(82@function,u8)
        lea rax, [rsp+417]
        mov bl, [rax]
        lea rax, [rsp+420]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+416]
        mov [rax], bl
        ; cast t.77(77@function,i64), t.78(78@function,u8)
        lea rax, [rsp+416]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+408]
        mov [rax], rbx
        ; call _, printIntLf [t.77(77@function,i64)]
        lea rax, [rsp+408]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 34:20 logic or
        ; const t.85(85@function,u8), 1
        mov al, 1
        lea rbx, [rsp+433]
        mov [rbx], al
        ; const t.86(86@function,u8), 2
        mov al, 2
        lea rbx, [rsp+434]
        mov [rbx], al
        ; equals t.84(84@function,bool), t.85(85@function,u8), t.86(86@function,u8)
        lea rax, [rsp+433]
        mov bl, [rax]
        lea rax, [rsp+434]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+432]
        mov [rax], bl
        ; branch t.84(84@function,bool), true, @or_next_13
        lea rax, [rsp+432]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_13
        ; @or_2nd_13
        ; const t.87(87@function,u8), 2
        mov al, 2
        lea rbx, [rsp+435]
        mov [rbx], al
        ; const t.88(88@function,u8), 3
        mov al, 3
        lea rbx, [rsp+436]
        mov [rbx], al
        ; lt t.84(84@function,bool), t.87(87@function,u8), t.88(88@function,u8)
        lea rax, [rsp+435]
        mov bl, [rax]
        lea rax, [rsp+436]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+432]
        mov [rax], bl
        ; @or_next_13:
@or_next_13:
        ; cast t.83(83@function,i64), t.84(84@function,bool)
        lea rax, [rsp+432]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+424]
        mov [rax], rbx
        ; call _, printIntLf [t.83(83@function,i64)]
        lea rax, [rsp+424]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 35:20 logic and
        ; const t.91(91@function,u8), 1
        mov al, 1
        lea rbx, [rsp+449]
        mov [rbx], al
        ; const t.92(92@function,u8), 2
        mov al, 2
        lea rbx, [rsp+450]
        mov [rbx], al
        ; equals t.90(90@function,bool), t.91(91@function,u8), t.92(92@function,u8)
        lea rax, [rsp+449]
        mov bl, [rax]
        lea rax, [rsp+450]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+448]
        mov [rax], bl
        ; branch t.90(90@function,bool), false, @and_next_14
        lea rax, [rsp+448]
        mov bl, [rax]
        or bl, bl
        jz @and_next_14
        ; @and_2nd_14
        ; const t.93(93@function,u8), 2
        mov al, 2
        lea rbx, [rsp+451]
        mov [rbx], al
        ; const t.94(94@function,u8), 3
        mov al, 3
        lea rbx, [rsp+452]
        mov [rbx], al
        ; lt t.90(90@function,bool), t.93(93@function,u8), t.94(94@function,u8)
        lea rax, [rsp+451]
        mov bl, [rax]
        lea rax, [rsp+452]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+448]
        mov [rax], bl
        ; @and_next_14:
@and_next_14:
        ; cast t.89(89@function,i64), t.90(90@function,bool)
        lea rax, [rsp+448]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+440]
        mov [rax], rbx
        ; call _, printIntLf [t.89(89@function,i64)]
        lea rax, [rsp+440]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.97(97@function,i16), 1
        mov ax, 1
        lea rbx, [rsp+466]
        mov [rbx], ax
        ; neg t.96(96@function,i16), t.97(97@function,i16)
        lea rax, [rsp+466]
        mov bx, [rax]
        neg rbx
        lea rax, [rsp+464]
        mov [rax], bx
        ; cast t.95(95@function,i64), t.96(96@function,i16)
        lea rax, [rsp+464]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+456]
        mov [rax], rbx
        ; call _, printIntLf [t.95(95@function,i64)]
        lea rax, [rsp+456]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.100(100@function,u8), 1
        mov al, 1
        lea rbx, [rsp+481]
        mov [rbx], al
        ; not t.99(99@function,u8), t.100(100@function,u8)
        lea rax, [rsp+481]
        mov bl, [rax]
        not rbx
        lea rax, [rsp+480]
        mov [rax], bl
        ; cast t.98(98@function,i64), t.99(99@function,u8)
        lea rax, [rsp+480]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+472]
        mov [rax], rbx
        ; call _, printIntLf [t.98(98@function,i64)]
        lea rax, [rsp+472]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; @main_ret:
@main_ret:
        ; release space for local variables
        add rsp, 496
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

section '.data' data readable
        string_0 db 'Bit-&:', 0x0a, 0x00
        string_1 db 0x0a, 'Bit-|:', 0x0a, 0x00
        string_2 db 0x0a, 'Bit-^:', 0x0a, 0x00
        string_3 db 0x0a, 'Logic-&&:', 0x0a, 0x00
        string_4 db 0x0a, 'Logic-||:', 0x0a, 0x00
        string_5 db 0x0a, 'Logic-!:', 0x0a, 0x00
        string_6 db 0x0a, 'misc:', 0x0a, 0x00

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
