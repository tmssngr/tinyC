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

        ; void main
@main:
        ; reserve space for local variables
        sub rsp, 272
        ; 2:14 string literal string_0
        lea rcx, [string_0]
        ; 2:14 var $.0(%0)
        lea rax, [rsp+0]
        ; 2:14 assign
        mov [rax], rcx
        ; 2:14 read var $.0(%0)
        lea rcx, [rsp+0]
        mov rax, [rcx]
        ; 2:2 print u8*
        sub rsp, 8
          mov rcx, rax
          call __printStringZero
        add rsp, 8
        ; 3:8 int lit 0
        mov cl, 0
        ; 3:12 int lit 0
        mov al, 0
        ; 3:10 and
        and cl, al
        movzx rax, cl
        ; 3:10 var $.1(%1)
        lea rcx, [rsp+8]
        ; 3:10 assign
        mov [rcx], rax
        ; 3:10 read var $.1(%1)
        lea rcx, [rsp+8]
        mov rax, [rcx]
        ; 3:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 4:8 int lit 0
        mov cl, 0
        ; 4:12 int lit 1
        mov al, 1
        ; 4:10 and
        and cl, al
        movzx rax, cl
        ; 4:10 var $.2(%2)
        lea rcx, [rsp+16]
        ; 4:10 assign
        mov [rcx], rax
        ; 4:10 read var $.2(%2)
        lea rcx, [rsp+16]
        mov rax, [rcx]
        ; 4:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 5:8 int lit 1
        mov cl, 1
        ; 5:12 int lit 0
        mov al, 0
        ; 5:10 and
        and cl, al
        movzx rax, cl
        ; 5:10 var $.3(%3)
        lea rcx, [rsp+24]
        ; 5:10 assign
        mov [rcx], rax
        ; 5:10 read var $.3(%3)
        lea rcx, [rsp+24]
        mov rax, [rcx]
        ; 5:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 6:8 int lit 1
        mov cl, 1
        ; 6:12 int lit 1
        mov al, 1
        ; 6:10 and
        and cl, al
        movzx rax, cl
        ; 6:10 var $.4(%4)
        lea rcx, [rsp+32]
        ; 6:10 assign
        mov [rcx], rax
        ; 6:10 read var $.4(%4)
        lea rcx, [rsp+32]
        mov rax, [rcx]
        ; 6:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 7:14 string literal string_1
        lea rcx, [string_1]
        ; 7:14 var $.5(%5)
        lea rax, [rsp+40]
        ; 7:14 assign
        mov [rax], rcx
        ; 7:14 read var $.5(%5)
        lea rcx, [rsp+40]
        mov rax, [rcx]
        ; 7:2 print u8*
        sub rsp, 8
          mov rcx, rax
          call __printStringZero
        add rsp, 8
        ; 8:8 int lit 0
        mov cl, 0
        ; 8:12 int lit 0
        mov al, 0
        ; 8:10 or
        or cl, al
        movzx rax, cl
        ; 8:10 var $.6(%6)
        lea rcx, [rsp+48]
        ; 8:10 assign
        mov [rcx], rax
        ; 8:10 read var $.6(%6)
        lea rcx, [rsp+48]
        mov rax, [rcx]
        ; 8:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 9:8 int lit 0
        mov cl, 0
        ; 9:12 int lit 1
        mov al, 1
        ; 9:10 or
        or cl, al
        movzx rax, cl
        ; 9:10 var $.7(%7)
        lea rcx, [rsp+56]
        ; 9:10 assign
        mov [rcx], rax
        ; 9:10 read var $.7(%7)
        lea rcx, [rsp+56]
        mov rax, [rcx]
        ; 9:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 10:8 int lit 1
        mov cl, 1
        ; 10:12 int lit 0
        mov al, 0
        ; 10:10 or
        or cl, al
        movzx rax, cl
        ; 10:10 var $.8(%8)
        lea rcx, [rsp+64]
        ; 10:10 assign
        mov [rcx], rax
        ; 10:10 read var $.8(%8)
        lea rcx, [rsp+64]
        mov rax, [rcx]
        ; 10:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 11:8 int lit 1
        mov cl, 1
        ; 11:12 int lit 1
        mov al, 1
        ; 11:10 or
        or cl, al
        movzx rax, cl
        ; 11:10 var $.9(%9)
        lea rcx, [rsp+72]
        ; 11:10 assign
        mov [rcx], rax
        ; 11:10 read var $.9(%9)
        lea rcx, [rsp+72]
        mov rax, [rcx]
        ; 11:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 12:14 string literal string_2
        lea rcx, [string_2]
        ; 12:14 var $.10(%10)
        lea rax, [rsp+80]
        ; 12:14 assign
        mov [rax], rcx
        ; 12:14 read var $.10(%10)
        lea rcx, [rsp+80]
        mov rax, [rcx]
        ; 12:2 print u8*
        sub rsp, 8
          mov rcx, rax
          call __printStringZero
        add rsp, 8
        ; 13:8 int lit 0
        mov cl, 0
        ; 13:12 int lit 0
        mov al, 0
        ; 13:10 xor
        xor cl, al
        movzx rax, cl
        ; 13:10 var $.11(%11)
        lea rcx, [rsp+88]
        ; 13:10 assign
        mov [rcx], rax
        ; 13:10 read var $.11(%11)
        lea rcx, [rsp+88]
        mov rax, [rcx]
        ; 13:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 14:8 int lit 0
        mov cl, 0
        ; 14:12 int lit 2
        mov al, 2
        ; 14:10 xor
        xor cl, al
        movzx rax, cl
        ; 14:10 var $.12(%12)
        lea rcx, [rsp+96]
        ; 14:10 assign
        mov [rcx], rax
        ; 14:10 read var $.12(%12)
        lea rcx, [rsp+96]
        mov rax, [rcx]
        ; 14:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 15:8 int lit 1
        mov cl, 1
        ; 15:12 int lit 0
        mov al, 0
        ; 15:10 xor
        xor cl, al
        movzx rax, cl
        ; 15:10 var $.13(%13)
        lea rcx, [rsp+104]
        ; 15:10 assign
        mov [rcx], rax
        ; 15:10 read var $.13(%13)
        lea rcx, [rsp+104]
        mov rax, [rcx]
        ; 15:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 16:8 int lit 1
        mov cl, 1
        ; 16:12 int lit 2
        mov al, 2
        ; 16:10 xor
        xor cl, al
        movzx rax, cl
        ; 16:10 var $.14(%14)
        lea rcx, [rsp+112]
        ; 16:10 assign
        mov [rcx], rax
        ; 16:10 read var $.14(%14)
        lea rcx, [rsp+112]
        mov rax, [rcx]
        ; 16:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 17:14 string literal string_3
        lea rcx, [string_3]
        ; 17:14 var $.15(%15)
        lea rax, [rsp+120]
        ; 17:14 assign
        mov [rax], rcx
        ; 17:14 read var $.15(%15)
        lea rcx, [rsp+120]
        mov rax, [rcx]
        ; 17:2 print u8*
        sub rsp, 8
          mov rcx, rax
          call __printStringZero
        add rsp, 8
        ; 18:14 logic and
        ; 18:8 bool lit false
        mov cl, 0
        or cl, cl
        jz @and_next_1
        ; 18:17 bool lit false
        mov al, 0
        mov cl, al
