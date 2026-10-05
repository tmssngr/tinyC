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

        ; i64 strlen@@u8
        ;   rsp+16: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length.1{r2}, 0
        mov rdx, 0
        ; 69:2 for *str != 0
        ; move length.2{r0}, length.1{r2}
        mov rax, rdx
        jmp _for_1
_for_1_body:
        ; move length.3{r2}, length.2{r0}
        mov rdx, rax
        ; add length.3{r2}, 1
        add rdx, 1
        ; add str.2{r1}, 1
        add rcx, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rdx
_for_1:
        ; load t.2.1{r2}, [str.1{r1}]
        mov dl, [rcx]
        ; branch t.2.1{r2} notequals 0: for_1_body
        cmp dl, 0
        jne _for_1_body
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
        ; 26:19 return r * 40 + c
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
        ;   rsp+48: arg row
        ;   rsp+56: arg column
_getBombCountAround@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; call index.1{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; 31:22 return [...] & 15
        ; cast t.6.1{r1}(i64), index.1{r0}(i16)
        movsx rcx, ax
        ; addrof t.5.1{r2}, field
        lea rdx, [var_1]
        ; add t.5.2{r2}, t.6.1{r1}
        add rdx, rcx
        ; load t.4.1{r1}, [t.5.2{r2}]
        mov cl, [rdx]
        ; move t.3.1{r0}, t.4.1{r1}
        mov al, cl
        ; and t.3.1{r0}, 15
        and al, 15
        add rsp, 32
        add rsp, 8
        ret

        ; i16 columnToX@u8
        ;   rsp+16: arg column
_columnToX@u8:
        sub rsp, 8
        ; cast c.1{r1}(i16), column{r1}(u8)
        movzx cx, cl
        ; 36:2 if false
        ; const t.2.1{r2}, 0
        mov dl, 0
        ; branch t.2.1{r2} notequals 0: if_2_then
        cmp dl, 0
        jne _if_2_then
        ; 40:17 return c + 1 << 1
        ; add t.4.1{r1}, 1
        add cx, 1
        ; move t.3.1{r0}, t.4.1{r1}
        mov ax, cx
        ; shiftleft t.3.1{r0}, 1
        sal ax, 1
        jmp _columnToX@u8_ret
_if_2_then:
        ; 37:10 return c
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
        ; 56:2 if cell & 32 != 0
        ; move t.5.1{r7}, cell{r1}
        mov r12b, cl
        ; and t.5.1{r7}, 32
        and r12b, 32
        ; branch t.5.1{r7} notequals 0: if_3_then
        cmp r12b, 0
        jne _if_3_then
        ; 70:7 if cell & 64 != 0
        ; move t.7.1{r7}, cell{r1}
        mov r12b, cl
        ; and t.7.1{r7}, 64
        and r12b, 64
        ; branch t.7.1{r7} equals 0: if_3_end, if_6_then
        cmp r12b, 0
        je _if_3_end
        jmp _if_6_then
_if_3_then:
        ; 57:3 if cell & 128 != 0
        ; move t.6.1{r6}, cell{r1}
        mov bl, cl
        ; and t.6.1{r6}, 128
        and bl, 128
        ; branch t.6.1{r6} equals 0: if_4_else, if_4_then
        cmp bl, 0
        je _if_4_else
        jmp _if_4_then
_if_6_then:
        ; const chr.3{r6}, 35
        mov bl, 35
        jmp _if_3_end
_if_4_else:
        ; move row{r1}, row{r2}
        mov cl, dl
        ; move column{r2}, column{r3}
        mov dl, r8b
        ; call count.1{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; 62:4 if count > 0
        ; branch count.1{r0} lteq 0: if_5_else, if_5_then
        cmp al, 0
        jbe _if_5_else
        jmp _if_5_then
_if_4_then:
        ; const chr.4{r6}, 42
        mov bl, 42
        jmp _if_3_end
_if_5_else:
        ; const chr.5{r6}, 32
        mov bl, 32
        jmp _if_3_end
_if_5_then:
        ; move chr.6{r6}, count.1{r0}
        mov bl, al
        ; add chr.6{r6}, 48
        add bl, 48
_if_3_end:
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
        ; 89:2 for row < 20
        jmp _for_7
_for_7_body:
        ; cast t.3.1{r1}(i16), row.2{r6}(u8)
        movzx cx, bl
        ; const arg.1.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[t.3.1{r1}, arg.1.1{r2}]
        call _setCursor@i16@i16
        ; 91:3 if true
        ; const t.4.1{r0}, 1
        mov al, 1
        ; branch t.4.1{r0} equals 0: if_8_end
        cmp al, 0
        je _if_8_end
        ; const arg.2.0{r1}, 124
        mov cl, 124
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
_if_8_end:
        ; const column.1{r0}, 0
        mov al, 0
        ; 94:3 for column < 40
        ; move column.2{r2}, column.1{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], column.2{r2}
        mov [r12], dl
        jmp _for_9
_for_9_body:
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], column.2{r2}
        mov [r12], dl
        ; 95:4 if true
        ; const t.5.1{r0}, 1
        mov al, 1
        ; branch t.5.1{r0} equals 0: if_10_end
        cmp al, 0
        je _if_10_end
        ; const arg.3.0{r1}, 32
        mov cl, 32
        ; call printChar@u8[arg.3.0{r1}]
        call _printChar@u8
_if_10_end:
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
_for_9:
        ; branch column.2{r2} lt 40: for_9_body
        cmp dl, 40
        jb _for_9_body
        ; 101:3 if true
        ; const t.9.1{r0}, 1
        mov al, 1
        ; branch t.9.1{r0} equals 0: for_7_continue
        cmp al, 0
        je _for_7_continue
        ; const t.10.1{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.10.1{r1}]
        call _printString@@u8
_for_7_continue:
        ; move row.7{r0}, row.2{r6}
        mov al, bl
        ; add row.7{r0}, 1
        add al, 1
        ; move row.2{r6}, row.7{r0}
        mov bl, al
_for_7:
        ; branch row.2{r6} lt 20: for_7_body
        cmp bl, 20
        jb _for_7_body
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
        ; 108:2 if false
        ; const t.6.1{r0}, 0
        mov al, 0
        ; branch t.6.1{r0} notequals 0: if_12_then
        cmp al, 0
        jne _if_12_then
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
        ; 119:2 if show
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; load show{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; branch show{r3} equals 0: showCursor@u8@u8@bool.no_critical_edge_10, if_14_then
        cmp r8b, 0
        je _showCursor@u8@u8@bool.no_critical_edge_10
        jmp _if_14_then
_if_12_then:
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; load show{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; branch show{r3} equals 0: showCursor@u8@u8@bool_ret, if_13_then
        cmp r8b, 0
        je _showCursor@u8@u8@bool_ret
        jmp _if_13_then
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
        jmp _if_14_end
_if_14_then:
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
        jmp _if_14_end
_if_13_then:
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
_if_14_end:
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
        ; 125:2 if show
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; load show{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; branch show{r3} notequals 0: if_15_then
        cmp r8b, 0
        jne _if_15_then
        ; addrof memVarAddr{r7}, chr.2
        lea r12, [rsp+50]
        ; load chr.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp _if_15_end
_if_15_then:
        ; const chr.5{r6}, 93
        mov bl, 93
        ; move chr.4{r1}, chr.5{r6}
        mov cl, bl
_if_15_end:
        ; call printChar@u8[chr.4{r1}]
        call _printChar@u8
_showCursor@u8@u8@bool_ret:
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
        ; branch a{r1} lt 0: if_16_then
        cmp cx, 0
        jl _if_16_then
        ; 183:9 return a
        ; move a{r0}, a{r1}
        mov ax, cx
        jmp _abs@i16_ret
_if_16_then:
        ; 181:10 return -a
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
        ; 188:2 for i > 0
        jmp _for_17
_for_17_body:
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
_for_17:
        ; branch i.2{r1} gt 0: for_17_body
        cmp cx, 0
        jg _for_17_body
        add rsp, 8
        ret

        ; i16 initField@u8@u8
        ;   rsp+80: arg curr_r
        ;   rsp+88: arg curr_c
        ;   rsp+48: var c.1
        ;   rsp+50: var bombCount.2
        ;   rsp+52: var bombs.2
        ;   rsp+54: var row.1
        ;   rsp+56: var column.1
        ;   rsp+58: var bombCount.4
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
        ; const bombCount.1{r0}, 0
        mov ax, 0
        ; const bombs.1{r1}, 72
        mov cx, 72
        ; 197:2 for bombs > 0
        ; addrof memVarAddr{r7}, bombCount.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombCount.2{r0}
        mov [r12], ax
        ; move bombs.2{r0}, bombs.1{r1}
        mov ax, cx
        ; addrof memVarAddr{r7}, bombs.2
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], bombs.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, bombCount.2
        lea r12, [rsp+50]
        ; load bombCount.2{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; addrof memVarAddr{r7}, bombs.2
        lea r12, [rsp+52]
        ; move bombs.2{r2}, bombs.2{r1}
        mov dx, cx
        jmp _for_18
_for_18_body:
        ; addrof memVarAddr{r7}, bombCount.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombCount.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, bombs.2
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], bombs.2{r2}
        mov [r12], dx
        ; call t.8.1{r0} = random16[] -> i16
        call _random16
        ; move row.1{r3}, t.8.1{r0}
        mov r8w, ax
        ; mod row.1{r2}, row.1{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move row.1{r3}, row.1{r2}
        mov r8w, dx
        ; addrof memVarAddr{r7}, row.1
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], row.1{r3}
        mov [r12], r8w
        ; call t.9.1{r0} = random16[] -> i16
        call _random16
        ; move column.1{r3}, t.9.1{r0}
        mov r8w, ax
        ; mod column.1{r2}, column.1{r0}, 40
        movsx rax, ax
        cqo
        mov rcx, 40
        idiv rcx
        ; move column.1{r3}, column.1{r2}
        mov r8w, dx
        ; addrof memVarAddr{r7}, column.1
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], column.1{r3}
        mov [r12], r8w
        ; 200:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=200:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=200:20], location=200:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=201:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=201:20], location=201:18]]) > 1
        ; addrof memVarAddr{r7}, row.1
        lea r12, [rsp+54]
        ; load row.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.11.1{r1}, row.1{r0}
        mov cx, ax
        ; sub t.11.1{r1}, r.1{r6}
        sub cx, bx
        ; call t.10.1{r0} = abs@i16[t.11.1{r1}] -> i16
        call _abs@i16
        ; branch t.10.1{r0} gt 1: if_19_then
        cmp ax, 1
        jg _if_19_then
        ; addrof memVarAddr{r7}, column.1
        lea r12, [rsp+56]
        ; load column.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.13.1{r1}, column.1{r0}
        mov cx, ax
        ; addrof memVarAddr{r7}, c.1
        lea r12, [rsp+48]
        ; load c.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; sub t.13.1{r1}, c.1{r0}
        sub cx, ax
        ; call t.12.1{r0} = abs@i16[t.13.1{r1}] -> i16
        call _abs@i16
        ; branch t.12.1{r0} gt 1: if_19_then
        cmp ax, 1
        jg _if_19_then
        ; addrof memVarAddr{r7}, bombCount.2
        lea r12, [rsp+50]
        ; load bombCount.2{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; addrof memVarAddr{r7}, bombCount.4
        lea r12, [rsp+58]
        ; store [memVarAddr{r7}], bombCount.4{r0}
        mov [r12], ax
        ; move bombCount.4{r1}, bombCount.4{r0}
        mov cx, ax
        jmp _for_18_continue
_if_19_then:
        ; 202:4 if setBomb@u8@u8([ExprCast[typeString=u8, expression=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=202:19], type=u8, location=202:16], ExprCast[typeString=u8, expression=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=202:28], type=u8, location=202:25]])
        ; addrof memVarAddr{r7}, row.1
        lea r12, [rsp+54]
        ; load row.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; cast t.15.1{r1}(u8), row.1{r0}(i16)
        mov cl, al
        ; addrof memVarAddr{r7}, column.1
        lea r12, [rsp+56]
        ; load column.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; cast t.16.1{r2}(u8), column.1{r0}(i16)
        mov dl, al
        ; call t.14.1{r0} = setBomb@u8@u8[t.15.1{r1}, t.16.1{r2}] -> bool
        call _setBomb@u8@u8
        ; branch t.14.1{r0} notequals 0: if_21_then
        cmp al, 0
        jne _if_21_then
        ; addrof memVarAddr{r7}, bombCount.2
        lea r12, [rsp+50]
        ; load bombCount.2{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move bombCount.4{r1}, bombCount.2{r0}
        mov cx, ax
        jmp _for_18_continue
_if_21_then:
        ; addrof memVarAddr{r7}, bombCount.2
        lea r12, [rsp+50]
        ; load bombCount.2{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move bombCount.5{r1}, bombCount.2{r0}
        mov cx, ax
        ; add bombCount.5{r1}, 1
        add cx, 1
_for_18_continue:
        ; addrof memVarAddr{r7}, bombs.2
        lea r12, [rsp+52]
        ; load bombs.2{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; sub bombs.5{r2}, 1
        sub dx, 1
        ; move bombCount.2{r0}, bombCount.4{r1}
        mov ax, cx
_for_18:
        ; branch bombs.2{r2} gt 0: for_18_body
        cmp dx, 0
        jg _for_18_body
        ; 207:9 return bombCount
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; bool setBomb@u8@u8
        ;   rsp+64: arg row
        ;   rsp+72: arg column
        ;   rsp+48: var rowTo.2
        ;   rsp+49: var colTo.2
        ;   rsp+50: var r.2
_setBomb@u8@u8:
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
        ; call index.1{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; move index.1{r1}, index.1{r0}
        mov cx, ax
        ; 212:2 if [...] == 128
        ; cast t.14.1{r2}(i64), index.1{r1}(i16)
        movsx rdx, cx
        ; addrof t.13.1{r3}, field
        lea r8, [var_1]
        ; add t.13.2{r3}, t.14.1{r2}
        add r8, rdx
        ; load t.12.1{r2}, [t.13.2{r3}]
        mov dl, [r8]
        ; branch t.12.1{r2} equals 128: if_22_then
        cmp dl, 128
        je _if_22_then
        ; const t.15.1{r2}, 128
        mov dl, 128
        ; cast t.17.1{r3}(i64), index.1{r1}(i16)
        movsx r8, cx
        ; addrof t.16.1{r4}, field
        lea r9, [var_1]
        ; add t.16.2{r4}, t.17.1{r3}
        add r9, r8
        ; store [t.16.2{r4}], t.15.1{r2}
        mov [r9], dl
        ; move rowFrom.1{r2}, row{r6}
        mov dl, bl
        ; 218:2 if rowFrom > 0
        ; branch rowFrom.1{r2} lteq 0: if_23_end, if_23_then
        cmp dl, 0
        jbe _if_23_end
        jmp _if_23_then
_if_22_then:
        ; 213:10 return false
        ; const {r0}, 0
        mov al, 0
        jmp _setBomb@u8@u8_ret
_if_23_then:
        ; move rowFrom.3{r2}, row{r6}
        mov dl, bl
        ; sub rowFrom.3{r2}, 1
        sub dl, 1
        ; sub index.3{r1}, 40
        sub cx, 40
_if_23_end:
        ; move rowTo.1{r3}, row{r6}
        mov r8b, bl
        ; add rowTo.1{r3}, 1
        add r8b, 1
        ; 223:2 if rowTo >= 20
        ; branch rowTo.1{r3} lt 20: if_24_end
        cmp r8b, 20
        jb _if_24_end
        ; sub rowTo.3{r3}, 1
        sub r8b, 1
_if_24_end:
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; move colFrom.1{r5}, column{r4}
        mov r10b, r9b
        ; 228:2 if colFrom > 0
        ; branch colFrom.1{r5} lteq 0: if_25_end
        cmp r10b, 0
        jbe _if_25_end
        ; sub colFrom.3{r5}, 1
        sub r10b, 1
        ; sub index.6{r1}, 1
        sub cx, 1
_if_25_end:
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], rowTo.2{r3}
        mov [r12], r8b
        ; move colTo.1{r3}, column{r4}
        mov r8b, r9b
        ; add colTo.1{r3}, 1
        add r8b, 1
        ; 233:2 if colTo >= 40
        ; branch colTo.1{r3} lt 40: if_26_end
        cmp r8b, 40
        jb _if_26_end
        ; sub colTo.3{r3}, 1
        sub r8b, 1
_if_26_end:
        ; 238:2 for r <= rowTo
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r4}
        mov [r12], r9b
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], row{r6}
        mov [r12], bl
        ; move r.2{r4}, r.2{r2}
        mov r9b, dl
        ; move colTo.2{r2}, colTo.2{r3}
        mov dl, r8b
        ; move colFrom.2{r3}, colFrom.2{r5}
        mov r8b, r10b
        jmp _for_27
_for_27_body:
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], rowTo.2{r5}
        mov [r12], r10b
        ; move colFrom.2{r5}, colFrom.2{r3}
        mov r10b, r8b
        ; move colTo.2{r3}, colTo.2{r2}
        mov r8b, dl
        ; move r.2{r2}, r.2{r4}
        mov dl, r9b
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        ; load row{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], colTo.2{r3}
        mov [r12], r8b
        ; move colFrom.2{r3}, colFrom.2{r5}
        mov r8b, r10b
        ; 239:3 for c <= colTo
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], r.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        jmp _for_28
_for_28_body:
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], colTo.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+50]
        ; load r.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        ; load row{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; branch r.2{r2} notequals row{r6}: if_29_end
        cmp dl, bl
        jne _if_29_end
        ; branch c.2{r5} notequals column{r4}: if_29_end
        cmp r10b, r9b
        jne _if_29_end
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+50]
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        jmp _for_28_continue
_if_29_end:
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r4}
        mov [r12], r9b
        ; cast t.19.1{r4}(i64), index.9{r1}(i16)
        movsx r9, cx
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], row{r6}
        mov [r12], bl
        ; addrof t.18.1{r6}, field
        lea rbx, [var_1]
        ; add t.18.2{r6}, t.19.1{r4}
        add rbx, r9
        ; load cell.1{r4}, [t.18.2{r6}]
        mov r9b, [rbx]
        ; 245:4 if cell & 128 == 0
        ; move t.20.1{r6}, cell.1{r4}
        mov bl, r9b
        ; and t.20.1{r6}, 128
        and bl, 128
        ; branch t.20.1{r6} equals 0: if_31_then
        cmp bl, 0
        je _if_31_then
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], r.2{r2}
        mov [r12], dl
        jmp _for_28_continue
