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
        ; call r0, strlen, [str]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str, r0]
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
        ; addrof r0, chr
        lea rcx, [rsp+24]
        ; const r1, 1
        mov rdx, 1
        ; call _, printStringLength [r0, r1]
        push rcx
        push rdx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint
        ;   rsp+152: arg number
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
        ;   rsp+128: var t.18
        ;   rsp+136: var t.19
        ;   rsp+137: var t.20
@printUint:
        ; reserve space for local variables
        sub rsp, 144
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
        lea rax, [rsp+152]
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
        lea rax, [rsp+152]
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
        add rsp, 144
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
        ; const r0, 0
        mov rcx, 0
        ; move r1, number
        lea rax, [rsp+40]
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
        lea rax, [rsp+40]
        mov rcx, [rax]
        ; neg r0, r0
        neg rcx
        ; move number, r0
        lea rax, [rsp+40]
        mov [rax], rcx
@if_3_end:
        ; call _, printUint [number]
        lea rax, [rsp+40]
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
        ; const r0, 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; move length, r0
        lea rax, [rsp+0]
        mov [rax], rcx
@for_4:
        ; move r0, str
        lea rax, [rsp+56]
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
        lea rax, [rsp+56]
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
        lea rax, [rsp+56]
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
        add rsp, 48
        ret

        ; void main
        ;   rsp+0: var a
        ;   rsp+2: var b
        ;   rsp+4: var c
        ;   rsp+6: var d
        ;   rsp+8: var t
        ;   rsp+9: var f
        ;   rsp+10: var b10
        ;   rsp+11: var b6
        ;   rsp+12: var b1
        ;   rsp+16: var t.9
        ;   rsp+24: var t.10
        ;   rsp+32: var t.11
        ;   rsp+40: var t.12
        ;   rsp+48: var t.13
        ;   rsp+56: var t.14
        ;   rsp+64: var t.15
        ;   rsp+72: var t.16
        ;   rsp+80: var t.17
        ;   rsp+88: var t.18
        ;   rsp+96: var t.19
        ;   rsp+104: var t.20
        ;   rsp+112: var t.21
        ;   rsp+120: var t.22
        ;   rsp+128: var t.23
        ;   rsp+136: var t.24
        ;   rsp+144: var t.25
        ;   rsp+152: var t.26
        ;   rsp+160: var t.27
        ;   rsp+168: var t.28
        ;   rsp+176: var t.29
        ;   rsp+184: var t.30
        ;   rsp+192: var t.31
        ;   rsp+200: var t.32
        ;   rsp+208: var t.33
        ;   rsp+216: var t.34
        ;   rsp+224: var t.35
        ;   rsp+232: var t.36
        ;   rsp+240: var t.37
        ;   rsp+248: var t.38
        ;   rsp+256: var t.39
        ;   rsp+264: var t.40
        ;   rsp+272: var t.41
        ;   rsp+280: var t.42
        ;   rsp+288: var t.43
        ;   rsp+296: var t.44
        ;   rsp+304: var t.45
        ;   rsp+312: var t.46
        ;   rsp+320: var t.47
        ;   rsp+328: var t.48
        ;   rsp+336: var t.49
        ;   rsp+344: var t.50
        ;   rsp+352: var t.51
        ;   rsp+360: var t.52
        ;   rsp+368: var t.53
        ;   rsp+376: var t.54
        ;   rsp+384: var t.55
        ;   rsp+392: var t.56
        ;   rsp+400: var t.57
        ;   rsp+408: var t.58
        ;   rsp+416: var t.59
        ;   rsp+424: var t.60
        ;   rsp+432: var t.61
        ;   rsp+433: var t.62
        ;   rsp+440: var t.63
        ;   rsp+448: var t.64
        ;   rsp+456: var t.65
        ;   rsp+464: var t.66
        ;   rsp+472: var t.67
        ;   rsp+480: var t.68
        ;   rsp+488: var t.69
        ;   rsp+496: var t.70
        ;   rsp+504: var t.71
        ;   rsp+512: var t.72
@main:
        ; reserve space for local variables
        sub rsp, 528
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
        lea rax, [rsp+248]
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
        lea rax, [rsp+248]
        mov [rax], dl
@and_next_5:
        ; move r0, t.38
        lea rax, [rsp+248]
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
        lea rax, [rsp+264]
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
        lea rax, [rsp+264]
        mov [rax], dl
@and_next_6:
        ; move r0, t.40
        lea rax, [rsp+264]
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
        lea rax, [rsp+280]
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
        lea rax, [rsp+280]
        mov [rax], dl
@and_next_7:
        ; move r0, t.42
        lea rax, [rsp+280]
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
        lea rax, [rsp+296]
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
        lea rax, [rsp+296]
        mov [rax], dl
@and_next_8:
        ; move r0, t.44
        lea rax, [rsp+296]
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
        lea rax, [rsp+320]
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
        lea rax, [rsp+320]
        mov [rax], dl
@or_next_9:
        ; move r0, t.47
        lea rax, [rsp+320]
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
        lea rax, [rsp+336]
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
        lea rax, [rsp+336]
        mov [rax], dl
@or_next_10:
        ; move r0, t.49
        lea rax, [rsp+336]
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
        lea rax, [rsp+352]
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
        lea rax, [rsp+352]
        mov [rax], dl
@or_next_11:
        ; move r0, t.51
        lea rax, [rsp+352]
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
        lea rax, [rsp+368]
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
        lea rax, [rsp+368]
        mov [rax], dl
@or_next_12:
        ; move r0, t.53
        lea rax, [rsp+368]
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
        lea rax, [rsp+12]
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
        lea rax, [rsp+448]
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
        lea rax, [rsp+448]
        mov [rax], r9b
@or_next_13:
        ; move r0, t.64
        lea rax, [rsp+448]
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
        lea rax, [rsp+464]
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
        lea rax, [rsp+464]
        mov [rax], cl
@and_next_14:
        ; move r0, t.66
        lea rax, [rsp+464]
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
        lea rax, [rsp+12]
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
        add rsp, 528
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