@and_next_1:
        movzx rax, cl
        ; 18:14 var $.16(%16)
        lea rcx, [rsp+128]
        ; 18:14 assign
        mov [rcx], rax
        ; 18:14 read var $.16(%16)
        lea rcx, [rsp+128]
        mov rax, [rcx]
        ; 18:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 19:14 logic and
        ; 19:8 bool lit false
        mov cl, 0
        or cl, cl
        jz @and_next_2
        ; 19:17 bool lit true
        mov al, 1
        mov cl, al
@and_next_2:
        movzx rax, cl
        ; 19:14 var $.17(%17)
        lea rcx, [rsp+136]
        ; 19:14 assign
        mov [rcx], rax
        ; 19:14 read var $.17(%17)
        lea rcx, [rsp+136]
        mov rax, [rcx]
        ; 19:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 20:13 logic and
        ; 20:8 bool lit true
        mov cl, 1
        or cl, cl
        jz @and_next_3
        ; 20:16 bool lit false
        mov al, 0
        mov cl, al
@and_next_3:
        movzx rax, cl
        ; 20:13 var $.18(%18)
        lea rcx, [rsp+144]
        ; 20:13 assign
        mov [rcx], rax
        ; 20:13 read var $.18(%18)
        lea rcx, [rsp+144]
        mov rax, [rcx]
        ; 20:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 21:13 logic and
        ; 21:8 bool lit true
        mov cl, 1
        or cl, cl
        jz @and_next_4
        ; 21:16 bool lit true
        mov al, 1
        mov cl, al