_if_31_then:
        ; and count.2{r4}, 15
        and r9b, 15
        ; add count.3{r4}, 1
        add r9b, 1
        ; cast t.22.1{r6}(i64), index.9{r1}(i16)
        movsx rbx, cx
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], r.2{r2}
        mov [r12], dl
        ; addrof t.21.1{r2}, field
        lea rdx, [var_1]
        ; add t.21.2{r2}, t.22.1{r6}
        add rdx, rbx
        ; store [t.21.2{r2}], count.3{r4}
        mov [rdx], r9b
_for_28_continue:
        ; move c.5{r2}, c.2{r5}
        mov dl, r10b
        ; add c.5{r2}, 1
        add dl, 1
        ; add index.13{r1}, 1
        add cx, 1
        ; move c.2{r5}, c.5{r2}
        mov r10b, dl
_for_28:
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+49]
        ; load colTo.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; branch c.2{r5} lteq colTo.2{r2}: for_28_body
        cmp r10b, dl
        jbe _for_28_body
        ; cast t.26.1{r4}(i16), colTo.2{r2}(u8)
        movzx r9w, dl
        ; sub t.25.1{r1}, t.26.1{r4}
        sub cx, r9w
        ; cast t.27.1{r4}(i16), colFrom.2{r3}(u8)
        movzx r9w, r8b
        ; add t.24.1{r1}, t.27.1{r4}
        add cx, r9w
        ; add t.23.1{r1}, 40
        add cx, 40
        ; sub index.10{r1}, 1
        sub cx, 1
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+50]
        ; load r.2{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; add r.4{r4}, 1
        add r9b, 1
_for_27:
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+48]
        ; load rowTo.2{r5}, [memVarAddr{r7}]
        mov r10b, [r12]
        ; branch r.2{r4} lteq rowTo.2{r5}: for_27_body
        cmp r9b, r10b
        jbe _for_27_body
        ; 253:9 return true
        ; const {r0}, 1
        mov al, 1
