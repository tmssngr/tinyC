format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void printString@@u8
        ;   rsp+24: arg str
@printString@@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move str{r8}, str{r1}
        mov rbx, rdi
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; call length{r0} = strlen@@u8[str{r1}] -> i64
        call @strlen@@u8
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; move length{r2}, length{r0}
        mov rsi, rax
        ; call printStringLength@@u8@i64[str{r1}, length{r2}]
        call @printStringLength@@u8@i64
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void printChar@u8
        ;   rsp+32: arg chr
@printChar@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], chr{r1}
        mov [r12], dil
        ; addrof t.1{r1}, chr
        lea rdi, [rsp+32]
        ; const arg.0.1{r2}, 1
        mov sil, 1
        ; call printStringLength@@u8@u8[t.1{r1}, arg.0.1{r2}]
        call @printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printUint@i16
        ;   rsp+0: arg number
@printUint@i16:
        sub rsp, 8
        ; cast t.1{r1}(i64), number{r1}(i16)
        movsx rdi, di
        ; call printUint@i64[t.1{r1}]
        call @printUint@i64
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+24: arg number
        ;   rsp+40: var buffer
@printUint@i64:
        sub rsp, 48
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const pos{r8}, 20
        mov bl, 20
        ; 33:2 while true
@while_1:
        ; sub pos{r8}, pos{r8}, 1
        sub bl, 1
        ; move remainder{r5}, number{r1}
        mov r8, rdi
        ; move remainder{r0}, remainder{r5}
        mov rax, r8
        ; mod remainder{r3}, remainder{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder{r5}, remainder{r3}
        mov r8, rdx
        ; move number{r0}, number{r1}
        mov rax, rdi
        ; div number{r0}, number{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number{r1}, number{r0}
        mov rdi, rax
        ; cast t.5{r0}(u8), remainder{r5}(i64)
        mov al, r8b
        ; add digit{r0}, digit{r0}, 48
        add al, 48
        ; cast t.7{r3}(i64), pos{r8}(u8)
        movzx rdx, bl
        ; addrof t.6{r4}, [buffer]
        lea rcx, [rsp+40]
        ; add t.6{r4}, t.6{r4}, t.7{r3}
        add rcx, rdx
        ; store [t.6{r4}], digit{r0}
        mov [rcx], al
        ; 39:3 if number == 0
        ; equals t.8{r0}, number{r1}, 0
        cmp rdi, 0
        sete al
        ; branch t.8{r0}, false, @while_1, @while_1_break
        or al, al
        jz @while_1
        ; cast t.10{r0}(i64), pos{r8}(u8)
        movzx rax, bl
        ; addrof t.9{r1}, [buffer]
        lea rdi, [rsp+40]
        ; add t.9{r1}, t.9{r1}, t.10{r0}
        add rdi, rax
        ; const t.12{r0}, 20
        mov al, 20
        ; move t.11{r2}, t.12{r0}
        mov sil, al
        ; sub t.11{r2}, t.11{r2}, pos{r8}
        sub sil, bl
        ; call printStringLength@@u8@u8[t.9{r1}, t.11{r2}]
        call @printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 48
        ret

        ; i64 strlen@@u8
        ;   rsp+0: arg str
@strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 69:2 for *str != 0
        jmp @for_3
@for_3_body:
        ; add length{r0}, length{r0}, 1
        add rax, 1
        ; add str{r1}, str{r1}, 1
        add rdi, 1
@for_3:
        ; load t.3{r2}, [str{r1}]
        mov sil, [rdi]
        ; notequals t.2{r2}, t.3{r2}, 0
        cmp sil, 0
        setne sil
        ; branch t.2{r2}, true, @for_3_body, @for_3_break
        or sil, sil
        jnz @for_3_body
        ; 72:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+0: arg str
        ;   rsp+8: arg length
@printStringLength@@u8@u8:
        sub rsp, 24
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call @printStringLength@@u8@i64
        add rsp, 24
        ret

        ; void initRandom@i32
        ;   rsp+32: arg salt
@initRandom@i32:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move tmp.__random__{r0}, salt{r1}
        mov eax, edi
        ; addrof memVarAddr{r9}, __random__
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.__random__{r0}
        mov [r12], eax
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i32 random
@random:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; addrof memVarAddr{r9}, __random__
        lea r12, [var_0]
        ; load tmp.__random__{r0}, [memVarAddr{r9}]
        mov eax, [r12]
        ; move r{r1}, tmp.__random__{r0}
        mov edi, eax
        ; move t.5{r2}, r{r1}
        mov esi, edi
        ; and t.5{r2}, t.5{r2}, 524287
        and esi, 524287
        ; mul b{r2}, b{r2}, 48271
        movsxd rsi, esi
        imul  rsi, 48271
        ; shiftright t.6{r1}, t.6{r1}, 15
        sar edi, 15
        ; mul c{r1}, c{r1}, 48271
        movsxd rdi, edi
        imul  rdi, 48271
        ; move t.7{r3}, c{r1}
        mov edx, edi
        ; and t.7{r3}, t.7{r3}, 65535
        and edx, 65535
        ; shiftleft d{r3}, d{r3}, 15
        sal edx, 15
        ; shiftright t.9{r1}, t.9{r1}, 16
        sar edi, 16
        ; add t.8{r1}, t.8{r1}, b{r2}
        add edi, esi
        ; add e{r1}, e{r1}, d{r3}
        add edi, edx
        ; move t.10{r2}, e{r1}
        mov esi, edi
        ; and t.10{r2}, t.10{r2}, 2147483647
        and esi, 2147483647
        ; shiftright t.11{r1}, t.11{r1}, 31
        sar edi, 31
        ; move tmp.__random__{r0}, t.10{r2}
        mov eax, esi
        ; add tmp.__random__{r0}, tmp.__random__{r0}, t.11{r1}
        add eax, edi
        ; 16:9 return __random__
        ; addrof memVarAddr{r9}, __random__
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.__random__{r0}
        mov [r12], eax
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i16 random16
@random16:
        sub rsp, 8
        ; 20:23 return (i16) & 32767
        ; call t.2{r0} = random[] -> i32
        call @random
        ; cast t.1{r1}(i16), t.2{r0}(i32)
        mov di, ax
        ; move t.0{r0}, t.1{r1}
        mov ax, di
        ; and t.0{r0}, t.0{r0}, 32767
        and ax, 32767
        add rsp, 8
        ret

        ; i16 rowColumnToCell@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
@rowColumnToCell@i16@i16:
        sub rsp, 8
        ; 16:21 return row * 17 + column
        ; mul t.3{r1}, t.3{r1}, 17
        movsx rdi, di
        imul  rdi, 17
        ; move t.2{r0}, t.3{r1}
        mov ax, di
        ; add t.2{r0}, t.2{r0}, column{r2}
        add ax, si
        add rsp, 8
        ret

        ; u8 getCell@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
@getCell@i16@i16:
        sub rsp, 8
        ; 20:15 return [...]
        ; call t.5{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call @rowColumnToCell@i16@i16
        ; cast t.4{r1}(i64), t.5{r0}(i16)
        movsx rdi, ax
        ; addrof t.3{r2}, [field]
        lea rsi, [var_1]
        ; add t.3{r2}, t.3{r2}, t.4{r1}
        add rsi, rdi
        ; load t.2{r0}, [t.3{r2}]
        mov al, [rsi]
        add rsp, 8
        ret

        ; bool isBomb@u8
        ;   rsp+0: arg cell
@isBomb@u8:
        sub rsp, 8
        ; 24:27 return cell & 1 != 0
        ; and t.2{r1}, t.2{r1}, 1
        and dil, 1
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool isOpen@u8
        ;   rsp+0: arg cell
@isOpen@u8:
        sub rsp, 8
        ; 28:27 return cell & 2 != 0
        ; and t.2{r1}, t.2{r1}, 2
        and dil, 2
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool isFlag@u8
        ;   rsp+0: arg cell
@isFlag@u8:
        sub rsp, 8
        ; 32:27 return cell & 4 != 0
        ; and t.2{r1}, t.2{r1}, 4
        and dil, 4
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool checkCellBounds@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
@checkCellBounds@i16@i16:
        sub rsp, 8
        ; 37:21 return row >= 0 && row < 20 && column >= 0 && column < 17
        ; 37:21 logic and
        ; 37:6 logic and
        ; 36:21 logic and
        ; gteq t.2{r0}, row{r1}, 0
        cmp di, 0
        setge al
        ; branch t.2{r0}, false, @and_next_6, @and_2nd_6
        or al, al
        jz @and_next_6
        ; lt t.2{r0}, row{r1}, 20
        cmp di, 20
        setl al
@and_next_6:
        ; branch t.2{r0}, false, @and_next_5, @and_2nd_5
        or al, al
        jz @and_next_5
        ; gteq t.2{r0}, column{r2}, 0
        cmp si, 0
        setge al
@and_next_5:
        ; branch t.2{r0}, false, @checkCellBounds@i16@i16_ret, @and_2nd_4
        or al, al
        jz @checkCellBounds@i16@i16_ret
        ; lt t.2{r0}, column{r2}, 17
        cmp si, 17
        setl al
@checkCellBounds@i16@i16_ret:
        add rsp, 8
        ret

        ; void setCell@i16@i16@u8
        ;   rsp+24: arg row
        ;   rsp+26: arg column
        ;   rsp+28: arg cell
@setCell@i16@i16@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move cell{r8}, cell{r3}
        mov bl, dl
        ; call t.5{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call @rowColumnToCell@i16@i16
        ; cast t.4{r0}(i64), t.5{r0}(i16)
        movsx rax, ax
        ; addrof t.3{r1}, [field]
        lea rdi, [var_1]
        ; add t.3{r1}, t.3{r1}, t.4{r0}
        add rdi, rax
        ; store [t.3{r1}], cell{r8}
        mov [rdi], bl
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; u8 getBombCountAround@i16@i16
        ;   rsp+32: arg row
        ;   rsp+34: arg column
        ;   rsp+36: var count
        ;   rsp+38: var dr
        ;   rsp+40: var r
        ;   rsp+42: var dc
        ;   rsp+44: var c
@getBombCountAround@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bx, di
        ; const count{r0}, 0
        mov al, 0
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], count{r0}
        mov [r12], al
        ; const dr{r0}, -1
        mov ax, -1
        ; 46:2 for dr <= 1
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; move dr{r1}, dr{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp @for_7
@for_7_body:
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], count{r0}
        mov [r12], al
        ; move dr{r0}, dr{r1}
        mov ax, di
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move r{r1}, row{r8}
        mov di, bx
        ; add r{r1}, r{r1}, dr{r0}
        add di, ax
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], dr{r0}
        mov [r12], ax
        ; const dc{r0}, -1
        mov ax, -1
        ; 48:3 for dc <= 1
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; move dc{r1}, dc{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp @for_8
@for_8_body:
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], count{r0}
        mov [r12], al
        ; move dc{r0}, dc{r1}
        mov ax, di
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move c{r3}, column{r2}
        mov dx, si
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; add c{r3}, c{r3}, dc{r0}
        add dx, ax
        ; addrof memVarAddr{r9}, dc
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], dc{r0}
        mov [r12], ax
        ; 50:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=50:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=50:27]])
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; move c{r2}, c{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], c{r3}
        mov [r12], dx
        ; call t.10{r0} = checkCellBounds@i16@i16[r{r1}, c{r2}] -> bool
        call @checkCellBounds@i16@i16
        ; branch t.10{r0}, true, @if_9_then, @no_critical_edge_11
        or al, al
        jnz @if_9_then
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp @for_8_continue
@if_9_then:
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+44]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call cell{r0} = getCell@i16@i16[r{r1}, c{r2}] -> u8
        call @getCell@i16@i16
        ; 52:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=52:16]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; call t.11{r0} = isBomb@u8[cell{r1}] -> bool
        call @isBomb@u8
        ; branch t.11{r0}, true, @if_10_then, @no_critical_edge_12
        or al, al
        jnz @if_10_then
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp @for_8_continue
@if_10_then:
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; add count{r0}, count{r0}, 1
        add al, 1
