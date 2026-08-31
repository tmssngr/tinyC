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
        call init
        call @main
        mov rcx, 0
        sub rsp, 0x20
        call [ExitProcess]

        ; void printString@@u8
        ;   rsp+48: arg str
@printString@@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move r6{str}, r1{str}
        mov rbx, rcx
        ; move r1{str}, r6{str}
        mov rcx, rbx
        ; call r0{length} = strlen@@u8[r1{str}] -> i64
        call @strlen@@u8
        ; move r1{str}, r6{str}
        mov rcx, rbx
        ; move r2{length}, r0{length}
        mov rdx, rax
        ; call printStringLength@@u8@i64[r1{str}, r2{length}]
        call @printStringLength@@u8@i64
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printChar@u8
        ;   rsp+64: arg chr
@printChar@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; addrof r7{memVarAddr}, chr
        lea r12, [rsp+64]
        ; store [r7{memVarAddr}], r1{chr}
        mov [r12], cl
        ; addrof r1{t.1}, chr
        lea rcx, [rsp+64]
        ; const r2{t.2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[r1{t.1}, r2{t.2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printUint@i16
        ;   rsp+48: arg number
@printUint@i16:
        sub rsp, 8
        sub rsp, 32
        ; cast r1{t.1}(i64), r1{number}(i16)
        movsx rcx, cx
        ; call printUint@i64[r1{t.1}]
        call @printUint@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+80: arg number
        ;   rsp+40: var buffer
@printUint@i64:
        sub rsp, 32
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const r6{pos}, 20
        mov bl, 20
        ; 28:2 while true
@while_1:
        ; const r3{t.5}, 1
        mov r8b, 1
        ; sub r6{pos}, r6{pos}, r3{t.5}
        sub bl, r8b
        ; const r3{t.6}, 10
        mov r8, 10
        ; move r4{remainder}, r1{number}
        mov r9, rcx
        ; move r0{remainder}, r4{remainder}
        mov rax, r9
        ; mod r2{remainder}, r0{remainder}, r3{t.6}
        cqo
        idiv r8
        ; move r4{remainder}, r2{remainder}
        mov r9, rdx
        ; const r3{t.7}, 10
        mov r8, 10
        ; move r0{number}, r1{number}
        mov rax, rcx
        ; div r0{number}, r0{number}, r3{t.7}
        cqo
        idiv r8
        ; move r1{number}, r0{number}
        mov rcx, rax
        ; cast r0{t.8}(u8), r4{remainder}(i64)
        mov al, r9b
        ; const r3{t.9}, 48
        mov r8b, 48
        ; add r0{digit}, r0{digit}, r3{t.9}
        add al, r8b
        ; cast r3{t.11}(i64), r6{pos}(u8)
        movzx r8, bl
        ; addrof r4{t.10}, [buffer]
        lea r9, [rsp+40]
        ; add r4{t.10}, r4{t.10}, r3{t.11}
        add r9, r8
        ; store [r4{t.10}], r0{digit}
        mov [r9], al
        ; 34:3 if number == 0
        ; const r0{t.13}, 0
        mov rax, 0
        ; equals r0{t.12}, r1{number}, r0{t.13}
        cmp rcx, rax
        sete al
        ; branch r0{t.12}, false, @while_1, @while_1_break
        or al, al
        jz @while_1
        ; cast r0{t.15}(i64), r6{pos}(u8)
        movzx rax, bl
        ; addrof r1{t.14}, [buffer]
        lea rcx, [rsp+40]
        ; add r1{t.14}, r1{t.14}, r0{t.15}
        add rcx, rax
        ; const r0{t.17}, 20
        mov al, 20
        ; move r2{t.16}, r0{t.17}
        mov dl, al
        ; sub r2{t.16}, r2{t.16}, r6{pos}
        sub dl, bl
        ; call printStringLength@@u8@u8[r1{t.14}, r2{t.16}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        add rsp, 32
        ret

        ; i64 strlen@@u8
        ;   rsp+16: arg str
@strlen@@u8:
        sub rsp, 8
        ; const r0{length}, 0
        mov rax, 0
        ; 64:2 for *str != 0
        jmp @for_3
@for_3_body:
        ; const r2{t.5}, 1
        mov rdx, 1
        ; add r0{length}, r0{length}, r2{t.5}
        add rax, rdx
        ; const r2{t.6}, 1
        mov rdx, 1
        ; add r1{str}, r1{str}, r2{t.6}
        add rcx, rdx
@for_3:
        ; load r2{t.3}, [r1{str}]
        mov dl, [rcx]
        ; const r3{t.4}, 0
        mov r8b, 0
        ; notequals r2{t.2}, r2{t.3}, r3{t.4}
        cmp dl, r8b
        setne dl
        ; branch r2{t.2}, true, @for_3_body, @for_3_break
        or dl, dl
        jnz @for_3_body
        ; 67:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
@printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast r2{t.2}(i64), r2{length}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[r1{str}, r2{t.2}]
        call @printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void initRandom@i32
        ;   rsp+32: arg salt
@initRandom@i32:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        ; move r0{tmp.__random__}, r1{salt}
        mov eax, ecx
        ; addrof r7{memVarAddr}, __random__
        lea r12, [var_0]
        ; store [r7{memVarAddr}], r0{tmp.__random__}
        mov [r12], eax
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; i32 random
@random:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        ; addrof r7{memVarAddr}, __random__
        lea r12, [var_0]
        ; load r0{tmp.__random__}, [r7{memVarAddr}]
        mov eax, [r12]
        ; move r2{r}, r0{tmp.__random__}
        mov edx, eax
        ; const r3{t.6}, 524287
        mov r8d, 524287
        ; move r4{t.5}, r2{r}
        mov r9d, edx
        ; and r4{t.5}, r4{t.5}, r3{t.6}
        and r9d, r8d
        ; const r3{t.7}, 48271
        mov r8d, 48271
        ; mul r4{b}, r4{b}, r3{t.7}
        movsxd r9, r9d
        movsxd r8, r8d
        imul  r9, r8
        ; const r1{t.9}, 15
        mov ecx, 15
        ; shiftright r2{t.8}, r2{t.8}, r1{t.9}
        sar edx, cl
        ; const r3{t.10}, 48271
        mov r8d, 48271
        ; mul r2{c}, r2{c}, r3{t.10}
        movsxd rdx, edx
        movsxd r8, r8d
        imul  rdx, r8
        ; const r3{t.12}, 65535
        mov r8d, 65535
        ; move r5{t.11}, r2{c}
        mov r10d, edx
        ; and r5{t.11}, r5{t.11}, r3{t.12}
        and r10d, r8d
        ; const r1{t.13}, 15
        mov ecx, 15
        ; move r3{d}, r5{t.11}
        mov r8d, r10d
        ; shiftleft r3{d}, r3{d}, r1{t.13}
        sal r8d, cl
        ; const r1{t.16}, 16
        mov ecx, 16
        ; shiftright r2{t.15}, r2{t.15}, r1{t.16}
        sar edx, cl
        ; add r2{t.14}, r2{t.14}, r4{b}
        add edx, r9d
        ; add r2{e}, r2{e}, r3{d}
        add edx, r8d
        ; const r3{t.18}, 2147483647
        mov r8d, 2147483647
        ; move r4{t.17}, r2{e}
        mov r9d, edx
        ; and r4{t.17}, r4{t.17}, r3{t.18}
        and r9d, r8d
        ; const r1{t.20}, 31
        mov ecx, 31
        ; shiftright r2{t.19}, r2{t.19}, r1{t.20}
        sar edx, cl
        ; move r0{tmp.__random__}, r4{t.17}
        mov eax, r9d
        ; add r0{tmp.__random__}, r0{tmp.__random__}, r2{t.19}
        add eax, edx
        ; 15:9 return __random__
        ; addrof r7{memVarAddr}, __random__
        lea r12, [var_0]
        ; store [r7{memVarAddr}], r0{tmp.__random__}
        mov [r12], eax
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; i16 rowColumnToCell@i16@i16
        ;   rsp+16: arg row
        ;   rsp+24: arg column
@rowColumnToCell@i16@i16:
        sub rsp, 8
        ; 16:21 return row * 40 + column
        ; const r3{t.4}, 40
        mov r8w, 40
        ; mul r1{t.3}, r1{t.3}, r3{t.4}
        movsx rcx, cx
        movsx r8, r8w
        imul  rcx, r8
        ; move r0{t.2}, r1{t.3}
        mov ax, cx
        ; add r0{t.2}, r0{t.2}, r2{column}
        add ax, dx
        add rsp, 8
        ret

        ; u8 getCell@i16@i16
        ;   rsp+48: arg row
        ;   rsp+56: arg column
@getCell@i16@i16:
        sub rsp, 8
        sub rsp, 32
        ; 20:15 return [...]
        ; call r0{t.5} = rowColumnToCell@i16@i16[r1{row}, r2{column}] -> i16
        call @rowColumnToCell@i16@i16
        ; cast r1{t.4}(i64), r0{t.5}(i16)
        movsx rcx, ax
        ; addrof r2{t.3}, [field]
        lea rdx, [var_1]
        ; add r2{t.3}, r2{t.3}, r1{t.4}
        add rdx, rcx
        ; load r0{t.2}, [r2{t.3}]
        mov al, [rdx]
        add rsp, 32
        add rsp, 8
        ret

        ; bool isBomb@u8
        ;   rsp+16: arg cell
@isBomb@u8:
        sub rsp, 8
        ; 24:27 return cell & 1 != 0
        ; const r2{t.3}, 1
        mov dl, 1
        ; and r1{t.2}, r1{t.2}, r2{t.3}
        and cl, dl
        ; const r2{t.4}, 0
        mov dl, 0
        ; notequals r0{t.1}, r1{t.2}, r2{t.4}
        cmp cl, dl
        setne al
        add rsp, 8
        ret

        ; bool isOpen@u8
        ;   rsp+16: arg cell
@isOpen@u8:
        sub rsp, 8
        ; 28:27 return cell & 2 != 0
        ; const r2{t.3}, 2
        mov dl, 2
        ; and r1{t.2}, r1{t.2}, r2{t.3}
        and cl, dl
        ; const r2{t.4}, 0
        mov dl, 0
        ; notequals r0{t.1}, r1{t.2}, r2{t.4}
        cmp cl, dl
        setne al
        add rsp, 8
        ret

        ; bool isFlag@u8
        ;   rsp+16: arg cell
@isFlag@u8:
        sub rsp, 8
        ; 32:27 return cell & 4 != 0
        ; const r2{t.3}, 4
        mov dl, 4
        ; and r1{t.2}, r1{t.2}, r2{t.3}
        and cl, dl
        ; const r2{t.4}, 0
        mov dl, 0
        ; notequals r0{t.1}, r1{t.2}, r2{t.4}
        cmp cl, dl
        setne al
        add rsp, 8
        ret

        ; bool checkCellBounds@i16@i16
        ;   rsp+16: arg row
        ;   rsp+24: arg column
@checkCellBounds@i16@i16:
        sub rsp, 8
        ; 37:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 37:21 logic and
        ; 37:6 logic and
        ; 36:21 logic and
        ; const r3{t.3}, 0
        mov r8w, 0
        ; gteq r0{t.2}, r1{row}, r3{t.3}
        cmp cx, r8w
        setge al
        ; branch r0{t.2}, false, @and_next_6, @and_2nd_6
        or al, al
        jz @and_next_6
        ; const r3{t.4}, 20
        mov r8w, 20
        ; lt r0{t.2}, r1{row}, r3{t.4}
        cmp cx, r8w
        setl al
@and_next_6:
        ; branch r0{t.2}, false, @and_next_5, @and_2nd_5
        or al, al
        jz @and_next_5
        ; const r1{t.5}, 0
        mov cx, 0
        ; gteq r0{t.2}, r2{column}, r1{t.5}
        cmp dx, cx
        setge al
@and_next_5:
        ; branch r0{t.2}, false, @checkCellBounds@i16@i16_ret, @and_2nd_4
        or al, al
        jz @checkCellBounds@i16@i16_ret
        ; const r1{t.6}, 40
        mov cx, 40
        ; lt r0{t.2}, r2{column}, r1{t.6}
        cmp dx, cx
        setl al
@checkCellBounds@i16@i16_ret:
        add rsp, 8
        ret

        ; void setCell@i16@i16@u8
        ;   rsp+48: arg row
        ;   rsp+56: arg column
        ;   rsp+64: arg cell
@setCell@i16@i16@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move r6{cell}, r3{cell}
        mov bl, r8b
        ; call r0{t.5} = rowColumnToCell@i16@i16[r1{row}, r2{column}] -> i16
        call @rowColumnToCell@i16@i16
        ; cast r0{t.4}(i64), r0{t.5}(i16)
        movsx rax, ax
        ; addrof r1{t.3}, [field]
        lea rcx, [var_1]
        ; add r1{t.3}, r1{t.3}, r0{t.4}
        add rcx, rax
        ; store [r1{t.3}], r6{cell}
        mov [rcx], bl
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; u8 getBombCountAround@i16@i16
        ;   rsp+80: arg row
        ;   rsp+88: arg column
        ;   rsp+48: var count
        ;   rsp+50: var dr
        ;   rsp+52: var r
        ;   rsp+54: var dc
        ;   rsp+56: var c
@getBombCountAround@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move r6{row}, r1{row}
        mov bx, cx
        ; const r0{count}, 0
        mov al, 0
        ; addrof r7{memVarAddr}, count
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r0{count}
        mov [r12], al
        ; const r0{dr}, -1
        mov ax, -1
        ; 46:2 for dr <= 1
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+88]
        ; store [r7{memVarAddr}], r2{column}
        mov [r12], dx
        ; move r2{dr}, r0{dr}
        mov dx, ax
        ; addrof r7{memVarAddr}, count
        lea r12, [rsp+48]
        ; load r0{count}, [r7{memVarAddr}]
        mov al, [r12]
        jmp @for_7
@for_7_body:
        ; addrof r7{memVarAddr}, count
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r0{count}
        mov [r12], al
        ; move r0{dr}, r2{dr}
        mov ax, dx
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+88]
        ; load r2{column}, [r7{memVarAddr}]
        mov dx, [r12]
        ; move r1{r}, r6{row}
        mov cx, bx
        ; add r1{r}, r1{r}, r0{dr}
        add cx, ax
        ; addrof r7{memVarAddr}, dr
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r0{dr}
        mov [r12], ax
        ; const r0{dc}, -1
        mov ax, -1
        ; 48:3 for dc <= 1
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+88]
        ; store [r7{memVarAddr}], r2{column}
        mov [r12], dx
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+52]
        ; store [r7{memVarAddr}], r1{r}
        mov [r12], cx
        ; move r2{dc}, r0{dc}
        mov dx, ax
        ; addrof r7{memVarAddr}, count
        lea r12, [rsp+48]
        ; load r0{count}, [r7{memVarAddr}]
        mov al, [r12]
        jmp @for_8