_setBomb@u8@u8_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void maybeRevealAround@u8@u8
        ;   rsp+80: arg row
        ;   rsp+88: arg column
        ;   rsp+48: var r.2
        ;   rsp+50: var index.3
        ;   rsp+52: var c.2
        ;   rsp+53: var r.7
        ;   rsp+54: var index.5
        ;   rsp+56: var c.4
        ;   rsp+57: var c.7
        ;   rsp+58: var index.8
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
        ; 258:2 if getBombCountAround@u8@u8([ExprVarAccess[varName=row, index=0, scope=parameter, type=u8, varIsArray=false, location=258:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=u8, varIsArray=false, location=258:30]]) != 0
        ; move row{r1}, row{r6}
        mov cl, bl
        ; load column{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; call t.10.1{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; branch t.10.1{r0} notequals 0: maybeRevealAround@u8@u8_ret
        cmp al, 0
        jne _maybeRevealAround@u8@u8_ret
        ; const changed.1{r6}, 1
        mov bl, 1
        ; 263:2 while changed
        jmp _while_33
_while_33_body:
        ; const changed.3{r6}, 0
        mov bl, 0
        ; const index.1{r0}, 0
        mov ax, 0
        ; const r.1{r3}, 0
        mov r8b, 0
        ; 267:3 for r < 20
        ; move r.2{r1}, r.1{r3}
        mov cl, r8b
        ; move index.2{r3}, index.2{r0}
        mov r8w, ax
        jmp _for_34
_for_34_body:
        ; move index.2{r0}, index.2{r3}
        mov ax, r8w
        ; const c.1{r3}, 0
        mov r8b, 0
        ; 268:4 for c < 40
        ; move c.2{r2}, c.1{r3}
        mov dl, r8b
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r.2{r1}
        mov [r12], cl
        ; move index.3{r3}, index.3{r0}
        mov r8w, ax
        jmp _for_35
_for_35_body:
        ; move index.3{r0}, index.3{r3}
        mov ax, r8w
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; load r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; cast t.12.1{r3}(i64), index.3{r0}(i16)
        movsx r8, ax
        ; addrof memVarAddr{r7}, index.3
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], index.3{r0}
        mov [r12], ax
        ; addrof t.11.1{r0}, field
        lea rax, [var_1]
        ; add t.11.2{r0}, t.12.1{r3}
        add rax, r8
        ; load cell.1{r0}, [t.11.2{r0}]
        mov al, [rax]
        ; 270:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.13.1{r3}, cell.1{r0}
        mov r8b, al
        ; and t.13.1{r3}, 32
        and r8b, 32
        ; branch t.13.1{r3} notequals 0: or_37
        cmp r8b, 0
        jne _or_37
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], c.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        jmp _for_35_continue
_or_37:
        ; and t.14.1{r0}, 128
        and al, 128
        ; branch t.14.1{r0} equals 0: if_36_end
        cmp al, 0
        je _if_36_end
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], c.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r.2{r1}
        mov [r12], cl
        jmp _for_35_continue
