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
        call _main
        mov rcx, 0
        sub rsp, 0x20
        call [ExitProcess]

        ; void printString@@u8
        ;   rsp+48: arg str
_printString@@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move str{r6}, str{r1}
        mov rbx, rcx
        ; call length.1{r0} = strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length.1{r2}, length.1{r0}
        mov rdx, rax
        ; call printStringLength@@u8@i64[str{r1}, length.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printChar@u8
        ;   rsp+64: arg chr
_printChar@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], chr{r1}
        mov [r12], cl
        ; move t.1.1{r1}, t.1.1{r7}
        mov rcx, r12
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printUint@i16
        ;   rsp+48: arg number
_printUint@i16:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1.1{r1}(i64), number{r1}(i16)
        movsx rcx, cx
        ; call printUint@i64[t.1.1{r1}]
        call _printUint@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+80: arg number
        ;   rsp+40: var buffer
_printUint@i64:
        sub rsp, 32
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const pos.1{r6}, 20
        mov bl, 20
        ; 33:2 while true
        ; move number.1{r3}, number{r1}
        mov r8, rcx
_while_1:
        ; sub pos.3{r6}, 1
        sub bl, 1
        ; move remainder.1{r4}, number.1{r3}
        mov r9, r8
        ; move remainder.1{r0}, remainder.1{r4}
        mov rax, r9
        ; mod remainder.1{r2}, remainder.1{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder.1{r4}, remainder.1{r2}
        mov r9, rdx
        ; move number.2{r0}, number.2{r3}
        mov rax, r8
        ; div number.2{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number.2{r3}, number.2{r0}
        mov r8, rax
        ; cast t.5.1{r0}(u8), remainder.1{r4}(i64)
        mov al, r9b
        ; add digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r4}(i64), pos.3{r6}(u8)
        movzx r9, bl
        ; addrof t.6.1{r5}, buffer
        lea r10, [rsp+40]
        ; add t.6.2{r5}, t.7.1{r4}
        add r10, r9
        ; store [t.6.2{r5}], digit.1{r0}
        mov [r10], al
        ; 39:3 if number == 0
        ; branch number.2{r3} notequals 0: while_1
        cmp r8, 0
        jne _while_1
        ; move t.9.1{r0}, t.9.1{r4}
        mov rax, r9
        ; addrof t.8.1{r3}, buffer
        lea r8, [rsp+40]
        ; move t.8.2{r1}, t.8.1{r3}
        mov rcx, r8
        ; move t.8.2{r1}, t.8.2{r5}
        mov rcx, r10
        ; const t.11.1{r0}, 20
        mov al, 20
        ; move t.10.1{r2}, t.11.1{r0}
        mov dl, al
        ; sub t.10.1{r2}, pos.3{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        add rsp, 32
        ret

        ; i64 strlen@@u8
        ;   rsp+16: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length.1{r2}, 0
        mov rdx, 0
        ; 69:2 for *str != 0
        ; move length.2{r0}, length.1{r2}
        mov rax, rdx
        jmp _for_3
_for_3_body:
        ; move length.3{r2}, length.2{r0}
        mov rdx, rax
        ; add length.3{r2}, 1
        add rdx, 1
        ; add str.2{r1}, 1
        add rcx, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rdx
_for_3:
        ; load t.2.1{r2}, [str.1{r1}]
        mov dl, [rcx]
        ; branch t.2.1{r2} notequals 0: for_3_body
        cmp dl, 0
        jne _for_3_body
        ; 72:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
_printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void initRandom@i32
        ;   rsp+16: arg salt
_initRandom@i32:
        sub rsp, 8
        ; move t.1.1{r0}, salt{r1}
        mov eax, ecx
        ; addrof a.2.1{r1}, __random__
        lea rcx, [var_0]
        ; store [a.2.1{r1}], t.1.1{r0}
        mov [rcx], eax
        add rsp, 8
        ret

        ; i32 random
_random:
        sub rsp, 8
        ; addrof a.5.1{r1}, __random__
        lea rcx, [var_0]
        ; load r.1{r1}, [a.5.1{r1}]
        mov ecx, [rcx]
        ; move t.6.1{r2}, r.1{r1}
        mov edx, ecx
        ; and t.6.1{r2}, 524287
        and edx, 524287
        ; mul b.1{r2}, 48271
        movsxd rdx, edx
        imul  rdx, 48271
        ; shiftright t.7.1{r1}, 15
        sar ecx, 15
        ; mul c.1{r1}, 48271
        movsxd rcx, ecx
        imul  rcx, 48271
        ; move t.8.1{r3}, c.1{r1}
        mov r8d, ecx
        ; and t.8.1{r3}, 65535
        and r8d, 65535
        ; shiftleft d.1{r3}, 15
        sal r8d, 15
        ; shiftright t.10.1{r1}, 16
        sar ecx, 16
        ; add t.9.1{r1}, b.1{r2}
        add ecx, edx
        ; add e.1{r1}, d.1{r3}
        add ecx, r8d
        ; move t.12.1{r2}, e.1{r1}
        mov edx, ecx
        ; and t.12.1{r2}, 2147483647
        and edx, 2147483647
        ; shiftright t.13.1{r1}, 31
        sar ecx, 31
        ; add t.11.1{r2}, t.13.1{r1}
        add edx, ecx
        ; addrof a.14.1{r1}, __random__
        lea rcx, [var_0]
        ; store [a.14.1{r1}], t.11.1{r2}
        mov [rcx], edx
        ; 16:9 return __random__
        ; move t.16.1{r0}, t.16.1{r2}
        mov eax, edx
        add rsp, 8
        ret

        ; i16 random16
_random16:
        sub rsp, 8
        sub rsp, 32
        ; 20:23 return (i16) & 32767
        ; call t.2.1{r0} = random[] -> i32
        call _random
        ; cast t.1.1{r1}(i16), t.2.1{r0}(i32)
        mov cx, ax
        ; move t.0.1{r0}, t.1.1{r1}
        mov ax, cx
        ; and t.0.1{r0}, 32767
        and ax, 32767
        add rsp, 32
        add rsp, 8
        ret

        ; i16 rowColumnToCell@u8@u8
        ;   rsp+16: arg row
        ;   rsp+24: arg column
_rowColumnToCell@u8@u8:
        sub rsp, 8
        ; cast r.1{r1}(i16), row{r1}(u8)
        movzx cx, cl
        ; cast c.1{r2}(i16), column{r2}(u8)
        movzx dx, dl
        ; 25:19 return r * 40 + c
        ; mul t.5.1{r1}, 40
        movsx rcx, cx
        imul  rcx, 40
        ; move t.4.1{r0}, t.5.1{r1}
        mov ax, cx
        ; add t.4.1{r0}, c.1{r2}
        add ax, dx
        add rsp, 8
        ret

        ; u8 getBombCountAround@u8@u8
        ;   rsp+64: arg row
        ;   rsp+72: arg column
        ;   rsp+48: var rowFrom.2
        ;   rsp+49: var rowTo.2
        ;   rsp+50: var colFrom.2
        ;   rsp+51: var colTo.2
        ;   rsp+52: var count.1
_getBombCountAround@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move row{r6}, row{r1}
        mov bl, cl
        ; move rowFrom.1{r0}, row{r6}
        mov al, bl
        ; 30:2 if rowFrom > 0
        ; branch rowFrom.1{r0} lteq 0: if_4_end
        cmp al, 0
        jbe _if_4_end
        ; sub rowFrom.3{r0}, 1
        sub al, 1
        ; move rowFrom.2{r1}, rowFrom.3{r0}
        mov cl, al
_if_4_end:
        ; move rowTo.1{r0}, row{r6}
        mov al, bl
        ; add rowTo.1{r0}, 1
        add al, 1
        ; 34:2 if rowTo >= 20
        ; branch rowTo.1{r0} gteq 20: if_5_then
        cmp al, 20
        jae _if_5_then
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], rowTo.2{r0}
        mov [r12], al
        jmp _if_5_end
_if_5_then:
        ; sub rowTo.3{r0}, 1
        sub al, 1
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], rowTo.2{r0}
        mov [r12], al
