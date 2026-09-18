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
_printString@@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move str{r8}, str{r1}
        mov rbx, rdi
        ; call length.1{r0} = strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; move length.1{r2}, length.1{r0}
        mov rsi, rax
        ; call printStringLength@@u8@i64[str{r1}, length.1{r2}]
        call _printStringLength@@u8@i64
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void printChar@u8
        ;   rsp+32: arg chr
_printChar@u8:
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
        ; move t.1.1{r1}, t.1.1{r9}
        mov rdi, r12
        ; const arg.0.1{r2}, 1
        mov sil, 1
        ; call printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printUint@i16
        ;   rsp+0: arg number
_printUint@i16:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(i16)
        movsx rdi, di
        ; call printUint@i64[t.1.1{r1}]
        call _printUint@i64
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+24: arg number
        ;   rsp+40: var buffer
_printUint@i64:
        sub rsp, 48
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const pos.1{r8}, 20
        mov bl, 20
        ; 33:2 while true
        ; move number.1{r5}, number{r1}
        mov r8, rdi
_while_1:
        ; sub pos.3{r8}, 1
        sub bl, 1
        ; move remainder.1{r6}, number.1{r5}
        mov r9, r8
        ; move remainder.1{r0}, remainder.1{r6}
        mov rax, r9
        ; mod remainder.1{r3}, remainder.1{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder.1{r6}, remainder.1{r3}
        mov r9, rdx
        ; move number.2{r0}, number.2{r5}
        mov rax, r8
        ; div number.2{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number.2{r5}, number.2{r0}
        mov r8, rax
        ; cast t.5.1{r0}(u8), remainder.1{r6}(i64)
        mov al, r9b
        ; add digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r3}(i64), pos.3{r8}(u8)
        movzx rdx, bl
        ; addrof t.6.1{r4}, buffer
        lea rcx, [rsp+40]
        ; add t.6.2{r4}, t.7.1{r3}
        add rcx, rdx
        ; store [t.6.2{r4}], digit.1{r0}
        mov [rcx], al
        ; 39:3 if number == 0
        ; branch number.2{r5} notequals 0: while_1
        cmp r8, 0
        jne _while_1
        ; move t.9.1{r0}, t.9.1{r3}
        mov rax, rdx
        ; addrof t.8.1{r3}, buffer
        lea rdx, [rsp+40]
        ; move t.8.2{r1}, t.8.1{r3}
        mov rdi, rdx
        ; move t.8.2{r1}, t.8.2{r4}
        mov rdi, rcx
        ; const t.11.1{r0}, 20
        mov al, 20
        ; move t.10.1{r2}, t.11.1{r0}
        mov sil, al
        ; sub t.10.1{r2}, pos.3{r8}
        sub sil, bl
        ; call printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 48
        ret

        ; i64 strlen@@u8
        ;   rsp+0: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length.1{r2}, 0
        mov rsi, 0
        ; 69:2 for *str != 0
        ; move length.2{r0}, length.1{r2}
        mov rax, rsi
        jmp _for_3
_for_3_body:
        ; move length.3{r2}, length.2{r0}
        mov rsi, rax
        ; add length.3{r2}, 1
        add rsi, 1
        ; add str.2{r1}, 1
        add rdi, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rsi
_for_3:
        ; load t.2.1{r2}, [str.1{r1}]
        mov sil, [rdi]
        ; branch t.2.1{r2} notequals 0: for_3_body
        cmp sil, 0
        jne _for_3_body
        ; 72:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+0: arg str
        ;   rsp+8: arg length
_printStringLength@@u8@u8:
        sub rsp, 24
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 24
        ret

        ; void initRandom@i32
        ;   rsp+0: arg salt
_initRandom@i32:
        sub rsp, 8
        ; move t.1.1{r0}, salt{r1}
        mov eax, edi
        ; addrof a.2.1{r1}, __random__
        lea rdi, [var_0]
        ; store [a.2.1{r1}], t.1.1{r0}
        mov [rdi], eax
        add rsp, 8
        ret

        ; i32 random
_random:
        sub rsp, 8
        ; addrof a.5.1{r1}, __random__
        lea rdi, [var_0]
        ; load r.1{r1}, [a.5.1{r1}]
        mov edi, [rdi]
        ; move t.6.1{r2}, r.1{r1}
        mov esi, edi
        ; and t.6.1{r2}, 524287
        and esi, 524287
        ; mul b.1{r2}, 48271
        movsxd rsi, esi
        imul  rsi, 48271
        ; shiftright t.7.1{r1}, 15
        sar edi, 15
        ; mul c.1{r1}, 48271
        movsxd rdi, edi
        imul  rdi, 48271
        ; move t.8.1{r3}, c.1{r1}
        mov edx, edi
        ; and t.8.1{r3}, 65535
        and edx, 65535
        ; shiftleft d.1{r3}, 15
        sal edx, 15
        ; shiftright t.10.1{r1}, 16
        sar edi, 16
        ; add t.9.1{r1}, b.1{r2}
        add edi, esi
        ; add e.1{r1}, d.1{r3}
        add edi, edx
        ; move t.12.1{r2}, e.1{r1}
        mov esi, edi
        ; and t.12.1{r2}, 2147483647
        and esi, 2147483647
        ; shiftright t.13.1{r1}, 31
        sar edi, 31
        ; add t.11.1{r2}, t.13.1{r1}
        add esi, edi
        ; addrof a.14.1{r1}, __random__
        lea rdi, [var_0]
        ; store [a.14.1{r1}], t.11.1{r2}
        mov [rdi], esi
        ; 16:9 return __random__
        ; move t.16.1{r0}, t.16.1{r2}
        mov eax, esi
        add rsp, 8
        ret

        ; i16 random16
_random16:
        sub rsp, 8
        ; 20:23 return (i16) & 32767
        ; call t.2.1{r0} = random[] -> i32
        call _random
        ; cast t.1.1{r1}(i16), t.2.1{r0}(i32)
        mov di, ax
        ; move t.0.1{r0}, t.1.1{r1}
        mov ax, di
        ; and t.0.1{r0}, 32767
        and ax, 32767
        add rsp, 8
        ret

        ; i16 rowColumnToCell@u8@u8
        ;   rsp+0: arg row
        ;   rsp+1: arg column
_rowColumnToCell@u8@u8:
        sub rsp, 8
        ; cast r.1{r1}(i16), row{r1}(u8)
        movzx di, dil
        ; cast c.1{r2}(i16), column{r2}(u8)
        movzx si, sil
        ; 23:19 return r * 40 + c
        ; mul t.5.1{r1}, 40
        movsx rdi, di
        imul  rdi, 40
        ; move t.4.1{r0}, t.5.1{r1}
        mov ax, di
        ; add t.4.1{r0}, c.1{r2}
        add ax, si
        add rsp, 8
        ret

        ; u8 getCell@u8@u8
        ;   rsp+0: arg row
        ;   rsp+1: arg column
_getCell@u8@u8:
        sub rsp, 8
        ; 27:15 return [...]
        ; call t.5.1{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.4.1{r1}(i64), t.5.1{r0}(i16)
        movsx rdi, ax
        ; addrof t.3.1{r2}, field
        lea rsi, [var_1]
        ; add t.3.2{r2}, t.4.1{r1}
        add rsi, rdi
        ; load t.2.1{r0}, [t.3.2{r2}]
        mov al, [rsi]
        add rsp, 8
        ret

        ; bool isBomb@u8
        ;   rsp+0: arg cell
_isBomb@u8:
        sub rsp, 8
        ; 31:27 return cell & 1 != 0
        ; and t.2.1{r1}, 1
        and dil, 1
        ; notequals t.1.1{r0}, t.2.1{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool isOpen@u8
        ;   rsp+0: arg cell
_isOpen@u8:
        sub rsp, 8
        ; 35:27 return cell & 2 != 0
        ; and t.2.1{r1}, 2
        and dil, 2
        ; notequals t.1.1{r0}, t.2.1{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool isFlag@u8
        ;   rsp+0: arg cell
_isFlag@u8:
        sub rsp, 8
        ; 39:27 return cell & 4 != 0
        ; and t.2.1{r1}, 4
        and dil, 4
        ; notequals t.1.1{r0}, t.2.1{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; void setCell@u8@u8@u8
        ;   rsp+24: arg row
        ;   rsp+25: arg column
        ;   rsp+26: arg cell
_setCell@u8@u8@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move cell{r8}, cell{r3}
        mov bl, dl
        ; call t.5.1{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.4.1{r0}(i64), t.5.1{r0}(i16)
        movsx rax, ax
        ; addrof t.3.1{r1}, field
        lea rdi, [var_1]
        ; add t.3.2{r1}, t.4.1{r0}
        add rdi, rax
        ; store [t.3.2{r1}], cell{r8}
        mov [rdi], bl
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; u8 getBombCountAround@u8@u8
        ;   rsp+32: arg row
        ;   rsp+33: arg column
        ;   rsp+34: var rowTo.2
        ;   rsp+35: var colFrom.2
        ;   rsp+36: var colTo.2
        ;   rsp+37: var r.2
        ;   rsp+38: var count.3
        ;   rsp+39: var c.2
        ;   rsp+40: var count.5
_getBombCountAround@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bl, dil
        ; move rowFrom.1{r0}, row{r8}
        mov al, bl
        ; 48:2 if rowFrom > 0
        ; branch rowFrom.1{r0} lteq 0: if_4_end
        cmp al, 0
        jbe _if_4_end
        ; sub rowFrom.3{r0}, 1
        sub al, 1
_if_4_end:
        ; move rowTo.1{r3}, row{r8}
        mov dl, bl
        ; add rowTo.1{r3}, 1
        add dl, 1
        ; 52:2 if rowTo >= 20
        ; branch rowTo.1{r3} gteq 20: if_5_then
        cmp dl, 20
        jae _if_5_then
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r3}
        mov [r12], dl
        jmp _if_5_end
_if_5_then:
        ; sub rowTo.3{r3}, 1
        sub dl, 1
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r3}
        mov [r12], dl
_if_5_end:
        ; move colFrom.1{r3}, column{r2}
        mov dl, sil
        ; 57:2 if colFrom > 0
        ; branch colFrom.1{r3} lteq 0: if_6_end
        cmp dl, 0
        jbe _if_6_end
        ; sub colFrom.3{r3}, 1
        sub dl, 1
_if_6_end:
        ; move colTo.1{r4}, column{r2}
        mov cl, sil
        ; add colTo.1{r4}, 1
        add cl, 1
        ; 61:2 if colTo >= 40
        ; branch colTo.1{r4} gteq 40: if_7_then
        cmp cl, 40
        jae _if_7_then
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo.2{r4}
        mov [r12], cl
        jmp _if_7_end
_if_7_then:
        ; sub colTo.3{r4}, 1
        sub cl, 1
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo.2{r4}
        mov [r12], cl
_if_7_end:
        ; const count.1{r4}, 0
        mov cl, 0
        ; 66:2 for r <= rowTo
        ; move r.2{r1}, r.1{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], colFrom.2{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; load colTo.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; move count.2{r0}, count.2{r4}
        mov al, cl
        ; move r.2{r2}, r.2{r1}
        mov sil, dil
        jmp _for_8
_for_8_body:
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo.2{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+35]
        ; load colFrom.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; move count.2{r4}, count.2{r0}
        mov cl, al
        ; move r.2{r1}, r.2{r2}
        mov dil, sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move c.1{r0}, colFrom.2{r3}
        mov al, dl
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+35]
        ; 67:3 for c <= colTo
        ; move count.3{r3}, count.2{r4}
        mov dl, cl
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        ; move c.2{r2}, c.2{r0}
        mov sil, al
        ; move count.3{r1}, count.3{r3}
        mov dil, dl
        jmp _for_9
_for_9_body:
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo.2{r3}
        mov [r12], dl
        ; move c.2{r0}, c.2{r2}
        mov al, sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move count.3{r3}, count.3{r1}
        mov dl, dil
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch r.2{r1} equals row{r8}: and_11
        cmp dil, bl
        je _and_11
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; addrof memVarAddr{r9}, count.3
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], count.3{r3}
        mov [r12], dl
        jmp _if_10_end
_and_11:
        ; branch c.2{r0} equals column{r2}: getBombCountAround@u8@u8.no_critical_edge_26, getBombCountAround@u8@u8.no_critical_edge_27
        cmp al, sil
        je _getBombCountAround@u8@u8.no_critical_edge_26
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        jmp _getBombCountAround@u8@u8.no_critical_edge_27
_getBombCountAround@u8@u8.no_critical_edge_26:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, count.5
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], count.5{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], c.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, count.5
        lea r12, [rsp+40]
        ; move count.5{r1}, count.5{r3}
        mov dil, dl
        jmp _for_9_continue
_getBombCountAround@u8@u8.no_critical_edge_27:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, count.3
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], count.3{r3}
        mov [r12], dl
_if_10_end:
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        ; move c.2{r2}, c.2{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], c.2{r0}
        mov [r12], al
        ; call cell.1{r0} = getCell@u8@u8[r.2{r1}, c.2{r2}] -> u8
        call _getCell@u8@u8
        ; 72:4 if isBomb@u8([ExprVarAccess[varName=cell, index=9, scope=function, type=u8, varIsArray=false, location=72:14]])
        ; move cell.1{r1}, cell.1{r0}
        mov dil, al
        ; call t.10.1{r0} = isBomb@u8[cell.1{r1}] -> bool
        call _isBomb@u8
        ; branch t.10.1{r0} notequals 0: if_12_then
        cmp al, 0
        jne _if_12_then
        ; addrof memVarAddr{r9}, count.3
        lea r12, [rsp+38]
        ; load count.3{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _for_9_continue
_if_12_then:
        ; addrof memVarAddr{r9}, count.3
        lea r12, [rsp+38]
        ; load count.3{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; add count.6{r1}, 1
        add dil, 1
_for_9_continue:
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+39]
        ; load c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add c.5{r2}, 1
        add sil, 1
_for_9:
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; load colTo.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch c.2{r2} lteq colTo.2{r3}: for_9_body
        cmp sil, dl
        jbe _for_9_body
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; load r.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add r.4{r2}, 1
        add sil, 1
        ; move count.2{r0}, count.3{r1}
        mov al, dil
_for_8:
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; load rowTo.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch r.2{r2} lteq rowTo.2{r1}: for_8_body
        cmp sil, dil
        jbe _for_8_body
        ; 77:9 return count
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; i16 columnToX@u8
        ;   rsp+0: arg column
_columnToX@u8:
        sub rsp, 8
        ; cast c.1{r1}(i16), column{r1}(u8)
        movzx di, dil
        ; 82:17 return c + 1 << 1
        ; add t.3.1{r1}, 1
        add di, 1
        ; move t.2.1{r0}, t.3.1{r1}
        mov ax, di
        ; shiftleft t.2.1{r0}, 1
        sal ax, 1
        add rsp, 8
        ret

        ; void printCellAt@u8@u8
        ;   rsp+32: arg row
        ;   rsp+33: arg column
_printCellAt@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bl, dil
        ; move column{r9}, column{r2}
        mov r12b, sil
        ; call cell.1{r0} = getCell@u8@u8[row{r1}, column{r2}] -> u8
        call _getCell@u8@u8
        ; move cell.1{r1}, cell.1{r0}
        mov dil, al
        ; move row{r2}, row{r8}
        mov sil, bl
        ; move column{r3}, column{r9}
        mov dl, r12b
        ; call printCellAt@u8@u8@u8[cell.1{r1}, row{r2}, column{r3}]
        call _printCellAt@u8@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printCellAt@u8@u8@u8
        ;   rsp+32: arg cell
        ;   rsp+33: arg row
        ;   rsp+34: arg column
_printCellAt@u8@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move cell{r8}, cell{r1}
        mov bl, dil
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], row{r2}
        mov [r12], sil
        ; move column{r1}, column{r3}
        mov dil, dl
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r3}
        mov [r12], dl
        ; call x.1{r0} = columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+33]
        ; load row{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; cast t.4.1{r1}(i16), row{r2}(u8)
        movzx di, sil
        ; move x.1{r2}, x.1{r0}
        mov si, ax
        ; call setCursor@i16@i16[t.4.1{r1}, x.1{r2}]
        call _setCursor@i16@i16
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; load row{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; call printCell@u8@u8@u8[cell{r1}, row{r2}, column{r3}]
        call _printCell@u8@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printCell@u8@u8@u8
        ;   rsp+32: arg cell
        ;   rsp+33: arg row
        ;   rsp+34: arg column
        ;   rsp+35: var chr.1
_printCell@u8@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move cell{r8}, cell{r1}
        mov bl, dil
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], row{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r3}
        mov [r12], dl
        ; const chr.1{r0}, 46
        mov al, 46
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], al
        ; 98:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=98:13]])
        ; call t.5.1{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.5.1{r0} notequals 0: if_13_then
        cmp al, 0
        jne _if_13_then
        ; 112:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=112:18]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.7.1{r0} = isFlag@u8[cell{r1}] -> bool
        call _isFlag@u8
        ; branch t.7.1{r0} equals 0: printCell@u8@u8@u8.no_critical_edge_10, if_16_then
        cmp al, 0
        je _printCell@u8@u8@u8.no_critical_edge_10
        jmp _if_16_then