@for_8_body:
        ; addrof r7{memVarAddr}, count
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r0{count}
        mov [r12], al
        ; move r0{dc}, r2{dc}
        mov ax, dx
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+88]
        ; load r2{column}, [r7{memVarAddr}]
        mov dx, [r12]
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+52]
        ; load r1{r}, [r7{memVarAddr}]
        mov cx, [r12]
        ; move r3{c}, r2{column}
        mov r8w, dx
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+88]
        ; store [r7{memVarAddr}], r2{column}
        mov [r12], dx
        ; add r3{c}, r3{c}, r0{dc}
        add r8w, ax
        ; addrof r7{memVarAddr}, dc
        lea r12, [rsp+54]
        ; store [r7{memVarAddr}], r0{dc}
        mov [r12], ax
        ; 50:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=50:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=50:27]])
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+52]
        ; store [r7{memVarAddr}], r1{r}
        mov [r12], cx
        ; move r2{c}, r3{c}
        mov dx, r8w
        ; addrof r7{memVarAddr}, c
        lea r12, [rsp+56]
        ; store [r7{memVarAddr}], r3{c}
        mov [r12], r8w
        ; call r0{t.12} = checkCellBounds@i16@i16[r1{r}, r2{c}] -> bool
        call @checkCellBounds@i16@i16
        ; branch r0{t.12}, true, @if_9_then, @no_critical_edge_11
        or al, al
        jnz @if_9_then
        ; addrof r7{memVarAddr}, count
        lea r12, [rsp+48]
        ; load r0{count}, [r7{memVarAddr}]
        mov al, [r12]
        jmp @for_8_continue