_if_5_end:
        ; move colFrom.1{r0}, column{r2}
        mov al, dl
        ; 39:2 if colFrom > 0
        ; branch colFrom.1{r0} lteq 0: if_6_end
        cmp al, 0
        jbe _if_6_end
        ; sub colFrom.3{r0}, 1
        sub al, 1
_if_6_end:
        ; move colTo.1{r3}, column{r2}
        mov r8b, dl
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dl
        ; add colTo.1{r3}, 1
        add r8b, 1
        ; 43:2 if colTo >= 40
        ; branch colTo.1{r3} gteq 40: if_7_then
        cmp r8b, 40
        jae _if_7_then
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], colTo.2{r3}
        mov [r12], r8b
        jmp _if_7_end
_if_7_then:
        ; sub colTo.3{r3}, 1
        sub r8b, 1
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], colTo.2{r3}
        mov [r12], r8b
_if_7_end:
        ; const count.1{r3}, 0
        mov r8b, 0
        ; addrof memVarAddr{r7}, count.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], count.1{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, rowFrom.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], rowFrom.2{r1}
        mov [r12], cl
        ; move colFrom.2{r2}, colFrom.2{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], colFrom.2{r0}
        mov [r12], al
        ; call index.1{r0} = rowColumnToCell@u8@u8[rowFrom.2{r1}, colFrom.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; addrof memVarAddr{r7}, rowFrom.2
        lea r12, [rsp+48]
        ; load rowFrom.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; 49:2 for r <= rowTo
        ; addrof memVarAddr{r7}, count.1
        lea r12, [rsp+52]
        ; load count.1{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move index.2{r3}, index.1{r0}
        mov r8w, ax
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], row{r6}
        mov [r12], bl
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+50]
        ; load colFrom.2{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+51]
        ; load colTo.2{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        jmp _for_8
_for_8_body:
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], colFrom.2{r4}
        mov [r12], r9b
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], colTo.2{r6}
        mov [r12], bl
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], rowTo.2{r5}
        mov [r12], r10b
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        ; load row{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+50]
        ; move c.1{r5}, colFrom.2{r4}
        mov r10b, r9b
        ; 50:3 for c <= colTo
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        jmp _for_9
_for_9_body:
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], colTo.2{r6}
        mov [r12], bl
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        ; load row{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; branch r.2{r1} equals row{r6}: and_11
        cmp cl, bl
        je _and_11
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r0}, [memVarAddr{r7}]
        mov al, [r12]
        jmp _if_10_end
_and_11:
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; branch c.2{r5} notequals column{r0}: if_10_end
        cmp r10b, al
        jne _if_10_end
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], row{r6}
        mov [r12], bl
        jmp _for_9_continue
_if_10_end:
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], row{r6}
        mov [r12], bl
        ; cast t.12.1{r6}(i64), index.3{r3}(i16)
        movsx rbx, r8w
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r0}
        mov [r12], al
        ; addrof t.11.1{r0}, field
        lea rax, [var_1]
        ; add t.11.2{r0}, t.12.1{r6}
        add rax, rbx
        ; load cell.1{r6}, [t.11.2{r0}]
        mov bl, [rax]
        ; 56:4 if cell & 1 != 0
        ; and t.13.1{r6}, 1
        and bl, 1
        ; branch t.13.1{r6} equals 0: for_9_continue
        cmp bl, 0
        je _for_9_continue
        ; add count.6{r2}, 1
        add dl, 1
_for_9_continue:
        ; add c.5{r5}, 1
        add r10b, 1
        ; add index.7{r3}, 1
        add r8w, 1
_for_9:
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+51]
        ; load colTo.2{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; branch c.2{r5} lteq colTo.2{r6}: for_9_body
        cmp r10b, bl
        jbe _for_9_body
        ; cast t.17.1{r5}(i16), colTo.2{r6}(u8)
        movzx r10w, bl
        ; sub t.16.1{r3}, t.17.1{r5}
        sub r8w, r10w
        ; cast t.18.1{r5}(i16), colFrom.2{r4}(u8)
        movzx r10w, r9b
        ; add t.15.1{r3}, t.18.1{r5}
        add r8w, r10w
        ; add t.14.1{r3}, 40
        add r8w, 40
        ; sub index.4{r3}, 1
        sub r8w, 1
        ; add r.4{r1}, 1
        add cl, 1
_for_8:
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+49]
        ; load rowTo.2{r5}, [memVarAddr{r7}]
        mov r10b, [r12]
        ; branch r.2{r1} lteq rowTo.2{r5}: for_8_body
        cmp cl, r10b
        jbe _for_8_body
        ; 62:9 return count
        ; move count.2{r0}, count.2{r2}
        mov al, dl
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; i16 columnToX@u8
        ;   rsp+16: arg column
_columnToX@u8:
        sub rsp, 8
        ; cast c.1{r1}(i16), column{r1}(u8)
        movzx cx, cl
        ; 67:2 if false
        ; const t.2.1{r2}, 0
        mov dl, 0
        ; branch t.2.1{r2} notequals 0: if_13_then
        cmp dl, 0
        jne _if_13_then
        ; 71:17 return c + 1 << 1
        ; add t.4.1{r1}, 1
        add cx, 1
        ; move t.3.1{r0}, t.4.1{r1}
        mov ax, cx
        ; shiftleft t.3.1{r0}, 1
        sal ax, 1
        jmp _columnToX@u8_ret
_if_13_then:
        ; 68:10 return c
        ; move c.1{r0}, c.1{r1}
        mov ax, cx
_columnToX@u8_ret:
        add rsp, 8
        ret

        ; void printCellAt@u8@u8
        ;   rsp+64: arg row
        ;   rsp+72: arg column