@for_8_continue:
        ; addrof memVarAddr{r9}, dc
        lea r12, [rsp+42]
        ; load dc{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add dc{r1}, dc{r1}, 1
        add di, 1
@for_8:
        ; lteq t.9{r2}, dc{r1}, 1
        cmp di, 1
        setle sil
        ; branch t.9{r2}, true, @for_8_body, @for_7_continue
        or sil, sil
        jnz @for_8_body
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+38]
        ; load dr{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add dr{r1}, dr{r1}, 1
        add di, 1
@for_7:
        ; lteq t.8{r2}, dr{r1}, 1
        cmp di, 1
        setle sil
        ; branch t.8{r2}, true, @for_7_body, @for_7_break
        or sil, sil
        jnz @for_7_body
        ; 58:9 return count
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; u8 getSpacer@i16@i16@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
        ;   rsp+4: arg rowCursor
        ;   rsp+6: arg columnCursor
@getSpacer@i16@i16@i16@i16:
        sub rsp, 8
        ; 62:2 if rowCursor == row
        ; equals t.4{r1}, rowCursor{r3}, row{r1}
        cmp dx, di
        sete dil
        ; branch t.4{r1}, false, @if_11_end, @if_11_then
        or dil, dil
        jz @if_11_end
        ; 63:3 if columnCursor == column
        ; equals t.5{r1}, columnCursor{r4}, column{r2}
        cmp cx, si
        sete dil
        ; branch t.5{r1}, true, @if_12_then, @if_12_end
        or dil, dil
        jnz @if_12_then
        ; 66:3 if columnCursor == column - 1
        ; move t.8{r1}, column{r2}
        mov di, si
        ; sub t.8{r1}, t.8{r1}, 1
        sub di, 1
        ; equals t.7{r1}, columnCursor{r4}, t.8{r1}
        cmp cx, di
        sete dil
        ; branch t.7{r1}, false, @if_11_end, @if_13_then
        or dil, dil
        jz @if_11_end
        jmp @if_13_then
@if_12_then:
        ; 64:11 return 91
        ; const t.6{r0}, 91
        mov al, 91
        jmp @getSpacer@i16@i16@i16@i16_ret
@if_13_then:
        ; 67:11 return 93
        ; const t.9{r1}, 93
        mov dil, 93
        ; move t.9{r0}, t.9{r1}
        mov al, dil
        jmp @getSpacer@i16@i16@i16@i16_ret
@if_11_end:
        ; 70:9 return 32
        ; const t.10{r1}, 32
        mov dil, 32
        ; move t.10{r0}, t.10{r1}
        mov al, dil
@getSpacer@i16@i16@i16@i16_ret:
        add rsp, 8
        ret

        ; void printCell@u8@i16@i16
        ;   rsp+32: arg cell
        ;   rsp+34: arg row
        ;   rsp+36: arg column
        ;   rsp+38: var chr
@printCell@u8@i16@i16:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move cell{r8}, cell{r1}
        mov bl, dil
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], row{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], column{r3}
        mov [r12], dx
        ; const chr{r1}, 46
        mov dil, 46
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], chr{r1}
        mov [r12], dil
        ; 75:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:13]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.5{r0} = isOpen@u8[cell{r1}] -> bool
        call @isOpen@u8
        ; branch t.5{r0}, true, @if_14_then, @if_14_else
        or al, al
        jnz @if_14_then
        ; 89:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=89:18]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.8{r0} = isFlag@u8[cell{r1}] -> bool
        call @isFlag@u8
        ; branch t.8{r0}, false, @no_critical_edge_10, @if_17_then
        or al, al
        jz @no_critical_edge_10
        jmp @if_17_then