@if_9_then:
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+52]
        ; load r1{r}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+52]
        ; store [r7{memVarAddr}], r1{r}
        mov [r12], cx
        ; addrof r7{memVarAddr}, c
        lea r12, [rsp+56]
        ; load r2{c}, [r7{memVarAddr}]
        mov dx, [r12]
        ; call r0{cell} = getCell@i16@i16[r1{r}, r2{c}] -> u8
        call @getCell@i16@i16
        ; 52:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=52:16]])
        ; move r1{cell}, r0{cell}
        mov cl, al
        ; call r0{t.13} = isBomb@u8[r1{cell}] -> bool
        call @isBomb@u8
        ; branch r0{t.13}, true, @if_10_then, @no_critical_edge_12
        or al, al
        jnz @if_10_then
        ; addrof r7{memVarAddr}, count
        lea r12, [rsp+48]
        ; load r0{count}, [r7{memVarAddr}]
        mov al, [r12]
        jmp @for_8_continue
@if_10_then:
        ; const r1{t.14}, 1
        mov cl, 1
        ; addrof r7{memVarAddr}, count
        lea r12, [rsp+48]
        ; load r0{count}, [r7{memVarAddr}]
        mov al, [r12]
        ; add r0{count}, r0{count}, r1{t.14}
        add al, cl
@for_8_continue:
        ; const r1{t.15}, 1
        mov cx, 1
        ; addrof r7{memVarAddr}, dc
        lea r12, [rsp+54]
        ; load r2{dc}, [r7{memVarAddr}]
        mov dx, [r12]
        ; add r2{dc}, r2{dc}, r1{t.15}
        add dx, cx
@for_8:
        ; const r1{t.11}, 1
        mov cx, 1
        ; lteq r1{t.10}, r2{dc}, r1{t.11}
        cmp dx, cx
        setle cl
        ; branch r1{t.10}, true, @for_8_body, @for_7_continue
        or cl, cl
        jnz @for_8_body
        ; const r1{t.16}, 1
        mov cx, 1
        ; addrof r7{memVarAddr}, dr
        lea r12, [rsp+50]
        ; load r2{dr}, [r7{memVarAddr}]
        mov dx, [r12]
        ; add r2{dr}, r2{dr}, r1{t.16}
        add dx, cx
@for_7:
        ; const r1{t.9}, 1
        mov cx, 1
        ; lteq r1{t.8}, r2{dr}, r1{t.9}
        cmp dx, cx
        setle cl
        ; branch r1{t.8}, true, @for_7_body, @for_7_break
        or cl, cl
        jnz @for_7_body
        ; 58:9 return count
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; u8 getSpacer@i16@i16@i16@i16
        ;   rsp+16: arg row
        ;   rsp+24: arg column
        ;   rsp+32: arg rowCursor
        ;   rsp+40: arg columnCursor
@getSpacer@i16@i16@i16@i16:
        sub rsp, 8
        ; 62:2 if rowCursor == row
        ; equals r1{t.4}, r3{rowCursor}, r1{row}
        cmp r8w, cx
        sete cl
        ; branch r1{t.4}, false, @if_11_end, @if_11_then
        or cl, cl
        jz @if_11_end
        ; 63:3 if columnCursor == column
        ; equals r1{t.5}, r4{columnCursor}, r2{column}
        cmp r9w, dx
        sete cl
        ; branch r1{t.5}, true, @if_12_then, @if_12_end
        or cl, cl
        jnz @if_12_then
        ; 66:3 if columnCursor == column - 1
        ; const r1{t.9}, 1
        mov cx, 1
        ; sub r2{t.8}, r2{t.8}, r1{t.9}
        sub dx, cx
        ; equals r1{t.7}, r4{columnCursor}, r2{t.8}
        cmp r9w, dx
        sete cl
        ; branch r1{t.7}, false, @if_11_end, @if_13_then
        or cl, cl
        jz @if_11_end
        jmp @if_13_then
@if_12_then:
        ; 64:11 return 91
        ; const r0{t.6}, 91
        mov al, 91
        jmp @getSpacer@i16@i16@i16@i16_ret
@if_13_then:
        ; 67:11 return 93
        ; const r1{t.10}, 93
        mov cl, 93
        ; move r0{t.10}, r1{t.10}
        mov al, cl
        jmp @getSpacer@i16@i16@i16@i16_ret
@if_11_end:
        ; 70:9 return 32
        ; const r1{t.11}, 32
        mov cl, 32
        ; move r0{t.11}, r1{t.11}
        mov al, cl
@getSpacer@i16@i16@i16@i16_ret:
        add rsp, 8
        ret

        ; void printCell@u8@i16@i16
        ;   rsp+64: arg cell
        ;   rsp+72: arg row
        ;   rsp+80: arg column
@printCell@u8@i16@i16:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move r6{cell}, r1{cell}
        mov bl, cl
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+72]
        ; store [r7{memVarAddr}], r2{row}
        mov [r12], dx
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+80]
        ; store [r7{memVarAddr}], r3{column}
        mov [r12], r8w
        ; 75:2 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:13]])
        ; move r1{cell}, r6{cell}
        mov cl, bl
        ; call r0{t.5} = isFlag@u8[r1{cell}] -> bool
        call @isFlag@u8
        ; branch r0{t.5}, true, @if_14_then, @if_14_else
        or al, al
        jnz @if_14_then
        ; 79:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=79:14]])
        ; move r1{cell}, r6{cell}
        mov cl, bl
        ; call r0{t.6} = isBomb@u8[r1{cell}] -> bool
        call @isBomb@u8
        ; branch r0{t.6}, false, @if_15_else, @if_15_then
        or al, al
        jz @if_15_else
        jmp @if_15_then
@if_14_then:
        ; const r6{chr}, 35
        mov bl, 35
        jmp @if_14_end
