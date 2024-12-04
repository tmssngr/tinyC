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
        ;   rsp+8: arg str
@printString:
        ; call r0, strlen, [str]
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str, r0]
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ret

        ; void printChar
        ;   rsp+8: arg chr
@printChar:
        ; addrof r0, chr
        lea rcx, [rsp+8]
        ; const r1, 1
        mov rdx, 1
        ; call _, printStringLength [r0, r1]
        push rcx
        push rdx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ret

        ; void printUint
        ;   rsp+40: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
@printUint:
        ; reserve space for local variables
        sub rsp, 32
        ; const r0, 20
        mov cl, 20
        ; 13:2 while true
        ; move pos, r0
        lea rax, [rsp+20]
        mov [rax], cl
@while_1:
        ; const r0, 1
        mov cl, 1
        ; move r1, pos
        lea rax, [rsp+20]
        mov dl, [rax]
        ; sub r0, r1, r0
        mov al, dl
        sub al, cl
        mov cl, al
        ; const r1, 10
        mov rdx, 10
        ; move r2, number
        lea rax, [rsp+40]
        mov r9, [rax]
        ; move r3, r2
        mov r10, r9
        ; mod r1, r3, r1
        mov rax, r10
        mov rbx, rdx
        cqo
        idiv rbx
        ; const r3, 10
        mov r10, 10
        ; div r2, r2, r3
        push rdx
        mov rax, r9
        mov rbx, r10
        cqo
        idiv rbx
        mov r9, rax
        pop rdx
        ; cast r1(u8), r1(i64)
        ; const r3, 48
        mov r10b, 48
        ; add r1, r1, r3
        add dl, r10b
        ; cast r3(i64), r0(u8)
        movzx r10, cl
        ; cast r3(u8*), r3(i64)
        ; Spill pos
        ; move pos, r0
        lea rax, [rsp+20]
        mov [rax], cl
        ; addrof r0, [buffer]
        lea rcx, [rsp+0]
        ; add r0, r0, r3
        add rcx, r10
        ; store [r0], r1
        mov [rcx], dl
        ; 19:3 if number == 0
        ; const r0, 0
        mov rcx, 0
        ; equals r0, r2, r0
        cmp r9, rcx
        sete cl
        ; move number, r2
        lea rax, [rsp+40]
        mov [rax], r9
        ; branch r0, false, @while_1
        or cl, cl
        jz @while_1
        ; move r0, pos
        lea rax, [rsp+20]
        mov cl, [rax]
        ; cast r1(i64), r0(u8)
        movzx rdx, cl
        ; cast r1(u8*), r1(i64)
        ; addrof r2, [buffer]
        lea r9, [rsp+0]
        ; add r1, r2, r1
        mov rax, r9
        add rax, rdx
        mov rdx, rax
        ; const r2, 20
        mov r9b, 20
        ; sub r0, r2, r0
        mov al, r9b
        sub al, cl
        mov cl, al
        ; cast r0(i64), r0(u8)
        movzx rcx, cl
        ; call _, printStringLength [r1, r0]
        push rdx
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 32
        ret

        ; void printIntLf
        ;   rsp+8: arg number
@printIntLf:
        ; 27:2 if number < 0
        ; const r0, 0
        mov rcx, 0
        ; move r1, number
        lea rax, [rsp+8]
        mov rdx, [rax]
        ; lt r0, r1, r0
        cmp rdx, rcx
        setl cl
        ; branch r0, false, @if_3_end
        or cl, cl
        jz @if_3_end
        ; const r0, 45
        mov cl, 45
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        ; move r0, number
        lea rax, [rsp+8]
        mov rcx, [rax]
        ; neg r0, r0
        neg rcx
        ; move number, r0
        lea rax, [rsp+8]
        mov [rax], rcx
@if_3_end:
        ; call _, printUint [number]
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @printUint
        add rsp, 8
        ; const r0, 10
        mov cl, 10
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        ret

        ; i64 strlen
        ;   rsp+24: arg str
        ;   rsp+0: var length
@strlen:
        ; reserve space for local variables
        sub rsp, 16
        ; const r0, 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; move length, r0
        lea rax, [rsp+0]
        mov [rax], rcx