_printCellAt@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move row{r6}, row{r1}
        mov bl, cl
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dl
        ; call t.5.1{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.4.1{r0}(i64), t.5.1{r0}(i16)
        movsx rax, ax
        ; addrof t.3.1{r4}, field
        lea r9, [var_1]
        ; add t.3.2{r4}, t.4.1{r0}
        add r9, rax
        ; load cell.1{r1}, [t.3.2{r4}]
        mov cl, [r9]
        ; move row{r2}, row{r6}
        mov dl, bl
        ; load column{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; call printCellAt@u8@u8@u8[cell.1{r1}, row{r2}, column{r3}]
        call _printCellAt@u8@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printCellAt@u8@u8@u8
        ;   rsp+64: arg cell
        ;   rsp+72: arg row
        ;   rsp+80: arg column
_printCellAt@u8@u8@u8:
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
        mov [r12], dl
        ; move column{r1}, column{r3}
        mov cl, r8b
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], column{r3}
        mov [r12], r8b
        ; call x.1{r0} = columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+72]
        ; load row{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; cast t.4.1{r1}(i16), row{r2}(u8)
        movzx cx, dl
        ; move x.1{r2}, x.1{r0}
        mov dx, ax
        ; call setCursor@i16@i16[t.4.1{r1}, x.1{r2}]
        call _setCursor@i16@i16
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; load row{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+80]
        ; load column{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; call printCell@u8@u8@u8[cell{r1}, row{r2}, column{r3}]
        call _printCell@u8@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printCell@u8@u8@u8
        ;   rsp+64: arg cell
        ;   rsp+72: arg row
        ;   rsp+80: arg column
_printCell@u8@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const chr.1{r6}, 46
        mov bl, 46
        ; 87:2 if cell & 2 != 0
        ; move t.5.1{r7}, cell{r1}
        mov r12b, cl
        ; and t.5.1{r7}, 2
        and r12b, 2
        ; branch t.5.1{r7} notequals 0: if_14_then
        cmp r12b, 0
        jne _if_14_then
        ; 101:7 if cell & 4 != 0
        ; move t.7.1{r7}, cell{r1}
        mov r12b, cl
        ; and t.7.1{r7}, 4
        and r12b, 4
        ; branch t.7.1{r7} equals 0: if_14_end, if_17_then
        cmp r12b, 0
        je _if_14_end
        jmp _if_17_then
_if_14_then:
        ; 88:3 if cell & 1 != 0
        ; move t.6.1{r6}, cell{r1}
        mov bl, cl
        ; and t.6.1{r6}, 1
        and bl, 1
        ; branch t.6.1{r6} equals 0: if_15_else, if_15_then
        cmp bl, 0
        je _if_15_else
        jmp _if_15_then
_if_17_then:
        ; const chr.3{r6}, 35
        mov bl, 35
        jmp _if_14_end
_if_15_else:
        ; move row{r1}, row{r2}
        mov cl, dl
        ; move column{r2}, column{r3}
        mov dl, r8b
        ; call count.1{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; 93:4 if count > 0
        ; branch count.1{r0} lteq 0: if_16_else, if_16_then
        cmp al, 0
        jbe _if_16_else
        jmp _if_16_then
_if_15_then:
        ; const chr.4{r6}, 42
        mov bl, 42
        jmp _if_14_end
_if_16_else:
        ; const chr.5{r6}, 32
        mov bl, 32
        jmp _if_14_end
_if_16_then:
        ; move chr.6{r6}, count.1{r0}
        mov bl, al
        ; add chr.6{r6}, 48
        add bl, 48
_if_14_end:
        ; move chr.2{r1}, chr.2{r6}
        mov cl, bl
        ; call printChar@u8[chr.2{r1}]
        call _printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void initializeScreen
_initializeScreen:
        sub rsp, 8
        sub rsp, 32
        ; call printField[]
        call _printField
        add rsp, 32
        add rsp, 8
        ret

        ; void printField
        ;   rsp+48: var column.2
_printField:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const arg.0.0{r1}, 0
        mov cx, 0
        ; const arg.0.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const row.1{r6}, 0
        mov bl, 0
        ; 120:2 for row < 20
        jmp _for_18
_for_18_body:
        ; cast t.3.1{r1}(i16), row.2{r6}(u8)
        movzx cx, bl
        ; const arg.1.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[t.3.1{r1}, arg.1.1{r2}]
        call _setCursor@i16@i16
        ; 122:3 if true
        ; const t.4.1{r0}, 1
        mov al, 1
        ; branch t.4.1{r0} equals 0: if_19_end
        cmp al, 0
        je _if_19_end
        ; const arg.2.0{r1}, 124
        mov cl, 124
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
_if_19_end:
        ; const column.1{r0}, 0
        mov al, 0
        ; 125:3 for column < 40
        ; move column.2{r2}, column.1{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], column.2{r2}
        mov [r12], dl
        jmp _for_20
_for_20_body:
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], column.2{r2}
        mov [r12], dl
        ; 126:4 if true
        ; const t.5.1{r0}, 1
        mov al, 1
        ; branch t.5.1{r0} equals 0: if_21_end
        cmp al, 0
        je _if_21_end
        ; const arg.3.0{r1}, 32
        mov cl, 32
        ; call printChar@u8[arg.3.0{r1}]
        call _printChar@u8
_if_21_end:
        ; move row.2{r1}, row.2{r6}
        mov cl, bl
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+48]
        ; load column.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; call t.8.1{r0} = rowColumnToCell@u8@u8[row.2{r1}, column.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.7.1{r0}(i64), t.8.1{r0}(i16)
        movsx rax, ax
        ; addrof t.6.1{r4}, field
        lea r9, [var_1]
        ; add t.6.2{r4}, t.7.1{r0}
        add r9, rax
        ; load cell.1{r1}, [t.6.2{r4}]
        mov cl, [r9]
        ; move row.2{r2}, row.2{r6}
        mov dl, bl
        ; load column.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; call printCell@u8@u8@u8[cell.1{r1}, row.2{r2}, column.2{r3}]
        call _printCell@u8@u8@u8
        ; load column.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move column.4{r0}, column.2{r2}
        mov al, dl
        ; add column.4{r0}, 1
        add al, 1
        ; move column.2{r2}, column.4{r0}
        mov dl, al
_for_20:
        ; branch column.2{r2} lt 40: for_20_body
        cmp dl, 40
        jb _for_20_body
        ; 132:3 if true
        ; const t.9.1{r0}, 1
        mov al, 1
        ; branch t.9.1{r0} equals 0: for_18_continue
        cmp al, 0
        je _for_18_continue
        ; const t.10.1{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.10.1{r1}]
        call _printString@@u8
_for_18_continue:
        ; move row.7{r0}, row.2{r6}
        mov al, bl
        ; add row.7{r0}, 1
        add al, 1
        ; move row.2{r6}, row.7{r0}
        mov bl, al
_for_18:
        ; branch row.2{r6} lt 20: for_18_body
        cmp bl, 20
        jb _for_18_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void showCursor@u8@u8@bool
        ;   rsp+64: arg row
        ;   rsp+72: arg column
        ;   rsp+80: arg show
        ;   rsp+48: var x.1
        ;   rsp+50: var chr.2
_showCursor@u8@u8@bool:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move row{r6}, row{r1}
        mov bl, cl
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], show{r3}
        mov [r12], r8b
        ; 139:2 if false
        ; const t.6.1{r0}, 0
        mov al, 0
        ; branch t.6.1{r0} notequals 0: if_23_then
        cmp al, 0
        jne _if_23_then
        ; move column{r1}, column{r2}
        mov cl, dl
        ; call x.1{r0} = columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; cast t.8.1{r1}(i16), row{r6}(u8)
        movzx cx, bl
        ; move t.9.1{r2}, x.1{r0}
        mov dx, ax
        ; addrof memVarAddr{r7}, x.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], x.1{r0}
        mov [r12], ax
        ; sub t.9.1{r2}, 1
        sub dx, 1
        ; call setCursor@i16@i16[t.8.1{r1}, t.9.1{r2}]
        call _setCursor@i16@i16
        ; const chr.1{r0}, 32
        mov al, 32
        ; 150:2 if show
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; load show{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; branch show{r3} equals 0: showCursor@u8@u8@bool.no_critical_edge_10, if_25_then
        cmp r8b, 0
        je _showCursor@u8@u8@bool.no_critical_edge_10
        jmp _if_25_then
_if_23_then:
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; load show{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; branch show{r3} equals 0: showCursor@u8@u8@bool_ret, if_24_then
        cmp r8b, 0
        je _showCursor@u8@u8@bool_ret
        jmp _if_24_then
_showCursor@u8@u8@bool.no_critical_edge_10:
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], show{r3}
        mov [r12], r8b
        ; move chr.2{r1}, chr.1{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, chr.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], chr.2{r1}
        mov [r12], cl
        jmp _if_25_end
_if_25_then:
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], show{r3}
        mov [r12], r8b
        ; const chr.3{r0}, 91
        mov al, 91
        ; move chr.2{r1}, chr.3{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, chr.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], chr.2{r1}
        mov [r12], cl
        jmp _if_25_end