_if_13_then:
        ; 99:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=99:14]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.6.1{r0} = isBomb@u8[cell{r1}] -> bool
        call _isBomb@u8
        ; branch t.6.1{r0} equals 0: if_14_else, if_14_then
        cmp al, 0
        je _if_14_else
        jmp _if_14_then
_printCell@u8@u8@u8.no_critical_edge_10:
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+35]
        ; load chr.1{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        jmp _if_13_end
_if_16_then:
        ; const chr.3{r8}, 35
        mov bl, 35
        jmp _if_13_end
_if_14_else:
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+33]
        ; load row{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move row{r1}, row{r2}
        mov dil, sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; move column{r2}, column{r3}
        mov sil, dl
        ; call count.1{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; 104:4 if count > 0
        ; branch count.1{r0} lteq 0: if_15_else, if_15_then
        cmp al, 0
        jbe _if_15_else
        jmp _if_15_then
_if_14_then:
        ; const chr.4{r8}, 42
        mov bl, 42
        jmp _if_13_end
_if_15_else:
        ; const chr.5{r8}, 32
        mov bl, 32
        jmp _if_13_end
_if_15_then:
        ; move chr.6{r8}, count.1{r0}
        mov bl, al
        ; add chr.6{r8}, 48
        add bl, 48
_if_13_end:
        ; move chr.2{r1}, chr.2{r8}
        mov dil, bl
        ; call printChar@u8[chr.2{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printField
_printField:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const arg.0.0{r1}, 0
        mov di, 0
        ; const arg.0.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const row.1{r8}, 0
        mov bl, 0
        ; 120:2 for row < 20
        jmp _for_17
_for_17_body:
        ; const arg.1.0{r1}, 124
        mov dil, 124
        ; call printChar@u8[arg.1.0{r1}]
        call _printChar@u8
        ; const column.1{r9}, 0
        mov r12b, 0
        ; 122:3 for column < 40
        jmp _for_18
_for_18_body:
        ; const arg.2.0{r1}, 32
        mov dil, 32
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        ; move row.2{r1}, row.2{r8}
        mov dil, bl
        ; move column.2{r2}, column.2{r9}
        mov sil, r12b
        ; call cell.1{r0} = getCell@u8@u8[row.2{r1}, column.2{r2}] -> u8
        call _getCell@u8@u8
        ; move cell.1{r1}, cell.1{r0}
        mov dil, al
        ; move row.2{r2}, row.2{r8}
        mov sil, bl
        ; move column.2{r3}, column.2{r9}
        mov dl, r12b
        ; call printCell@u8@u8@u8[cell.1{r1}, row.2{r2}, column.2{r3}]
        call _printCell@u8@u8@u8
        ; add column.3{r9}, 1
        add r12b, 1
_for_18:
        ; branch column.2{r9} lt 40: for_18_body
        cmp r12b, 40
        jb _for_18_body
        ; const t.3.1{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        ; move row.4{r0}, row.2{r8}
        mov al, bl
        ; add row.4{r0}, 1
        add al, 1
        ; move row.2{r8}, row.4{r0}
        mov bl, al
_for_17:
        ; branch row.2{r8} lt 20: for_17_body
        cmp bl, 20
        jb _for_17_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void showCursor@u8@u8@bool
        ;   rsp+32: arg row
        ;   rsp+33: arg column
        ;   rsp+34: arg show
        ;   rsp+36: var x.1
        ;   rsp+38: var chr.2
_showCursor@u8@u8@bool:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bl, dil
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], show{r3}
        mov [r12], dl
        ; move column{r1}, column{r2}
        mov dil, sil
        ; call x.1{r0} = columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; cast t.5.1{r1}(i16), row{r8}(u8)
        movzx di, bl
        ; move t.6.1{r2}, x.1{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, x.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], x.1{r0}
        mov [r12], ax
        ; sub t.6.1{r2}, 1
        sub si, 1
        ; call setCursor@i16@i16[t.5.1{r1}, t.6.1{r2}]
        call _setCursor@i16@i16
        ; const chr.1{r0}, 32
        mov al, 32
        ; 135:2 if show
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; load show{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch show{r3} notequals 0: if_19_then
        cmp dl, 0
        jne _if_19_then
        ; move chr.2{r1}, chr.1{r0}
        mov dil, al
        jmp _if_19_end
_if_19_then:
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], show{r3}
        mov [r12], dl
        ; const chr.3{r0}, 91
        mov al, 91
        ; move chr.2{r1}, chr.3{r0}
        mov dil, al
_if_19_end:
        ; addrof memVarAddr{r9}, chr.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], chr.2{r1}
        mov [r12], dil
        ; call printChar@u8[chr.2{r1}]
        call _printChar@u8
        ; cast t.7.1{r1}(i16), row{r8}(u8)
        movzx di, bl
        ; addrof memVarAddr{r9}, x.1
        lea r12, [rsp+36]
        ; load x.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.8.1{r2}, x.1{r0}
        mov si, ax
        ; add t.8.1{r2}, 1
        add si, 1
        ; call setCursor@i16@i16[t.7.1{r1}, t.8.1{r2}]
        call _setCursor@i16@i16
        ; 141:2 if show
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; load show{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch show{r3} notequals 0: if_20_then
        cmp dl, 0
        jne _if_20_then
        ; addrof memVarAddr{r9}, chr.2
        lea r12, [rsp+38]
        ; load chr.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _if_20_end
_if_20_then:
        ; const chr.5{r8}, 93
        mov bl, 93
        ; move chr.4{r1}, chr.5{r8}
        mov dil, bl
_if_20_end:
        ; call printChar@u8[chr.4{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printSpaces@i16
        ;   rsp+24: arg i
_printSpaces@i16:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move i.1{r8}, i{r1}
        mov bx, di
        jmp _for_21
_for_21_body:
        ; const arg.0.0{r1}, 48
        mov dil, 48
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; move i.2{r0}, i.1{r8}
        mov ax, bx
        ; sub i.2{r0}, 1
        sub ax, 1
        ; move i.1{r8}, i.2{r0}
        mov bx, ax
_for_21:
        ; branch i.1{r8} gt 0: for_21_body
        cmp bx, 0
        jg _for_21_body
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; u8 getDigitCount@i16
        ;   rsp+0: arg value
_getDigitCount@i16:
        sub rsp, 8
        ; const count.1{r2}, 0
        mov sil, 0
        ; 155:2 if value < 0
        ; branch value{r1} gteq 0: while_23
        cmp di, 0
        jge _while_23
        ; const count.3{r2}, 1
        mov sil, 1
        ; neg value.2{r1}, value{r1}
        neg rdi
_while_23:
        ; add count.5{r2}, 1
        add sil, 1
        ; move value.4{r0}, value.4{r1}
        mov ax, di
        ; div value.4{r0}, 10
        movsx rax, ax
        cqo
        mov rcx, 10
        idiv rcx
        ; move value.4{r1}, value.4{r0}
        mov di, ax
        ; 163:3 if value == 0
        ; branch value.4{r1} notequals 0: while_23
        cmp di, 0
        jne _while_23
        ; 168:9 return count
        ; move count.5{r0}, count.5{r2}
        mov al, sil
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+32: var r.2
        ;   rsp+33: var c.2
_getHiddenCount:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const count.1{r8}, 0
        mov bx, 0
        ; const r.1{r0}, 0
        mov al, 0
        ; 173:2 for r < 20
        ; move r.2{r1}, r.1{r0}
        mov dil, al
        jmp _for_25
_for_25_body:
        ; const c.1{r0}, 0
        mov al, 0
        ; 174:3 for c < 40
        ; move c.2{r2}, c.1{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        jmp _for_26
_for_26_body:
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+32]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], c.2{r2}
        mov [r12], sil
        ; call cell.1{r0} = getCell@u8@u8[r.2{r1}, c.2{r2}] -> u8
        call _getCell@u8@u8
        ; 176:4 if cell & 6 == 0
        ; move t.4.1{r1}, cell.1{r0}
        mov dil, al
        ; and t.4.1{r1}, 6
        and dil, 6
        ; branch t.4.1{r1} equals 0: if_27_then
        cmp dil, 0
        je _if_27_then
        ; move count.4{r1}, count.3{r8}
        mov di, bx
        jmp _for_26_continue
_if_27_then:
        ; move count.5{r1}, count.3{r8}
        mov di, bx
        ; add count.5{r1}, 1
        add di, 1
_for_26_continue:
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+33]
        ; load c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add c.4{r2}, 1
        add sil, 1
        ; move count.3{r8}, count.4{r1}
        mov bx, di
_for_26:
        ; branch c.2{r2} lt 40: for_26_body
        cmp sil, 40
        jb _for_26_body
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+32]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; add r.4{r1}, 1
        add dil, 1
_for_25:
        ; branch r.2{r1} lt 20: for_25_body
        cmp dil, 20
        jb _for_25_body
        ; 181:9 return count
        ; move count.2{r0}, count.2{r8}
        mov ax, bx
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; bool printLeft
        ;   rsp+32: var leftDigits.1
        ;   rsp+34: var bombDigits.1
_printLeft:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; call count.1{r0} = getHiddenCount[] -> i16
        call _getHiddenCount
        ; move count.1{r8}, count.1{r0}
        mov bx, ax
        ; move count.1{r1}, count.1{r8}
        mov di, bx
        ; call t.3.1{r0} = getDigitCount@i16[count.1{r1}] -> u8
        call _getDigitCount@i16
        ; cast leftDigits.1{r0}(i16), t.3.1{r0}(u8)
        movzx ax, al
        ; addrof memVarAddr{r9}, leftDigits.1
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], leftDigits.1{r0}
        mov [r12], ax
        ; const arg.2.0{r1}, 40
        mov di, 40
        ; call t.4.1{r0} = getDigitCount@i16[arg.2.0{r1}] -> u8
        call _getDigitCount@i16
        ; cast bombDigits.1{r0}(i16), t.4.1{r0}(u8)
        movzx ax, al
        ; addrof memVarAddr{r9}, bombDigits.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombDigits.1{r0}
        mov [r12], ax
        ; const arg.3.0{r1}, 20
        mov di, 20
        ; const arg.3.1{r2}, 6
        mov si, 6
        ; call setCursor@i16@i16[arg.3.0{r1}, arg.3.1{r2}]
        call _setCursor@i16@i16
        ; load bombDigits.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.5.1{r1}, bombDigits.1{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, leftDigits.1
        lea r12, [rsp+32]
        ; load leftDigits.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub t.5.1{r1}, leftDigits.1{r0}
        sub di, ax
        ; call printSpaces@i16[t.5.1{r1}]
        call _printSpaces@i16
        ; move count.1{r1}, count.1{r8}
        mov di, bx
        ; call printUint@i16[count.1{r1}]
        call _printUint@i16
        ; 192:15 return count == 0
        ; equals t.6.1{r0}, count.1{r8}, 0
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
_abs@i16:
        sub rsp, 8
        ; branch a{r1} lt 0: if_28_then
        cmp di, 0
        jl _if_28_then
        ; 199:9 return a
        ; move a{r0}, a{r1}
        mov ax, di
        jmp _abs@i16_ret
_if_28_then:
        ; 197:10 return -a
        ; neg t.1.1{r1}, a{r1}
        neg rdi
        ; move t.1.1{r0}, t.1.1{r1}
        mov ax, di
_abs@i16_ret:
        add rsp, 8
        ret

        ; void clearField
_clearField:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const r.1{r8}, 0
        mov bl, 0
        ; 203:2 for r < 20
        jmp _for_29
_for_29_body:
        ; const c.1{r9}, 0
        mov r12b, 0
        ; 204:3 for c < 40
        jmp _for_30
_for_30_body:
        ; move r.2{r1}, r.2{r8}
        mov dil, bl
        ; move c.2{r2}, c.2{r9}
        mov sil, r12b
        ; const arg.0.2{r3}, 0
        mov dl, 0
        ; call setCell@u8@u8@u8[r.2{r1}, c.2{r2}, arg.0.2{r3}]
        call _setCell@u8@u8@u8
        ; move c.3{r0}, c.2{r9}
        mov al, r12b
        ; add c.3{r0}, 1
        add al, 1
        ; move c.2{r9}, c.3{r0}
        mov r12b, al
_for_30:
        ; branch c.2{r9} lt 40: for_30_body
        cmp r12b, 40
        jb _for_30_body
        ; move r.4{r0}, r.2{r8}
        mov al, bl
        ; add r.4{r0}, 1
        add al, 1
        ; move r.2{r8}, r.4{r0}
        mov bl, al
_for_29:
        ; branch r.2{r8} lt 20: for_29_body
        cmp bl, 20
        jb _for_29_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void initField@u8@u8
        ;   rsp+32: arg curr_r
        ;   rsp+33: arg curr_c
        ;   rsp+34: var c.1
        ;   rsp+36: var bombs.2
        ;   rsp+38: var row.1
        ;   rsp+40: var column.1
_initField@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; cast r.1{r8}(i16), curr_r{r1}(u8)
        movzx bx, dil
        ; cast c.1{r0}(i16), curr_c{r2}(u8)
        movzx ax, sil
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c.1{r0}
        mov [r12], ax
        ; const bombs.1{r0}, 40
        mov ax, 40
        ; 213:2 for bombs > 0
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs.2{r0}
        mov [r12], ax
        jmp _for_31
_for_31_body:
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs.2{r0}
        mov [r12], ax
        ; call t.7.1{r0} = random16[] -> i16
        call _random16
        ; move row.1{r1}, t.7.1{r0}
        mov di, ax
        ; mod row.1{r3}, row.1{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move row.1{r1}, row.1{r3}
        mov di, dx
        ; addrof memVarAddr{r9}, row.1
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], row.1{r1}
        mov [r12], di
        ; call t.8.1{r0} = random16[] -> i16
        call _random16
        ; move column.1{r2}, t.8.1{r0}
        mov si, ax
        ; mod column.1{r3}, column.1{r0}, 40
        movsx rax, ax
        cqo
        mov rcx, 40
        idiv rcx
        ; move column.1{r2}, column.1{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, column.1
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], column.1{r2}
        mov [r12], si
        ; 216:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=5, scope=function, type=i16, varIsArray=false, location=216:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=216:20], location=216:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=6, scope=function, type=i16, varIsArray=false, location=217:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=217:20], location=217:18]]) > 1
        ; addrof memVarAddr{r9}, row.1
        lea r12, [rsp+38]
        ; load row.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.10.1{r1}, row.1{r0}
        mov di, ax
        ; sub t.10.1{r1}, r.1{r8}
        sub di, bx
        ; call t.9.1{r0} = abs@i16[t.10.1{r1}] -> i16
        call _abs@i16
        ; branch t.9.1{r0} gt 1: if_32_then
        cmp ax, 1
        jg _if_32_then
        ; addrof memVarAddr{r9}, column.1
        lea r12, [rsp+40]
        ; load column.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.12.1{r1}, column.1{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub t.12.1{r1}, c.1{r0}
        sub di, ax
        ; call t.11.1{r0} = abs@i16[t.12.1{r1}] -> i16
        call _abs@i16
        ; branch t.11.1{r0} lteq 1: for_31_continue, if_32_then
        cmp ax, 1
        jle _for_31_continue
_if_32_then:
        ; addrof memVarAddr{r9}, row.1
        lea r12, [rsp+38]
        ; load row.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; cast t.13.1{r1}(u8), row.1{r0}(i16)
        mov dil, al
        ; addrof memVarAddr{r9}, column.1
        lea r12, [rsp+40]
        ; load column.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; cast t.14.1{r2}(u8), column.1{r0}(i16)
        mov sil, al
        ; const arg.4.2{r3}, 1
        mov dl, 1
        ; call setCell@u8@u8@u8[t.13.1{r1}, t.14.1{r2}, arg.4.2{r3}]
        call _setCell@u8@u8@u8
_for_31_continue:
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+36]
        ; load bombs.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub bombs.5{r0}, 1
        sub ax, 1
