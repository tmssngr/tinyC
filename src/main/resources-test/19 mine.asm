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
        ; call r.0(0@register,i64), strlen, [str(0@argument,u8*)]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str(0@argument,u8*), r.0(0@register,i64)]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
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
        ; addrof r.0(0@register,u8*), chr(0@argument,u8)
        lea rcx, [rsp+24]
        ; const r.1(1@register,i64), 1
        mov rdx, 1
        ; call _, printStringLength [r.0(0@register,u8*), r.1(1@register,i64)]
        push rcx
        push rdx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
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
        ; const r.0(0@register,u8), 20
        mov cl, 20
        ; 13:2 while true
        ; copy pos(2@function,u8), r.0(0@register,u8)
        lea rax, [rsp+20]
        mov [rax], cl
@while_1:
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,u8), pos(2@function,u8)
        lea rax, [rsp+20]
        mov dl, [rax]
        ; sub r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        sub al, cl
        mov cl, al
        ; const r.1(1@register,i64), 10
        mov rdx, 10
        ; copy r.2(2@register,i64), number(0@argument,i64)
        lea rax, [rsp+136]
        mov r9, [rax]
        ; mod r.1(1@register,i64), r.2(2@register,i64), r.1(1@register,i64)
        mov rax, r9
        mov rbx, rdx
        cqo
        idiv rbx
        ; const r.3(3@register,i64), 10
        mov r10, 10
        ; div r.2(2@register,i64), r.2(2@register,i64), r.3(3@register,i64)
        push rdx
        mov rax, r9
        mov rbx, r10
        cqo
        idiv rbx
        mov r9, rax
        pop rdx
        ; cast r.1(1@register,u8), r.1(1@register,i64)
        ; const r.3(3@register,u8), 48
        mov r10b, 48
        ; add r.1(1@register,u8), r.1(1@register,u8), r.3(3@register,u8)
        add dl, r10b
        ; cast r.3(3@register,i64), r.0(0@register,u8)
        movzx r10, cl
        ; array r.3(3@register,u8*), buffer(1@function,u8*) + r.3(3@register,i64)
        lea rax, [rsp+0]
        add r10, rax
        ; store [r.3(3@register,u8*)], r.1(1@register,u8)
        mov [r10], dl
        ; 19:3 if number == 0
        ; const r.1(1@register,i64), 0
        mov rdx, 0
        ; equals r.1(1@register,bool), r.2(2@register,i64), r.1(1@register,i64)
        cmp r9, rdx
        sete dl
        ; copy pos(2@function,u8), r.0(0@register,u8)
        lea rax, [rsp+20]
        mov [rax], cl
        ; copy number(0@argument,i64), r.2(2@register,i64)
        lea rax, [rsp+136]
        mov [rax], r9
        ; branch r.1(1@register,bool), false, @while_1
        or dl, dl
        jz @while_1
        ; copy r.0(0@register,u8), pos(2@function,u8)
        lea rax, [rsp+20]
        mov cl, [rax]
        ; cast r.1(1@register,i64), r.0(0@register,u8)
        movzx rdx, cl
        ; addrof r.1(1@register,u8*), [buffer(1@function,u8*) + r.1(1@register,i64)]
        lea rax, [rsp+0]
        add rdx, rax
        ; const r.2(2@register,u8), 20
        mov r9b, 20
        ; sub r.0(0@register,u8), r.2(2@register,u8), r.0(0@register,u8)
        mov al, r9b
        sub al, cl
        mov cl, al
        ; cast r.0(0@register,i64), r.0(0@register,u8)
        movzx rcx, cl
        ; call _, printStringLength [r.1(1@register,u8*), r.0(0@register,i64)]
        push rdx
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 128
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
        ; const r.0(0@register,i64), 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; copy length(1@function,i64), r.0(0@register,i64)
        lea rax, [rsp+0]
        mov [rax], rcx
@for_3:
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        lea rax, [rsp+56]
        mov rcx, [rax]
        ; load r.1(1@register,u8), [r.0(0@register,u8*)]
        mov dl, [rcx]
        ; const r.2(2@register,u8), 0
        mov r9b, 0
        ; notequals r.1(1@register,bool), r.1(1@register,u8), r.2(2@register,u8)
        cmp dl, r9b
        setne dl
        ; branch r.1(1@register,bool), false, @for_3_break
        or dl, dl
        jz @for_3_break
        ; const r.0(0@register,i64), 1
        mov rcx, 1
        ; copy r.1(1@register,i64), length(1@function,i64)
        lea rax, [rsp+0]
        mov rdx, [rax]
        ; add r.0(0@register,i64), r.1(1@register,i64), r.0(0@register,i64)
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; copy length(1@function,i64), r.0(0@register,i64)
        lea rax, [rsp+0]
        mov [rax], rcx
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        lea rax, [rsp+56]
        mov rcx, [rax]
        ; cast r.0(0@register,i64), r.0(0@register,u8*)
        ; const r.1(1@register,i64), 1
        mov rdx, 1
        ; add r.0(0@register,i64), r.0(0@register,i64), r.1(1@register,i64)
        add rcx, rdx
        ; cast r.0(0@register,u8*), r.0(0@register,i64)
        ; copy str(0@argument,u8*), r.0(0@register,u8*)
        lea rax, [rsp+56]
        mov [rax], rcx
        jmp @for_3
@for_3_break:
        ; 40:9 return length
        ; copy r.0(0@register,i64), length(1@function,i64)
        lea rax, [rsp+0]
        mov rcx, [rax]
        ; ret r.0(0@register,i64)
        mov rax, rcx
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

        ; i16 getChar
@getChar:
        sub    rsp, 28h
          call [_getch]
          test al, al
          js   .1
          jnz  .2
          dec  al
.1:
          mov  rbx, rax
          shl  rbx, 8
          call [_getch]
          or   rax, rbx
.2:
        add    rsp, 28h
        ret

        ; void setCursor
@setCursor:
        mov     rdi, rsp
        and     spl, 0xf0

        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        mov     dx, [rdi+10h]
        shl     rdx, 16
        mov     dx, [rdi+18h]
        sub     rsp, 20h
          call   [SetConsoleCursorPosition]
        mov     rsp, rdi
        ret

        ; void initRandom
        ;   rsp+8: arg salt
@initRandom:
        ; copy r.0(0@register,i32), salt(0@argument,i32)
        lea rax, [rsp+8]
        mov ecx, [rax]
        ; copy __random__(0@global,i32), r.0(0@register,i32)
        lea rax, [var_0]
        mov [rax], ecx
        ret

        ; i32 random
        ;   rsp+0: var r
        ;   rsp+4: var b
        ;   rsp+8: var c
        ;   rsp+12: var d
        ;   rsp+16: var e
        ;   rsp+20: var t.5
        ;   rsp+24: var t.6
        ;   rsp+28: var t.7
        ;   rsp+32: var t.8
        ;   rsp+36: var t.9
        ;   rsp+40: var t.10
        ;   rsp+44: var t.11
        ;   rsp+48: var t.12
        ;   rsp+52: var t.13
        ;   rsp+56: var t.14
        ;   rsp+60: var t.15
        ;   rsp+64: var t.16
        ;   rsp+68: var t.17
        ;   rsp+72: var t.18
        ;   rsp+76: var t.19
        ;   rsp+80: var t.20
