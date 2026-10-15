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

        ; void _printString@@u8
        ;   rsp+48: arg str
_printString@@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move str{r6}, str{r1}
        mov rbx, rcx
        ; call length.1{r0} = _strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length.1{r2}, length.1{r0}
        mov rdx, rax
        ; call _printStringLength@@u8@i64[str{r1}, length.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void _printChar@u8
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
        ; call _printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; i64 _strlen@@u8
        ;   rsp+16: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length.1{r0}, 0
        mov rax, 0
        ; 73:2 for *str != 0
        jmp for_1
for_1_body:
        ; add length.3{r0}, 1
        add rax, 1
        ; add str.2{r1}, 1
        add rcx, 1
for_1:
        ; load t.2.1{r2}, [str.1{r1}]
        mov dl, [rcx]
        ; branch t.2.1{r2} notequals 0: for_1_body
        cmp dl, 0
        jne for_1_body
        ; 76:9 return length
        add rsp, 8
        ret

        ; void _printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
_printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call _printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void _initRandom@i32
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

        ; i32 _random
_random:
        sub rsp, 8
        ; addrof a.5.1{r0}, __random__
        lea rax, [var_0]
        ; load r.1{r0}, [a.5.1{r0}]
        mov eax, [rax]
        ; move t.6.1{r1}, r.1{r0}
        mov ecx, eax
        ; and t.6.1{r1}, 524287
        and ecx, 524287
        ; mul b.1{r1}, 48271
        movsxd rcx, ecx
        imul  rcx, 48271
        ; shiftright t.7.1{r0}, 15
        sar eax, 15
        ; mul c.1{r0}, 48271
        movsxd rax, eax
        imul  rax, 48271
        ; move t.8.1{r2}, c.1{r0}
        mov edx, eax
        ; and t.8.1{r2}, 65535
        and edx, 65535
        ; shiftleft d.1{r2}, 15
        sal edx, 15
        ; shiftright t.10.1{r0}, 16
        sar eax, 16
        ; add t.9.1{r0}, b.1{r1}
        add eax, ecx
        ; add e.1{r0}, d.1{r2}
        add eax, edx
        ; move t.12.1{r1}, e.1{r0}
        mov ecx, eax
        ; and t.12.1{r1}, 2147483647
        and ecx, 2147483647
        ; shiftright t.13.1{r0}, 31
        sar eax, 31
        ; add t.11.1{r1}, t.13.1{r0}
        add ecx, eax
        ; addrof a.14.1{r0}, __random__
        lea rax, [var_0]
        ; store [a.14.1{r0}], t.11.1{r1}
        mov [rax], ecx
        ; 16:9 return __random__
        ; move t.16.1{r0}, t.16.1{r1}
        mov eax, ecx
        add rsp, 8
        ret

        ; i16 _random16
_random16:
        sub rsp, 8
        sub rsp, 32
        ; 20:25 return (i16) & 32767
        ; call t.2.1{r0} = _random[] -> i32
        call _random
        ; cast t.1.1{r0}(i16), t.2.1{r0}(i32)
        ; and t.0.1{r0}, 32767
        and ax, 32767
        add rsp, 32
        add rsp, 8
        ret

        ; i16 _rowColumnToCell@u8@u8
        ;   rsp+16: arg row
        ;   rsp+24: arg column
_rowColumnToCell@u8@u8:
        sub rsp, 8
        ; cast r.1{r0}(i16), row{r1}(u8)
        movzx ax, cl
        ; cast c.1{r1}(i16), column{r2}(u8)
        movzx cx, dl
        ; 33:19 return r * 40 + c
        ; mul t.5.1{r0}, 40
        movsx rax, ax
        imul  rax, 40
        ; add t.4.1{r0}, c.1{r1}
        add ax, cx
        add rsp, 8
        ret

        ; i16 _columnToX@u8
        ;   rsp+16: arg column
_columnToX@u8:
        sub rsp, 8
        ; cast c.1{r0}(i16), column{r1}(u8)
        movzx ax, cl
        ; 42:17 return c + 1 << 1
        ; add t.3.1{r0}, 1
        add ax, 1
        ; shiftleft t.2.1{r0}, 1
        sal ax, 1
        add rsp, 8
        ret

        ; void _printCellAt@u8@u8
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
        ; move column{r0}, column{r2}
        mov al, dl
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r0}
        mov [r12], al
        ; call t.5.1{r0} = _rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.4.1{r0}(i64), t.5.1{r0}(i16)
        movsx rax, ax
        ; addrof t.3.1{r1}, field
        lea rcx, [var_1]
        ; add t.3.2{r1}, t.4.1{r0}
        add rcx, rax
        ; load cell.1{r1}, [t.3.2{r1}]
        mov cl, [rcx]
        ; move row{r2}, row{r6}
        mov dl, bl
        ; load column{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; call _printCellAt@u8@u8@u8[cell.1{r1}, row{r2}, column{r3}]
        call _printCellAt@u8@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void _printCellAt@u8@u8@u8
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
        ; call x.1{r0} = _columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+72]
        ; load row{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; cast t.4.1{r1}(i16), row{r2}(u8)
        movzx cx, dl
        ; move x.1{r2}, x.1{r0}
        mov dx, ax
        ; call _setCursor@i16@i16[t.4.1{r1}, x.1{r2}]
        call _setCursor@i16@i16
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; load row{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+80]
        ; load column{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; call _printCell@u8@u8@u8[cell{r1}, row{r2}, column{r3}]
        call _printCell@u8@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void _printCell@u8@u8@u8
        ;   rsp+48: arg cell
        ;   rsp+56: arg row
        ;   rsp+64: arg column
_printCell@u8@u8@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const chr.1{r0}, 46
        mov al, 46
        ; 58:2 if cell & 32 != 0
        ; move t.6.1{r4}, cell{r1}
        mov r9b, cl
        ; and t.6.1{r4}, 32
        and r9b, 32
        ; branch t.6.1{r4} notequals 0: if_2_then
        cmp r9b, 0
        jne if_2_then
        ; 73:7 if cell & 64 != 0
        ; and t.11.1{r1}, 64
        and cl, 64
        ; branch t.11.1{r1} equals 0: _printCell@u8@u8@u8.no_critical_edge_10, if_5_then
        cmp cl, 0
        je _printCell@u8@u8@u8.no_critical_edge_10
        jmp if_5_then
if_2_then:
        ; 59:3 if cell & 128 != 0
        ; move t.7.1{r0}, cell{r1}
        mov al, cl
        ; and t.7.1{r0}, 128
        and al, 128
        ; branch t.7.1{r0} equals 0: if_3_else, if_3_then
        cmp al, 0
        je if_3_else
        jmp if_3_then
_printCell@u8@u8@u8.no_critical_edge_10:
        ; move chr.2{r6}, chr.1{r0}
        mov bl, al
        jmp if_2_end
if_5_then:
        ; const chr.3{r0}, 35
        mov al, 35
        ; move chr.2{r6}, chr.3{r0}
        mov bl, al
        jmp if_2_end
if_3_else:
        ; move row{r1}, row{r2}
        mov cl, dl
        ; move column{r2}, column{r3}
        mov dl, r8b
        ; call index.1{r0} = _rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.10.1{r0}(i64), index.1{r0}(i16)
        movsx rax, ax
        ; addrof t.9.1{r1}, field
        lea rcx, [var_1]
        ; add t.9.2{r1}, t.10.1{r0}
        add rcx, rax
        ; load t.8.1{r0}, [t.9.2{r1}]
        mov al, [rcx]
        ; and count.1{r0}, 15
        and al, 15
        ; 65:4 if count > 0
        ; branch count.1{r0} lteq 0: if_4_else, if_4_then
        cmp al, 0
        jbe if_4_else
        jmp if_4_then
if_3_then:
        ; const chr.4{r0}, 42
        mov al, 42
        ; move chr.2{r6}, chr.4{r0}
        mov bl, al
        jmp if_2_end
if_4_else:
        ; const chr.5{r0}, 32
        mov al, 32
        ; move chr.2{r6}, chr.5{r0}
        mov bl, al
        jmp if_2_end
if_4_then:
        ; add chr.6{r0}, 48
        add al, 48
        ; move chr.2{r6}, chr.6{r0}
        mov bl, al
if_2_end:
        ; move chr.2{r1}, chr.2{r6}
        mov cl, bl
        ; call _printChar@u8[chr.2{r1}]
        call _printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void _initializeScreen
_initializeScreen:
        sub rsp, 8
        sub rsp, 32
        ; call _printField[]
        call _printField
        add rsp, 32
        add rsp, 8
        ret

        ; void _printField
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
        ; call _setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const row.1{r0}, 0
        mov al, 0
        ; 92:2 for row < 20
        ; move row.2{r6}, row.1{r0}
        mov bl, al
        jmp for_6
for_6_body:
        ; cast t.3.1{r1}(i16), row.2{r6}(u8)
        movzx cx, bl
        ; const arg.1.1{r2}, 0
        mov dx, 0
        ; call _setCursor@i16@i16[t.3.1{r1}, arg.1.1{r2}]
        call _setCursor@i16@i16
        ; const arg.2.0{r1}, 124
        mov cl, 124
        ; call _printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        ; const column.1{r0}, 0
        mov al, 0
        ; 97:3 for column < 40
        ; move column.2{r2}, column.1{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], column.2{r2}
        mov [r12], dl
        jmp for_7
for_7_body:
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], column.2{r2}
        mov [r12], dl
        ; const arg.3.0{r1}, 32
        mov cl, 32
        ; call _printChar@u8[arg.3.0{r1}]
        call _printChar@u8
        ; move row.2{r1}, row.2{r6}
        mov cl, bl
        ; load column.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move column.2{r2}, column.2{r0}
        mov dl, al
        ; call t.6.1{r0} = _rowColumnToCell@u8@u8[row.2{r1}, column.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.5.1{r0}(i64), t.6.1{r0}(i16)
        movsx rax, ax
        ; addrof t.4.1{r1}, field
        lea rcx, [var_1]
        ; add t.4.2{r1}, t.5.1{r0}
        add rcx, rax
        ; load cell.1{r1}, [t.4.2{r1}]
        mov cl, [rcx]
        ; move row.2{r2}, row.2{r6}
        mov dl, bl
        ; load column.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move column.2{r3}, column.2{r0}
        mov r8b, al
        ; call _printCell@u8@u8@u8[cell.1{r1}, row.2{r2}, column.2{r3}]
        call _printCell@u8@u8@u8
        ; load column.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move column.3{r0}, column.2{r2}
        mov al, dl
        ; add column.3{r0}, 1
        add al, 1
        ; move column.2{r2}, column.3{r0}
        mov dl, al
for_7:
        ; branch column.2{r2} lt 40: for_7_body
        cmp dl, 40
        jb for_7_body
        ; const t.7.1{r1}, [string-0]
        lea rcx, [string_0]
        ; call _printString@@u8[t.7.1{r1}]
        call _printString@@u8
        ; move row.4{r0}, row.2{r6}
        mov al, bl
        ; add row.4{r0}, 1
        add al, 1
        ; move row.2{r6}, row.4{r0}
        mov bl, al
for_6:
        ; branch row.2{r6} lt 20: for_6_body
        cmp bl, 20
        jb for_6_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void _showCursor@u8@u8@bool
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
        ; move column{r1}, column{r2}
        mov cl, dl
        ; call x.1{r0} = _columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; cast t.6.1{r1}(i16), row{r6}(u8)
        movzx cx, bl
        ; move t.7.1{r2}, x.1{r0}
        mov dx, ax
        ; addrof memVarAddr{r7}, x.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], x.1{r0}
        mov [r12], ax
        ; sub t.7.1{r2}, 1
        sub dx, 1
        ; call _setCursor@i16@i16[t.6.1{r1}, t.7.1{r2}]
        call _setCursor@i16@i16
        ; const chr.1{r0}, 32
        mov al, 32
        ; 122:2 if show
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; load show{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; branch show{r3} equals 0: if_8_end
        cmp r8b, 0
        je if_8_end
        ; const chr.3{r0}, 91
        mov al, 91
if_8_end:
        ; move chr.2{r1}, chr.2{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, chr.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], chr.2{r0}
        mov [r12], al
        ; call _printChar@u8[chr.2{r1}]
        call _printChar@u8
        ; cast t.8.1{r1}(i16), row{r6}(u8)
        movzx cx, bl
        ; addrof memVarAddr{r7}, x.1
        lea r12, [rsp+48]
        ; load x.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.9.1{r2}, x.1{r0}
        mov dx, ax
        ; add t.9.1{r2}, 1
        add dx, 1
        ; call _setCursor@i16@i16[t.8.1{r1}, t.9.1{r2}]
        call _setCursor@i16@i16
        ; 128:2 if show
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; load show{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; branch show{r3} notequals 0: if_9_then
        cmp r8b, 0
        jne if_9_then
        ; addrof memVarAddr{r7}, chr.2
        lea r12, [rsp+50]
        ; load chr.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp if_9_end
if_9_then:
        ; const chr.5{r0}, 93
        mov al, 93
        ; move chr.4{r1}, chr.5{r0}
        mov cl, al
if_9_end:
        ; call _printChar@u8[chr.4{r1}]
        call _printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; i16 _abs@i16
        ;   rsp+16: arg a
_abs@i16:
        sub rsp, 8
        ; branch a{r1} lt 0: if_10_then
        cmp cx, 0
        jl if_10_then
        ; 186:9 return a
        ; move a{r0}, a{r1}
        mov ax, cx
        jmp _abs@i16_ret
if_10_then:
        ; 184:10 return -a
        ; neg t.1.1{r1}, a{r1}
        neg rcx
        ; move t.1.1{r0}, t.1.1{r1}
        mov ax, cx
_abs@i16_ret:
        add rsp, 8
        ret

        ; void _clearField
_clearField:
        sub rsp, 8
        ; const index.1{r0}, 0
        mov ax, 0
        ; const i.1{r1}, 800
        mov cx, 800
        ; 191:2 for i > 0
        jmp for_11
for_11_body:
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
for_11:
        ; branch i.2{r1} gt 0: for_11_body
        cmp cx, 0
        jg for_11_body
        add rsp, 8
        ret

        ; i16 _initField@u8@u8
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
        ; 200:2 for bombs > 0
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
        jmp for_12
for_12_body:
        ; addrof memVarAddr{r7}, bombCount.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombCount.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, bombs.2
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], bombs.2{r1}
        mov [r12], cx
        ; call t.8.1{r0} = _random16[] -> i16
        call _random16
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
        ; call t.9.1{r0} = _random16[] -> i16
        call _random16
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
        ; 203:3 if _abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=203:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=203:20], location=203:18]]) > 1 || _abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=204:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=204:20], location=204:18]]) > 1
        ; addrof memVarAddr{r7}, row.1
        lea r12, [rsp+54]
        ; load row.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.11.1{r1}, row.1{r0}
        mov cx, ax
        ; sub t.11.1{r1}, r.1{r6}
        sub cx, bx
        ; call t.10.1{r0} = _abs@i16[t.11.1{r1}] -> i16
        call _abs@i16
        ; branch t.10.1{r0} gt 1: if_13_then
        cmp ax, 1
        jg if_13_then
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
        ; call t.12.1{r0} = _abs@i16[t.13.1{r1}] -> i16
        call _abs@i16
        ; branch t.12.1{r0} gt 1: if_13_then
        cmp ax, 1
        jg if_13_then
        ; addrof memVarAddr{r7}, bombCount.2
        lea r12, [rsp+50]
        ; load bombCount.2{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; addrof memVarAddr{r7}, bombCount.4
        lea r12, [rsp+58]
        ; store [memVarAddr{r7}], bombCount.4{r0}
        mov [r12], ax
        jmp for_12_continue
if_13_then:
        ; 205:4 if _setBomb@u8@u8([ExprCast[typeString=u8, expression=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=205:15], type=u8, location=205:22], ExprCast[typeString=u8, expression=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=205:26], type=u8, location=205:36]])
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
        ; call t.14.1{r0} = _setBomb@u8@u8[t.15.1{r1}, t.16.1{r2}] -> bool
        call _setBomb@u8@u8
        ; branch t.14.1{r0} notequals 0: if_15_then
        cmp al, 0
        jne if_15_then
        ; addrof memVarAddr{r7}, bombCount.2
        lea r12, [rsp+50]
        ; load bombCount.2{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        jmp for_12_continue
if_15_then:
        ; addrof memVarAddr{r7}, bombCount.2
        lea r12, [rsp+50]
        ; load bombCount.2{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; add bombCount.5{r0}, 1
        add ax, 1
for_12_continue:
        ; addrof memVarAddr{r7}, bombs.2
        lea r12, [rsp+52]
        ; load bombs.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; sub bombs.5{r1}, 1
        sub cx, 1
for_12:
        ; branch bombs.2{r1} gt 0: for_12_body
        cmp cx, 0
        jg for_12_body
        ; 210:9 return bombCount
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; bool _setBomb@u8@u8
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
        ; move column{r0}, column{r2}
        mov al, dl
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r0}
        mov [r12], al
        ; call index.1{r0} = _rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; move index.1{r1}, index.1{r0}
        mov cx, ax
        ; 215:2 if [...] == 128
        ; cast t.14.1{r0}(i64), index.1{r1}(i16)
        movsx rax, cx
        ; addrof t.13.1{r2}, field
        lea rdx, [var_1]
        ; add t.13.2{r2}, t.14.1{r0}
        add rdx, rax
        ; load t.12.1{r0}, [t.13.2{r2}]
        mov al, [rdx]
        ; branch t.12.1{r0} equals 128: if_16_then
        cmp al, 128
        je if_16_then
        ; const t.15.1{r0}, 128
        mov al, 128
        ; cast t.17.1{r2}(i64), index.1{r1}(i16)
        movsx rdx, cx
        ; addrof t.16.1{r3}, field
        lea r8, [var_1]
        ; add t.16.2{r3}, t.17.1{r2}
        add r8, rdx
        ; store [t.16.2{r3}], t.15.1{r0}
        mov [r8], al
        ; move rowFrom.1{r2}, row{r6}
        mov dl, bl
        ; 221:2 if rowFrom > 0
        ; branch rowFrom.1{r2} lteq 0: if_17_end, if_17_then
        cmp dl, 0
        jbe if_17_end
        jmp if_17_then
if_16_then:
        ; const {r0}, 0
        mov al, 0
        jmp _setBomb@u8@u8_ret
if_17_then:
        ; sub rowFrom.3{r2}, 1
        sub dl, 1
        ; sub index.3{r1}, 40
        sub cx, 40
if_17_end:
        ; move rowTo.1{r3}, row{r6}
        mov r8b, bl
        ; add rowTo.1{r3}, 1
        add r8b, 1
        ; 226:2 if rowTo >= 20
        ; branch rowTo.1{r3} lt 20: if_18_end
        cmp r8b, 20
        jb if_18_end
        ; sub rowTo.3{r3}, 1
        sub r8b, 1
if_18_end:
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; move colFrom.1{r5}, column{r4}
        mov r10b, r9b
        ; 231:2 if colFrom > 0
        ; branch colFrom.1{r5} lteq 0: if_19_end
        cmp r10b, 0
        jbe if_19_end
        ; sub colFrom.3{r5}, 1
        sub r10b, 1
        ; sub index.6{r1}, 1
        sub cx, 1
if_19_end:
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], rowTo.2{r3}
        mov [r12], r8b
        ; move colTo.1{r3}, column{r4}
        mov r8b, r9b
        ; add colTo.1{r3}, 1
        add r8b, 1
        ; 236:2 if colTo >= 40
        ; branch colTo.1{r3} lt 40: if_20_end
        cmp r8b, 40
        jb if_20_end
        ; sub colTo.3{r3}, 1
        sub r8b, 1