_for_31:
        ; branch bombs.2{r0} gt 0: for_31_body
        cmp ax, 0
        jg _for_31_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void maybeRevealAround@u8@u8
        ;   rsp+32: arg row
        ;   rsp+33: arg column
        ;   rsp+34: var rowTo.2
        ;   rsp+35: var colFrom.2
        ;   rsp+36: var colTo.2
        ;   rsp+37: var r.2
        ;   rsp+38: var c.2
        ;   rsp+39: var cell.1
_maybeRevealAround@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bl, dil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; call printCellAt@u8@u8[row{r1}, column{r2}]
        call _printCellAt@u8@u8
        ; 225:2 if getBombCountAround@u8@u8([ExprVarAccess[varName=row, index=0, scope=parameter, type=u8, varIsArray=false, location=225:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=u8, varIsArray=false, location=225:30]]) != 0
        ; move row{r1}, row{r8}
        mov dil, bl
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call t.9.1{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; branch t.9.1{r0} notequals 0: maybeRevealAround@u8@u8_ret
        cmp al, 0
        jne _maybeRevealAround@u8@u8_ret
        ; move rowFrom.1{r0}, row{r8}
        mov al, bl
        ; 230:2 if rowFrom > 0
        ; branch rowFrom.1{r0} lteq 0: if_35_end
        cmp al, 0
        jbe _if_35_end
        ; sub rowFrom.3{r0}, 1
        sub al, 1
_if_35_end:
        ; move rowTo.1{r3}, row{r8}
        mov dl, bl
        ; add rowTo.1{r3}, 1
        add dl, 1
        ; 234:2 if rowTo >= 20
        ; branch rowTo.1{r3} gteq 20: if_36_then
        cmp dl, 20
        jae _if_36_then
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r3}
        mov [r12], dl
        jmp _if_36_end