@if_14_then:
        ; 76:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=76:14]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.6{r0} = isBomb@u8[cell{r1}] -> bool
        call @isBomb@u8
        ; branch t.6{r0}, false, @if_15_else, @if_15_then
        or al, al
        jz @if_15_else
        jmp @if_15_then
@no_critical_edge_10:
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+38]
        ; load chr{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        jmp @if_14_end
@if_17_then:
        ; const chr{r8}, 35
        mov bl, 35
        jmp @if_14_end
@if_15_else:
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+34]
        ; load row{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move row{r1}, row{r2}
        mov di, si
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+36]
        ; load column{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; move column{r2}, column{r3}
        mov si, dx
        ; call count{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call @getBombCountAround@i16@i16
        ; 81:4 if count > 0
        ; gt t.7{r8}, count{r0}, 0
        cmp al, 0
        seta bl
        ; branch t.7{r8}, false, @if_16_else, @if_16_then
        or bl, bl
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
        ; move chr{r8}, count{r0}
        mov bl, al
        ; add chr{r8}, chr{r8}, 48
        add bl, 48
@if_14_end:
        ; move chr{r1}, chr{r8}
        mov dil, bl
        ; call printChar@u8[chr{r1}]
        call @printChar@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printField@i16@i16
        ;   rsp+32: arg rowCursor
        ;   rsp+34: arg columnCursor
        ;   rsp+36: var row
        ;   rsp+38: var column
@printField@i16@i16:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move rowCursor{r8}, rowCursor{r1}
        mov bx, di
        ; addrof memVarAddr{r9}, columnCursor
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], columnCursor{r2}
        mov [r12], si
        ; const arg.0.0{r1}, 0
        mov di, 0
        ; const arg.0.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call @setCursor@i16@i16
        ; const row{r1}, 0
        mov di, 0
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; 97:2 for row < 20
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        jmp @for_18
@for_18_body:
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; const arg.1.0{r1}, 124
        mov dil, 124
        ; call printChar@u8[arg.1.0{r1}]
        call @printChar@u8
        ; const column{r2}, 0
        mov si, 0
        ; 99:3 for column < 17
        jmp @for_19
@for_19_body:
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; move rowCursor{r3}, rowCursor{r8}
        mov dx, bx
        ; addrof memVarAddr{r9}, columnCursor
        lea r12, [rsp+34]
        ; load columnCursor{r4}, [memVarAddr{r9}]
        mov cx, [r12]
        ; addrof memVarAddr{r9}, columnCursor
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], columnCursor{r4}
        mov [r12], cx
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r1}, column{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call @getSpacer@i16@i16@i16@i16
        ; move spacer{r1}, spacer{r0}
        mov dil, al
        ; call printChar@u8[spacer{r1}]
        call @printChar@u8
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+38]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; call cell{r0} = getCell@i16@i16[row{r1}, column{r2}] -> u8
        call @getCell@i16@i16
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+38]
        ; load column{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], column{r3}
        mov [r12], dx
        ; call printCell@u8@i16@i16[cell{r1}, row{r2}, column{r3}]
        call @printCell@u8@i16@i16
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+38]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add column{r2}, column{r2}, 1
        add si, 1