@random:
        ; reserve space for local variables
        sub rsp, 96
        ; copy r.0(0@register,i32), __random__(0@global,i32)
        lea rax, [var_0]
        mov ecx, [rax]
        ; const r.1(1@register,i32), 524287
        mov edx, 524287
        ; and r.1(1@register,i32), r.0(0@register,i32), r.1(1@register,i32)
        mov eax, ecx
        and eax, edx
        mov edx, eax
        ; const r.2(2@register,i32), 48271
        mov r9d, 48271
        ; mul r.1(1@register,i32), r.1(1@register,i32), r.2(2@register,i32)
        movsxd rdx, edx
        movsxd r9, r9d
        imul  rdx, r9
        ; const r.2(2@register,i32), 15
        mov r9d, 15
        ; shiftright r.0(0@register,i32), r.0(0@register,i32), r.2(2@register,i32)
        mov eax, ecx
        mov ecx, r9d
        sar eax, cl
        mov ecx, eax
        ; const r.2(2@register,i32), 48271
        mov r9d, 48271
        ; mul r.0(0@register,i32), r.0(0@register,i32), r.2(2@register,i32)
        movsxd rcx, ecx
        movsxd r9, r9d
        imul  rcx, r9
        ; const r.2(2@register,i32), 65535
        mov r9d, 65535
        ; and r.2(2@register,i32), r.0(0@register,i32), r.2(2@register,i32)
        mov eax, ecx
        and eax, r9d
        mov r9d, eax
        ; const r.3(3@register,i32), 15
        mov r10d, 15
        ; shiftleft r.2(2@register,i32), r.2(2@register,i32), r.3(3@register,i32)
        mov rbx, rcx
        mov eax, r9d
        mov cl, r10b
        sal eax, cl
        mov r9d, eax
        mov rcx, rbx
        ; const r.3(3@register,i32), 16
        mov r10d, 16
        ; shiftright r.0(0@register,i32), r.0(0@register,i32), r.3(3@register,i32)
        mov eax, ecx
        mov ecx, r10d
        sar eax, cl
        mov ecx, eax
        ; add r.0(0@register,i32), r.0(0@register,i32), r.1(1@register,i32)
        add ecx, edx
        ; add r.0(0@register,i32), r.0(0@register,i32), r.2(2@register,i32)
        add ecx, r9d
        ; const r.1(1@register,i32), 2147483647
        mov edx, 2147483647
        ; and r.1(1@register,i32), r.0(0@register,i32), r.1(1@register,i32)
        mov eax, ecx
        and eax, edx
        mov edx, eax
        ; const r.2(2@register,i32), 31
        mov r9d, 31
        ; shiftright r.0(0@register,i32), r.0(0@register,i32), r.2(2@register,i32)
        mov eax, ecx
        mov ecx, r9d
        sar eax, cl
        mov ecx, eax
        ; add r.0(0@register,i32), r.1(1@register,i32), r.0(0@register,i32)
        mov eax, edx
        add eax, ecx
        mov ecx, eax
        ; 127:9 return __random__
        ; copy __random__(0@global,i32), r.0(0@register,i32)
        lea rax, [var_0]
        mov [rax], ecx
        ; ret r.0(0@register,i32)
        mov rax, rcx
        ; release space for local variables
        add rsp, 96
        ret

        ; i16 rowColumnToCell
        ;   rsp+40: arg row
        ;   rsp+32: arg column
        ;   rsp+0: var t.2
        ;   rsp+2: var t.3
        ;   rsp+4: var t.4
@rowColumnToCell:
        ; reserve space for local variables
        sub rsp, 16
        ; 15:21 return row * 40 + column
        ; const r.0(0@register,i16), 40
        mov cx, 40
        ; copy r.1(1@register,i16), row(0@argument,i16)
        lea rax, [rsp+40]
        mov dx, [rax]
        ; mul r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        movsx rdx, dx
        movsx rcx, cx
        mov rax, rdx
        imul rax, rcx
        mov rcx, rax
        ; copy r.1(1@register,i16), column(1@argument,i16)
        lea rax, [rsp+32]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        add cx, dx
        ; ret r.0(0@register,i16)
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; u8 getCell
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+0: var t.2
        ;   rsp+8: var t.3
        ;   rsp+16: var t.4
        ;   rsp+24: var t.5
@getCell:
        ; reserve space for local variables
        sub rsp, 32
        ; 19:15 return [...]
        ; call r.0(0@register,i16), rowColumnToCell, [row(0@argument,i16), column(1@argument,i16)]
        lea rax, [rsp+56]
        mov ax, [rax]
        push rax
        lea rax, [rsp+56]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @rowColumnToCell
        add rsp, 24
        mov cx, ax
        ; cast r.0(0@register,i64), r.0(0@register,i16)
        movzx rcx, cx
        ; array r.0(0@register,u8*), field(1@global,u8*) + r.0(0@register,i64)
        lea rax, [var_1]
        add rcx, rax
        ; load r.0(0@register,u8), [r.0(0@register,u8*)]
        mov cl, [rcx]
        ; ret r.0(0@register,u8)
        mov rax, rcx
        ; release space for local variables
        add rsp, 32
        ret

        ; bool isBomb
        ;   rsp+24: arg cell
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+3: var t.4
@isBomb:
        ; reserve space for local variables
        sub rsp, 16
        ; 23:27 return cell & 1 != 0
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,u8), cell(0@argument,u8)
        lea rax, [rsp+24]
        mov dl, [rax]
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        and al, cl
        mov cl, al
        ; const r.1(1@register,u8), 0
        mov dl, 0
        ; notequals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        setne cl
        ; ret r.0(0@register,bool)
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool isOpen
        ;   rsp+24: arg cell
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+3: var t.4
@isOpen:
        ; reserve space for local variables
        sub rsp, 16
        ; 27:27 return cell & 2 != 0
        ; const r.0(0@register,u8), 2
        mov cl, 2
        ; copy r.1(1@register,u8), cell(0@argument,u8)
        lea rax, [rsp+24]
        mov dl, [rax]
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        and al, cl
        mov cl, al
        ; const r.1(1@register,u8), 0
        mov dl, 0
        ; notequals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        setne cl
        ; ret r.0(0@register,bool)
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool isFlag
        ;   rsp+24: arg cell
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+3: var t.4
@isFlag:
        ; reserve space for local variables
        sub rsp, 16
        ; 31:27 return cell & 4 != 0
        ; const r.0(0@register,u8), 4
        mov cl, 4
        ; copy r.1(1@register,u8), cell(0@argument,u8)
        lea rax, [rsp+24]
        mov dl, [rax]
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        and al, cl
        mov cl, al
        ; const r.1(1@register,u8), 0
        mov dl, 0
        ; notequals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        setne cl
        ; ret r.0(0@register,bool)
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool checkCellBounds
        ;   rsp+40: arg row
        ;   rsp+32: arg column
        ;   rsp+0: var t.2
        ;   rsp+2: var t.3
        ;   rsp+4: var t.4
        ;   rsp+6: var t.5
        ;   rsp+8: var t.6
@checkCellBounds:
        ; reserve space for local variables
        sub rsp, 16
        ; 36:21 return row > 0 && row < 20 && column > 0 && column < 40
        ; 36:21 logic and
        ; 36:6 logic and
        ; 35:21 logic and
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; copy r.1(1@register,i16), row(0@argument,i16)
        lea rax, [rsp+40]
        mov dx, [rax]
        ; gt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setg cl
        ; copy t.2(2@function,bool), r.0(0@register,bool)
        lea rax, [rsp+0]
        mov [rax], cl
        ; branch r.0(0@register,bool), false, @and_next_6
        or cl, cl
        jz @and_next_6
        ; const r.0(0@register,i16), 20
        mov cx, 20
        ; copy r.1(1@register,i16), row(0@argument,i16)
        lea rax, [rsp+40]
        mov dx, [rax]
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setl cl
        ; copy t.2(2@function,bool), r.0(0@register,bool)
        lea rax, [rsp+0]
        mov [rax], cl
@and_next_6:
        ; copy r.0(0@register,bool), t.2(2@function,bool)
        lea rax, [rsp+0]
        mov cl, [rax]
        ; branch r.0(0@register,bool), false, @and_next_5
        or cl, cl
        jz @and_next_5
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; copy r.1(1@register,i16), column(1@argument,i16)
        lea rax, [rsp+32]
        mov dx, [rax]
        ; gt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setg cl
        ; copy t.2(2@function,bool), r.0(0@register,bool)
        lea rax, [rsp+0]
        mov [rax], cl
@and_next_5:
        ; copy r.0(0@register,bool), t.2(2@function,bool)
        lea rax, [rsp+0]
        mov cl, [rax]
        ; branch r.0(0@register,bool), false, @and_next_4
        or cl, cl
        jz @and_next_4
        ; const r.0(0@register,i16), 40
        mov cx, 40
        ; copy r.1(1@register,i16), column(1@argument,i16)
        lea rax, [rsp+32]
        mov dx, [rax]
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setl cl
        ; copy t.2(2@function,bool), r.0(0@register,bool)
        lea rax, [rsp+0]
        mov [rax], cl
@and_next_4:
        ; copy r.0(0@register,bool), t.2(2@function,bool)
        lea rax, [rsp+0]
        mov cl, [rax]
        ; ret r.0(0@register,bool)
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; void setCell
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+40: arg cell
        ;   rsp+0: var t.3
        ;   rsp+8: var t.4
        ;   rsp+16: var t.5