@if_15_else:
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+72]
        ; load r1{row}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+80]
        ; load r2{column}, [r7{memVarAddr}]
        mov dx, [r12]
        ; call r0{count} = getBombCountAround@i16@i16[r1{row}, r2{column}] -> u8
        call @getBombCountAround@i16@i16
        ; 84:4 if count > 0
        ; const r6{t.8}, 0
        mov bl, 0
        ; gt r6{t.7}, r0{count}, r6{t.8}
        cmp al, bl
        seta bl
        ; branch r6{t.7}, false, @if_16_else, @if_16_then
        or bl, bl
        jz @if_16_else
        jmp @if_16_then
@if_15_then:
        ; const r6{chr}, 42
        mov bl, 42
        jmp @if_14_end
@if_16_else:
        ; const r6{chr}, 32
        mov bl, 32
        jmp @if_14_end
@if_16_then:
        ; const r2{t.9}, 48
        mov dl, 48
        ; move r6{chr}, r0{count}
        mov bl, al
        ; add r6{chr}, r6{chr}, r2{t.9}
        add bl, dl
@if_14_end:
        ; move r1{chr}, r6{chr}
        mov cl, bl
        ; call printChar@u8[r1{chr}]
        call @printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printField@i16@i16
        ;   rsp+64: arg rowCursor
        ;   rsp+72: arg columnCursor
        ;   rsp+48: var row
        ;   rsp+50: var column
@printField@i16@i16:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move r6{rowCursor}, r1{rowCursor}
        mov bx, cx
        ; addrof r7{memVarAddr}, columnCursor
        lea r12, [rsp+72]
        ; store [r7{memVarAddr}], r2{columnCursor}
        mov [r12], dx
        ; const r1{t.7}, 0
        mov cx, 0
        ; const r2{t.8}, 0
        mov dx, 0
        ; call setCursor@i16@i16[r1{t.7}, r2{t.8}]
        call @setCursor@i16@i16
        ; const r1{row}, 0
        mov cx, 0
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r1{row}
        mov [r12], cx
        ; 97:2 for row < 20
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+48]
        ; load r1{row}, [r7{memVarAddr}]
        mov cx, [r12]
        jmp @for_17
@for_17_body:
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r1{row}
        mov [r12], cx
        ; const r1{t.11}, 124
        mov cl, 124
        ; call printChar@u8[r1{t.11}]
        call @printChar@u8
        ; const r2{column}, 0
        mov dx, 0
        ; 99:3 for column < 40
        ; move r5{column}, r2{column}
        mov r10w, dx
        jmp @for_18
@for_18_body:
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+48]
        ; load r1{row}, [r7{memVarAddr}]
        mov cx, [r12]
        ; move r2{column}, r5{column}
        mov dx, r10w
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r1{row}
        mov [r12], cx
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r2{column}
        mov [r12], dx
        ; move r3{rowCursor}, r6{rowCursor}
        mov r8w, bx
        ; addrof r7{memVarAddr}, columnCursor
        lea r12, [rsp+72]
        ; load r4{columnCursor}, [r7{memVarAddr}]
        mov r9w, [r12]
        ; addrof r7{memVarAddr}, columnCursor
        lea r12, [rsp+72]
        ; store [r7{memVarAddr}], r4{columnCursor}
        mov [r12], r9w
        ; call r0{spacer} = getSpacer@i16@i16@i16@i16[r1{row}, r2{column}, r3{rowCursor}, r4{columnCursor}] -> u8
        call @getSpacer@i16@i16@i16@i16
        ; move r1{spacer}, r0{spacer}
        mov cl, al
        ; call printChar@u8[r1{spacer}]
        call @printChar@u8
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+48]
        ; load r1{row}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r1{row}
        mov [r12], cx
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+50]
        ; load r2{column}, [r7{memVarAddr}]
        mov dx, [r12]
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r2{column}
        mov [r12], dx
        ; call r0{cell} = getCell@i16@i16[r1{row}, r2{column}] -> u8
        call @getCell@i16@i16
        ; move r1{cell}, r0{cell}
        mov cl, al
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+48]
        ; load r2{row}, [r7{memVarAddr}]
        mov dx, [r12]
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r2{row}
        mov [r12], dx
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+50]
        ; load r3{column}, [r7{memVarAddr}]
        mov r8w, [r12]
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r3{column}
        mov [r12], r8w
        ; call printCell@u8@i16@i16[r1{cell}, r2{row}, r3{column}]
        call @printCell@u8@i16@i16
        ; const r0{t.14}, 1
        mov ax, 1
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+50]
        ; load r5{column}, [r7{memVarAddr}]
        mov r10w, [r12]
        ; add r5{column}, r5{column}, r0{t.14}
        add r10w, ax
@for_18:
        ; const r0{t.13}, 40
        mov ax, 40
        ; lt r0{t.12}, r5{column}, r0{t.13}
        cmp r10w, ax
        setl al
        ; branch r0{t.12}, true, @for_18_body, @for_18_break
        or al, al
        jnz @for_18_body
        ; const r2{t.15}, 40
        mov dx, 40
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+48]
        ; load r1{row}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r1{row}
        mov [r12], cx
        ; move r3{rowCursor}, r6{rowCursor}
        mov r8w, bx
        ; addrof r7{memVarAddr}, columnCursor
        lea r12, [rsp+72]
        ; load r4{columnCursor}, [r7{memVarAddr}]
        mov r9w, [r12]
        ; addrof r7{memVarAddr}, columnCursor
        lea r12, [rsp+72]
        ; store [r7{memVarAddr}], r4{columnCursor}
        mov [r12], r9w
        ; call r0{spacer} = getSpacer@i16@i16@i16@i16[r1{row}, r2{t.15}, r3{rowCursor}, r4{columnCursor}] -> u8
        call @getSpacer@i16@i16@i16@i16
        ; move r1{spacer}, r0{spacer}
        mov cl, al
        ; call printChar@u8[r1{spacer}]
        call @printChar@u8
        ; const r1{t.16}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[r1{t.16}]
        call @printString@@u8
        ; const r0{t.17}, 1
        mov ax, 1
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+48]
        ; load r1{row}, [r7{memVarAddr}]
        mov cx, [r12]
        ; add r1{row}, r1{row}, r0{t.17}
        add cx, ax
@for_17:
        ; const r0{t.10}, 20
        mov ax, 20
        ; lt r0{t.9}, r1{row}, r0{t.10}
        cmp cx, ax
        setl al
        ; branch r0{t.9}, true, @for_17_body, @printField@i16@i16_ret
        or al, al
        jnz @for_17_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printSpaces@i16
        ;   rsp+48: arg i
@printSpaces@i16:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move r6{i}, r1{i}
        mov bx, cx
        ; 112:2 for i > 0
        jmp @for_19
@for_19_body:
        ; const r1{t.3}, 48
        mov cl, 48
        ; call printChar@u8[r1{t.3}]
        call @printChar@u8
        ; const r0{t.4}, 1
        mov ax, 1
        ; sub r6{i}, r6{i}, r0{t.4}
        sub bx, ax
@for_19:
        ; const r0{t.2}, 0
        mov ax, 0
        ; gt r0{t.1}, r6{i}, r0{t.2}
        cmp bx, ax
        setg al
        ; branch r0{t.1}, true, @for_19_body, @printSpaces@i16_ret
        or al, al
        jnz @for_19_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; u8 getDigitCount@i16
        ;   rsp+16: arg value
@getDigitCount@i16:
        sub rsp, 8
        ; const r3{count}, 0
        mov r8b, 0
        ; 119:2 if value < 0
        ; const r4{t.3}, 0
        mov r9w, 0
        ; lt r4{t.2}, r1{value}, r4{t.3}
        cmp cx, r9w
        setl r9b
        ; branch r4{t.2}, false, @while_21, @if_20_then
        or r9b, r9b
        jz @while_21
        ; const r3{count}, 1
        mov r8b, 1
        ; neg r1{value}, r1{value}
        neg rcx
