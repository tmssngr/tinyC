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
        ;   rsp+64: arg chr
@printChar@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], chr{r1}
        mov [r12], cl
        ; addrof t.1{r1}, chr
        lea rcx, [rsp+64]
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1{r1}, arg.0.1{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; i64 strlen@@u8
        ;   rsp+16: arg str
@strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 69:2 for *str != 0
        jmp @for_1
@for_1_body:
        ; add length{r0}, length{r0}, 1
        add rax, 1
        ; add str{r1}, str{r1}, 1
        add rcx, 1
@for_1:
        ; load t.3{r2}, [str{r1}]
        mov dl, [rcx]
        ; notequals t.2{r2}, t.3{r2}, 0
        cmp dl, 0
        setne dl
        ; branch t.2{r2}, true, @for_1_body, @for_1_break
        or dl, dl
        jnz @for_1_body
        ; 72:9 return length
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
        add rsp, 8
        ret

        ; i16 rowColumnToCell@i16@i16
        ;   rsp+16: arg row
        ;   rsp+24: arg column
@rowColumnToCell@i16@i16:
        sub rsp, 8
        ; 16:21 return row * 17 + column
        ; mul t.3{r1}, t.3{r1}, 17
        movsx rcx, cx
        imul  rcx, 17
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
        ; 20:15 return [...]
        ; call t.5{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call @rowColumnToCell@i16@i16
        ; cast t.4{r1}(i64), t.5{r0}(i16)
        movsx rcx, ax
        ; addrof t.3{r2}, [field]
        lea rdx, [var_0]
        ; add t.3{r2}, t.3{r2}, t.4{r1}
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
        ; 24:27 return cell & 1 != 0
        ; and t.2{r1}, t.2{r1}, 1
        and cl, 1
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp cl, 0
        setne al
        add rsp, 8
        ret

        ; bool isOpen@u8
        ;   rsp+16: arg cell
@isOpen@u8:
        sub rsp, 8
        ; 28:27 return cell & 2 != 0
        ; and t.2{r1}, t.2{r1}, 2
        and cl, 2
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp cl, 0
        setne al
        add rsp, 8
        ret

        ; bool isFlag@u8
        ;   rsp+16: arg cell
@isFlag@u8:
        sub rsp, 8
        ; 32:27 return cell & 4 != 0
        ; and t.2{r1}, t.2{r1}, 4
        and cl, 4
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp cl, 0
        setne al
        add rsp, 8
        ret

        ; bool checkCellBounds@i16@i16
        ;   rsp+16: arg row
        ;   rsp+24: arg column
@checkCellBounds@i16@i16:
        sub rsp, 8
        ; 37:21 return row >= 0 && row < 20 && column >= 0 && column < 17
        ; 37:21 logic and
        ; 37:6 logic and
        ; 36:21 logic and
        ; gteq t.2{r0}, row{r1}, 0
        cmp cx, 0
        setge al
        ; branch t.2{r0}, false, @and_next_4, @and_2nd_4
        or al, al
        jz @and_next_4
        ; lt t.2{r0}, row{r1}, 20
        cmp cx, 20
        setl al
@and_next_4:
        ; branch t.2{r0}, false, @and_next_3, @and_2nd_3
        or al, al
        jz @and_next_3
        ; gteq t.2{r0}, column{r2}, 0
        cmp dx, 0
        setge al
@and_next_3:
        ; branch t.2{r0}, false, @checkCellBounds@i16@i16_ret, @and_2nd_2
        or al, al
        jz @checkCellBounds@i16@i16_ret
        ; lt t.2{r0}, column{r2}, 17
        cmp dx, 17
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
        movsx rax, ax
        ; addrof t.3{r1}, [field]
        lea rcx, [var_0]
        ; add t.3{r1}, t.3{r1}, t.4{r0}
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
        ; const count{r0}, 0
        mov al, 0
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], count{r0}
        mov [r12], al
        ; const dr{r0}, -1
        mov ax, -1
        ; 46:2 for dr <= 1
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dx
        ; move dr{r1}, dr{r0}
        mov cx, ax
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+48]
        ; load count{r0}, [memVarAddr{r7}]
        mov al, [r12]
        jmp @for_5
