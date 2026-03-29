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
        ; const t.2{r2}, 1
        mov sil, 1
        ; call printStringLength@@u8@u8[t.1{r1}, t.2{r2}]
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
        movzx rdi, di
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
        ; 21:2 while true
@while_1:
        ; const t.5{r4}, 1
        mov cl, 1
        ; sub pos{r8}, pos{r8}, t.5{r4}
        sub bl, cl
        ; const t.6{r4}, 10
        mov rcx, 10
        ; move remainder{r5}, number{r1}
        mov r8, rdi
        ; move remainder{r0}, remainder{r5}
        mov rax, r8
        ; mod remainder{r3}, remainder{r0}, t.6{r4}
        cqo
        idiv rcx
        ; move remainder{r5}, remainder{r3}
        mov r8, rdx
        ; const t.7{r4}, 10
        mov rcx, 10
        ; move number{r0}, number{r1}
        mov rax, rdi
        ; div number{r0}, number{r0}, t.7{r4}
        cqo
        idiv rcx
        ; move number{r1}, number{r0}
        mov rdi, rax
        ; cast t.8{r0}(u8), remainder{r5}(i64)
        mov al, r8b
        ; const t.9{r3}, 48
        mov dl, 48
        ; add digit{r0}, digit{r0}, t.9{r3}
        add al, dl
        ; cast t.11{r3}(i64), pos{r8}(u8)
        movzx rdx, bl
        ; addrof t.10{r4}, [buffer]
        lea rcx, [rsp+40]
        ; add t.10{r4}, t.10{r4}, t.11{r3}
        add rcx, rdx
        ; store [t.10{r4}], digit{r0}
        mov [rcx], al
        ; 27:3 if number == 0
        ; const t.13{r0}, 0
        mov rax, 0
        ; equals t.12{r0}, number{r1}, t.13{r0}
        cmp rdi, rax
        sete al
        ; branch t.12{r0}, false, @while_1, @while_1_break
        or al, al
        jz @while_1
        ; cast t.15{r0}(i64), pos{r8}(u8)
        movzx rax, bl
        ; addrof t.14{r1}, [buffer]
        lea rdi, [rsp+40]
        ; add t.14{r1}, t.14{r1}, t.15{r0}
        add rdi, rax
        ; const t.17{r0}, 20
        mov al, 20
        ; move t.16{r2}, t.17{r0}
        mov sil, al
        ; sub t.16{r2}, t.16{r2}, pos{r8}
        sub sil, bl
        ; call printStringLength@@u8@u8[t.14{r1}, t.16{r2}]
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
        ; 57:2 for *str != 0
        jmp @for_3
@for_3_body:
        ; const t.5{r2}, 1
        mov rsi, 1
        ; add length{r0}, length{r0}, t.5{r2}
        add rax, rsi
        ; const t.6{r2}, 1
        mov rsi, 1
        ; add str{r1}, str{r1}, t.6{r2}
        add rdi, rsi
@for_3:
        ; load t.3{r2}, [str{r1}]
        mov sil, [rdi]
        ; const t.4{r3}, 0
        mov dl, 0
        ; notequals t.2{r2}, t.3{r2}, t.4{r3}
        cmp sil, dl
        setne sil
        ; branch t.2{r2}, true, @for_3_body, @for_3_break
        or sil, sil
        jnz @for_3_body
        ; 60:9 return length
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
        ; move t.17{r3}, e{r1}
        mov edx, edi
        ; and t.17{r3}, t.17{r3}, t.18{r2}
        and edx, esi
        ; const t.20{r4}, 31
        mov ecx, 31
        ; shiftright t.19{r1}, t.19{r1}, t.20{r4}
        sar edi, cl
        ; move tmp.__random__{r0}, t.17{r3}
        mov eax, edx
        ; add tmp.__random__{r0}, tmp.__random__{r0}, t.19{r1}
        add eax, edi
        ; 142:9 return __random__
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

        ; i16 rowColumnToCell@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
@rowColumnToCell@i16@i16:
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

        ; u8 getCell@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
