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
        ; move str{r6}, str{r1}
        mov rbx, rcx
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; call length{r0} = strlen@@u8[str{r1}] -> i64
        call @strlen@@u8
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length{r2}, length{r0}
        mov rdx, rax
        ; call printStringLength@@u8@i64[str{r1}, length{r2}]
        call @printStringLength@@u8@i64
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printChar@u8
        ;   rsp+48: arg chr
@printChar@u8:
        sub rsp, 8
        sub rsp, 32
        ; move chr, chr{r1}
        lea r11, [rsp+48]
        mov [r11], cl
        ; addrof t.1{r1}, chr
        lea rcx, [rsp+48]
        ; const t.2{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1{r1}, t.2{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        add rsp, 8
        ret

        ; void printUint@i16
        ;   rsp+48: arg number
@printUint@i16:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1{r1}(i64), number{r1}(i16)
        movzx rcx, cx
        ; call printUint@i64[t.1{r1}]
        call @printUint@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+96: arg number
        ;   rsp+60: var buffer
@printUint@i64:
        sub rsp, 40
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const pos{r6}, 20
        mov bl, 20
        ; 25:2 while true
@while_1:
        ; const t.5{r7}, 1
        mov r12b, 1
        ; sub pos{r6}, pos{r6}, t.5{r7}
        sub bl, r12b
        ; const t.6{r7}, 10
        mov r12, 10
        ; move remainder{r3}, number{r1}
        mov r8, rcx
        ; move remainder{r0}, remainder{r3}
        mov rax, r8
        ; mod remainder{r2}, remainder{r0}, t.6{r7}
        cqo
        idiv r12
        ; move remainder{r3}, remainder{r2}
        mov r8, rdx
        ; const t.7{r7}, 10
        mov r12, 10
        ; move number{r0}, number{r1}
        mov rax, rcx
        ; div number{r0}, number{r0}, t.7{r7}
        cqo
        idiv r12
        ; move number{r1}, number{r0}
        mov rcx, rax
        ; cast t.8{r7}(u8), remainder{r3}(i64)
        mov r12b, r8b
        ; const t.9{r0}, 48
        mov al, 48
        ; add digit{r7}, digit{r7}, t.9{r0}
        add r12b, al
        ; cast t.11{r0}(i64), pos{r6}(u8)
        movzx rax, bl
        ; cast t.12{r0}(u8*), t.11{r0}(i64)
        ; addrof t.10{r3}, [buffer]
        lea r8, [rsp+60]
        ; add t.10{r3}, t.10{r3}, t.12{r0}
        add r8, rax
        ; store [t.10{r3}], digit{r7}
        mov [r8], r12b
        ; 31:3 if number == 0
        ; const t.14{r7}, 0
        mov r12, 0
        ; equals t.13{r7}, number{r1}, t.14{r7}
        cmp rcx, r12
        sete r12b
        ; branch t.13{r7}, false, @while_1, @while_1_break
        or r12b, r12b
        jz @while_1
        ; cast t.16{r7}(i64), pos{r6}(u8)
        movzx r12, bl
        ; cast t.17{r7}(u8*), t.16{r7}(i64)
        ; addrof t.15{r1}, [buffer]
        lea rcx, [rsp+60]
        ; add t.15{r1}, t.15{r1}, t.17{r7}
        add rcx, r12
        ; const t.19{r7}, 20
        mov r12b, 20
        ; move t.18{r2}, t.19{r7}
        mov dl, r12b
        ; sub t.18{r2}, t.18{r2}, pos{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.15{r1}, t.18{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 40
        ret

        ; i64 strlen@@u8
        ;   rsp+16: arg str
@strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 61:2 for *str != 0
        jmp @for_3
@for_3_body:
        ; const t.5{r2}, 1
        mov rdx, 1
        ; add length{r0}, length{r0}, t.5{r2}
        add rax, rdx
        ; cast t.7{r1}(i64), str{r1}(u8*)
        ; const t.8{r2}, 1
        mov rdx, 1
        ; add t.6{r1}, t.6{r1}, t.8{r2}
        add rcx, rdx
        ; cast str{r1}(u8*), t.6{r1}(i64)
@for_3:
        ; load t.3{r2}, [str{r1}]
        mov dl, [rcx]
        ; const t.4{r3}, 0
        mov r8b, 0
        ; notequals t.2{r2}, t.3{r2}, t.4{r3}
        cmp dl, r8b
        setne dl
        ; branch t.2{r2}, true, @for_3_body, @for_3_break
        or dl, dl
        jnz @for_3_body
        ; 64:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
@printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call @printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void initRandom@i32
        ;   rsp+16: arg salt
@initRandom@i32:
        sub rsp, 8
        ; move tmp.__random__{r0}, salt{r1}
        mov eax, ecx
        ; move __random__, tmp.__random__{r0}
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; i32 random
@random:
        sub rsp, 8
        ; move tmp.__random__{r0}, __random__
        lea r11, [var_0]
        mov eax, [r11]
        ; move r{r2}, tmp.__random__{r0}
        mov edx, eax
        ; const t.6{r3}, 524287
        mov r8d, 524287
        ; move t.5{r4}, r{r2}
        mov r9d, edx
        ; and t.5{r4}, t.5{r4}, t.6{r3}
        and r9d, r8d
        ; const t.7{r3}, 48271
        mov r8d, 48271
        ; mul b{r4}, b{r4}, t.7{r3}
        movsxd r9, r9d
        movsxd r8, r8d
        imul  r9, r8
        ; const t.9{r1}, 15
        mov ecx, 15
        ; shiftright t.8{r2}, t.8{r2}, t.9{r1}
        sar edx, cl
        ; const t.10{r3}, 48271
        mov r8d, 48271
        ; mul c{r2}, c{r2}, t.10{r3}
        movsxd rdx, edx
        movsxd r8, r8d
        imul  rdx, r8
        ; const t.12{r3}, 65535
        mov r8d, 65535
        ; move t.11{r5}, c{r2}
        mov r10d, edx
        ; and t.11{r5}, t.11{r5}, t.12{r3}
        and r10d, r8d
        ; const t.13{r1}, 15
        mov ecx, 15
        ; move d{r3}, t.11{r5}
        mov r8d, r10d
        ; shiftleft d{r3}, d{r3}, t.13{r1}
        sal r8d, cl
        ; const t.16{r1}, 16
        mov ecx, 16
        ; shiftright t.15{r2}, t.15{r2}, t.16{r1}
        sar edx, cl
        ; add t.14{r2}, t.14{r2}, b{r4}
        add edx, r9d
        ; add e{r2}, e{r2}, d{r3}
        add edx, r8d
        ; const t.18{r3}, 2147483647
        mov r8d, 2147483647
        ; move t.17{r4}, e{r2}
        mov r9d, edx
        ; and t.17{r4}, t.17{r4}, t.18{r3}
        and r9d, r8d
        ; const t.20{r1}, 31
        mov ecx, 31
        ; shiftright t.19{r2}, t.19{r2}, t.20{r1}
        sar edx, cl
        ; move tmp.__random__{r0}, t.17{r4}
        mov eax, r9d
        ; add tmp.__random__{r0}, tmp.__random__{r0}, t.19{r2}
        add eax, edx
        ; 151:9 return __random__
        ; move __random__, tmp.__random__{r0}
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; i16 rowColumnToCell@i16@i16
        ;   rsp+16: arg row
        ;   rsp+24: arg column
@rowColumnToCell@i16@i16:
        sub rsp, 8
        ; 15:21 return row * 40 + column
        ; const t.4{r3}, 40
        mov r8w, 40
        ; mul t.3{r1}, t.3{r1}, t.4{r3}
        movsx rcx, cx
        movsx r8, r8w
        imul  rcx, r8
        ; move t.2{r0}, t.3{r1}
        mov ax, cx
        ; add t.2{r0}, t.2{r0}, column{r2}
        add ax, dx
        add rsp, 8
        ret

        ; u8 getCell@i16@i16
        ;   rsp+48: arg row
        ;   rsp+56: arg column
@getCell@i16@i16:
        sub rsp, 8
        sub rsp, 32
        ; 19:15 return [...]
        ; call t.5{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call @rowColumnToCell@i16@i16
        ; cast t.4{r1}(i64), t.5{r0}(i16)
        movzx rcx, ax
        ; cast t.6{r1}(u8*), t.4{r1}(i64)
        ; addrof t.3{r2}, [field]
        lea rdx, [var_1]
        ; add t.3{r2}, t.3{r2}, t.6{r1}
        add rdx, rcx
        ; load t.2{r0}, [t.3{r2}]
        mov al, [rdx]
        add rsp, 32
        add rsp, 8
        ret

        ; bool isBomb@u8
        ;   rsp+16: arg cell
@isBomb@u8:
        sub rsp, 8
        ; 23:27 return cell & 1 != 0
        ; const t.3{r2}, 1
        mov dl, 1
        ; and t.2{r1}, t.2{r1}, t.3{r2}
        and cl, dl
        ; const t.4{r2}, 0
        mov dl, 0
        ; notequals t.1{r0}, t.2{r1}, t.4{r2}
        cmp cl, dl
        setne al
        add rsp, 8
        ret

        ; bool isOpen@u8
        ;   rsp+16: arg cell
@isOpen@u8:
        sub rsp, 8
        ; 27:27 return cell & 2 != 0
        ; const t.3{r2}, 2
        mov dl, 2
        ; and t.2{r1}, t.2{r1}, t.3{r2}
        and cl, dl
        ; const t.4{r2}, 0
        mov dl, 0
        ; notequals t.1{r0}, t.2{r1}, t.4{r2}
        cmp cl, dl
        setne al
        add rsp, 8
        ret

        ; bool isFlag@u8
        ;   rsp+16: arg cell
@isFlag@u8:
        sub rsp, 8
        ; 31:27 return cell & 4 != 0
        ; const t.3{r2}, 4
        mov dl, 4
        ; and t.2{r1}, t.2{r1}, t.3{r2}
        and cl, dl
        ; const t.4{r2}, 0
        mov dl, 0
        ; notequals t.1{r0}, t.2{r1}, t.4{r2}
        cmp cl, dl
        setne al
        add rsp, 8
        ret

        ; bool checkCellBounds@i16@i16
        ;   rsp+16: arg row
        ;   rsp+24: arg column
@checkCellBounds@i16@i16:
        sub rsp, 8
        ; 36:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 36:21 logic and
        ; 36:6 logic and
        ; 35:21 logic and
        ; const t.3{r3}, 0
        mov r8w, 0
        ; gteq t.2{r0}, row{r1}, t.3{r3}
        cmp cx, r8w
        setge al
        ; branch t.2{r0}, false, @and_next_6, @and_2nd_6
        or al, al
        jz @and_next_6
        ; const t.4{r3}, 20
        mov r8w, 20
        ; lt t.2{r0}, row{r1}, t.4{r3}
        cmp cx, r8w
        setl al
@and_next_6:
        ; branch t.2{r0}, false, @and_next_5, @and_2nd_5
        or al, al
        jz @and_next_5
        ; const t.5{r1}, 0
        mov cx, 0
        ; gteq t.2{r0}, column{r2}, t.5{r1}
        cmp dx, cx
        setge al
@and_next_5:
        ; branch t.2{r0}, false, @checkCellBounds@i16@i16_ret, @and_2nd_4
        or al, al
        jz @checkCellBounds@i16@i16_ret
        ; const t.6{r1}, 40
        mov cx, 40
        ; lt t.2{r0}, column{r2}, t.6{r1}
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
        ; move cell{r6}, cell{r3}
        mov bl, r8b
        ; call t.5{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call @rowColumnToCell@i16@i16
        ; cast t.4{r0}(i64), t.5{r0}(i16)
        movzx rax, ax
        ; cast t.6{r0}(u8*), t.4{r0}(i64)
        ; addrof t.3{r1}, [field]
        lea rcx, [var_1]
        ; add t.3{r1}, t.3{r1}, t.6{r0}
        add rcx, rax
        ; store [t.3{r1}], cell{r6}
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
        ; move row{r6}, row{r1}
        mov bx, cx
        ; move column{r7}, column{r2}
        mov r12w, dx
        ; const count{r0}, 0
        mov al, 0
        ; move count, count{r0}
        lea r11, [rsp+48]
        mov [r11], al
        ; const dr{r0}, -1
        mov ax, -1
        ; 45:2 for dr <= 1
        ; move dr{r2}, dr{r0}
        mov dx, ax
        ; move count{r0}, count
        lea r11, [rsp+48]
        mov al, [r11]
        jmp @for_7
@for_7_body:
        ; move count, count{r0}
        lea r11, [rsp+48]
        mov [r11], al
        ; move dr{r0}, dr{r2}
        mov ax, dx
        ; move r{r1}, row{r6}
        mov cx, bx
        ; add r{r1}, r{r1}, dr{r0}
        add cx, ax
        ; move dr, dr{r0}
        lea r11, [rsp+50]
        mov [r11], ax
        ; const dc{r0}, -1
        mov ax, -1
        ; 47:3 for dc <= 1
        ; move r, r{r1}
        lea r11, [rsp+52]
        mov [r11], cx
        ; move dc{r2}, dc{r0}
        mov dx, ax
        ; move count{r0}, count
        lea r11, [rsp+48]
        mov al, [r11]
        jmp @for_8
@for_8_body:
        ; move count, count{r0}
        lea r11, [rsp+48]
        mov [r11], al
        ; move dc{r0}, dc{r2}
        mov ax, dx
        ; move r{r1}, r
        lea r11, [rsp+52]
        mov cx, [r11]
        ; move c{r2}, column{r7}
        mov dx, r12w
        ; add c{r2}, c{r2}, dc{r0}
        add dx, ax
        ; move dc, dc{r0}
        lea r11, [rsp+54]
        mov [r11], ax
        ; 49:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=49:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=49:27]])
        ; move r, r{r1}
        lea r11, [rsp+52]
        mov [r11], cx
        ; move c, c{r2}
        lea r11, [rsp+56]
        mov [r11], dx
        ; call t.12{r0} = checkCellBounds@i16@i16[r{r1}, c{r2}] -> bool
        call @checkCellBounds@i16@i16
        ; branch t.12{r0}, true, @if_9_then, @no_critical_edge_11
        or al, al
        jnz @if_9_then
        ; move count{r0}, count
        lea r11, [rsp+48]
        mov al, [r11]
        jmp @for_8_continue
@if_9_then:
        ; move r{r1}, r
        lea r11, [rsp+52]
        mov cx, [r11]
        ; move r, r{r1}
        lea r11, [rsp+52]
        mov [r11], cx
        ; move c{r2}, c
        lea r11, [rsp+56]
        mov dx, [r11]
        ; call cell{r0} = getCell@i16@i16[r{r1}, c{r2}] -> u8
        call @getCell@i16@i16
        ; 51:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=51:16]])
        ; move cell{r1}, cell{r0}
        mov cl, al
        ; call t.13{r0} = isBomb@u8[cell{r1}] -> bool
        call @isBomb@u8
        ; branch t.13{r0}, true, @if_10_then, @no_critical_edge_12
        or al, al
        jnz @if_10_then
        ; move count{r0}, count
        lea r11, [rsp+48]
        mov al, [r11]
        jmp @for_8_continue