@for_5_body:
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], count{r0}
        mov [r12], al
        ; move dr{r0}, dr{r1}
        mov ax, cx
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+88]
        ; load column{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; move r{r1}, row{r6}
        mov cx, bx
        ; add r{r1}, r{r1}, dr{r0}
        add cx, ax
        ; addrof memVarAddr{r7}, dr
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], dr{r0}
        mov [r12], ax
        ; const dc{r0}, -1
        mov ax, -1
        ; 48:3 for dc <= 1
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dx
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], r{r1}
        mov [r12], cx
        ; move dc{r1}, dc{r0}
        mov cx, ax
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+48]
        ; load count{r0}, [memVarAddr{r7}]
        mov al, [r12]
        jmp @for_6
@for_6_body:
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], count{r0}
        mov [r12], al
        ; move dc{r0}, dc{r1}
        mov ax, cx
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+88]
        ; load column{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+52]
        ; load r{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; move c{r3}, column{r2}
        mov r8w, dx
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dx
        ; add c{r3}, c{r3}, dc{r0}
        add r8w, ax
        ; addrof memVarAddr{r7}, dc
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], dc{r0}
        mov [r12], ax
        ; 50:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=50:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=50:27]])
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], r{r1}
        mov [r12], cx
        ; move c{r2}, c{r3}
        mov dx, r8w
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], c{r3}
        mov [r12], r8w
        ; call t.10{r0} = checkCellBounds@i16@i16[r{r1}, c{r2}] -> bool
        call @checkCellBounds@i16@i16
        ; branch t.10{r0}, true, @if_7_then, @no_critical_edge_11
        or al, al
        jnz @if_7_then
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+48]
        ; load count{r0}, [memVarAddr{r7}]
        mov al, [r12]
        jmp @for_6_continue
@if_7_then:
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+52]
        ; load r{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], r{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+56]
        ; load c{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; call cell{r0} = getCell@i16@i16[r{r1}, c{r2}] -> u8
        call @getCell@i16@i16
        ; 52:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=52:16]])
        ; move cell{r1}, cell{r0}
        mov cl, al
        ; call t.11{r0} = isBomb@u8[cell{r1}] -> bool
        call @isBomb@u8
        ; branch t.11{r0}, true, @if_8_then, @no_critical_edge_12
        or al, al
        jnz @if_8_then
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+48]
        ; load count{r0}, [memVarAddr{r7}]
        mov al, [r12]
        jmp @for_6_continue
@if_8_then:
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+48]
        ; load count{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; add count{r0}, count{r0}, 1
        add al, 1
@for_6_continue:
        ; addrof memVarAddr{r7}, dc
        lea r12, [rsp+54]
        ; load dc{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; add dc{r1}, dc{r1}, 1
        add cx, 1
@for_6:
        ; lteq t.9{r2}, dc{r1}, 1
        cmp cx, 1
        setle dl
        ; branch t.9{r2}, true, @for_6_body, @for_5_continue
        or dl, dl
        jnz @for_6_body
        ; addrof memVarAddr{r7}, dr
        lea r12, [rsp+50]
        ; load dr{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; add dr{r1}, dr{r1}, 1
        add cx, 1
@for_5:
        ; lteq t.8{r2}, dr{r1}, 1
        cmp cx, 1
        setle dl
        ; branch t.8{r2}, true, @for_5_body, @for_5_break
        or dl, dl
        jnz @for_5_body
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
        ; equals t.4{r1}, rowCursor{r3}, row{r1}
        cmp r8w, cx
        sete cl
        ; branch t.4{r1}, false, @if_9_end, @if_9_then
        or cl, cl
        jz @if_9_end
        ; 63:3 if columnCursor == column
        ; equals t.5{r1}, columnCursor{r4}, column{r2}
        cmp r9w, dx
        sete cl
        ; branch t.5{r1}, true, @if_10_then, @if_10_end
        or cl, cl
        jnz @if_10_then
        ; 66:3 if columnCursor == column - 1
        ; move t.8{r1}, column{r2}
        mov cx, dx
        ; sub t.8{r1}, t.8{r1}, 1
        sub cx, 1
        ; equals t.7{r1}, columnCursor{r4}, t.8{r1}
        cmp r9w, cx
        sete cl
        ; branch t.7{r1}, false, @if_9_end, @if_11_then
        or cl, cl
        jz @if_9_end
        jmp @if_11_then
@if_10_then:
        ; 64:11 return 91
        ; const t.6{r0}, 91
        mov al, 91
        jmp @getSpacer@i16@i16@i16@i16_ret
@if_11_then:
        ; 67:11 return 93
        ; const t.9{r1}, 93
        mov cl, 93
        ; move t.9{r0}, t.9{r1}
        mov al, cl
        jmp @getSpacer@i16@i16@i16@i16_ret
@if_9_end:
        ; 70:9 return 32
        ; const t.10{r1}, 32
        mov cl, 32
        ; move t.10{r0}, t.10{r1}
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
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], row{r2}
        mov [r12], dx
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], column{r3}
        mov [r12], r8w
        ; const chr{r1}, 46
        mov cl, 46
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], chr{r1}
        mov [r12], cl
        ; 75:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:13]])
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; call t.5{r0} = isOpen@u8[cell{r1}] -> bool
        call @isOpen@u8
        ; branch t.5{r0}, true, @if_12_then, @if_12_else
        or al, al
        jnz @if_12_then
        ; 89:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=89:18]])
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; call t.8{r0} = isFlag@u8[cell{r1}] -> bool
        call @isFlag@u8
        ; branch t.8{r0}, false, @no_critical_edge_10, @if_15_then
        or al, al
        jz @no_critical_edge_10
        jmp @if_15_then
