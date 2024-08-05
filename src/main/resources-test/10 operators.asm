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
        sub rsp, 32
        ; 31:22 read var str(%0)
        lea rax, [rsp+40]
        mov rbx, [rax]
        ; 31:22 var $.2(%2)
        lea rax, [rsp+8]
        ; 31:22 assign
        mov [rax], rbx
        ; 31:15 call strlen
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        ; 31:2 var length(%1)
        lea rbx, [rsp+0]
        ; 31:2 assign
        mov [rbx], rax
        ; 32:20 read var str(%0)
        lea rax, [rsp+40]
        mov rbx, [rax]
        ; 32:20 var $.3(%3)
        lea rax, [rsp+16]
        ; 32:20 assign
        mov [rax], rbx
        ; 32:2 call printStringLength
        lea rax, [rsp+16]
        mov rcx, [rax]
        lea rax, [rsp+0]
        mov rdx, [rax]
        sub rsp, 8
          call __printStringLength
        add rsp, 8
@printString_ret:
        ; release space for local variables
        add rsp, 32
        ret

        ; void printChar
@printChar:
        ; reserve space for local variables
        sub rsp, 16
        ; 36:21 var chr(%0)
        lea rax, [rsp+24]
        ; 36:20 var $.1(%1)
        lea rbx, [rsp+0]
        ; 36:20 assign
        mov [rbx], rax
        ; 36:26 int lit 1
        mov rax, 1
        ; 36:26 var $.2(%2)
        lea rbx, [rsp+8]
        ; 36:26 assign
        mov [rbx], rax
        ; 36:2 call printStringLength
        lea rax, [rsp+0]
        mov rcx, [rax]
        lea rax, [rsp+8]
        mov rdx, [rax]
        sub rsp, 8
          call __printStringLength
        add rsp, 8
@printChar_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint
@printUint:
        ; reserve space for local variables
        sub rsp, 48
        ; 41:11 int lit 20
        mov al, 20
        ; 41:2 var pos(%2)
        lea rbx, [rsp+20]
        ; 41:2 assign
        mov [rbx], al
        ; 42:2 while true
@while_1:
        ; 42:9 bool lit true
        mov al, 1
        or al, al
        jz @while_1_break
        ; while body
        ; 43:9 read var pos(%2)
        lea rax, [rsp+20]
        mov bl, [rax]
        ; 43:15 int lit 1
        mov al, 1
        ; 43:13 sub
        sub bl, al
        ; 43:3 var pos(%2)
        lea rax, [rsp+20]
        ; 43:7 assign
        mov [rax], bl
        ; 44:19 read var number(%0)
        lea rax, [rsp+56]
        mov rbx, [rax]
        ; 44:28 int lit 10
        mov rax, 10
        ; 44:26 mod
        mov rdx, rax
        mov rax, rbx
        mov rbx, rdx
        cqo
        idiv rbx
        mov rbx, rdx
        ; 44:3 var remainder(%3)
        lea rax, [rsp+21]
        ; 44:3 assign
        mov [rax], rbx
        ; 45:12 read var number(%0)
        lea rax, [rsp+56]
        mov rbx, [rax]
        ; 45:21 int lit 10
        mov rax, 10
        ; 45:19 divide
        mov rdx, rax
        mov rax, rbx
        mov rbx, rdx
        cqo
        idiv rbx
        mov rbx, rax
        ; 45:3 var number(%0)
        lea rax, [rsp+56]
        ; 45:10 assign
        mov [rax], rbx
        ; 46:18 read var remainder(%3)
        lea rax, [rsp+21]
        mov rbx, [rax]
        ; 46:30 int lit 48
        mov al, 48
        ; 46:28 add
        add bl, al
        ; 46:3 var digit(%4)
        lea rax, [rsp+29]
        ; 46:3 assign
        mov [rax], bl
        ; 47:17 read var digit(%4)
        lea rax, [rsp+29]
        mov bl, [rax]
        ; 47:10 array buffer(%1)
        ; 47:10 read var pos(%2)
        lea rax, [rsp+20]
        mov cl, [rax]
        movzx rax, cl
        imul rax, 1
        lea rcx, [rsp+0]
        add rcx, rax
        ; 47:15 assign
        mov [rcx], bl
        ; 48:3 if number == 0
        ; 48:7 read var number(%0)
        lea rax, [rsp+56]
        mov rbx, [rax]
        ; 48:17 int lit 0
        mov rax, 0
        ; 48:14 ==
        cmp rbx, rax
        sete cl
        and cl, 0xFF
        or cl, cl
        jz @else_2
        ; then
        jmp @while_1_break
        jmp @endif_2
        ; else