@for_4:
        ; move r0, str
        lea rax, [rsp+24]
        mov rcx, [rax]
        ; load r1, [r0]
        mov dl, [rcx]
        ; const r2, 0
        mov r9b, 0
        ; notequals r1, r1, r2
        cmp dl, r9b
        setne dl
        ; branch r1, false, @for_4_break
        or dl, dl
        jz @for_4_break
        ; const r0, 1
        mov rcx, 1
        ; move r1, length
        lea rax, [rsp+0]
        mov rdx, [rax]
        ; add r0, r1, r0
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; move r1, str
        lea rax, [rsp+24]
        mov rdx, [rax]
        ; cast r1(i64), r1(u8*)
        ; const r2, 1
        mov r9, 1
        ; add r1, r1, r2
        add rdx, r9
        ; cast r1(u8*), r1(i64)
        ; move length, r0
        lea rax, [rsp+0]
        mov [rax], rcx
        ; move str, r1
        lea rax, [rsp+24]
        mov [rax], rdx
        jmp @for_4
@for_4_break:
        ; 40:9 return length
        ; move r0, length
        lea rax, [rsp+0]
        mov rcx, [rax]
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
        ;   rsp+0: var a
        ;   rsp+2: var b
        ;   rsp+4: var c
        ;   rsp+6: var d
        ;   rsp+8: var t
        ;   rsp+9: var f
        ;   rsp+10: var b1
        ;   rsp+11: var t.38
        ;   rsp+12: var t.40
        ;   rsp+13: var t.42
        ;   rsp+14: var t.44
        ;   rsp+15: var t.47
        ;   rsp+16: var t.49
        ;   rsp+17: var t.51
        ;   rsp+18: var t.53
        ;   rsp+19: var t.64
        ;   rsp+20: var t.66
@main:
        ; reserve space for local variables
        sub rsp, 32
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0, [string-0]
        lea rcx, [string_0]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; const r0, 0
        mov cx, 0
        ; const r1, 1
        mov dx, 1
        ; const r2, 2
        mov r9w, 2
        ; const r3, 3
        mov r10w, 3
        ; Spill a
        ; move a, r0
        lea rax, [rsp+0]
        mov [rax], cx
        ; const r0, 1
        mov cl, 1
        ; Spill t
        ; move t, r0
        lea rax, [rsp+8]
        mov [rax], cl
        ; const r0, 0
        mov cl, 0
        ; Spill f
        ; move f, r0
        lea rax, [rsp+9]
        mov [rax], cl
        ; Spill b
        ; move b, r1
        lea rax, [rsp+2]
        mov [rax], dx
        ; move r0, a
        lea rax, [rsp+0]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; and r1, r1, r0
        and dx, cx
        ; cast r1(i64), r1(i16)
        movzx rdx, dx
        ; move c, r2
        lea rax, [rsp+4]
        mov [rax], r9w
        ; move d, r3
        lea rax, [rsp+6]
        mov [rax], r10w
        ; call _, printIntLf [r1]
        push rdx
          call @printIntLf
        add rsp, 8
        ; move r0, a
        lea rax, [rsp+0]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; move r2, b
        lea rax, [rsp+2]
        mov r9w, [rax]
        ; and r1, r1, r2
        and dx, r9w
        ; cast r1(i64), r1(i16)
        movzx rdx, dx
        ; call _, printIntLf [r1]
        push rdx
          call @printIntLf
        add rsp, 8
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; move r2, a
        lea rax, [rsp+0]
        mov r9w, [rax]
        ; and r1, r1, r2
        and dx, r9w
        ; cast r1(i64), r1(i16)
        movzx rdx, dx
        ; call _, printIntLf [r1]
        push rdx
          call @printIntLf
        add rsp, 8
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; and r1, r1, r0
        and dx, cx
        ; cast r1(i64), r1(i16)
        movzx rdx, dx
        ; call _, printIntLf [r1]
        push rdx
          call @printIntLf
        add rsp, 8
        ; const r0, [string-1]
        lea rcx, [string_1]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; move r0, a
        lea rax, [rsp+0]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; or r1, r1, r0
        or dx, cx
        ; cast r1(i64), r1(i16)
        movzx rdx, dx
        ; call _, printIntLf [r1]
        push rdx
          call @printIntLf
        add rsp, 8
        ; move r0, a
        lea rax, [rsp+0]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; move r2, b
        lea rax, [rsp+2]
        mov r9w, [rax]
        ; or r1, r1, r2
        or dx, r9w
        ; cast r1(i64), r1(i16)
        movzx rdx, dx
        ; call _, printIntLf [r1]
        push rdx
          call @printIntLf
        add rsp, 8
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; move r2, a
        lea rax, [rsp+0]
        mov r9w, [rax]
        ; or r1, r1, r2
        or dx, r9w
        ; cast r1(i64), r1(i16)
        movzx rdx, dx
        ; call _, printIntLf [r1]
        push rdx
          call @printIntLf
        add rsp, 8
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; or r1, r1, r0
        or dx, cx
        ; cast r1(i64), r1(i16)
        movzx rdx, dx
        ; call _, printIntLf [r1]
        push rdx
          call @printIntLf
        add rsp, 8
        ; const r0, [string-2]
        lea rcx, [string_2]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; move r0, a
        lea rax, [rsp+0]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; xor r1, r1, r0
        xor dx, cx
        ; cast r1(i64), r1(i16)
        movzx rdx, dx
        ; call _, printIntLf [r1]
        push rdx
          call @printIntLf
        add rsp, 8
        ; move r0, a
        lea rax, [rsp+0]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; move r2, c
        lea rax, [rsp+4]
        mov r9w, [rax]
        ; xor r1, r1, r2
        xor dx, r9w
        ; cast r1(i64), r1(i16)
        movzx rdx, dx
        ; call _, printIntLf [r1]
        push rdx
          call @printIntLf
        add rsp, 8
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; move r2, a
        lea rax, [rsp+0]
        mov r9w, [rax]
        ; xor r1, r1, r2
        xor dx, r9w
        ; cast r1(i64), r1(i16)
        movzx rdx, dx
        ; call _, printIntLf [r1]
        push rdx
          call @printIntLf
        add rsp, 8
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; move r2, c
        lea rax, [rsp+4]
        mov r9w, [rax]
        ; xor r1, r1, r2
        xor dx, r9w
        ; cast r1(i64), r1(i16)
        movzx rdx, dx
        ; call _, printIntLf [r1]
        push rdx
          call @printIntLf
        add rsp, 8
        ; const r0, [string-3]
        lea rcx, [string_3]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; 26:15 logic and
        ; move r0, f
        lea rax, [rsp+9]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.38, r1
        lea rax, [rsp+11]
        mov [rax], dl
        ; branch r1, false, @and_next_5
        or dl, dl
        jz @and_next_5
        ; move r0, f
        lea rax, [rsp+9]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.38, r1
        lea rax, [rsp+11]
        mov [rax], dl