_if_36_then:
        ; sub rowTo.3{r3}, 1
        sub dl, 1
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r3}
        mov [r12], dl
_if_36_end:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move colFrom.1{r3}, column{r2}
        mov dl, sil
        ; 239:2 if colFrom > 0
        ; branch colFrom.1{r3} lteq 0: if_37_end
        cmp dl, 0
        jbe _if_37_end
        ; sub colFrom.3{r3}, 1
        sub dl, 1
_if_37_end:
        ; move colTo.1{r4}, column{r2}
        mov cl, sil
        ; add colTo.1{r4}, 1
        add cl, 1
        ; 243:2 if colTo >= 40
        ; branch colTo.1{r4} gteq 40: if_38_then
        cmp cl, 40
        jae _if_38_then
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo.2{r4}
        mov [r12], cl
        jmp _if_38_end
_if_38_then:
        ; sub colTo.3{r4}, 1
        sub cl, 1
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo.2{r4}
        mov [r12], cl
_if_38_end:
        ; 246:2 for r <= rowTo
        ; move r.2{r1}, r.1{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], colFrom.2{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; load colTo.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp _for_39
_for_39_body:
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+35]
        ; load colFrom.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move c.1{r0}, colFrom.2{r3}
        mov al, dl
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+35]
        ; 247:3 for c <= colTo
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        ; move c.2{r2}, c.2{r0}
        mov sil, al
        jmp _for_40