@setCell:
        ; reserve space for local variables
        sub rsp, 32
        ; call r.0(0@register,i16), rowColumnToCell, [row(0@argument,i16), column(1@argument,i16)]
        lea rax, [rsp+56]
        mov ax, [rax]
        push rax
        lea rax, [rsp+56]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @rowColumnToCell
        add rsp, 24
        mov cx, ax
        ; cast r.0(0@register,i64), r.0(0@register,i16)
        movzx rcx, cx
        ; array r.0(0@register,u8*), field(1@global,u8*) + r.0(0@register,i64)
        lea rax, [var_1]
        add rcx, rax
        ; copy r.1(1@register,u8), cell(2@argument,u8)
        lea rax, [rsp+40]
        mov dl, [rax]
        ; store [r.0(0@register,u8*)], r.1(1@register,u8)
        mov [rcx], dl
        ; release space for local variables
        add rsp, 32
        ret

        ; u8 getBombCountAround
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+0: var count
        ;   rsp+2: var dr
        ;   rsp+4: var r
        ;   rsp+6: var dc
        ;   rsp+8: var c
        ;   rsp+10: var cell
        ;   rsp+11: var t.8
        ;   rsp+12: var t.9
        ;   rsp+14: var t.10
        ;   rsp+16: var t.11
        ;   rsp+18: var t.12
        ;   rsp+19: var t.13
        ;   rsp+20: var t.14
        ;   rsp+22: var t.15
        ;   rsp+24: var t.16
@getBombCountAround:
        ; reserve space for local variables
        sub rsp, 32
        ; const r.0(0@register,u8), 0
        mov cl, 0
        ; const r.1(1@register,i16), -1
        mov dx, -1
        ; 45:2 for dr <= 1
        ; copy count(2@function,u8), r.0(0@register,u8)
        lea rax, [rsp+0]
        mov [rax], cl
        ; copy dr(3@function,i16), r.1(1@register,i16)
        lea rax, [rsp+2]
        mov [rax], dx
@for_7:
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), dr(3@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; lteq r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setle cl
        ; branch r.0(0@register,bool), false, @for_7_break
        or cl, cl
        jz @for_7_break
        ; copy r.0(0@register,i16), row(0@argument,i16)
        lea rax, [rsp+56]
        mov cx, [rax]
        ; copy r.1(1@register,i16), dr(3@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        mov r9w, cx
        add r9w, dx
        ; const r.3(3@register,i16), -1
        mov r10w, -1
        ; 47:3 for dc <= 1
        ; copy r(4@function,i16), r.2(2@register,i16)
        lea rax, [rsp+4]
        mov [rax], r9w
        ; copy dc(5@function,i16), r.3(3@register,i16)
        lea rax, [rsp+6]
        mov [rax], r10w
@for_8:
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), dc(5@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; lteq r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setle cl
        ; branch r.0(0@register,bool), false, @for_7_continue
        or cl, cl
        jz @for_7_continue
        ; copy r.0(0@register,i16), column(1@argument,i16)
        lea rax, [rsp+48]
        mov cx, [rax]
        ; copy r.1(1@register,i16), dc(5@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; add r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        mov r9w, cx
        add r9w, dx
        ; 49:4 if checkCellBounds([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=49:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=49:27]])
        ; copy c(6@function,i16), r.2(2@register,i16)
        lea rax, [rsp+8]
        mov [rax], r9w
        ; call r.0(0@register,bool), checkCellBounds, [r(4@function,i16), r.2(2@register,i16)]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        push r9
        sub rsp, 8
          call @checkCellBounds
        add rsp, 24
        mov cl, al
        ; branch r.0(0@register,bool), false, @for_8_continue
        or cl, cl
        jz @for_8_continue
        ; call r.0(0@register,u8), getCell, [r(4@function,i16), c(6@function,i16)]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+16]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getCell
        add rsp, 24
        mov cl, al
        ; 51:5 if isBomb([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=51:16]])
        ; call r.0(0@register,bool), isBomb, [r.0(0@register,u8)]
        push rcx
          call @isBomb
        add rsp, 8
        mov cl, al
        ; branch r.0(0@register,bool), false, @for_8_continue
        or cl, cl
        jz @for_8_continue
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,u8), count(2@function,u8)
        lea rax, [rsp+0]
        mov dl, [rax]
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy count(2@function,u8), r.0(0@register,u8)
        lea rax, [rsp+0]
        mov [rax], cl
@for_8_continue:
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), dc(5@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; copy dc(5@function,i16), r.0(0@register,i16)
        lea rax, [rsp+6]
        mov [rax], cx
        jmp @for_8
@for_7_continue:
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), dr(3@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; copy dr(3@function,i16), r.0(0@register,i16)
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @for_7
@for_7_break:
        ; 57:9 return count
        ; copy r.0(0@register,u8), count(2@function,u8)
        lea rax, [rsp+0]
        mov cl, [rax]
        ; ret r.0(0@register,u8)
        mov rax, rcx
        ; release space for local variables
        add rsp, 32
        ret

        ; u8 getSpacer
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+40: arg rowCursor
        ;   rsp+32: arg columnCursor
        ;   rsp+0: var t.4
        ;   rsp+1: var t.5
        ;   rsp+2: var t.6
        ;   rsp+3: var t.7
        ;   rsp+4: var t.8
        ;   rsp+6: var t.9
        ;   rsp+8: var t.10
        ;   rsp+9: var t.11
@getSpacer:
        ; reserve space for local variables
        sub rsp, 16
        ; 61:2 if rowCursor == row
        ; copy r.0(0@register,i16), rowCursor(2@argument,i16)
        lea rax, [rsp+40]
        mov cx, [rax]
        ; copy r.1(1@register,i16), row(0@argument,i16)
        lea rax, [rsp+56]
        mov dx, [rax]
        ; equals r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        sete cl
        ; branch r.0(0@register,bool), false, @if_11_end
        or cl, cl
        jz @if_11_end
        ; 62:3 if columnCursor == column
        ; copy r.0(0@register,i16), columnCursor(3@argument,i16)
        lea rax, [rsp+32]
        mov cx, [rax]
        ; copy r.1(1@register,i16), column(1@argument,i16)
        lea rax, [rsp+48]
        mov dx, [rax]
        ; equals r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        sete r9b
        ; branch r.2(2@register,bool), false, @if_12_end
        or r9b, r9b
        jz @if_12_end
        ; 63:11 return 91
        ; const r.0(0@register,u8), 91
        mov cl, 91
        ; ret r.0(0@register,u8)
        mov rax, rcx
        jmp @getSpacer_ret
@if_12_end:
        ; 65:3 if columnCursor == column - 1
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), column(1@argument,i16)
        lea rax, [rsp+48]
        mov dx, [rax]
        ; sub r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        sub ax, cx
        mov cx, ax
        ; copy r.1(1@register,i16), columnCursor(3@argument,i16)
        lea rax, [rsp+32]
        mov dx, [rax]
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        sete cl
        ; branch r.0(0@register,bool), false, @if_11_end
        or cl, cl
        jz @if_11_end
        ; 66:11 return 93
        ; const r.0(0@register,u8), 93
        mov cl, 93
        ; ret r.0(0@register,u8)
        mov rax, rcx
        jmp @getSpacer_ret
@if_11_end:
        ; 69:9 return 32
        ; const r.0(0@register,u8), 32
        mov cl, 32
        ; ret r.0(0@register,u8)
        mov rax, rcx
@getSpacer_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printCell
        ;   rsp+40: arg cell
        ;   rsp+32: arg row
        ;   rsp+24: arg column
        ;   rsp+0: var chr
        ;   rsp+1: var count
        ;   rsp+2: var t.5
        ;   rsp+3: var t.6
        ;   rsp+4: var t.7
        ;   rsp+5: var t.8
        ;   rsp+6: var t.9
        ;   rsp+7: var t.10