_if_36_end:
        ; 273:5 if getBombCountAround@u8@u8([ExprVarAccess[varName=r, index=4, scope=function, type=u8, varIsArray=false, location=273:28], ExprVarAccess[varName=c, index=5, scope=function, type=u8, varIsArray=false, location=273:31]]) != 0
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], c.2{r2}
        mov [r12], dl
        ; call t.15.1{r0} = getBombCountAround@u8@u8[r.2{r1}, c.2{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; branch t.15.1{r0} notequals 0: for_35_continue
        cmp al, 0
        jne _for_35_continue
        ; 277:5 if revealNeighbors@u8@u8([ExprVarAccess[varName=r, index=4, scope=function, type=u8, varIsArray=false, location=277:24], ExprVarAccess[varName=c, index=5, scope=function, type=u8, varIsArray=false, location=277:27]])
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; load r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+52]
        ; load c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; call t.16.1{r0} = revealNeighbors@u8@u8[r.2{r1}, c.2{r2}] -> bool
        call _revealNeighbors@u8@u8
        ; branch t.16.1{r0} equals 0: for_35_continue
        cmp al, 0
        je _for_35_continue
        ; const changed.9{r6}, 1
        mov bl, 1
_for_35_continue:
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+52]
        ; load c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move c.6{r0}, c.2{r2}
        mov al, dl
        ; add c.6{r0}, 1
        add al, 1
        ; addrof memVarAddr{r7}, index.3
        lea r12, [rsp+50]
        ; load index.3{r3}, [memVarAddr{r7}]
        mov r8w, [r12]
        ; add index.7{r3}, 1
        add r8w, 1
        ; move c.2{r2}, c.6{r0}
        mov dl, al
_for_35:
        ; branch c.2{r2} lt 40: for_35_body
        cmp dl, 40
        jb _for_35_body
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; load r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; move r.6{r0}, r.2{r1}
        mov al, cl
        ; add r.6{r0}, 1
        add al, 1
        ; move r.2{r1}, r.6{r0}
        mov cl, al
_for_34:
        ; branch r.2{r1} lt 20: for_34_body
        cmp cl, 20
        jb _for_34_body
        ; branch changed.4{r6} equals 0: maybeRevealAround@u8@u8_ret
        cmp bl, 0
        je _maybeRevealAround@u8@u8_ret
        ; const r.4{r0}, 20
        mov al, 20
        ; 288:3 while true
        ; move r.5{r1}, r.5{r0}
        mov cl, al
        ; move index.4{r0}, index.4{r3}
        mov ax, r8w
        jmp _while_41