@else_2:
@endif_2:
        jmp @while_1
@while_1_break:
        ; 52:28 array buffer(%1)
        ; 52:28 read var pos(%2)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rax, bl
        imul rax, 1
        lea rbx, [rsp+0]
        add rbx, rax
        ; 52:20 var $.5(%5)
        lea rax, [rsp+30]
        ; 52:20 assign
        mov [rax], rbx
        ; 52:34 int lit 20
        mov al, 20
        ; 52:39 read var pos(%2)
        lea rbx, [rsp+20]
        mov cl, [rbx]
        ; 52:37 sub
        sub al, cl
        movzx rbx, al
        ; 52:37 var $.6(%6)
        lea rax, [rsp+38]
        ; 52:37 assign
        mov [rax], rbx
        ; 52:2 call printStringLength
        lea rax, [rsp+30]
        mov rcx, [rax]
        lea rax, [rsp+38]
        mov rdx, [rax]
        sub rsp, 8
          call __printStringLength
        add rsp, 8
@printUint_ret:
        ; release space for local variables
        add rsp, 48
        ret

        ; void printIntLf
@printIntLf:
        ; reserve space for local variables
        sub rsp, 16
        ; 56:2 if number < 0
        ; 56:6 read var number(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 56:15 int lit 0
        mov rax, 0
        ; 56:13 <
        cmp rbx, rax
        setl cl
        and cl, 0xFF
        or cl, cl
        jz @else_3
        ; then
        ; 57:13 int lit 45
        mov al, 45
        ; 57:13 var $.1(%1)
        lea rbx, [rsp+0]
        ; 57:13 assign
        mov [rbx], al
        ; 57:3 call printChar
        lea rax, [rsp+0]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        ; 58:13 read var number(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 58:12 neg
        neg rbx
        ; 58:3 var number(%0)
        lea rax, [rsp+24]
        ; 58:10 assign
        mov [rax], rbx
        jmp @endif_3
        ; else
@else_3:
@endif_3:
        ; 60:12 read var number(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 60:12 var $.2(%2)
        lea rax, [rsp+1]
        ; 60:12 assign
        mov [rax], rbx
        ; 60:2 call printUint
        lea rax, [rsp+1]
        mov rax, [rax]
        push rax
          call @printUint
        add rsp, 8
        ; 61:12 int lit 10
        mov al, 10
        ; 61:12 var $.3(%3)
        lea rbx, [rsp+9]
        ; 61:12 assign
        mov [rbx], al
        ; 61:2 call printChar
        lea rax, [rsp+9]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
@printIntLf_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; i64 strlen
@strlen:
        ; reserve space for local variables
        sub rsp, 16
        ; 65:15 int lit 0
        mov rax, 0
        ; 65:2 var length(%1)
        lea rbx, [rsp+0]
        ; 65:2 assign
        mov [rbx], rax
        ; 66:2 for *str != 0
@for_4:
        ; 66:10 read var str(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 66:9 deref
        mov al, [rbx]
        ; 66:17 int lit 0
        mov bl, 0
        ; 66:14 !=
        cmp al, bl
        setne cl
        and cl, 0xFF
        or cl, cl
        jz @for_4_break
        ; for body
        ; 67:12 read var length(%1)
        lea rax, [rsp+0]
        mov rbx, [rax]
        ; 67:21 int lit 1
        mov rax, 1
        ; 67:19 add
        add rbx, rax
        ; 67:3 var length(%1)
        lea rax, [rsp+0]
        ; 67:10 assign
        mov [rax], rbx
@for_4_continue:
        ; 66:26 read var str(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 66:32 int lit 1
        mov rax, 1
        ; 66:30 add
        add rbx, rax
        ; 66:20 var str(%0)
        lea rax, [rsp+24]
        ; 66:24 assign
        mov [rax], rbx
        jmp @for_4
@for_4_break:
        ; 69:9 return length
        ; 69:9 read var length(%1)
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        jmp @strlen_ret
@strlen_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
@main:
        ; reserve space for local variables
        sub rsp, 272
        ; 4:14 string literal string_0
        lea rax, [string_0]
        ; 4:14 var $.0(%0)
        lea rbx, [rsp+0]
        ; 4:14 assign
        mov [rbx], rax
        ; 4:2 call printString
        lea rax, [rsp+0]
        mov rax, [rax]
        push rax
          call @printString
        add rsp, 8
        ; 5:8 int lit 0
        mov al, 0
        ; 5:12 int lit 0
        mov bl, 0
        ; 5:10 and
        and al, bl
        movzx rbx, al
        ; 5:10 var $.1(%1)
        lea rax, [rsp+8]
        ; 5:10 assign
        mov [rax], rbx
        ; 5:2 call print
        lea rax, [rsp+8]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 6:8 int lit 0
        mov al, 0
        ; 6:12 int lit 1
        mov bl, 1
        ; 6:10 and
        and al, bl
        movzx rbx, al
        ; 6:10 var $.2(%2)
        lea rax, [rsp+16]
        ; 6:10 assign
        mov [rax], rbx
        ; 6:2 call print
        lea rax, [rsp+16]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 7:8 int lit 1
        mov al, 1
        ; 7:12 int lit 0
        mov bl, 0
        ; 7:10 and
        and al, bl
        movzx rbx, al
        ; 7:10 var $.3(%3)
        lea rax, [rsp+24]
        ; 7:10 assign
        mov [rax], rbx
        ; 7:2 call print
        lea rax, [rsp+24]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 8:8 int lit 1
        mov al, 1
        ; 8:12 int lit 1
        mov bl, 1
        ; 8:10 and
        and al, bl
        movzx rbx, al
        ; 8:10 var $.4(%4)
        lea rax, [rsp+32]
        ; 8:10 assign
        mov [rax], rbx
        ; 8:2 call print
        lea rax, [rsp+32]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 9:14 string literal string_1
        lea rax, [string_1]
        ; 9:14 var $.5(%5)
        lea rbx, [rsp+40]
        ; 9:14 assign
        mov [rbx], rax
        ; 9:2 call printString
        lea rax, [rsp+40]
        mov rax, [rax]
        push rax
          call @printString
        add rsp, 8
        ; 10:8 int lit 0
        mov al, 0
        ; 10:12 int lit 0
        mov bl, 0
        ; 10:10 or
        or al, bl
        movzx rbx, al
        ; 10:10 var $.6(%6)
        lea rax, [rsp+48]
        ; 10:10 assign
        mov [rax], rbx
        ; 10:2 call print
        lea rax, [rsp+48]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 11:8 int lit 0
        mov al, 0
        ; 11:12 int lit 1
        mov bl, 1
        ; 11:10 or
        or al, bl
        movzx rbx, al
        ; 11:10 var $.7(%7)
        lea rax, [rsp+56]
        ; 11:10 assign
        mov [rax], rbx
        ; 11:2 call print
        lea rax, [rsp+56]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 12:8 int lit 1
        mov al, 1
        ; 12:12 int lit 0
        mov bl, 0
        ; 12:10 or
        or al, bl
        movzx rbx, al
        ; 12:10 var $.8(%8)
        lea rax, [rsp+64]
        ; 12:10 assign
        mov [rax], rbx
        ; 12:2 call print
        lea rax, [rsp+64]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 13:8 int lit 1
        mov al, 1
        ; 13:12 int lit 1
        mov bl, 1
        ; 13:10 or
        or al, bl
        movzx rbx, al
        ; 13:10 var $.9(%9)
        lea rax, [rsp+72]
        ; 13:10 assign
        mov [rax], rbx
        ; 13:2 call print
        lea rax, [rsp+72]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 14:14 string literal string_2
        lea rax, [string_2]
        ; 14:14 var $.10(%10)
        lea rbx, [rsp+80]
        ; 14:14 assign
        mov [rbx], rax
        ; 14:2 call printString
        lea rax, [rsp+80]
        mov rax, [rax]
        push rax
          call @printString
        add rsp, 8
        ; 15:8 int lit 0
        mov al, 0
        ; 15:12 int lit 0
        mov bl, 0
        ; 15:10 xor
        xor al, bl
        movzx rbx, al
        ; 15:10 var $.11(%11)
        lea rax, [rsp+88]
        ; 15:10 assign
        mov [rax], rbx
        ; 15:2 call print
        lea rax, [rsp+88]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 16:8 int lit 0
        mov al, 0
        ; 16:12 int lit 2
        mov bl, 2
        ; 16:10 xor
        xor al, bl
        movzx rbx, al
        ; 16:10 var $.12(%12)
        lea rax, [rsp+96]
        ; 16:10 assign
        mov [rax], rbx
        ; 16:2 call print
        lea rax, [rsp+96]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 17:8 int lit 1
        mov al, 1
        ; 17:12 int lit 0
        mov bl, 0
        ; 17:10 xor
        xor al, bl
        movzx rbx, al
        ; 17:10 var $.13(%13)
        lea rax, [rsp+104]
        ; 17:10 assign
        mov [rax], rbx
        ; 17:2 call print
        lea rax, [rsp+104]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 18:8 int lit 1
        mov al, 1
        ; 18:12 int lit 2
        mov bl, 2
        ; 18:10 xor
        xor al, bl
        movzx rbx, al
        ; 18:10 var $.14(%14)
        lea rax, [rsp+112]
        ; 18:10 assign
        mov [rax], rbx
        ; 18:2 call print
        lea rax, [rsp+112]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 19:14 string literal string_3
        lea rax, [string_3]
        ; 19:14 var $.15(%15)
        lea rbx, [rsp+120]
        ; 19:14 assign
        mov [rbx], rax
        ; 19:2 call printString
        lea rax, [rsp+120]
        mov rax, [rax]
        push rax
          call @printString
        add rsp, 8
        ; 20:14 logic and
        ; 20:8 bool lit false
        mov al, 0
        or al, al
        jz @and_next_5
        ; 20:17 bool lit false
        mov bl, 0
        mov al, bl
@and_next_5:
        movzx rbx, al
        ; 20:14 var $.16(%16)
        lea rax, [rsp+128]
        ; 20:14 assign
        mov [rax], rbx
        ; 20:2 call print
        lea rax, [rsp+128]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 21:14 logic and
        ; 21:8 bool lit false
        mov al, 0
        or al, al
        jz @and_next_6
        ; 21:17 bool lit true
        mov bl, 1
        mov al, bl
@and_next_6:
        movzx rbx, al
        ; 21:14 var $.17(%17)
        lea rax, [rsp+136]
        ; 21:14 assign
        mov [rax], rbx
        ; 21:2 call print
        lea rax, [rsp+136]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 22:13 logic and
        ; 22:8 bool lit true
        mov al, 1
        or al, al
        jz @and_next_7
        ; 22:16 bool lit false
        mov bl, 0
        mov al, bl
@and_next_7:
        movzx rbx, al
        ; 22:13 var $.18(%18)
        lea rax, [rsp+144]
        ; 22:13 assign
        mov [rax], rbx
        ; 22:2 call print
        lea rax, [rsp+144]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 23:13 logic and
        ; 23:8 bool lit true
        mov al, 1
        or al, al
        jz @and_next_8
        ; 23:16 bool lit true
        mov bl, 1
        mov al, bl
@and_next_8:
        movzx rbx, al
        ; 23:13 var $.19(%19)
        lea rax, [rsp+152]
        ; 23:13 assign
        mov [rax], rbx
        ; 23:2 call print
        lea rax, [rsp+152]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 24:14 string literal string_4
        lea rax, [string_4]
        ; 24:14 var $.20(%20)
        lea rbx, [rsp+160]
        ; 24:14 assign
        mov [rbx], rax
        ; 24:2 call printString
        lea rax, [rsp+160]
        mov rax, [rax]
        push rax
          call @printString
        add rsp, 8
        ; 25:14 logic or
        ; 25:8 bool lit false
        mov al, 0
        or al, al
        jnz @or_next_9
        ; 25:17 bool lit false
        mov bl, 0
        mov al, bl
@or_next_9:
        movzx rbx, al
        ; 25:14 var $.21(%21)
        lea rax, [rsp+168]
        ; 25:14 assign
        mov [rax], rbx
        ; 25:2 call print
        lea rax, [rsp+168]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 26:14 logic or
        ; 26:8 bool lit false
        mov al, 0
        or al, al
        jnz @or_next_10
        ; 26:17 bool lit true
        mov bl, 1
        mov al, bl
@or_next_10:
        movzx rbx, al
        ; 26:14 var $.22(%22)
        lea rax, [rsp+176]
        ; 26:14 assign
        mov [rax], rbx
        ; 26:2 call print
        lea rax, [rsp+176]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 27:13 logic or
        ; 27:8 bool lit true
        mov al, 1
        or al, al
        jnz @or_next_11
        ; 27:16 bool lit false
        mov bl, 0
        mov al, bl
@or_next_11:
        movzx rbx, al
        ; 27:13 var $.23(%23)
        lea rax, [rsp+184]
        ; 27:13 assign
        mov [rax], rbx
        ; 27:2 call print
        lea rax, [rsp+184]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 28:13 logic or
        ; 28:8 bool lit true
        mov al, 1
        or al, al
        jnz @or_next_12
        ; 28:16 bool lit true
        mov bl, 1
        mov al, bl
@or_next_12:
        movzx rbx, al
        ; 28:13 var $.24(%24)
        lea rax, [rsp+192]
        ; 28:13 assign
        mov [rax], rbx
        ; 28:2 call print
        lea rax, [rsp+192]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 29:14 string literal string_5
        lea rax, [string_5]
        ; 29:14 var $.25(%25)
        lea rbx, [rsp+200]
        ; 29:14 assign
        mov [rbx], rax
        ; 29:2 call printString
        lea rax, [rsp+200]
        mov rax, [rax]
        push rax
          call @printString
        add rsp, 8
        ; 30:9 bool lit false
        mov al, 0
        ; 30:8 not
        or al, al
        sete al
        movzx rbx, al
        ; 30:8 var $.26(%26)
        lea rax, [rsp+208]
        ; 30:8 assign
        mov [rax], rbx
        ; 30:2 call print
        lea rax, [rsp+208]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 31:9 bool lit true
        mov al, 1
        ; 31:8 not
        or al, al
        sete al
        movzx rbx, al
        ; 31:8 var $.27(%27)
        lea rax, [rsp+216]
        ; 31:8 assign
        mov [rax], rbx
        ; 31:2 call print
        lea rax, [rsp+216]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 32:14 string literal string_6
        lea rax, [string_6]
        ; 32:14 var $.28(%28)
        lea rbx, [rsp+224]
        ; 32:14 assign
        mov [rbx], rax
        ; 32:2 call printString
        lea rax, [rsp+224]
        mov rax, [rax]
        push rax
          call @printString
        add rsp, 8
        ; 33:8 int lit 10
        mov al, 10
        ; 33:17 int lit 6
        mov bl, 6
        ; 33:15 and
        and al, bl
        ; 33:26 int lit 1
        mov bl, 1
        ; 33:24 or
        or al, bl
        movzx rbx, al
        ; 33:24 var $.29(%29)
        lea rax, [rsp+232]
        ; 33:24 assign
        mov [rax], rbx
        ; 33:2 call print
        lea rax, [rsp+232]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 34:15 logic or
        ; 34:8 int lit 1
        mov al, 1
        ; 34:13 int lit 2
        mov bl, 2
        ; 34:10 ==
        cmp al, bl
        sete cl
        and cl, 0xFF
        or cl, cl
        jnz @or_next_13
        ; 34:18 int lit 2
        mov al, 2
        ; 34:22 int lit 3
        mov bl, 3
        ; 34:20 <
        cmp al, bl
        setl dl
        and dl, 0xFF
        mov cl, dl
@or_next_13:
        movzx rax, cl
        ; 34:15 var $.30(%30)
        lea rbx, [rsp+240]
        ; 34:15 assign
        mov [rbx], rax
        ; 34:2 call print
        lea rax, [rsp+240]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 35:15 logic and
        ; 35:8 int lit 1
        mov al, 1
        ; 35:13 int lit 2
        mov bl, 2
        ; 35:10 ==
        cmp al, bl
        sete cl
        and cl, 0xFF
        or cl, cl
        jz @and_next_14
        ; 35:18 int lit 2
        mov al, 2
        ; 35:22 int lit 3
        mov bl, 3
        ; 35:20 <
        cmp al, bl
        setl dl
        and dl, 0xFF
        mov cl, dl
@and_next_14:
        movzx rax, cl
        ; 35:15 var $.31(%31)
        lea rbx, [rsp+248]
        ; 35:15 assign
        mov [rbx], rax
        ; 35:2 call print
        lea rax, [rsp+248]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 36:9 int lit 1
        mov ax, 1
        ; 36:8 neg
        neg ax
        movzx rbx, ax
        ; 36:8 var $.32(%32)
        lea rax, [rsp+256]
        ; 36:8 assign
        mov [rax], rbx
        ; 36:2 call print
        lea rax, [rsp+256]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 37:9 int lit 1
        mov al, 1
        ; 37:8 com
        not al
        movzx rbx, al
        ; 37:8 var $.33(%33)
        lea rax, [rsp+264]
        ; 37:8 assign
        mov [rax], rbx
        ; 37:2 call print
        lea rax, [rsp+264]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
@main_ret:
        ; release space for local variables
        add rsp, 272
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
__emit:
        push rcx ; = sub rsp, 8
          mov rcx, rsp
          mov rdx, 1
          call __printStringLength
        pop rcx
        ret
__printStringLength:
        mov     rdi, rsp
        and     spl, 0xf0

        mov     r8, rdx
        mov     rdx, rcx
        lea     rcx, [hStdOut]
        mov     rcx, qword [rcx]
        xor     r9, r9
        push    0
          sub     rsp, 20h
            call    [WriteFile]
          add     rsp, 20h
        ; add     rsp, 8
        mov     rsp, rdi
        ret
__printUint:
        push   rbp
        mov    rbp,rsp
        sub    rsp, 50h
        mov    qword [rsp+24h], rcx

        ; int pos = sizeof(buf);
        mov    ax, 20h
        mov    word [rsp+20h], ax

        ; do {
.print:
        ; pos--;
        mov    ax, word [rsp+20h]
        dec    ax
        mov    word [rsp+20h], ax

        ; int remainder = x mod 10;
        ; x = x / 10;
        mov    rax, qword [rsp+24h]
        mov    ecx, 10
        xor    edx, edx
        div    ecx
        mov    qword [rsp+24h], rax

        ; int digit = remainder + '0';
        add    dl, '0'

        ; buf[pos] = digit;
        mov    ax, word [rsp+20h]
        movzx  rax, ax
        lea    rcx, qword [rsp]
        add    rcx, rax
        mov    byte [rcx], dl

        ; } while (x > 0);
        mov    rax, qword [rsp+24h]
        cmp    rax, 0
        ja     .print

        ; rcx = &buf[pos]

        ; rdx = sizeof(buf) - pos
        mov    ax, word [rsp+20h]
        movzx  rax, ax
        mov    rdx, 20h
        sub    rdx, rax

        ;sub    rsp, 8  not necessary because initial push rbp
          call   __printStringLength
        ;add    rsp, 8
        leave ; Set SP to BP, then pop BP
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