@for_19:
        ; lt t.8{r0}, column{r2}, 17
        cmp si, 17
        setl al
        ; branch t.8{r0}, true, @for_19_body, @for_19_break
        or al, al
        jnz @for_19_body
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; move rowCursor{r3}, rowCursor{r8}
        mov dx, bx
        ; addrof memVarAddr{r9}, columnCursor
        lea r12, [rsp+34]
        ; load columnCursor{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move columnCursor{r4}, columnCursor{r2}
        mov cx, si
        ; addrof memVarAddr{r9}, columnCursor
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], columnCursor{r2}
        mov [r12], si
        ; const arg.6.1{r2}, 17
        mov si, 17
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r1}, arg.6.1{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call @getSpacer@i16@i16@i16@i16
        ; move spacer{r1}, spacer{r0}
        mov dil, al
        ; call printChar@u8[spacer{r1}]
        call @printChar@u8
        ; const t.9{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.9{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add row{r1}, row{r1}, 1
        add di, 1
@for_18:
        ; lt t.7{r0}, row{r1}, 20
        cmp di, 20
        setl al
        ; branch t.7{r0}, true, @for_18_body, @printField@i16@i16_ret
        or al, al
        jnz @for_18_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printSpaces@i16
        ;   rsp+24: arg i
@printSpaces@i16:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move i{r8}, i{r1}
        mov bx, di
        ; 112:2 for i > 0
        jmp @for_20
@for_20_body:
        ; const arg.0.0{r1}, 48
        mov dil, 48
        ; call printChar@u8[arg.0.0{r1}]
        call @printChar@u8
        ; sub i{r8}, i{r8}, 1
        sub bx, 1
@for_20:
        ; gt t.1{r0}, i{r8}, 0
        cmp bx, 0
        setg al
        ; branch t.1{r0}, true, @for_20_body, @printSpaces@i16_ret
        or al, al
        jnz @for_20_body
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; u8 getDigitCount@i16
        ;   rsp+0: arg value
@getDigitCount@i16:
        sub rsp, 8
        ; const count{r2}, 0
        mov sil, 0
        ; 119:2 if value < 0
        ; lt t.2{r5}, value{r1}, 0
        cmp di, 0
        setl r8b
        ; branch t.2{r5}, false, @while_22, @if_21_then
        or r8b, r8b
        jz @while_22
        ; const count{r2}, 1
        mov sil, 1
        ; neg value{r1}, value{r1}
        neg rdi
@while_22:
        ; add count{r2}, count{r2}, 1
        add sil, 1
        ; move value{r0}, value{r1}
        mov ax, di
        ; div value{r0}, value{r0}, 10
        movsx rax, ax
        cqo
        mov rcx, 10
        idiv rcx
        ; move value{r1}, value{r0}
        mov di, ax
        ; 127:3 if value == 0
        ; equals t.3{r3}, value{r1}, 0
        cmp di, 0
        sete dl
        ; branch t.3{r3}, false, @while_22, @while_22_break
        or dl, dl
        jz @while_22
        ; 132:9 return count
        ; move count{r0}, count{r2}
        mov al, sil
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+32: var r
        ;   rsp+34: var c
@getHiddenCount:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const count{r8}, 0
        mov bx, 0
        ; const r{r1}, 0
        mov di, 0
        ; 137:2 for r < 20
        jmp @for_24
@for_24_body:
        ; const c{r2}, 0
        mov si, 0
        ; 138:3 for c < 17
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        jmp @for_25
@for_25_body:
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+32]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], si
        ; call cell{r0} = getCell@i16@i16[r{r1}, c{r2}] -> u8
        call @getCell@i16@i16
        ; 140:4 if cell & 6 == 0
        ; move t.7{r1}, cell{r0}
        mov dil, al
        ; and t.7{r1}, t.7{r1}, 6
        and dil, 6
        ; equals t.6{r1}, t.7{r1}, 0
        cmp dil, 0
        sete dil
        ; branch t.6{r1}, false, @for_25_continue, @if_26_then
        or dil, dil
        jz @for_25_continue
        ; add count{r8}, count{r8}, 1
        add bx, 1
@for_25_continue:
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add c{r2}, c{r2}, 1
        add si, 1
@for_25:
        ; lt t.5{r1}, c{r2}, 17
        cmp si, 17
        setl dil
        ; branch t.5{r1}, true, @for_25_body, @for_24_continue
        or dil, dil
        jnz @for_25_body
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+32]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add r{r1}, r{r1}, 1
        add di, 1