_if_42_end:
        ; move index.4{r3}, index.4{r0}
        mov r8w, ax
        ; move r.5{r0}, r.5{r1}
        mov al, cl
        ; sub r.7{r1}, 1
        sub cl, 1
        ; const c.3{r0}, 40
        mov al, 40
        ; 295:4 while true
        ; addrof memVarAddr{r7}, r.7
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], r.7{r1}
        mov [r12], cl
        ; move c.4{r1}, c.4{r0}
        mov cl, al
        ; move index.5{r0}, index.5{r3}
        mov ax, r8w
        jmp _while_43
_if_44_end:
        ; move index.5{r3}, index.5{r0}
        mov r8w, ax
        ; move c.4{r0}, c.4{r1}
        mov al, cl
        ; addrof memVarAddr{r7}, r.7
        lea r12, [rsp+53]
        ; load r.7{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; move c.7{r2}, c.4{r0}
        mov dl, al
        ; sub c.7{r2}, 1
        sub dl, 1
        ; move index.8{r0}, index.5{r3}
        mov ax, r8w
        ; sub index.8{r0}, 1
        sub ax, 1
        ; cast t.18.1{r3}(i64), index.8{r0}(i16)
        movsx r8, ax
        ; addrof t.17.1{r4}, field
        lea r9, [var_1]
        ; add t.17.2{r4}, t.18.1{r3}
        add r9, r8
        ; load cell.2{r3}, [t.17.2{r4}]
        mov r8b, [r9]
        ; 302:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.19.1{r4}, cell.2{r3}
        mov r9b, r8b
        ; and t.19.1{r4}, 32
        and r9b, 32
        ; branch t.19.1{r4} notequals 0: or_46
        cmp r9b, 0
        jne _or_46
        ; move index.5{r3}, index.8{r0}
        mov r8w, ax
        ; move c.4{r0}, c.7{r2}
        mov al, dl
        ; move c.4{r1}, c.4{r0}
        mov cl, al
        ; move index.5{r0}, index.5{r3}
        mov ax, r8w
        jmp _while_43
_or_46:
        ; and t.20.1{r3}, 128
        and r8b, 128
        ; branch t.20.1{r3} equals 0: if_45_end
        cmp r8b, 0
        je _if_45_end
        ; move index.5{r3}, index.8{r0}
        mov r8w, ax
        ; addrof memVarAddr{r7}, index.5
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], index.5{r3}
        mov [r12], r8w
        ; move c.4{r0}, c.7{r2}
        mov al, dl
        ; addrof memVarAddr{r7}, c.4
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], c.4{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, r.7
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], r.7{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, c.4
        lea r12, [rsp+56]
        ; move c.4{r1}, c.4{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, index.5
        lea r12, [rsp+54]
        ; move index.5{r0}, index.5{r3}
        mov ax, r8w
        jmp _while_43
_if_45_end:
        ; addrof memVarAddr{r7}, index.8
        lea r12, [rsp+58]
        ; store [memVarAddr{r7}], index.8{r0}
        mov [r12], ax
        ; 305:5 if getBombCountAround@u8@u8([ExprVarAccess[varName=r, index=7, scope=function, type=u8, varIsArray=false, location=305:28], ExprVarAccess[varName=c, index=8, scope=function, type=u8, varIsArray=false, location=305:31]]) != 0
        ; addrof memVarAddr{r7}, r.7
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], r.7{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, c.7
        lea r12, [rsp+57]
        ; store [memVarAddr{r7}], c.7{r2}
        mov [r12], dl
        ; call t.21.1{r0} = getBombCountAround@u8@u8[r.7{r1}, c.7{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; branch t.21.1{r0} equals 0: if_47_end
        cmp al, 0
        je _if_47_end
        ; addrof memVarAddr{r7}, index.8
        lea r12, [rsp+58]
        ; load index.8{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; addrof memVarAddr{r7}, index.5
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], index.5{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, c.7
        lea r12, [rsp+57]
        ; load c.7{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move c.4{r0}, c.7{r2}
        mov al, dl
        ; addrof memVarAddr{r7}, c.4
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], c.4{r0}
        mov [r12], al
        ; move c.4{r1}, c.4{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, index.5
        lea r12, [rsp+54]
        ; load index.5{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        jmp _while_43
_if_47_end:
        ; addrof memVarAddr{r7}, c.7
        lea r12, [rsp+57]
        ; load c.7{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; 309:5 if revealNeighbors@u8@u8([ExprVarAccess[varName=r, index=7, scope=function, type=u8, varIsArray=false, location=309:24], ExprVarAccess[varName=c, index=8, scope=function, type=u8, varIsArray=false, location=309:27]])
        ; addrof memVarAddr{r7}, r.7
        lea r12, [rsp+53]
        ; load r.7{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, c.7
        lea r12, [rsp+57]
        ; call t.22.1{r0} = revealNeighbors@u8@u8[r.7{r1}, c.7{r2}] -> bool
        call _revealNeighbors@u8@u8
        ; branch t.22.1{r0} notequals 0: if_48_then
        cmp al, 0
        jne _if_48_then
        ; addrof memVarAddr{r7}, index.8
        lea r12, [rsp+58]
        ; load index.8{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; addrof memVarAddr{r7}, c.7
        lea r12, [rsp+57]
        ; load c.7{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move c.4{r1}, c.7{r2}
        mov cl, dl
        jmp _while_43
_if_48_then:
        ; addrof memVarAddr{r7}, c.7
        lea r12, [rsp+57]
        ; load c.7{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, index.8
        lea r12, [rsp+58]
        ; load index.8{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; const changed.10{r1}, 1
        mov cl, 1
        ; move changed.7{r6}, changed.10{r1}
        mov bl, cl
        ; move c.4{r1}, c.7{r2}
        mov cl, dl
_while_43:
        ; branch c.4{r1} notequals 0: if_44_end
        cmp cl, 0
        jne _if_44_end
        ; addrof memVarAddr{r7}, r.7
        lea r12, [rsp+53]
        ; load r.7{r1}, [memVarAddr{r7}]
        mov cl, [r12]
_while_41:
        ; branch r.5{r1} notequals 0: if_42_end, while_33
        cmp cl, 0
        jne _if_42_end
_while_33:
        ; branch changed.2{r6} notequals 0: while_33_body, maybeRevealAround@u8@u8_ret
        cmp bl, 0
        jne _while_33_body
_maybeRevealAround@u8@u8_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; bool revealNeighbors@u8@u8
        ;   rsp+64: arg row
        ;   rsp+72: arg column
        ;   rsp+48: var rowTo.2
        ;   rsp+49: var colFrom.2
        ;   rsp+50: var colTo.2
        ;   rsp+52: var index.3
        ;   rsp+54: var c.2
        ;   rsp+55: var changed.4
_revealNeighbors@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move rowFrom.1{r6}, row{r1}
        mov bl, cl
        ; 319:2 if rowFrom > 0
        ; branch rowFrom.1{r6} lteq 0: if_49_end
        cmp bl, 0
        jbe _if_49_end
        ; sub rowFrom.3{r6}, 1
        sub bl, 1
_if_49_end:
        ; move rowTo.1{r0}, row{r1}
        mov al, cl
        ; add rowTo.1{r0}, 1
        add al, 1
        ; 323:2 if rowTo >= 20
        ; branch rowTo.1{r0} gteq 20: if_50_then
        cmp al, 20
        jae _if_50_then
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], rowTo.2{r0}
        mov [r12], al
        jmp _if_50_end
_if_50_then:
        ; sub rowTo.3{r0}, 1
        sub al, 1
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], rowTo.2{r0}
        mov [r12], al
_if_50_end:
        ; move colFrom.1{r0}, column{r2}
        mov al, dl
        ; 328:2 if colFrom > 0
        ; branch colFrom.1{r0} lteq 0: if_51_end
        cmp al, 0
        jbe _if_51_end
        ; sub colFrom.3{r0}, 1
        sub al, 1
_if_51_end:
        ; move colTo.1{r3}, column{r2}
        mov r8b, dl
        ; add colTo.1{r3}, 1
        add r8b, 1
        ; 332:2 if colTo >= 40
        ; branch colTo.1{r3} gteq 40: if_52_then
        cmp r8b, 40
        jae _if_52_then
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], colTo.2{r3}
        mov [r12], r8b
        jmp _if_52_end
_if_52_then:
        ; sub colTo.3{r3}, 1
        sub r8b, 1
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], colTo.2{r3}
        mov [r12], r8b
_if_52_end:
        ; move rowFrom.2{r1}, rowFrom.2{r6}
        mov cl, bl
        ; move colFrom.2{r2}, colFrom.2{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], colFrom.2{r0}
        mov [r12], al
        ; call index.1{r0} = rowColumnToCell@u8@u8[rowFrom.2{r1}, colFrom.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; const changed.1{r4}, 0
        mov r9b, 0
        ; 337:2 for r <= rowTo
        ; load colFrom.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+50]
        ; load colTo.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move changed.2{r1}, changed.2{r4}
        mov cl, r9b
        ; move index.2{r4}, index.2{r0}
        mov r9w, ax
        ; move changed.2{r0}, changed.2{r1}
        mov al, cl
        jmp _for_53
_for_53_body:
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], colFrom.2{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], colTo.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], rowTo.2{r1}
        mov [r12], cl
        ; move changed.2{r1}, changed.2{r0}
        mov cl, al
        ; move index.2{r0}, index.2{r4}
        mov ax, r9w
        ; move changed.2{r4}, changed.2{r1}
        mov r9b, cl
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+49]
        ; move colFrom.2{r2}, colFrom.2{r3}
        mov dl, r8b
        ; move c.1{r5}, colFrom.2{r2}
        mov r10b, dl
        ; 338:3 for c <= colTo
        ; move index.3{r4}, index.3{r0}
        mov r9w, ax
        jmp _for_54
_for_54_body:
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], colTo.2{r2}
        mov [r12], dl
        ; move index.3{r0}, index.3{r4}
        mov ax, r9w
        ; move changed.3{r4}, changed.3{r1}
        mov r9b, cl
        ; cast t.12.1{r5}(i64), index.3{r0}(i16)
        movsx r10, ax
        ; addrof t.11.1{r2}, field
        lea rdx, [var_1]
        ; add t.11.2{r2}, t.12.1{r5}
        add rdx, r10
        ; load cell.1{r5}, [t.11.2{r2}]
        mov r10b, [rdx]
        ; 340:4 if cell & 32 != 0
        ; move t.13.1{r2}, cell.1{r5}
        mov dl, r10b
        ; and t.13.1{r2}, 32
        and dl, 32
        ; branch t.13.1{r2} equals 0: if_55_end
        cmp dl, 0
        je _if_55_end
        ; addrof memVarAddr{r7}, changed.4
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], changed.4{r4}
        mov [r12], r9b
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], c.2{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, index.3
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], index.3{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, changed.4
        lea r12, [rsp+55]
        jmp _for_54_continue
_if_55_end:
        ; move cell.2{r1}, cell.1{r5}
        mov cl, r10b
        ; or cell.2{r1}, 32
        or cl, 32
        ; cast t.15.1{r4}(i64), index.3{r0}(i16)
        movsx r9, ax
        ; addrof memVarAddr{r7}, index.3
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], index.3{r0}
        mov [r12], ax
        ; addrof t.14.1{r0}, field
        lea rax, [var_1]
        ; add t.14.2{r0}, t.15.1{r4}
        add rax, r9
        ; store [t.14.2{r0}], cell.2{r1}
        mov [rax], cl
        ; move r.2{r2}, r.2{r6}
        mov dl, bl
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], c.2{r3}
        mov [r12], r8b
        ; call printCellAt@u8@u8@u8[cell.2{r1}, r.2{r2}, c.2{r3}]
        call _printCellAt@u8@u8@u8
        ; const changed.5{r1}, 1
        mov cl, 1
_for_54_continue:
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+54]
        ; load c.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; move c.4{r2}, c.2{r3}
        mov dl, r8b
        ; add c.4{r2}, 1
        add dl, 1
        ; addrof memVarAddr{r7}, index.3
        lea r12, [rsp+52]
        ; load index.3{r4}, [memVarAddr{r7}]
        mov r9w, [r12]
        ; move index.6{r3}, index.3{r4}
        mov r8w, r9w
        ; add index.6{r3}, 1
        add r8w, 1
        ; move index.3{r4}, index.6{r3}
        mov r9w, r8w
        ; move c.2{r3}, c.4{r2}
        mov r8b, dl
_for_54:
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+50]
        ; load colTo.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; branch c.2{r3} lteq colTo.2{r2}: for_54_body
        cmp r8b, dl
        jbe _for_54_body
        ; cast t.19.1{r3}(i16), colTo.2{r2}(u8)
        movzx r8w, dl
        ; sub t.18.1{r4}, t.19.1{r3}
        sub r9w, r8w
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+49]
        ; load colFrom.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; cast t.20.1{r5}(i16), colFrom.2{r3}(u8)
        movzx r10w, r8b
        ; add t.17.1{r4}, t.20.1{r5}
        add r9w, r10w
        ; add t.16.1{r4}, 40
        add r9w, 40
        ; sub index.4{r4}, 1
        sub r9w, 1
        ; move r.4{r5}, r.2{r6}
        mov r10b, bl
        ; add r.4{r5}, 1
        add r10b, 1
        ; move changed.2{r0}, changed.3{r1}
        mov al, cl
        ; move r.2{r6}, r.4{r5}
        mov bl, r10b
