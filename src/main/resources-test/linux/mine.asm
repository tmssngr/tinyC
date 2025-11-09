format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void printString
        ;   rsp+64: arg str
@printString:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        sub rsp, 32
        ; move str{r8}, str{r1}
        mov rbx, rdi
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; call length{r0} = strlen[str{r1}] -> i64
        call @strlen
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; move length{r2}, length{r0}
        mov rsi, rax
        ; call printStringLength[str{r1}, length{r2}]
        call @printStringLength
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void printChar
        ;   rsp+64: arg chr
@printChar:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        sub rsp, 32
        ; addrof t.1{r8}, chr
        lea rbx, [rsp+64]
        ; const t.2{r2}, 1
        mov rsi, 1
        ; move chr, tmp.chr{r1}
        lea r11, [rsp+64]
        mov [r11], dil
        ; move t.1{r1}, t.1{r8}
        mov rdi, rbx
        ; call printStringLength[t.1{r1}, t.2{r2}]
        call @printStringLength
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void printUint
        ;   rsp+112: arg number
        ;   rsp+80: var buffer
@printUint:
        sub rsp, 40
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; const pos{r8}, 20
        mov bl, 20
        ; 13:2 while true
@while_1:
        ; dec pos{r8}
        dec bl
        ; const t.5{r9}, 10
        mov r12, 10
        ; move remainder{r4}, number{r1}
        mov rcx, rdi
        ; move remainder{r0}, remainder{r4}
        mov rax, rcx
        ; mod remainder{r3}, remainder{r0}, t.5{r9}
        cqo
        idiv r12
        ; move remainder{r4}, remainder{r3}
        mov rcx, rdx
        ; const t.6{r9}, 10
        mov r12, 10
        ; move number{r0}, number{r1}
        mov rax, rdi
        ; div number{r0}, number{r0}, t.6{r9}
        cqo
        idiv r12
        ; move number{r1}, number{r0}
        mov rdi, rax
        ; cast t.7{r9}(u8), remainder{r4}(i64)
        mov r12b, cl
        ; const t.8{r0}, 48
        mov al, 48
        ; add digit{r9}, digit{r9}, t.8{r0}
        add r12b, al
        ; cast t.10{r0}(i64), pos{r8}(u8)
        movzx rax, bl
        ; cast t.11{r0}(u8*), t.10{r0}(i64)
        ; addrof t.9{r3}, [buffer]
        lea rdx, [rsp+80]
        ; add t.9{r3}, t.9{r3}, t.11{r0}
        add rdx, rax
        ; store [t.9{r3}], digit{r9}
        mov [rdx], r12b
        ; 19:3 if number == 0
        ; equals t.12{r9}, number{r1}, 0
        cmp rdi, 0
        sete r12b
        ; branch t.12{r9}, false, @while_1
        or r12b, r12b
        jz @while_1
        ; cast t.14{r9}(i64), pos{r8}(u8)
        movzx r12, bl
        ; cast t.15{r9}(u8*), t.14{r9}(i64)
        ; addrof t.13{r1}, [buffer]
        lea rdi, [rsp+80]
        ; add t.13{r1}, t.13{r1}, t.15{r9}
        add rdi, r12
        ; const t.18{r9}, 20
        mov r12b, 20
        ; sub t.17{r9}, t.17{r9}, pos{r8}
        sub r12b, bl
        ; cast t.16{r2}(i64), t.17{r9}(u8)
        movzx rsi, r12b
        ; call printStringLength[t.13{r1}, t.16{r2}]
        call @printStringLength
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 40
        ret

        ; i64 strlen
        ;   rsp+16: arg str
@strlen:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 37:2 for *str != 0
        jmp @for_3
@for_3_body:
        ; inc length{r0}
        inc rax
        ; cast t.5{r2}(i64), str{r1}(u8*)
        mov rsi, rdi
        ; const t.6{r3}, 1
        mov rdx, 1
        ; move t.4{r1}, t.5{r2}
        mov rdi, rsi
        ; add t.4{r1}, t.4{r1}, t.6{r3}
        add rdi, rdx
        ; cast str{r1}(u8*), t.4{r1}(i64)
@for_3:
        ; load t.3{r2}, [str{r1}]
        mov sil, [rdi]
        ; notequals t.2{r2}, t.3{r2}, 0
        cmp sil, 0
        setne sil
        ; branch t.2{r2}, true, @for_3_body
        or sil, sil
        jnz @for_3_body
        ; 40:9 return length
        add rsp, 8
        ret

        ; void initRandom
        ;   rsp+16: arg salt
@initRandom:
        sub rsp, 8
        ; move tmp.__random__{r0}, salt{r1}
        mov eax, edi
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
        ; move r{r1}, tmp.__random__{r0}
        mov edi, eax
        ; const t.6{r2}, 524287
        mov esi, 524287
        ; move t.5{r3}, r{r1}
        mov edx, edi
        ; and t.5{r3}, t.5{r3}, t.6{r2}
        and edx, esi
        ; const t.7{r2}, 48271
        mov esi, 48271
        ; mul b{r3}, b{r3}, t.7{r2}
        movsxd rdx, edx
        movsxd rsi, esi
        imul  rdx, rsi
        ; const t.9{r4}, 15
        mov ecx, 15
        ; shiftright t.8{r1}, t.8{r1}, t.9{r4}
        sar edi, cl
        ; const t.10{r2}, 48271
        mov esi, 48271
        ; mul c{r1}, c{r1}, t.10{r2}
        movsxd rdi, edi
        movsxd rsi, esi
        imul  rdi, rsi
        ; const t.12{r2}, 65535
        mov esi, 65535
        ; move t.11{r5}, c{r1}
        mov r8d, edi
        ; and t.11{r5}, t.11{r5}, t.12{r2}
        and r8d, esi
        ; const t.13{r4}, 15
        mov ecx, 15
        ; move d{r2}, t.11{r5}
        mov esi, r8d
        ; shiftleft d{r2}, d{r2}, t.13{r4}
        sal esi, cl
        ; const t.16{r4}, 16
        mov ecx, 16
        ; shiftright t.15{r1}, t.15{r1}, t.16{r4}
        sar edi, cl
        ; add t.14{r1}, t.14{r1}, b{r3}
        add edi, edx
        ; add e{r1}, e{r1}, d{r2}
        add edi, esi
        ; const t.18{r2}, 2147483647
        mov esi, 2147483647
        ; move t.17{r0}, e{r1}
        mov eax, edi
        ; and t.17{r0}, t.17{r0}, t.18{r2}
        and eax, esi
        ; const t.20{r4}, 31
        mov ecx, 31
        ; shiftright t.19{r1}, t.19{r1}, t.20{r4}
        sar edi, cl
        ; add tmp.__random__{r0}, tmp.__random__{r0}, t.19{r1}
        add eax, edi
        ; 118:9 return __random__
        ; move __random__, tmp.__random__{r0}
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; i16 rowColumnToCell
        ;   rsp+16: arg row
        ;   rsp+24: arg column