if_20_end:
        ; 241:2 for r <= rowTo
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
        jmp for_21
for_21_body:
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
        ; 242:3 for c <= colTo
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], r.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        jmp for_22
for_22_body:
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
        ; branch r.2{r2} notequals row{r6}: if_23_end
        cmp dl, bl
        jne if_23_end
        ; branch c.2{r5} notequals column{r4}: if_23_end
        cmp r10b, r9b
        jne if_23_end
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+64]
        jmp for_22_continue
if_23_end:
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
        ; 248:4 if cell & 128 == 0
        ; move t.20.1{r6}, cell.1{r4}
        mov bl, r9b
        ; and t.20.1{r6}, 128
        and bl, 128
        ; branch t.20.1{r6} equals 0: if_25_then
        cmp bl, 0
        je if_25_then
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], r.2{r2}
        mov [r12], dl
        jmp for_22_continue
if_25_then:
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
for_22_continue:
        ; move c.5{r2}, c.2{r5}
        mov dl, r10b
        ; add c.5{r2}, 1
        add dl, 1
        ; add index.13{r1}, 1
        add cx, 1
        ; move c.2{r5}, c.5{r2}
        mov r10b, dl
for_22:
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+49]
        ; load colTo.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; branch c.2{r5} lteq colTo.2{r2}: for_22_body
        cmp r10b, dl
        jbe for_22_body
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
for_21:
        ; addrof memVarAddr{r7}, rowTo.2
        lea r12, [rsp+48]
        ; load rowTo.2{r5}, [memVarAddr{r7}]
        mov r10b, [r12]
        ; branch r.2{r4} lteq rowTo.2{r5}: for_21_body
        cmp r9b, r10b
        jbe for_21_body
        ; const {r0}, 1
        mov al, 1