@if_10_then:
        ; const t.14{r1}, 1
        mov cl, 1
        ; move count{r0}, count
        lea r11, [rsp+48]
        mov al, [r11]
        ; add count{r0}, count{r0}, t.14{r1}
        add al, cl
@for_8_continue:
        ; const t.15{r1}, 1
        mov cx, 1
        ; move dc{r2}, dc
        lea r11, [rsp+54]
        mov dx, [r11]
        ; add dc{r2}, dc{r2}, t.15{r1}
        add dx, cx
@for_8:
        ; const t.11{r1}, 1
        mov cx, 1
        ; lteq t.10{r1}, dc{r2}, t.11{r1}
        cmp dx, cx
        setle cl
        ; branch t.10{r1}, true, @for_8_body, @for_7_continue
        or cl, cl
        jnz @for_8_body
        ; const t.16{r1}, 1
        mov cx, 1
        ; move dr{r2}, dr
        lea r11, [rsp+50]
        mov dx, [r11]
        ; add dr{r2}, dr{r2}, t.16{r1}
        add dx, cx
@for_7:
        ; const t.9{r1}, 1
        mov cx, 1
        ; lteq t.8{r1}, dr{r2}, t.9{r1}
        cmp dx, cx
        setle cl
        ; branch t.8{r1}, true, @for_7_body, @for_7_break
        or cl, cl
        jnz @for_7_body
        ; 57:9 return count
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
        ; 61:2 if rowCursor == row
        ; equals t.4{r1}, rowCursor{r3}, row{r1}
        cmp r8w, cx
        sete cl
        ; branch t.4{r1}, false, @if_11_end, @if_11_then
        or cl, cl
        jz @if_11_end
        ; 62:3 if columnCursor == column
        ; equals t.5{r1}, columnCursor{r4}, column{r2}
        cmp r9w, dx
        sete cl
        ; branch t.5{r1}, true, @if_12_then, @if_12_end
        or cl, cl
        jnz @if_12_then
        ; 65:3 if columnCursor == column - 1
        ; const t.9{r1}, 1
        mov cx, 1
        ; sub t.8{r2}, t.8{r2}, t.9{r1}
        sub dx, cx
        ; equals t.7{r1}, columnCursor{r4}, t.8{r2}
        cmp r9w, dx
        sete cl
        ; branch t.7{r1}, false, @if_11_end, @if_13_then
        or cl, cl
        jz @if_11_end
        jmp @if_13_then