@printCell:
        ; reserve space for local variables
        sub rsp, 16
        ; const r.0(0@register,u8), 46
        mov cl, 46
        ; 74:2 if isOpen([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=74:13]])
        ; copy chr(3@function,u8), r.0(0@register,u8)
        lea rax, [rsp+0]
        mov [rax], cl
        ; call r.0(0@register,bool), isOpen, [cell(0@argument,u8)]
        lea rax, [rsp+40]
        mov al, [rax]
        push rax
          call @isOpen
        add rsp, 8
        mov cl, al
        ; branch r.0(0@register,bool), false, @if_14_else
        or cl, cl
        jz @if_14_else
        ; 75:3 if isBomb([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=75:14]])
        ; call r.0(0@register,bool), isBomb, [cell(0@argument,u8)]
        lea rax, [rsp+40]
        mov al, [rax]
        push rax
          call @isBomb
        add rsp, 8
        mov cl, al
        ; branch r.0(0@register,bool), false, @if_15_else
        or cl, cl
        jz @if_15_else
        ; const r.0(0@register,u8), 42
        mov cl, 42
        ; copy chr(3@function,u8), r.0(0@register,u8)
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @if_14_end
@if_15_else:
        ; call r.0(0@register,u8), getBombCountAround, [row(1@argument,i16), column(2@argument,i16)]
        lea rax, [rsp+32]
        mov ax, [rax]
        push rax
        lea rax, [rsp+32]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getBombCountAround
        add rsp, 24
        mov cl, al
        ; 80:4 if count > 0
        ; const r.1(1@register,u8), 0
        mov dl, 0
        ; gt r.1(1@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        seta dl
        ; copy count(4@function,u8), r.0(0@register,u8)
        lea rax, [rsp+1]
        mov [rax], cl
        ; branch r.1(1@register,bool), false, @if_16_else
        or dl, dl
        jz @if_16_else
        ; const r.0(0@register,u8), 48
        mov cl, 48
        ; copy r.1(1@register,u8), count(4@function,u8)
        lea rax, [rsp+1]
        mov dl, [rax]
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy chr(3@function,u8), r.0(0@register,u8)
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @if_14_end
@if_16_else:
        ; const r.0(0@register,u8), 32
        mov cl, 32
        ; copy chr(3@function,u8), r.0(0@register,u8)
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @if_14_end
@if_14_else:
        ; 88:7 if isFlag([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=88:18]])
        ; call r.0(0@register,bool), isFlag, [cell(0@argument,u8)]
        lea rax, [rsp+40]
        mov al, [rax]
        push rax
          call @isFlag
        add rsp, 8
        mov cl, al
        ; branch r.0(0@register,bool), false, @if_14_end
        or cl, cl
        jz @if_14_end
        ; const r.0(0@register,u8), 35
        mov cl, 35
        ; copy chr(3@function,u8), r.0(0@register,u8)
        lea rax, [rsp+0]
        mov [rax], cl
@if_14_end:
        ; call _, printChar [chr(3@function,u8)]
        lea rax, [rsp+0]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printField
        ;   rsp+72: arg rowCursor
        ;   rsp+64: arg columnCursor
        ;   rsp+0: var row
        ;   rsp+2: var column
        ;   rsp+4: var spacer
        ;   rsp+5: var cell
        ;   rsp+6: var spacer
        ;   rsp+8: var t.7
        ;   rsp+10: var t.8
        ;   rsp+12: var t.9
        ;   rsp+14: var t.10
        ;   rsp+16: var t.11
        ;   rsp+17: var t.12
        ;   rsp+18: var t.13
        ;   rsp+20: var t.14
        ;   rsp+22: var t.15
        ;   rsp+24: var t.16
        ;   rsp+32: var t.17
@printField:
        ; reserve space for local variables
        sub rsp, 48
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; const r.1(1@register,i16), 0
        mov dx, 0
        ; call _, setCursor [r.0(0@register,i16), r.1(1@register,i16)]
        push rcx
        push rdx
        sub rsp, 8
          call @setCursor
        add rsp, 24
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; 96:2 for row < 20
        ; copy row(2@function,i16), r.0(0@register,i16)
        lea rax, [rsp+0]
        mov [rax], cx
@for_18:
        ; const r.0(0@register,i16), 20
        mov cx, 20
        ; copy r.1(1@register,i16), row(2@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setl cl
        ; branch r.0(0@register,bool), false, @printField_ret
        or cl, cl
        jz @printField_ret
        ; const r.0(0@register,u8), 124
        mov cl, 124
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; 98:3 for column < 40
        ; copy column(3@function,i16), r.0(0@register,i16)
        lea rax, [rsp+2]
        mov [rax], cx
@for_19:
        ; const r.0(0@register,i16), 40
        mov cx, 40
        ; copy r.1(1@register,i16), column(3@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setl cl
        ; branch r.0(0@register,bool), false, @for_19_break
        or cl, cl
        jz @for_19_break
        ; call r.0(0@register,u8), getSpacer, [row(2@function,i16), column(3@function,i16), rowCursor(0@argument,i16), columnCursor(1@argument,i16)]
        lea rax, [rsp+0]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        lea rax, [rsp+88]
        mov ax, [rax]
        push rax
        lea rax, [rsp+88]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getSpacer
        add rsp, 40
        mov cl, al
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
        ; call r.0(0@register,u8), getCell, [row(2@function,i16), column(3@function,i16)]
        lea rax, [rsp+0]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getCell
        add rsp, 24
        mov cl, al
        ; call _, printCell [r.0(0@register,u8), row(2@function,i16), column(3@function,i16)]
        push rcx
        lea rax, [rsp+8]
        mov ax, [rax]
        push rax
        lea rax, [rsp+18]
        mov ax, [rax]
        push rax
          call @printCell
        add rsp, 24
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), column(3@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; copy column(3@function,i16), r.0(0@register,i16)
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @for_19
@for_19_break:
        ; const r.0(0@register,i16), 40
        mov cx, 40
        ; call r.0(0@register,u8), getSpacer, [row(2@function,i16), r.0(0@register,i16), rowCursor(0@argument,i16), columnCursor(1@argument,i16)]
        lea rax, [rsp+0]
        mov ax, [rax]
        push rax
        push rcx
        lea rax, [rsp+88]
        mov ax, [rax]
        push rax
        lea rax, [rsp+88]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getSpacer
        add rsp, 40
        mov cl, al
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
        ; const r.0(0@register,u8*), [string-0]
        lea rcx, [string_0]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), row(2@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; copy row(2@function,i16), r.0(0@register,i16)
        lea rax, [rsp+0]
        mov [rax], cx
        jmp @for_18
@printField_ret:
        ; release space for local variables
        add rsp, 48
        ret

        ; void printSpaces
        ;   rsp+24: arg i
        ;   rsp+0: var t.1
        ;   rsp+2: var t.2
        ;   rsp+4: var t.3
        ;   rsp+6: var t.4
@printSpaces:
        ; reserve space for local variables
        sub rsp, 16
@for_20:
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; copy r.1(1@register,i16), i(0@argument,i16)
        lea rax, [rsp+24]
        mov dx, [rax]
        ; gt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setg cl
        ; branch r.0(0@register,bool), false, @printSpaces_ret
        or cl, cl
        jz @printSpaces_ret
        ; const r.0(0@register,u8), 48
        mov cl, 48
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), i(0@argument,i16)
        lea rax, [rsp+24]
        mov dx, [rax]
        ; sub r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        sub ax, cx
        mov cx, ax
        ; copy i(0@argument,i16), r.0(0@register,i16)
        lea rax, [rsp+24]
        mov [rax], cx
        jmp @for_20
@printSpaces_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; u8 getDigitCount
        ;   rsp+24: arg value
        ;   rsp+0: var count
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+4: var t.4
        ;   rsp+6: var t.5
        ;   rsp+8: var t.6
        ;   rsp+10: var t.7
@getDigitCount:
        ; reserve space for local variables
        sub rsp, 16
        ; const r.0(0@register,u8), 0
        mov cl, 0
        ; 118:2 if value < 0
        ; const r.1(1@register,i16), 0
        mov dx, 0
        ; copy r.2(2@register,i16), value(0@argument,i16)
        lea rax, [rsp+24]
        mov r9w, [rax]
        ; lt r.1(1@register,bool), r.2(2@register,i16), r.1(1@register,i16)
        cmp r9w, dx
        setl dl
        ; copy count(1@function,u8), r.0(0@register,u8)
        lea rax, [rsp+0]
        mov [rax], cl
        ; branch r.1(1@register,bool), false, @while_22
        or dl, dl
        jz @while_22
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,i16), value(0@argument,i16)
        lea rax, [rsp+24]
        mov dx, [rax]
        ; neg r.1(1@register,i16), r.1(1@register,i16)
        neg rdx
        ; copy count(1@function,u8), r.0(0@register,u8)
        lea rax, [rsp+0]
        mov [rax], cl
        ; copy value(0@argument,i16), r.1(1@register,i16)
        lea rax, [rsp+24]
        mov [rax], dx