@getCell@i16@i16:
        sub rsp, 8
        ; 19:15 return [...]
        ; call t.5{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call @rowColumnToCell@i16@i16
        ; cast t.4{r1}(i64), t.5{r0}(i16)
        movzx rdi, ax
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
        ; 23:27 return cell & 1 != 0
        ; const t.3{r2}, 1
        mov sil, 1
        ; and t.2{r1}, t.2{r1}, t.3{r2}
        and dil, sil
        ; const t.4{r2}, 0
        mov sil, 0
        ; notequals t.1{r0}, t.2{r1}, t.4{r2}
        cmp dil, sil
        setne al
        add rsp, 8
        ret

        ; bool isOpen@u8
        ;   rsp+0: arg cell
@isOpen@u8:
        sub rsp, 8
        ; 27:27 return cell & 2 != 0
        ; const t.3{r2}, 2
        mov sil, 2
        ; and t.2{r1}, t.2{r1}, t.3{r2}
        and dil, sil
        ; const t.4{r2}, 0
        mov sil, 0
        ; notequals t.1{r0}, t.2{r1}, t.4{r2}
        cmp dil, sil
        setne al
        add rsp, 8
        ret

        ; bool isFlag@u8
        ;   rsp+0: arg cell
@isFlag@u8:
        sub rsp, 8
        ; 31:27 return cell & 4 != 0
        ; const t.3{r2}, 4
        mov sil, 4
        ; and t.2{r1}, t.2{r1}, t.3{r2}
        and dil, sil
        ; const t.4{r2}, 0
        mov sil, 0
        ; notequals t.1{r0}, t.2{r1}, t.4{r2}
        cmp dil, sil
        setne al
        add rsp, 8
        ret

        ; bool checkCellBounds@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
@checkCellBounds@i16@i16:
        sub rsp, 8
        ; 36:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 36:21 logic and
        ; 36:6 logic and
        ; 35:21 logic and
        ; const t.3{r3}, 0
        mov dx, 0
        ; gteq t.2{r0}, row{r1}, t.3{r3}
        cmp di, dx
        setge al
        ; branch t.2{r0}, false, @and_next_6, @and_2nd_6
        or al, al
        jz @and_next_6
        ; const t.4{r3}, 20
        mov dx, 20
        ; lt t.2{r0}, row{r1}, t.4{r3}
        cmp di, dx
        setl al
@and_next_6:
        ; branch t.2{r0}, false, @and_next_5, @and_2nd_5
        or al, al
        jz @and_next_5
        ; const t.5{r1}, 0
        mov di, 0
        ; gteq t.2{r0}, column{r2}, t.5{r1}
        cmp si, di
        setge al
@and_next_5:
        ; branch t.2{r0}, false, @checkCellBounds@i16@i16_ret, @and_2nd_4
        or al, al
        jz @checkCellBounds@i16@i16_ret
        ; const t.6{r1}, 40
        mov di, 40
        ; lt t.2{r0}, column{r2}, t.6{r1}
        cmp si, di
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
        movzx rax, ax
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
        ; 45:2 for dr <= 1
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; move dr{r2}, dr{r0}
        mov si, ax
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
        ; move dr{r0}, dr{r2}
        mov ax, si
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
        ; 47:3 for dc <= 1
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; move dc{r2}, dc{r0}
        mov si, ax
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
        ; move dc{r0}, dc{r2}
        mov ax, si
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
        ; 49:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=49:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=49:27]])
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
        ; call t.12{r0} = checkCellBounds@i16@i16[r{r1}, c{r2}] -> bool
        call @checkCellBounds@i16@i16
        ; branch t.12{r0}, true, @if_9_then, @no_critical_edge_11
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
        ; 51:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=51:16]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; call t.13{r0} = isBomb@u8[cell{r1}] -> bool
        call @isBomb@u8
        ; branch t.13{r0}, true, @if_10_then, @no_critical_edge_12
        or al, al
        jnz @if_10_then
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp @for_8_continue
@if_10_then:
        ; const t.14{r1}, 1
        mov dil, 1
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; add count{r0}, count{r0}, t.14{r1}
        add al, dil
@for_8_continue:
        ; const t.15{r1}, 1
        mov di, 1
        ; addrof memVarAddr{r9}, dc
        lea r12, [rsp+42]
        ; load dc{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add dc{r2}, dc{r2}, t.15{r1}
        add si, di
@for_8:
        ; const t.11{r1}, 1
        mov di, 1
        ; lteq t.10{r1}, dc{r2}, t.11{r1}
        cmp si, di
        setle dil
        ; branch t.10{r1}, true, @for_8_body, @for_7_continue
        or dil, dil
        jnz @for_8_body
        ; const t.16{r1}, 1
        mov di, 1
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+38]
        ; load dr{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add dr{r2}, dr{r2}, t.16{r1}
        add si, di
@for_7:
        ; const t.9{r1}, 1
        mov di, 1
        ; lteq t.8{r1}, dr{r2}, t.9{r1}
        cmp si, di
        setle dil
        ; branch t.8{r1}, true, @for_7_body, @for_7_break
        or dil, dil
        jnz @for_7_body
        ; 57:9 return count
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
        ; 61:2 if rowCursor == row
        ; equals t.4{r1}, rowCursor{r3}, row{r1}
        cmp dx, di
        sete dil
        ; branch t.4{r1}, false, @if_11_end, @if_11_then
        or dil, dil
        jz @if_11_end
        ; 62:3 if columnCursor == column
        ; equals t.5{r1}, columnCursor{r4}, column{r2}
        cmp cx, si
        sete dil
        ; branch t.5{r1}, true, @if_12_then, @if_12_end
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
        ; branch t.7{r1}, false, @if_11_end, @if_13_then
        or dil, dil
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
        mov dil, 93
        ; move t.10{r0}, t.10{r1}
        mov al, dil
        jmp @getSpacer@i16@i16@i16@i16_ret
@if_11_end:
        ; 69:9 return 32
        ; const t.11{r1}, 32
        mov dil, 32
        ; move t.11{r0}, t.11{r1}
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
        ; 74:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=74:13]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.5{r0} = isOpen@u8[cell{r1}] -> bool
        call @isOpen@u8
        ; branch t.5{r0}, false, @if_14_else, @if_14_then
        or al, al
        jz @if_14_else
        ; 75:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:14]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.6{r0} = isBomb@u8[cell{r1}] -> bool
        call @isBomb@u8
        ; branch t.6{r0}, true, @if_15_then, @if_15_else
        or al, al
        jnz @if_15_then
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+34]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+36]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call count{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call @getBombCountAround@i16@i16
        ; 80:4 if count > 0
        ; const t.8{r2}, 0
        mov sil, 0
        ; gt t.7{r2}, count{r0}, t.8{r2}
        cmp al, sil
        seta sil
        ; branch t.7{r2}, false, @if_16_else, @if_16_then
        or sil, sil
        jz @if_16_else
        jmp @if_16_then
@if_15_then:
        ; const chr{r0}, 42
        mov al, 42
        ; move chr{r1}, chr{r0}
        mov dil, al
        jmp @if_14_end
@if_16_else:
        ; const chr{r0}, 32
        mov al, 32
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], al
        jmp @if_14_else