@for_24:
        ; lt t.4{r2}, r{r1}, 20
        cmp di, 20
        setl sil
        ; branch t.4{r2}, true, @for_24_body, @for_24_break
        or sil, sil
        jnz @for_24_body
        ; 145:9 return count
        ; move count{r0}, count{r8}
        mov ax, bx
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; bool printLeft
        ;   rsp+32: var leftDigits
        ;   rsp+34: var bombDigits
@printLeft:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; call count{r0} = getHiddenCount[] -> i16
        call @getHiddenCount
        ; move count{r8}, count{r0}
        mov bx, ax
        ; move count{r1}, count{r8}
        mov di, bx
        ; call t.3{r0} = getDigitCount@i16[count{r1}] -> u8
        call @getDigitCount@i16
        ; cast leftDigits{r0}(i16), t.3{r0}(u8)
        movzx ax, al
        ; addrof memVarAddr{r9}, leftDigits
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], leftDigits{r0}
        mov [r12], ax
        ; const arg.2.0{r1}, 17
        mov di, 17
        ; call t.4{r0} = getDigitCount@i16[arg.2.0{r1}] -> u8
        call @getDigitCount@i16
        ; cast bombDigits{r0}(i16), t.4{r0}(u8)
        movzx ax, al
        ; addrof memVarAddr{r9}, bombDigits
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombDigits{r0}
        mov [r12], ax
        ; const t.5{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.5{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r9}, bombDigits
        lea r12, [rsp+34]
        ; load bombDigits{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.6{r1}, bombDigits{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, leftDigits
        lea r12, [rsp+32]
        ; load leftDigits{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub t.6{r1}, t.6{r1}, leftDigits{r0}
        sub di, ax
        ; call printSpaces@i16[t.6{r1}]
        call @printSpaces@i16
        ; move count{r1}, count{r8}
        mov di, bx
        ; call printUint@i16[count{r1}]
        call @printUint@i16
        ; 156:15 return count == 0
        ; equals t.7{r0}, count{r8}, 0
        cmp bx, 0
        sete al
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i16 abs@i16
        ;   rsp+0: arg a
@abs@i16:
        sub rsp, 8
        ; 160:2 if a < 0
        ; lt t.1{r2}, a{r1}, 0
        cmp di, 0
        setl sil
        ; branch t.1{r2}, true, @if_27_then, @if_27_end
        or sil, sil
        jnz @if_27_then
        ; 163:9 return a
        ; move a{r0}, a{r1}
        mov ax, di
        jmp @abs@i16_ret
@if_27_then:
        ; 161:10 return -a
        ; neg t.2{r1}, a{r1}
        neg rdi
        ; move t.2{r0}, t.2{r1}
        mov ax, di
@abs@i16_ret:
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
        ; const r{r8}, 0
        mov bx, 0
        ; 167:2 for r < 20
        jmp @for_28
@for_28_body:
        ; const c{r9}, 0
        mov r12w, 0
        ; 168:3 for c < 17
        jmp @for_29
@for_29_body:
        ; move r{r1}, r{r8}
        mov di, bx
        ; move c{r2}, c{r9}
        mov si, r12w
        ; const arg.0.2{r3}, 0
        mov dl, 0
        ; call setCell@i16@i16@u8[r{r1}, c{r2}, arg.0.2{r3}]
        call @setCell@i16@i16@u8
        ; add c{r9}, c{r9}, 1
        add r12w, 1
@for_29:
        ; lt t.3{r0}, c{r9}, 17
        cmp r12w, 17
        setl al
        ; branch t.3{r0}, true, @for_29_body, @for_28_continue
        or al, al
        jnz @for_29_body
        ; add r{r8}, r{r8}, 1
        add bx, 1
@for_28:
        ; lt t.2{r0}, r{r8}, 20
        cmp bx, 20
        setl al
        ; branch t.2{r0}, true, @for_28_body, @clearField_ret
        or al, al
        jnz @for_28_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void initField@i16@i16
        ;   rsp+32: arg curr_r
        ;   rsp+34: arg curr_c
        ;   rsp+36: var bombs
        ;   rsp+38: var row
        ;   rsp+40: var column
        ;   rsp+42: var t.8
@initField@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move curr_r{r8}, curr_r{r1}
        mov bx, di
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; const bombs{r0}, 17
        mov ax, 17
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs{r0}
        mov [r12], ax
        ; 175:2 for bombs > 0
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; load bombs{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        jmp @for_30
@for_30_body:
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs{r0}
        mov [r12], ax
        ; call t.6{r0} = random16[] -> i16
        call @random16
        ; move row{r1}, t.6{r0}
        mov di, ax
        ; move row{r0}, row{r1}
        mov ax, di
        ; mod row{r3}, row{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move row{r1}, row{r3}
        mov di, dx
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; call t.7{r0} = random16[] -> i16
        call @random16
        ; move column{r2}, t.7{r0}
        mov si, ax
        ; move column{r0}, column{r2}
        mov ax, si
        ; mod column{r3}, column{r0}, 17
        movsx rax, ax
        cqo
        mov rcx, 17
        idiv rcx
        ; move column{r2}, column{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; 178:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=179:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=179:20], location=179:18]]) > 1
        ; 179:4 logic or
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; load row{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.10{r1}, row{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], row{r0}
        mov [r12], ax
        ; sub t.10{r1}, t.10{r1}, curr_r{r8}
        sub di, bx
        ; call t.9{r0} = abs@i16[t.10{r1}] -> i16
        call @abs@i16
        ; gt t.8{r0}, t.9{r0}, 1
        cmp ax, 1
        setg al
        ; branch t.8{r0}, true, @no_critical_edge_8, @or_2nd_32
        or al, al
        jnz @no_critical_edge_8
        ; addrof memVarAddr{r9}, t.8
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], t.8{r0}
        mov [r12], al
        jmp @or_2nd_32
@no_critical_edge_8:
        ; addrof memVarAddr{r9}, t.8
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], t.8{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, t.8
        lea r12, [rsp+42]
        ; load t.8{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp @or_next_32
@or_2nd_32:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; load column{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.12{r1}, column{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], column{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+34]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; sub t.12{r1}, t.12{r1}, curr_c{r2}
        sub di, si
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; call t.11{r0} = abs@i16[t.12{r1}] -> i16
        call @abs@i16
        ; gt t.8{r0}, t.11{r0}, 1
        cmp ax, 1
        setg al
@or_next_32:
        ; branch t.8{r0}, false, @for_30_continue, @if_31_then
        or al, al
        jz @for_30_continue
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; load row{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move row{r1}, row{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; load column{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move column{r2}, column{r0}
        mov si, ax
        ; const arg.4.2{r3}, 1
        mov dl, 1
        ; call setCell@i16@i16@u8[row{r1}, column{r2}, arg.4.2{r3}]
        call @setCell@i16@i16@u8
@for_30_continue:
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; load bombs{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub bombs{r0}, bombs{r0}, 1
        sub ax, 1
@for_30:
        ; gt t.5{r1}, bombs{r0}, 0
        cmp ax, 0
        setg dil
        ; branch t.5{r1}, true, @for_30_body, @initField@i16@i16_ret
        or dil, dil
        jnz @for_30_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void maybeRevealAround@i16@i16
        ;   rsp+32: arg row
        ;   rsp+34: arg column
        ;   rsp+36: var dr
        ;   rsp+38: var r
        ;   rsp+40: var dc
        ;   rsp+42: var c
        ;   rsp+44: var cell
@maybeRevealAround@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bx, di
        ; 186:2 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=186:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=186:30]]) != 0
        ; move row{r1}, row{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; call t.8{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call @getBombCountAround@i16@i16
        ; notequals t.7{r0}, t.8{r0}, 0
        cmp al, 0
        setne al
        ; branch t.7{r0}, true, @maybeRevealAround@i16@i16_ret, @if_33_end
        or al, al
        jnz @maybeRevealAround@i16@i16_ret
        ; const dr{r0}, -1
        mov ax, -1
        ; 190:2 for dr <= 1
        jmp @for_34
@for_34_body:
        ; move r{r1}, row{r8}
        mov di, bx
        ; add r{r1}, r{r1}, dr{r0}
        add di, ax
        ; const dc{r3}, -1
        mov dx, -1
        ; 192:3 for dc <= 1
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], dr{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; move dc{r0}, dc{r3}
        mov ax, dx
        jmp @for_35
@for_35_body:
        ; move dc{r3}, dc{r0}
        mov dx, ax
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+36]
        ; load dr{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; 193:4 if dr == 0 && dc == 0
        ; 193:16 logic and
        ; equals t.11{r4}, dr{r0}, 0
        cmp ax, 0
        sete cl
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], dr{r0}
        mov [r12], ax
        ; branch t.11{r4}, false, @and_next_37, @and_2nd_37
        or cl, cl
        jz @and_next_37
        ; equals t.11{r4}, dc{r3}, 0
        cmp dx, 0
        sete cl
@and_next_37:
        ; branch t.11{r4}, false, @if_36_end, @no_critical_edge_17
        or cl, cl
        jz @if_36_end
        ; addrof memVarAddr{r9}, dc
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], dc{r3}
        mov [r12], dx
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        jmp @for_35_continue
@if_36_end:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move c{r0}, column{r2}
        mov ax, si
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; add c{r0}, c{r0}, dc{r3}
        add ax, dx
        ; addrof memVarAddr{r9}, dc
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], dc{r3}
        mov [r12], dx
        ; 198:4 if !checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=198:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=198:28]])
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; move c{r2}, c{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], ax
        ; call t.13{r0} = checkCellBounds@i16@i16[r{r1}, c{r2}] -> bool
        call @checkCellBounds@i16@i16
        ; notlog t.12{r0}, t.13{r0}
        or al, al
        sete al
        ; branch t.12{r0}, true, @for_35_continue, @if_38_end
        or al, al
        jnz @for_35_continue
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+42]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], si
        ; call cell{r0} = getCell@i16@i16[r{r1}, c{r2}] -> u8
        call @getCell@i16@i16
        ; 203:4 if isOpen@u8([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=203:15]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; call t.14{r0} = isOpen@u8[cell{r1}] -> bool
        call @isOpen@u8
        ; branch t.14{r0}, true, @for_35_continue, @if_39_end
        or al, al
        jnz @for_35_continue
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+44]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.15{r3}, cell{r0}
        mov dl, al
        ; or t.15{r3}, t.15{r3}, 2
        or dl, 2
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+42]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], si
        ; call setCell@i16@i16@u8[r{r1}, c{r2}, t.15{r3}]
        call @setCell@i16@i16@u8
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+42]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call maybeRevealAround@i16@i16[r{r1}, c{r2}]
        call @maybeRevealAround@i16@i16