@while_22:
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,u8), count(1@function,u8)
        lea rax, [rsp+0]
        mov dl, [rax]
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        add al, cl
        mov cl, al
        ; const r.1(1@register,i16), 10
        mov dx, 10
        ; copy r.2(2@register,i16), value(0@argument,i16)
        lea rax, [rsp+24]
        mov r9w, [rax]
        ; div r.1(1@register,i16), r.2(2@register,i16), r.1(1@register,i16)
        movsx rax, r9w
        movsx rbx, dx
        cqo
        idiv rbx
        mov rdx, rax
        ; 126:3 if value == 0
        ; const r.2(2@register,i16), 0
        mov r9w, 0
        ; equals r.2(2@register,bool), r.1(1@register,i16), r.2(2@register,i16)
        cmp dx, r9w
        sete r9b
        ; copy count(1@function,u8), r.0(0@register,u8)
        lea rax, [rsp+0]
        mov [rax], cl
        ; copy value(0@argument,i16), r.1(1@register,i16)
        lea rax, [rsp+24]
        mov [rax], dx
        ; branch r.2(2@register,bool), false, @while_22
        or r9b, r9b
        jz @while_22
        ; 131:9 return count
        ; copy r.0(0@register,u8), count(1@function,u8)
        lea rax, [rsp+0]
        mov cl, [rax]
        ; ret r.0(0@register,u8)
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool printLeft
        ;   rsp+0: var count
        ;   rsp+2: var r
        ;   rsp+4: var c
        ;   rsp+6: var cell
        ;   rsp+7: var leftDigits
        ;   rsp+8: var bombDigits
        ;   rsp+9: var t.6
        ;   rsp+10: var t.7
        ;   rsp+12: var t.8
        ;   rsp+14: var t.9
        ;   rsp+16: var t.10
        ;   rsp+17: var t.11
        ;   rsp+18: var t.12
        ;   rsp+19: var t.13
        ;   rsp+20: var t.14
        ;   rsp+22: var t.15
        ;   rsp+24: var t.16
        ;   rsp+26: var t.17
        ;   rsp+32: var t.18
        ;   rsp+40: var t.19
        ;   rsp+42: var t.20
        ;   rsp+48: var t.21
        ;   rsp+56: var t.22
        ;   rsp+58: var t.23
@printLeft:
        ; reserve space for local variables
        sub rsp, 64
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; const r.1(1@register,i16), 0
        mov dx, 0
        ; 136:2 for r < 20
        ; copy count(0@function,i16), r.0(0@register,i16)
        lea rax, [rsp+0]
        mov [rax], cx
        ; copy r(1@function,i16), r.1(1@register,i16)
        lea rax, [rsp+2]
        mov [rax], dx