@and_next_5:
        ; move r0, t.38
        lea rax, [rsp+11]
        mov cl, [rax]
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 27:15 logic and
        ; move r0, f
        lea rax, [rsp+9]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.40, r1
        lea rax, [rsp+12]
        mov [rax], dl
        ; branch r1, false, @and_next_6
        or dl, dl
        jz @and_next_6
        ; move r0, t
        lea rax, [rsp+8]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.40, r1
        lea rax, [rsp+12]
        mov [rax], dl
@and_next_6:
        ; move r0, t.40
        lea rax, [rsp+12]
        mov cl, [rax]
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 28:15 logic and
        ; move r0, t
        lea rax, [rsp+8]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.42, r1
        lea rax, [rsp+13]
        mov [rax], dl
        ; branch r1, false, @and_next_7
        or dl, dl
        jz @and_next_7
        ; move r0, f
        lea rax, [rsp+9]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.42, r1
        lea rax, [rsp+13]
        mov [rax], dl
@and_next_7:
        ; move r0, t.42
        lea rax, [rsp+13]
        mov cl, [rax]
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 29:15 logic and
        ; move r0, t
        lea rax, [rsp+8]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.44, r1
        lea rax, [rsp+14]
        mov [rax], dl
        ; branch r1, false, @and_next_8
        or dl, dl
        jz @and_next_8
        ; move r0, t
        lea rax, [rsp+8]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.44, r1
        lea rax, [rsp+14]
        mov [rax], dl
@and_next_8:
        ; move r0, t.44
        lea rax, [rsp+14]
        mov cl, [rax]
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r0, [string-4]
        lea rcx, [string_4]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; 31:15 logic or
        ; move r0, f
        lea rax, [rsp+9]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.47, r1
        lea rax, [rsp+15]
        mov [rax], dl
        ; branch r1, true, @or_next_9
        or dl, dl
        jnz @or_next_9
        ; move r0, f
        lea rax, [rsp+9]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.47, r1
        lea rax, [rsp+15]
        mov [rax], dl