@rowColumnToCell:
        sub rsp, 8
        ; 15:21 return row * 40 + column
        ; const t.4{r3}, 40
        mov dx, 40
        ; mul t.3{r1}, t.3{r1}, t.4{r3}
        movsx rdi, di
        movsx rdx, dx
        imul  rdi, rdx
        ; move t.2{r0}, t.3{r1}
        mov ax, di
        ; add t.2{r0}, t.2{r0}, column{r2}
        add ax, si
        add rsp, 8
        ret

        ; u8 getCell
        ;   rsp+48: arg row
        ;   rsp+56: arg column
@getCell:
        sub rsp, 8
        sub rsp, 32
        ; 19:15 return [...]
        ; call t.5{r0} = rowColumnToCell[row{r1}, column{r2}] -> i16
        call @rowColumnToCell
        ; cast t.4{r1}(i64), t.5{r0}(i16)
        movzx rdi, ax
        ; cast t.6{r1}(u8*), t.4{r1}(i64)
        ; addrof t.3{r2}, [field]
        lea rsi, [var_1]
        ; add t.3{r2}, t.3{r2}, t.6{r1}
        add rsi, rdi
        ; load t.2{r0}, [t.3{r2}]
        mov al, [rsi]
        add rsp, 32
        add rsp, 8
        ret

        ; bool isBomb
        ;   rsp+16: arg cell
@isBomb:
        sub rsp, 8
        ; 23:27 return cell & 1 != 0
        ; const t.3{r2}, 1
        mov sil, 1
        ; and t.2{r1}, t.2{r1}, t.3{r2}
        and dil, sil
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool isOpen
        ;   rsp+16: arg cell
@isOpen:
        sub rsp, 8
        ; 27:27 return cell & 2 != 0
        ; const t.3{r2}, 2
        mov sil, 2
        ; and t.2{r1}, t.2{r1}, t.3{r2}
        and dil, sil
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool isFlag
        ;   rsp+16: arg cell
@isFlag:
        sub rsp, 8
        ; 31:27 return cell & 4 != 0
        ; const t.3{r2}, 4
        mov sil, 4
        ; and t.2{r1}, t.2{r1}, t.3{r2}
        and dil, sil
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool checkCellBounds
        ;   rsp+16: arg row
        ;   rsp+24: arg column
@checkCellBounds:
        sub rsp, 8
        ; 36:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 36:21 logic and
        ; 36:6 logic and
        ; 35:21 logic and
        ; gteq t.2{r0}, row{r1}, 0
        cmp di, 0
        setge al
        ; branch t.2{r0}, false, @and_next_6
        or al, al
        jz @and_next_6
        ; lt t.2{r0}, row{r1}, 20
        cmp di, 20
        setl al
@and_next_6:
        ; branch t.2{r0}, false, @and_next_5
        or al, al
        jz @and_next_5
        ; gteq t.2{r0}, column{r2}, 0
        cmp si, 0
        setge al
@and_next_5:
        ; branch t.2{r0}, false, @checkCellBounds_ret
        or al, al
        jz @checkCellBounds_ret
        ; lt t.2{r0}, column{r2}, 40
        cmp si, 40
        setl al
@checkCellBounds_ret:
        add rsp, 8
        ret

        ; void setCell
        ;   rsp+64: arg row
        ;   rsp+72: arg column
        ;   rsp+80: arg cell
@setCell:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        sub rsp, 32
        ; move cell{r8}, cell{r3}
        mov bl, dl
        ; call t.5{r0} = rowColumnToCell[row{r1}, column{r2}] -> i16
        call @rowColumnToCell
        ; cast t.4{r0}(i64), t.5{r0}(i16)
        movzx rax, ax
        ; cast t.6{r0}(u8*), t.4{r0}(i64)
        ; addrof t.3{r1}, [field]
        lea rdi, [var_1]
        ; add t.3{r1}, t.3{r1}, t.6{r0}
        add rdi, rax
        ; store [t.3{r1}], cell{r8}
        mov [rdi], bl
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; u8 getBombCountAround
        ;   rsp+96: arg row
        ;   rsp+104: arg column
        ;   rsp+64: var count
        ;   rsp+66: var dr
        ;   rsp+68: var r
        ;   rsp+70: var dc
        ;   rsp+72: var c
@getBombCountAround:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; move row{r8}, row{r1}
        mov bx, di
        ; move column{r9}, column{r2}
        mov r12w, si
        ; const count{r0}, 0
        mov al, 0
        ; move count, count{r0}
        lea r11, [rsp+64]
        mov [r11], al
        ; const dr{r0}, -1
        mov ax, -1
        ; 45:2 for dr <= 1
        ; move dr{r1}, dr{r0}
        mov di, ax
        ; move count{r0}, count
        lea r11, [rsp+64]
        mov al, [r11]
        jmp @for_7
@for_7_body:
        ; move count, count{r0}
        lea r11, [rsp+64]
        mov [r11], al
        ; move dr{r0}, dr{r1}
        mov ax, di
        ; move r{r1}, row{r8}
        mov di, bx
        ; add r{r1}, r{r1}, dr{r0}
        add di, ax
        ; move dr, dr{r0}
        lea r11, [rsp+66]
        mov [r11], ax
        ; const dc{r0}, -1
        mov ax, -1
        ; 47:3 for dc <= 1
        ; move r, r{r1}
        lea r11, [rsp+68]
        mov [r11], di
        ; move dc{r1}, dc{r0}
        mov di, ax
        ; move count{r0}, count
        lea r11, [rsp+64]
        mov al, [r11]
        jmp @for_8
@for_8_body:
        ; move count, count{r0}
        lea r11, [rsp+64]
        mov [r11], al
        ; move dc{r0}, dc{r1}
        mov ax, di
        ; move r{r1}, r
        lea r11, [rsp+68]
        mov di, [r11]
        ; move c{r2}, column{r9}
        mov si, r12w
        ; add c{r2}, c{r2}, dc{r0}
        add si, ax
        ; move dc, dc{r0}
        lea r11, [rsp+70]
        mov [r11], ax
        ; 49:4 if checkCellBounds([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=49:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=49:27]])
        ; move r, r{r1}
        lea r11, [rsp+68]
        mov [r11], di
        ; move c, c{r2}
        lea r11, [rsp+72]
        mov [r11], si
        ; call t.10{r0} = checkCellBounds[r{r1}, c{r2}] -> bool
        call @checkCellBounds
        ; branch t.10{r0}, true, @if_9_then
        or al, al
        jnz @if_9_then
        ; move count{r0}, count
        lea r11, [rsp+64]
        mov al, [r11]
        jmp @for_8_continue
