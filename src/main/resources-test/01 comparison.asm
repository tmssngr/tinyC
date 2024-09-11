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

        ; void printUint
        ;   rsp+136: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
        ;   rsp+24: var remainder
        ;   rsp+32: var digit
        ;   rsp+33: var t.5
        ;   rsp+40: var t.6
        ;   rsp+48: var t.7
        ;   rsp+56: var t.8
        ;   rsp+57: var t.9
        ;   rsp+64: var t.10
        ;   rsp+72: var t.11
        ;   rsp+80: var t.12
        ;   rsp+88: var t.13
        ;   rsp+96: var t.14
        ;   rsp+104: var t.15
        ;   rsp+112: var t.16
        ;   rsp+120: var t.17
        ;   rsp+121: var t.18
@printUint:
        ; reserve space for local variables
        sub rsp, 128
        ; const pos(2@function,u8), 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 13:2 while true
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
@if_2_end:
        ; jump @while_1
        jmp @while_1
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
@printUint_ret:
        ; release space for local variables
        add rsp, 128
        ret

        ; void printIntLf
        ;   rsp+40: arg number
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
        ;   rsp+16: var t.3
        ;   rsp+17: var t.4
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
@printIntLf_ret:
        ; release space for local variables
        add rsp, 32
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
        ; jump @for_4
        jmp @for_4
@for_4_break:
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

        ; void main
        ;   rsp+0: var t.0
        ;   rsp+8: var t.1
        ;   rsp+16: var t.2
        ;   rsp+17: var t.3
        ;   rsp+18: var t.4
        ;   rsp+24: var t.5
        ;   rsp+32: var t.6
        ;   rsp+33: var t.7
        ;   rsp+34: var t.8
        ;   rsp+40: var t.9
        ;   rsp+48: var t.10
        ;   rsp+56: var t.11
        ;   rsp+57: var t.12
        ;   rsp+58: var t.13
        ;   rsp+64: var t.14
        ;   rsp+72: var t.15
        ;   rsp+73: var t.16
        ;   rsp+74: var t.17
        ;   rsp+80: var t.18
        ;   rsp+88: var t.19
        ;   rsp+96: var t.20
        ;   rsp+97: var t.21
        ;   rsp+98: var t.22
        ;   rsp+104: var t.23
        ;   rsp+112: var t.24
        ;   rsp+113: var t.25
        ;   rsp+114: var t.26
        ;   rsp+120: var t.27
        ;   rsp+128: var t.28
        ;   rsp+136: var t.29
        ;   rsp+137: var t.30
        ;   rsp+138: var t.31
        ;   rsp+144: var t.32
        ;   rsp+152: var t.33
        ;   rsp+153: var t.34
        ;   rsp+154: var t.35
        ;   rsp+160: var t.36
        ;   rsp+168: var t.37
        ;   rsp+176: var t.38
        ;   rsp+177: var t.39
        ;   rsp+178: var t.40
        ;   rsp+184: var t.41
        ;   rsp+192: var t.42
        ;   rsp+200: var t.43
        ;   rsp+201: var t.44
        ;   rsp+202: var t.45
        ;   rsp+208: var t.46
        ;   rsp+216: var t.47
        ;   rsp+224: var t.48
        ;   rsp+225: var t.49
        ;   rsp+226: var t.50
        ;   rsp+232: var t.51
        ;   rsp+240: var t.52
        ;   rsp+241: var t.53
        ;   rsp+242: var t.54
        ;   rsp+248: var t.55
        ;   rsp+256: var t.56
        ;   rsp+264: var t.57
        ;   rsp+265: var t.58
        ;   rsp+266: var t.59
        ;   rsp+272: var t.60
        ;   rsp+280: var t.61
        ;   rsp+281: var t.62
        ;   rsp+282: var t.63
        ;   rsp+288: var t.64
        ;   rsp+296: var t.65
        ;   rsp+304: var t.66
        ;   rsp+305: var t.67
        ;   rsp+306: var t.68
        ;   rsp+312: var t.69
        ;   rsp+320: var t.70
        ;   rsp+321: var t.71
        ;   rsp+322: var t.72
        ;   rsp+328: var t.73
        ;   rsp+336: var t.74
        ;   rsp+344: var t.75
        ;   rsp+345: var t.76
        ;   rsp+346: var t.77
        ;   rsp+352: var t.78
        ;   rsp+360: var t.79
        ;   rsp+361: var t.80
        ;   rsp+362: var t.81