_setBomb@u8@u8_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void _maybeRevealAround@u8@u8
        ;   rsp+64: arg row
        ;   rsp+72: arg column
        ;   rsp+48: var r.2
        ;   rsp+49: var changed.5
        ;   rsp+50: var c.2
        ;   rsp+51: var r.7
        ;   rsp+52: var changed.7
        ;   rsp+53: var c.4
        ;   rsp+54: var changed.8
        ;   rsp+55: var c.7
_maybeRevealAround@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move row{r6}, row{r1}
        mov bl, cl
        ; move column{r0}, column{r2}
        mov al, dl
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r0}
        mov [r12], al
        ; call _printCellAt@u8@u8[row{r1}, column{r2}]
        call _printCellAt@u8@u8
        ; move row{r1}, row{r6}
        mov cl, bl
        ; load column{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move column{r2}, column{r0}
        mov dl, al
        ; call index.1{r0} = _rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; 262:2 if [...] & 15 != 0
        ; cast t.15.1{r1}(i64), index.1{r0}(i16)
        movsx rcx, ax
        ; addrof t.14.1{r2}, field
        lea rdx, [var_1]
        ; add t.14.2{r2}, t.15.1{r1}
        add rdx, rcx
        ; load t.13.1{r1}, [t.14.2{r2}]
        mov cl, [rdx]
        ; and t.12.1{r1}, 15
        and cl, 15
        ; branch t.12.1{r1} notequals 0: _maybeRevealAround@u8@u8_ret
        cmp cl, 0
        jne _maybeRevealAround@u8@u8_ret
        ; const t.17.1{r1}, 0
        mov rcx, 0
        ; addrof t.16.1{r2}, revealStackRows
        lea rdx, [var_2]
        ; add t.16.2{r2}, t.17.1{r1}
        add rdx, rcx
        ; store [t.16.2{r2}], row{r6}
        mov [rdx], bl
        ; addrof t.18.1{r2}, revealStackColumns
        lea rdx, [var_3]
        ; add t.18.2{r2}, t.19.1{r1}
        add rdx, rcx
        ; load column{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; store [t.18.2{r2}], column{r1}
        mov [rdx], cl
        ; addrof a.20.1{r1}, revealStackIndices
        lea rcx, [var_4]
        ; store [a.20.1{r1}], index.1{r0}
        mov [rcx], ax
        ; move a.22.1{r0}, a.22.1{r1}
        mov rax, rcx
        ; add t.21.1{r0}, 2
        add rax, 2
        ; addrof a.23.1{r1}, revealStackIndexTop
        lea rcx, [var_5]
        ; store [a.23.1{r1}], t.21.1{r0}
        mov [rcx], rax
        ; const t.24.1{r0}, 1
        mov al, 1
        ; addrof a.25.1{r1}, revealStackSize
        lea rcx, [var_6]
        ; store [a.25.1{r1}], t.24.1{r0}
        mov [rcx], al
        ; 271:2 while revealStackSize > 0
        jmp while_27
while_27_body:
        ; addrof a.28.1{r0}, revealStackSize
        lea rax, [var_6]
        ; load t.29.1{r0}, [a.28.1{r0}]
        mov al, [rax]
        ; sub stackSize.1{r0}, 1
        sub al, 1
        ; move t.30.1{r1}, stackSize.1{r0}
        mov cl, al
        ; addrof a.31.1{r2}, revealStackSize
        lea rdx, [var_6]
        ; store [a.31.1{r2}], t.30.1{r1}
        mov [rdx], cl
        ; cast t.33.1{r1}(i64), stackSize.1{r0}(u8)
        movzx rcx, al
        ; addrof t.32.1{r2}, revealStackRows
        lea rdx, [var_2]
        ; add t.32.2{r2}, t.33.1{r1}
        add rdx, rcx
        ; load row.1{r1}, [t.32.2{r2}]
        mov cl, [rdx]
        ; cast t.35.1{r0}(i64), stackSize.1{r0}(u8)
        movzx rax, al
        ; addrof t.34.1{r2}, revealStackColumns
        lea rdx, [var_3]
        ; add t.34.2{r2}, t.35.1{r0}
        add rdx, rax
        ; load column.1{r2}, [t.34.2{r2}]
        mov dl, [rdx]
        ; addrof a.36.1{r0}, revealStackIndexTop
        lea rax, [var_5]
        ; load t.37.1{r0}, [a.36.1{r0}]
        mov rax, [rax]
        ; add stackIndex.1{r0}, -2
        add rax, -2
        ; move t.38.1{r3}, stackIndex.1{r0}
        mov r8, rax
        ; addrof a.39.1{r4}, revealStackIndexTop
        lea r9, [var_5]
        ; store [a.39.1{r4}], t.38.1{r3}
        mov [r9], r8
        ; load index.2{r3}, [stackIndex.1{r0}]
        mov r8w, [rax]
        ; call _ = _revealNeighbors@u8@u8@i16[row.1{r1}, column.1{r2}, index.2{r3}] -> bool
        call _revealNeighbors@u8@u8@i16
        ; 280:3 if revealStackSize == 255
        ; addrof a.40.1{r0}, revealStackSize
        lea rax, [var_6]
        ; load t.41.1{r0}, [a.40.1{r0}]
        mov al, [rax]
        ; branch t.41.1{r0} equals 255: while_27_break, while_27
        cmp al, 255
        je while_27_break
while_27:
        ; addrof a.26.1{r0}, revealStackSize
        lea rax, [var_6]
        ; load t.27.1{r0}, [a.26.1{r0}]
        mov al, [rax]
        ; branch t.27.1{r0} gt 0: while_27_body, while_27_break
        cmp al, 0
        ja while_27_body
while_27_break:
        ; 284:2 if revealStackSize != 255
        ; addrof a.42.1{r0}, revealStackSize
        lea rax, [var_6]
        ; load t.43.1{r0}, [a.42.1{r0}]
        mov al, [rax]
        ; branch t.43.1{r0} notequals 255: _maybeRevealAround@u8@u8_ret
        cmp al, 255
        jne _maybeRevealAround@u8@u8_ret
        ; const changed.1{r0}, 1
        mov al, 1
        ; 289:2 while changed
        ; move changed.2{r6}, changed.1{r0}
        mov bl, al
        jmp while_30
while_30_body:
        ; const changed.3{r0}, 0
        mov al, 0
        ; const index.3{r1}, 0
        mov cx, 0
        ; const r.1{r2}, 0
        mov dl, 0
        ; 293:3 for r < 20
        ; move index.4{r6}, index.3{r1}
        mov bx, cx
        ; move r.2{r1}, r.2{r2}
        mov cl, dl
        jmp for_31
for_31_body:
        ; move r.2{r2}, r.2{r1}
        mov dl, cl
        ; const c.1{r1}, 0
        mov cl, 0
        ; 294:4 for c < 40
        ; move c.2{r3}, c.1{r1}
        mov r8b, cl
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r.2{r2}
        mov [r12], dl
        ; move c.2{r2}, c.2{r3}
        mov dl, r8b
        jmp for_32
for_32_body:
        ; move c.2{r3}, c.2{r2}
        mov r8b, dl
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; load r.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; cast t.45.1{r1}(i64), index.5{r6}(i16)
        movsx rcx, bx
        ; addrof t.44.1{r4}, field
        lea r9, [var_1]
        ; add t.44.2{r4}, t.45.1{r1}
        add r9, rcx
        ; load cell.1{r1}, [t.44.2{r4}]
        mov cl, [r9]
        ; 296:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.46.1{r4}, cell.1{r1}
        mov r9b, cl
        ; and t.46.1{r4}, 32
        and r9b, 32
        ; branch t.46.1{r4} notequals 0: or_34
        cmp r9b, 0
        jne or_34
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c.2{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        jmp for_32_continue
or_34:
        ; and t.47.1{r1}, 128
        and cl, 128
        ; branch t.47.1{r1} equals 0: if_33_end
        cmp cl, 0
        je if_33_end
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c.2{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r.2{r2}
        mov [r12], dl
        jmp for_32_continue
if_33_end:
        ; 299:5 if [...] & 15 != 0
        ; cast t.51.1{r1}(i64), index.5{r6}(i16)
        movsx rcx, bx
        ; addrof t.50.1{r4}, field
        lea r9, [var_1]
        ; add t.50.2{r4}, t.51.1{r1}
        add r9, rcx
        ; load t.49.1{r1}, [t.50.2{r4}]
        mov cl, [r9]
        ; and t.48.1{r1}, 15
        and cl, 15
        ; branch t.48.1{r1} equals 0: if_35_end
        cmp cl, 0
        je if_35_end
        ; addrof memVarAddr{r7}, changed.8
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], changed.8{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c.2{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, changed.8
        lea r12, [rsp+54]
        jmp for_32_continue
if_35_end:
        ; addrof memVarAddr{r7}, changed.5
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], changed.5{r0}
        mov [r12], al
        ; 303:5 if _revealNeighbors@u8@u8@i16([ExprVarAccess[varName=r, index=6, scope=function, type=u8, varIsArray=false, location=303:24], ExprVarAccess[varName=c, index=7, scope=function, type=u8, varIsArray=false, location=303:27], ExprVarAccess[varName=index, index=2, scope=function, type=i16, varIsArray=false, location=303:30]])
        ; move r.2{r1}, r.2{r2}
        mov cl, dl
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r.2{r2}
        mov [r12], dl
        ; move c.2{r2}, c.2{r3}
        mov dl, r8b
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c.2{r3}
        mov [r12], r8b
        ; move index.5{r3}, index.5{r6}
        mov r8w, bx
        ; call t.52.1{r0} = _revealNeighbors@u8@u8@i16[r.2{r1}, c.2{r2}, index.5{r3}] -> bool
        call _revealNeighbors@u8@u8@i16
        ; branch t.52.1{r0} notequals 0: if_36_then
        cmp al, 0
        jne if_36_then
        ; addrof memVarAddr{r7}, changed.5
        lea r12, [rsp+49]
        ; load changed.5{r0}, [memVarAddr{r7}]
        mov al, [r12]
        jmp for_32_continue
if_36_then:
        ; const changed.9{r0}, 1
        mov al, 1
for_32_continue:
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+50]
        ; load c.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move c.6{r1}, c.2{r2}
        mov cl, dl
        ; add c.6{r1}, 1
        add cl, 1
        ; move index.9{r2}, index.5{r6}
        mov dx, bx
        ; add index.9{r2}, 1
        add dx, 1
        ; move index.5{r6}, index.9{r2}
        mov bx, dx
        ; move c.2{r2}, c.6{r1}
        mov dl, cl
for_32:
        ; branch c.2{r2} lt 40: for_32_body
        cmp dl, 40
        jb for_32_body
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+48]
        ; load r.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; add r.6{r1}, 1
        add cl, 1
for_31:
        ; branch r.2{r1} lt 20: for_31_body
        cmp cl, 20
        jb for_31_body
        ; branch changed.4{r0} equals 0: _maybeRevealAround@u8@u8_ret
        cmp al, 0
        je _maybeRevealAround@u8@u8_ret
        ; const r.4{r1}, 20
        mov cl, 20
        ; 314:3 while true
        jmp while_38
if_39_end:
        ; move r.7{r2}, r.5{r1}
        mov dl, cl
        ; sub r.7{r2}, 1
        sub dl, 1
        ; const c.3{r1}, 40
        mov cl, 40
        ; 321:4 while true
        ; addrof memVarAddr{r7}, r.7
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], r.7{r2}
        mov [r12], dl
        jmp while_40
if_41_end:
        ; addrof memVarAddr{r7}, r.7
        lea r12, [rsp+51]
        ; load r.7{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move c.7{r3}, c.4{r1}
        mov r8b, cl
        ; sub c.7{r3}, 1
        sub r8b, 1
        ; sub index.10{r6}, 1
        sub bx, 1
        ; cast t.54.1{r1}(i64), index.10{r6}(i16)
        movsx rcx, bx
        ; addrof t.53.1{r4}, field
        lea r9, [var_1]
        ; add t.53.2{r4}, t.54.1{r1}
        add r9, rcx
        ; load cell.2{r1}, [t.53.2{r4}]
        mov cl, [r9]
        ; 328:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.55.1{r4}, cell.2{r1}
        mov r9b, cl
        ; and t.55.1{r4}, 32
        and r9b, 32
        ; branch t.55.1{r4} notequals 0: or_43
        cmp r9b, 0
        jne or_43
        ; move c.4{r1}, c.7{r3}
        mov cl, r8b
        jmp while_40
or_43:
        ; and t.56.1{r1}, 128
        and cl, 128
        ; branch t.56.1{r1} equals 0: if_42_end
        cmp cl, 0
        je if_42_end
        ; move c.4{r1}, c.7{r3}
        mov cl, r8b
        ; addrof memVarAddr{r7}, r.7
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], r.7{r2}
        mov [r12], dl
        jmp while_40
if_42_end:
        ; 331:5 if [...] & 15 != 0
        ; cast t.60.1{r1}(i64), index.10{r6}(i16)
        movsx rcx, bx
        ; addrof t.59.1{r4}, field
        lea r9, [var_1]
        ; add t.59.2{r4}, t.60.1{r1}
        add r9, rcx
        ; load t.58.1{r1}, [t.59.2{r4}]
        mov cl, [r9]
        ; and t.57.1{r1}, 15
        and cl, 15
        ; branch t.57.1{r1} equals 0: if_44_end
        cmp cl, 0
        je if_44_end
        ; addrof memVarAddr{r7}, changed.7
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], changed.7{r0}
        mov [r12], al
        ; move c.4{r1}, c.7{r3}
        mov cl, r8b
        ; addrof memVarAddr{r7}, c.4
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], c.4{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, r.7
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], r.7{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, changed.7
        lea r12, [rsp+52]
        jmp while_40
if_44_end:
        ; addrof memVarAddr{r7}, changed.7
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], changed.7{r0}
        mov [r12], al
        ; 335:5 if _revealNeighbors@u8@u8@i16([ExprVarAccess[varName=r, index=9, scope=function, type=u8, varIsArray=false, location=335:24], ExprVarAccess[varName=c, index=10, scope=function, type=u8, varIsArray=false, location=335:27], ExprVarAccess[varName=index, index=2, scope=function, type=i16, varIsArray=false, location=335:30]])
        ; move r.7{r1}, r.7{r2}
        mov cl, dl
        ; addrof memVarAddr{r7}, r.7
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], r.7{r2}
        mov [r12], dl
        ; move c.7{r2}, c.7{r3}
        mov dl, r8b
        ; addrof memVarAddr{r7}, c.7
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], c.7{r3}
        mov [r12], r8b
        ; move index.10{r3}, index.10{r6}
        mov r8w, bx
        ; call t.61.1{r0} = _revealNeighbors@u8@u8@i16[r.7{r1}, c.7{r2}, index.10{r3}] -> bool
        call _revealNeighbors@u8@u8@i16
        ; branch t.61.1{r0} notequals 0: if_45_then
        cmp al, 0
        jne if_45_then
        ; addrof memVarAddr{r7}, changed.7
        lea r12, [rsp+52]
        ; load changed.7{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; addrof memVarAddr{r7}, c.7
        lea r12, [rsp+55]
        ; load c.7{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move c.4{r1}, c.7{r2}
        mov cl, dl
        jmp while_40
if_45_then:
        ; addrof memVarAddr{r7}, c.7
        lea r12, [rsp+55]
        ; load c.7{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; const changed.10{r0}, 1
        mov al, 1
        ; move c.4{r1}, c.7{r2}
        mov cl, dl
while_40:
        ; branch c.4{r1} notequals 0: if_41_end
        cmp cl, 0
        jne if_41_end
        ; addrof memVarAddr{r7}, r.7
        lea r12, [rsp+51]
        ; load r.7{r1}, [memVarAddr{r7}]
        mov cl, [r12]
while_38:
        ; branch r.5{r1} notequals 0: if_39_end
        cmp cl, 0
        jne if_39_end
        ; move changed.2{r6}, changed.6{r0}
        mov bl, al
while_30:
        ; branch changed.2{r6} notequals 0: while_30_body, _maybeRevealAround@u8@u8_ret
        cmp bl, 0
        jne while_30_body
_maybeRevealAround@u8@u8_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void _pushReveal@u8@u8@i16
        ;   rsp+16: arg row
        ;   rsp+24: arg column
        ;   rsp+32: arg index
_pushReveal@u8@u8@i16:
        sub rsp, 8
        ; addrof a.4.1{r0}, revealStackSize
        lea rax, [var_6]
        ; load stackSize.1{r0}, [a.4.1{r0}]
        mov al, [rax]
        ; 345:2 if stackSize >= 16
        ; branch stackSize.1{r0} gteq 16: if_46_then
        cmp al, 16
        jae if_46_then
        ; cast t.8.1{r4}(i64), stackSize.1{r0}(u8)
        movzx r9, al
        ; addrof t.7.1{r5}, revealStackRows
        lea r10, [var_2]
        ; add t.7.2{r5}, t.8.1{r4}
        add r10, r9
        ; store [t.7.2{r5}], row{r1}
        mov [r10], cl
        ; move t.10.1{r1}, t.10.1{r4}
        mov rcx, r9
        ; addrof t.9.1{r4}, revealStackColumns
        lea r9, [var_3]
        ; add t.9.2{r4}, t.10.1{r1}
        add r9, rcx
        ; store [t.9.2{r4}], column{r2}
        mov [r9], dl
        ; addrof a.11.1{r1}, revealStackIndexTop
        lea rcx, [var_5]
        ; load t.12.1{r1}, [a.11.1{r1}]
        mov rcx, [rcx]
        ; store [t.12.1{r1}], index{r3}
        mov [rcx], r8w
        ; addrof a.14.1{r1}, revealStackIndexTop
        lea rcx, [var_5]
        ; load t.15.1{r1}, [a.14.1{r1}]
        mov rcx, [rcx]
        ; add t.13.1{r1}, 2
        add rcx, 2
        ; addrof a.16.1{r2}, revealStackIndexTop
        lea rdx, [var_5]
        ; store [a.16.1{r2}], t.13.1{r1}
        mov [rdx], rcx
        ; add t.17.1{r0}, 1
        add al, 1
        ; addrof a.18.1{r1}, revealStackSize
        lea rcx, [var_6]
        ; store [a.18.1{r1}], t.17.1{r0}
        mov [rcx], al
        jmp _pushReveal@u8@u8@i16_ret
if_46_then:
        ; const t.5.1{r0}, 255
        mov al, 255
        ; addrof a.6.1{r1}, revealStackSize
        lea rcx, [var_6]
        ; store [a.6.1{r1}], t.5.1{r0}
        mov [rcx], al
        ; 347:3 return
_pushReveal@u8@u8@i16_ret:
        add rsp, 8
        ret

        ; bool _revealNeighbors@u8@u8@i16
        ;   rsp+80: arg row
        ;   rsp+88: arg column
        ;   rsp+96: arg index
        ;   rsp+48: var colFrom.2
        ;   rsp+49: var colTo.2
        ;   rsp+50: var r.2
        ;   rsp+52: var index.8
        ;   rsp+54: var c.2
        ;   rsp+55: var changed.4
        ;   rsp+56: var cell.2
        ;   rsp+57: var changed.5
_revealNeighbors@u8@u8@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move rowFrom.1{r0}, row{r1}
        mov al, cl
        ; 359:2 if rowFrom > 0
        ; branch rowFrom.1{r0} lteq 0: if_47_end
        cmp al, 0
        jbe if_47_end
        ; sub rowFrom.3{r0}, 1
        sub al, 1
        ; sub index.2{r3}, 40
        sub r8w, 40
if_47_end:
        ; add rowTo.1{r1}, 1
        add cl, 1
        ; 364:2 if rowTo >= 20
        ; branch rowTo.1{r1} gteq 20: if_48_then
        cmp cl, 20
        jae if_48_then
        ; move rowTo.2{r6}, rowTo.1{r1}
        mov bl, cl
        jmp if_48_end
if_48_then:
        ; sub rowTo.3{r1}, 1
        sub cl, 1
        ; move rowTo.2{r6}, rowTo.3{r1}
        mov bl, cl
if_48_end:
        ; move colFrom.1{r1}, column{r2}
        mov cl, dl
        ; 369:2 if colFrom > 0
        ; branch colFrom.1{r1} lteq 0: if_49_end
        cmp cl, 0
        jbe if_49_end
        ; sub colFrom.3{r1}, 1
        sub cl, 1
        ; sub index.5{r3}, 1
        sub r8w, 1
if_49_end:
        ; add colTo.1{r2}, 1
        add dl, 1
        ; 374:2 if colTo >= 40
        ; branch colTo.1{r2} gteq 40: if_50_then
        cmp dl, 40
        jae if_50_then
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], colTo.2{r2}
        mov [r12], dl
        jmp if_50_end
if_50_then:
        ; sub colTo.3{r2}, 1
        sub dl, 1
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], colTo.2{r2}
        mov [r12], dl
if_50_end:
        ; const changed.1{r2}, 0
        mov dl, 0
        ; 378:2 for r <= rowTo
        ; move r.2{r4}, r.2{r0}
        mov r9b, al
        ; move changed.2{r0}, changed.2{r2}
        mov al, dl
        ; move index.7{r2}, index.7{r3}
        mov dx, r8w
        ; move colFrom.2{r3}, colFrom.2{r1}
        mov r8b, cl
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+49]
        ; load colTo.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp for_51