@if_16_then:
        ; const t.9{r8}, 48
        mov bl, 48
        ; add chr{r0}, chr{r0}, t.9{r8}
        add al, bl
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+38]
        ; load chr{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp @if_14_end
@if_14_else:
        ; 88:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=88:18]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.10{r0} = isFlag@u8[cell{r1}] -> bool
        call @isFlag@u8
        ; branch t.10{r0}, true, @if_17_then, @no_critical_edge_11
        or al, al
        jnz @if_17_then
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+38]
        ; load chr{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp @if_14_end
@if_17_then:
        ; const chr{r1}, 35
        mov dil, 35
@if_14_end:
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
        ; const t.7{r1}, 0
        mov di, 0
        ; const t.8{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[t.7{r1}, t.8{r2}]
        call @setCursor@i16@i16
        ; const row{r1}, 0
        mov di, 0
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; 96:2 for row < 20
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
        ; const t.11{r1}, 124
        mov dil, 124
        ; call printChar@u8[t.11{r1}]
        call @printChar@u8
        ; const column{r2}, 0
        mov si, 0
        ; 98:3 for column < 40
        ; move column{r5}, column{r2}
        mov r8w, si
        jmp @for_19
@for_19_body:
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move column{r2}, column{r5}
        mov si, r8w
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
        ; const t.14{r0}, 1
        mov ax, 1
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+38]
        ; load column{r5}, [memVarAddr{r9}]
        mov r8w, [r12]
        ; add column{r5}, column{r5}, t.14{r0}
        add r8w, ax
@for_19:
        ; const t.13{r0}, 40
        mov ax, 40
        ; lt t.12{r0}, column{r5}, t.13{r0}
        cmp r8w, ax
        setl al
        ; branch t.12{r0}, true, @for_19_body, @for_19_break
        or al, al
        jnz @for_19_body
        ; const t.15{r2}, 40
        mov si, 40
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
        ; load columnCursor{r4}, [memVarAddr{r9}]
        mov cx, [r12]
        ; addrof memVarAddr{r9}, columnCursor
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], columnCursor{r4}
        mov [r12], cx
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r1}, t.15{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call @getSpacer@i16@i16@i16@i16
        ; move spacer{r1}, spacer{r0}
        mov dil, al
        ; call printChar@u8[spacer{r1}]
        call @printChar@u8
        ; const t.16{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.16{r1}]
        call @printString@@u8
        ; const t.17{r0}, 1
        mov ax, 1
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add row{r1}, row{r1}, t.17{r0}
        add di, ax
@for_18:
        ; const t.10{r0}, 20
        mov ax, 20
        ; lt t.9{r0}, row{r1}, t.10{r0}
        cmp di, ax
        setl al
        ; branch t.9{r0}, true, @for_18_body, @printField@i16@i16_ret
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
        ; 111:2 for i > 0
        jmp @for_20
@for_20_body:
        ; const t.3{r1}, 48
        mov dil, 48
        ; call printChar@u8[t.3{r1}]
        call @printChar@u8
        ; const t.4{r0}, 1
        mov ax, 1
        ; sub i{r8}, i{r8}, t.4{r0}
        sub bx, ax
@for_20:
        ; const t.2{r0}, 0
        mov ax, 0
        ; gt t.1{r0}, i{r8}, t.2{r0}
        cmp bx, ax
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
        ; 118:2 if value < 0
        ; const t.3{r4}, 0
        mov cx, 0
        ; lt t.2{r4}, value{r1}, t.3{r4}
        cmp di, cx
        setl cl
        ; branch t.2{r4}, false, @while_22, @if_21_then
        or cl, cl
        jz @while_22
        ; const count{r2}, 1
        mov sil, 1
        ; neg value{r1}, value{r1}
        neg rdi
@while_22:
        ; const t.4{r4}, 1
        mov cl, 1
        ; add count{r2}, count{r2}, t.4{r4}
        add sil, cl
        ; const t.5{r4}, 10
        mov cx, 10
        ; move value{r0}, value{r1}
        mov ax, di
        ; div value{r0}, value{r0}, t.5{r4}
        movsx rax, ax
        movsx rcx, cx
        cqo
        idiv rcx
        ; move value{r1}, value{r0}
        mov di, ax
        ; 126:3 if value == 0
        ; const t.7{r3}, 0
        mov dx, 0
        ; equals t.6{r3}, value{r1}, t.7{r3}
        cmp di, dx
        sete dl
        ; branch t.6{r3}, false, @while_22, @while_22_break
        or dl, dl
        jz @while_22
        ; 131:9 return count
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
        ; 136:2 for r < 20
        ; move r{r2}, r{r1}
        mov si, di
        jmp @for_24
@for_24_body:
        ; move r{r1}, r{r2}
        mov di, si
        ; const c{r2}, 0
        mov si, 0
        ; 137:3 for c < 40
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
        ; 139:4 if cell & 6 == 0
        ; const t.10{r1}, 6
        mov dil, 6
        ; move t.9{r2}, cell{r0}
        mov sil, al
        ; and t.9{r2}, t.9{r2}, t.10{r1}
        and sil, dil
        ; const t.11{r1}, 0
        mov dil, 0
        ; equals t.8{r1}, t.9{r2}, t.11{r1}
        cmp sil, dil
        sete dil
        ; branch t.8{r1}, false, @for_25_continue, @if_26_then
        or dil, dil
        jz @for_25_continue
        ; const t.12{r1}, 1
        mov di, 1
        ; add count{r8}, count{r8}, t.12{r1}
        add bx, di
@for_25_continue:
        ; const t.13{r1}, 1
        mov di, 1
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add c{r2}, c{r2}, t.13{r1}
        add si, di
@for_25:
        ; const t.7{r1}, 40
        mov di, 40
        ; lt t.6{r1}, c{r2}, t.7{r1}
        cmp si, di
        setl dil
        ; branch t.6{r1}, true, @for_25_body, @for_24_continue
        or dil, dil
        jnz @for_25_body
        ; const t.14{r1}, 1
        mov di, 1
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+32]
        ; load r{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add r{r2}, r{r2}, t.14{r1}
        add si, di
@for_24:
        ; const t.5{r1}, 20
        mov di, 20
        ; lt t.4{r1}, r{r2}, t.5{r1}
        cmp si, di
        setl dil
        ; branch t.4{r1}, true, @for_24_body, @for_24_break
        or dil, dil
        jnz @for_24_body
        ; 144:9 return count
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
        ; const t.5{r1}, 40
        mov di, 40
        ; call t.4{r0} = getDigitCount@i16[t.5{r1}] -> u8
        call @getDigitCount@i16
        ; cast bombDigits{r0}(i16), t.4{r0}(u8)
        movzx ax, al
        ; addrof memVarAddr{r9}, bombDigits
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombDigits{r0}
        mov [r12], ax
        ; const t.6{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.6{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r9}, bombDigits
        lea r12, [rsp+34]
        ; load bombDigits{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.7{r1}, bombDigits{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, leftDigits
        lea r12, [rsp+32]
        ; load leftDigits{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub t.7{r1}, t.7{r1}, leftDigits{r0}
        sub di, ax
        ; call printSpaces@i16[t.7{r1}]
        call @printSpaces@i16
        ; move count{r1}, count{r8}
        mov di, bx
        ; call printUint@i16[count{r1}]
        call @printUint@i16
        ; 155:15 return count == 0
        ; const t.9{r1}, 0
        mov di, 0
        ; equals t.8{r0}, count{r8}, t.9{r1}
        cmp bx, di
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
        ; 159:2 if a < 0
        ; const t.2{r2}, 0
        mov si, 0
        ; lt t.1{r2}, a{r1}, t.2{r2}
        cmp di, si
        setl sil
        ; branch t.1{r2}, true, @if_27_then, @if_27_end
        or sil, sil
        jnz @if_27_then
        ; 162:9 return a
        ; move a{r0}, a{r1}
        mov ax, di
        jmp @abs@i16_ret
@if_27_then:
        ; 160:10 return -a
        ; neg t.3{r1}, a{r1}
        neg rdi
        ; move t.3{r0}, t.3{r1}
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
        ; 166:2 for r < 20
        jmp @for_28
@for_28_body:
        ; const c{r9}, 0
        mov r12w, 0
        ; 167:3 for c < 40
        jmp @for_29
@for_29_body:
        ; const t.6{r3}, 0
        mov dl, 0
        ; move r{r1}, r{r8}
        mov di, bx
        ; move c{r2}, c{r9}
        mov si, r12w
        ; call setCell@i16@i16@u8[r{r1}, c{r2}, t.6{r3}]
        call @setCell@i16@i16@u8
        ; const t.7{r0}, 1
        mov ax, 1
        ; add c{r9}, c{r9}, t.7{r0}
        add r12w, ax
@for_29:
        ; const t.5{r0}, 40
        mov ax, 40
        ; lt t.4{r0}, c{r9}, t.5{r0}
        cmp r12w, ax
        setl al
        ; branch t.4{r0}, true, @for_29_body, @for_28_continue
        or al, al
        jnz @for_29_body
        ; const t.8{r0}, 1
        mov ax, 1
        ; add r{r8}, r{r8}, t.8{r0}
        add bx, ax
@for_28:
        ; const t.3{r0}, 20
        mov ax, 20
        ; lt t.2{r0}, r{r8}, t.3{r0}
        cmp bx, ax
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
        ;   rsp+42: var t.13
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
        ; const bombs{r0}, 40
        mov ax, 40
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs{r0}
        mov [r12], ax
        ; 174:2 for bombs > 0
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; load bombs{r1}, [memVarAddr{r9}]
        mov di, [r12]
        jmp @for_30
@for_30_body:
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs{r1}
        mov [r12], di
        ; call t.8{r0} = random[] -> i32
        call @random
        ; const t.9{r1}, 20
        mov edi, 20
        ; move t.7{r2}, t.8{r0}
        mov esi, eax
        ; move t.7{r0}, t.7{r2}
        mov eax, esi
        ; mod t.7{r3}, t.7{r0}, t.9{r1}
        movsxd rax, eax
        movsxd rdi, edi
        cqo
        idiv rdi
        ; move t.7{r2}, t.7{r3}
        mov esi, edx
        ; cast row{r1}(i16), t.7{r2}(i32)
        mov di, si
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; call t.11{r0} = random[] -> i32
        call @random
        ; const t.12{r2}, 40
        mov esi, 40
        ; move t.10{r4}, t.11{r0}
        mov ecx, eax
        ; move t.10{r0}, t.10{r4}
        mov eax, ecx
        ; mod t.10{r3}, t.10{r0}, t.12{r2}
        movsxd rax, eax
        movsxd rsi, esi
        cqo
        idiv rsi
        ; move t.10{r4}, t.10{r3}
        mov ecx, edx
        ; cast column{r2}(i16), t.10{r4}(i32)
        mov si, cx
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; 177:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=177:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=177:20], location=177:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1
        ; 178:4 logic or
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; load row{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.15{r1}, row{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], row{r0}
        mov [r12], ax
        ; sub t.15{r1}, t.15{r1}, curr_r{r8}
        sub di, bx
        ; call t.14{r0} = abs@i16[t.15{r1}] -> i16
        call @abs@i16
        ; const t.16{r2}, 1
        mov si, 1
        ; gt t.13{r0}, t.14{r0}, t.16{r2}
        cmp ax, si
        setg al
        ; branch t.13{r0}, true, @no_critical_edge_8, @or_2nd_32
        or al, al
        jnz @no_critical_edge_8
        ; addrof memVarAddr{r9}, t.13
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], t.13{r0}
        mov [r12], al
        jmp @or_2nd_32
@no_critical_edge_8:
        ; addrof memVarAddr{r9}, t.13
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], t.13{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, t.13
        lea r12, [rsp+42]
        ; load t.13{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp @or_next_32
@or_2nd_32:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; load column{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.18{r1}, column{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+34]
        ; load curr_c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], column{r0}
        mov [r12], ax
        ; sub t.18{r1}, t.18{r1}, curr_c{r0}
        sub di, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_c{r0}
        mov [r12], ax
        ; call t.17{r0} = abs@i16[t.18{r1}] -> i16
        call @abs@i16
        ; const t.19{r4}, 1
        mov cx, 1
        ; gt t.13{r0}, t.17{r0}, t.19{r4}
        cmp ax, cx
        setg al
@or_next_32:
        ; branch t.13{r0}, false, @for_30_continue, @if_31_then
        or al, al
        jz @for_30_continue
        ; const t.20{r3}, 1
        mov dl, 1
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call setCell@i16@i16@u8[row{r1}, column{r2}, t.20{r3}]
        call @setCell@i16@i16@u8
@for_30_continue:
        ; const t.21{r0}, 1
        mov ax, 1
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; load bombs{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; sub bombs{r1}, bombs{r1}, t.21{r0}
        sub di, ax
@for_30:
        ; const t.6{r0}, 0
        mov ax, 0
        ; gt t.5{r0}, bombs{r1}, t.6{r0}
        cmp di, ax
        setg al
        ; branch t.5{r0}, true, @for_30_body, @initField@i16@i16_ret
        or al, al
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
        ; 185:2 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=185:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=185:30]]) != 0
        ; move row{r1}, row{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; call t.8{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call @getBombCountAround@i16@i16
        ; const t.9{r3}, 0
        mov dl, 0
        ; notequals t.7{r0}, t.8{r0}, t.9{r3}
        cmp al, dl
        setne al
        ; branch t.7{r0}, true, @maybeRevealAround@i16@i16_ret, @if_33_end
        or al, al
        jnz @maybeRevealAround@i16@i16_ret
        ; const dr{r0}, -1
        mov ax, -1
        ; 189:2 for dr <= 1
        ; move dr{r1}, dr{r0}
        mov di, ax
        jmp @for_34
@for_34_body:
        ; move dr{r0}, dr{r1}
        mov ax, di
        ; move r{r1}, row{r8}
        mov di, bx
        ; add r{r1}, r{r1}, dr{r0}
        add di, ax
        ; const dc{r3}, -1
        mov dx, -1
        ; 191:3 for dc <= 1
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], dr{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; move dc{r1}, dc{r3}
        mov di, dx
        jmp @for_35
@for_35_body:
        ; move dc{r3}, dc{r1}
        mov dx, di
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+36]
        ; load dr{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; 192:4 if dr == 0 && dc == 0
        ; 192:16 logic and
        ; const t.15{r4}, 0
        mov cx, 0
        ; equals t.14{r4}, dr{r0}, t.15{r4}
        cmp ax, cx
        sete cl
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], dr{r0}
        mov [r12], ax
        ; branch t.14{r4}, false, @and_next_37, @and_2nd_37
        or cl, cl
        jz @and_next_37
        ; const t.16{r0}, 0
        mov ax, 0
        ; equals t.14{r4}, dc{r3}, t.16{r0}
        cmp dx, ax
        sete cl
@and_next_37:
        ; branch t.14{r4}, false, @if_36_end, @no_critical_edge_17
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
        ; load column{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move c{r2}, column{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r0}
        mov [r12], ax
        ; add c{r2}, c{r2}, dc{r3}
        add si, dx
        ; addrof memVarAddr{r9}, dc
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], dc{r3}
        mov [r12], dx
        ; 197:4 if !checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=197:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=197:28]])
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], si
        ; call t.18{r0} = checkCellBounds@i16@i16[r{r1}, c{r2}] -> bool
        call @checkCellBounds@i16@i16
        ; notlog t.17{r0}, t.18{r0}
        or al, al
        sete al
        ; branch t.17{r0}, true, @for_35_continue, @if_38_end
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
        ; 202:4 if isOpen@u8([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=202:15]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; call t.19{r0} = isOpen@u8[cell{r1}] -> bool
        call @isOpen@u8
        ; branch t.19{r0}, true, @for_35_continue, @if_39_end
        or al, al
        jnz @for_35_continue
        ; const t.21{r0}, 2
        mov al, 2
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+44]
        ; load cell{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; move t.20{r3}, cell{r4}
        mov dl, cl
        ; or t.20{r3}, t.20{r3}, t.21{r0}
        or dl, al
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
        ; call setCell@i16@i16@u8[r{r1}, c{r2}, t.20{r3}]
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
        ; const t.22{r0}, 1
        mov ax, 1
        ; addrof memVarAddr{r9}, dc
        lea r12, [rsp+40]
        ; load dc{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add dc{r1}, dc{r1}, t.22{r0}
        add di, ax
@for_35:
        ; const t.13{r0}, 1
        mov ax, 1
        ; lteq t.12{r0}, dc{r1}, t.13{r0}
        cmp di, ax
        setle al
        ; branch t.12{r0}, true, @for_35_body, @for_34_continue
        or al, al
        jnz @for_35_body
        ; const t.23{r0}, 1
        mov ax, 1
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+36]
        ; load dr{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add dr{r1}, dr{r1}, t.23{r0}
        add di, ax
@for_34:
        ; const t.11{r0}, 1
        mov ax, 1
        ; lteq t.10{r0}, dr{r1}, t.11{r0}
        cmp di, ax
        setle al
        ; branch t.10{r0}, true, @for_34_body, @maybeRevealAround@i16@i16_ret
        or al, al
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
        ;   rsp+36: var chr
        ;   rsp+38: var cell
        ;   rsp+39: var cell
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
        ; const t.6{r1}, 7439742
        mov edi, 7439742
        ; addrof memVarAddr{r9}, __random__
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.__random__{r8}
        mov [r12], ebx
        ; call initRandom@i32[t.6{r1}]
        call @initRandom@i32
        ; const needsInitialize{r8}, 1
        mov bl, 1
        ; call clearField[]
        call @clearField
        ; const curr_c{r0}, 20
        mov ax, 20
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
        ; move chr{r4}, chr{r0}
        mov cx, ax
        ; 228:3 if chr == 27
        ; const t.11{r5}, 27
        mov r8w, 27
        ; equals t.10{r5}, chr{r4}, t.11{r5}
        cmp cx, r8w
        sete r8b
        ; branch t.10{r5}, true, @main_ret, @if_43_end
        or r8b, r8b
        jnz @main_ret
        ; 233:3 if chr == -8120
        ; const t.13{r5}, -8120
        mov r8w, -8120
        ; equals t.12{r5}, chr{r4}, t.13{r5}
        cmp cx, r8w
        sete r8b
        ; branch t.12{r5}, true, @if_44_then, @if_44_else
        or r8b, r8b
        jnz @if_44_then
        ; 237:8 if chr == -8112
        ; const t.20{r5}, -8112
        mov r8w, -8112
        ; equals t.19{r5}, chr{r4}, t.20{r5}
        cmp cx, r8w
        sete r8b
        ; branch t.19{r5}, false, @if_45_else, @if_45_then
        or r8b, r8b
        jz @if_45_else
        jmp @if_45_then
@if_44_then:
        ; const t.16{r4}, 20
        mov cx, 20
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move t.15{r5}, curr_r{r1}
        mov r8w, di
        ; add t.15{r5}, t.15{r5}, t.16{r4}
        add r8w, cx
        ; const t.17{r4}, 1
        mov cx, 1
        ; sub t.14{r5}, t.14{r5}, t.17{r4}
        sub r8w, cx
        ; const t.18{r4}, 20
        mov cx, 20
        ; move curr_r{r1}, t.14{r5}
        mov di, r8w
        ; move curr_r{r0}, curr_r{r1}
        mov ax, di
        ; mod curr_r{r3}, curr_r{r0}, t.18{r4}
        movsx rax, ax
        movsx rcx, cx
        cqo
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
        ; 241:8 if chr == -8117
        ; const t.25{r5}, -8117
        mov r8w, -8117
        ; equals t.24{r5}, chr{r4}, t.25{r5}
        cmp cx, r8w
        sete r8b
        ; branch t.24{r5}, false, @if_46_else, @if_46_then
        or r8b, r8b
        jz @if_46_else
        jmp @if_46_then
@if_45_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; const t.22{r4}, 1
        mov cx, 1
        ; move t.21{r5}, curr_r{r1}
        mov r8w, di
        ; add t.21{r5}, t.21{r5}, t.22{r4}
        add r8w, cx
        ; const t.23{r4}, 20
        mov cx, 20
        ; move curr_r{r1}, t.21{r5}
        mov di, r8w
        ; move curr_r{r0}, curr_r{r1}
        mov ax, di
        ; mod curr_r{r3}, curr_r{r0}, t.23{r4}
        movsx rax, ax
        movsx rcx, cx
        cqo
        idiv rcx
        ; move curr_r{r1}, curr_r{r3}
        mov di, dx
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp @while_40
@if_46_else:
        ; 245:8 if chr == -8117
        ; const t.32{r5}, -8117
        mov r8w, -8117
        ; equals t.31{r5}, chr{r4}, t.32{r5}
        cmp cx, r8w
        sete r8b
        ; branch t.31{r5}, false, @if_47_else, @if_47_then
        or r8b, r8b
        jz @if_47_else
        jmp @if_47_then
@if_46_then:
        ; const t.28{r4}, 40
        mov cx, 40
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move t.27{r5}, curr_c{r2}
        mov r8w, si
        ; add t.27{r5}, t.27{r5}, t.28{r4}
        add r8w, cx
        ; const t.29{r4}, 1
        mov cx, 1
        ; sub t.26{r5}, t.26{r5}, t.29{r4}
        sub r8w, cx
        ; const t.30{r4}, 40
        mov cx, 40
        ; move curr_c{r2}, t.26{r5}
        mov si, r8w
        ; move curr_c{r0}, curr_c{r2}
        mov ax, si
        ; mod curr_c{r3}, curr_c{r0}, t.30{r4}
        movsx rax, ax
        movsx rcx, cx
        cqo
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
        ; 249:8 if chr == -8115
        ; const t.39{r5}, -8115
        mov r8w, -8115
        ; equals t.38{r5}, chr{r4}, t.39{r5}
        cmp cx, r8w
        sete r8b
        ; branch t.38{r5}, false, @if_48_else, @if_48_then
        or r8b, r8b
        jz @if_48_else
        jmp @if_48_then
@if_47_then:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; const t.35{r4}, 40
        mov cx, 40
        ; move t.34{r5}, curr_c{r2}
        mov r8w, si
        ; add t.34{r5}, t.34{r5}, t.35{r4}
        add r8w, cx
        ; const t.36{r4}, 1
        mov cx, 1
        ; sub t.33{r5}, t.33{r5}, t.36{r4}
        sub r8w, cx
        ; const t.37{r4}, 40
        mov cx, 40
        ; move curr_c{r2}, t.33{r5}
        mov si, r8w
        ; move curr_c{r0}, curr_c{r2}
        mov ax, si
        ; mod curr_c{r3}, curr_c{r0}, t.37{r4}
        movsx rax, ax
        movsx rcx, cx
        cqo
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
        ; 253:8 if chr == 32
        ; const t.44{r5}, 32
        mov r8w, 32
        ; equals t.43{r5}, chr{r4}, t.44{r5}
        cmp cx, r8w
        sete r8b
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], chr{r4}
        mov [r12], cx
        ; branch t.43{r5}, false, @no_critical_edge_30, @if_49_then
        or r8b, r8b
        jz @no_critical_edge_30
        jmp @if_49_then
@if_48_then:
        ; const t.41{r4}, 1
        mov cx, 1
        ; move t.40{r5}, curr_c{r2}
        mov r8w, si
        ; add t.40{r5}, t.40{r5}, t.41{r4}
        add r8w, cx
        ; const t.42{r4}, 40
        mov cx, 40
        ; move curr_c{r2}, t.40{r5}
        mov si, r8w
        ; move curr_c{r0}, curr_c{r2}
        mov ax, si
        ; mod curr_c{r3}, curr_c{r0}, t.42{r4}
        movsx rax, ax
        movsx rcx, cx
        cqo
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
@no_critical_edge_30:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp @if_49_else
@if_49_then:
        ; 254:4 if !needsInitialize
        ; notlog t.45{r0}, needsInitialize{r8}
        or bl, bl
        sete al
        ; branch t.45{r0}, true, @if_50_then, @no_critical_edge_34
        or al, al
        jnz @if_50_then
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
        ; 256:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=256:17]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
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
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+38]
        ; load cell{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; xor cell{r3}, cell{r3}, t.48{r0}
        xor dl, al
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; call setCell@i16@i16@u8[curr_r{r1}, curr_c{r2}, cell{r3}]
        call @setCell@i16@i16@u8
@if_49_else:
        ; 262:8 if chr == 13
        ; const t.50{r0}, 13
        mov ax, 13
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+36]
        ; load chr{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; equals t.49{r0}, chr{r3}, t.50{r0}
        cmp dx, ax
        sete al
        ; branch t.49{r0}, true, @if_52_then, @while_40
        or al, al
        jnz @if_52_then
@while_40:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; call printField@i16@i16[curr_r{r1}, curr_c{r2}]
        call @printField@i16@i16
        ; 220:3 if !needsInitialize
        ; notlog t.7{r0}, needsInitialize{r8}
        or bl, bl
        sete al
        ; branch t.7{r0}, false, @if_41_end, @if_41_then
        or al, al
        jz @if_41_end
        jmp @if_41_then
@if_42_then:
        ; const t.9{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.9{r1}]
        call @printString@@u8
        jmp @main_ret
@if_52_then:
        ; branch needsInitialize{r8}, true, @if_53_then, @no_critical_edge_32
        or bl, bl
        jnz @if_53_then
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r8}, [memVarAddr{r9}]
        mov bx, [r12]
        jmp @if_53_end
