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
        ; 2:22 read var str(%0)
        lea rax, [rsp+40]
        mov rbx, [rax]
        ; 2:22 var $.2(%2)
        lea rax, [rsp+8]
        ; 2:22 assign
        mov [rax], rbx
        ; 2:15 call strlen
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        ; 2:2 var length(%1)
        lea rbx, [rsp+0]
        ; 2:2 assign
        mov [rbx], rax
        ; 3:20 read var str(%0)
        lea rax, [rsp+40]
        mov rbx, [rax]
        ; 3:20 var $.3(%3)
        lea rax, [rsp+16]
        ; 3:20 assign
        mov [rax], rbx
        ; 3:2 call printStringLength
        lea rax, [rsp+16]
        mov rax, [rax]
        push rax
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printString_ret:
        ; release space for local variables
        add rsp, 32
        ret

        ; void printChar
@printChar:
        ; reserve space for local variables
        sub rsp, 16
        ; 7:21 var chr(%0)
        lea rax, [rsp+24]
        ; 7:20 var $.1(%1)
        lea rbx, [rsp+0]
        ; 7:20 assign
        mov [rbx], rax
        ; 7:26 int lit 1
        mov rax, 1
        ; 7:26 var $.2(%2)
        lea rbx, [rsp+8]
        ; 7:26 assign
        mov [rbx], rax
        ; 7:2 call printStringLength
        lea rax, [rsp+0]
        mov rax, [rax]
        push rax
        lea rax, [rsp+16]
        mov rax, [rax]
        push rax
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printChar_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint
@printUint:
        ; reserve space for local variables
        sub rsp, 48
        ; 12:11 int lit 20
        mov al, 20
        ; 12:2 var pos(%2)
        lea rbx, [rsp+20]
        ; 12:2 assign
        mov [rbx], al
        ; 13:2 while true
@while_1:
        ; 13:9 bool lit true
        mov al, 1
        or al, al
        jz @while_1_break
        ; while body
        ; 14:9 read var pos(%2)
        lea rax, [rsp+20]
        mov bl, [rax]
        ; 14:15 int lit 1
        mov al, 1
        ; 14:13 sub
        sub bl, al
        ; 14:3 var pos(%2)
        lea rax, [rsp+20]
        ; 14:7 assign
        mov [rax], bl
        ; 15:19 read var number(%0)
        lea rax, [rsp+56]
        mov rbx, [rax]
        ; 15:28 int lit 10
        mov rax, 10
        ; 15:26 mod
        mov rdx, rax
        mov rax, rbx
        mov rbx, rdx
        cqo
        idiv rbx
        mov rbx, rdx
        ; 15:3 var remainder(%3)
        lea rax, [rsp+21]
        ; 15:3 assign
        mov [rax], rbx
        ; 16:12 read var number(%0)
        lea rax, [rsp+56]
        mov rbx, [rax]
        ; 16:21 int lit 10
        mov rax, 10
        ; 16:19 divide
        mov rdx, rax
        mov rax, rbx
        mov rbx, rdx
        cqo
        idiv rbx
        mov rbx, rax
        ; 16:3 var number(%0)
        lea rax, [rsp+56]
        ; 16:10 assign
        mov [rax], rbx
        ; 17:18 read var remainder(%3)
        lea rax, [rsp+21]
        mov rbx, [rax]
        ; 17:30 int lit 48
        mov al, 48
        ; 17:28 add
        add bl, al
        ; 17:3 var digit(%4)
        lea rax, [rsp+29]
        ; 17:3 assign
        mov [rax], bl
        ; 18:17 read var digit(%4)
        lea rax, [rsp+29]
        mov bl, [rax]
        ; 18:10 array buffer(%1)
        ; 18:10 read var pos(%2)
        lea rax, [rsp+20]
        mov cl, [rax]
        movzx rax, cl
        imul rax, 1
        lea rcx, [rsp+0]
        add rcx, rax
        ; 18:15 assign
        mov [rcx], bl
        ; 19:3 if number == 0
        ; 19:7 read var number(%0)
        lea rax, [rsp+56]
        mov rbx, [rax]
        ; 19:17 int lit 0
        mov rax, 0
        ; 19:14 ==
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
        ; 23:28 array buffer(%1)
        ; 23:28 read var pos(%2)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rax, bl
        imul rax, 1
        lea rbx, [rsp+0]
        add rbx, rax
        ; 23:20 var $.5(%5)
        lea rax, [rsp+30]
        ; 23:20 assign
        mov [rax], rbx
        ; 23:34 int lit 20
        mov al, 20
        ; 23:39 read var pos(%2)
        lea rbx, [rsp+20]
        mov cl, [rbx]
        ; 23:37 sub
        sub al, cl
        movzx rbx, al
        ; 23:37 var $.6(%6)
        lea rax, [rsp+38]
        ; 23:37 assign
        mov [rax], rbx
        ; 23:2 call printStringLength
        lea rax, [rsp+30]
        mov rax, [rax]
        push rax
        lea rax, [rsp+46]
        mov rax, [rax]
        push rax
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printUint_ret:
        ; release space for local variables
        add rsp, 48
        ret

        ; void printIntLf