for_51_body:
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], colTo.2{r1}
        mov [r12], cl
        ; move colFrom.2{r1}, colFrom.2{r3}
        mov cl, r8b
        ; move index.7{r3}, index.7{r2}
        mov r8w, dx
        ; move changed.2{r2}, changed.2{r0}
        mov dl, al
        ; move r.2{r0}, r.2{r4}
        mov al, r9b
        ; move c.1{r4}, colFrom.2{r1}
        mov r9b, cl
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], colFrom.2{r1}
        mov [r12], cl
        ; 379:3 for c <= colTo
        ; move changed.3{r1}, changed.2{r2}
        mov cl, dl
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], r.2{r0}
        mov [r12], al
        ; move changed.3{r0}, changed.3{r1}
        mov al, cl
        ; move index.8{r2}, index.8{r3}
        mov dx, r8w
        ; move c.2{r3}, c.2{r4}
        mov r8b, r9b
        jmp for_52
for_52_body:
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], colTo.2{r1}
        mov [r12], cl
        ; move c.2{r4}, c.2{r3}
        mov r9b, r8b
        ; move changed.3{r1}, changed.3{r0}
        mov cl, al
        ; move index.8{r3}, index.8{r2}
        mov r8w, dx
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+50]
        ; load r.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; cast t.12.1{r2}(i64), index.8{r3}(i16)
        movsx rdx, r8w
        ; addrof t.11.1{r5}, field
        lea r10, [var_1]
        ; add t.11.2{r5}, t.12.1{r2}
        add r10, rdx
        ; load cell.1{r2}, [t.11.2{r5}]
        mov dl, [r10]
        ; 381:4 if cell & 32 != 0
        ; move t.13.1{r5}, cell.1{r2}
        mov r10b, dl
        ; and t.13.1{r5}, 32
        and r10b, 32
        ; branch t.13.1{r5} equals 0: if_53_end
        cmp r10b, 0
        je if_53_end
        ; addrof memVarAddr{r7}, changed.4
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], changed.4{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], c.2{r4}
        mov [r12], r9b
        ; addrof memVarAddr{r7}, index.8
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], index.8{r3}
        mov [r12], r8w
        ; addrof memVarAddr{r7}, changed.4
        lea r12, [rsp+55]
        ; move changed.4{r0}, changed.4{r1}
        mov al, cl
        jmp for_52_continue