_for_53:
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+48]
        ; load rowTo.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch r.2{r6} lteq rowTo.2{r1}: for_53_body
        cmp bl, cl
        jbe _for_53_body
        ; 351:9 return changed
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void main
        ;   rsp+48: var row.2
        ;   rsp+50: var bombsLeft.2
        ;   rsp+52: var chr.1
        ;   rsp+54: var bombsLeft.3
        ;   rsp+56: var bombsLeft.6
_main:
        sub rsp, 24
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
        ; const col.1{r6}, 20
        mov bl, 20
        ; const row.1{r0}, 10
        mov al, 10
        ; const bombsLeft.1{r4}, -1
        mov r9w, -1
        ; 363:2 while true
        ; move row.2{r1}, row.1{r0}
        mov cl, al
        ; move bombsLeft.2{r0}, bombsLeft.1{r4}
        mov ax, r9w
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        jmp _while_56
_if_57_end:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; const t.11.1{r3}, 1
        mov r8b, 1
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call showCursor@u8@u8@bool[row.2{r1}, col.2{r2}, t.11.1{r3}]
        call _showCursor@u8@u8@bool
        ; call chr.1{r0} = getChar[] -> i16
        call _getChar
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], chr.1{r0}
        mov [r12], ax
        ; const t.12.1{r3}, 0
        mov r8b, 0
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call showCursor@u8@u8@bool[row.2{r1}, col.2{r2}, t.12.1{r3}]
        call _showCursor@u8@u8@bool
        ; 372:3 if chr == 27
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+52]
        ; load chr.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; branch chr.1{r0} equals 27: main_ret
        cmp ax, 27
        je _main_ret
        ; branch chr.1{r0} equals 13: if_59_then
        cmp ax, 13
        je _if_59_then
        ; branch chr.1{r0} notequals -8120: if_63_else, if_63_then
        cmp ax, -8120
        jne _if_63_else
        jmp _if_63_then