@printIntLf:
        ; reserve space for local variables
        sub rsp, 16
        ; 27:2 if number < 0
        ; 27:6 read var number(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 27:15 int lit 0
        mov rax, 0
        ; 27:13 <
        cmp rbx, rax
        setl cl
        and cl, 0xFF
        or cl, cl
        jz @else_3
        ; then
        ; 28:13 int lit 45
        mov al, 45
        ; 28:13 var $.1(%1)
        lea rbx, [rsp+0]
        ; 28:13 assign
        mov [rbx], al
        ; 28:3 call printChar
        lea rax, [rsp+0]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        ; 29:13 read var number(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 29:12 neg
        neg rbx
        ; 29:3 var number(%0)
        lea rax, [rsp+24]
        ; 29:10 assign
        mov [rax], rbx
        jmp @endif_3
        ; else
@else_3:
@endif_3:
        ; 31:12 read var number(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 31:12 var $.2(%2)
        lea rax, [rsp+1]
        ; 31:12 assign
        mov [rax], rbx
        ; 31:2 call printUint
        lea rax, [rsp+1]
        mov rax, [rax]
        push rax
          call @printUint
        add rsp, 8
        ; 32:12 int lit 10
        mov al, 10
        ; 32:12 var $.3(%3)
        lea rbx, [rsp+9]
        ; 32:12 assign
        mov [rbx], al
        ; 32:2 call printChar
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
        ; 36:15 int lit 0
        mov rax, 0
        ; 36:2 var length(%1)
        lea rbx, [rsp+0]
        ; 36:2 assign
        mov [rbx], rax
        ; 37:2 for *str != 0
@for_4:
        ; 37:10 read var str(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 37:9 deref
        mov al, [rbx]
        ; 37:17 int lit 0
        mov bl, 0
        ; 37:14 !=
        cmp al, bl
        setne cl
        and cl, 0xFF
        or cl, cl
        jz @for_4_break
        ; for body
        ; 38:12 read var length(%1)
        lea rax, [rsp+0]
        mov rbx, [rax]
        ; 38:21 int lit 1
        mov rax, 1
        ; 38:19 add
        add rbx, rax
        ; 38:3 var length(%1)
        lea rax, [rsp+0]
        ; 38:10 assign
        mov [rax], rbx
@for_4_continue:
        ; 37:26 read var str(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 37:32 int lit 1
        mov rax, 1
        ; 37:30 add
        add rbx, rax
        ; 37:20 var str(%0)
        lea rax, [rsp+24]
        ; 37:24 assign
        mov [rax], rbx
        jmp @for_4
@for_4_break:
        ; 40:9 return length
        ; 40:9 read var length(%1)
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        jmp @strlen_ret
@strlen_ret:
        ; release space for local variables
        add rsp, 16
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
        ; 5:13 int lit 0
        mov al, 0
        ; 5:17 int lit 0
        mov bl, 0
        ; 5:15 and
        and al, bl
        movzx rbx, al
        ; 5:15 var $.1(%1)
        lea rax, [rsp+8]
        ; 5:15 assign
        mov [rax], rbx
        ; 5:2 call printIntLf
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 6:13 int lit 0
        mov al, 0
        ; 6:17 int lit 1
        mov bl, 1
        ; 6:15 and
        and al, bl
        movzx rbx, al
        ; 6:15 var $.2(%2)
        lea rax, [rsp+16]
        ; 6:15 assign
        mov [rax], rbx
        ; 6:2 call printIntLf
        lea rax, [rsp+16]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 7:13 int lit 1
        mov al, 1
        ; 7:17 int lit 0
        mov bl, 0
        ; 7:15 and
        and al, bl
        movzx rbx, al
        ; 7:15 var $.3(%3)
        lea rax, [rsp+24]
        ; 7:15 assign
        mov [rax], rbx
        ; 7:2 call printIntLf
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 8:13 int lit 1
        mov al, 1
        ; 8:17 int lit 1
        mov bl, 1
        ; 8:15 and
        and al, bl
        movzx rbx, al
        ; 8:15 var $.4(%4)
        lea rax, [rsp+32]
        ; 8:15 assign
        mov [rax], rbx
        ; 8:2 call printIntLf
        lea rax, [rsp+32]
        mov rax, [rax]
        push rax
          call @printIntLf
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
        ; 10:13 int lit 0
        mov al, 0
        ; 10:17 int lit 0
        mov bl, 0
        ; 10:15 or
        or al, bl
        movzx rbx, al
        ; 10:15 var $.6(%6)
        lea rax, [rsp+48]
        ; 10:15 assign
        mov [rax], rbx
        ; 10:2 call printIntLf
        lea rax, [rsp+48]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 11:13 int lit 0
        mov al, 0
        ; 11:17 int lit 1
        mov bl, 1
        ; 11:15 or
        or al, bl
        movzx rbx, al
        ; 11:15 var $.7(%7)
        lea rax, [rsp+56]
        ; 11:15 assign
        mov [rax], rbx
        ; 11:2 call printIntLf
        lea rax, [rsp+56]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 12:13 int lit 1
        mov al, 1
        ; 12:17 int lit 0
        mov bl, 0
        ; 12:15 or
        or al, bl
        movzx rbx, al
        ; 12:15 var $.8(%8)
        lea rax, [rsp+64]
        ; 12:15 assign
        mov [rax], rbx
        ; 12:2 call printIntLf
        lea rax, [rsp+64]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 13:13 int lit 1
        mov al, 1
        ; 13:17 int lit 1
        mov bl, 1
        ; 13:15 or
        or al, bl
        movzx rbx, al
        ; 13:15 var $.9(%9)
        lea rax, [rsp+72]
        ; 13:15 assign
        mov [rax], rbx
        ; 13:2 call printIntLf
        lea rax, [rsp+72]
        mov rax, [rax]
        push rax
          call @printIntLf
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
        ; 15:13 int lit 0
        mov al, 0
        ; 15:17 int lit 0
        mov bl, 0
        ; 15:15 xor
        xor al, bl
        movzx rbx, al
        ; 15:15 var $.11(%11)
        lea rax, [rsp+88]
        ; 15:15 assign
        mov [rax], rbx
        ; 15:2 call printIntLf
        lea rax, [rsp+88]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 16:13 int lit 0
        mov al, 0
        ; 16:17 int lit 2
        mov bl, 2
        ; 16:15 xor
        xor al, bl
        movzx rbx, al
        ; 16:15 var $.12(%12)
        lea rax, [rsp+96]
        ; 16:15 assign
        mov [rax], rbx
        ; 16:2 call printIntLf
        lea rax, [rsp+96]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 17:13 int lit 1
        mov al, 1
        ; 17:17 int lit 0
        mov bl, 0
        ; 17:15 xor
        xor al, bl
        movzx rbx, al
        ; 17:15 var $.13(%13)
        lea rax, [rsp+104]
        ; 17:15 assign
        mov [rax], rbx
        ; 17:2 call printIntLf
        lea rax, [rsp+104]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 18:13 int lit 1
        mov al, 1
        ; 18:17 int lit 2
        mov bl, 2
        ; 18:15 xor
        xor al, bl
        movzx rbx, al
        ; 18:15 var $.14(%14)
        lea rax, [rsp+112]
        ; 18:15 assign
        mov [rax], rbx
        ; 18:2 call printIntLf
        lea rax, [rsp+112]
        mov rax, [rax]
        push rax
          call @printIntLf
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
        ; 20:19 logic and
        ; 20:13 bool lit false
        mov al, 0
        or al, al
        jz @and_next_5
        ; 20:22 bool lit false
        mov bl, 0
        mov al, bl
@and_next_5:
        movzx rbx, al
        ; 20:19 var $.16(%16)
        lea rax, [rsp+128]
        ; 20:19 assign
        mov [rax], rbx
        ; 20:2 call printIntLf
        lea rax, [rsp+128]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 21:19 logic and
        ; 21:13 bool lit false
        mov al, 0
        or al, al
        jz @and_next_6
        ; 21:22 bool lit true
        mov bl, 1
        mov al, bl
@and_next_6:
        movzx rbx, al
        ; 21:19 var $.17(%17)
        lea rax, [rsp+136]
        ; 21:19 assign
        mov [rax], rbx
        ; 21:2 call printIntLf
        lea rax, [rsp+136]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 22:18 logic and
        ; 22:13 bool lit true
        mov al, 1
        or al, al
        jz @and_next_7
        ; 22:21 bool lit false
        mov bl, 0
        mov al, bl
@and_next_7:
        movzx rbx, al
        ; 22:18 var $.18(%18)
        lea rax, [rsp+144]
        ; 22:18 assign
        mov [rax], rbx
        ; 22:2 call printIntLf
        lea rax, [rsp+144]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 23:18 logic and
        ; 23:13 bool lit true
        mov al, 1
        or al, al
        jz @and_next_8
        ; 23:21 bool lit true
        mov bl, 1
        mov al, bl
@and_next_8:
        movzx rbx, al
        ; 23:18 var $.19(%19)
        lea rax, [rsp+152]
        ; 23:18 assign
        mov [rax], rbx
        ; 23:2 call printIntLf
        lea rax, [rsp+152]
        mov rax, [rax]
        push rax
          call @printIntLf
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
        ; 25:19 logic or
        ; 25:13 bool lit false
        mov al, 0
        or al, al
        jnz @or_next_9
        ; 25:22 bool lit false
        mov bl, 0
        mov al, bl
@or_next_9:
        movzx rbx, al
        ; 25:19 var $.21(%21)
        lea rax, [rsp+168]
        ; 25:19 assign
        mov [rax], rbx
        ; 25:2 call printIntLf
        lea rax, [rsp+168]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 26:19 logic or
        ; 26:13 bool lit false
        mov al, 0
        or al, al
        jnz @or_next_10
        ; 26:22 bool lit true
        mov bl, 1
        mov al, bl
@or_next_10:
        movzx rbx, al
        ; 26:19 var $.22(%22)
        lea rax, [rsp+176]
        ; 26:19 assign
        mov [rax], rbx
        ; 26:2 call printIntLf
        lea rax, [rsp+176]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 27:18 logic or
        ; 27:13 bool lit true
        mov al, 1
        or al, al
        jnz @or_next_11
        ; 27:21 bool lit false
        mov bl, 0
        mov al, bl
@or_next_11:
        movzx rbx, al
        ; 27:18 var $.23(%23)
        lea rax, [rsp+184]
        ; 27:18 assign
        mov [rax], rbx
        ; 27:2 call printIntLf
        lea rax, [rsp+184]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 28:18 logic or
        ; 28:13 bool lit true
        mov al, 1
        or al, al
        jnz @or_next_12
        ; 28:21 bool lit true
        mov bl, 1
        mov al, bl
@or_next_12:
        movzx rbx, al
        ; 28:18 var $.24(%24)
        lea rax, [rsp+192]
        ; 28:18 assign
        mov [rax], rbx
        ; 28:2 call printIntLf
        lea rax, [rsp+192]
        mov rax, [rax]
        push rax
          call @printIntLf
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
        ; 30:14 bool lit false
        mov al, 0
        ; 30:13 not
        or al, al
        sete al
        movzx rbx, al
        ; 30:13 var $.26(%26)
        lea rax, [rsp+208]
        ; 30:13 assign
        mov [rax], rbx
        ; 30:2 call printIntLf
        lea rax, [rsp+208]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 31:14 bool lit true
        mov al, 1
        ; 31:13 not
        or al, al
        sete al
        movzx rbx, al
        ; 31:13 var $.27(%27)
        lea rax, [rsp+216]
        ; 31:13 assign
        mov [rax], rbx
        ; 31:2 call printIntLf
        lea rax, [rsp+216]
        mov rax, [rax]
        push rax
          call @printIntLf
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
        ; 33:13 int lit 10
        mov al, 10
        ; 33:22 int lit 6
        mov bl, 6
        ; 33:20 and
        and al, bl
        ; 33:31 int lit 1
        mov bl, 1
        ; 33:29 or
        or al, bl
        movzx rbx, al
        ; 33:29 var $.29(%29)
        lea rax, [rsp+232]
        ; 33:29 assign
        mov [rax], rbx
        ; 33:2 call printIntLf
        lea rax, [rsp+232]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 34:20 logic or
        ; 34:13 int lit 1
        mov al, 1
        ; 34:18 int lit 2
        mov bl, 2
        ; 34:15 ==
        cmp al, bl
        sete cl
        and cl, 0xFF
        or cl, cl
        jnz @or_next_13
        ; 34:23 int lit 2
        mov al, 2
        ; 34:27 int lit 3
        mov bl, 3
        ; 34:25 <
        cmp al, bl
        setl dl
        and dl, 0xFF
        mov cl, dl
@or_next_13:
        movzx rax, cl
        ; 34:20 var $.30(%30)
        lea rbx, [rsp+240]
        ; 34:20 assign
        mov [rbx], rax
        ; 34:2 call printIntLf
        lea rax, [rsp+240]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 35:20 logic and
        ; 35:13 int lit 1
        mov al, 1
        ; 35:18 int lit 2
        mov bl, 2
        ; 35:15 ==
        cmp al, bl
        sete cl
        and cl, 0xFF
        or cl, cl
        jz @and_next_14
        ; 35:23 int lit 2
        mov al, 2
        ; 35:27 int lit 3
        mov bl, 3
        ; 35:25 <
        cmp al, bl
        setl dl
        and dl, 0xFF
        mov cl, dl
@and_next_14:
        movzx rax, cl
        ; 35:20 var $.31(%31)
        lea rbx, [rsp+248]
        ; 35:20 assign
        mov [rbx], rax
        ; 35:2 call printIntLf
        lea rax, [rsp+248]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 36:14 int lit 1
        mov ax, 1
        ; 36:13 neg
        neg ax
        movzx rbx, ax
        ; 36:13 var $.32(%32)
        lea rax, [rsp+256]
        ; 36:13 assign
        mov [rax], rbx
        ; 36:2 call printIntLf
        lea rax, [rsp+256]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 37:14 int lit 1
        mov al, 1
        ; 37:13 com
        not al
        movzx rbx, al
        ; 37:13 var $.33(%33)
        lea rax, [rsp+264]
        ; 37:13 assign
        mov [rax], rbx
        ; 37:2 call printIntLf
        lea rax, [rsp+264]
        mov rax, [rax]
        push rax
          call @printIntLf
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