@and_next_4:
        movzx rax, cl
        ; 21:13 var $.19(%19)
        lea rcx, [rsp+152]
        ; 21:13 assign
        mov [rcx], rax
        ; 21:13 read var $.19(%19)
        lea rcx, [rsp+152]
        mov rax, [rcx]
        ; 21:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 22:14 string literal string_4
        lea rcx, [string_4]
        ; 22:14 var $.20(%20)
        lea rax, [rsp+160]
        ; 22:14 assign
        mov [rax], rcx
        ; 22:14 read var $.20(%20)
        lea rcx, [rsp+160]
        mov rax, [rcx]
        ; 22:2 print u8*
        sub rsp, 8
          mov rcx, rax
          call __printStringZero
        add rsp, 8
        ; 23:14 logic or
        ; 23:8 bool lit false
        mov cl, 0
        or cl, cl
        jnz @or_next_5
        ; 23:17 bool lit false
        mov al, 0
        mov cl, al
@or_next_5:
        movzx rax, cl
        ; 23:14 var $.21(%21)
        lea rcx, [rsp+168]
        ; 23:14 assign
        mov [rcx], rax
        ; 23:14 read var $.21(%21)
        lea rcx, [rsp+168]
        mov rax, [rcx]
        ; 23:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 24:14 logic or
        ; 24:8 bool lit false
        mov cl, 0
        or cl, cl
        jnz @or_next_6
        ; 24:17 bool lit true
        mov al, 1
        mov cl, al
@or_next_6:
        movzx rax, cl
        ; 24:14 var $.22(%22)
        lea rcx, [rsp+176]
        ; 24:14 assign
        mov [rcx], rax
        ; 24:14 read var $.22(%22)
        lea rcx, [rsp+176]
        mov rax, [rcx]
        ; 24:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 25:13 logic or
        ; 25:8 bool lit true
        mov cl, 1
        or cl, cl
        jnz @or_next_7
        ; 25:16 bool lit false
        mov al, 0
        mov cl, al
@or_next_7:
        movzx rax, cl
        ; 25:13 var $.23(%23)
        lea rcx, [rsp+184]
        ; 25:13 assign
        mov [rcx], rax
        ; 25:13 read var $.23(%23)
        lea rcx, [rsp+184]
        mov rax, [rcx]
        ; 25:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 26:13 logic or
        ; 26:8 bool lit true
        mov cl, 1
        or cl, cl
        jnz @or_next_8
        ; 26:16 bool lit true
        mov al, 1
        mov cl, al