@while_21:
        ; const r4{t.4}, 1
        mov r9b, 1
        ; add r3{count}, r3{count}, r4{t.4}
        add r8b, r9b
        ; const r4{t.5}, 10
        mov r9w, 10
        ; move r0{value}, r1{value}
        mov ax, cx
        ; div r0{value}, r0{value}, r4{t.5}
        movsx rax, ax
        movsx r9, r9w
        cqo
        idiv r9
        ; move r1{value}, r0{value}
        mov cx, ax
        ; 127:3 if value == 0
        ; const r2{t.7}, 0
        mov dx, 0
        ; equals r2{t.6}, r1{value}, r2{t.7}
        cmp cx, dx
        sete dl
        ; branch r2{t.6}, false, @while_21, @while_21_break
        or dl, dl
        jz @while_21
        ; 132:9 return count
        ; move r0{count}, r3{count}
        mov al, r8b
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+48: var r
        ;   rsp+50: var c
@getHiddenCount:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const r6{count}, 0
        mov bx, 0
        ; const r1{r}, 0
        mov cx, 0
        ; 137:2 for r < 20
        ; move r2{r}, r1{r}
        mov dx, cx
        jmp @for_23
@for_23_body:
        ; move r1{r}, r2{r}
        mov cx, dx
        ; const r2{c}, 0
        mov dx, 0
        ; 138:3 for c < 40
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r1{r}
        mov [r12], cx
        jmp @for_24
@for_24_body:
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+48]
        ; load r1{r}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r1{r}
        mov [r12], cx
        ; addrof r7{memVarAddr}, c
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r2{c}
        mov [r12], dx
        ; call r0{cell} = getCell@i16@i16[r1{r}, r2{c}] -> u8
        call @getCell@i16@i16
        ; 140:4 if cell & 6 == 0
        ; const r1{t.10}, 6
        mov cl, 6
        ; move r2{t.9}, r0{cell}
        mov dl, al
        ; and r2{t.9}, r2{t.9}, r1{t.10}
        and dl, cl
        ; const r1{t.11}, 0
        mov cl, 0
        ; equals r1{t.8}, r2{t.9}, r1{t.11}
        cmp dl, cl
        sete cl
        ; branch r1{t.8}, false, @for_24_continue, @if_25_then
        or cl, cl
        jz @for_24_continue
        ; const r1{t.12}, 1
        mov cx, 1
        ; add r6{count}, r6{count}, r1{t.12}
        add bx, cx
@for_24_continue:
        ; const r1{t.13}, 1
        mov cx, 1
        ; addrof r7{memVarAddr}, c
        lea r12, [rsp+50]
        ; load r2{c}, [r7{memVarAddr}]
        mov dx, [r12]
        ; add r2{c}, r2{c}, r1{t.13}
        add dx, cx
@for_24:
        ; const r1{t.7}, 40
        mov cx, 40
        ; lt r1{t.6}, r2{c}, r1{t.7}
        cmp dx, cx
        setl cl
        ; branch r1{t.6}, true, @for_24_body, @for_23_continue
        or cl, cl
        jnz @for_24_body
        ; const r1{t.14}, 1
        mov cx, 1
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+48]
        ; load r2{r}, [r7{memVarAddr}]
        mov dx, [r12]
        ; add r2{r}, r2{r}, r1{t.14}
        add dx, cx
@for_23:
        ; const r1{t.5}, 20
        mov cx, 20
        ; lt r1{t.4}, r2{r}, r1{t.5}
        cmp dx, cx
        setl cl
        ; branch r1{t.4}, true, @for_23_body, @for_23_break
        or cl, cl
        jnz @for_23_body
        ; 145:9 return count
        ; move r0{count}, r6{count}
        mov ax, bx
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; bool printLeft
        ;   rsp+48: var leftDigits
        ;   rsp+50: var bombDigits
@printLeft:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; call r0{count} = getHiddenCount[] -> i16
        call @getHiddenCount
        ; move r6{count}, r0{count}
        mov bx, ax
        ; move r1{count}, r6{count}
        mov cx, bx
        ; call r0{t.3} = getDigitCount@i16[r1{count}] -> u8
        call @getDigitCount@i16
        ; cast r0{leftDigits}(i16), r0{t.3}(u8)
        movzx ax, al
        ; addrof r7{memVarAddr}, leftDigits
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r0{leftDigits}
        mov [r12], ax
        ; const r1{t.5}, 40
        mov cx, 40
        ; call r0{t.4} = getDigitCount@i16[r1{t.5}] -> u8
        call @getDigitCount@i16
        ; cast r0{bombDigits}(i16), r0{t.4}(u8)
        movzx ax, al
        ; addrof r7{memVarAddr}, bombDigits
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r0{bombDigits}
        mov [r12], ax
        ; const r1{t.6}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[r1{t.6}]
        call @printString@@u8
        ; addrof r7{memVarAddr}, bombDigits
        lea r12, [rsp+50]
        ; load r0{bombDigits}, [r7{memVarAddr}]
        mov ax, [r12]
        ; move r1{t.7}, r0{bombDigits}
        mov cx, ax
        ; addrof r7{memVarAddr}, leftDigits
        lea r12, [rsp+48]
        ; load r0{leftDigits}, [r7{memVarAddr}]
        mov ax, [r12]
        ; sub r1{t.7}, r1{t.7}, r0{leftDigits}
        sub cx, ax
        ; call printSpaces@i16[r1{t.7}]
        call @printSpaces@i16
        ; move r1{count}, r6{count}
        mov cx, bx
        ; call printUint@i16[r1{count}]
        call @printUint@i16
        ; 156:15 return count == 0
        ; const r1{t.9}, 0
        mov cx, 0
        ; equals r0{t.8}, r6{count}, r1{t.9}
        cmp bx, cx
        sete al
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; i16 abs@i16
        ;   rsp+16: arg a
@abs@i16:
        sub rsp, 8
        ; 160:2 if a < 0
        ; const r2{t.2}, 0
        mov dx, 0
        ; lt r2{t.1}, r1{a}, r2{t.2}
        cmp cx, dx
        setl dl
        ; branch r2{t.1}, true, @if_26_then, @if_26_end
        or dl, dl
        jnz @if_26_then
        ; 163:9 return a
        ; move r0{a}, r1{a}
        mov ax, cx
        jmp @abs@i16_ret
@if_26_then:
        ; 161:10 return -a
        ; neg r1{t.3}, r1{a}
        neg rcx
        ; move r0{t.3}, r1{t.3}
        mov ax, cx
@abs@i16_ret:
        add rsp, 8
        ret

        ; void clearField
@clearField:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const r6{r}, 0
        mov bx, 0
        ; 167:2 for r < 20
        jmp @for_27
@for_27_body:
        ; const r7{c}, 0
        mov r12w, 0
        ; 168:3 for c < 40
        jmp @for_28
@for_28_body:
        ; const r3{t.6}, 0
        mov r8b, 0
        ; move r1{r}, r6{r}
        mov cx, bx
        ; move r2{c}, r7{c}
        mov dx, r12w
        ; call setCell@i16@i16@u8[r1{r}, r2{c}, r3{t.6}]
        call @setCell@i16@i16@u8
        ; const r0{t.7}, 1
        mov ax, 1
        ; add r7{c}, r7{c}, r0{t.7}
        add r12w, ax