_if_24_then:
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move column{r1}, column{r2}
        mov cl, dl
        ; call x.3{r0} = columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; cast t.7.1{r1}(i16), row{r6}(u8)
        movzx cx, bl
        ; move x.3{r2}, x.3{r0}
        mov dx, ax
        ; call setCursor@i16@i16[t.7.1{r1}, x.3{r2}]
        call _setCursor@i16@i16
        jmp _showCursor@u8@u8@bool_ret
_if_25_end:
        ; addrof memVarAddr{r7}, chr.2
        lea r12, [rsp+50]
        ; load chr.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; call printChar@u8[chr.2{r1}]
        call _printChar@u8
        ; cast t.10.1{r1}(i16), row{r6}(u8)
        movzx cx, bl
        ; addrof memVarAddr{r7}, x.1
        lea r12, [rsp+48]
        ; load x.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.11.1{r2}, x.1{r0}
        mov dx, ax
        ; add t.11.1{r2}, 1
        add dx, 1
        ; call setCursor@i16@i16[t.10.1{r1}, t.11.1{r2}]
        call _setCursor@i16@i16
        ; 156:2 if show
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; load show{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; branch show{r3} notequals 0: if_26_then
        cmp r8b, 0
        jne _if_26_then
        ; addrof memVarAddr{r7}, chr.2
        lea r12, [rsp+50]
        ; load chr.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp _if_26_end
_if_26_then:
        ; const chr.5{r6}, 93
        mov bl, 93
        ; move chr.4{r1}, chr.5{r6}
        mov cl, bl
_if_26_end:
        ; call printChar@u8[chr.4{r1}]
        call _printChar@u8
_showCursor@u8@u8@bool_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printSpaces@i16
        ;   rsp+48: arg i
_printSpaces@i16:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move i.1{r6}, i{r1}
        mov bx, cx
        jmp _for_27
_for_27_body:
        ; const arg.0.0{r1}, 48
        mov cl, 48
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; move i.2{r0}, i.1{r6}
        mov ax, bx
        ; sub i.2{r0}, 1
        sub ax, 1
        ; move i.1{r6}, i.2{r0}
        mov bx, ax
_for_27:
        ; branch i.1{r6} gt 0: for_27_body
        cmp bx, 0
        jg _for_27_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; u8 getDigitCount@i16
        ;   rsp+16: arg value
_getDigitCount@i16:
        sub rsp, 8
        ; const count.1{r3}, 0
        mov r8b, 0
        ; 170:2 if value < 0
        ; branch value{r1} lt 0: if_28_then
        cmp cx, 0
        jl _if_28_then
        ; move value.1{r4}, value{r1}
        mov r9w, cx
        jmp _while_29
_if_28_then:
        ; const count.3{r3}, 1
        mov r8b, 1
        ; neg value.2{r4}, value{r1}
        mov r9, rcx
        neg r9
_while_29:
        ; add count.5{r3}, 1
        add r8b, 1
        ; move value.4{r0}, value.4{r4}
        mov ax, r9w
        ; div value.4{r0}, 10
        movsx rax, ax
        cqo
        mov rcx, 10
        idiv rcx
        ; move value.4{r4}, value.4{r0}
        mov r9w, ax
        ; 178:3 if value == 0
        ; branch value.4{r4} notequals 0: while_29
        cmp r9w, 0
        jne _while_29
        ; 183:9 return count
        ; move count.5{r0}, count.5{r3}
        mov al, r8b
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+48: var r.2
        ;   rsp+49: var c.2
_getHiddenCount:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const count.1{r6}, 0
        mov bx, 0
        ; const r.1{r0}, 0
        mov al, 0
        ; 188:2 for r < 20
        ; move r.2{r1}, r.1{r0}
        mov cl, al
        jmp _for_31
_for_31_body:
        ; const c.1{r0}, 0
        mov al, 0
        ; 189:3 for c < 40
        ; move c.2{r2}, c.1{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r.2{r1}
        mov [r12], cl
        jmp _for_32
_for_32_body:
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; load r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], c.2{r2}
        mov [r12], dl
        ; call t.6.1{r0} = rowColumnToCell@u8@u8[r.2{r1}, c.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.5.1{r1}(i64), t.6.1{r0}(i16)
        movsx rcx, ax
        ; addrof t.4.1{r2}, field
        lea rdx, [var_1]
        ; add t.4.2{r2}, t.5.1{r1}
        add rdx, rcx
        ; load cell.1{r1}, [t.4.2{r2}]
        mov cl, [rdx]
        ; 191:4 if cell & 6 == 0
        ; and t.7.1{r1}, 6
        and cl, 6
        ; branch t.7.1{r1} equals 0: if_33_then
        cmp cl, 0
        je _if_33_then
        ; move count.4{r1}, count.3{r6}
        mov cx, bx
        jmp _for_32_continue
_if_33_then:
        ; move count.5{r1}, count.3{r6}
        mov cx, bx
        ; add count.5{r1}, 1
        add cx, 1
_for_32_continue:
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+49]
        ; load c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; add c.4{r2}, 1
        add dl, 1
        ; move count.3{r6}, count.4{r1}
        mov bx, cx
_for_32:
        ; branch c.2{r2} lt 40: for_32_body
        cmp dl, 40
        jb _for_32_body
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; load r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; add r.4{r1}, 1
        add cl, 1
_for_31:
        ; branch r.2{r1} lt 20: for_31_body
        cmp cl, 20
        jb _for_31_body
        ; 196:9 return count
        ; move count.2{r0}, count.2{r6}
        mov ax, bx
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; bool printLeft
        ;   rsp+48: var leftDigits.1
        ;   rsp+50: var bombDigits.1
_printLeft:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; call count.1{r0} = getHiddenCount[] -> i16
        call _getHiddenCount
        ; move count.1{r6}, count.1{r0}
        mov bx, ax
        ; move count.1{r1}, count.1{r6}
        mov cx, bx
        ; call t.3.1{r0} = getDigitCount@i16[count.1{r1}] -> u8
        call _getDigitCount@i16
        ; cast leftDigits.1{r0}(i16), t.3.1{r0}(u8)
        movzx ax, al
        ; addrof memVarAddr{r7}, leftDigits.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], leftDigits.1{r0}
        mov [r12], ax
        ; const arg.2.0{r1}, 72
        mov cx, 72
        ; call t.4.1{r0} = getDigitCount@i16[arg.2.0{r1}] -> u8
        call _getDigitCount@i16
        ; cast bombDigits.1{r0}(i16), t.4.1{r0}(u8)
        movzx ax, al
        ; addrof memVarAddr{r7}, bombDigits.1
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombDigits.1{r0}
        mov [r12], ax
        ; const arg.3.0{r1}, 20
        mov cx, 20
        ; const arg.3.1{r2}, 6
        mov dx, 6
        ; call setCursor@i16@i16[arg.3.0{r1}, arg.3.1{r2}]
        call _setCursor@i16@i16
        ; load bombDigits.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.5.1{r1}, bombDigits.1{r0}
        mov cx, ax
        ; addrof memVarAddr{r7}, leftDigits.1
        lea r12, [rsp+48]
        ; load leftDigits.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; sub t.5.1{r1}, leftDigits.1{r0}
        sub cx, ax
        ; call printSpaces@i16[t.5.1{r1}]
        call _printSpaces@i16
        ; move count.1{r1}, count.1{r6}
        mov cx, bx
        ; call printUint@i16[count.1{r1}]
        call _printUint@i16
        ; 207:15 return count == 0
        ; equals t.6.1{r0}, count.1{r6}, 0
        cmp bx, 0
        sete al
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; i16 abs@i16
        ;   rsp+16: arg a