@or_next_8:
        movzx rax, cl
        ; 26:13 var $.24(%24)
        lea rcx, [rsp+192]
        ; 26:13 assign
        mov [rcx], rax
        ; 26:13 read var $.24(%24)
        lea rcx, [rsp+192]
        mov rax, [rcx]
        ; 26:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 27:14 string literal string_5
        lea rcx, [string_5]
        ; 27:14 var $.25(%25)
        lea rax, [rsp+200]
        ; 27:14 assign
        mov [rax], rcx
        ; 27:14 read var $.25(%25)
        lea rcx, [rsp+200]
        mov rax, [rcx]
        ; 27:2 print u8*
        sub rsp, 8
          mov rcx, rax
          call __printStringZero
        add rsp, 8
        ; 28:9 bool lit false
        mov cl, 0
        ; 28:8 not
        or cl, cl
        sete cl
        movzx rax, cl
        ; 28:8 var $.26(%26)
        lea rcx, [rsp+208]
        ; 28:8 assign
        mov [rcx], rax
        ; 28:8 read var $.26(%26)
        lea rcx, [rsp+208]
        mov rax, [rcx]
        ; 28:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 29:9 bool lit true
        mov cl, 1
        ; 29:8 not
        or cl, cl
        sete cl
        movzx rax, cl
        ; 29:8 var $.27(%27)
        lea rcx, [rsp+216]
        ; 29:8 assign
        mov [rcx], rax
        ; 29:8 read var $.27(%27)
        lea rcx, [rsp+216]
        mov rax, [rcx]
        ; 29:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 30:14 string literal string_6
        lea rcx, [string_6]
        ; 30:14 var $.28(%28)
        lea rax, [rsp+224]
        ; 30:14 assign
        mov [rax], rcx
        ; 30:14 read var $.28(%28)
        lea rcx, [rsp+224]
        mov rax, [rcx]
        ; 30:2 print u8*
        sub rsp, 8
          mov rcx, rax
          call __printStringZero
        add rsp, 8
        ; 31:8 int lit 10
        mov cl, 10
        ; 31:17 int lit 6
        mov al, 6
        ; 31:15 and
        and cl, al
        ; 31:26 int lit 1
        mov al, 1
        ; 31:24 or
        or cl, al
        movzx rax, cl
        ; 31:24 var $.29(%29)
        lea rcx, [rsp+232]
        ; 31:24 assign
        mov [rcx], rax
        ; 31:24 read var $.29(%29)
        lea rcx, [rsp+232]
        mov rax, [rcx]
        ; 31:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 32:15 logic or
        ; 32:8 int lit 1
        mov cl, 1
        ; 32:13 int lit 2
        mov al, 2
        ; 32:10 ==
        cmp cl, al
        sete bl
        and bl, 0xFF
        or bl, bl
        jnz @or_next_9
        ; 32:18 int lit 2
        mov cl, 2
        ; 32:22 int lit 3
        mov al, 3
        ; 32:20 <
        cmp cl, al
        setl dl
        and dl, 0xFF
        mov bl, dl
@or_next_9:
        movzx rcx, bl
        ; 32:15 var $.30(%30)
        lea rax, [rsp+240]
        ; 32:15 assign
        mov [rax], rcx
        ; 32:15 read var $.30(%30)
        lea rcx, [rsp+240]
        mov rax, [rcx]
        ; 32:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 33:15 logic and
        ; 33:8 int lit 1
        mov cl, 1
        ; 33:13 int lit 2
        mov al, 2
        ; 33:10 ==
        cmp cl, al
        sete bl
        and bl, 0xFF
        or bl, bl
        jz @and_next_10
        ; 33:18 int lit 2
        mov cl, 2
        ; 33:22 int lit 3
        mov al, 3
        ; 33:20 <
        cmp cl, al
        setl dl
        and dl, 0xFF
        mov bl, dl
@and_next_10:
        movzx rcx, bl
        ; 33:15 var $.31(%31)
        lea rax, [rsp+248]
        ; 33:15 assign
        mov [rax], rcx
        ; 33:15 read var $.31(%31)
        lea rcx, [rsp+248]
        mov rax, [rcx]
        ; 33:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 34:9 int lit 1
        mov cx, 1
        ; 34:8 neg
        neg cx
        movzx rax, cx
        ; 34:8 var $.32(%32)
        lea rcx, [rsp+256]
        ; 34:8 assign
        mov [rcx], rax
        ; 34:8 read var $.32(%32)
        lea rcx, [rsp+256]
        mov rax, [rcx]
        ; 34:2 print i64
        sub rsp, 8
          mov rcx, rax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 35:9 int lit 1
        mov cl, 1
        ; 35:8 com
        not cl
        movzx rax, cl
        ; 35:8 var $.33(%33)
        lea rcx, [rsp+264]
        ; 35:8 assign
        mov [rcx], rax
        ; 35:8 read var $.33(%33)
        lea rcx, [rsp+264]
        mov rax, [rcx]
        ; 35:2 print i64
        sub rsp, 8
          mov rcx, rax
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
          call __printString
        pop rcx
        ret
__printStringZero:
        mov rdx, rcx
__printStringZero_1:
        mov r9l, [rdx]
        or  r9l, r9l
        jz __printStringZero_2
        add rdx, 1
        jmp __printStringZero_1
__printStringZero_2:
        sub rdx, rcx
__printString:
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
          call   __printString
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