@for_28:
        ; const r0{t.5}, 40
        mov ax, 40
        ; lt r0{t.4}, r7{c}, r0{t.5}
        cmp r12w, ax
        setl al
        ; branch r0{t.4}, true, @for_28_body, @for_27_continue
        or al, al
        jnz @for_28_body
        ; const r0{t.8}, 1
        mov ax, 1
        ; add r6{r}, r6{r}, r0{t.8}
        add bx, ax
@for_27:
        ; const r0{t.3}, 20
        mov ax, 20
        ; lt r0{t.2}, r6{r}, r0{t.3}
        cmp bx, ax
        setl al
        ; branch r0{t.2}, true, @for_27_body, @clearField_ret
        or al, al
        jnz @for_27_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void initField@i16@i16
        ;   rsp+64: arg curr_r
        ;   rsp+72: arg curr_c
        ;   rsp+48: var bombs
        ;   rsp+50: var row
        ;   rsp+52: var column
        ;   rsp+54: var t.13
@initField@i16@i16:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move r6{curr_r}, r1{curr_r}
        mov bx, cx
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+72]
        ; store [r7{memVarAddr}], r2{curr_c}
        mov [r12], dx
        ; const r0{bombs}, 40
        mov ax, 40
        ; addrof r7{memVarAddr}, bombs
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r0{bombs}
        mov [r12], ax
        ; 175:2 for bombs > 0
        ; addrof r7{memVarAddr}, bombs
        lea r12, [rsp+48]
        ; load r1{bombs}, [r7{memVarAddr}]
        mov cx, [r12]
        jmp @for_29
@for_29_body:
        ; addrof r7{memVarAddr}, bombs
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r1{bombs}
        mov [r12], cx
        ; call r0{t.8} = random[] -> i32
        call @random
        ; const r1{t.9}, 20
        mov ecx, 20
        ; move r3{t.7}, r0{t.8}
        mov r8d, eax
        ; move r0{t.7}, r3{t.7}
        mov eax, r8d
        ; mod r2{t.7}, r0{t.7}, r1{t.9}
        movsxd rax, eax
        movsxd rcx, ecx
        cqo
        idiv rcx
        ; move r3{t.7}, r2{t.7}
        mov r8d, edx
        ; cast r1{row}(i16), r3{t.7}(i32)
        mov cx, r8w
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{row}
        mov [r12], cx
        ; call r0{t.11} = random[] -> i32
        call @random
        ; const r3{t.12}, 40
        mov r8d, 40
        ; move r4{t.10}, r0{t.11}
        mov r9d, eax
        ; move r0{t.10}, r4{t.10}
        mov eax, r9d
        ; mod r2{t.10}, r0{t.10}, r3{t.12}
        movsxd rax, eax
        movsxd r8, r8d
        cqo
        idiv r8
        ; move r4{t.10}, r2{t.10}
        mov r9d, edx
        ; cast r2{column}(i16), r4{t.10}(i32)
        mov dx, r9w
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+52]
        ; store [r7{memVarAddr}], r2{column}
        mov [r12], dx
        ; 178:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=179:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=179:20], location=179:18]]) > 1
        ; 179:4 logic or
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+50]
        ; load r0{row}, [r7{memVarAddr}]
        mov ax, [r12]
        ; move r1{t.15}, r0{row}
        mov cx, ax
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r0{row}
        mov [r12], ax
        ; sub r1{t.15}, r1{t.15}, r6{curr_r}
        sub cx, bx
        ; call r0{t.14} = abs@i16[r1{t.15}] -> i16
        call @abs@i16
        ; const r2{t.16}, 1
        mov dx, 1
        ; gt r0{t.13}, r0{t.14}, r2{t.16}
        cmp ax, dx
        setg al
        ; branch r0{t.13}, true, @no_critical_edge_8, @or_2nd_31
        or al, al
        jnz @no_critical_edge_8
        ; addrof r7{memVarAddr}, t.13
        lea r12, [rsp+54]
        ; store [r7{memVarAddr}], r0{t.13}
        mov [r12], al
        jmp @or_2nd_31
@no_critical_edge_8:
        ; addrof r7{memVarAddr}, t.13
        lea r12, [rsp+54]
        ; store [r7{memVarAddr}], r0{t.13}
        mov [r12], al
        ; addrof r7{memVarAddr}, t.13
        lea r12, [rsp+54]
        ; load r0{t.13}, [r7{memVarAddr}]
        mov al, [r12]
        jmp @or_next_31
@or_2nd_31:
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+52]
        ; load r0{column}, [r7{memVarAddr}]
        mov ax, [r12]
        ; move r1{t.18}, r0{column}
        mov cx, ax
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+72]
        ; load r0{curr_c}, [r7{memVarAddr}]
        mov ax, [r12]
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+52]
        ; store [r7{memVarAddr}], r0{column}
        mov [r12], ax
        ; sub r1{t.18}, r1{t.18}, r0{curr_c}
        sub cx, ax
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+72]
        ; store [r7{memVarAddr}], r0{curr_c}
        mov [r12], ax
        ; call r0{t.17} = abs@i16[r1{t.18}] -> i16
        call @abs@i16
        ; const r4{t.19}, 1
        mov r9w, 1
        ; gt r0{t.13}, r0{t.17}, r4{t.19}
        cmp ax, r9w
        setg al
@or_next_31:
        ; branch r0{t.13}, false, @for_29_continue, @if_30_then
        or al, al
        jz @for_29_continue
        ; const r3{t.20}, 1
        mov r8b, 1
        ; addrof r7{memVarAddr}, row
        lea r12, [rsp+50]
        ; load r1{row}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+52]
        ; load r2{column}, [r7{memVarAddr}]
        mov dx, [r12]
        ; call setCell@i16@i16@u8[r1{row}, r2{column}, r3{t.20}]
        call @setCell@i16@i16@u8
@for_29_continue:
        ; const r0{t.21}, 1
        mov ax, 1
        ; addrof r7{memVarAddr}, bombs
        lea r12, [rsp+48]
        ; load r1{bombs}, [r7{memVarAddr}]
        mov cx, [r12]
        ; sub r1{bombs}, r1{bombs}, r0{t.21}
        sub cx, ax
@for_29:
        ; const r0{t.6}, 0
        mov ax, 0
        ; gt r0{t.5}, r1{bombs}, r0{t.6}
        cmp cx, ax
        setg al
        ; branch r0{t.5}, true, @for_29_body, @initField@i16@i16_ret
        or al, al
        jnz @for_29_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void maybeRevealAround@i16@i16
        ;   rsp+80: arg row
        ;   rsp+88: arg column
        ;   rsp+48: var dr
        ;   rsp+50: var r
        ;   rsp+52: var dc
        ;   rsp+54: var c
        ;   rsp+56: var cell
@maybeRevealAround@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move r6{row}, r1{row}
        mov bx, cx
        ; 186:2 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=186:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=186:30]]) != 0
        ; move r1{row}, r6{row}
        mov cx, bx
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+88]
        ; store [r7{memVarAddr}], r2{column}
        mov [r12], dx
        ; call r0{t.8} = getBombCountAround@i16@i16[r1{row}, r2{column}] -> u8
        call @getBombCountAround@i16@i16
        ; const r3{t.9}, 0
        mov r8b, 0
        ; notequals r0{t.7}, r0{t.8}, r3{t.9}
        cmp al, r8b
        setne al
        ; branch r0{t.7}, true, @maybeRevealAround@i16@i16_ret, @if_32_end
        or al, al
        jnz @maybeRevealAround@i16@i16_ret
        ; const r0{dr}, -1
        mov ax, -1
        ; 190:2 for dr <= 1
        ; move r1{dr}, r0{dr}
        mov cx, ax
        jmp @for_33