_for_40_body:
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo.2{r0}
        mov [r12], al
        ; move c.2{r0}, c.2{r2}
        mov al, sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch r.2{r1} equals row{r8}: and_42
        cmp dil, bl
        je _and_42
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        jmp _if_41_end
_and_42:
        ; branch c.2{r0} equals column{r2}: maybeRevealAround@u8@u8.no_critical_edge_28, maybeRevealAround@u8@u8.no_critical_edge_29
        cmp al, sil
        je _maybeRevealAround@u8@u8.no_critical_edge_28
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        jmp _maybeRevealAround@u8@u8.no_critical_edge_29
_maybeRevealAround@u8@u8.no_critical_edge_28:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        jmp _for_40_continue
_maybeRevealAround@u8@u8.no_critical_edge_29:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
_if_41_end:
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        ; move c.2{r2}, c.2{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r0}
        mov [r12], al
        ; call cell.1{r0} = getCell@u8@u8[r.2{r1}, c.2{r2}] -> u8
        call _getCell@u8@u8
        ; 253:4 if isOpen@u8([ExprVarAccess[varName=cell, index=8, scope=function, type=u8, varIsArray=false, location=253:15]])
        ; move cell.1{r1}, cell.1{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell.1
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], cell.1{r0}
        mov [r12], al
        ; call t.10.1{r0} = isOpen@u8[cell.1{r1}] -> bool
        call _isOpen@u8
        ; branch t.10.1{r0} notequals 0: for_40_continue
        cmp al, 0
        jne _for_40_continue
        ; load cell.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.11.1{r3}, cell.1{r0}
        mov dl, al
        ; or t.11.1{r3}, 2
        or dl, 2
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; load c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call setCell@u8@u8@u8[r.2{r1}, c.2{r2}, t.11.1{r3}]
        call _setCell@u8@u8@u8
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; load c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call maybeRevealAround@u8@u8[r.2{r1}, c.2{r2}]
        call _maybeRevealAround@u8@u8