_abs@i16:
        sub rsp, 8
        ; branch a{r1} lt 0: if_34_then
        cmp cx, 0
        jl _if_34_then
        ; 214:9 return a
        ; move a{r0}, a{r1}
        mov ax, cx
        jmp _abs@i16_ret
_if_34_then:
        ; 212:10 return -a
        ; neg t.1.1{r1}, a{r1}
        neg rcx
        ; move t.1.1{r0}, t.1.1{r1}
        mov ax, cx
_abs@i16_ret:
        add rsp, 8
        ret

        ; void clearField
_clearField:
        sub rsp, 8
        ; const index.1{r0}, 0
        mov ax, 0
        ; const i.1{r1}, 800
        mov cx, 800
        ; 219:2 for i > 0
        jmp _for_35
_for_35_body:
        ; const t.2.1{r2}, 0
        mov dl, 0
        ; cast t.4.1{r3}(i64), index.2{r0}(i16)
        movsx r8, ax
        ; addrof t.3.1{r4}, field
        lea r9, [var_1]
        ; add t.3.2{r4}, t.4.1{r3}
        add r9, r8
        ; store [t.3.2{r4}], t.2.1{r2}
        mov [r9], dl
        ; sub i.3{r1}, 1
        sub cx, 1
        ; add index.3{r0}, 1
        add ax, 1
_for_35:
        ; branch i.2{r1} gt 0: for_35_body
        cmp cx, 0
        jg _for_35_body
        add rsp, 8
        ret

        ; void initField@u8@u8
        ;   rsp+80: arg curr_r
        ;   rsp+88: arg curr_c
        ;   rsp+48: var c.1
        ;   rsp+50: var bombs.2
        ;   rsp+52: var row.1
        ;   rsp+54: var column.1
        ;   rsp+56: var t.13.1
_initField@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; cast r.1{r6}(i16), curr_r{r1}(u8)
        movzx bx, cl
        ; cast c.1{r0}(i16), curr_c{r2}(u8)
        movzx ax, dl
        ; addrof memVarAddr{r7}, c.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], c.1{r0}
        mov [r12], ax
        ; const bombs.1{r0}, 72
        mov ax, 72
        ; 227:2 for bombs > 0
        ; addrof memVarAddr{r7}, bombs.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombs.2{r0}
        mov [r12], ax
        jmp _for_36
_for_36_body:
        ; addrof memVarAddr{r7}, bombs.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombs.2{r0}
        mov [r12], ax
        ; call t.7.1{r0} = random16[] -> i16
        call _random16
        ; move row.1{r3}, t.7.1{r0}
        mov r8w, ax
        ; mod row.1{r2}, row.1{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move row.1{r3}, row.1{r2}
        mov r8w, dx
        ; addrof memVarAddr{r7}, row.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], row.1{r3}
        mov [r12], r8w
        ; call t.8.1{r0} = random16[] -> i16
        call _random16
        ; move column.1{r3}, t.8.1{r0}
        mov r8w, ax
        ; mod column.1{r2}, column.1{r0}, 40
        movsx rax, ax
        cqo
        mov rcx, 40
        idiv rcx
        ; move column.1{r3}, column.1{r2}
        mov r8w, dx
        ; addrof memVarAddr{r7}, column.1
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], column.1{r3}
        mov [r12], r8w
        ; 230:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=5, scope=function, type=i16, varIsArray=false, location=230:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=230:20], location=230:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=6, scope=function, type=i16, varIsArray=false, location=231:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=231:20], location=231:18]]) > 1
        ; addrof memVarAddr{r7}, row.1
        lea r12, [rsp+52]
        ; load row.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.10.1{r1}, row.1{r0}
        mov cx, ax
        ; sub t.10.1{r1}, r.1{r6}
        sub cx, bx
        ; call t.9.1{r0} = abs@i16[t.10.1{r1}] -> i16
        call _abs@i16
        ; branch t.9.1{r0} gt 1: if_37_then
        cmp ax, 1
        jg _if_37_then
        ; addrof memVarAddr{r7}, column.1
        lea r12, [rsp+54]
        ; load column.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.12.1{r1}, column.1{r0}
        mov cx, ax
        ; addrof memVarAddr{r7}, c.1
        lea r12, [rsp+48]
        ; load c.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; sub t.12.1{r1}, c.1{r0}
        sub cx, ax
        ; call t.11.1{r0} = abs@i16[t.12.1{r1}] -> i16
        call _abs@i16
        ; branch t.11.1{r0} lteq 1: for_36_continue, if_37_then
        cmp ax, 1
        jle _for_36_continue