@or_next_9:
        ; move r0, t.47
        lea rax, [rsp+15]
        mov cl, [rax]
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 32:15 logic or
        ; move r0, f
        lea rax, [rsp+9]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.49, r1
        lea rax, [rsp+16]
        mov [rax], dl
        ; branch r1, true, @or_next_10
        or dl, dl
        jnz @or_next_10
        ; move r0, t
        lea rax, [rsp+8]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.49, r1
        lea rax, [rsp+16]
        mov [rax], dl
@or_next_10:
        ; move r0, t.49
        lea rax, [rsp+16]
        mov cl, [rax]
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 33:15 logic or
        ; move r0, t
        lea rax, [rsp+8]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.51, r1
        lea rax, [rsp+17]
        mov [rax], dl
        ; branch r1, true, @or_next_11
        or dl, dl
        jnz @or_next_11
        ; move r0, f
        lea rax, [rsp+9]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.51, r1
        lea rax, [rsp+17]
        mov [rax], dl
@or_next_11:
        ; move r0, t.51
        lea rax, [rsp+17]
        mov cl, [rax]
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 34:15 logic or
        ; move r0, t
        lea rax, [rsp+8]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.53, r1
        lea rax, [rsp+18]
        mov [rax], dl
        ; branch r1, true, @or_next_12
        or dl, dl
        jnz @or_next_12
        ; move r0, t
        lea rax, [rsp+8]
        mov cl, [rax]
        ; move r1, r0
        mov dl, cl
        ; move t.53, r1
        lea rax, [rsp+18]
        mov [rax], dl
@or_next_12:
        ; move r0, t.53
        lea rax, [rsp+18]
        mov cl, [rax]
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r0, [string-5]
        lea rcx, [string_5]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; move r0, f
        lea rax, [rsp+9]
        mov cl, [rax]
        ; notlog r0, r0
        or cl, cl
        sete cl
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; move r0, t
        lea rax, [rsp+8]
        mov cl, [rax]
        ; notlog r0, r0
        or cl, cl
        sete cl
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r0, [string-6]
        lea rcx, [string_6]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; const r0, 10
        mov cl, 10
        ; const r1, 6
        mov dl, 6
        ; const r2, 1
        mov r9b, 1
        ; and r0, r0, r1
        and cl, dl
        ; or r0, r0, r2
        or cl, r9b
        ; cast r0(i64), r0(u8)
        movzx rcx, cl
        ; move b1, r2
        lea rax, [rsp+10]
        mov [rax], r9b
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 43:20 logic or
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, c
        lea rax, [rsp+4]
        mov dx, [rax]
        ; equals r2, r0, r1
        cmp cx, dx
        sete r9b
        ; move t.64, r2
        lea rax, [rsp+19]
        mov [rax], r9b
        ; branch r2, true, @or_next_13
        or r9b, r9b
        jnz @or_next_13
        ; move r0, c
        lea rax, [rsp+4]
        mov cx, [rax]
        ; move r1, d
        lea rax, [rsp+6]
        mov dx, [rax]
        ; lt r2, r0, r1
        cmp cx, dx
        setl r9b
        ; move t.64, r2
        lea rax, [rsp+19]
        mov [rax], r9b
@or_next_13:
        ; move r0, t.64
        lea rax, [rsp+19]
        mov cl, [rax]
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 44:20 logic and
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, c
        lea rax, [rsp+4]
        mov dx, [rax]
        ; equals r2, r0, r1
        cmp cx, dx
        sete r9b
        ; move t.66, r2
        lea rax, [rsp+20]
        mov [rax], r9b
        ; branch r2, false, @and_next_14
        or r9b, r9b
        jz @and_next_14
        ; move r0, c
        lea rax, [rsp+4]
        mov cx, [rax]
        ; move r1, d
        lea rax, [rsp+6]
        mov dx, [rax]
        ; lt r0, r0, r1
        cmp cx, dx
        setl cl
        ; move t.66, r0
        lea rax, [rsp+20]
        mov [rax], cl
@and_next_14:
        ; move r0, t.66
        lea rax, [rsp+20]
        mov cl, [rax]
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r0, -1
        mov cx, -1
        ; cast r0(i64), r0(i16)
        movzx rcx, cx
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; neg r0, r0
        neg rcx
        ; cast r0(i64), r0(i16)
        movzx rcx, cx
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; move r0, b1
        lea rax, [rsp+10]
        mov cl, [rax]
        ; not r0, r0
        not rcx
        ; cast r0(i64), r0(u8)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; release space for local variables
        add rsp, 32
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