_for_40_continue:
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; load c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move c.5{r0}, c.2{r2}
        mov al, sil
        ; add c.5{r0}, 1
        add al, 1
        ; move c.2{r2}, c.5{r0}
        mov sil, al
_for_40:
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; load colTo.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; branch c.2{r2} lteq colTo.2{r0}: for_40_body
        cmp sil, al
        jbe _for_40_body
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; add r.4{r1}, 1
        add dil, 1
_for_39:
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; load rowTo.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; branch r.2{r1} lteq rowTo.2{r2}: for_39_body, maybeRevealAround@u8@u8_ret
        cmp dil, sil
        jbe _for_39_body
_maybeRevealAround@u8@u8_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void main
        ;   rsp+32: var curr_c.2
        ;   rsp+33: var curr_r.2
        ;   rsp+34: var chr.1
        ;   rsp+36: var cell.1
        ;   rsp+37: var cell.3
        ;   rsp+38: var cell.4
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; begin initialize global variables
        ; const t.6.1{r8}, 0
        mov ebx, 0
        ; addrof a.7.1{r0}, __random__
        lea rax, [var_0]
        ; store [a.7.1{r0}], t.6.1{r8}
        mov [rax], ebx
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov edi, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; const needsInitialize.1{r8}, 1
        mov bl, 1
        ; call clearField[]
        call _clearField
        ; call printField[]
        call _printField
        ; const arg.3.0{r1}, 20
        mov di, 20
        ; const arg.3.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.3.0{r1}, arg.3.1{r2}]
        call _setCursor@i16@i16
        ; const t.8.1{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.8.1{r1}]
        call _printString@@u8
        ; const curr_c.1{r0}, 20
        mov al, 20
        ; const curr_r.1{r1}, 10
        mov dil, 10
        ; 272:2 while true
        ; move curr_c.2{r2}, curr_c.1{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        jmp _while_44
_if_45_then:
        ; 274:4 if printLeft([])
        ; call t.9.1{r0} = printLeft[] -> bool
        call _printLeft
        ; branch t.9.1{r0} notequals 0: if_46_then, if_45_end
        cmp al, 0
        jne _if_46_then
_if_45_end:
        ; const t.11.1{r3}, 1
        mov dl, 1
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call showCursor@u8@u8@bool[curr_r.2{r1}, curr_c.2{r2}, t.11.1{r3}]
        call _showCursor@u8@u8@bool
        ; call chr.1{r0} = getChar[] -> i16
        call _getChar
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        ; const t.12.1{r3}, 0
        mov dl, 0
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call showCursor@u8@u8@bool[curr_r.2{r1}, curr_c.2{r2}, t.12.1{r3}]
        call _showCursor@u8@u8@bool
        ; 283:3 if chr == 27
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+34]
        ; load chr.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; branch chr.1{r0} equals 27: main_ret
        cmp ax, 27
        je _main_ret
        ; branch chr.1{r0} equals 13: if_48_then
        cmp ax, 13
        je _if_48_then
        ; branch chr.1{r0} notequals -8120: if_52_else, if_52_then
        cmp ax, -8120
        jne _if_52_else
        jmp _if_52_then