_if_37_then:
        ; const t.13.1{r0}, 1
        mov al, 1
        ; addrof memVarAddr{r7}, t.13.1
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], t.13.1{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, row.1
        lea r12, [rsp+52]
        ; load row.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; cast t.17.1{r1}(u8), row.1{r0}(i16)
        mov cl, al
        ; addrof memVarAddr{r7}, column.1
        lea r12, [rsp+54]
        ; load column.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; cast t.18.1{r2}(u8), column.1{r0}(i16)
        mov dl, al
        ; call t.16.1{r0} = rowColumnToCell@u8@u8[t.17.1{r1}, t.18.1{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.15.1{r0}(i64), t.16.1{r0}(i16)
        movsx rax, ax
        ; addrof t.14.1{r1}, field
        lea rcx, [var_1]
        ; add t.14.2{r1}, t.15.1{r0}
        add rcx, rax
        ; addrof memVarAddr{r7}, t.13.1
        lea r12, [rsp+56]
        ; load t.13.1{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; store [t.14.2{r1}], t.13.1{r0}
        mov [rcx], al
_for_36_continue:
        ; addrof memVarAddr{r7}, bombs.2
        lea r12, [rsp+50]
        ; load bombs.2{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; sub bombs.5{r0}, 1
        sub ax, 1
_for_36:
        ; branch bombs.2{r0} gt 0: for_36_body
        cmp ax, 0
        jg _for_36_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void maybeRevealAround@u8@u8
        ;   rsp+80: arg row
        ;   rsp+88: arg column
        ;   rsp+48: var r.2
        ;   rsp+50: var index.3
        ;   rsp+52: var c.2
        ;   rsp+53: var rowFrom.2
        ;   rsp+54: var rowTo.2
        ;   rsp+55: var colFrom.2
        ;   rsp+56: var colTo.2
        ;   rsp+57: var neighborRow.2
        ;   rsp+58: var neighborIndex.3
        ;   rsp+60: var neighborColumn.2
_maybeRevealAround@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move row{r6}, row{r1}
        mov bl, cl
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dl
        ; call printCellAt@u8@u8[row{r1}, column{r2}]
        call _printCellAt@u8@u8
        ; 239:2 if getBombCountAround@u8@u8([ExprVarAccess[varName=row, index=0, scope=parameter, type=u8, varIsArray=false, location=239:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=u8, varIsArray=false, location=239:30]]) != 0
        ; move row{r1}, row{r6}
        mov cl, bl
        ; load column{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; call t.15.1{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; branch t.15.1{r0} notequals 0: maybeRevealAround@u8@u8_ret
        cmp al, 0
        jne _maybeRevealAround@u8@u8_ret
        ; const changed.1{r6}, 1
        mov bl, 1
        ; 244:2 while changed
        jmp _while_40
_while_40_body:
        ; const changed.3{r6}, 0
        mov bl, 0
        ; const index.1{r0}, 0
        mov ax, 0
        ; const r.1{r3}, 0
        mov r8b, 0
        ; 247:3 for r < 20
        ; move r.2{r1}, r.1{r3}
        mov cl, r8b
        ; move index.2{r2}, index.2{r0}
        mov dx, ax
        ; move r.2{r0}, r.2{r1}
        mov al, cl
        ; move index.2{r1}, index.2{r2}
        mov cx, dx
        jmp _for_41
_for_41_body:
        ; move index.2{r2}, index.2{r1}
        mov dx, cx
        ; move r.2{r1}, r.2{r0}
        mov cl, al
        ; move index.2{r0}, index.2{r2}
        mov ax, dx
        ; const c.1{r3}, 0
        mov r8b, 0
        ; 248:4 for c < 40
        ; move c.2{r2}, c.1{r3}
        mov dl, r8b
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r.2{r1}
        mov [r12], cl
        ; move index.3{r1}, index.3{r0}
        mov cx, ax
        jmp _for_42
_for_42_body:
        ; move index.3{r0}, index.3{r1}
        mov ax, cx
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; load r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; cast t.17.1{r3}(i64), index.3{r0}(i16)
        movsx r8, ax
        ; addrof memVarAddr{r7}, index.3
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], index.3{r0}
        mov [r12], ax
        ; addrof t.16.1{r0}, field
        lea rax, [var_1]
        ; add t.16.2{r0}, t.17.1{r3}
        add rax, r8
        ; load cell.1{r0}, [t.16.2{r0}]
        mov al, [rax]
        ; 250:5 if cell & 2 == 0 || cell & 1 != 0
        ; move t.18.1{r3}, cell.1{r0}
        mov r8b, al
        ; and t.18.1{r3}, 2
        and r8b, 2
        ; branch t.18.1{r3} notequals 0: or_44
        cmp r8b, 0
        jne _or_44
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], c.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        jmp _for_42_continue
_or_44:
        ; and t.19.1{r0}, 1
        and al, 1
        ; branch t.19.1{r0} equals 0: if_43_end
        cmp al, 0
        je _if_43_end
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], c.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r.2{r1}
        mov [r12], cl
        jmp _for_42_continue
_if_43_end:
        ; 253:5 if getBombCountAround@u8@u8([ExprVarAccess[varName=r, index=4, scope=function, type=u8, varIsArray=false, location=253:28], ExprVarAccess[varName=c, index=5, scope=function, type=u8, varIsArray=false, location=253:31]]) != 0
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], c.2{r2}
        mov [r12], dl
        ; call t.20.1{r0} = getBombCountAround@u8@u8[r.2{r1}, c.2{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; branch t.20.1{r0} notequals 0: for_42_continue
        cmp al, 0
        jne _for_42_continue
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; load r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; move rowFrom.1{r0}, r.2{r1}
        mov al, cl
        ; 258:5 if rowFrom > 0
        ; branch rowFrom.1{r0} lteq 0: if_46_end
        cmp al, 0
        jbe _if_46_end
        ; sub rowFrom.3{r0}, 1
        sub al, 1
_if_46_end:
        ; move rowTo.1{r3}, r.2{r1}
        mov r8b, cl
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r.2{r1}
        mov [r12], cl
        ; add rowTo.1{r3}, 1
        add r8b, 1
        ; 262:5 if rowTo >= 20
        ; branch rowTo.1{r3} gteq 20: if_47_then
        cmp r8b, 20
        jae _if_47_then
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], rowTo.2{r3}
        mov [r12], r8b
        jmp _if_47_end
_if_47_then:
        ; sub rowTo.3{r3}, 1
        sub r8b, 1
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], rowTo.2{r3}
        mov [r12], r8b
_if_47_end:
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+52]
        ; load c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move colFrom.1{r3}, c.2{r2}
        mov r8b, dl
        ; 267:5 if colFrom > 0
        ; branch colFrom.1{r3} lteq 0: if_48_end
        cmp r8b, 0
        jbe _if_48_end
        ; sub colFrom.3{r3}, 1
        sub r8b, 1
_if_48_end:
        ; move colTo.1{r4}, c.2{r2}
        mov r9b, dl
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], c.2{r2}
        mov [r12], dl
        ; add colTo.1{r4}, 1
        add r9b, 1
        ; 271:5 if colTo >= 40
        ; branch colTo.1{r4} gteq 40: if_49_then
        cmp r9b, 40
        jae _if_49_then
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], colTo.2{r4}
        mov [r12], r9b
        jmp _if_49_end
_if_49_then:
        ; sub colTo.3{r4}, 1
        sub r9b, 1
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], colTo.2{r4}
        mov [r12], r9b
_if_49_end:
        ; move rowFrom.2{r1}, rowFrom.2{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, rowFrom.2
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], rowFrom.2{r0}
        mov [r12], al
        ; move colFrom.2{r2}, colFrom.2{r3}
        mov dl, r8b
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], colFrom.2{r3}
        mov [r12], r8b
        ; call neighborIndex.1{r0} = rowColumnToCell@u8@u8[rowFrom.2{r1}, colFrom.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; addrof memVarAddr{r7}, rowFrom.2
        lea r12, [rsp+53]
        ; load rowFrom.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; move neighborRow.1{r4}, rowFrom.2{r1}
        mov r9b, cl
        ; 275:5 for neighborRow <= rowTo
        ; move neighborRow.2{r2}, neighborRow.1{r4}
        mov dl, r9b
        ; move neighborIndex.2{r1}, neighborIndex.2{r0}
        mov cx, ax
        ; move neighborRow.2{r3}, neighborRow.2{r2}
        mov r8b, dl
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+55]
        ; load colFrom.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+56]
        ; load colTo.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        jmp _for_50