_if_59_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r3}, [memVarAddr{r7}]
        mov r8w, [r12]
        ; branch bombsLeft.2{r3} gteq 0: main.no_critical_edge_42, if_60_then
        cmp r8w, 0
        jge _main.no_critical_edge_42
        jmp _if_60_then
_if_63_else:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r3}, [memVarAddr{r7}]
        mov r8w, [r12]
        ; branch chr.1{r0} notequals -8112: if_65_else, if_65_then
        cmp ax, -8112
        jne _if_65_else
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], chr.1{r0}
        mov [r12], ax
        jmp _if_65_then
_if_63_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r3}, [memVarAddr{r7}]
        mov r8w, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch row.2{r1} lteq 0: main.no_critical_edge_41, if_64_then
        cmp cl, 0
        jbe _main.no_critical_edge_41
        jmp _if_64_then
_main.no_critical_edge_42:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; move bombsLeft.3{r0}, bombsLeft.2{r3}
        mov ax, r8w
        ; addrof memVarAddr{r7}, bombsLeft.3
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], bombsLeft.3{r0}
        mov [r12], ax
        jmp _if_60_end
_if_60_then:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call bombsLeft.4{r0} = initField@u8@u8[row.2{r1}, col.2{r2}] -> i16
        call _initField@u8@u8
        ; addrof memVarAddr{r7}, bombsLeft.3
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], bombsLeft.3{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp _if_60_end
_if_65_else:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r3}
        mov [r12], r8w
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8117: if_67_else, if_67_then
        cmp ax, -8117
        jne _if_67_else
        jmp _if_67_then
_if_65_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r3}
        mov [r12], r8w
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch row.2{r1} gteq 19: main.no_critical_edge_40, if_66_then
        cmp cl, 19
        jae _main.no_critical_edge_40
        jmp _if_66_then
_main.no_critical_edge_41:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r3}
        mov [r12], r8w
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, r8w
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cl
        jmp _while_56
_if_64_then:
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, r8w
        ; move row.4{r3}, row.2{r1}
        mov r8b, cl
        ; sub row.4{r3}, 1
        sub r8b, 1
        ; move row.2{r1}, row.4{r3}
        mov cl, r8b
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        jmp _while_56
_if_60_end:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cl
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call index.1{r0} = rowColumnToCell@u8@u8[row.2{r1}, col.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.14.1{r3}(i64), index.1{r0}(i16)
        movsx r8, ax
        ; addrof t.13.1{r4}, field
        lea r9, [var_1]
        ; add t.13.2{r4}, t.14.1{r3}
        add r9, r8
        ; load cell.1{r3}, [t.13.2{r4}]
        mov r8b, [r9]
        ; 382:4 if cell & 32 == 0
        ; move t.15.1{r4}, cell.1{r3}
        mov r9b, r8b
        ; and t.15.1{r4}, 32
        and r9b, 32
        ; branch t.15.1{r4} notequals 0: main.no_critical_edge_43, if_61_then
        cmp r9b, 0
        jne _main.no_critical_edge_43
        jmp _if_61_then
_if_67_else:
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8115: if_69_else, if_69_then
        cmp ax, -8115
        jne _if_69_else
        jmp _if_69_then
_if_67_then:
        ; branch col.2{r6} lteq 0: main.no_critical_edge_39, if_68_then
        cmp bl, 0
        jbe _main.no_critical_edge_39
        jmp _if_68_then
_main.no_critical_edge_40:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r3}, [memVarAddr{r7}]
        mov r8w, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, r8w
        jmp _while_56