_if_48_then:
        ; branch needsInitialize.2{r8} equals 0: main.no_critical_edge_39, if_49_then
        cmp bl, 0
        je _main.no_critical_edge_39
        jmp _if_49_then
_if_52_else:
        ; branch chr.1{r0} notequals -8112: if_54_else, if_54_then
        cmp ax, -8112
        jne _if_54_else
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        jmp _if_54_then
_if_52_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch curr_r.2{r1} lteq 0: main.no_critical_edge_38, if_53_then
        cmp dil, 0
        jbe _main.no_critical_edge_38
        jmp _if_53_then
_main.no_critical_edge_39:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        jmp _if_49_end
_if_49_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; const needsInitialize.5{r8}, 0
        mov bl, 0
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call initField@u8@u8[curr_r.2{r1}, curr_c.2{r2}]
        call _initField@u8@u8
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _if_49_end
_if_54_else:
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8117: if_56_else, if_56_then
        cmp ax, -8117
        jne _if_56_else
        jmp _if_56_then
_if_54_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch curr_r.2{r1} gteq 19: main.no_critical_edge_37, if_55_then
        cmp dil, 19
        jae _main.no_critical_edge_37
        jmp _if_55_then
_main.no_critical_edge_38:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        jmp _while_44
_if_53_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move curr_r.5{r0}, curr_r.2{r1}
        mov al, dil
        ; sub curr_r.5{r0}, 1
        sub al, 1
        ; move curr_r.2{r1}, curr_r.5{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        jmp _while_44
_if_49_end:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; call cell.1{r0} = getCell@u8@u8[curr_r.2{r1}, curr_c.2{r2}] -> u8
        call _getCell@u8@u8
        ; 293:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=293:16]])
        ; move cell.1{r1}, cell.1{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], cell.1{r0}
        mov [r12], al
        ; call t.13.1{r0} = isOpen@u8[cell.1{r1}] -> bool
        call _isOpen@u8
        ; branch t.13.1{r0} notequals 0: main.no_critical_edge_40, if_50_then
        cmp al, 0
        jne _main.no_critical_edge_40
        jmp _if_50_then