if_53_end:
        ; or cell.2{r2}, 32
        or dl, 32
        ; cast t.15.1{r1}(i64), index.8{r3}(i16)
        movsx rcx, r8w
        ; addrof memVarAddr{r7}, index.8
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], index.8{r3}
        mov [r12], r8w
        ; addrof t.14.1{r3}, field
        lea r8, [var_1]
        ; add t.14.2{r3}, t.15.1{r1}
        add r8, rcx
        ; store [t.14.2{r3}], cell.2{r2}
        mov [r8], dl
        ; move cell.2{r1}, cell.2{r2}
        mov cl, dl
        ; addrof memVarAddr{r7}, cell.2
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], cell.2{r2}
        mov [r12], dl
        ; move r.2{r2}, r.2{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], r.2{r0}
        mov [r12], al
        ; move c.2{r3}, c.2{r4}
        mov r8b, r9b
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], c.2{r4}
        mov [r12], r9b
        ; call _printCellAt@u8@u8@u8[cell.2{r1}, r.2{r2}, c.2{r3}]
        call _printCellAt@u8@u8@u8
        ; const changed.5{r0}, 1
        mov al, 1
        ; 389:4 if cell & 143 == 0 && revealStackSize != 255
        ; addrof memVarAddr{r7}, cell.2
        lea r12, [rsp+56]
        ; load cell.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; and t.16.1{r1}, 143
        and cl, 143
        ; branch t.16.1{r1} notequals 0: for_52_continue
        cmp cl, 0
        jne for_52_continue
        ; addrof a.17.1{r1}, revealStackSize
        lea rcx, [var_6]
        ; load t.18.1{r1}, [a.17.1{r1}]
        mov cl, [rcx]
        ; branch t.18.1{r1} notequals 255: if_54_then
        cmp cl, 255
        jne if_54_then
        ; addrof memVarAddr{r7}, changed.4
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], changed.4{r0}
        mov [r12], al
        jmp for_52_continue