@for_33_body:
        ; move r0{dr}, r1{dr}
        mov ax, cx
        ; move r1{r}, r6{row}
        mov cx, bx
        ; add r1{r}, r1{r}, r0{dr}
        add cx, ax
        ; const r3{dc}, -1
        mov r8w, -1
        ; 192:3 for dc <= 1
        ; addrof r7{memVarAddr}, dr
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r0{dr}
        mov [r12], ax
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{r}
        mov [r12], cx
        ; move r1{dc}, r3{dc}
        mov cx, r8w
        jmp @for_34
@for_34_body:
        ; move r3{dc}, r1{dc}
        mov r8w, cx
        ; addrof r7{memVarAddr}, dr
        lea r12, [rsp+48]
        ; load r0{dr}, [r7{memVarAddr}]
        mov ax, [r12]
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+50]
        ; load r1{r}, [r7{memVarAddr}]
        mov cx, [r12]
        ; 193:4 if dr == 0 && dc == 0
        ; 193:16 logic and
        ; const r4{t.15}, 0
        mov r9w, 0
        ; equals r4{t.14}, r0{dr}, r4{t.15}
        cmp ax, r9w
        sete r9b
        ; addrof r7{memVarAddr}, dr
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r0{dr}
        mov [r12], ax
        ; branch r4{t.14}, false, @and_next_36, @and_2nd_36
        or r9b, r9b
        jz @and_next_36
        ; const r0{t.16}, 0
        mov ax, 0
        ; equals r4{t.14}, r3{dc}, r0{t.16}
        cmp r8w, ax
        sete r9b
@and_next_36:
        ; branch r4{t.14}, false, @if_35_end, @no_critical_edge_17
        or r9b, r9b
        jz @if_35_end
        ; addrof r7{memVarAddr}, dc
        lea r12, [rsp+52]
        ; store [r7{memVarAddr}], r3{dc}
        mov [r12], r8w
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{r}
        mov [r12], cx
        jmp @for_34_continue
@if_35_end:
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+88]
        ; load r0{column}, [r7{memVarAddr}]
        mov ax, [r12]
        ; move r2{c}, r0{column}
        mov dx, ax
        ; addrof r7{memVarAddr}, column
        lea r12, [rsp+88]
        ; store [r7{memVarAddr}], r0{column}
        mov [r12], ax
        ; add r2{c}, r2{c}, r3{dc}
        add dx, r8w
        ; addrof r7{memVarAddr}, dc
        lea r12, [rsp+52]
        ; store [r7{memVarAddr}], r3{dc}
        mov [r12], r8w
        ; 198:4 if !checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=198:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=198:28]])
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{r}
        mov [r12], cx
        ; addrof r7{memVarAddr}, c
        lea r12, [rsp+54]
        ; store [r7{memVarAddr}], r2{c}
        mov [r12], dx
        ; call r0{t.18} = checkCellBounds@i16@i16[r1{r}, r2{c}] -> bool
        call @checkCellBounds@i16@i16
        ; notlog r0{t.17}, r0{t.18}
        or al, al
        sete al
        ; branch r0{t.17}, true, @for_34_continue, @if_37_end
        or al, al
        jnz @for_34_continue
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+50]
        ; load r1{r}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{r}
        mov [r12], cx
        ; addrof r7{memVarAddr}, c
        lea r12, [rsp+54]
        ; load r2{c}, [r7{memVarAddr}]
        mov dx, [r12]
        ; addrof r7{memVarAddr}, c
        lea r12, [rsp+54]
        ; store [r7{memVarAddr}], r2{c}
        mov [r12], dx
        ; call r0{cell} = getCell@i16@i16[r1{r}, r2{c}] -> u8
        call @getCell@i16@i16
        ; 203:4 if isOpen@u8([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=203:15]])
        ; move r1{cell}, r0{cell}
        mov cl, al
        ; addrof r7{memVarAddr}, cell
        lea r12, [rsp+56]
        ; store [r7{memVarAddr}], r0{cell}
        mov [r12], al
        ; call r0{t.19} = isOpen@u8[r1{cell}] -> bool
        call @isOpen@u8
        ; branch r0{t.19}, true, @for_34_continue, @if_38_end
        or al, al
        jnz @for_34_continue
        ; const r0{t.21}, 2
        mov al, 2
        ; addrof r7{memVarAddr}, cell
        lea r12, [rsp+56]
        ; load r4{cell}, [r7{memVarAddr}]
        mov r9b, [r12]
        ; move r3{t.20}, r4{cell}
        mov r8b, r9b
        ; or r3{t.20}, r3{t.20}, r0{t.21}
        or r8b, al
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+50]
        ; load r1{r}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{r}
        mov [r12], cx
        ; addrof r7{memVarAddr}, c
        lea r12, [rsp+54]
        ; load r2{c}, [r7{memVarAddr}]
        mov dx, [r12]
        ; addrof r7{memVarAddr}, c
        lea r12, [rsp+54]
        ; store [r7{memVarAddr}], r2{c}
        mov [r12], dx
        ; call setCell@i16@i16@u8[r1{r}, r2{c}, r3{t.20}]
        call @setCell@i16@i16@u8
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+50]
        ; load r1{r}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, r
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{r}
        mov [r12], cx
        ; addrof r7{memVarAddr}, c
        lea r12, [rsp+54]
        ; load r2{c}, [r7{memVarAddr}]
        mov dx, [r12]
        ; call maybeRevealAround@i16@i16[r1{r}, r2{c}]
        call @maybeRevealAround@i16@i16
@for_34_continue:
        ; const r0{t.22}, 1
        mov ax, 1
        ; addrof r7{memVarAddr}, dc
        lea r12, [rsp+52]
        ; load r1{dc}, [r7{memVarAddr}]
        mov cx, [r12]
        ; add r1{dc}, r1{dc}, r0{t.22}
        add cx, ax
@for_34:
        ; const r0{t.13}, 1
        mov ax, 1
        ; lteq r0{t.12}, r1{dc}, r0{t.13}
        cmp cx, ax
        setle al
        ; branch r0{t.12}, true, @for_34_body, @for_33_continue
        or al, al
        jnz @for_34_body
        ; const r0{t.23}, 1
        mov ax, 1
        ; addrof r7{memVarAddr}, dr
        lea r12, [rsp+48]
        ; load r1{dr}, [r7{memVarAddr}]
        mov cx, [r12]
        ; add r1{dr}, r1{dr}, r0{t.23}
        add cx, ax
@for_33:
        ; const r0{t.11}, 1
        mov ax, 1
        ; lteq r0{t.10}, r1{dr}, r0{t.11}
        cmp cx, ax
        setle al
        ; branch r0{t.10}, true, @for_33_body, @maybeRevealAround@i16@i16_ret
        or al, al
        jnz @for_33_body
@maybeRevealAround@i16@i16_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void main
        ;   rsp+48: var curr_c
        ;   rsp+50: var curr_r
        ;   rsp+52: var cell
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; const r6{tmp.__random__}, 0
        mov ebx, 0
        ; end initialize global variables
        ; const r1{t.5}, 7439742
        mov ecx, 7439742
        ; addrof r7{memVarAddr}, __random__
        lea r12, [var_0]
        ; store [r7{memVarAddr}], r6{tmp.__random__}
        mov [r12], ebx
        ; call initRandom@i32[r1{t.5}]
        call @initRandom@i32
        ; const r6{needsInitialize}, 1
        mov bl, 1
        ; call clearField[]
        call @clearField
        ; const r2{curr_c}, 20
        mov dx, 20
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r2{curr_c}
        mov [r12], dx
        ; const r1{curr_r}, 10
        mov cx, 10
        ; addrof r7{memVarAddr}, curr_r
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{curr_r}
        mov [r12], cx
        ; 219:2 while true
        jmp @while_39