_for_50_body:
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], colFrom.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], colTo.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], rowTo.2{r4}
        mov [r12], r9b
        ; move neighborIndex.2{r0}, neighborIndex.2{r1}
        mov ax, cx
        ; move neighborRow.2{r2}, neighborRow.2{r3}
        mov dl, r8b
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+55]
        ; load colFrom.2{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; move neighborColumn.1{r5}, colFrom.2{r4}
        mov r10b, r9b
        ; 276:6 for neighborColumn <= colTo
        ; move neighborColumn.2{r3}, neighborColumn.1{r5}
        mov r8b, r10b
        ; addrof memVarAddr{r7}, neighborRow.2
        lea r12, [rsp+57]
        ; store [memVarAddr{r7}], neighborRow.2{r2}
        mov [r12], dl
        jmp _for_51
_for_51_body:
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], colTo.2{r0}
        mov [r12], al
        ; move neighborIndex.3{r0}, neighborIndex.3{r1}
        mov ax, cx
        ; addrof memVarAddr{r7}, neighborRow.2
        lea r12, [rsp+57]
        ; load neighborRow.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; cast t.22.1{r4}(i64), neighborIndex.3{r0}(i16)
        movsx r9, ax
        ; addrof t.21.1{r5}, field
        lea r10, [var_1]
        ; add t.21.2{r5}, t.22.1{r4}
        add r10, r9
        ; load neighborCell.1{r4}, [t.21.2{r5}]
        mov r9b, [r10]
        ; 278:7 if neighborCell & 2 != 0
        ; move t.23.1{r5}, neighborCell.1{r4}
        mov r10b, r9b
        ; and t.23.1{r5}, 2
        and r10b, 2
        ; branch t.23.1{r5} equals 0: if_52_end
        cmp r10b, 0
        je _if_52_end
        ; addrof memVarAddr{r7}, neighborColumn.2
        lea r12, [rsp+60]
        ; store [memVarAddr{r7}], neighborColumn.2{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, neighborIndex.3
        lea r12, [rsp+58]
        ; store [memVarAddr{r7}], neighborIndex.3{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, neighborRow.2
        lea r12, [rsp+57]
        jmp _for_51_continue
_if_52_end:
        ; move t.24.1{r6}, neighborCell.1{r4}
        mov bl, r9b
        ; or t.24.1{r6}, 2
        or bl, 2
        ; cast t.26.1{r4}(i64), neighborIndex.3{r0}(i16)
        movsx r9, ax
        ; addrof t.25.1{r5}, field
        lea r10, [var_1]
        ; add t.25.2{r5}, t.26.1{r4}
        add r10, r9
        ; store [t.25.2{r5}], t.24.1{r6}
        mov [r10], bl
        ; move t.29.1{r6}, t.29.1{r4}
        mov rbx, r9
        ; addrof memVarAddr{r7}, neighborIndex.3
        lea r12, [rsp+58]
        ; store [memVarAddr{r7}], neighborIndex.3{r0}
        mov [r12], ax
        ; addrof t.28.1{r0}, field
        lea rax, [var_1]
        ; move t.28.2{r0}, t.28.2{r5}
        mov rax, r10
        ; load t.27.1{r1}, [t.28.2{r0}]
        mov cl, [rax]
        ; addrof memVarAddr{r7}, neighborRow.2
        lea r12, [rsp+57]
        ; store [memVarAddr{r7}], neighborRow.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, neighborColumn.2
        lea r12, [rsp+60]
        ; store [memVarAddr{r7}], neighborColumn.2{r3}
        mov [r12], r8b
        ; call printCellAt@u8@u8@u8[t.27.1{r1}, neighborRow.2{r2}, neighborColumn.2{r3}]
        call _printCellAt@u8@u8@u8
        ; const changed.14{r0}, 1
        mov al, 1
        ; move changed.13{r6}, changed.14{r0}
        mov bl, al
_for_51_continue:
        ; addrof memVarAddr{r7}, neighborColumn.2
        lea r12, [rsp+60]
        ; load neighborColumn.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; move neighborColumn.4{r0}, neighborColumn.2{r3}
        mov al, r8b
        ; add neighborColumn.4{r0}, 1
        add al, 1
        ; addrof memVarAddr{r7}, neighborIndex.3
        lea r12, [rsp+58]
        ; load neighborIndex.3{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; add neighborIndex.6{r1}, 1
        add cx, 1
        ; move neighborColumn.2{r3}, neighborColumn.4{r0}
        mov r8b, al
_for_51:
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+56]
        ; load colTo.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; branch neighborColumn.2{r3} lteq colTo.2{r0}: for_51_body
        cmp r8b, al
        jbe _for_51_body
        ; cast t.33.1{r2}(i16), colTo.2{r0}(u8)
        movzx dx, al
        ; sub t.32.1{r1}, t.33.1{r2}
        sub cx, dx
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+55]
        ; load colFrom.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; cast t.34.1{r3}(i16), colFrom.2{r2}(u8)
        movzx r8w, dl
        ; add t.31.1{r1}, t.34.1{r3}
        add cx, r8w
        ; add t.30.1{r1}, 40
        add cx, 40
        ; sub neighborIndex.4{r1}, 1
        sub cx, 1
        ; addrof memVarAddr{r7}, neighborRow.2
        lea r12, [rsp+57]
        ; load neighborRow.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; add neighborRow.4{r3}, 1
        add r8b, 1
_for_50:
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+54]
        ; load rowTo.2{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; branch neighborRow.2{r3} lteq rowTo.2{r4}: for_50_body, for_42_continue
        cmp r8b, r9b
        jbe _for_50_body
_for_42_continue:
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+52]
        ; load c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move c.4{r0}, c.2{r2}
        mov al, dl
        ; add c.4{r0}, 1
        add al, 1
        ; addrof memVarAddr{r7}, index.3
        lea r12, [rsp+50]
        ; load index.3{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; add index.5{r1}, 1
        add cx, 1
        ; move c.2{r2}, c.4{r0}
        mov dl, al
_for_42:
        ; branch c.2{r2} lt 40: for_42_body
        cmp dl, 40
        jb _for_42_body
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; load r.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; add r.4{r0}, 1
        add al, 1
_for_41:
        ; branch r.2{r0} lt 20: for_41_body, while_40
        cmp al, 20
        jb _for_41_body
_while_40:
        ; branch changed.2{r6} notequals 0: while_40_body, maybeRevealAround@u8@u8_ret
        cmp bl, 0
        jne _while_40_body
_maybeRevealAround@u8@u8_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void main
        ;   rsp+48: var curr_c.2
        ;   rsp+49: var curr_r.2
        ;   rsp+50: var chr.1
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; const t.8.1{r6}, 0
        mov ebx, 0
        ; addrof a.9.1{r0}, __random__
        lea rax, [var_0]
        ; store [a.9.1{r0}], t.8.1{r6}
        mov [rax], ebx
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov ecx, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; const needsInitialize.1{r6}, 1
        mov bl, 1
        ; call clearField[]
        call _clearField
        ; call initializeScreen[]
        call _initializeScreen
        ; const arg.3.0{r1}, 20
        mov cx, 20
        ; const arg.3.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.3.0{r1}, arg.3.1{r2}]
        call _setCursor@i16@i16
        ; const t.10.1{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[t.10.1{r1}]
        call _printString@@u8
        ; const curr_c.1{r0}, 20
        mov al, 20
        ; const curr_r.1{r1}, 10
        mov cl, 10
        ; 302:2 while true
        ; move curr_c.2{r2}, curr_c.1{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r.2{r1}
        mov [r12], cl
        jmp _while_53
_if_54_then:
        ; 304:4 if printLeft([])
        ; call t.11.1{r0} = printLeft[] -> bool
        call _printLeft
        ; branch t.11.1{r0} notequals 0: if_55_then, if_54_end
        cmp al, 0
        jne _if_55_then
_if_54_end:
        ; const t.13.1{r3}, 1
        mov r8b, 1
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; call showCursor@u8@u8@bool[curr_r.2{r1}, curr_c.2{r2}, t.13.1{r3}]
        call _showCursor@u8@u8@bool
        ; call chr.1{r0} = getChar[] -> i16
        call _getChar
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], chr.1{r0}
        mov [r12], ax
        ; const t.14.1{r3}, 0
        mov r8b, 0
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; call showCursor@u8@u8@bool[curr_r.2{r1}, curr_c.2{r2}, t.14.1{r3}]
        call _showCursor@u8@u8@bool
        ; 313:3 if chr == 27
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+50]
        ; load chr.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; branch chr.1{r0} equals 27: main_ret
        cmp ax, 27
        je _main_ret
        ; branch chr.1{r0} equals 13: if_57_then
        cmp ax, 13
        je _if_57_then
        ; branch chr.1{r0} notequals -8120: if_61_else, if_61_then
        cmp ax, -8120
        jne _if_61_else
        jmp _if_61_then
_if_57_then:
        ; branch needsInitialize.2{r6} equals 0: main.no_critical_edge_39, if_58_then
        cmp bl, 0
        je _main.no_critical_edge_39
        jmp _if_58_then
_if_61_else:
        ; branch chr.1{r0} notequals -8112: if_63_else, if_63_then
        cmp ax, -8112
        jne _if_63_else
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], chr.1{r0}
        mov [r12], ax
        jmp _if_63_then
_if_61_then:
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch curr_r.2{r1} lteq 0: main.no_critical_edge_38, if_62_then
        cmp cl, 0
        jbe _main.no_critical_edge_38
        jmp _if_62_then