if_54_then:
        ; addrof memVarAddr{r7}, changed.5
        lea r12, [rsp+57]
        ; store [memVarAddr{r7}], changed.5{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+50]
        ; load r.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move r.2{r1}, r.2{r2}
        mov cl, dl
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+54]
        ; load c.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; move c.2{r2}, c.2{r3}
        mov dl, r8b
        ; addrof memVarAddr{r7}, index.8
        lea r12, [rsp+52]
        ; load index.8{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move index.8{r3}, index.8{r0}
        mov r8w, ax
        ; call _pushReveal@u8@u8@i16[r.2{r1}, c.2{r2}, index.8{r3}]
        call _pushReveal@u8@u8@i16
        ; addrof memVarAddr{r7}, changed.5
        lea r12, [rsp+57]
        ; load changed.5{r0}, [memVarAddr{r7}]
        mov al, [r12]
for_52_continue:
        ; addrof memVarAddr{r7}, c.2
        lea r12, [rsp+54]
        ; load c.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; move c.4{r1}, c.2{r3}
        mov cl, r8b
        ; add c.4{r1}, 1
        add cl, 1
        ; addrof memVarAddr{r7}, index.8
        lea r12, [rsp+52]
        ; load index.8{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; add index.11{r2}, 1
        add dx, 1
        ; move c.2{r3}, c.4{r1}
        mov r8b, cl
for_52:
        ; addrof memVarAddr{r7}, colTo.2
        lea r12, [rsp+49]
        ; load colTo.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch c.2{r3} lteq colTo.2{r1}: for_52_body
        cmp r8b, cl
        jbe for_52_body
        ; cast t.22.1{r3}(i16), colTo.2{r1}(u8)
        movzx r8w, cl
        ; sub t.21.1{r2}, t.22.1{r3}
        sub dx, r8w
        ; addrof memVarAddr{r7}, colFrom.2
        lea r12, [rsp+48]
        ; load colFrom.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; cast t.23.1{r4}(i16), colFrom.2{r3}(u8)
        movzx r9w, r8b
        ; add t.20.1{r2}, t.23.1{r4}
        add dx, r9w
        ; add t.19.1{r2}, 40
        add dx, 40
        ; sub index.9{r2}, 1
        sub dx, 1
        ; addrof memVarAddr{r7}, r.2
        lea r12, [rsp+50]
        ; load r.2{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; add r.4{r4}, 1
        add r9b, 1
for_51:
        ; branch r.2{r4} lteq rowTo.2{r6}: for_51_body
        cmp r9b, bl
        jbe for_51_body
        ; 395:9 return changed
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void _main
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
        ; const t.8.1{r0}, 0
        mov eax, 0
        ; addrof a.9.1{r1}, __random__
        lea rcx, [var_0]
        ; store [a.9.1{r1}], t.8.1{r0}
        mov [rcx], eax
        ; const t.10.1{r0}, 0
        mov rax, 0
        ; addrof a.11.1{r1}, revealStackIndexTop
        lea rcx, [var_5]
        ; store [a.11.1{r1}], t.10.1{r0}
        mov [rcx], rax
        ; const t.12.1{r0}, 0
        mov al, 0
        ; addrof a.13.1{r1}, revealStackSize
        lea rcx, [var_6]
        ; store [a.13.1{r1}], t.12.1{r0}
        mov [rcx], al
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov ecx, 7439742
        ; call _initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; call _clearField[]
        call _clearField
        ; call _initializeScreen[]
        call _initializeScreen
        ; const arg.3.0{r1}, 20
        mov cx, 20
        ; const arg.3.1{r2}, 0
        mov dx, 0
        ; call _setCursor@i16@i16[arg.3.0{r1}, arg.3.1{r2}]
        call _setCursor@i16@i16
        ; const col.1{r0}, 20
        mov al, 20
        ; const row.1{r1}, 10
        mov cl, 10
        ; const bombsLeft.1{r2}, -1
        mov dx, -1
        ; 407:2 while true
        ; move col.2{r6}, col.1{r0}
        mov bl, al
        ; move row.2{r0}, row.1{r1}
        mov al, cl
        ; move bombsLeft.2{r1}, bombsLeft.1{r2}
        mov cx, dx
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, cx
        jmp while_56
if_57_end:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; const t.15.1{r3}, 1
        mov r8b, 1
        ; move row.2{r1}, row.2{r0}
        mov cl, al
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call _showCursor@u8@u8@bool[row.2{r1}, col.2{r2}, t.15.1{r3}]
        call _showCursor@u8@u8@bool
        ; call chr.1{r0} = _getChar[] -> i16
        call _getChar
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], chr.1{r0}
        mov [r12], ax
        ; const t.16.1{r3}, 0
        mov r8b, 0
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move row.2{r1}, row.2{r0}
        mov cl, al
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call _showCursor@u8@u8@bool[row.2{r1}, col.2{r2}, t.16.1{r3}]
        call _showCursor@u8@u8@bool
        ; 416:3 if chr == 27
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+52]
        ; load chr.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; branch chr.1{r0} equals 27: _main_ret
        cmp ax, 27
        je _main_ret
        ; branch chr.1{r0} equals 13: if_59_then
        cmp ax, 13
        je if_59_then
        ; branch chr.1{r0} notequals -8120: if_63_else, if_63_then
        cmp ax, -8120
        jne if_63_else
        jmp if_63_then
if_59_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; branch bombsLeft.2{r1} gteq 0: _main.no_critical_edge_42, if_60_then
        cmp cx, 0
        jge _main.no_critical_edge_42
        jmp if_60_then
if_63_else:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; branch chr.1{r0} notequals -8112: if_65_else, if_65_then
        cmp ax, -8112
        jne if_65_else
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], chr.1{r0}
        mov [r12], ax
        jmp if_65_then