@for_35_continue:
        ; addrof memVarAddr{r9}, dc
        lea r12, [rsp+40]
        ; load dc{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; add dc{r0}, dc{r0}, 1
        add ax, 1
@for_35:
        ; lteq t.10{r1}, dc{r0}, 1
        cmp ax, 1
        setle dil
        ; branch t.10{r1}, true, @for_35_body, @for_34_continue
        or dil, dil
        jnz @for_35_body
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+36]
        ; load dr{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; add dr{r0}, dr{r0}, 1
        add ax, 1
@for_34:
        ; lteq t.9{r1}, dr{r0}, 1
        cmp ax, 1
        setle dil
        ; branch t.9{r1}, true, @for_34_body, @maybeRevealAround@i16@i16_ret
        or dil, dil
        jnz @for_34_body
@maybeRevealAround@i16@i16_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void main
        ;   rsp+32: var curr_c
        ;   rsp+34: var curr_r
        ;   rsp+36: var cell
        ;   rsp+37: var cell
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; begin initialize global variables
        ; const tmp.__random__{r8}, 0
        mov ebx, 0
        ; end initialize global variables
        ; addrof memVarAddr{r9}, __random__
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.__random__{r8}
        mov [r12], ebx
        ; const arg.0.0{r1}, 7439742
        mov edi, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call @initRandom@i32
        ; const needsInitialize{r8}, 1
        mov bl, 1
        ; call clearField[]
        call @clearField
        ; const curr_c{r0}, 8
        mov ax, 8
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r0}
        mov [r12], ax
        ; const curr_r{r0}, 10
        mov ax, 10
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r0}
        mov [r12], ax
        ; 219:2 while true
        jmp @while_40