@if_53_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r8}, [memVarAddr{r9}]
        mov bx, [r12]
        ; move curr_r{r1}, curr_r{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; call initField@i16@i16[curr_r{r1}, curr_c{r2}]
        call @initField@i16@i16
@if_53_end:
        ; move curr_r{r1}, curr_r{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; call cell{r0} = getCell@i16@i16[curr_r{r1}, curr_c{r2}] -> u8
        call @getCell@i16@i16
        ; 268:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=268:16]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
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
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+39]
        ; load cell{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; move t.53{r3}, cell{r4}
        mov dl, cl
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], cell{r4}
        mov [r12], cl
        ; or t.53{r3}, t.53{r3}, t.54{r0}
        or dl, al
        ; move curr_r{r1}, curr_r{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; call setCell@i16@i16@u8[curr_r{r1}, curr_c{r2}, t.53{r3}]
        call @setCell@i16@i16@u8
@if_54_end:
        ; 271:4 if isBomb@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=271:15]])
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+39]
        ; load cell{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; call t.55{r0} = isBomb@u8[cell{r1}] -> bool
        call @isBomb@u8
        ; branch t.55{r0}, true, @if_55_then, @if_55_end
        or al, al
        jnz @if_55_then
        ; move curr_r{r1}, curr_r{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call maybeRevealAround@i16@i16[curr_r{r1}, curr_c{r2}]
        call @maybeRevealAround@i16@i16
        jmp @main_ret
@if_55_then:
        ; move curr_r{r1}, curr_r{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call printField@i16@i16[curr_r{r1}, curr_c{r2}]
        call @printField@i16@i16
        ; const t.56{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString@@u8[t.56{r1}]
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
        ; variable 1: field[] (u8*/6400)
        var_1 rb 6400

segment readable
        string_0 db '|', 0x0a, 0x00
        string_1 db 'Left: ', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