if_63_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; branch row.2{r0} lteq 0: _main.no_critical_edge_41, if_64_then
        cmp al, 0
        jbe _main.no_critical_edge_41
        jmp if_64_then
_main.no_critical_edge_42:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; addrof memVarAddr{r7}, bombsLeft.3
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], bombsLeft.3{r1}
        mov [r12], cx
        jmp if_60_end
if_60_then:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move row.2{r1}, row.2{r0}
        mov cl, al
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call bombsLeft.4{r0} = _initField@u8@u8[row.2{r1}, col.2{r2}] -> i16
        call _initField@u8@u8
        ; addrof memVarAddr{r7}, bombsLeft.3
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], bombsLeft.3{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        jmp if_60_end
if_65_else:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8117: if_67_else, if_67_then
        cmp ax, -8117
        jne if_67_else
        jmp if_67_then
if_65_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; branch row.2{r0} gteq 19: _main.no_critical_edge_40, if_66_then
        cmp al, 19
        jae _main.no_critical_edge_40
        jmp if_66_then
_main.no_critical_edge_41:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r0}
        mov [r12], al
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, cx
        jmp while_56
if_64_then:
        ; sub row.4{r0}, 1
        sub al, 1
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, cx
        jmp while_56
if_60_end:
        ; move row.2{r1}, row.2{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r0}
        mov [r12], al
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call index.1{r0} = _rowColumnToCell@u8@u8[row.2{r1}, col.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.18.1{r1}(i64), index.1{r0}(i16)
        movsx rcx, ax
        ; addrof t.17.1{r2}, field
        lea rdx, [var_1]
        ; add t.17.2{r2}, t.18.1{r1}
        add rdx, rcx
        ; load cell.1{r1}, [t.17.2{r2}]
        mov cl, [rdx]
        ; 426:4 if cell & 32 == 0
        ; move t.19.1{r2}, cell.1{r1}
        mov dl, cl
        ; and t.19.1{r2}, 32
        and dl, 32
        ; branch t.19.1{r2} notequals 0: _main.no_critical_edge_43, if_61_then
        cmp dl, 0
        jne _main.no_critical_edge_43
        jmp if_61_then
if_67_else:
        ; addrof memVarAddr{r7}, chr.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8115: if_69_else, if_69_then
        cmp ax, -8115
        jne if_69_else
        jmp if_69_then
if_67_then:
        ; branch col.2{r6} lteq 0: _main.no_critical_edge_39, if_68_then
        cmp bl, 0
        jbe _main.no_critical_edge_39
        jmp if_68_then
_main.no_critical_edge_40:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r0}
        mov [r12], al
        ; move row.2{r2}, row.2{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, cx
        jmp while_56
if_66_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; add row.5{r0}, 1
        add al, 1
        ; move row.2{r2}, row.5{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r2}
        mov [r12], dl
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, cx
        jmp while_56
_main.no_critical_edge_43:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        jmp if_61_end
if_61_then:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move t.20.1{r3}, cell.1{r1}
        mov r8b, cl
        ; or t.20.1{r3}, 32
        or r8b, 32
        ; cast t.22.1{r0}(i64), index.1{r0}(i16)
        movsx rax, ax
        ; addrof t.21.1{r4}, field
        lea r9, [var_1]
        ; add t.21.2{r4}, t.22.1{r0}
        add r9, rax
        ; store [t.21.2{r4}], t.20.1{r3}
        mov [r9], r8b
        jmp if_61_end
if_69_else:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; branch chr.1{r0} notequals 32: _main.no_critical_edge_34, if_71_then
        cmp ax, 32
        jne _main.no_critical_edge_34
        jmp if_71_then
if_69_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; branch col.2{r6} gteq 39: _main.no_critical_edge_38, if_70_then
        cmp bl, 39
        jae _main.no_critical_edge_38
        jmp if_70_then
_main.no_critical_edge_39:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, cx
        jmp while_56
if_68_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move col.5{r0}, col.2{r6}
        mov al, bl
        ; sub col.5{r0}, 1
        sub al, 1
        ; move col.2{r6}, col.5{r0}
        mov bl, al
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, cx
        jmp while_56
if_61_end:
        ; 429:4 if cell & 128 != 0
        ; move t.23.1{r0}, cell.1{r1}
        mov al, cl
        ; and t.23.1{r0}, 128
        and al, 128
        ; branch t.23.1{r0} equals 0: if_62_end, if_62_then
        cmp al, 0
        je if_62_end
        jmp if_62_then
_main.no_critical_edge_34:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r2}
        mov [r12], dl
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, cx
        jmp while_56