@if_41_then:
        ; 222:4 if printLeft([])
        ; call t.7{r0} = printLeft[] -> bool
        call @printLeft
        ; branch t.7{r0}, true, @if_42_then, @if_41_end
        or al, al
        jnz @if_42_then
@if_41_end:
        ; call chr{r0} = getChar[] -> i16
        call @getChar
        ; move chr{r5}, chr{r0}
        mov r8w, ax
        ; 229:3 if chr == 27
        ; equals t.9{r6}, chr{r5}, 27
        cmp r8w, 27
        sete r9b
        ; branch t.9{r6}, true, @main_ret, @if_43_end
        or r9b, r9b
        jnz @main_ret
        ; 234:3 if chr == -8120
        ; equals t.10{r6}, chr{r5}, -8120
        cmp r8w, -8120
        sete r9b
        ; branch t.10{r6}, true, @if_44_then, @if_44_else
        or r9b, r9b
        jnz @if_44_then
        ; 238:8 if chr == -8112
        ; equals t.13{r6}, chr{r5}, -8112
        cmp r8w, -8112
        sete r9b
        ; branch t.13{r6}, false, @if_45_else, @if_45_then
        or r9b, r9b
        jz @if_45_else
        jmp @if_45_then
@if_44_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move t.12{r5}, curr_r{r1}
        mov r8w, di
        ; add t.12{r5}, t.12{r5}, 20
        add r8w, 20
        ; sub t.11{r5}, t.11{r5}, 1
        sub r8w, 1
        ; move curr_r{r1}, t.11{r5}
        mov di, r8w
        ; move curr_r{r0}, curr_r{r1}
        mov ax, di
        ; mod curr_r{r3}, curr_r{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move curr_r{r1}, curr_r{r3}
        mov di, dx
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp @while_40
@if_45_else:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; 242:8 if chr == -8117
        ; equals t.15{r6}, chr{r5}, -8117
        cmp r8w, -8117
        sete r9b
        ; branch t.15{r6}, false, @if_46_else, @if_46_then
        or r9b, r9b
        jz @if_46_else
        jmp @if_46_then
@if_45_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move t.14{r5}, curr_r{r1}
        mov r8w, di
        ; add t.14{r5}, t.14{r5}, 1
        add r8w, 1
        ; move curr_r{r1}, t.14{r5}
        mov di, r8w
        ; move curr_r{r0}, curr_r{r1}
        mov ax, di
        ; mod curr_r{r3}, curr_r{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move curr_r{r1}, curr_r{r3}
        mov di, dx
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp @while_40
@if_46_else:
        ; 246:8 if chr == -8117
        ; equals t.18{r6}, chr{r5}, -8117
        cmp r8w, -8117
        sete r9b
        ; branch t.18{r6}, false, @if_47_else, @if_47_then
        or r9b, r9b
        jz @if_47_else
        jmp @if_47_then
@if_46_then:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move t.17{r5}, curr_c{r2}
        mov r8w, si
        ; add t.17{r5}, t.17{r5}, 17
        add r8w, 17
        ; sub t.16{r5}, t.16{r5}, 1
        sub r8w, 1
        ; move curr_c{r2}, t.16{r5}
        mov si, r8w
        ; move curr_c{r0}, curr_c{r2}
        mov ax, si
        ; mod curr_c{r3}, curr_c{r0}, 17
        movsx rax, ax
        cqo
        mov rcx, 17
        idiv rcx
        ; move curr_c{r2}, curr_c{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp @while_40
@if_47_else:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; 250:8 if chr == -8115
        ; equals t.21{r6}, chr{r5}, -8115
        cmp r8w, -8115
        sete r9b
        ; branch t.21{r6}, false, @if_48_else, @if_48_then
        or r9b, r9b
        jz @if_48_else
        jmp @if_48_then
@if_47_then:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move t.20{r5}, curr_c{r2}
        mov r8w, si
        ; add t.20{r5}, t.20{r5}, 17
        add r8w, 17
        ; sub t.19{r5}, t.19{r5}, 1
        sub r8w, 1
        ; move curr_c{r2}, t.19{r5}
        mov si, r8w
        ; move curr_c{r0}, curr_c{r2}
        mov ax, si
        ; mod curr_c{r3}, curr_c{r0}, 17
        movsx rax, ax
        cqo
        mov rcx, 17
        idiv rcx
        ; move curr_c{r2}, curr_c{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp @while_40
@if_48_else:
        ; 254:8 if chr == 32
        ; equals t.23{r6}, chr{r5}, 32
        cmp r8w, 32
        sete r9b
        ; branch t.23{r6}, false, @if_49_else, @if_49_then
        or r9b, r9b
        jz @if_49_else
        jmp @if_49_then
@if_48_then:
        ; move t.22{r5}, curr_c{r2}
        mov r8w, si
        ; add t.22{r5}, t.22{r5}, 1
        add r8w, 1
        ; move curr_c{r2}, t.22{r5}
        mov si, r8w
        ; move curr_c{r0}, curr_c{r2}
        mov ax, si
        ; mod curr_c{r3}, curr_c{r0}, 17
        movsx rax, ax
        cqo
        mov rcx, 17
        idiv rcx
        ; move curr_c{r2}, curr_c{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp @while_40
@if_49_else:
        ; 263:8 if chr == 13
        ; equals t.27{r0}, chr{r5}, 13
        cmp r8w, 13
        sete al
        ; branch t.27{r0}, false, @no_critical_edge_30, @if_52_then
        or al, al
        jz @no_critical_edge_30
        jmp @if_52_then
@if_49_then:
        ; 255:4 if !needsInitialize
        ; notlog t.24{r0}, needsInitialize{r8}
        or bl, bl
        sete al
        ; branch t.24{r0}, false, @no_critical_edge_33, @if_50_then
        or al, al
        jz @no_critical_edge_33
        jmp @if_50_then
@no_critical_edge_30:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp @while_40
@if_52_then:
        ; branch needsInitialize{r8}, false, @no_critical_edge_31, @if_53_then
        or bl, bl
        jz @no_critical_edge_31
        jmp @if_53_then
@no_critical_edge_33:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp @while_40
@if_50_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; call cell{r0} = getCell@i16@i16[curr_r{r1}, curr_c{r2}] -> u8
        call @getCell@i16@i16
        ; 257:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=257:17]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; call t.26{r0} = isOpen@u8[cell{r1}] -> bool
        call @isOpen@u8
        ; notlog t.25{r0}, t.26{r0}
        or al, al
        sete al
        ; branch t.25{r0}, false, @while_40, @if_51_then
        or al, al
        jz @while_40
        jmp @if_51_then
@no_critical_edge_31:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp @if_53_end
@if_53_then:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        ; const needsInitialize{r8}, 0
        mov bl, 0
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_r{r1}, curr_r{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_c{r2}, curr_c{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r0}
        mov [r12], ax
        ; call initField@i16@i16[curr_r{r1}, curr_c{r2}]
        call @initField@i16@i16
        jmp @if_53_end
@if_51_then:
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+36]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; xor cell{r0}, cell{r0}, 4
        xor al, 4
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; move cell{r3}, cell{r0}
        mov dl, al
        ; call setCell@i16@i16@u8[curr_r{r1}, curr_c{r2}, cell{r3}]
        call @setCell@i16@i16@u8
        jmp @while_40
@if_53_end:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_r{r1}, curr_r{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_c{r2}, curr_c{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r0}
        mov [r12], ax
        ; call cell{r0} = getCell@i16@i16[curr_r{r1}, curr_c{r2}] -> u8
        call @getCell@i16@i16
        ; 269:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=269:16]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; call t.29{r0} = isOpen@u8[cell{r1}] -> bool
        call @isOpen@u8
        ; notlog t.28{r0}, t.29{r0}
        or al, al
        sete al
        ; branch t.28{r0}, false, @if_54_end, @if_54_then
        or al, al
        jz @if_54_end
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+37]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.30{r3}, cell{r0}
        mov dl, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; or t.30{r3}, t.30{r3}, 2
        or dl, 2
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_r{r1}, curr_r{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_c{r2}, curr_c{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r0}
        mov [r12], ax
        ; call setCell@i16@i16@u8[curr_r{r1}, curr_c{r2}, t.30{r3}]
        call @setCell@i16@i16@u8
@if_54_end:
        ; 272:4 if isBomb@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=272:15]])
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+37]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; call t.31{r0} = isBomb@u8[cell{r1}] -> bool
        call @isBomb@u8
        ; branch t.31{r0}, true, @if_55_then, @if_55_end
        or al, al
        jnz @if_55_then
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_r{r1}, curr_r{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_c{r2}, curr_c{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r0}
        mov [r12], ax
        ; call maybeRevealAround@i16@i16[curr_r{r1}, curr_c{r2}]
        call @maybeRevealAround@i16@i16
@while_40:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_r{r1}, curr_r{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_c{r2}, curr_c{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r0}
        mov [r12], ax
        ; call printField@i16@i16[curr_r{r1}, curr_c{r2}]
        call @printField@i16@i16
        ; 221:3 if !needsInitialize
        ; notlog t.6{r0}, needsInitialize{r8}
        or bl, bl
        sete al
        ; branch t.6{r0}, false, @if_41_end, @if_41_then
        or al, al
        jz @if_41_end
        jmp @if_41_then
@if_42_then:
        ; const t.8{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.8{r1}]
        call @printString@@u8
        jmp @main_ret
@if_55_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_r{r1}, curr_r{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_c{r2}, curr_c{r0}
        mov si, ax
        ; call printField@i16@i16[curr_r{r1}, curr_c{r2}]
        call @printField@i16@i16
        ; const t.32{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString@@u8[t.32{r1}]
        call @printString@@u8
@main_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printStringLength@@u8@i64
@printStringLength@@u8@i64:
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

segment readable writable
        ; variable 0: __random__ (i32/4)
        var_0 rb 4
        ; variable 1: field[] (u8*/2720)
        var_1 rb 2720

segment readable
        string_0 db '|', 0x0a, 0x00
        string_1 db 'Left: ', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