@for_24:
        ; const r.0(0@register,i16), 20
        mov cx, 20
        ; copy r.1(1@register,i16), r(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setl cl
        ; branch r.0(0@register,bool), false, @for_24_break
        or cl, cl
        jz @for_24_break
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; 137:3 for c < 40
        ; copy c(2@function,i16), r.0(0@register,i16)
        lea rax, [rsp+4]
        mov [rax], cx
@for_25:
        ; const r.0(0@register,i16), 40
        mov cx, 40
        ; copy r.1(1@register,i16), c(2@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setl cl
        ; branch r.0(0@register,bool), false, @for_24_continue
        or cl, cl
        jz @for_24_continue
        ; call r.0(0@register,u8), getCell, [r(1@function,i16), c(2@function,i16)]
        lea rax, [rsp+2]
        mov ax, [rax]
        push rax
        lea rax, [rsp+12]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getCell
        add rsp, 24
        mov cl, al
        ; 139:4 if cell & 6 == 0
        ; const r.1(1@register,u8), 6
        mov dl, 6
        ; and r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        and cl, dl
        ; const r.1(1@register,u8), 0
        mov dl, 0
        ; equals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        sete cl
        ; branch r.0(0@register,bool), false, @for_25_continue
        or cl, cl
        jz @for_25_continue
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), count(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; copy count(0@function,i16), r.0(0@register,i16)
        lea rax, [rsp+0]
        mov [rax], cx
@for_25_continue:
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), c(2@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; copy c(2@function,i16), r.0(0@register,i16)
        lea rax, [rsp+4]
        mov [rax], cx
        jmp @for_25
@for_24_continue:
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), r(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; copy r(1@function,i16), r.0(0@register,i16)
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @for_24
@for_24_break:
        ; call r.0(0@register,u8), getDigitCount, [count(0@function,i16)]
        lea rax, [rsp+0]
        mov ax, [rax]
        push rax
          call @getDigitCount
        add rsp, 8
        mov cl, al
        ; const r.1(1@register,i16), 40
        mov dx, 40
        ; copy leftDigits(4@function,u8), r.0(0@register,u8)
        lea rax, [rsp+7]
        mov [rax], cl
        ; call r.0(0@register,u8), getDigitCount, [r.1(1@register,i16)]
        push rdx
          call @getDigitCount
        add rsp, 8
        mov cl, al
        ; const r.1(1@register,u8*), [string-1]
        lea rdx, [string_1]
        ; copy bombDigits(5@function,u8), r.0(0@register,u8)
        lea rax, [rsp+8]
        mov [rax], cl
        ; call _, printString [r.1(1@register,u8*)]
        push rdx
          call @printString
        add rsp, 8
        ; copy r.0(0@register,u8), bombDigits(5@function,u8)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r.1(1@register,u8), leftDigits(4@function,u8)
        lea rax, [rsp+7]
        mov dl, [rax]
        ; sub r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        sub cl, dl
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        movzx cx, cl
        ; call _, printSpaces [r.0(0@register,i16)]
        push rcx
          call @printSpaces
        add rsp, 8
        ; copy r.0(0@register,i16), count(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; cast r.1(1@register,i64), r.0(0@register,i16)
        movzx rdx, cx
        ; call _, printUint [r.1(1@register,i64)]
        push rdx
          call @printUint
        add rsp, 8
        ; 150:15 return count == 0
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; copy r.1(1@register,i16), count(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        sete cl
        ; ret r.0(0@register,bool)
        mov rax, rcx
        ; release space for local variables
        add rsp, 64
        ret

        ; i16 abs
        ;   rsp+24: arg a
        ;   rsp+0: var t.1
        ;   rsp+2: var t.2
        ;   rsp+4: var t.3
@abs:
        ; reserve space for local variables
        sub rsp, 16
        ; 154:2 if a < 0
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; copy r.1(1@register,i16), a(0@argument,i16)
        lea rax, [rsp+24]
        mov dx, [rax]
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setl cl
        ; branch r.0(0@register,bool), false, @if_27_end
        or cl, cl
        jz @if_27_end
        ; 155:10 return -a
        ; copy r.0(0@register,i16), a(0@argument,i16)
        lea rax, [rsp+24]
        mov cx, [rax]
        ; neg r.0(0@register,i16), r.0(0@register,i16)
        neg rcx
        ; ret r.0(0@register,i16)
        mov rax, rcx
        jmp @abs_ret
@if_27_end:
        ; 157:9 return a
        ; copy r.0(0@register,i16), a(0@argument,i16)
        lea rax, [rsp+24]
        mov cx, [rax]
        ; ret r.0(0@register,i16)
        mov rax, rcx
@abs_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void clearField
        ;   rsp+0: var r
        ;   rsp+2: var c
        ;   rsp+4: var t.2
        ;   rsp+6: var t.3
        ;   rsp+8: var t.4
        ;   rsp+10: var t.5
        ;   rsp+12: var t.6
        ;   rsp+14: var t.7
        ;   rsp+16: var t.8
@clearField:
        ; reserve space for local variables
        sub rsp, 32
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; 161:2 for r < 20
        ; copy r(0@function,i16), r.0(0@register,i16)
        lea rax, [rsp+0]
        mov [rax], cx
@for_28:
        ; const r.0(0@register,i16), 20
        mov cx, 20
        ; copy r.1(1@register,i16), r(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setl cl
        ; branch r.0(0@register,bool), false, @clearField_ret
        or cl, cl
        jz @clearField_ret
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; 162:3 for c < 40
        ; copy c(1@function,i16), r.0(0@register,i16)
        lea rax, [rsp+2]
        mov [rax], cx
@for_29:
        ; const r.0(0@register,i16), 40
        mov cx, 40
        ; copy r.1(1@register,i16), c(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setl cl
        ; branch r.0(0@register,bool), false, @for_28_continue
        or cl, cl
        jz @for_28_continue
        ; const r.0(0@register,u8), 0
        mov cl, 0
        ; call _, setCell [r(0@function,i16), c(1@function,i16), r.0(0@register,u8)]
        lea rax, [rsp+0]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        push rcx
          call @setCell
        add rsp, 24
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), c(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; copy c(1@function,i16), r.0(0@register,i16)
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @for_29
@for_28_continue:
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), r(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; copy r(0@function,i16), r.0(0@register,i16)
        lea rax, [rsp+0]
        mov [rax], cx
        jmp @for_28
@clearField_ret:
        ; release space for local variables
        add rsp, 32
        ret

        ; void initField
        ;   rsp+88: arg curr_r
        ;   rsp+80: arg curr_c
        ;   rsp+0: var bombs
        ;   rsp+2: var row
        ;   rsp+4: var column
        ;   rsp+6: var t.5
        ;   rsp+8: var t.6
        ;   rsp+12: var t.7
        ;   rsp+16: var t.8
        ;   rsp+20: var t.9
        ;   rsp+24: var t.10
        ;   rsp+28: var t.11
        ;   rsp+32: var t.12
        ;   rsp+36: var t.13
        ;   rsp+38: var t.14
        ;   rsp+40: var t.15
        ;   rsp+42: var t.16
        ;   rsp+44: var t.17
        ;   rsp+46: var t.18
        ;   rsp+48: var t.19
        ;   rsp+50: var t.20
        ;   rsp+52: var t.21
@initField:
        ; reserve space for local variables
        sub rsp, 64
        ; const r.0(0@register,i16), 40
        mov cx, 40
        ; 169:2 for bombs > 0
        ; copy bombs(2@function,i16), r.0(0@register,i16)
        lea rax, [rsp+0]
        mov [rax], cx
@for_30:
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; copy r.1(1@register,i16), bombs(2@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; gt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setg cl
        ; branch r.0(0@register,bool), false, @initField_ret
        or cl, cl
        jz @initField_ret
        ; call r.0(0@register,i32), random, []
        sub rsp, 8
          call @random
        add rsp, 8
        mov ecx, eax
        ; const r.1(1@register,i32), 20
        mov edx, 20
        ; mod r.0(0@register,i32), r.0(0@register,i32), r.1(1@register,i32)
        push rdx
        movsxd rax, ecx
        movsxd rbx, edx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; cast r.0(0@register,i16), r.0(0@register,i32)
        ; copy row(3@function,i16), r.0(0@register,i16)
        lea rax, [rsp+2]
        mov [rax], cx
        ; call r.0(0@register,i32), random, []
        sub rsp, 8
          call @random
        add rsp, 8
        mov ecx, eax
        ; const r.1(1@register,i32), 40
        mov edx, 40
        ; mod r.0(0@register,i32), r.0(0@register,i32), r.1(1@register,i32)
        push rdx
        movsxd rax, ecx
        movsxd rbx, edx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; cast r.0(0@register,i16), r.0(0@register,i32)
        ; 172:3 if abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=172:11], right=ExprVarAccess[varName=curr_r, index=0, scope=argument, type=i16, varIsArray=false, location=172:20], location=172:18]]) > 1 || abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=173:11], right=ExprVarAccess[varName=curr_c, index=1, scope=argument, type=i16, varIsArray=false, location=173:20], location=173:18]]) > 1
        ; 173:4 logic or
        ; copy r.1(1@register,i16), row(3@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; copy r.2(2@register,i16), curr_r(0@argument,i16)
        lea rax, [rsp+88]
        mov r9w, [rax]
        ; sub r.3(3@register,i16), r.1(1@register,i16), r.2(2@register,i16)
        mov r10w, dx
        sub r10w, r9w
        ; copy column(4@function,i16), r.0(0@register,i16)
        lea rax, [rsp+4]
        mov [rax], cx
        ; call r.0(0@register,i16), abs, [r.3(3@register,i16)]
        push r10
          call @abs
        add rsp, 8
        mov cx, ax
        ; const r.1(1@register,i16), 1
        mov dx, 1
        ; gt r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setg cl
        ; copy t.13(13@function,bool), r.0(0@register,bool)
        lea rax, [rsp+36]
        mov [rax], cl
        ; branch r.0(0@register,bool), true, @or_next_32
        or cl, cl
        jnz @or_next_32
        ; copy r.0(0@register,i16), column(4@function,i16)
        lea rax, [rsp+4]
        mov cx, [rax]
        ; copy r.1(1@register,i16), curr_c(1@argument,i16)
        lea rax, [rsp+80]
        mov dx, [rax]
        ; sub r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        mov r9w, cx
        sub r9w, dx
        ; call r.0(0@register,i16), abs, [r.2(2@register,i16)]
        push r9
          call @abs
        add rsp, 8
        mov cx, ax
        ; const r.1(1@register,i16), 1
        mov dx, 1
        ; gt r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setg cl
        ; copy t.13(13@function,bool), r.0(0@register,bool)
        lea rax, [rsp+36]
        mov [rax], cl
@or_next_32:
        ; copy r.0(0@register,bool), t.13(13@function,bool)
        lea rax, [rsp+36]
        mov cl, [rax]
        ; branch r.0(0@register,bool), false, @for_30_continue
        or cl, cl
        jz @for_30_continue
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; call _, setCell [row(3@function,i16), column(4@function,i16), r.0(0@register,u8)]
        lea rax, [rsp+2]
        mov ax, [rax]
        push rax
        lea rax, [rsp+12]
        mov ax, [rax]
        push rax
        push rcx
          call @setCell
        add rsp, 24
@for_30_continue:
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), bombs(2@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; sub r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        sub ax, cx
        mov cx, ax
        ; copy bombs(2@function,i16), r.0(0@register,i16)
        lea rax, [rsp+0]
        mov [rax], cx
        jmp @for_30
@initField_ret:
        ; release space for local variables
        add rsp, 64
        ret

        ; void maybeRevealAround
        ;   rsp+72: arg row
        ;   rsp+64: arg column
        ;   rsp+0: var dr
        ;   rsp+2: var r
        ;   rsp+4: var dc
        ;   rsp+6: var c
        ;   rsp+8: var cell
        ;   rsp+9: var t.7
        ;   rsp+10: var t.8
        ;   rsp+11: var t.9
        ;   rsp+12: var t.10
        ;   rsp+14: var t.11
        ;   rsp+16: var t.12
        ;   rsp+18: var t.13
        ;   rsp+20: var t.14
        ;   rsp+22: var t.15
        ;   rsp+24: var t.16
        ;   rsp+26: var t.17
        ;   rsp+27: var t.18
        ;   rsp+28: var t.19
        ;   rsp+29: var t.20
        ;   rsp+30: var t.21
        ;   rsp+32: var t.22
        ;   rsp+34: var t.23
@maybeRevealAround:
        ; reserve space for local variables
        sub rsp, 48
        ; 180:2 if getBombCountAround([ExprVarAccess[varName=row, index=0, scope=argument, type=i16, varIsArray=false, location=180:25], ExprVarAccess[varName=column, index=1, scope=argument, type=i16, varIsArray=false, location=180:30]]) != 0
        ; call r.0(0@register,u8), getBombCountAround, [row(0@argument,i16), column(1@argument,i16)]
        lea rax, [rsp+72]
        mov ax, [rax]
        push rax
        lea rax, [rsp+72]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getBombCountAround
        add rsp, 24
        mov cl, al
        ; const r.1(1@register,u8), 0
        mov dl, 0
        ; notequals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        setne cl
        ; branch r.0(0@register,bool), false, @if_33_end
        or cl, cl
        jz @if_33_end
        jmp @maybeRevealAround_ret
@if_33_end:
        ; const r.0(0@register,i16), -1
        mov cx, -1
        ; 184:2 for dr <= 1
        ; copy dr(2@function,i16), r.0(0@register,i16)
        lea rax, [rsp+0]
        mov [rax], cx
@for_34:
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), dr(2@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; lteq r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setle cl
        ; branch r.0(0@register,bool), false, @maybeRevealAround_ret
        or cl, cl
        jz @maybeRevealAround_ret
        ; copy r.0(0@register,i16), row(0@argument,i16)
        lea rax, [rsp+72]
        mov cx, [rax]
        ; copy r.1(1@register,i16), dr(2@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; add r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        mov r9w, cx
        add r9w, dx
        ; const r.3(3@register,i16), -1
        mov r10w, -1
        ; 186:3 for dc <= 1
        ; copy r(3@function,i16), r.2(2@register,i16)
        lea rax, [rsp+2]
        mov [rax], r9w
        ; copy dc(4@function,i16), r.3(3@register,i16)
        lea rax, [rsp+4]
        mov [rax], r10w
@for_35:
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), dc(4@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; lteq r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        setle cl
        ; branch r.0(0@register,bool), false, @for_34_continue
        or cl, cl
        jz @for_34_continue
        ; 187:4 if dr == 0 && dc == 0
        ; 187:16 logic and
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; copy r.1(1@register,i16), dr(2@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        sete cl
        ; copy t.14(14@function,bool), r.0(0@register,bool)
        lea rax, [rsp+20]
        mov [rax], cl
        ; branch r.0(0@register,bool), false, @and_next_37
        or cl, cl
        jz @and_next_37
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; copy r.1(1@register,i16), dc(4@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        sete cl
        ; copy t.14(14@function,bool), r.0(0@register,bool)
        lea rax, [rsp+20]
        mov [rax], cl
@and_next_37:
        ; copy r.0(0@register,bool), t.14(14@function,bool)
        lea rax, [rsp+20]
        mov cl, [rax]
        ; branch r.0(0@register,bool), false, @if_36_end
        or cl, cl
        jz @if_36_end
        jmp @for_35_continue
@if_36_end:
        ; copy r.0(0@register,i16), column(1@argument,i16)
        lea rax, [rsp+64]
        mov cx, [rax]
        ; copy r.1(1@register,i16), dc(4@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; add r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        mov r9w, cx
        add r9w, dx
        ; 192:4 if !checkCellBounds([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=192:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=192:28]])
        ; copy c(5@function,i16), r.2(2@register,i16)
        lea rax, [rsp+6]
        mov [rax], r9w
        ; call r.0(0@register,bool), checkCellBounds, [r(3@function,i16), r.2(2@register,i16)]
        lea rax, [rsp+2]
        mov ax, [rax]
        push rax
        push r9
        sub rsp, 8
          call @checkCellBounds
        add rsp, 24
        mov cl, al
        ; notlog r.0(0@register,bool), r.0(0@register,bool)
        or cl, cl
        sete cl
        ; branch r.0(0@register,bool), false, @if_38_end
        or cl, cl
        jz @if_38_end
        jmp @for_35_continue
@if_38_end:
        ; call r.0(0@register,u8), getCell, [r(3@function,i16), c(5@function,i16)]
        lea rax, [rsp+2]
        mov ax, [rax]
        push rax
        lea rax, [rsp+14]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getCell
        add rsp, 24
        mov cl, al
        ; 197:4 if isOpen([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=197:15]])
        ; copy cell(6@function,u8), r.0(0@register,u8)
        lea rax, [rsp+8]
        mov [rax], cl
        ; call r.0(0@register,bool), isOpen, [r.0(0@register,u8)]
        push rcx
          call @isOpen
        add rsp, 8
        mov cl, al
        ; branch r.0(0@register,bool), false, @if_39_end
        or cl, cl
        jz @if_39_end
        jmp @for_35_continue
@if_39_end:
        ; const r.0(0@register,u8), 2
        mov cl, 2
        ; copy r.1(1@register,u8), cell(6@function,u8)
        lea rax, [rsp+8]
        mov dl, [rax]
        ; or r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        or al, cl
        mov cl, al
        ; call _, setCell [r(3@function,i16), c(5@function,i16), r.0(0@register,u8)]
        lea rax, [rsp+2]
        mov ax, [rax]
        push rax
        lea rax, [rsp+14]
        mov ax, [rax]
        push rax
        push rcx
          call @setCell
        add rsp, 24
        ; call _, maybeRevealAround [r(3@function,i16), c(5@function,i16)]
        lea rax, [rsp+2]
        mov ax, [rax]
        push rax
        lea rax, [rsp+14]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @maybeRevealAround
        add rsp, 24
@for_35_continue:
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), dc(4@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; copy dc(4@function,i16), r.0(0@register,i16)
        lea rax, [rsp+4]
        mov [rax], cx
        jmp @for_35
@for_34_continue:
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), dr(2@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; copy dr(2@function,i16), r.0(0@register,i16)
        lea rax, [rsp+0]
        mov [rax], cx
        jmp @for_34
@maybeRevealAround_ret:
        ; release space for local variables
        add rsp, 48
        ret

        ; void main
        ;   rsp+0: var needsInitialize
        ;   rsp+2: var curr_c
        ;   rsp+4: var curr_r
        ;   rsp+6: var chr
        ;   rsp+8: var cell
        ;   rsp+9: var cell
        ;   rsp+12: var t.6
        ;   rsp+16: var t.7
        ;   rsp+17: var t.8
        ;   rsp+18: var t.9
        ;   rsp+19: var t.10
        ;   rsp+24: var t.11
        ;   rsp+32: var t.12
        ;   rsp+34: var t.13
        ;   rsp+36: var t.14
        ;   rsp+38: var t.15
        ;   rsp+40: var t.16
        ;   rsp+42: var t.17
        ;   rsp+44: var t.18
        ;   rsp+46: var t.19
        ;   rsp+48: var t.20
        ;   rsp+50: var t.21
        ;   rsp+52: var t.22
        ;   rsp+54: var t.23
        ;   rsp+56: var t.24
        ;   rsp+58: var t.25
        ;   rsp+60: var t.26
        ;   rsp+62: var t.27
        ;   rsp+64: var t.28
        ;   rsp+66: var t.29
        ;   rsp+68: var t.30
        ;   rsp+70: var t.31
        ;   rsp+72: var t.32
        ;   rsp+74: var t.33
        ;   rsp+76: var t.34
        ;   rsp+78: var t.35
        ;   rsp+80: var t.36
        ;   rsp+82: var t.37
        ;   rsp+84: var t.38
        ;   rsp+86: var t.39
        ;   rsp+88: var t.40
        ;   rsp+90: var t.41
        ;   rsp+92: var t.42
        ;   rsp+94: var t.43
        ;   rsp+96: var t.44
        ;   rsp+98: var t.45
        ;   rsp+100: var t.46
        ;   rsp+102: var t.47
        ;   rsp+103: var t.48
        ;   rsp+104: var t.49
        ;   rsp+105: var t.50
        ;   rsp+106: var t.51
        ;   rsp+108: var t.52
        ;   rsp+110: var t.53
        ;   rsp+111: var t.54
        ;   rsp+112: var t.55
        ;   rsp+113: var t.56
        ;   rsp+114: var t.57
        ;   rsp+120: var t.58
@main:
        ; reserve space for local variables
        sub rsp, 128
        ; begin initialize global variables
        ; const r.0(0@register,i32), 0
        mov ecx, 0
        ; end initialize global variables
        ; const r.1(1@register,i32), 7439742
        mov edx, 7439742
        ; copy __random__(0@global,i32), r.0(0@register,i32)
        lea rax, [var_0]
        mov [rax], ecx
        ; call _, initRandom [r.1(1@register,i32)]
        push rdx
          call @initRandom
        add rsp, 8
        ; const r.0(0@register,bool), 1
        mov cl, 1
        ; copy needsInitialize(0@function,bool), r.0(0@register,bool)
        lea rax, [rsp+0]
        mov [rax], cl
        ; call _, clearField []
        sub rsp, 8
          call @clearField
        add rsp, 8
        ; const r.0(0@register,u8), 20
        mov cl, 20
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        movzx cx, cl
        ; const r.1(1@register,u8), 10
        mov dl, 10
        ; cast r.1(1@register,i16), r.1(1@register,u8)
        movzx dx, dl
        ; 213:2 while true
        ; copy curr_c(1@function,i16), r.0(0@register,i16)
        lea rax, [rsp+2]
        mov [rax], cx
        ; copy curr_r(2@function,i16), r.1(1@register,i16)
        lea rax, [rsp+4]
        mov [rax], dx
@while_40:
        ; call _, printField [curr_r(2@function,i16), curr_c(1@function,i16)]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @printField
        add rsp, 24
        ; 215:3 if !needsInitialize
        ; copy r.0(0@register,bool), needsInitialize(0@function,bool)
        lea rax, [rsp+0]
        mov cl, [rax]
        ; notlog r.1(1@register,bool), r.0(0@register,bool)
        or cl, cl
        sete dl
        ; branch r.1(1@register,bool), false, @if_41_end
        or dl, dl
        jz @if_41_end
        ; 216:4 if printLeft([])
        ; call r.0(0@register,bool), printLeft, []
        sub rsp, 8
          call @printLeft
        add rsp, 8
        mov cl, al
        ; branch r.0(0@register,bool), false, @if_41_end
        or cl, cl
        jz @if_41_end
        ; const r.0(0@register,u8*), [string-2]
        lea rcx, [string_2]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        jmp @main_ret
@if_41_end:
        ; call r.0(0@register,i16), getChar, []
        sub rsp, 8
          call @getChar
        add rsp, 8
        mov cx, ax
        ; 223:3 if chr == 27
        ; const r.1(1@register,i16), 27
        mov dx, 27
        ; equals r.1(1@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        sete dl
        ; copy chr(3@function,i16), r.0(0@register,i16)
        lea rax, [rsp+6]
        mov [rax], cx
        ; branch r.1(1@register,bool), false, @if_43_end
        or dl, dl
        jz @if_43_end
        jmp @main_ret
@if_43_end:
        ; 228:3 if chr == 57416
        ; const r.0(0@register,i16), 57416
        mov cx, 57416
        ; copy r.1(1@register,i16), chr(3@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        sete cl
        ; branch r.0(0@register,bool), false, @if_44_else
        or cl, cl
        jz @if_44_else
        ; const r.0(0@register,i16), 20
        mov cx, 20
        ; copy r.1(1@register,i16), curr_r(2@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; const r.1(1@register,i16), 1
        mov dx, 1
        ; sub r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        sub cx, dx
        ; const r.1(1@register,i16), 20
        mov dx, 20
        ; mod r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        push rdx
        movsx rax, cx
        movsx rbx, dx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; copy curr_r(2@function,i16), r.0(0@register,i16)
        lea rax, [rsp+4]
        mov [rax], cx
        jmp @while_40
@if_44_else:
        ; 232:8 if chr == 57424
        ; const r.0(0@register,i16), 57424
        mov cx, 57424
        ; copy r.1(1@register,i16), chr(3@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        sete cl
        ; branch r.0(0@register,bool), false, @if_45_else
        or cl, cl
        jz @if_45_else
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), curr_r(2@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; const r.1(1@register,i16), 20
        mov dx, 20
        ; mod r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        push rdx
        movsx rax, cx
        movsx rbx, dx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; copy curr_r(2@function,i16), r.0(0@register,i16)
        lea rax, [rsp+4]
        mov [rax], cx
        jmp @while_40
@if_45_else:
        ; 236:8 if chr == 57419
        ; const r.0(0@register,i16), 57419
        mov cx, 57419
        ; copy r.1(1@register,i16), chr(3@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        sete cl
        ; branch r.0(0@register,bool), false, @if_46_else
        or cl, cl
        jz @if_46_else
        ; const r.0(0@register,i16), 40
        mov cx, 40
        ; copy r.1(1@register,i16), curr_c(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; const r.1(1@register,i16), 1
        mov dx, 1
        ; sub r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        sub cx, dx
        ; const r.1(1@register,i16), 40
        mov dx, 40
        ; mod r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        push rdx
        movsx rax, cx
        movsx rbx, dx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; copy curr_c(1@function,i16), r.0(0@register,i16)
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @while_40
@if_46_else:
        ; 240:8 if chr == 57419
        ; const r.0(0@register,i16), 57419
        mov cx, 57419
        ; copy r.1(1@register,i16), chr(3@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        sete cl
        ; branch r.0(0@register,bool), false, @if_47_else
        or cl, cl
        jz @if_47_else
        ; const r.0(0@register,i16), 40
        mov cx, 40
        ; copy r.1(1@register,i16), curr_c(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; const r.1(1@register,i16), 1
        mov dx, 1
        ; sub r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        sub cx, dx
        ; const r.1(1@register,i16), 40
        mov dx, 40
        ; mod r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        push rdx
        movsx rax, cx
        movsx rbx, dx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; copy curr_c(1@function,i16), r.0(0@register,i16)
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @while_40
@if_47_else:
        ; 244:8 if chr == 57421
        ; const r.0(0@register,i16), 57421
        mov cx, 57421
        ; copy r.1(1@register,i16), chr(3@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        sete cl
        ; branch r.0(0@register,bool), false, @if_48_else
        or cl, cl
        jz @if_48_else
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; copy r.1(1@register,i16), curr_c(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; const r.1(1@register,i16), 40
        mov dx, 40
        ; mod r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        push rdx
        movsx rax, cx
        movsx rbx, dx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; copy curr_c(1@function,i16), r.0(0@register,i16)
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @while_40
@if_48_else:
        ; 248:8 if chr == 32
        ; const r.0(0@register,i16), 32
        mov cx, 32
        ; copy r.1(1@register,i16), chr(3@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        sete cl
        ; branch r.0(0@register,bool), false, @if_49_else
        or cl, cl
        jz @if_49_else
        ; 249:4 if !needsInitialize
        ; copy r.0(0@register,bool), needsInitialize(0@function,bool)
        lea rax, [rsp+0]
        mov cl, [rax]
        ; notlog r.1(1@register,bool), r.0(0@register,bool)
        or cl, cl
        sete dl
        ; branch r.1(1@register,bool), false, @while_40
        or dl, dl
        jz @while_40
        ; call r.0(0@register,u8), getCell, [curr_r(2@function,i16), curr_c(1@function,i16)]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getCell
        add rsp, 24
        mov cl, al
        ; 251:5 if !isOpen([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=251:17]])
        ; copy cell(4@function,u8), r.0(0@register,u8)
        lea rax, [rsp+8]
        mov [rax], cl
        ; call r.0(0@register,bool), isOpen, [r.0(0@register,u8)]
        push rcx
          call @isOpen
        add rsp, 8
        mov cl, al
        ; notlog r.0(0@register,bool), r.0(0@register,bool)
        or cl, cl
        sete cl
        ; branch r.0(0@register,bool), false, @while_40
        or cl, cl
        jz @while_40
        ; const r.0(0@register,u8), 4
        mov cl, 4
        ; copy r.1(1@register,u8), cell(4@function,u8)
        lea rax, [rsp+8]
        mov dl, [rax]
        ; xor r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        xor al, cl
        mov cl, al
        ; call _, setCell [curr_r(2@function,i16), curr_c(1@function,i16), r.0(0@register,u8)]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        push rcx
          call @setCell
        add rsp, 24
        jmp @while_40
@if_49_else:
        ; 257:8 if chr == 13
        ; const r.0(0@register,i16), 13
        mov cx, 13
        ; copy r.1(1@register,i16), chr(3@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        cmp dx, cx
        sete cl
        ; branch r.0(0@register,bool), false, @while_40
        or cl, cl
        jz @while_40
        ; copy r.0(0@register,bool), needsInitialize(0@function,bool)
        lea rax, [rsp+0]
        mov cl, [rax]
        ; branch r.0(0@register,bool), false, @if_53_end
        or cl, cl
        jz @if_53_end
        ; const r.0(0@register,bool), 0
        mov cl, 0
        ; copy needsInitialize(0@function,bool), r.0(0@register,bool)
        lea rax, [rsp+0]
        mov [rax], cl
        ; call _, initField [curr_r(2@function,i16), curr_c(1@function,i16)]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @initField
        add rsp, 24
@if_53_end:
        ; call r.0(0@register,u8), getCell, [curr_r(2@function,i16), curr_c(1@function,i16)]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getCell
        add rsp, 24
        mov cl, al
        ; 263:4 if !isOpen([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=263:16]])
        ; copy cell(5@function,u8), r.0(0@register,u8)
        lea rax, [rsp+9]
        mov [rax], cl
        ; call r.0(0@register,bool), isOpen, [r.0(0@register,u8)]
        push rcx
          call @isOpen
        add rsp, 8
        mov cl, al
        ; notlog r.0(0@register,bool), r.0(0@register,bool)
        or cl, cl
        sete cl
        ; branch r.0(0@register,bool), false, @if_54_end
        or cl, cl
        jz @if_54_end
        ; const r.0(0@register,u8), 2
        mov cl, 2
        ; copy r.1(1@register,u8), cell(5@function,u8)
        lea rax, [rsp+9]
        mov dl, [rax]
        ; or r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        or al, cl
        mov cl, al
        ; call _, setCell [curr_r(2@function,i16), curr_c(1@function,i16), r.0(0@register,u8)]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        push rcx
          call @setCell
        add rsp, 24
@if_54_end:
        ; 266:4 if isBomb([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=266:15]])
        ; call r.0(0@register,bool), isBomb, [cell(5@function,u8)]
        lea rax, [rsp+9]
        mov al, [rax]
        push rax
          call @isBomb
        add rsp, 8
        mov cl, al
        ; branch r.0(0@register,bool), false, @if_55_end
        or cl, cl
        jz @if_55_end
        ; call _, printField [curr_r(2@function,i16), curr_c(1@function,i16)]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @printField
        add rsp, 24
        ; const r.0(0@register,u8*), [string-3]
        lea rcx, [string_3]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        jmp @main_ret
@if_55_end:
        ; call _, maybeRevealAround [curr_r(2@function,i16), curr_c(1@function,i16)]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @maybeRevealAround
        add rsp, 24
        jmp @while_40
@main_ret:
        ; release space for local variables
        add rsp, 128
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
        ; variable 0: __random__ (4)
        var_0 rb 4
        ; variable 1: field (6400)
        var_1 rb 6400

section '.data' data readable
        string_0 db '|', 0x0a, 0x00
        string_1 db 'Left: ', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

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