if_71_then:
        ; branch bombsLeft.2{r1} lt 0: _main.no_critical_edge_35, if_72_then
        cmp cx, 0
        jl _main.no_critical_edge_35
        jmp if_72_then
_main.no_critical_edge_38:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r2}
        mov [r12], dl
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, cx
        jmp while_56
if_70_then:
        ; move col.6{r0}, col.2{r6}
        mov al, bl
        ; add col.6{r0}, 1
        add al, 1
        ; move col.2{r6}, col.6{r0}
        mov bl, al
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, cx
        jmp while_56
if_62_end:
        ; move row.2{r1}, row.2{r2}
        mov cl, dl
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r2}
        mov [r12], dl
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call _maybeRevealAround@u8@u8[row.2{r1}, col.2{r2}]
        call _maybeRevealAround@u8@u8
        ; addrof memVarAddr{r7}, bombsLeft.3
        lea r12, [rsp+54]
        ; load bombsLeft.3{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, cx
        jmp while_56
_main.no_critical_edge_35:
        ; move row.2{r0}, row.2{r2}
        mov al, dl
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, cx
        jmp while_56
if_72_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombsLeft.2{r1}
        mov [r12], cx
        ; move row.2{r0}, row.2{r2}
        mov al, dl
        ; move row.2{r1}, row.2{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r0}
        mov [r12], al
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call index.2{r0} = _rowColumnToCell@u8@u8[row.2{r1}, col.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.26.1{r1}(i64), index.2{r0}(i16)
        movsx rcx, ax
        ; addrof t.25.1{r2}, field
        lea rdx, [var_1]
        ; add t.25.2{r2}, t.26.1{r1}
        add rdx, rcx
        ; load cell.3{r1}, [t.25.2{r2}]
        mov cl, [rdx]
        ; 465:5 if cell & 32 == 0
        ; move t.27.1{r2}, cell.3{r1}
        mov dl, cl
        ; and t.27.1{r2}, 32
        and dl, 32
        ; branch t.27.1{r2} equals 0: if_73_then
        cmp dl, 0
        je if_73_then
        ; load row.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; move bombsLeft.2{r0}, bombsLeft.2{r2}
        mov ax, dx
        jmp while_56
if_73_then:
        ; addrof memVarAddr{r7}, bombsLeft.2
        lea r12, [rsp+50]
        ; load bombsLeft.2{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; xor cell.4{r1}, 64
        xor cl, 64
        ; 467:6 if cell & 128 != 0
        ; move t.28.1{r4}, cell.4{r1}
        mov r9b, cl
        ; and t.28.1{r4}, 128
        and r9b, 128
        ; branch t.28.1{r4} notequals 0: if_74_then
        cmp r9b, 0
        jne if_74_then
        ; addrof memVarAddr{r7}, bombsLeft.6
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], bombsLeft.6{r2}
        mov [r12], dx
        jmp if_74_end
if_74_then:
        ; 468:7 if cell & 64 != 0
        ; move t.29.1{r4}, cell.4{r1}
        mov r9b, cl
        ; and t.29.1{r4}, 64
        and r9b, 64
        ; branch t.29.1{r4} notequals 0: if_75_then
        cmp r9b, 0
        jne if_75_then
        ; add bombsLeft.7{r2}, 1
        add dx, 1
        ; addrof memVarAddr{r7}, bombsLeft.6
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], bombsLeft.6{r2}
        mov [r12], dx
        jmp if_74_end
if_75_then:
        ; sub bombsLeft.8{r2}, 1
        sub dx, 1
        ; addrof memVarAddr{r7}, bombsLeft.6
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], bombsLeft.6{r2}
        mov [r12], dx
if_74_end:
        ; cast t.31.1{r0}(i64), index.2{r0}(i16)
        movsx rax, ax
        ; addrof t.30.1{r2}, field
        lea rdx, [var_1]
        ; add t.30.2{r2}, t.31.1{r0}
        add rdx, rax
        ; store [t.30.2{r2}], cell.4{r1}
        mov [rdx], cl
        ; move row.2{r2}, row.2{r3}
        mov dl, r8b
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r3}
        mov [r12], r8b
        ; move col.2{r3}, col.2{r6}
        mov r8b, bl
        ; call _printCellAt@u8@u8@u8[cell.4{r1}, row.2{r2}, col.2{r3}]
        call _printCellAt@u8@u8@u8
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, bombsLeft.6
        lea r12, [rsp+56]
        ; load bombsLeft.6{r0}, [memVarAddr{r7}]
        mov ax, [r12]
while_56:
        ; branch bombsLeft.2{r0} notequals 0: if_57_end
        cmp ax, 0
        jne if_57_end
        ; const t.14.1{r1}, [string-1]
        lea rcx, [string_1]
        ; call _printString@@u8[t.14.1{r1}]
        call _printString@@u8
        jmp _main_ret
if_62_then:
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r2}
        mov [r12], dl
        ; move row.2{r1}, row.2{r2}
        mov cl, dl
        ; move col.2{r2}, col.2{r6}
        mov dl, bl
        ; call _printCellAt@u8@u8[row.2{r1}, col.2{r2}]
        call _printCellAt@u8@u8
        ; const t.24.1{r1}, [string-2]
        lea rcx, [string_2]
        ; call _printString@@u8[t.24.1{r1}]
        call _printString@@u8
_main_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void _printStringLength@@u8@i64
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

        ; i16 _getChar
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

        ; void _setCursor@i16@i16
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
        ; variable 1: field[] (u8*/800)
        var_1 rb 800
        ; variable 2: revealStackRows[] (u8*/16)
        var_2 rb 16
        ; variable 3: revealStackColumns[] (u8*/16)
        var_3 rb 16
        ; variable 4: revealStackIndices[] (i16*/32)
        var_4 rb 32
        ; variable 5: revealStackIndexTop (i16*/8)
        var_5 rb 8
        ; variable 6: revealStackSize (u8/1)
        var_6 rb 1

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