@if_9_then:
        ; move r{r1}, r
        lea r11, [rsp+68]
        mov di, [r11]
        ; move r, r{r1}
        lea r11, [rsp+68]
        mov [r11], di
        ; move c{r2}, c
        lea r11, [rsp+72]
        mov si, [r11]
        ; call cell{r0} = getCell[r{r1}, c{r2}] -> u8
        call @getCell
        ; 51:5 if isBomb([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=51:16]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; call t.11{r0} = isBomb[cell{r1}] -> bool
        call @isBomb
        ; branch t.11{r0}, true, @if_10_then
        or al, al
        jnz @if_10_then
        ; move count{r0}, count
        lea r11, [rsp+64]
        mov al, [r11]
        jmp @for_8_continue
@if_10_then:
        ; move count{r0}, count
        lea r11, [rsp+64]
        mov al, [r11]
        ; inc count{r0}
        inc al
@for_8_continue:
        ; move dc{r1}, dc
        lea r11, [rsp+70]
        mov di, [r11]
        ; inc dc{r1}
        inc di
@for_8:
        ; lteq t.9{r2}, dc{r1}, 1
        cmp di, 1
        setle sil
        ; branch t.9{r2}, true, @for_8_body
        or sil, sil
        jnz @for_8_body
        ; move dr{r1}, dr
        lea r11, [rsp+66]
        mov di, [r11]
        ; inc dr{r1}
        inc di
@for_7:
        ; lteq t.8{r2}, dr{r1}, 1
        cmp di, 1
        setle sil
        ; branch t.8{r2}, true, @for_7_body
        or sil, sil
        jnz @for_7_body
        ; 57:9 return count
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; u8 getSpacer
        ;   rsp+16: arg row
        ;   rsp+24: arg column
        ;   rsp+32: arg rowCursor
        ;   rsp+40: arg columnCursor
@getSpacer:
        sub rsp, 8
        ; 61:2 if rowCursor == row
        ; equals t.4{r1}, rowCursor{r3}, row{r1}
        cmp dx, di
        sete dil
        ; branch t.4{r1}, false, @if_11_end
        or dil, dil
        jz @if_11_end
        ; 62:3 if columnCursor == column
        ; equals t.5{r1}, columnCursor{r4}, column{r2}
        cmp cx, si
        sete dil
        ; branch t.5{r1}, true, @if_12_then
        or dil, dil
        jnz @if_12_then
        ; 65:3 if columnCursor == column - 1
        ; const t.9{r1}, 1
        mov di, 1
        ; sub t.8{r2}, t.8{r2}, t.9{r1}
        sub si, di
        ; equals t.7{r1}, columnCursor{r4}, t.8{r2}
        cmp cx, si
        sete dil
        ; branch t.7{r1}, false, @if_11_end
        or dil, dil
        jz @if_11_end
        jmp @if_13_then
@if_12_then:
        ; 63:11 return 91
        ; const t.6{r0}, 91
        mov al, 91
        jmp @getSpacer_ret
@if_13_then:
        ; 66:11 return 93
        ; const t.10{r1}, 93
        mov dil, 93
        ; move t.10{r0}, t.10{r1}
        mov al, dil
        jmp @getSpacer_ret
@if_11_end:
        ; 69:9 return 32
        ; const t.11{r1}, 32
        mov dil, 32
        ; move t.11{r0}, t.11{r1}
        mov al, dil
@getSpacer_ret:
        add rsp, 8
        ret

        ; void printCell
        ;   rsp+80: arg cell
        ;   rsp+88: arg row
        ;   rsp+96: arg column
        ;   rsp+64: var chr
@printCell:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; move cell{r8}, cell{r1}
        mov bl, dil
        ; move row{r9}, row{r2}
        mov r12w, si
        ; move column, column{r3}
        lea r11, [rsp+96]
        mov [r11], dx
        ; const chr{r1}, 46
        mov dil, 46
        ; move chr, chr{r1}
        lea r11, [rsp+64]
        mov [r11], dil
        ; 74:2 if isOpen([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=74:13]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.5{r0} = isOpen[cell{r1}] -> bool
        call @isOpen
        ; branch t.5{r0}, true, @if_14_then
        or al, al
        jnz @if_14_then
        ; 88:7 if isFlag([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=88:18]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.9{r0} = isFlag[cell{r1}] -> bool
        call @isFlag
        ; branch t.9{r0}, false, @no_critical_edge_13
        or al, al
        jz @no_critical_edge_13
        jmp @if_17_then
@if_14_then:
        ; 75:3 if isBomb([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=75:14]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.6{r0} = isBomb[cell{r1}] -> bool
        call @isBomb
        ; branch t.6{r0}, false, @if_15_else
        or al, al
        jz @if_15_else
        jmp @if_15_then
@no_critical_edge_13:
        ; move chr{r8}, chr
        lea r11, [rsp+64]
        mov bl, [r11]
        jmp @if_14_end
@if_17_then:
        ; const chr{r8}, 35
        mov bl, 35
        jmp @if_14_end
@if_15_else:
        ; move row{r1}, row{r9}
        mov di, r12w
        ; move column{r2}, column
        lea r11, [rsp+96]
        mov si, [r11]
        ; call count{r0} = getBombCountAround[row{r1}, column{r2}] -> u8
        call @getBombCountAround
        ; 80:4 if count > 0
        ; gt t.7{r9}, count{r0}, 0
        cmp al, 0
        seta r12b
        ; branch t.7{r9}, false, @if_16_else
        or r12b, r12b
        jz @if_16_else
        jmp @if_16_then
@if_15_then:
        ; const chr{r8}, 42
        mov bl, 42
        jmp @if_14_end
@if_16_else:
        ; const chr{r8}, 32
        mov bl, 32
        jmp @if_14_end
@if_16_then:
        ; const t.8{r9}, 48
        mov r12b, 48
        ; move chr{r8}, count{r0}
        mov bl, al
        ; add chr{r8}, chr{r8}, t.8{r9}
        add bl, r12b
@if_14_end:
        ; move chr{r1}, chr{r8}
        mov dil, bl
        ; call printChar[chr{r1}]
        call @printChar
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printField
        ;   rsp+80: arg rowCursor
        ;   rsp+88: arg columnCursor
        ;   rsp+64: var row
        ;   rsp+66: var column
@printField:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; move rowCursor{r8}, rowCursor{r1}
        mov bx, di
        ; move columnCursor{r9}, columnCursor{r2}
        mov r12w, si
        ; const t.7{r1}, 0
        mov di, 0
        ; const t.8{r2}, 0
        mov si, 0
        ; call setCursor[t.7{r1}, t.8{r2}]
        call @setCursor
        ; const row{r1}, 0
        mov di, 0
        ; move row, row{r1}
        lea r11, [rsp+64]
        mov [r11], di
        ; 96:2 for row < 20
        ; move row{r0}, row
        lea r11, [rsp+64]
        mov ax, [r11]
        jmp @for_18
@for_18_body:
        ; move row, row{r0}
        lea r11, [rsp+64]
        mov [r11], ax
        ; const t.10{r1}, 124
        mov dil, 124
        ; call printChar[t.10{r1}]
        call @printChar
        ; const column{r2}, 0
        mov si, 0
        ; 98:3 for column < 40
        ; move column{r0}, column{r2}
        mov ax, si
        jmp @for_19
@for_19_body:
        ; move row{r1}, row
        lea r11, [rsp+64]
        mov di, [r11]
        ; move column{r2}, column{r0}
        mov si, ax
        ; move row, row{r1}
        lea r11, [rsp+64]
        mov [r11], di
        ; move column, column{r2}
        lea r11, [rsp+66]
        mov [r11], si
        ; move rowCursor{r3}, rowCursor{r8}
        mov dx, bx
        ; move columnCursor{r4}, columnCursor{r9}
        mov cx, r12w
        ; call spacer{r0} = getSpacer[row{r1}, column{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call @getSpacer
        ; move spacer{r1}, spacer{r0}
        mov dil, al
        ; call printChar[spacer{r1}]
        call @printChar
        ; move row{r1}, row
        lea r11, [rsp+64]
        mov di, [r11]
        ; move row, row{r1}
        lea r11, [rsp+64]
        mov [r11], di
        ; move column{r2}, column
        lea r11, [rsp+66]
        mov si, [r11]
        ; move column, column{r2}
        lea r11, [rsp+66]
        mov [r11], si
        ; call cell{r0} = getCell[row{r1}, column{r2}] -> u8
        call @getCell
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; move row{r2}, row
        lea r11, [rsp+64]
        mov si, [r11]
        ; move row, row{r2}
        lea r11, [rsp+64]
        mov [r11], si
        ; move column{r3}, column
        lea r11, [rsp+66]
        mov dx, [r11]
        ; move column, column{r3}
        lea r11, [rsp+66]
        mov [r11], dx
        ; call printCell[cell{r1}, row{r2}, column{r3}]
        call @printCell
        ; move column{r0}, column
        lea r11, [rsp+66]
        mov ax, [r11]
        ; inc column{r0}
        inc ax
@for_19:
        ; lt t.11{r5}, column{r0}, 40
        cmp ax, 40
        setl r8b
        ; branch t.11{r5}, true, @for_19_body
        or r8b, r8b
        jnz @for_19_body
        ; const t.12{r2}, 40
        mov si, 40
        ; move row{r1}, row
        lea r11, [rsp+64]
        mov di, [r11]
        ; move row, row{r1}
        lea r11, [rsp+64]
        mov [r11], di
        ; move rowCursor{r3}, rowCursor{r8}
        mov dx, bx
        ; move columnCursor{r4}, columnCursor{r9}
        mov cx, r12w
        ; call spacer{r0} = getSpacer[row{r1}, t.12{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call @getSpacer
        ; move spacer{r1}, spacer{r0}
        mov dil, al
        ; call printChar[spacer{r1}]
        call @printChar
        ; const t.13{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString[t.13{r1}]
        call @printString
        ; move row{r0}, row
        lea r11, [rsp+64]
        mov ax, [r11]
        ; inc row{r0}
        inc ax
@for_18:
        ; lt t.9{r1}, row{r0}, 20
        cmp ax, 20
        setl dil
        ; branch t.9{r1}, true, @for_18_body
        or dil, dil
        jnz @for_18_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printSpaces
        ;   rsp+64: arg i
@printSpaces:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        sub rsp, 32
        ; move i{r8}, i{r1}
        mov bx, di
        ; 111:2 for i > 0
        jmp @for_20
@for_20_body:
        ; const t.2{r1}, 48
        mov dil, 48
        ; call printChar[t.2{r1}]
        call @printChar
        ; dec i{r8}
        dec bx
@for_20:
        ; gt t.1{r0}, i{r8}, 0
        cmp bx, 0
        setg al
        ; branch t.1{r0}, true, @for_20_body
        or al, al
        jnz @for_20_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; u8 getDigitCount
        ;   rsp+16: arg value
@getDigitCount:
        sub rsp, 8
        ; const count{r2}, 0
        mov sil, 0
        ; 118:2 if value < 0
        ; lt t.2{r4}, value{r1}, 0
        cmp di, 0
        setl cl
        ; branch t.2{r4}, false, @while_22
        or cl, cl
        jz @while_22
        ; const count{r2}, 1
        mov sil, 1
        ; neg value{r1}, value{r1}
        neg rdi
@while_22:
        ; inc count{r2}
        inc sil
        ; const t.3{r4}, 10
        mov cx, 10
        ; move value{r0}, value{r1}
        mov ax, di
        ; div value{r0}, value{r0}, t.3{r4}
        movsx rax, ax
        movsx rcx, cx
        cqo
        idiv rcx
        ; move value{r1}, value{r0}
        mov di, ax
        ; 126:3 if value == 0
        ; equals t.4{r3}, value{r1}, 0
        cmp di, 0
        sete dl
        ; branch t.4{r3}, false, @while_22
        or dl, dl
        jz @while_22
        ; 131:9 return count
        ; move count{r0}, count{r2}
        mov al, sil
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+64: var c
@getHiddenCount:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; const count{r8}, 0
        mov bx, 0
        ; const r{r9}, 0
        mov r12w, 0
        ; 136:2 for r < 20
        jmp @for_24
@for_24_body:
        ; const c{r2}, 0
        mov si, 0
        ; 137:3 for c < 40
        ; move c{r1}, c{r2}
        mov di, si
        jmp @for_25
@for_25_body:
        ; move c{r2}, c{r1}
        mov si, di
        ; move r{r1}, r{r9}
        mov di, r12w
        ; move c, c{r2}
        lea r11, [rsp+64]
        mov [r11], si
        ; call cell{r0} = getCell[r{r1}, c{r2}] -> u8
        call @getCell
        ; 139:4 if cell & 6 == 0
        ; const t.8{r1}, 6
        mov dil, 6
        ; move t.7{r2}, cell{r0}
        mov sil, al
        ; and t.7{r2}, t.7{r2}, t.8{r1}
        and sil, dil
        ; equals t.6{r1}, t.7{r2}, 0
        cmp sil, 0
        sete dil
        ; branch t.6{r1}, false, @for_25_continue
        or dil, dil
        jz @for_25_continue
        ; inc count{r8}
        inc bx
@for_25_continue:
        ; move c{r1}, c
        lea r11, [rsp+64]
        mov di, [r11]
        ; inc c{r1}
        inc di
@for_25:
        ; lt t.5{r2}, c{r1}, 40
        cmp di, 40
        setl sil
        ; branch t.5{r2}, true, @for_25_body
        or sil, sil
        jnz @for_25_body
        ; inc r{r9}
        inc r12w
@for_24:
        ; lt t.4{r1}, r{r9}, 20
        cmp r12w, 20
        setl dil
        ; branch t.4{r1}, true, @for_24_body
        or dil, dil
        jnz @for_24_body
        ; 144:9 return count
        ; move count{r0}, count{r8}
        mov ax, bx
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; bool printLeft
        ;   rsp+64: var bombDigits
@printLeft:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; call count{r0} = getHiddenCount[] -> i16
        call @getHiddenCount
        ; move count{r8}, count{r0}
        mov bx, ax
        ; move count{r1}, count{r8}
        mov di, bx
        ; call t.3{r0} = getDigitCount[count{r1}] -> u8
        call @getDigitCount
        ; cast leftDigits{r9}(i16), t.3{r0}(u8)
        movzx r12w, al
        ; const t.5{r1}, 40
        mov di, 40
        ; call t.4{r0} = getDigitCount[t.5{r1}] -> u8
        call @getDigitCount
        ; cast bombDigits{r0}(i16), t.4{r0}(u8)
        movzx ax, al
        ; move bombDigits, bombDigits{r0}
        lea r11, [rsp+64]
        mov [r11], ax
        ; const t.6{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString[t.6{r1}]
        call @printString
        ; move bombDigits{r0}, bombDigits
        lea r11, [rsp+64]
        mov ax, [r11]
        ; move t.7{r1}, bombDigits{r0}
        mov di, ax
        ; sub t.7{r1}, t.7{r1}, leftDigits{r9}
        sub di, r12w
        ; call printSpaces[t.7{r1}]
        call @printSpaces
        ; cast t.8{r1}(i64), count{r8}(i16)
        movzx rdi, bx
        ; call printUint[t.8{r1}]
        call @printUint
        ; 155:15 return count == 0
        ; equals t.9{r0}, count{r8}, 0
        cmp bx, 0
        sete al
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i16 abs
        ;   rsp+16: arg a
@abs:
        sub rsp, 8
        ; 159:2 if a < 0
        ; lt t.1{r2}, a{r1}, 0
        cmp di, 0
        setl sil
        ; branch t.1{r2}, true, @if_27_then
        or sil, sil
        jnz @if_27_then
        ; 162:9 return a
        ; move a{r0}, a{r1}
        mov ax, di
        jmp @abs_ret
@if_27_then:
        ; 160:10 return -a
        ; neg t.2{r1}, a{r1}
        neg rdi
        ; move t.2{r0}, t.2{r1}
        mov ax, di
@abs_ret:
        add rsp, 8
        ret

        ; void clearField
@clearField:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; const r{r8}, 0
        mov bx, 0
        ; 166:2 for r < 20
        jmp @for_28
@for_28_body:
        ; const c{r9}, 0
        mov r12w, 0
        ; 167:3 for c < 40
        jmp @for_29
@for_29_body:
        ; const t.4{r3}, 0
        mov dl, 0
        ; move r{r1}, r{r8}
        mov di, bx
        ; move c{r2}, c{r9}
        mov si, r12w
        ; call setCell[r{r1}, c{r2}, t.4{r3}]
        call @setCell
        ; inc c{r9}
        inc r12w
@for_29:
        ; lt t.3{r0}, c{r9}, 40
        cmp r12w, 40
        setl al
        ; branch t.3{r0}, true, @for_29_body
        or al, al
        jnz @for_29_body
        ; inc r{r8}
        inc bx
@for_28:
        ; lt t.2{r0}, r{r8}, 20
        cmp bx, 20
        setl al
        ; branch t.2{r0}, true, @for_28_body
        or al, al
        jnz @for_28_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void initField
        ;   rsp+80: arg curr_r
        ;   rsp+88: arg curr_c
        ;   rsp+64: var bombs
        ;   rsp+66: var row
        ;   rsp+68: var column
        ;   rsp+70: var t.12
@initField:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; move curr_r{r8}, curr_r{r1}
        mov bx, di
        ; move curr_c{r9}, curr_c{r2}
        mov r12w, si
        ; const bombs{r0}, 40
        mov ax, 40
        ; move bombs, bombs{r0}
        lea r11, [rsp+64]
        mov [r11], ax
        ; 174:2 for bombs > 0
        ; move bombs{r0}, bombs
        lea r11, [rsp+64]
        mov ax, [r11]
        jmp @for_30
@for_30_body:
        ; move bombs, bombs{r0}
        lea r11, [rsp+64]
        mov [r11], ax
        ; call t.7{r0} = random[] -> i32
        call @random
        ; const t.8{r1}, 20
        mov edi, 20
        ; move t.6{r2}, t.7{r0}
        mov esi, eax
        ; move t.6{r0}, t.6{r2}
        mov eax, esi
        ; mod t.6{r3}, t.6{r0}, t.8{r1}
        movsxd rax, eax
        movsxd rdi, edi
        cqo
        idiv rdi
        ; move t.6{r2}, t.6{r3}
        mov esi, edx
        ; cast row{r1}(i16), t.6{r2}(i32)
        mov di, si
        ; move row, row{r1}
        lea r11, [rsp+66]
        mov [r11], di
        ; call t.10{r0} = random[] -> i32
        call @random
        ; const t.11{r2}, 40
        mov esi, 40
        ; move t.9{r4}, t.10{r0}
        mov ecx, eax
        ; move t.9{r0}, t.9{r4}
        mov eax, ecx
        ; mod t.9{r3}, t.9{r0}, t.11{r2}
        movsxd rax, eax
        movsxd rsi, esi
        cqo
        idiv rsi
        ; move t.9{r4}, t.9{r3}
        mov ecx, edx
        ; cast column{r2}(i16), t.9{r4}(i32)
        mov si, cx
        ; move column, column{r2}
        lea r11, [rsp+68]
        mov [r11], si
        ; 177:3 if abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=177:11], right=ExprVarAccess[varName=curr_r, index=0, scope=argument, type=i16, varIsArray=false, location=177:20], location=177:18]]) > 1 || abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_c, index=1, scope=argument, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1
        ; 178:4 logic or
        ; move row{r0}, row
        lea r11, [rsp+66]
        mov ax, [r11]
        ; move t.14{r1}, row{r0}
        mov di, ax
        ; move row, row{r0}
        lea r11, [rsp+66]
        mov [r11], ax
        ; sub t.14{r1}, t.14{r1}, curr_r{r8}
        sub di, bx
        ; call t.13{r0} = abs[t.14{r1}] -> i16
        call @abs
        ; gt t.12{r0}, t.13{r0}, 1
        cmp ax, 1
        setg al
        ; branch t.12{r0}, true, @no_critical_edge_10
        or al, al
        jnz @no_critical_edge_10
        ; move t.12, t.12{r0}
        lea r11, [rsp+70]
        mov [r11], al
        jmp @or_2nd_32
@no_critical_edge_10:
        ; move t.12, t.12{r0}
        lea r11, [rsp+70]
        mov [r11], al
        ; move t.12{r0}, t.12
        lea r11, [rsp+70]
        mov al, [r11]
        jmp @or_next_32
@or_2nd_32:
        ; move column{r0}, column
        lea r11, [rsp+68]
        mov ax, [r11]
        ; move t.16{r1}, column{r0}
        mov di, ax
        ; move column, column{r0}
        lea r11, [rsp+68]
        mov [r11], ax
        ; sub t.16{r1}, t.16{r1}, curr_c{r9}
        sub di, r12w
        ; call t.15{r0} = abs[t.16{r1}] -> i16
        call @abs
        ; gt t.12{r0}, t.15{r0}, 1
        cmp ax, 1
        setg al
@or_next_32:
        ; branch t.12{r0}, false, @for_30_continue
        or al, al
        jz @for_30_continue
        ; const t.17{r3}, 1
        mov dl, 1
        ; move row{r1}, row
        lea r11, [rsp+66]
        mov di, [r11]
        ; move column{r2}, column
        lea r11, [rsp+68]
        mov si, [r11]
        ; call setCell[row{r1}, column{r2}, t.17{r3}]
        call @setCell
@for_30_continue:
        ; move bombs{r0}, bombs
        lea r11, [rsp+64]
        mov ax, [r11]
        ; dec bombs{r0}
        dec ax
@for_30:
        ; gt t.5{r1}, bombs{r0}, 0
        cmp ax, 0
        setg dil
        ; branch t.5{r1}, true, @for_30_body
        or dil, dil
        jnz @for_30_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void maybeRevealAround
        ;   rsp+96: arg row
        ;   rsp+104: arg column
        ;   rsp+64: var dr
        ;   rsp+66: var r
        ;   rsp+68: var dc
        ;   rsp+70: var c
        ;   rsp+72: var cell
@maybeRevealAround:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; move row{r8}, row{r1}
        mov bx, di
        ; move column{r9}, column{r2}
        mov r12w, si
        ; 185:2 if getBombCountAround([ExprVarAccess[varName=row, index=0, scope=argument, type=i16, varIsArray=false, location=185:25], ExprVarAccess[varName=column, index=1, scope=argument, type=i16, varIsArray=false, location=185:30]]) != 0
        ; move row{r1}, row{r8}
        mov di, bx
        ; move column{r2}, column{r9}
        mov si, r12w
        ; call t.8{r0} = getBombCountAround[row{r1}, column{r2}] -> u8
        call @getBombCountAround
        ; notequals t.7{r0}, t.8{r0}, 0
        cmp al, 0
        setne al
        ; branch t.7{r0}, true, @maybeRevealAround_ret
        or al, al
        jnz @maybeRevealAround_ret
        ; const dr{r0}, -1
        mov ax, -1
        ; 189:2 for dr <= 1
        jmp @for_34
@for_34_body:
        ; move r{r1}, row{r8}
        mov di, bx
        ; add r{r1}, r{r1}, dr{r0}
        add di, ax
        ; const dc{r3}, -1
        mov dx, -1
        ; 191:3 for dc <= 1
        ; move dr, dr{r0}
        lea r11, [rsp+64]
        mov [r11], ax
        ; move r, r{r1}
        lea r11, [rsp+66]
        mov [r11], di
        ; move dc{r0}, dc{r3}
        mov ax, dx
        jmp @for_35
@for_35_body:
        ; move dc{r3}, dc{r0}
        mov dx, ax
        ; move dr{r0}, dr
        lea r11, [rsp+64]
        mov ax, [r11]
        ; move r{r1}, r
        lea r11, [rsp+66]
        mov di, [r11]
        ; 192:4 if dr == 0 && dc == 0
        ; 192:16 logic and
        ; equals t.11{r4}, dr{r0}, 0
        cmp ax, 0
        sete cl
        ; move dr, dr{r0}
        lea r11, [rsp+64]
        mov [r11], ax
        ; branch t.11{r4}, false, @and_next_37
        or cl, cl
        jz @and_next_37
        ; equals t.11{r4}, dc{r3}, 0
        cmp dx, 0
        sete cl
@and_next_37:
        ; branch t.11{r4}, true, @if_36_then
        or cl, cl
        jnz @if_36_then
        ; move c{r2}, column{r9}
        mov si, r12w
        ; add c{r2}, c{r2}, dc{r3}
        add si, dx
        ; move dc, dc{r3}
        lea r11, [rsp+68]
        mov [r11], dx
        ; 197:4 if !checkCellBounds([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=197:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=197:28]])
        ; move r, r{r1}
        lea r11, [rsp+66]
        mov [r11], di
        ; move c, c{r2}
        lea r11, [rsp+70]
        mov [r11], si
        ; call t.13{r0} = checkCellBounds[r{r1}, c{r2}] -> bool
        call @checkCellBounds
        ; notlog t.12{r0}, t.13{r0}
        or al, al
        sete al
        ; branch t.12{r0}, false, @if_38_end
        or al, al
        jz @if_38_end
        jmp @for_35_continue
@if_36_then:
        ; move dc, dc{r3}
        lea r11, [rsp+68]
        mov [r11], dx
        ; move r, r{r1}
        lea r11, [rsp+66]
        mov [r11], di
        jmp @for_35_continue
@if_38_end:
        ; move r{r1}, r
        lea r11, [rsp+66]
        mov di, [r11]
        ; move r, r{r1}
        lea r11, [rsp+66]
        mov [r11], di
        ; move c{r2}, c
        lea r11, [rsp+70]
        mov si, [r11]
        ; move c, c{r2}
        lea r11, [rsp+70]
        mov [r11], si
        ; call cell{r0} = getCell[r{r1}, c{r2}] -> u8
        call @getCell
        ; 202:4 if isOpen([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=202:15]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; move cell, cell{r0}
        lea r11, [rsp+72]
        mov [r11], al
        ; call t.14{r0} = isOpen[cell{r1}] -> bool
        call @isOpen
        ; branch t.14{r0}, true, @for_35_continue
        or al, al
        jnz @for_35_continue
        ; const t.16{r0}, 2
        mov al, 2
        ; move cell{r4}, cell
        lea r11, [rsp+72]
        mov cl, [r11]
        ; move t.15{r3}, cell{r4}
        mov dl, cl
        ; or t.15{r3}, t.15{r3}, t.16{r0}
        or dl, al
        ; move r{r1}, r
        lea r11, [rsp+66]
        mov di, [r11]
        ; move r, r{r1}
        lea r11, [rsp+66]
        mov [r11], di
        ; move c{r2}, c
        lea r11, [rsp+70]
        mov si, [r11]
        ; move c, c{r2}
        lea r11, [rsp+70]
        mov [r11], si
        ; call setCell[r{r1}, c{r2}, t.15{r3}]
        call @setCell
        ; move r{r1}, r
        lea r11, [rsp+66]
        mov di, [r11]
        ; move r, r{r1}
        lea r11, [rsp+66]
        mov [r11], di
        ; move c{r2}, c
        lea r11, [rsp+70]
        mov si, [r11]
        ; call maybeRevealAround[r{r1}, c{r2}]
        call @maybeRevealAround
@for_35_continue:
        ; move dc{r0}, dc
        lea r11, [rsp+68]
        mov ax, [r11]
        ; inc dc{r0}
        inc ax
@for_35:
        ; lteq t.10{r1}, dc{r0}, 1
        cmp ax, 1
        setle dil
        ; branch t.10{r1}, true, @for_35_body
        or dil, dil
        jnz @for_35_body
        ; move dr{r0}, dr
        lea r11, [rsp+64]
        mov ax, [r11]
        ; inc dr{r0}
        inc ax
@for_34:
        ; lteq t.9{r1}, dr{r0}, 1
        cmp ax, 1
        setle dil
        ; branch t.9{r1}, true, @for_34_body
        or dil, dil
        jnz @for_34_body
@maybeRevealAround_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void main
        ;   rsp+64: var curr_r
        ;   rsp+66: var cell
        ;   rsp+67: var cell
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; const tmp.__random__{r8}, 0
        mov ebx, 0
        ; end initialize global variables
        ; const t.6{r1}, 7439742
        mov edi, 7439742
        ; move __random__, tmp.__random__{r8}
        lea r11, [var_0]
        mov [r11], ebx
        ; call initRandom[t.6{r1}]
        call @initRandom
        ; const needsInitialize{r8}, 1
        mov bl, 1
        ; call clearField[]
        call @clearField
        ; const t.7{r9}, 20
        mov r12b, 20
        ; cast curr_c{r9}(i16), t.7{r9}(u8)
        movzx r12w, r12b
        ; const t.8{r0}, 10
        mov al, 10
        ; cast curr_r{r0}(i16), t.8{r0}(u8)
        movzx ax, al
        ; move curr_r, curr_r{r0}
        lea r11, [rsp+64]
        mov [r11], ax
        ; 218:2 while true
        jmp @while_40
@if_41_then:
        ; 221:4 if printLeft([])
        ; call t.10{r0} = printLeft[] -> bool
        call @printLeft
        ; branch t.10{r0}, true, @if_42_then
        or al, al
        jnz @if_42_then
@if_41_end:
        ; call chr{r0} = getChar[] -> i16
        call @getChar
        ; move chr{r4}, chr{r0}
        mov cx, ax
        ; 228:3 if chr == 27
        ; equals t.12{r5}, chr{r4}, 27
        cmp cx, 27
        sete r8b
        ; branch t.12{r5}, true, @main_ret
        or r8b, r8b
        jnz @main_ret
        ; 233:3 if chr == 57416
        ; equals t.13{r5}, chr{r4}, 57416
        cmp cx, 57416
        sete r8b
        ; branch t.13{r5}, true, @if_44_then
        or r8b, r8b
        jnz @if_44_then
        ; 237:8 if chr == 57424
        ; equals t.19{r5}, chr{r4}, 57424
        cmp cx, 57424
        sete r8b
        ; branch t.19{r5}, false, @if_45_else
        or r8b, r8b
        jz @if_45_else
        jmp @if_45_then
@if_44_then:
        ; const t.16{r5}, 20
        mov r8w, 20
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+64]
        mov di, [r11]
        ; move t.15{r6}, curr_r{r1}
        mov r9w, di
        ; add t.15{r6}, t.15{r6}, t.16{r5}
        add r9w, r8w
        ; const t.17{r5}, 1
        mov r8w, 1
        ; move t.14{r1}, t.15{r6}
        mov di, r9w
        ; sub t.14{r1}, t.14{r1}, t.17{r5}
        sub di, r8w
        ; const t.18{r5}, 20
        mov r8w, 20
        ; move curr_r{r0}, curr_r{r1}
        mov ax, di
        ; mod curr_r{r3}, curr_r{r0}, t.18{r5}
        movsx rax, ax
        movsx r8, r8w
        cqo
        idiv r8
        ; move curr_r{r1}, curr_r{r3}
        mov di, dx
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        jmp @while_40
@if_45_else:
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+64]
        mov di, [r11]
        ; 241:8 if chr == 57419
        ; equals t.23{r5}, chr{r4}, 57419
        cmp cx, 57419
        sete r8b
        ; branch t.23{r5}, false, @if_46_else
        or r8b, r8b
        jz @if_46_else
        jmp @if_46_then
@if_45_then:
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+64]
        mov di, [r11]
        ; const t.21{r5}, 1
        mov r8w, 1
        ; add t.20{r1}, t.20{r1}, t.21{r5}
        add di, r8w
        ; const t.22{r5}, 20
        mov r8w, 20
        ; move curr_r{r0}, curr_r{r1}
        mov ax, di
        ; mod curr_r{r3}, curr_r{r0}, t.22{r5}
        movsx rax, ax
        movsx r8, r8w
        cqo
        idiv r8
        ; move curr_r{r1}, curr_r{r3}
        mov di, dx
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        jmp @while_40
@if_46_else:
        ; 245:8 if chr == 57419
        ; equals t.29{r5}, chr{r4}, 57419
        cmp cx, 57419
        sete r8b
        ; branch t.29{r5}, false, @if_47_else
        or r8b, r8b
        jz @if_47_else
        jmp @if_47_then
@if_46_then:
        ; const t.26{r5}, 40
        mov r8w, 40
        ; move t.25{r6}, curr_c{r9}
        mov r9w, r12w
        ; add t.25{r6}, t.25{r6}, t.26{r5}
        add r9w, r8w
        ; const t.27{r5}, 1
        mov r8w, 1
        ; move t.24{r9}, t.25{r6}
        mov r12w, r9w
        ; sub t.24{r9}, t.24{r9}, t.27{r5}
        sub r12w, r8w
        ; const t.28{r5}, 40
        mov r8w, 40
        ; move curr_c{r0}, curr_c{r9}
        mov ax, r12w
        ; mod curr_c{r3}, curr_c{r0}, t.28{r5}
        movsx rax, ax
        movsx r8, r8w
        cqo
        idiv r8
        ; move curr_c{r9}, curr_c{r3}
        mov r12w, dx
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        jmp @while_40
@if_47_else:
        ; 249:8 if chr == 57421
        ; equals t.35{r5}, chr{r4}, 57421
        cmp cx, 57421
        sete r8b
        ; branch t.35{r5}, false, @if_48_else
        or r8b, r8b
        jz @if_48_else
        jmp @if_48_then
@if_47_then:
        ; const t.32{r5}, 40
        mov r8w, 40
        ; move t.31{r6}, curr_c{r9}
        mov r9w, r12w
        ; add t.31{r6}, t.31{r6}, t.32{r5}
        add r9w, r8w
        ; const t.33{r5}, 1
        mov r8w, 1
        ; move t.30{r9}, t.31{r6}
        mov r12w, r9w
        ; sub t.30{r9}, t.30{r9}, t.33{r5}
        sub r12w, r8w
        ; const t.34{r5}, 40
        mov r8w, 40
        ; move curr_c{r0}, curr_c{r9}
        mov ax, r12w
        ; mod curr_c{r3}, curr_c{r0}, t.34{r5}
        movsx rax, ax
        movsx r8, r8w
        cqo
        idiv r8
        ; move curr_c{r9}, curr_c{r3}
        mov r12w, dx
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        jmp @while_40
@if_48_else:
        ; 253:8 if chr == 32
        ; equals t.39{r5}, chr{r4}, 32
        cmp cx, 32
        sete r8b
        ; branch t.39{r5}, false, @if_49_else
        or r8b, r8b
        jz @if_49_else
        jmp @if_49_then
@if_48_then:
        ; const t.37{r5}, 1
        mov r8w, 1
        ; add t.36{r9}, t.36{r9}, t.37{r5}
        add r12w, r8w
        ; const t.38{r5}, 40
        mov r8w, 40
        ; move curr_c{r0}, curr_c{r9}
        mov ax, r12w
        ; mod curr_c{r3}, curr_c{r0}, t.38{r5}
        movsx rax, ax
        movsx r8, r8w
        cqo
        idiv r8
        ; move curr_c{r9}, curr_c{r3}
        mov r12w, dx
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        jmp @while_40
@if_49_else:
        ; 262:8 if chr == 13
        ; equals t.44{r0}, chr{r4}, 13
        cmp cx, 13
        sete al
        ; branch t.44{r0}, false, @no_critical_edge_41
        or al, al
        jz @no_critical_edge_41
        jmp @if_52_then
@if_49_then:
        ; 254:4 if !needsInitialize
        ; notlog t.40{r0}, needsInitialize{r8}
        or bl, bl
        sete al
        ; branch t.40{r0}, false, @no_critical_edge_44
        or al, al
        jz @no_critical_edge_44
        jmp @if_50_then
@no_critical_edge_41:
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        jmp @while_40
@if_52_then:
        ; branch needsInitialize{r8}, false, @no_critical_edge_42
        or bl, bl
        jz @no_critical_edge_42
        jmp @if_53_then
@no_critical_edge_44:
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        jmp @while_40
@if_50_then:
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        ; move curr_c{r2}, curr_c{r9}
        mov si, r12w
        ; call cell{r0} = getCell[curr_r{r1}, curr_c{r2}] -> u8
        call @getCell
        ; 256:5 if !isOpen([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=256:17]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; move cell, cell{r0}
        lea r11, [rsp+66]
        mov [r11], al
        ; call t.42{r0} = isOpen[cell{r1}] -> bool
        call @isOpen
        ; notlog t.41{r0}, t.42{r0}
        or al, al
        sete al
        ; branch t.41{r0}, false, @while_40
        or al, al
        jz @while_40
        jmp @if_51_then
@no_critical_edge_42:
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        jmp @if_53_end
@if_53_then:
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        ; const needsInitialize{r8}, 0
        mov bl, 0
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+64]
        mov di, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        ; move curr_c{r2}, curr_c{r9}
        mov si, r12w
        ; call initField[curr_r{r1}, curr_c{r2}]
        call @initField
        jmp @if_53_end
@if_51_then:
        ; const t.43{r0}, 4
        mov al, 4
        ; move cell{r3}, cell
        lea r11, [rsp+66]
        mov dl, [r11]
        ; xor cell{r3}, cell{r3}, t.43{r0}
        xor dl, al
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+64]
        mov di, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        ; move curr_c{r2}, curr_c{r9}
        mov si, r12w
        ; call setCell[curr_r{r1}, curr_c{r2}, cell{r3}]
        call @setCell
        jmp @while_40
@if_53_end:
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+64]
        mov di, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        ; move curr_c{r2}, curr_c{r9}
        mov si, r12w
        ; call cell{r0} = getCell[curr_r{r1}, curr_c{r2}] -> u8
        call @getCell
        ; 268:4 if !isOpen([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=268:16]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; move cell, cell{r0}
        lea r11, [rsp+67]
        mov [r11], al
        ; call t.46{r0} = isOpen[cell{r1}] -> bool
        call @isOpen
        ; notlog t.45{r0}, t.46{r0}
        or al, al
        sete al
        ; branch t.45{r0}, false, @if_54_end
        or al, al
        jz @if_54_end
        ; const t.48{r0}, 2
        mov al, 2
        ; move cell{r4}, cell
        lea r11, [rsp+67]
        mov cl, [r11]
        ; move t.47{r3}, cell{r4}
        mov dl, cl
        ; move cell, cell{r4}
        lea r11, [rsp+67]
        mov [r11], cl
        ; or t.47{r3}, t.47{r3}, t.48{r0}
        or dl, al
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+64]
        mov di, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        ; move curr_c{r2}, curr_c{r9}
        mov si, r12w
        ; call setCell[curr_r{r1}, curr_c{r2}, t.47{r3}]
        call @setCell
@if_54_end:
        ; 271:4 if isBomb([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=271:15]])
        ; move cell{r1}, cell
        lea r11, [rsp+67]
        mov dil, [r11]
        ; call t.49{r0} = isBomb[cell{r1}] -> bool
        call @isBomb
        ; branch t.49{r0}, true, @if_55_then
        or al, al
        jnz @if_55_then
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+64]
        mov di, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        ; move curr_c{r2}, curr_c{r9}
        mov si, r12w
        ; call maybeRevealAround[curr_r{r1}, curr_c{r2}]
        call @maybeRevealAround