_main.no_critical_edge_39:
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        jmp _if_58_end
_if_58_then:
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; const needsInitialize.5{r6}, 0
        mov bl, 0
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; call initField@u8@u8[curr_r.2{r1}, curr_c.2{r2}]
        call _initField@u8@u8
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp _if_58_end
_if_63_else:
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8117: if_65_else, if_65_then
        cmp ax, -8117
        jne _if_65_else
        jmp _if_65_then
_if_63_then:
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch curr_r.2{r1} gteq 19: main.no_critical_edge_37, if_64_then
        cmp cl, 19
        jae _main.no_critical_edge_37
        jmp _if_64_then
_main.no_critical_edge_38:
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r.2{r1}
        mov [r12], cl
        jmp _while_53
_if_62_then:
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move curr_r.5{r0}, curr_r.2{r1}
        mov al, cl
        ; sub curr_r.5{r0}, 1
        sub al, 1
        ; move curr_r.2{r1}, curr_r.5{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r.2{r1}
        mov [r12], cl
        jmp _while_53
_if_58_end:
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c.2{r2}
        mov [r12], dl
        ; call index.1{r0} = rowColumnToCell@u8@u8[curr_r.2{r1}, curr_c.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.16.1{r3}(i64), index.1{r0}(i16)
        movsx r8, ax
        ; addrof t.15.1{r4}, field
        lea r9, [var_1]
        ; add t.15.2{r4}, t.16.1{r3}
        add r9, r8
        ; load cell.1{r3}, [t.15.2{r4}]
        mov r8b, [r9]
        ; 324:4 if cell & 2 == 0
        ; move t.17.1{r4}, cell.1{r3}
        mov r9b, r8b
        ; and t.17.1{r4}, 2
        and r9b, 2
        ; branch t.17.1{r4} notequals 0: main.no_critical_edge_40, if_59_then
        cmp r9b, 0
        jne _main.no_critical_edge_40
        jmp _if_59_then
_if_65_else:
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8115: if_67_else, if_67_then
        cmp ax, -8115
        jne _if_67_else
        jmp _if_67_then
_if_65_then:
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; branch curr_c.2{r2} lteq 0: main.no_critical_edge_36, if_66_then
        cmp dl, 0
        jbe _main.no_critical_edge_36
        jmp _if_66_then
_main.no_critical_edge_37:
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        jmp _while_53
_if_64_then:
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move curr_r.6{r0}, curr_r.2{r1}
        mov al, cl
        ; add curr_r.6{r0}, 1
        add al, 1
        ; move curr_r.2{r1}, curr_r.6{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r.2{r1}
        mov [r12], cl
        jmp _while_53
_main.no_critical_edge_40:
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp _if_59_end
_if_59_then:
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; move t.18.1{r4}, cell.1{r3}
        mov r9b, r8b
        ; or t.18.1{r4}, 2
        or r9b, 2
        ; cast t.20.1{r0}(i64), index.1{r0}(i16)
        movsx rax, ax
        ; addrof t.19.1{r5}, field
        lea r10, [var_1]
        ; add t.19.2{r5}, t.20.1{r0}
        add r10, rax
        ; store [t.19.2{r5}], t.18.1{r4}
        mov [r10], r9b
        jmp _if_59_end
_if_67_else:
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch chr.1{r0} notequals 32: main.no_critical_edge_32, if_69_then
        cmp ax, 32
        jne _main.no_critical_edge_32
        jmp _if_69_then
_if_67_then:
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch curr_c.2{r2} gteq 39: main.no_critical_edge_35, if_68_then
        cmp dl, 39
        jae _main.no_critical_edge_35
        jmp _if_68_then
_main.no_critical_edge_36:
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        jmp _while_53
_if_66_then:
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; move curr_c.6{r0}, curr_c.2{r2}
        mov al, dl
        ; sub curr_c.6{r0}, 1
        sub al, 1
        ; move curr_c.2{r2}, curr_c.6{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        jmp _while_53
_if_59_end:
        ; 327:4 if cell & 1 != 0
        ; move t.21.1{r0}, cell.1{r3}
        mov al, r8b
        ; and t.21.1{r0}, 1
        and al, 1
        ; branch t.21.1{r0} equals 0: if_60_end, if_60_then
        cmp al, 0
        je _if_60_end
        jmp _if_60_then
_main.no_critical_edge_32:
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r.2{r1}
        mov [r12], cl
        jmp _while_53
_if_69_then:
        ; branch needsInitialize.2{r6} notequals 0: main.no_critical_edge_33, if_70_then
        cmp bl, 0
        jne _main.no_critical_edge_33
        jmp _if_70_then
_main.no_critical_edge_35:
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r.2{r1}
        mov [r12], cl
        jmp _while_53
_if_68_then:
        ; move curr_c.7{r0}, curr_c.2{r2}
        mov al, dl
        ; add curr_c.7{r0}, 1
        add al, 1
        ; move curr_c.2{r2}, curr_c.7{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r.2{r1}
        mov [r12], cl
        jmp _while_53
_if_60_end:
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c.2{r2}
        mov [r12], dl
        ; call maybeRevealAround@u8@u8[curr_r.2{r1}, curr_c.2{r2}]
        call _maybeRevealAround@u8@u8
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        jmp _while_53
_main.no_critical_edge_33:
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r.2{r1}
        mov [r12], cl
        jmp _while_53
_if_70_then:
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c.2{r2}
        mov [r12], dl
        ; call index.2{r0} = rowColumnToCell@u8@u8[curr_r.2{r1}, curr_c.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.24.1{r4}(i64), index.2{r0}(i16)
        movsx r9, ax
        ; addrof t.23.1{r5}, field
        lea r10, [var_1]
        ; add t.23.2{r5}, t.24.1{r4}
        add r10, r9
        ; load cell.3{r4}, [t.23.2{r5}]
        mov r9b, [r10]
        ; 363:5 if cell & 2 == 0
        ; move t.25.1{r5}, cell.3{r4}
        mov r10b, r9b
        ; and t.25.1{r5}, 2
        and r10b, 2
        ; branch t.25.1{r5} equals 0: if_71_then
        cmp r10b, 0
        je _if_71_then
        ; load curr_c.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        jmp _while_53
_if_71_then:
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; load curr_c.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move cell.4{r1}, cell.3{r4}
        mov cl, r9b
        ; xor cell.4{r1}, 4
        xor cl, 4
        ; cast t.27.1{r0}(i64), index.2{r0}(i16)
        movsx rax, ax
        ; addrof t.26.1{r4}, field
        lea r9, [var_1]
        ; add t.26.2{r4}, t.27.1{r0}
        add r9, rax
        ; store [t.26.2{r4}], cell.4{r1}
        mov [r9], cl
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; call printCellAt@u8@u8@u8[cell.4{r1}, curr_r.2{r2}, curr_c.2{r3}]
        call _printCellAt@u8@u8@u8
        ; load curr_c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; load curr_r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
_while_53:
        ; branch needsInitialize.2{r6} notequals 0: if_54_end, if_54_then
        cmp bl, 0
        jne _if_54_end
        jmp _if_54_then
_if_55_then:
        ; const t.12.1{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString@@u8[t.12.1{r1}]
        call _printString@@u8
        jmp _main_ret
_if_60_then:
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c.2
        lea r12, [rsp+48]
        ; call printCellAt@u8@u8[curr_r.2{r1}, curr_c.2{r2}]
        call _printCellAt@u8@u8
        ; const t.22.1{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString@@u8[t.22.1{r1}]
        call _printString@@u8
_main_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
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
_getChar:
        push   rbx
        sub    rsp, 20h
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
        add    rsp, 20h
        pop    rbx
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
        string_0 db ' |', 0x00
        string_1 db 'Left:', 0x00
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