_if_66_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r3}, [memVarAddr{r7}]
        mov r8w, [r12]
        ; move row.5{r0}, row.2{r1}
        mov al, cl
        ; add row.5{r0}, 1
        add al, 1
        ; move row.2{r1}, row.5{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cl
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, r8w
        jmp _while_56
_main.no_critical_edge_43:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp _if_61_end
_if_61_then:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; move t.16.1{r4}, cell.1{r3}
        mov r9b, r8b
        ; or t.16.1{r4}, 32
        or r9b, 32
        ; cast t.18.1{r0}(i64), index.1{r0}(i16)
        movsx rax, ax
        ; addrof t.17.1{r5}, field
        lea r10, [var_1]
        ; add t.17.2{r5}, t.18.1{r0}
        add r10, rax
        ; store [t.17.2{r5}], t.16.1{r4}
        mov [r10], r9b
        jmp _if_61_end
_if_69_else:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r3}, [memVarAddr{r7}]
        mov r8w, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch chr.1{r0} notequals 32: main.no_critical_edge_34, if_71_then
        cmp ax, 32
        jne _main.no_critical_edge_34
        jmp _if_71_then
_if_69_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r3}, [memVarAddr{r7}]
        mov r8w, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch col.2{r6} gteq 39: main.no_critical_edge_38, if_70_then
        cmp bl, 39
        jae _main.no_critical_edge_38
        jmp _if_70_then
_main.no_critical_edge_39:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r3}, [memVarAddr{r7}]
        mov r8w, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, r8w
        jmp _while_56
_if_68_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r3}, [memVarAddr{r7}]
        mov r8w, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; sub col.5{r6}, 1
        sub bl, 1
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, r8w
        jmp _while_56
_if_61_end:
        ; 385:4 if cell & 128 != 0
        ; move t.19.1{r0}, cell.1{r3}
        mov al, r8b
        ; and t.19.1{r0}, 128
        and al, 128
        ; branch t.19.1{r0} equals 0: if_62_end, if_62_then
        cmp al, 0
        je _if_62_end
        jmp _if_62_then
_main.no_critical_edge_34:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cl
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, r8w
        jmp _while_56
_if_71_then:
        ; branch bombsLeft.2{r3} lt 0: main.no_critical_edge_35, if_72_then
        cmp r8w, 0
        jl _main.no_critical_edge_35
        jmp _if_72_then
_main.no_critical_edge_38:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cl
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, r8w
        jmp _while_56
_if_70_then:
        ; add col.6{r6}, 1
        add bl, 1
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r3}
        mov [r12], r8w
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, r8w
        jmp _while_56
_if_62_end:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cl
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call maybeRevealAround@u8@u8[row.2{r1}, col.2{r2}]
        call _maybeRevealAround@u8@u8
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, bombsLeft.3
        lea r12, [rsp+54]
        ; load bombsLeft.3{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        jmp _while_56
_main.no_critical_edge_35:
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, r8w
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        jmp _while_56
_if_72_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r3}
        mov [r12], r8w
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cl
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call index.2{r0} = rowColumnToCell@u8@u8[row.2{r1}, col.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.22.1{r4}(i64), index.2{r0}(i16)
        movsx r9, ax
        ; addrof t.21.1{r5}, field
        lea r10, [var_1]
        ; add t.21.2{r5}, t.22.1{r4}
        add r10, r9
        ; load cell.3{r4}, [t.21.2{r5}]
        mov r9b, [r10]
        ; 421:5 if cell & 32 == 0
        ; move t.23.1{r5}, cell.3{r4}
        mov r10b, r9b
        ; and t.23.1{r5}, 32
        and r10b, 32
        ; branch t.23.1{r5} equals 0: if_73_then
        cmp r10b, 0
        je _if_73_then
        ; load row.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r5}, [memVarAddr{r7}]
        mov r10w, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; move bombsLeft.2{r0}, bombsLeft.2{r5}
        mov ax, r10w
        jmp _while_56
_if_73_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r5}, [memVarAddr{r7}]
        mov r10w, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move cell.4{r1}, cell.3{r4}
        mov cl, r9b
        ; xor cell.4{r1}, 64
        xor cl, 64
        ; 423:6 if cell & 128 != 0
        ; move t.24.1{r4}, cell.4{r1}
        mov r9b, cl
        ; and t.24.1{r4}, 128
        and r9b, 128
        ; branch t.24.1{r4} notequals 0: if_74_then
        cmp r9b, 0
        jne _if_74_then
        ; move bombsLeft.6{r4}, bombsLeft.2{r5}
        mov r9w, r10w
        ; addrof memVarAddr{r7}, bombsLeft.6
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], bombsLeft.6{r4}
        mov [r12], r9w
        jmp _if_74_end
_if_74_then:
        ; 424:7 if cell & 64 != 0
        ; move t.25.1{r4}, cell.4{r1}
        mov r9b, cl
        ; and t.25.1{r4}, 64
        and r9b, 64
        ; branch t.25.1{r4} notequals 0: if_75_then
        cmp r9b, 0
        jne _if_75_then
        ; move bombsLeft.7{r4}, bombsLeft.2{r5}
        mov r9w, r10w
        ; add bombsLeft.7{r4}, 1
        add r9w, 1
        ; addrof memVarAddr{r7}, bombsLeft.6
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], bombsLeft.6{r4}
        mov [r12], r9w
        jmp _if_74_end
_if_75_then:
        ; move bombsLeft.8{r4}, bombsLeft.2{r5}
        mov r9w, r10w
        ; sub bombsLeft.8{r4}, 1
        sub r9w, 1
        ; addrof memVarAddr{r7}, bombsLeft.6
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], bombsLeft.6{r4}
        mov [r12], r9w
_if_74_end:
        ; cast t.27.1{r0}(i64), index.2{r0}(i16)
        movsx rax, ax
        ; addrof t.26.1{r4}, field
        lea r9, [var_1]
        ; add t.26.2{r4}, t.27.1{r0}
        add r9, rax
        ; store [t.26.2{r4}], cell.4{r1}
        mov [r9], cl
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r2}
        mov [r12], dl
        ; move col.2{r3}, col.2{r6}
        mov r8b, bl
        ; call printCellAt@u8@u8@u8[cell.4{r1}, row.2{r2}, col.2{r3}]
        call _printCellAt@u8@u8@u8
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, bombsLeft.6
        lea r12, [rsp+56]
        ; load bombsLeft.6{r0}, [memVarAddr{r7}]
        mov ax, [r12]
_while_56:
        ; branch bombsLeft.2{r0} notequals 0: if_57_end
        cmp ax, 0
        jne _if_57_end
        ; const t.10.1{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[t.10.1{r1}]
        call _printString@@u8
        jmp _main_ret
_if_62_then:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cl
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call printCellAt@u8@u8[row.2{r1}, col.2{r2}]
        call _printCellAt@u8@u8
        ; const t.20.1{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString@@u8[t.20.1{r1}]
        call _printString@@u8
_main_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
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
        string_1 db ' You', 0x27, 've cleaned the field!', 0x00
        string_2 db 'boom! you', 0x27, 've lost', 0x00

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