@if_12_then:
        ; 76:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=76:14]])
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; call t.6{r0} = isBomb@u8[cell{r1}] -> bool
        call @isBomb@u8
        ; branch t.6{r0}, false, @if_13_else, @if_13_then
        or al, al
        jz @if_13_else
        jmp @if_13_then
@no_critical_edge_10:
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+48]
        ; load chr{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        jmp @if_12_end
@if_15_then:
        ; const chr{r6}, 35
        mov bl, 35
        jmp @if_12_end
@if_13_else:
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+72]
        ; load row{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; move row{r1}, row{r2}
        mov cx, dx
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+80]
        ; load column{r3}, [memVarAddr{r7}]
        mov r8w, [r12]
        ; move column{r2}, column{r3}
        mov dx, r8w
        ; call count{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call @getBombCountAround@i16@i16
        ; 81:4 if count > 0
        ; gt t.7{r6}, count{r0}, 0
        cmp al, 0
        seta bl
        ; branch t.7{r6}, false, @if_14_else, @if_14_then
        or bl, bl
        jz @if_14_else
        jmp @if_14_then
@if_13_then:
        ; const chr{r6}, 42
        mov bl, 42
        jmp @if_12_end
@if_14_else:
        ; const chr{r6}, 32
        mov bl, 32
        jmp @if_12_end
@if_14_then:
        ; move chr{r6}, count{r0}
        mov bl, al
        ; add chr{r6}, chr{r6}, 48
        add bl, 48
@if_12_end:
        ; move chr{r1}, chr{r6}
        mov cl, bl
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
        ; addrof memVarAddr{r7}, columnCursor
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], columnCursor{r2}
        mov [r12], dx
        ; const arg.0.0{r1}, 0
        mov cx, 0
        ; const arg.0.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call @setCursor@i16@i16
        ; const row{r1}, 0
        mov cx, 0
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row{r1}
        mov [r12], cx
        ; 97:2 for row < 20
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+48]
        ; load row{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        jmp @for_16
@for_16_body:
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row{r1}
        mov [r12], cx
        ; const arg.1.0{r1}, 124
        mov cl, 124
        ; call printChar@u8[arg.1.0{r1}]
        call @printChar@u8
        ; const column{r2}, 0
        mov dx, 0
        ; 99:3 for column < 17
        jmp @for_17
@for_17_body:
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+48]
        ; load row{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dx
        ; move rowCursor{r3}, rowCursor{r6}
        mov r8w, bx
        ; addrof memVarAddr{r7}, columnCursor
        lea r12, [rsp+72]
        ; load columnCursor{r4}, [memVarAddr{r7}]
        mov r9w, [r12]
        ; addrof memVarAddr{r7}, columnCursor
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], columnCursor{r4}
        mov [r12], r9w
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r1}, column{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call @getSpacer@i16@i16@i16@i16
        ; move spacer{r1}, spacer{r0}
        mov cl, al
        ; call printChar@u8[spacer{r1}]
        call @printChar@u8
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+48]
        ; load row{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+50]
        ; load column{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dx
        ; call cell{r0} = getCell@i16@i16[row{r1}, column{r2}] -> u8
        call @getCell@i16@i16
        ; move cell{r1}, cell{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+48]
        ; load row{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row{r2}
        mov [r12], dx
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+50]
        ; load column{r3}, [memVarAddr{r7}]
        mov r8w, [r12]
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], column{r3}
        mov [r12], r8w
        ; call printCell@u8@i16@i16[cell{r1}, row{r2}, column{r3}]
        call @printCell@u8@i16@i16
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+50]
        ; load column{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; add column{r2}, column{r2}, 1
        add dx, 1
@for_17:
        ; lt t.8{r0}, column{r2}, 17
        cmp dx, 17
        setl al
        ; branch t.8{r0}, true, @for_17_body, @for_17_break
        or al, al
        jnz @for_17_body
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+48]
        ; load row{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row{r1}
        mov [r12], cx
        ; move rowCursor{r3}, rowCursor{r6}
        mov r8w, bx
        ; addrof memVarAddr{r7}, columnCursor
        lea r12, [rsp+72]
        ; load columnCursor{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; move columnCursor{r4}, columnCursor{r2}
        mov r9w, dx
        ; addrof memVarAddr{r7}, columnCursor
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], columnCursor{r2}
        mov [r12], dx
        ; const arg.6.1{r2}, 17
        mov dx, 17
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r1}, arg.6.1{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call @getSpacer@i16@i16@i16@i16
        ; move spacer{r1}, spacer{r0}
        mov cl, al
        ; call printChar@u8[spacer{r1}]
        call @printChar@u8
        ; const t.9{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.9{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+48]
        ; load row{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; add row{r1}, row{r1}, 1
        add cx, 1
@for_16:
        ; lt t.7{r0}, row{r1}, 20
        cmp cx, 20
        setl al
        ; branch t.7{r0}, true, @for_16_body, @printField@i16@i16_ret
        or al, al
        jnz @for_16_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
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
        ; 167:2 for r < 20
        jmp @for_18
@for_18_body:
        ; const c{r7}, 0
        mov r12w, 0
        ; 168:3 for c < 17
        jmp @for_19
@for_19_body:
        ; move r{r1}, r{r6}
        mov cx, bx
        ; move c{r2}, c{r7}
        mov dx, r12w
        ; const arg.0.2{r3}, 0
        mov r8b, 0
        ; call setCell@i16@i16@u8[r{r1}, c{r2}, arg.0.2{r3}]
        call @setCell@i16@i16@u8
        ; add c{r7}, c{r7}, 1
        add r12w, 1
@for_19:
        ; lt t.3{r0}, c{r7}, 17
        cmp r12w, 17
        setl al
        ; branch t.3{r0}, true, @for_19_body, @for_18_continue
        or al, al
        jnz @for_19_body
        ; add r{r6}, r{r6}, 1
        add bx, 1
@for_18:
        ; lt t.2{r0}, r{r6}, 20
        cmp bx, 20
        setl al
        ; branch t.2{r0}, true, @for_18_body, @clearField_ret
        or al, al
        jnz @for_18_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void main
@main:
        sub rsp, 8
        sub rsp, 32
        ; begin initialize global variables
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov ecx, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call @initRandom@i32
        ; call clearField[]
        call @clearField
        ; const curr_c{r2}, 8
        mov dx, 8
        ; const curr_r{r1}, 10
        mov cx, 10
        ; 219:2 while true
        ; call printField@i16@i16[curr_r{r1}, curr_c{r2}]
        call @printField@i16@i16
        add rsp, 32
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
        ; variable 0: field[] (u8*/2720)
        var_0 rb 2720

section '.data' data readable
        string_0 db '|', 0x0a, 0x00
        string_1 db 'Left: ', 0x00

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