_if_56_else:
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8115: if_58_else, if_58_then
        cmp ax, -8115
        jne _if_58_else
        jmp _if_58_then
_if_56_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; branch curr_c.2{r2} lteq 0: main.no_critical_edge_36, if_57_then
        cmp sil, 0
        jbe _main.no_critical_edge_36
        jmp _if_57_then
_main.no_critical_edge_37:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _while_44
_if_55_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move curr_r.6{r0}, curr_r.2{r1}
        mov al, dil
        ; add curr_r.6{r0}, 1
        add al, 1
        ; move curr_r.2{r1}, curr_r.6{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        jmp _while_44
_main.no_critical_edge_40:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _if_50_end
_if_50_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, cell.1
        lea r12, [rsp+36]
        ; load cell.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.14.1{r3}, cell.1{r0}
        mov dl, al
        ; or t.14.1{r3}, 2
        or dl, 2
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; call setCell@u8@u8@u8[curr_r.2{r1}, curr_c.2{r2}, t.14.1{r3}]
        call _setCell@u8@u8@u8
        jmp _if_50_end
_if_58_else:
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals 32: main.no_critical_edge_32, if_60_then
        cmp ax, 32
        jne _main.no_critical_edge_32
        jmp _if_60_then
_if_58_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; branch curr_c.2{r2} gteq 39: main.no_critical_edge_35, if_59_then
        cmp sil, 39
        jae _main.no_critical_edge_35
        jmp _if_59_then
_main.no_critical_edge_36:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _while_44
_if_57_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move curr_c.6{r0}, curr_c.2{r2}
        mov al, sil
        ; sub curr_c.6{r0}, 1
        sub al, 1
        ; move curr_c.2{r2}, curr_c.6{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _while_44
_if_50_end:
        ; 296:4 if isBomb@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=296:15]])
        ; addrof memVarAddr{r9}, cell.1
        lea r12, [rsp+36]
        ; load cell.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move cell.1{r1}, cell.1{r0}
        mov dil, al
        ; call t.15.1{r0} = isBomb@u8[cell.1{r1}] -> bool
        call _isBomb@u8
        ; branch t.15.1{r0} equals 0: if_51_end, if_51_then
        cmp al, 0
        je _if_51_end
        jmp _if_51_then
_main.no_critical_edge_32:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _while_44
_if_60_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch needsInitialize.2{r8} notequals 0: main.no_critical_edge_33, if_61_then
        cmp bl, 0
        jne _main.no_critical_edge_33
        jmp _if_61_then
_main.no_critical_edge_35:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _while_44
_if_59_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move curr_c.7{r0}, curr_c.2{r2}
        mov al, sil
        ; add curr_c.7{r0}, 1
        add al, 1
        ; move curr_c.2{r2}, curr_c.7{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _while_44
_if_51_end:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; call maybeRevealAround@u8@u8[curr_r.2{r1}, curr_c.2{r2}]
        call _maybeRevealAround@u8@u8
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _while_44
_main.no_critical_edge_33:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        jmp _while_44
_if_61_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; call cell.3{r0} = getCell@u8@u8[curr_r.2{r1}, curr_c.2{r2}] -> u8
        call _getCell@u8@u8
        ; 331:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=331:17]])
        ; move cell.3{r1}, cell.3{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell.3
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], cell.3{r0}
        mov [r12], al
        ; call t.17.1{r0} = isOpen@u8[cell.3{r1}] -> bool
        call _isOpen@u8
        ; branch t.17.1{r0} equals 0: if_62_then
        cmp al, 0
        je _if_62_then
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _while_44
_if_62_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, cell.3
        lea r12, [rsp+37]
        ; load cell.3{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move cell.4{r3}, cell.3{r0}
        mov dl, al
        ; xor cell.4{r3}, 4
        xor dl, 4
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; addrof memVarAddr{r9}, cell.4
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], cell.4{r3}
        mov [r12], dl
        ; call setCell@u8@u8@u8[curr_r.2{r1}, curr_c.2{r2}, cell.4{r3}]
        call _setCell@u8@u8@u8
        ; load cell.4{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; move cell.4{r1}, cell.4{r3}
        mov dil, dl
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; call printCellAt@u8@u8@u8[cell.4{r1}, curr_r.2{r2}, curr_c.2{r3}]
        call _printCellAt@u8@u8@u8
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
_while_44:
        ; branch needsInitialize.2{r8} notequals 0: if_45_end, if_45_then
        cmp bl, 0
        jne _if_45_end
        jmp _if_45_then
_if_46_then:
        ; const t.10.1{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.10.1{r1}]
        call _printString@@u8
        jmp _main_ret
_if_51_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call printCellAt@u8@u8[curr_r.2{r1}, curr_c.2{r2}]
        call _printCellAt@u8@u8
        ; const t.16.1{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString@@u8[t.16.1{r1}]
        call _printString@@u8
_main_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
        mov rdx, rsi
        mov rsi, rdi
        mov rdi, 1
        mov rax, 1
        syscall
        ret

        ; i16 getChar
_getChar:
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
_setCursor@i16@i16:
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
        string_0 db ' |', 0x0a, 0x00
        string_1 db 'Left:', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