@if_40_then:
        ; 222:4 if printLeft([])
        ; call r0{t.7} = printLeft[] -> bool
        call @printLeft
        ; branch r0{t.7}, true, @if_41_then, @if_40_end
        or al, al
        jnz @if_41_then
@if_40_end:
        ; call r0{chr} = getChar[] -> i16
        call @getChar
        ; 229:3 if chr == 27
        ; const r3{t.10}, 27
        mov r8w, 27
        ; equals r3{t.9}, r0{chr}, r3{t.10}
        cmp ax, r8w
        sete r8b
        ; branch r3{t.9}, true, @main_ret, @if_42_end
        or r8b, r8b
        jnz @main_ret
        ; 234:3 if chr == 13
        ; const r3{t.12}, 13
        mov r8w, 13
        ; equals r0{t.11}, r0{chr}, r3{t.12}
        cmp ax, r8w
        sete al
        ; branch r0{t.11}, false, @while_39, @if_43_then
        or al, al
        jz @while_39
        ; branch r6{needsInitialize}, false, @if_44_end, @if_44_then
        or bl, bl
        jz @if_44_end
        ; const r6{needsInitialize}, 0
        mov bl, 0
        ; addrof r7{memVarAddr}, curr_r
        lea r12, [rsp+50]
        ; load r1{curr_r}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+48]
        ; load r2{curr_c}, [r7{memVarAddr}]
        mov dx, [r12]
        ; addrof r7{memVarAddr}, curr_r
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{curr_r}
        mov [r12], cx
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r2{curr_c}
        mov [r12], dx
        ; call initField@i16@i16[r1{curr_r}, r2{curr_c}]
        call @initField@i16@i16
        ; addrof r7{memVarAddr}, curr_r
        lea r12, [rsp+50]
        ; load r1{curr_r}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+48]
        ; load r2{curr_c}, [r7{memVarAddr}]
        mov dx, [r12]
        ; addrof r7{memVarAddr}, curr_r
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{curr_r}
        mov [r12], cx
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r2{curr_c}
        mov [r12], dx
        ; call printField@i16@i16[r1{curr_r}, r2{curr_c}]
        call @printField@i16@i16
@if_44_end:
        ; addrof r7{memVarAddr}, curr_r
        lea r12, [rsp+50]
        ; load r1{curr_r}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+48]
        ; load r2{curr_c}, [r7{memVarAddr}]
        mov dx, [r12]
        ; addrof r7{memVarAddr}, curr_r
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{curr_r}
        mov [r12], cx
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r2{curr_c}
        mov [r12], dx
        ; call r0{cell} = getCell@i16@i16[r1{curr_r}, r2{curr_c}] -> u8
        call @getCell@i16@i16
        ; 241:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=241:16]])
        ; move r1{cell}, r0{cell}
        mov cl, al
        ; addrof r7{memVarAddr}, cell
        lea r12, [rsp+52]
        ; store [r7{memVarAddr}], r0{cell}
        mov [r12], al
        ; call r0{t.14} = isOpen@u8[r1{cell}] -> bool
        call @isOpen@u8
        ; notlog r0{t.13}, r0{t.14}
        or al, al
        sete al
        ; branch r0{t.13}, false, @if_45_end, @if_45_then
        or al, al
        jz @if_45_end
        ; const r0{t.16}, 2
        mov al, 2
        ; addrof r7{memVarAddr}, cell
        lea r12, [rsp+52]
        ; load r4{cell}, [r7{memVarAddr}]
        mov r9b, [r12]
        ; move r3{t.15}, r4{cell}
        mov r8b, r9b
        ; addrof r7{memVarAddr}, cell
        lea r12, [rsp+52]
        ; store [r7{memVarAddr}], r4{cell}
        mov [r12], r9b
        ; or r3{t.15}, r3{t.15}, r0{t.16}
        or r8b, al
        ; addrof r7{memVarAddr}, curr_r
        lea r12, [rsp+50]
        ; load r1{curr_r}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+48]
        ; load r2{curr_c}, [r7{memVarAddr}]
        mov dx, [r12]
        ; addrof r7{memVarAddr}, curr_r
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{curr_r}
        mov [r12], cx
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r2{curr_c}
        mov [r12], dx
        ; call setCell@i16@i16@u8[r1{curr_r}, r2{curr_c}, r3{t.15}]
        call @setCell@i16@i16@u8
@if_45_end:
        ; 244:4 if isBomb@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=244:15]])
        ; addrof r7{memVarAddr}, cell
        lea r12, [rsp+52]
        ; load r1{cell}, [r7{memVarAddr}]
        mov cl, [r12]
        ; call r0{t.17} = isBomb@u8[r1{cell}] -> bool
        call @isBomb@u8
        ; branch r0{t.17}, true, @if_46_then, @if_46_end
        or al, al
        jnz @if_46_then
        ; addrof r7{memVarAddr}, curr_r
        lea r12, [rsp+50]
        ; load r1{curr_r}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+48]
        ; load r2{curr_c}, [r7{memVarAddr}]
        mov dx, [r12]
        ; addrof r7{memVarAddr}, curr_r
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{curr_r}
        mov [r12], cx
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r2{curr_c}
        mov [r12], dx
        ; call maybeRevealAround@i16@i16[r1{curr_r}, r2{curr_c}]
        call @maybeRevealAround@i16@i16
@while_39:
        ; addrof r7{memVarAddr}, curr_r
        lea r12, [rsp+50]
        ; load r1{curr_r}, [r7{memVarAddr}]
        mov cx, [r12]
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+48]
        ; load r2{curr_c}, [r7{memVarAddr}]
        mov dx, [r12]
        ; addrof r7{memVarAddr}, curr_r
        lea r12, [rsp+50]
        ; store [r7{memVarAddr}], r1{curr_r}
        mov [r12], cx
        ; addrof r7{memVarAddr}, curr_c
        lea r12, [rsp+48]
        ; store [r7{memVarAddr}], r2{curr_c}
        mov [r12], dx
        ; call printField@i16@i16[r1{curr_r}, r2{curr_c}]
        call @printField@i16@i16
        ; 221:3 if !needsInitialize
        ; notlog r0{t.6}, r6{needsInitialize}
        or bl, bl
        sete al
        ; branch r0{t.6}, false, @if_40_end, @if_40_then
        or al, al
        jz @if_40_end
        jmp @if_40_then
@if_41_then:
        ; const r1{t.8}, [string-2]
        lea rcx, [string_2]
        ; call printString@@u8[r1{t.8}]
        call @printString@@u8
        jmp @main_ret
@if_46_then:
        ; const r1{t.18}, [string-3]
        lea rcx, [string_3]
        ; call printString@@u8[r1{t.18}]
        call @printString@@u8
@main_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength@@u8@i64
@printStringLength@@u8@i64:
        mov     rdi, rsp

        mov     r8, rdx
        mov     rdx, rcx
        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
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

        ; void setCursor@i16@i16
@setCursor@i16@i16:
        sub     rsp, 28h
        shl     rcx, 16
        movsxd  rcx, ecx
        movsx   rdx, dx
        add     rdx, rcx
        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        call   [SetConsoleCursorPosition]
        add     rsp, 28h
        ret

init:
        sub rsp, 28h
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
        add rsp, 28h
        ret

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8
        ; variable 0: __random__ (i32/4)
        var_0 rb 4
        ; variable 1: field[] (u8*/6400)
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