@if_12_then:
        ; 63:11 return 91
        ; const t.6{r0}, 91
        mov al, 91
        jmp @getSpacer@i16@i16@i16@i16_ret
@if_13_then:
        ; 66:11 return 93
        ; const t.10{r1}, 93
        mov cl, 93
        ; move t.10{r0}, t.10{r1}
        mov al, cl
        jmp @getSpacer@i16@i16@i16@i16_ret
@if_11_end:
        ; 69:9 return 32
        ; const t.11{r1}, 32
        mov cl, 32
        ; move t.11{r0}, t.11{r1}
        mov al, cl
@getSpacer@i16@i16@i16@i16_ret:
        add rsp, 8
        ret

        ; void printCell@u8@i16@i16
        ;   rsp+64: arg cell
        ;   rsp+72: arg row
        ;   rsp+80: arg column
        ;   rsp+48: var chr
@printCell@u8@i16@i16:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move cell{r6}, cell{r1}
        mov bl, cl
        ; move row{r7}, row{r2}
        mov r12w, dx
        ; move column, column{r3}
        lea r11, [rsp+80]
        mov [r11], r8w
        ; const chr{r1}, 46
        mov cl, 46
        ; move chr, chr{r1}
        lea r11, [rsp+48]
        mov [r11], cl
        ; 74:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=74:13]])
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; call t.5{r0} = isOpen@u8[cell{r1}] -> bool
        call @isOpen@u8
        ; branch t.5{r0}, true, @if_14_then, @no_critical_edge_10
        or al, al
        jnz @if_14_then
        ; move chr{r7}, chr
        lea r11, [rsp+48]
        mov r12b, [r11]
        jmp @if_14_else
@if_14_then:
        ; 75:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:14]])
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; call t.6{r0} = isBomb@u8[cell{r1}] -> bool
        call @isBomb@u8
        ; branch t.6{r0}, true, @if_15_then, @if_15_else
        or al, al
        jnz @if_15_then
        ; move row{r1}, row{r7}
        mov cx, r12w
        ; move column{r2}, column
        lea r11, [rsp+80]
        mov dx, [r11]
        ; call count{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call @getBombCountAround@i16@i16
        ; 80:4 if count > 0
        ; const t.8{r7}, 0
        mov r12b, 0
        ; gt t.7{r7}, count{r0}, t.8{r7}
        cmp al, r12b
        seta r12b
        ; branch t.7{r7}, false, @if_16_else, @if_16_then
        or r12b, r12b
        jz @if_16_else
        jmp @if_16_then
@if_15_then:
        ; const chr{r7}, 42
        mov r12b, 42
        jmp @if_14_end
@if_16_else:
        ; const chr{r7}, 32
        mov r12b, 32
        jmp @if_14_else
@if_16_then:
        ; const t.9{r6}, 48
        mov bl, 48
        ; move chr{r7}, count{r0}
        mov r12b, al
        ; add chr{r7}, chr{r7}, t.9{r6}
        add r12b, bl
        jmp @if_14_end
@if_14_else:
        ; 88:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=88:18]])
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; call t.10{r0} = isFlag@u8[cell{r1}] -> bool
        call @isFlag@u8
        ; branch t.10{r0}, false, @if_14_end, @if_17_then
        or al, al
        jz @if_14_end
        ; const chr{r7}, 35
        mov r12b, 35