@main:
        ; reserve space for local variables
        sub rsp, 368
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
        ; const t.3(3@function,u8), 1
        mov al, 1
        lea rbx, [rsp+17]
        mov [rbx], al
        ; const t.4(4@function,u8), 2
        mov al, 2
        lea rbx, [rsp+18]
        mov [rbx], al
        ; lt t.2(2@function,bool), t.3(3@function,u8), t.4(4@function,u8)
        lea rax, [rsp+17]
        mov bl, [rax]
        lea rax, [rsp+18]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+16]
        mov [rax], bl
        ; cast t.1(1@function,i64), t.2(2@function,bool)
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
        ; const t.7(7@function,u8), 2
        mov al, 2
        lea rbx, [rsp+33]
        mov [rbx], al
        ; const t.8(8@function,u8), 1
        mov al, 1
        lea rbx, [rsp+34]
        mov [rbx], al
        ; lt t.6(6@function,bool), t.7(7@function,u8), t.8(8@function,u8)
        lea rax, [rsp+33]
        mov bl, [rax]
        lea rax, [rsp+34]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.5(5@function,i64), t.6(6@function,bool)
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
        ; const t.9(9@function,u8*), [string-1]
        lea rax, [string_1]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; call _, printString [t.9(9@function,u8*)]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.12(12@function,u8), 0
        mov al, 0
        lea rbx, [rsp+57]
        mov [rbx], al
        ; const t.13(13@function,u8), 128
        mov al, 128
        lea rbx, [rsp+58]
        mov [rbx], al
        ; lt t.11(11@function,bool), t.12(12@function,u8), t.13(13@function,u8)
        lea rax, [rsp+57]
        mov bl, [rax]
        lea rax, [rsp+58]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+56]
        mov [rax], bl
        ; cast t.10(10@function,i64), t.11(11@function,bool)
        lea rax, [rsp+56]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+48]
        mov [rax], rbx
        ; call _, printIntLf [t.10(10@function,i64)]
        lea rax, [rsp+48]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.16(16@function,u8), 128
        mov al, 128
        lea rbx, [rsp+73]
        mov [rbx], al
        ; const t.17(17@function,u8), 0
        mov al, 0
        lea rbx, [rsp+74]
        mov [rbx], al
        ; lt t.15(15@function,bool), t.16(16@function,u8), t.17(17@function,u8)
        lea rax, [rsp+73]
        mov bl, [rax]
        lea rax, [rsp+74]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+72]
        mov [rax], bl
        ; cast t.14(14@function,i64), t.15(15@function,bool)
        lea rax, [rsp+72]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+64]
        mov [rax], rbx
        ; call _, printIntLf [t.14(14@function,i64)]
        lea rax, [rsp+64]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.18(18@function,u8*), [string-2]
        lea rax, [string_2]
        lea rbx, [rsp+80]
        mov [rbx], rax
        ; call _, printString [t.18(18@function,u8*)]
        lea rax, [rsp+80]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.21(21@function,u8), 1
        mov al, 1
        lea rbx, [rsp+97]
        mov [rbx], al
        ; const t.22(22@function,u8), 2
        mov al, 2
        lea rbx, [rsp+98]
        mov [rbx], al
        ; lteq t.20(20@function,bool), t.21(21@function,u8), t.22(22@function,u8)
        lea rax, [rsp+97]
        mov bl, [rax]
        lea rax, [rsp+98]
        mov cl, [rax]
        cmp bl, cl
        setbe bl
        lea rax, [rsp+96]
        mov [rax], bl
        ; cast t.19(19@function,i64), t.20(20@function,bool)
        lea rax, [rsp+96]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+88]
        mov [rax], rbx
        ; call _, printIntLf [t.19(19@function,i64)]
        lea rax, [rsp+88]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.25(25@function,u8), 2
        mov al, 2
        lea rbx, [rsp+113]
        mov [rbx], al
        ; const t.26(26@function,u8), 1
        mov al, 1
        lea rbx, [rsp+114]
        mov [rbx], al
        ; lteq t.24(24@function,bool), t.25(25@function,u8), t.26(26@function,u8)
        lea rax, [rsp+113]
        mov bl, [rax]
        lea rax, [rsp+114]
        mov cl, [rax]
        cmp bl, cl
        setbe bl
        lea rax, [rsp+112]
        mov [rax], bl
        ; cast t.23(23@function,i64), t.24(24@function,bool)
        lea rax, [rsp+112]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+104]
        mov [rax], rbx
        ; call _, printIntLf [t.23(23@function,i64)]
        lea rax, [rsp+104]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.27(27@function,u8*), [string-3]
        lea rax, [string_3]
        lea rbx, [rsp+120]
        mov [rbx], rax
        ; call _, printString [t.27(27@function,u8*)]
        lea rax, [rsp+120]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.30(30@function,u8), 0
        mov al, 0
        lea rbx, [rsp+137]
        mov [rbx], al
        ; const t.31(31@function,u8), 128
        mov al, 128
        lea rbx, [rsp+138]
        mov [rbx], al
        ; lteq t.29(29@function,bool), t.30(30@function,u8), t.31(31@function,u8)
        lea rax, [rsp+137]
        mov bl, [rax]
        lea rax, [rsp+138]
        mov cl, [rax]
        cmp bl, cl
        setbe bl
        lea rax, [rsp+136]
        mov [rax], bl
        ; cast t.28(28@function,i64), t.29(29@function,bool)
        lea rax, [rsp+136]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+128]
        mov [rax], rbx
        ; call _, printIntLf [t.28(28@function,i64)]
        lea rax, [rsp+128]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.34(34@function,u8), 128
        mov al, 128
        lea rbx, [rsp+153]
        mov [rbx], al
        ; const t.35(35@function,u8), 0
        mov al, 0
        lea rbx, [rsp+154]
        mov [rbx], al
        ; lteq t.33(33@function,bool), t.34(34@function,u8), t.35(35@function,u8)
        lea rax, [rsp+153]
        mov bl, [rax]
        lea rax, [rsp+154]
        mov cl, [rax]
        cmp bl, cl
        setbe bl
        lea rax, [rsp+152]
        mov [rax], bl
        ; cast t.32(32@function,i64), t.33(33@function,bool)
        lea rax, [rsp+152]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+144]
        mov [rax], rbx
        ; call _, printIntLf [t.32(32@function,i64)]
        lea rax, [rsp+144]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.36(36@function,u8*), [string-4]
        lea rax, [string_4]
        lea rbx, [rsp+160]
        mov [rbx], rax
        ; call _, printString [t.36(36@function,u8*)]
        lea rax, [rsp+160]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.39(39@function,u8), 1
        mov al, 1
        lea rbx, [rsp+177]
        mov [rbx], al
        ; const t.40(40@function,u8), 2
        mov al, 2
        lea rbx, [rsp+178]
        mov [rbx], al
        ; equals t.38(38@function,bool), t.39(39@function,u8), t.40(40@function,u8)
        lea rax, [rsp+177]
        mov bl, [rax]
        lea rax, [rsp+178]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+176]
        mov [rax], bl
        ; cast t.37(37@function,i64), t.38(38@function,bool)
        lea rax, [rsp+176]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+168]
        mov [rax], rbx
        ; call _, printIntLf [t.37(37@function,i64)]
        lea rax, [rsp+168]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.41(41@function,u8*), [string-5]
        lea rax, [string_5]
        lea rbx, [rsp+184]
        mov [rbx], rax
        ; call _, printString [t.41(41@function,u8*)]
        lea rax, [rsp+184]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.44(44@function,u8), 1
        mov al, 1
        lea rbx, [rsp+201]
        mov [rbx], al
        ; const t.45(45@function,u8), 2
        mov al, 2
        lea rbx, [rsp+202]
        mov [rbx], al
        ; notequals t.43(43@function,bool), t.44(44@function,u8), t.45(45@function,u8)
        lea rax, [rsp+201]
        mov bl, [rax]
        lea rax, [rsp+202]
        mov cl, [rax]
        cmp bl, cl
        setne bl
        lea rax, [rsp+200]
        mov [rax], bl
        ; cast t.42(42@function,i64), t.43(43@function,bool)
        lea rax, [rsp+200]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+192]
        mov [rax], rbx
        ; call _, printIntLf [t.42(42@function,i64)]
        lea rax, [rsp+192]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.46(46@function,u8*), [string-6]
        lea rax, [string_6]
        lea rbx, [rsp+208]
        mov [rbx], rax
        ; call _, printString [t.46(46@function,u8*)]
        lea rax, [rsp+208]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.49(49@function,u8), 1
        mov al, 1
        lea rbx, [rsp+225]
        mov [rbx], al
        ; const t.50(50@function,u8), 2
        mov al, 2
        lea rbx, [rsp+226]
        mov [rbx], al
        ; gteq t.48(48@function,bool), t.49(49@function,u8), t.50(50@function,u8)
        lea rax, [rsp+225]
        mov bl, [rax]
        lea rax, [rsp+226]
        mov cl, [rax]
        cmp bl, cl
        setae bl
        lea rax, [rsp+224]
        mov [rax], bl
        ; cast t.47(47@function,i64), t.48(48@function,bool)
        lea rax, [rsp+224]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+216]
        mov [rax], rbx
        ; call _, printIntLf [t.47(47@function,i64)]
        lea rax, [rsp+216]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.53(53@function,u8), 2
        mov al, 2
        lea rbx, [rsp+241]
        mov [rbx], al
        ; const t.54(54@function,u8), 1
        mov al, 1
        lea rbx, [rsp+242]
        mov [rbx], al
        ; gteq t.52(52@function,bool), t.53(53@function,u8), t.54(54@function,u8)
        lea rax, [rsp+241]
        mov bl, [rax]
        lea rax, [rsp+242]
        mov cl, [rax]
        cmp bl, cl
        setae bl
        lea rax, [rsp+240]
        mov [rax], bl
        ; cast t.51(51@function,i64), t.52(52@function,bool)
        lea rax, [rsp+240]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+232]
        mov [rax], rbx
        ; call _, printIntLf [t.51(51@function,i64)]
        lea rax, [rsp+232]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.55(55@function,u8*), [string-7]
        lea rax, [string_7]
        lea rbx, [rsp+248]
        mov [rbx], rax
        ; call _, printString [t.55(55@function,u8*)]
        lea rax, [rsp+248]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.58(58@function,u8), 0
        mov al, 0
        lea rbx, [rsp+265]
        mov [rbx], al
        ; const t.59(59@function,u8), 128
        mov al, 128
        lea rbx, [rsp+266]
        mov [rbx], al
        ; gteq t.57(57@function,bool), t.58(58@function,u8), t.59(59@function,u8)
        lea rax, [rsp+265]
        mov bl, [rax]
        lea rax, [rsp+266]
        mov cl, [rax]
        cmp bl, cl
        setae bl
        lea rax, [rsp+264]
        mov [rax], bl
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
        ; const t.62(62@function,u8), 128
        mov al, 128
        lea rbx, [rsp+281]
        mov [rbx], al
        ; const t.63(63@function,u8), 0
        mov al, 0
        lea rbx, [rsp+282]
        mov [rbx], al
        ; gteq t.61(61@function,bool), t.62(62@function,u8), t.63(63@function,u8)
        lea rax, [rsp+281]
        mov bl, [rax]
        lea rax, [rsp+282]
        mov cl, [rax]
        cmp bl, cl
        setae bl
        lea rax, [rsp+280]
        mov [rax], bl
        ; cast t.60(60@function,i64), t.61(61@function,bool)
        lea rax, [rsp+280]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+272]
        mov [rax], rbx
        ; call _, printIntLf [t.60(60@function,i64)]
        lea rax, [rsp+272]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.64(64@function,u8*), [string-8]
        lea rax, [string_8]
        lea rbx, [rsp+288]
        mov [rbx], rax
        ; call _, printString [t.64(64@function,u8*)]
        lea rax, [rsp+288]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.67(67@function,u8), 1
        mov al, 1
        lea rbx, [rsp+305]
        mov [rbx], al
        ; const t.68(68@function,u8), 2
        mov al, 2
        lea rbx, [rsp+306]
        mov [rbx], al
        ; gt t.66(66@function,bool), t.67(67@function,u8), t.68(68@function,u8)
        lea rax, [rsp+305]
        mov bl, [rax]
        lea rax, [rsp+306]
        mov cl, [rax]
        cmp bl, cl
        seta bl
        lea rax, [rsp+304]
        mov [rax], bl
        ; cast t.65(65@function,i64), t.66(66@function,bool)
        lea rax, [rsp+304]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+296]
        mov [rax], rbx
        ; call _, printIntLf [t.65(65@function,i64)]
        lea rax, [rsp+296]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.71(71@function,u8), 2
        mov al, 2
        lea rbx, [rsp+321]
        mov [rbx], al
        ; const t.72(72@function,u8), 1
        mov al, 1
        lea rbx, [rsp+322]
        mov [rbx], al
        ; gt t.70(70@function,bool), t.71(71@function,u8), t.72(72@function,u8)
        lea rax, [rsp+321]
        mov bl, [rax]
        lea rax, [rsp+322]
        mov cl, [rax]
        cmp bl, cl
        seta bl
        lea rax, [rsp+320]
        mov [rax], bl
        ; cast t.69(69@function,i64), t.70(70@function,bool)
        lea rax, [rsp+320]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+312]
        mov [rax], rbx
        ; call _, printIntLf [t.69(69@function,i64)]
        lea rax, [rsp+312]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.73(73@function,u8*), [string-9]
        lea rax, [string_9]
        lea rbx, [rsp+328]
        mov [rbx], rax
        ; call _, printString [t.73(73@function,u8*)]
        lea rax, [rsp+328]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const t.76(76@function,u8), 0
        mov al, 0
        lea rbx, [rsp+345]
        mov [rbx], al
        ; const t.77(77@function,u8), 128
        mov al, 128
        lea rbx, [rsp+346]
        mov [rbx], al
        ; gt t.75(75@function,bool), t.76(76@function,u8), t.77(77@function,u8)
        lea rax, [rsp+345]
        mov bl, [rax]
        lea rax, [rsp+346]
        mov cl, [rax]
        cmp bl, cl
        seta bl
        lea rax, [rsp+344]
        mov [rax], bl
        ; cast t.74(74@function,i64), t.75(75@function,bool)
        lea rax, [rsp+344]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+336]
        mov [rax], rbx
        ; call _, printIntLf [t.74(74@function,i64)]
        lea rax, [rsp+336]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.80(80@function,u8), 128
        mov al, 128
        lea rbx, [rsp+361]
        mov [rbx], al
        ; const t.81(81@function,u8), 0
        mov al, 0
        lea rbx, [rsp+362]
        mov [rbx], al
        ; gt t.79(79@function,bool), t.80(80@function,u8), t.81(81@function,u8)
        lea rax, [rsp+361]
        mov bl, [rax]
        lea rax, [rsp+362]
        mov cl, [rax]
        cmp bl, cl
        seta bl
        lea rax, [rsp+360]
        mov [rax], bl
        ; cast t.78(78@function,i64), t.79(79@function,bool)
        lea rax, [rsp+360]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+352]
        mov [rax], rbx
        ; call _, printIntLf [t.78(78@function,i64)]
        lea rax, [rsp+352]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
@main_ret:
        ; release space for local variables
        add rsp, 368
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