@while_40:
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+64]
        mov di, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+64]
        mov [r11], di
        ; move curr_c{r2}, curr_c{r9}
        mov si, r12w
        ; call printField[curr_r{r1}, curr_c{r2}]
        call @printField
        ; 220:3 if !needsInitialize
        ; notlog t.9{r0}, needsInitialize{r8}
        or bl, bl
        sete al
        ; branch t.9{r0}, false, @if_41_end
        or al, al
        jz @if_41_end
        jmp @if_41_then
@if_42_then:
        ; const t.11{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString[t.11{r1}]
        call @printString
        jmp @main_ret
@if_55_then:
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+64]
        mov di, [r11]
        ; move curr_c{r2}, curr_c{r9}
        mov si, r12w
        ; call printField[curr_r{r1}, curr_c{r2}]
        call @printField
        ; const t.50{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString[t.50{r1}]
        call @printString
@main_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printStringLength
@printStringLength:
        mov rdx, rsi
        mov rsi, rdi
        mov rdi, 1
        mov rax, 1
        syscall
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

segment readable writable
        ; variable 0: __random__ (i32/4)
        var_0 rb 4
        ; variable 1: field[] (u8*/6400)
        var_1 rb 6400

segment readable
        string_0 db '|', 0x0a, 0x00
        string_1 db 'Left: ', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