@if_14_end:
        ; move chr{r1}, chr{r7}
        mov cl, r12b
        ; call printChar@u8[chr{r1}]
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
        ; move rowCursor{r6}, rowCursor{r1}
        mov bx, cx
        ; move columnCursor{r7}, columnCursor{r2}
        mov r12w, dx
        ; const t.7{r1}, 0
        mov cx, 0
        ; const t.8{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[t.7{r1}, t.8{r2}]
        call @setCursor@i16@i16
        ; const row{r1}, 0
        mov cx, 0
        ; move row, row{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; 96:2 for row < 20
        ; move row{r1}, row
        lea r11, [rsp+48]
        mov cx, [r11]
        jmp @for_18
@for_18_body:
        ; move row, row{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; const t.11{r1}, 124
        mov cl, 124
        ; call printChar@u8[t.11{r1}]
        call @printChar@u8
        ; const column{r2}, 0
        mov dx, 0
        ; 98:3 for column < 40
        ; move column{r5}, column{r2}
        mov r10w, dx
        jmp @for_19
@for_19_body:
        ; move row{r1}, row
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move column{r2}, column{r5}
        mov dx, r10w
        ; move row, row{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move column, column{r2}
        lea r11, [rsp+50]
        mov [r11], dx
        ; move rowCursor{r3}, rowCursor{r6}
        mov r8w, bx
        ; move columnCursor{r4}, columnCursor{r7}
        mov r9w, r12w
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r1}, column{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call @getSpacer@i16@i16@i16@i16
        ; move spacer{r1}, spacer{r0}
        mov cl, al
        ; call printChar@u8[spacer{r1}]
        call @printChar@u8
        ; move row{r1}, row
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move row, row{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move column{r2}, column
        lea r11, [rsp+50]
        mov dx, [r11]
        ; move column, column{r2}
        lea r11, [rsp+50]
        mov [r11], dx
        ; call cell{r0} = getCell@i16@i16[row{r1}, column{r2}] -> u8
        call @getCell@i16@i16
        ; move cell{r1}, cell{r0}
        mov cl, al
        ; move row{r2}, row
        lea r11, [rsp+48]
        mov dx, [r11]
        ; move row, row{r2}
        lea r11, [rsp+48]
        mov [r11], dx
        ; move column{r3}, column
        lea r11, [rsp+50]
        mov r8w, [r11]
        ; move column, column{r3}
        lea r11, [rsp+50]
        mov [r11], r8w
        ; call printCell@u8@i16@i16[cell{r1}, row{r2}, column{r3}]
        call @printCell@u8@i16@i16
        ; const t.14{r0}, 1
        mov ax, 1
        ; move column{r5}, column
        lea r11, [rsp+50]
        mov r10w, [r11]
        ; add column{r5}, column{r5}, t.14{r0}
        add r10w, ax
@for_19:
        ; const t.13{r0}, 40
        mov ax, 40
        ; lt t.12{r0}, column{r5}, t.13{r0}
        cmp r10w, ax
        setl al
        ; branch t.12{r0}, true, @for_19_body, @for_19_break
        or al, al
        jnz @for_19_body
        ; const t.15{r2}, 40
        mov dx, 40
        ; move row{r1}, row
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move row, row{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move rowCursor{r3}, rowCursor{r6}
        mov r8w, bx
        ; move columnCursor{r4}, columnCursor{r7}
        mov r9w, r12w
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r1}, t.15{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call @getSpacer@i16@i16@i16@i16
        ; move spacer{r1}, spacer{r0}
        mov cl, al
        ; call printChar@u8[spacer{r1}]
        call @printChar@u8
        ; const t.16{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.16{r1}]
        call @printString@@u8
        ; const t.17{r0}, 1
        mov ax, 1
        ; move row{r1}, row
        lea r11, [rsp+48]
        mov cx, [r11]
        ; add row{r1}, row{r1}, t.17{r0}
        add cx, ax
@for_18:
        ; const t.10{r0}, 20
        mov ax, 20
        ; lt t.9{r0}, row{r1}, t.10{r0}
        cmp cx, ax
        setl al
        ; branch t.9{r0}, true, @for_18_body, @printField@i16@i16_ret
        or al, al
        jnz @for_18_body
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
        ; move i{r6}, i{r1}
        mov bx, cx
        ; 111:2 for i > 0
        jmp @for_20
@for_20_body:
        ; const t.3{r1}, 48
        mov cl, 48
        ; call printChar@u8[t.3{r1}]
        call @printChar@u8
        ; const t.4{r0}, 1
        mov ax, 1
        ; sub i{r6}, i{r6}, t.4{r0}
        sub bx, ax
@for_20:
        ; const t.2{r0}, 0
        mov ax, 0
        ; gt t.1{r0}, i{r6}, t.2{r0}
        cmp bx, ax
        setg al
        ; branch t.1{r0}, true, @for_20_body, @printSpaces@i16_ret
        or al, al
        jnz @for_20_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; u8 getDigitCount@i16
        ;   rsp+16: arg value
@getDigitCount@i16:
        sub rsp, 8
        ; const count{r3}, 0
        mov r8b, 0
        ; 118:2 if value < 0
        ; const t.3{r4}, 0
        mov r9w, 0
        ; lt t.2{r4}, value{r1}, t.3{r4}
        cmp cx, r9w
        setl r9b
        ; branch t.2{r4}, false, @while_22, @if_21_then
        or r9b, r9b
        jz @while_22
        ; const count{r3}, 1
        mov r8b, 1
        ; neg value{r1}, value{r1}
        neg rcx
@while_22:
        ; const t.4{r4}, 1
        mov r9b, 1
        ; add count{r3}, count{r3}, t.4{r4}
        add r8b, r9b
        ; const t.5{r4}, 10
        mov r9w, 10
        ; move value{r0}, value{r1}
        mov ax, cx
        ; div value{r0}, value{r0}, t.5{r4}
        movsx rax, ax
        movsx r9, r9w
        cqo
        idiv r9
        ; move value{r1}, value{r0}
        mov cx, ax
        ; 126:3 if value == 0
        ; const t.7{r2}, 0
        mov dx, 0
        ; equals t.6{r2}, value{r1}, t.7{r2}
        cmp cx, dx
        sete dl
        ; branch t.6{r2}, false, @while_22, @while_22_break
        or dl, dl
        jz @while_22
        ; 131:9 return count
        ; move count{r0}, count{r3}
        mov al, r8b
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+48: var c
@getHiddenCount:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const count{r6}, 0
        mov bx, 0
        ; const r{r7}, 0
        mov r12w, 0
        ; 136:2 for r < 20
        jmp @for_24
@for_24_body:
        ; const c{r2}, 0
        mov dx, 0
        ; 137:3 for c < 40
        jmp @for_25
@for_25_body:
        ; move r{r1}, r{r7}
        mov cx, r12w
        ; move c, c{r2}
        lea r11, [rsp+48]
        mov [r11], dx
        ; call cell{r0} = getCell@i16@i16[r{r1}, c{r2}] -> u8
        call @getCell@i16@i16
        ; 139:4 if cell & 6 == 0
        ; const t.10{r1}, 6
        mov cl, 6
        ; move t.9{r2}, cell{r0}
        mov dl, al
        ; and t.9{r2}, t.9{r2}, t.10{r1}
        and dl, cl
        ; const t.11{r1}, 0
        mov cl, 0
        ; equals t.8{r1}, t.9{r2}, t.11{r1}
        cmp dl, cl
        sete cl
        ; branch t.8{r1}, false, @for_25_continue, @if_26_then
        or cl, cl
        jz @for_25_continue
        ; const t.12{r1}, 1
        mov cx, 1
        ; add count{r6}, count{r6}, t.12{r1}
        add bx, cx
@for_25_continue:
        ; const t.13{r1}, 1
        mov cx, 1
        ; move c{r2}, c
        lea r11, [rsp+48]
        mov dx, [r11]
        ; add c{r2}, c{r2}, t.13{r1}
        add dx, cx
@for_25:
        ; const t.7{r1}, 40
        mov cx, 40
        ; lt t.6{r1}, c{r2}, t.7{r1}
        cmp dx, cx
        setl cl
        ; branch t.6{r1}, true, @for_25_body, @for_24_continue
        or cl, cl
        jnz @for_25_body
        ; const t.14{r1}, 1
        mov cx, 1
        ; add r{r7}, r{r7}, t.14{r1}
        add r12w, cx
@for_24:
        ; const t.5{r1}, 20
        mov cx, 20
        ; lt t.4{r1}, r{r7}, t.5{r1}
        cmp r12w, cx
        setl cl
        ; branch t.4{r1}, true, @for_24_body, @for_24_break
        or cl, cl
        jnz @for_24_body
        ; 144:9 return count
        ; move count{r0}, count{r6}
        mov ax, bx
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; bool printLeft
        ;   rsp+48: var bombDigits
@printLeft:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; call count{r0} = getHiddenCount[] -> i16
        call @getHiddenCount
        ; move count{r6}, count{r0}
        mov bx, ax
        ; move count{r1}, count{r6}
        mov cx, bx
        ; call t.3{r0} = getDigitCount@i16[count{r1}] -> u8
        call @getDigitCount@i16
        ; cast leftDigits{r7}(i16), t.3{r0}(u8)
        movzx r12w, al
        ; const t.5{r1}, 40
        mov cx, 40
        ; call t.4{r0} = getDigitCount@i16[t.5{r1}] -> u8
        call @getDigitCount@i16
        ; cast bombDigits{r0}(i16), t.4{r0}(u8)
        movzx ax, al
        ; move bombDigits, bombDigits{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; const t.6{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[t.6{r1}]
        call @printString@@u8
        ; move bombDigits{r0}, bombDigits
        lea r11, [rsp+48]
        mov ax, [r11]
        ; move t.7{r1}, bombDigits{r0}
        mov cx, ax
        ; sub t.7{r1}, t.7{r1}, leftDigits{r7}
        sub cx, r12w
        ; call printSpaces@i16[t.7{r1}]
        call @printSpaces@i16
        ; move count{r1}, count{r6}
        mov cx, bx
        ; call printUint@i16[count{r1}]
        call @printUint@i16
        ; 155:15 return count == 0
        ; const t.9{r1}, 0
        mov cx, 0
        ; equals t.8{r0}, count{r6}, t.9{r1}
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
        ; 159:2 if a < 0
        ; const t.2{r2}, 0
        mov dx, 0
        ; lt t.1{r2}, a{r1}, t.2{r2}
        cmp cx, dx
        setl dl
        ; branch t.1{r2}, true, @if_27_then, @if_27_end
        or dl, dl
        jnz @if_27_then
        ; 162:9 return a
        ; move a{r0}, a{r1}
        mov ax, cx
        jmp @abs@i16_ret
@if_27_then:
        ; 160:10 return -a
        ; neg t.3{r1}, a{r1}
        neg rcx
        ; move t.3{r0}, t.3{r1}
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
        ; const r{r6}, 0
        mov bx, 0
        ; 166:2 for r < 20
        jmp @for_28
@for_28_body:
        ; const c{r7}, 0
        mov r12w, 0
        ; 167:3 for c < 40
        jmp @for_29
@for_29_body:
        ; const t.6{r3}, 0
        mov r8b, 0
        ; move r{r1}, r{r6}
        mov cx, bx
        ; move c{r2}, c{r7}
        mov dx, r12w
        ; call setCell@i16@i16@u8[r{r1}, c{r2}, t.6{r3}]
        call @setCell@i16@i16@u8
        ; const t.7{r0}, 1
        mov ax, 1
        ; add c{r7}, c{r7}, t.7{r0}
        add r12w, ax
@for_29:
        ; const t.5{r0}, 40
        mov ax, 40
        ; lt t.4{r0}, c{r7}, t.5{r0}
        cmp r12w, ax
        setl al
        ; branch t.4{r0}, true, @for_29_body, @for_28_continue
        or al, al
        jnz @for_29_body
        ; const t.8{r0}, 1
        mov ax, 1
        ; add r{r6}, r{r6}, t.8{r0}
        add bx, ax
@for_28:
        ; const t.3{r0}, 20
        mov ax, 20
        ; lt t.2{r0}, r{r6}, t.3{r0}
        cmp bx, ax
        setl al
        ; branch t.2{r0}, true, @for_28_body, @clearField_ret
        or al, al
        jnz @for_28_body
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
        ; move curr_r{r6}, curr_r{r1}
        mov bx, cx
        ; move curr_c{r7}, curr_c{r2}
        mov r12w, dx
        ; const bombs{r0}, 40
        mov ax, 40
        ; move bombs, bombs{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; 174:2 for bombs > 0
        ; move bombs{r1}, bombs
        lea r11, [rsp+48]
        mov cx, [r11]
        jmp @for_30
@for_30_body:
        ; move bombs, bombs{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; call t.8{r0} = random[] -> i32
        call @random
        ; const t.9{r1}, 20
        mov ecx, 20
        ; move t.7{r3}, t.8{r0}
        mov r8d, eax
        ; move t.7{r0}, t.7{r3}
        mov eax, r8d
        ; mod t.7{r2}, t.7{r0}, t.9{r1}
        movsxd rax, eax
        movsxd rcx, ecx
        cqo
        idiv rcx
        ; move t.7{r3}, t.7{r2}
        mov r8d, edx
        ; cast row{r1}(i16), t.7{r3}(i32)
        mov cx, r8w
        ; move row, row{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; call t.11{r0} = random[] -> i32
        call @random
        ; const t.12{r3}, 40
        mov r8d, 40
        ; move t.10{r4}, t.11{r0}
        mov r9d, eax
        ; move t.10{r0}, t.10{r4}
        mov eax, r9d
        ; mod t.10{r2}, t.10{r0}, t.12{r3}
        movsxd rax, eax
        movsxd r8, r8d
        cqo
        idiv r8
        ; move t.10{r4}, t.10{r2}
        mov r9d, edx
        ; cast column{r2}(i16), t.10{r4}(i32)
        mov dx, r9w
        ; move column, column{r2}
        lea r11, [rsp+52]
        mov [r11], dx
        ; 177:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=177:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=177:20], location=177:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1
        ; 178:4 logic or
        ; move row{r0}, row
        lea r11, [rsp+50]
        mov ax, [r11]
        ; move t.15{r1}, row{r0}
        mov cx, ax
        ; move row, row{r0}
        lea r11, [rsp+50]
        mov [r11], ax
        ; sub t.15{r1}, t.15{r1}, curr_r{r6}
        sub cx, bx
        ; call t.14{r0} = abs@i16[t.15{r1}] -> i16
        call @abs@i16
        ; const t.16{r2}, 1
        mov dx, 1
        ; gt t.13{r0}, t.14{r0}, t.16{r2}
        cmp ax, dx
        setg al
        ; branch t.13{r0}, true, @no_critical_edge_8, @or_2nd_32
        or al, al
        jnz @no_critical_edge_8
        ; move t.13, t.13{r0}
        lea r11, [rsp+54]
        mov [r11], al
        jmp @or_2nd_32
@no_critical_edge_8:
        ; move t.13, t.13{r0}
        lea r11, [rsp+54]
        mov [r11], al
        ; move t.13{r0}, t.13
        lea r11, [rsp+54]
        mov al, [r11]
        jmp @or_next_32
@or_2nd_32:
        ; move column{r0}, column
        lea r11, [rsp+52]
        mov ax, [r11]
        ; move t.18{r1}, column{r0}
        mov cx, ax
        ; move column, column{r0}
        lea r11, [rsp+52]
        mov [r11], ax
        ; sub t.18{r1}, t.18{r1}, curr_c{r7}
        sub cx, r12w
        ; call t.17{r0} = abs@i16[t.18{r1}] -> i16
        call @abs@i16
        ; const t.19{r4}, 1
        mov r9w, 1
        ; gt t.13{r0}, t.17{r0}, t.19{r4}
        cmp ax, r9w
        setg al
@or_next_32:
        ; branch t.13{r0}, false, @for_30_continue, @if_31_then
        or al, al
        jz @for_30_continue
        ; const t.20{r3}, 1
        mov r8b, 1
        ; move row{r1}, row
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move column{r2}, column
        lea r11, [rsp+52]
        mov dx, [r11]
        ; call setCell@i16@i16@u8[row{r1}, column{r2}, t.20{r3}]
        call @setCell@i16@i16@u8
@for_30_continue:
        ; const t.21{r0}, 1
        mov ax, 1
        ; move bombs{r1}, bombs
        lea r11, [rsp+48]
        mov cx, [r11]
        ; sub bombs{r1}, bombs{r1}, t.21{r0}
        sub cx, ax
@for_30:
        ; const t.6{r0}, 0
        mov ax, 0
        ; gt t.5{r0}, bombs{r1}, t.6{r0}
        cmp cx, ax
        setg al
        ; branch t.5{r0}, true, @for_30_body, @initField@i16@i16_ret
        or al, al
        jnz @for_30_body
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
        ; move row{r6}, row{r1}
        mov bx, cx
        ; move column{r7}, column{r2}
        mov r12w, dx
        ; 185:2 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=185:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=185:30]]) != 0
        ; move row{r1}, row{r6}
        mov cx, bx
        ; move column{r2}, column{r7}
        mov dx, r12w
        ; call t.8{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call @getBombCountAround@i16@i16
        ; const t.9{r3}, 0
        mov r8b, 0
        ; notequals t.7{r0}, t.8{r0}, t.9{r3}
        cmp al, r8b
        setne al
        ; branch t.7{r0}, true, @maybeRevealAround@i16@i16_ret, @if_33_end
        or al, al
        jnz @maybeRevealAround@i16@i16_ret
        ; const dr{r0}, -1
        mov ax, -1
        ; 189:2 for dr <= 1
        ; move dr{r1}, dr{r0}
        mov cx, ax
        jmp @for_34
@for_34_body:
        ; move dr{r0}, dr{r1}
        mov ax, cx
        ; move r{r1}, row{r6}
        mov cx, bx
        ; add r{r1}, r{r1}, dr{r0}
        add cx, ax
        ; const dc{r3}, -1
        mov r8w, -1
        ; 191:3 for dc <= 1
        ; move dr, dr{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; move r, r{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move dc{r1}, dc{r3}
        mov cx, r8w
        jmp @for_35
@for_35_body:
        ; move dc{r3}, dc{r1}
        mov r8w, cx
        ; move dr{r0}, dr
        lea r11, [rsp+48]
        mov ax, [r11]
        ; move r{r1}, r
        lea r11, [rsp+50]
        mov cx, [r11]
        ; 192:4 if dr == 0 && dc == 0
        ; 192:16 logic and
        ; const t.15{r4}, 0
        mov r9w, 0
        ; equals t.14{r4}, dr{r0}, t.15{r4}
        cmp ax, r9w
        sete r9b
        ; move dr, dr{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; branch t.14{r4}, false, @and_next_37, @and_2nd_37
        or r9b, r9b
        jz @and_next_37
        ; const t.16{r0}, 0
        mov ax, 0
        ; equals t.14{r4}, dc{r3}, t.16{r0}
        cmp r8w, ax
        sete r9b
@and_next_37:
        ; branch t.14{r4}, false, @if_36_end, @no_critical_edge_17
        or r9b, r9b
        jz @if_36_end
        ; move dc, dc{r3}
        lea r11, [rsp+52]
        mov [r11], r8w
        ; move r, r{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        jmp @for_35_continue
@if_36_end:
        ; move c{r2}, column{r7}
        mov dx, r12w
        ; add c{r2}, c{r2}, dc{r3}
        add dx, r8w
        ; move dc, dc{r3}
        lea r11, [rsp+52]
        mov [r11], r8w
        ; 197:4 if !checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=197:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=197:28]])
        ; move r, r{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c, c{r2}
        lea r11, [rsp+54]
        mov [r11], dx
        ; call t.18{r0} = checkCellBounds@i16@i16[r{r1}, c{r2}] -> bool
        call @checkCellBounds@i16@i16
        ; notlog t.17{r0}, t.18{r0}
        or al, al
        sete al
        ; branch t.17{r0}, true, @for_35_continue, @if_38_end
        or al, al
        jnz @for_35_continue
        ; move r{r1}, r
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move r, r{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c{r2}, c
        lea r11, [rsp+54]
        mov dx, [r11]
        ; move c, c{r2}
        lea r11, [rsp+54]
        mov [r11], dx
        ; call cell{r0} = getCell@i16@i16[r{r1}, c{r2}] -> u8
        call @getCell@i16@i16
        ; 202:4 if isOpen@u8([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=202:15]])
        ; move cell{r1}, cell{r0}
        mov cl, al
        ; move cell, cell{r0}
        lea r11, [rsp+56]
        mov [r11], al
        ; call t.19{r0} = isOpen@u8[cell{r1}] -> bool
        call @isOpen@u8
        ; branch t.19{r0}, true, @for_35_continue, @if_39_end
        or al, al
        jnz @for_35_continue
        ; const t.21{r0}, 2
        mov al, 2
        ; move cell{r4}, cell
        lea r11, [rsp+56]
        mov r9b, [r11]
        ; move t.20{r3}, cell{r4}
        mov r8b, r9b
        ; or t.20{r3}, t.20{r3}, t.21{r0}
        or r8b, al
        ; move r{r1}, r
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move r, r{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c{r2}, c
        lea r11, [rsp+54]
        mov dx, [r11]
        ; move c, c{r2}
        lea r11, [rsp+54]
        mov [r11], dx
        ; call setCell@i16@i16@u8[r{r1}, c{r2}, t.20{r3}]
        call @setCell@i16@i16@u8
        ; move r{r1}, r
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move r, r{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c{r2}, c
        lea r11, [rsp+54]
        mov dx, [r11]
        ; call maybeRevealAround@i16@i16[r{r1}, c{r2}]
        call @maybeRevealAround@i16@i16
@for_35_continue:
        ; const t.22{r0}, 1
        mov ax, 1
        ; move dc{r1}, dc
        lea r11, [rsp+52]
        mov cx, [r11]
        ; add dc{r1}, dc{r1}, t.22{r0}
        add cx, ax
@for_35:
        ; const t.13{r0}, 1
        mov ax, 1
        ; lteq t.12{r0}, dc{r1}, t.13{r0}
        cmp cx, ax
        setle al
        ; branch t.12{r0}, true, @for_35_body, @for_34_continue
        or al, al
        jnz @for_35_body
        ; const t.23{r0}, 1
        mov ax, 1
        ; move dr{r1}, dr
        lea r11, [rsp+48]
        mov cx, [r11]
        ; add dr{r1}, dr{r1}, t.23{r0}
        add cx, ax
@for_34:
        ; const t.11{r0}, 1
        mov ax, 1
        ; lteq t.10{r0}, dr{r1}, t.11{r0}
        cmp cx, ax
        setle al
        ; branch t.10{r0}, true, @for_34_body, @maybeRevealAround@i16@i16_ret
        or al, al
        jnz @for_34_body
@maybeRevealAround@i16@i16_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void main
        ;   rsp+48: var curr_r
        ;   rsp+50: var chr
        ;   rsp+52: var cell
        ;   rsp+53: var cell
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; const tmp.__random__{r6}, 0
        mov ebx, 0
        ; end initialize global variables
        ; const t.6{r1}, 7439742
        mov ecx, 7439742
        ; move __random__, tmp.__random__{r6}
        lea r11, [var_0]
        mov [r11], ebx
        ; call initRandom@i32[t.6{r1}]
        call @initRandom@i32
        ; const needsInitialize{r6}, 1
        mov bl, 1
        ; call clearField[]
        call @clearField
        ; const curr_c{r7}, 20
        mov r12w, 20
        ; const curr_r{r0}, 10
        mov ax, 10
        ; move curr_r, curr_r{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; 218:2 while true
        jmp @while_40
@if_41_then:
        ; 221:4 if printLeft([])
        ; call t.8{r0} = printLeft[] -> bool
        call @printLeft
        ; branch t.8{r0}, true, @if_42_then, @if_41_end
        or al, al
        jnz @if_42_then
@if_41_end:
        ; call chr{r0} = getChar[] -> i16
        call @getChar
        ; move chr{r3}, chr{r0}
        mov r8w, ax
        ; 228:3 if chr == 27
        ; const t.11{r4}, 27
        mov r9w, 27
        ; equals t.10{r4}, chr{r3}, t.11{r4}
        cmp r8w, r9w
        sete r9b
        ; branch t.10{r4}, true, @main_ret, @if_43_end
        or r9b, r9b
        jnz @main_ret
        ; 233:3 if chr == -8120
        ; const t.13{r4}, -8120
        mov r9w, -8120
        ; equals t.12{r4}, chr{r3}, t.13{r4}
        cmp r8w, r9w
        sete r9b
        ; branch t.12{r4}, true, @if_44_then, @if_44_else
        or r9b, r9b
        jnz @if_44_then
        ; 237:8 if chr == -8112
        ; const t.20{r4}, -8112
        mov r9w, -8112
        ; equals t.19{r4}, chr{r3}, t.20{r4}
        cmp r8w, r9w
        sete r9b
        ; branch t.19{r4}, false, @if_45_else, @if_45_then
        or r9b, r9b
        jz @if_45_else
        jmp @if_45_then
@if_44_then:
        ; const t.16{r3}, 20
        mov r8w, 20
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move t.15{r4}, curr_r{r1}
        mov r9w, cx
        ; add t.15{r4}, t.15{r4}, t.16{r3}
        add r9w, r8w
        ; const t.17{r3}, 1
        mov r8w, 1
        ; sub t.14{r4}, t.14{r4}, t.17{r3}
        sub r9w, r8w
        ; const t.18{r3}, 20
        mov r8w, 20
        ; move curr_r{r1}, t.14{r4}
        mov cx, r9w
        ; move curr_r{r0}, curr_r{r1}
        mov ax, cx
        ; mod curr_r{r2}, curr_r{r0}, t.18{r3}
        movsx rax, ax
        movsx r8, r8w
        cqo
        idiv r8
        ; move curr_r{r1}, curr_r{r2}
        mov cx, dx
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        jmp @while_40
@if_45_else:
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+48]
        mov cx, [r11]
        ; 241:8 if chr == -8117
        ; const t.25{r4}, -8117
        mov r9w, -8117
        ; equals t.24{r4}, chr{r3}, t.25{r4}
        cmp r8w, r9w
        sete r9b
        ; branch t.24{r4}, false, @if_46_else, @if_46_then
        or r9b, r9b
        jz @if_46_else
        jmp @if_46_then
@if_45_then:
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+48]
        mov cx, [r11]
        ; const t.22{r3}, 1
        mov r8w, 1
        ; move t.21{r4}, curr_r{r1}
        mov r9w, cx
        ; add t.21{r4}, t.21{r4}, t.22{r3}
        add r9w, r8w
        ; const t.23{r3}, 20
        mov r8w, 20
        ; move curr_r{r1}, t.21{r4}
        mov cx, r9w
        ; move curr_r{r0}, curr_r{r1}
        mov ax, cx
        ; mod curr_r{r2}, curr_r{r0}, t.23{r3}
        movsx rax, ax
        movsx r8, r8w
        cqo
        idiv r8
        ; move curr_r{r1}, curr_r{r2}
        mov cx, dx
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        jmp @while_40
@if_46_else:
        ; 245:8 if chr == -8117
        ; const t.32{r4}, -8117
        mov r9w, -8117
        ; equals t.31{r4}, chr{r3}, t.32{r4}
        cmp r8w, r9w
        sete r9b
        ; branch t.31{r4}, false, @if_47_else, @if_47_then
        or r9b, r9b
        jz @if_47_else
        jmp @if_47_then
@if_46_then:
        ; const t.28{r3}, 40
        mov r8w, 40
        ; add t.27{r7}, t.27{r7}, t.28{r3}
        add r12w, r8w
        ; const t.29{r3}, 1
        mov r8w, 1
        ; sub t.26{r7}, t.26{r7}, t.29{r3}
        sub r12w, r8w
        ; const t.30{r3}, 40
        mov r8w, 40
        ; move curr_c{r0}, curr_c{r7}
        mov ax, r12w
        ; mod curr_c{r2}, curr_c{r0}, t.30{r3}
        movsx rax, ax
        movsx r8, r8w
        cqo
        idiv r8
        ; move curr_c{r7}, curr_c{r2}
        mov r12w, dx
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        jmp @while_40
@if_47_else:
        ; 249:8 if chr == -8115
        ; const t.39{r4}, -8115
        mov r9w, -8115
        ; equals t.38{r4}, chr{r3}, t.39{r4}
        cmp r8w, r9w
        sete r9b
        ; branch t.38{r4}, false, @if_48_else, @if_48_then
        or r9b, r9b
        jz @if_48_else
        jmp @if_48_then
@if_47_then:
        ; const t.35{r3}, 40
        mov r8w, 40
        ; add t.34{r7}, t.34{r7}, t.35{r3}
        add r12w, r8w
        ; const t.36{r3}, 1
        mov r8w, 1
        ; sub t.33{r7}, t.33{r7}, t.36{r3}
        sub r12w, r8w
        ; const t.37{r3}, 40
        mov r8w, 40
        ; move curr_c{r0}, curr_c{r7}
        mov ax, r12w
        ; mod curr_c{r2}, curr_c{r0}, t.37{r3}
        movsx rax, ax
        movsx r8, r8w
        cqo
        idiv r8
        ; move curr_c{r7}, curr_c{r2}
        mov r12w, dx
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        jmp @while_40
@if_48_else:
        ; 253:8 if chr == 32
        ; const t.44{r4}, 32
        mov r9w, 32
        ; equals t.43{r4}, chr{r3}, t.44{r4}
        cmp r8w, r9w
        sete r9b
        ; move chr, chr{r3}
        lea r11, [rsp+50]
        mov [r11], r8w
        ; branch t.43{r4}, false, @no_critical_edge_30, @if_49_then
        or r9b, r9b
        jz @no_critical_edge_30
        jmp @if_49_then
@if_48_then:
        ; const t.41{r3}, 1
        mov r8w, 1
        ; add t.40{r7}, t.40{r7}, t.41{r3}
        add r12w, r8w
        ; const t.42{r3}, 40
        mov r8w, 40
        ; move curr_c{r0}, curr_c{r7}
        mov ax, r12w
        ; mod curr_c{r2}, curr_c{r0}, t.42{r3}
        movsx rax, ax
        movsx r8, r8w
        cqo
        idiv r8
        ; move curr_c{r7}, curr_c{r2}
        mov r12w, dx
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        jmp @while_40
@no_critical_edge_30:
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        jmp @if_49_else
@if_49_then:
        ; 254:4 if !needsInitialize
        ; notlog t.45{r0}, needsInitialize{r6}
        or bl, bl
        sete al
        ; branch t.45{r0}, true, @if_50_then, @no_critical_edge_34
        or al, al
        jnz @if_50_then
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        jmp @while_40
@if_50_then:
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call cell{r0} = getCell@i16@i16[curr_r{r1}, curr_c{r2}] -> u8
        call @getCell@i16@i16
        ; 256:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=256:17]])
        ; move cell{r1}, cell{r0}
        mov cl, al
        ; move cell, cell{r0}
        lea r11, [rsp+52]
        mov [r11], al
        ; call t.47{r0} = isOpen@u8[cell{r1}] -> bool
        call @isOpen@u8
        ; notlog t.46{r0}, t.47{r0}
        or al, al
        sete al
        ; branch t.46{r0}, false, @while_40, @if_51_then
        or al, al
        jz @while_40
        ; const t.48{r0}, 4
        mov al, 4
        ; move cell{r3}, cell
        lea r11, [rsp+52]
        mov r8b, [r11]
        ; xor cell{r3}, cell{r3}, t.48{r0}
        xor r8b, al
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call setCell@i16@i16@u8[curr_r{r1}, curr_c{r2}, cell{r3}]
        call @setCell@i16@i16@u8
@if_49_else:
        ; 262:8 if chr == 13
        ; const t.50{r0}, 13
        mov ax, 13
        ; move chr{r3}, chr
        lea r11, [rsp+50]
        mov r8w, [r11]
        ; equals t.49{r0}, chr{r3}, t.50{r0}
        cmp r8w, ax
        sete al
        ; branch t.49{r0}, true, @if_52_then, @while_40
        or al, al
        jnz @if_52_then
@while_40:
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call printField@i16@i16[curr_r{r1}, curr_c{r2}]
        call @printField@i16@i16
        ; 220:3 if !needsInitialize
        ; notlog t.7{r0}, needsInitialize{r6}
        or bl, bl
        sete al
        ; branch t.7{r0}, false, @if_41_end, @if_41_then
        or al, al
        jz @if_41_end
        jmp @if_41_then
@if_42_then:
        ; const t.9{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString@@u8[t.9{r1}]
        call @printString@@u8
        jmp @main_ret
@if_52_then:
        ; branch needsInitialize{r6}, true, @if_53_then, @no_critical_edge_32
        or bl, bl
        jnz @if_53_then
        ; move curr_r{r6}, curr_r
        lea r11, [rsp+48]
        mov bx, [r11]
        jmp @if_53_end
@if_53_then:
        ; move curr_r{r6}, curr_r
        lea r11, [rsp+48]
        mov bx, [r11]
        ; move curr_r{r1}, curr_r{r6}
        mov cx, bx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call initField@i16@i16[curr_r{r1}, curr_c{r2}]
        call @initField@i16@i16
@if_53_end:
        ; move curr_r{r1}, curr_r{r6}
        mov cx, bx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call cell{r0} = getCell@i16@i16[curr_r{r1}, curr_c{r2}] -> u8
        call @getCell@i16@i16
        ; 268:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=268:16]])
        ; move cell{r1}, cell{r0}
        mov cl, al
        ; move cell, cell{r0}
        lea r11, [rsp+53]
        mov [r11], al
        ; call t.52{r0} = isOpen@u8[cell{r1}] -> bool
        call @isOpen@u8
        ; notlog t.51{r0}, t.52{r0}
        or al, al
        sete al
        ; branch t.51{r0}, false, @if_54_end, @if_54_then
        or al, al
        jz @if_54_end
        ; const t.54{r0}, 2
        mov al, 2
        ; move cell{r4}, cell
        lea r11, [rsp+53]
        mov r9b, [r11]
        ; move t.53{r3}, cell{r4}
        mov r8b, r9b
        ; move cell, cell{r4}
        lea r11, [rsp+53]
        mov [r11], r9b
        ; or t.53{r3}, t.53{r3}, t.54{r0}
        or r8b, al
        ; move curr_r{r1}, curr_r{r6}
        mov cx, bx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call setCell@i16@i16@u8[curr_r{r1}, curr_c{r2}, t.53{r3}]
        call @setCell@i16@i16@u8
@if_54_end:
        ; 271:4 if isBomb@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=271:15]])
        ; move cell{r1}, cell
        lea r11, [rsp+53]
        mov cl, [r11]
        ; call t.55{r0} = isBomb@u8[cell{r1}] -> bool
        call @isBomb@u8
        ; branch t.55{r0}, true, @if_55_then, @if_55_end
        or al, al
        jnz @if_55_then
        ; move curr_r{r1}, curr_r{r6}
        mov cx, bx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call maybeRevealAround@i16@i16[curr_r{r1}, curr_c{r2}]
        call @maybeRevealAround@i16@i16
        jmp @main_ret
@if_55_then:
        ; move curr_r{r1}, curr_r{r6}
        mov cx, bx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call printField@i16@i16[curr_r{r1}, curr_c{r2}]
        call @printField@i16@i16
        ; const t.56{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString@@u8[t.56{r1}]
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
