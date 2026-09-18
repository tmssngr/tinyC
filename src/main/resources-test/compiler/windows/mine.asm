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
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; call length{r0} = strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length{r2}, length{r0}
        mov rdx, rax
        ; call printStringLength@@u8@i64[str{r1}, length{r2}]
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
        ; addrof t.1{r1}, chr
        lea rcx, [rsp+64]
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1{r1}, arg.0.1{r2}]
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
        ; cast t.1{r1}(i64), number{r1}(i16)
        movsx rcx, cx
        ; call printUint@i64[t.1{r1}]
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
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; const pos{r3}, 20
        mov r8b, 20
        ; 33:2 while true
_while_1:
        ; sub pos{r3}, pos{r3}, 1
        sub r8b, 1
        ; move remainder{r4}, number{r6}
        mov r9, rbx
        ; move remainder{r0}, remainder{r4}
        mov rax, r9
        ; mod remainder{r2}, remainder{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder{r4}, remainder{r2}
        mov r9, rdx
        ; move number{r0}, number{r6}
        mov rax, rbx
        ; div number{r0}, number{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number{r6}, number{r0}
        mov rbx, rax
        ; cast t.5{r0}(u8), remainder{r4}(i64)
        mov al, r9b
        ; add digit{r0}, digit{r0}, 48
        add al, 48
        ; cast t.7{r4}(i64), pos{r3}(u8)
        movzx r9, r8b
        ; addrof t.6{r5}, [buffer]
        lea r10, [rsp+40]
        ; add t.6{r5}, t.6{r5}, t.7{r4}
        add r10, r9
        ; store [t.6{r5}], digit{r0}
        mov [r10], al
        ; 39:3 if number == 0
        ; branch number{r6} notequals 0: while_1, while_1_break
        cmp rbx, 0
        jne _while_1
        ; cast t.9{r6}(i64), pos{r3}(u8)
        movzx rbx, r8b
        ; addrof t.8{r1}, [buffer]
        lea rcx, [rsp+40]
        ; add t.8{r1}, t.8{r1}, t.9{r6}
        add rcx, rbx
        ; const t.11{r6}, 20
        mov bl, 20
        ; move t.10{r2}, t.11{r6}
        mov dl, bl
        ; sub t.10{r2}, t.10{r2}, pos{r3}
        sub dl, r8b
        ; call printStringLength@@u8@u8[t.8{r1}, t.10{r2}]
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
        ; const length{r0}, 0
        mov rax, 0
        ; 69:2 for *str != 0
        jmp _for_3
_for_3_body:
        ; add length{r0}, length{r0}, 1
        add rax, 1
        ; add str{r1}, str{r1}, 1
        add rcx, 1
_for_3:
        ; load t.2{r2}, [str{r1}]
        mov dl, [rcx]
        ; branch t.2{r2} notequals 0: for_3_body, for_3_break
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
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void initRandom@i32
        ;   rsp+16: arg salt
_initRandom@i32:
        sub rsp, 8
        ; move t.__random__{r0}, salt{r1}
        mov eax, ecx
        ; addrof a.__random__{r1}, __random__
        lea rcx, [var_0]
        ; store [a.__random__{r1}], t.__random__{r0}
        mov [rcx], eax
        add rsp, 8
        ret

        ; i32 random
_random:
        sub rsp, 8
        ; addrof a.__random__{r1}, __random__
        lea rcx, [var_0]
        ; load t.__random__{r1}, [a.__random__{r1}]
        mov ecx, [rcx]
        ; move t.5{r2}, r{r1}
        mov edx, ecx
        ; and t.5{r2}, t.5{r2}, 524287
        and edx, 524287
        ; mul b{r2}, b{r2}, 48271
        movsxd rdx, edx
        imul  rdx, 48271
        ; shiftright t.6{r1}, t.6{r1}, 15
        sar ecx, 15
        ; mul c{r1}, c{r1}, 48271
        movsxd rcx, ecx
        imul  rcx, 48271
        ; move t.7{r3}, c{r1}
        mov r8d, ecx
        ; and t.7{r3}, t.7{r3}, 65535
        and r8d, 65535
        ; shiftleft d{r3}, d{r3}, 15
        sal r8d, 15
        ; shiftright t.9{r1}, t.9{r1}, 16
        sar ecx, 16
        ; add t.8{r1}, t.8{r1}, b{r2}
        add ecx, edx
        ; add e{r1}, e{r1}, d{r3}
        add ecx, r8d
        ; move t.10{r2}, e{r1}
        mov edx, ecx
        ; and t.10{r2}, t.10{r2}, 2147483647
        and edx, 2147483647
        ; shiftright t.11{r1}, t.11{r1}, 31
        sar ecx, 31
        ; add t.__random__1{r2}, t.__random__1{r2}, t.11{r1}
        add edx, ecx
        ; addrof a.__random__1{r1}, __random__
        lea rcx, [var_0]
        ; store [a.__random__1{r1}], t.__random__1{r2}
        mov [rcx], edx
        ; 16:9 return __random__
        ; addrof a.__random__2{r1}, __random__
        lea rcx, [var_0]
        ; load t.__random__2{r0}, [a.__random__2{r1}]
        mov eax, [rcx]
        add rsp, 8
        ret

        ; i16 random16
_random16:
        sub rsp, 8
        sub rsp, 32
        ; 20:23 return (i16) & 32767
        ; call t.2{r0} = random[] -> i32
        call _random
        ; cast t.1{r1}(i16), t.2{r0}(i32)
        mov cx, ax
        ; move t.0{r0}, t.1{r1}
        mov ax, cx
        ; and t.0{r0}, t.0{r0}, 32767
        and ax, 32767
        add rsp, 32
        add rsp, 8
        ret

        ; i16 rowColumnToCell@u8@u8
        ;   rsp+16: arg row
        ;   rsp+24: arg column
_rowColumnToCell@u8@u8:
        sub rsp, 8
        ; cast r{r1}(i16), row{r1}(u8)
        movzx cx, cl
        ; cast c{r2}(i16), column{r2}(u8)
        movzx dx, dl
        ; 18:19 return r * 17 + c
        ; mul t.5{r1}, t.5{r1}, 17
        movsx rcx, cx
        imul  rcx, 17
        ; move t.4{r0}, t.5{r1}
        mov ax, cx
        ; add t.4{r0}, t.4{r0}, c{r2}
        add ax, dx
        add rsp, 8
        ret

        ; u8 getBombCountAround@u8@u8
        ;   rsp+64: arg row
        ;   rsp+72: arg column
        ;   rsp+48: var rowFrom
        ;   rsp+49: var rowTo
        ;   rsp+50: var colFrom
        ;   rsp+51: var colTo
        ;   rsp+52: var count
_getBombCountAround@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move row{r6}, row{r1}
        mov bl, cl
        ; move rowFrom{r1}, row{r6}
        mov cl, bl
        ; 23:2 if rowFrom > 0
        ; branch rowFrom{r1} lteq 0: if_4_end, if_4_then
        cmp cl, 0
        jbe _if_4_end
        ; move rowFrom{r1}, row{r6}
        mov cl, bl
        ; sub rowFrom{r1}, rowFrom{r1}, 1
        sub cl, 1
_if_4_end:
        ; move rowTo{r0}, row{r6}
        mov al, bl
        ; add rowTo{r0}, rowTo{r0}, 1
        add al, 1
        ; 27:2 if rowTo >= 20
        ; branch rowTo{r0} gteq 20: if_5_then, getBombCountAround@u8@u8.no_critical_edge_22
        cmp al, 20
        jae _if_5_then
        ; addrof memVarAddr{r7}, rowTo
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], rowTo{r0}
        mov [r12], al
        jmp _if_5_end
_if_5_then:
        ; sub rowTo{r0}, rowTo{r0}, 1
        sub al, 1
        ; addrof memVarAddr{r7}, rowTo
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], rowTo{r0}
        mov [r12], al
_if_5_end:
        ; move colFrom{r0}, column{r2}
        mov al, dl
        ; 32:2 if colFrom > 0
        ; branch colFrom{r0} lteq 0: if_6_end, if_6_then
        cmp al, 0
        jbe _if_6_end
        ; sub colFrom{r0}, colFrom{r0}, 1
        sub al, 1
_if_6_end:
        ; move colTo{r3}, column{r2}
        mov r8b, dl
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dl
        ; add colTo{r3}, colTo{r3}, 1
        add r8b, 1
        ; 36:2 if colTo >= 17
        ; branch colTo{r3} gteq 17: if_7_then, getBombCountAround@u8@u8.no_critical_edge_24
        cmp r8b, 17
        jae _if_7_then
        ; addrof memVarAddr{r7}, colTo
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], colTo{r3}
        mov [r12], r8b
        jmp _if_7_end
_if_7_then:
        ; sub colTo{r3}, colTo{r3}, 1
        sub r8b, 1
        ; addrof memVarAddr{r7}, colTo
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], colTo{r3}
        mov [r12], r8b
_if_7_end:
        ; const count{r3}, 0
        mov r8b, 0
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], count{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, rowFrom
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], rowFrom{r1}
        mov [r12], cl
        ; move colFrom{r2}, colFrom{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, colFrom
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], colFrom{r0}
        mov [r12], al
        ; call index{r0} = rowColumnToCell@u8@u8[rowFrom{r1}, colFrom{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; addrof memVarAddr{r7}, rowFrom
        lea r12, [rsp+48]
        ; load rowFrom{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; 42:2 for r <= rowTo
        ; addrof memVarAddr{r7}, colFrom
        lea r12, [rsp+50]
        ; load colFrom{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, colTo
        lea r12, [rsp+51]
        ; load colTo{r5}, [memVarAddr{r7}]
        mov r10b, [r12]
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+52]
        ; load count{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        jmp _for_8
_for_8_body:
        ; addrof memVarAddr{r7}, colFrom
        lea r12, [rsp+50]
        ; load colFrom{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, colFrom
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], colFrom{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, colTo
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], colTo{r5}
        mov [r12], r10b
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], count{r4}
        mov [r12], r9b
        ; addrof memVarAddr{r7}, rowTo
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], rowTo{r3}
        mov [r12], r8b
        ; move c{r3}, colFrom{r2}
        mov r8b, dl
        ; 43:3 for c <= colTo
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+52]
        ; load count{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        jmp _for_9
_for_9_body:
        ; addrof memVarAddr{r7}, colTo
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], colTo{r5}
        mov [r12], r10b
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], count{r4}
        mov [r12], r9b
        ; branch r{r1} equals row{r6}: and_11, getBombCountAround@u8@u8.no_critical_edge_25
        cmp cl, bl
        je _and_11
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        jmp _if_10_end
_and_11:
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; branch c{r3} notequals column{r4}: if_10_end, getBombCountAround@u8@u8.no_critical_edge_27
        cmp r8b, r9b
        jne _if_10_end
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r4}
        mov [r12], r9b
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+52]
        ; load count{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        jmp _for_9_continue
_if_10_end:
        ; cast t.12{r5}(i64), index{r0}(i16)
        movsx r10, ax
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r4}
        mov [r12], r9b
        ; addrof t.11{r4}, [field]
        lea r9, [var_1]
        ; add t.11{r4}, t.11{r4}, t.12{r5}
        add r9, r10
        ; load cell{r4}, [t.11{r4}]
        mov r9b, [r9]
        ; 49:4 if cell & 1 != 0
        ; and t.13{r4}, t.13{r4}, 1
        and r9b, 1
        ; branch t.13{r4} notequals 0: if_12_then, getBombCountAround@u8@u8.no_critical_edge_26
        cmp r9b, 0
        jne _if_12_then
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+52]
        ; load count{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        jmp _for_9_continue
_if_12_then:
        ; addrof memVarAddr{r7}, count
        lea r12, [rsp+52]
        ; load count{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; add count{r4}, count{r4}, 1
        add r9b, 1
_for_9_continue:
        ; add c{r3}, c{r3}, 1
        add r8b, 1
        ; add index{r0}, index{r0}, 1
        add ax, 1
_for_9:
        ; addrof memVarAddr{r7}, colTo
        lea r12, [rsp+51]
        ; load colTo{r5}, [memVarAddr{r7}]
        mov r10b, [r12]
        ; branch c{r3} lteq colTo{r5}: for_9_body, for_9_break
        cmp r8b, r10b
        jbe _for_9_body
        ; cast t.17{r3}(i16), colTo{r5}(u8)
        movzx r8w, r10b
        ; sub t.16{r0}, t.16{r0}, t.17{r3}
        sub ax, r8w
        ; cast t.18{r3}(i16), colFrom{r2}(u8)
        movzx r8w, dl
        ; add t.15{r0}, t.15{r0}, t.18{r3}
        add ax, r8w
        ; move t.14{r3}, t.15{r0}
        mov r8w, ax
        ; add t.14{r3}, t.14{r3}, 17
        add r8w, 17
        ; move index{r0}, t.14{r3}
        mov ax, r8w
        ; sub index{r0}, index{r0}, 1
        sub ax, 1
        ; add r{r1}, r{r1}, 1
        add cl, 1
_for_8:
        ; addrof memVarAddr{r7}, rowTo
        lea r12, [rsp+49]
        ; load rowTo{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; branch r{r1} lteq rowTo{r3}: for_8_body, for_8_break
        cmp cl, r8b
        jbe _for_8_body
        ; 55:9 return count
        ; move count{r0}, count{r4}
        mov al, r9b
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
        ; cast c{r1}(i16), column{r1}(u8)
        movzx cx, cl
        ; 60:17 return c + 1 << 1
        ; add t.3{r1}, t.3{r1}, 1
        add cx, 1
        ; move t.2{r0}, t.3{r1}
        mov ax, cx
        ; shiftleft t.2{r0}, t.2{r0}, 1
        sal ax, 1
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
        ; move column{r7}, column{r2}
        mov r12b, dl
        ; move row{r1}, row{r6}
        mov cl, bl
        ; move column{r2}, column{r7}
        mov dl, r12b
        ; call t.5{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.4{r0}(i64), t.5{r0}(i16)
        movsx rax, ax
        ; addrof t.3{r4}, [field]
        lea r9, [var_1]
        ; add t.3{r4}, t.3{r4}, t.4{r0}
        add r9, rax
        ; load cell{r1}, [t.3{r4}]
        mov cl, [r9]
        ; move row{r2}, row{r6}
        mov dl, bl
        ; move column{r3}, column{r7}
        mov r8b, r12b
        ; call printCellAt@u8@u8@u8[cell{r1}, row{r2}, column{r3}]
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
        ; call x{r0} = columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+72]
        ; load row{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; cast t.4{r1}(i16), row{r2}(u8)
        movzx cx, dl
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], row{r2}
        mov [r12], dl
        ; move x{r2}, x{r0}
        mov dx, ax
        ; call setCursor@i16@i16[t.4{r1}, x{r2}]
        call _setCursor@i16@i16
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+72]
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
        ; const chr{r6}, 46
        mov bl, 46
        ; 76:2 if cell & 2 != 0
        ; move t.5{r7}, cell{r1}
        mov r12b, cl
        ; and t.5{r7}, t.5{r7}, 2
        and r12b, 2
        ; branch t.5{r7} notequals 0: if_13_then, if_13_else
        cmp r12b, 0
        jne _if_13_then
        ; 90:7 if cell & 4 != 0
        ; move t.7{r7}, cell{r1}
        mov r12b, cl
        ; and t.7{r7}, t.7{r7}, 4
        and r12b, 4
        ; branch t.7{r7} equals 0: if_13_end, if_16_then
        cmp r12b, 0
        je _if_13_end
        jmp _if_16_then
_if_13_then:
        ; 77:3 if cell & 1 != 0
        ; move t.6{r6}, cell{r1}
        mov bl, cl
        ; and t.6{r6}, t.6{r6}, 1
        and bl, 1
        ; branch t.6{r6} equals 0: if_14_else, if_14_then
        cmp bl, 0
        je _if_14_else
        jmp _if_14_then
_if_16_then:
        ; const chr{r6}, 35
        mov bl, 35
        jmp _if_13_end
_if_14_else:
        ; move row{r1}, row{r2}
        mov cl, dl
        ; move column{r2}, column{r3}
        mov dl, r8b
        ; call count{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; 82:4 if count > 0
        ; branch count{r0} lteq 0: if_15_else, if_15_then
        cmp al, 0
        jbe _if_15_else
        jmp _if_15_then
_if_14_then:
        ; const chr{r6}, 42
        mov bl, 42
        jmp _if_13_end
_if_15_else:
        ; const chr{r6}, 32
        mov bl, 32
        jmp _if_13_end
_if_15_then:
        ; move chr{r6}, count{r0}
        mov bl, al
        ; add chr{r6}, chr{r6}, 48
        add bl, 48
_if_13_end:
        ; move chr{r1}, chr{r6}
        mov cl, bl
        ; call printChar@u8[chr{r1}]
        call _printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printField
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
        ; const row{r6}, 0
        mov bl, 0
        ; 98:2 for row < 20
        jmp _for_17
_for_17_body:
        ; const arg.1.0{r1}, 124
        mov cl, 124
        ; call printChar@u8[arg.1.0{r1}]
        call _printChar@u8
        ; const column{r7}, 0
        mov r12b, 0
        ; 100:3 for column < 17
        jmp _for_18
_for_18_body:
        ; const arg.2.0{r1}, 32
        mov cl, 32
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        ; move row{r1}, row{r6}
        mov cl, bl
        ; move column{r2}, column{r7}
        mov dl, r12b
        ; call t.5{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.4{r0}(i64), t.5{r0}(i16)
        movsx rax, ax
        ; addrof t.3{r4}, [field]
        lea r9, [var_1]
        ; add t.3{r4}, t.3{r4}, t.4{r0}
        add r9, rax
        ; load cell{r1}, [t.3{r4}]
        mov cl, [r9]
        ; move row{r2}, row{r6}
        mov dl, bl
        ; move column{r3}, column{r7}
        mov r8b, r12b
        ; call printCell@u8@u8@u8[cell{r1}, row{r2}, column{r3}]
        call _printCell@u8@u8@u8
        ; add column{r7}, column{r7}, 1
        add r12b, 1
_for_18:
        ; branch column{r7} lt 17: for_18_body, for_18_break
        cmp r12b, 17
        jb _for_18_body
        ; const t.6{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.6{r1}]
        call _printString@@u8
        ; add row{r6}, row{r6}, 1
        add bl, 1
_for_17:
        ; branch row{r6} lt 20: for_17_body, printField_ret
        cmp bl, 20
        jb _for_17_body
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
        ;   rsp+48: var x
        ;   rsp+50: var chr
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
        ; call x{r0} = columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; cast t.5{r1}(i16), row{r6}(u8)
        movzx cx, bl
        ; move t.6{r2}, x{r0}
        mov dx, ax
        ; addrof memVarAddr{r7}, x
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], x{r0}
        mov [r12], ax
        ; sub t.6{r2}, t.6{r2}, 1
        sub dx, 1
        ; call setCursor@i16@i16[t.5{r1}, t.6{r2}]
        call _setCursor@i16@i16
        ; const chr{r1}, 32
        mov cl, 32
        ; 113:2 if show
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; load show{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; branch show{r3} equals 0: showCursor@u8@u8@bool.no_critical_edge_6, if_19_then
        cmp r8b, 0
        je _showCursor@u8@u8@bool.no_critical_edge_6
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], show{r3}
        mov [r12], r8b
        jmp _if_19_then
_showCursor@u8@u8@bool.no_critical_edge_6:
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], show{r3}
        mov [r12], r8b
        jmp _if_19_end
_if_19_then:
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], show{r3}
        mov [r12], r8b
        ; const chr{r1}, 91
        mov cl, 91
_if_19_end:
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], chr{r1}
        mov [r12], cl
        ; call printChar@u8[chr{r1}]
        call _printChar@u8
        ; cast t.7{r1}(i16), row{r6}(u8)
        movzx cx, bl
        ; addrof memVarAddr{r7}, x
        lea r12, [rsp+48]
        ; load x{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.8{r2}, x{r0}
        mov dx, ax
        ; add t.8{r2}, t.8{r2}, 1
        add dx, 1
        ; call setCursor@i16@i16[t.7{r1}, t.8{r2}]
        call _setCursor@i16@i16
        ; 119:2 if show
        ; addrof memVarAddr{r7}, show
        lea r12, [rsp+80]
        ; load show{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; branch show{r3} notequals 0: if_20_then, showCursor@u8@u8@bool.no_critical_edge_7
        cmp r8b, 0
        jne _if_20_then
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+50]
        ; load chr{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp _if_20_end
_if_20_then:
        ; const chr{r1}, 93
        mov cl, 93
_if_20_end:
        ; call printChar@u8[chr{r1}]
        call _printChar@u8
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
        ; move i{r6}, i{r1}
        mov bx, cx
        ; 126:2 for i > 0
        jmp _for_21
_for_21_body:
        ; const arg.0.0{r1}, 48
        mov cl, 48
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; sub i{r6}, i{r6}, 1
        sub bx, 1
_for_21:
        ; branch i{r6} gt 0: for_21_body, printSpaces@i16_ret
        cmp bx, 0
        jg _for_21_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; u8 getDigitCount@i16
        ;   rsp+16: arg value
_getDigitCount@i16:
        sub rsp, 8
        ; move value{r3}, value{r1}
        mov r8w, cx
        ; const count{r4}, 0
        mov r9b, 0
        ; 133:2 if value < 0
        ; branch value{r3} gteq 0: while_23, if_22_then
        cmp r8w, 0
        jge _while_23
        ; const count{r4}, 1
        mov r9b, 1
        ; neg value{r3}, value{r3}
        neg r8
_while_23:
        ; add count{r4}, count{r4}, 1
        add r9b, 1
        ; move value{r0}, value{r3}
        mov ax, r8w
        ; div value{r0}, value{r0}, 10
        movsx rax, ax
        cqo
        mov rcx, 10
        idiv rcx
        ; move value{r3}, value{r0}
        mov r8w, ax
        ; 141:3 if value == 0
        ; branch value{r3} notequals 0: while_23, while_23_break
        cmp r8w, 0
        jne _while_23
        ; 146:9 return count
        ; move count{r0}, count{r4}
        mov al, r9b
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+48: var r
        ;   rsp+49: var c
_getHiddenCount:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const count{r6}, 0
        mov bx, 0
        ; const r{r1}, 0
        mov cl, 0
        ; 151:2 for r < 20
        jmp _for_25
_for_25_body:
        ; const c{r2}, 0
        mov dl, 0
        ; 152:3 for c < 17
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r{r1}
        mov [r12], cl
        jmp _for_26
_for_26_body:
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+48]
        ; load r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], r{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], c{r2}
        mov [r12], dl
        ; call t.6{r0} = rowColumnToCell@u8@u8[r{r1}, c{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.5{r1}(i64), t.6{r0}(i16)
        movsx rcx, ax
        ; addrof t.4{r2}, [field]
        lea rdx, [var_1]
        ; add t.4{r2}, t.4{r2}, t.5{r1}
        add rdx, rcx
        ; load cell{r1}, [t.4{r2}]
        mov cl, [rdx]
        ; 154:4 if cell & 6 == 0
        ; and t.7{r1}, t.7{r1}, 6
        and cl, 6
        ; branch t.7{r1} notequals 0: for_26_continue, if_27_then
        cmp cl, 0
        jne _for_26_continue
        ; add count{r6}, count{r6}, 1
        add bx, 1
_for_26_continue:
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+49]
        ; load c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; add c{r2}, c{r2}, 1
        add dl, 1
_for_26:
        ; branch c{r2} lt 17: for_26_body, for_25_continue
        cmp dl, 17
        jb _for_26_body
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+48]
        ; load r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; add r{r1}, r{r1}, 1
        add cl, 1
_for_25:
        ; branch r{r1} lt 20: for_25_body, for_25_break
        cmp cl, 20
        jb _for_25_body
        ; 159:9 return count
        ; move count{r0}, count{r6}
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
_printLeft:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; call count{r0} = getHiddenCount[] -> i16
        call _getHiddenCount
        ; move count{r6}, count{r0}
        mov bx, ax
        ; move count{r1}, count{r6}
        mov cx, bx
        ; call t.3{r0} = getDigitCount@i16[count{r1}] -> u8
        call _getDigitCount@i16
        ; cast leftDigits{r0}(i16), t.3{r0}(u8)
        movzx ax, al
        ; addrof memVarAddr{r7}, leftDigits
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], leftDigits{r0}
        mov [r12], ax
        ; const arg.2.0{r1}, 23
        mov cx, 23
        ; call t.4{r0} = getDigitCount@i16[arg.2.0{r1}] -> u8
        call _getDigitCount@i16
        ; cast bombDigits{r0}(i16), t.4{r0}(u8)
        movzx ax, al
        ; addrof memVarAddr{r7}, bombDigits
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombDigits{r0}
        mov [r12], ax
        ; const arg.3.0{r1}, 20
        mov cx, 20
        ; const arg.3.1{r2}, 6
        mov dx, 6
        ; call setCursor@i16@i16[arg.3.0{r1}, arg.3.1{r2}]
        call _setCursor@i16@i16
        ; addrof memVarAddr{r7}, bombDigits
        lea r12, [rsp+50]
        ; load bombDigits{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.5{r1}, bombDigits{r0}
        mov cx, ax
        ; addrof memVarAddr{r7}, leftDigits
        lea r12, [rsp+48]
        ; load leftDigits{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; sub t.5{r1}, t.5{r1}, leftDigits{r0}
        sub cx, ax
        ; call printSpaces@i16[t.5{r1}]
        call _printSpaces@i16
        ; move count{r1}, count{r6}
        mov cx, bx
        ; call printUint@i16[count{r1}]
        call _printUint@i16
        ; 170:15 return count == 0
        ; equals t.6{r0}, count{r6}, 0
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
        ; 174:2 if a < 0
        ; branch a{r1} lt 0: if_28_then, if_28_end
        cmp cx, 0
        jl _if_28_then
        ; 177:9 return a
        ; move a{r0}, a{r1}
        mov ax, cx
        jmp _abs@i16_ret
_if_28_then:
        ; 175:10 return -a
        ; neg t.1{r1}, a{r1}
        neg rcx
        ; move t.1{r0}, t.1{r1}
        mov ax, cx
_abs@i16_ret:
        add rsp, 8
        ret

        ; void clearField
_clearField:
        sub rsp, 8
        ; const index{r0}, 0
        mov ax, 0
        ; const i{r1}, 340
        mov cx, 340
        ; 182:2 for i > 0
        jmp _for_29
_for_29_body:
        ; const t.2{r2}, 0
        mov dl, 0
        ; cast t.4{r3}(i64), index{r0}(i16)
        movsx r8, ax
        ; addrof t.3{r4}, [field]
        lea r9, [var_1]
        ; add t.3{r4}, t.3{r4}, t.4{r3}
        add r9, r8
        ; store [t.3{r4}], t.2{r2}
        mov [r9], dl
        ; sub i{r1}, i{r1}, 1
        sub cx, 1
_for_29:
        ; branch i{r1} gt 0: for_29_body, clearField_ret
        cmp cx, 0
        jg _for_29_body
        add rsp, 8
        ret

        ; void initField@u8@u8
        ;   rsp+80: arg curr_r
        ;   rsp+88: arg curr_c
        ;   rsp+48: var c
        ;   rsp+50: var bombs
        ;   rsp+52: var row
        ;   rsp+54: var column
        ;   rsp+56: var t.13
_initField@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; cast r{r6}(i16), curr_r{r1}(u8)
        movzx bx, cl
        ; cast c{r0}(i16), curr_c{r2}(u8)
        movzx ax, dl
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], c{r0}
        mov [r12], ax
        ; const bombs{r0}, 23
        mov ax, 23
        ; addrof memVarAddr{r7}, bombs
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombs{r0}
        mov [r12], ax
        ; 190:2 for bombs > 0
        ; addrof memVarAddr{r7}, bombs
        lea r12, [rsp+50]
        ; load bombs{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        jmp _for_30
_for_30_body:
        ; addrof memVarAddr{r7}, bombs
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], bombs{r0}
        mov [r12], ax
        ; call t.7{r0} = random16[] -> i16
        call _random16
        ; move row{r3}, t.7{r0}
        mov r8w, ax
        ; move row{r0}, row{r3}
        mov ax, r8w
        ; mod row{r2}, row{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move row{r3}, row{r2}
        mov r8w, dx
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], row{r3}
        mov [r12], r8w
        ; call t.8{r0} = random16[] -> i16
        call _random16
        ; move column{r3}, t.8{r0}
        mov r8w, ax
        ; move column{r0}, column{r3}
        mov ax, r8w
        ; mod column{r2}, column{r0}, 17
        movsx rax, ax
        cqo
        mov rcx, 17
        idiv rcx
        ; move column{r3}, column{r2}
        mov r8w, dx
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], column{r3}
        mov [r12], r8w
        ; 193:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=5, scope=function, type=i16, varIsArray=false, location=193:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=193:20], location=193:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=6, scope=function, type=i16, varIsArray=false, location=194:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=194:20], location=194:18]]) > 1
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+52]
        ; load row{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.10{r1}, row{r0}
        mov cx, ax
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], row{r0}
        mov [r12], ax
        ; sub t.10{r1}, t.10{r1}, r{r6}
        sub cx, bx
        ; call t.9{r0} = abs@i16[t.10{r1}] -> i16
        call _abs@i16
        ; branch t.9{r0} gt 1: if_31_then, or_32
        cmp ax, 1
        jg _if_31_then
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+54]
        ; load column{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.12{r1}, column{r0}
        mov cx, ax
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], column{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+48]
        ; load c{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; sub t.12{r1}, t.12{r1}, c{r0}
        sub cx, ax
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], c{r0}
        mov [r12], ax
        ; call t.11{r0} = abs@i16[t.12{r1}] -> i16
        call _abs@i16
        ; branch t.11{r0} lteq 1: for_30_continue, if_31_then
        cmp ax, 1
        jle _for_30_continue
_if_31_then:
        ; const t.13{r0}, 1
        mov al, 1
        ; addrof memVarAddr{r7}, t.13
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], t.13{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, row
        lea r12, [rsp+52]
        ; load row{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; cast t.17{r1}(u8), row{r0}(i16)
        mov cl, al
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+54]
        ; load column{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; cast t.18{r2}(u8), column{r0}(i16)
        mov dl, al
        ; call t.16{r0} = rowColumnToCell@u8@u8[t.17{r1}, t.18{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.15{r0}(i64), t.16{r0}(i16)
        movsx rax, ax
        ; addrof t.14{r1}, [field]
        lea rcx, [var_1]
        ; add t.14{r1}, t.14{r1}, t.15{r0}
        add rcx, rax
        ; addrof memVarAddr{r7}, t.13
        lea r12, [rsp+56]
        ; load t.13{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; store [t.14{r1}], t.13{r0}
        mov [rcx], al
_for_30_continue:
        ; addrof memVarAddr{r7}, bombs
        lea r12, [rsp+50]
        ; load bombs{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; sub bombs{r0}, bombs{r0}, 1
        sub ax, 1
_for_30:
        ; branch bombs{r0} gt 0: for_30_body, initField@u8@u8_ret
        cmp ax, 0
        jg _for_30_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void maybeRevealAround@u8@u8
        ;   rsp+64: arg row
        ;   rsp+72: arg column
        ;   rsp+48: var rowFrom
        ;   rsp+49: var rowTo
        ;   rsp+50: var colFrom
        ;   rsp+51: var colTo
        ;   rsp+52: var index
        ;   rsp+54: var r
        ;   rsp+55: var c
_maybeRevealAround@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move row{r6}, row{r1}
        mov bl, cl
        ; move row{r1}, row{r6}
        mov cl, bl
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dl
        ; call printCellAt@u8@u8[row{r1}, column{r2}]
        call _printCellAt@u8@u8
        ; 202:2 if getBombCountAround@u8@u8([ExprVarAccess[varName=row, index=0, scope=parameter, type=u8, varIsArray=false, location=202:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=u8, varIsArray=false, location=202:30]]) != 0
        ; move row{r1}, row{r6}
        mov cl, bl
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dl
        ; call t.10{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; branch t.10{r0} notequals 0: maybeRevealAround@u8@u8_ret, if_33_end
        cmp al, 0
        jne _maybeRevealAround@u8@u8_ret
        ; move rowFrom{r1}, row{r6}
        mov cl, bl
        ; 207:2 if rowFrom > 0
        ; branch rowFrom{r1} lteq 0: if_34_end, if_34_then
        cmp cl, 0
        jbe _if_34_end
        ; move rowFrom{r1}, row{r6}
        mov cl, bl
        ; sub rowFrom{r1}, rowFrom{r1}, 1
        sub cl, 1
_if_34_end:
        ; move rowTo{r0}, row{r6}
        mov al, bl
        ; add rowTo{r0}, rowTo{r0}, 1
        add al, 1
        ; 211:2 if rowTo >= 20
        ; branch rowTo{r0} gteq 20: if_35_then, maybeRevealAround@u8@u8.no_critical_edge_23
        cmp al, 20
        jae _if_35_then
        ; addrof memVarAddr{r7}, rowTo
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], rowTo{r0}
        mov [r12], al
        jmp _if_35_end
_if_35_then:
        ; sub rowTo{r0}, rowTo{r0}, 1
        sub al, 1
        ; addrof memVarAddr{r7}, rowTo
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], rowTo{r0}
        mov [r12], al
_if_35_end:
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; move colFrom{r0}, column{r2}
        mov al, dl
        ; 216:2 if colFrom > 0
        ; branch colFrom{r0} lteq 0: if_36_end, if_36_then
        cmp al, 0
        jbe _if_36_end
        ; sub colFrom{r0}, colFrom{r0}, 1
        sub al, 1
_if_36_end:
        ; move colTo{r3}, column{r2}
        mov r8b, dl
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dl
        ; add colTo{r3}, colTo{r3}, 1
        add r8b, 1
        ; 220:2 if colTo >= 17
        ; branch colTo{r3} gteq 17: if_37_then, maybeRevealAround@u8@u8.no_critical_edge_25
        cmp r8b, 17
        jae _if_37_then
        ; addrof memVarAddr{r7}, colTo
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], colTo{r3}
        mov [r12], r8b
        jmp _if_37_end
_if_37_then:
        ; sub colTo{r3}, colTo{r3}, 1
        sub r8b, 1
        ; addrof memVarAddr{r7}, colTo
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], colTo{r3}
        mov [r12], r8b
_if_37_end:
        ; addrof memVarAddr{r7}, rowFrom
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], rowFrom{r1}
        mov [r12], cl
        ; move colFrom{r2}, colFrom{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, colFrom
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], colFrom{r0}
        mov [r12], al
        ; call index{r0} = rowColumnToCell@u8@u8[rowFrom{r1}, colFrom{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; addrof memVarAddr{r7}, rowFrom
        lea r12, [rsp+48]
        ; load rowFrom{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; 224:2 for r <= rowTo
        ; move r{r3}, r{r1}
        mov r8b, cl
        ; addrof memVarAddr{r7}, colFrom
        lea r12, [rsp+50]
        ; load colFrom{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, colTo
        lea r12, [rsp+51]
        ; load colTo{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp _for_38
_for_38_body:
        ; addrof memVarAddr{r7}, colFrom
        lea r12, [rsp+50]
        ; load colFrom{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, colFrom
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], colFrom{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, colTo
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], colTo{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, rowTo
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], rowTo{r4}
        mov [r12], r9b
        ; move r{r1}, r{r3}
        mov cl, r8b
        ; move c{r3}, colFrom{r2}
        mov r8b, dl
        ; addrof memVarAddr{r7}, colFrom
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], colFrom{r2}
        mov [r12], dl
        ; 225:3 for c <= colTo
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], r{r1}
        mov [r12], cl
        ; move c{r2}, c{r3}
        mov dl, r8b
        jmp _for_39
_for_39_body:
        ; addrof memVarAddr{r7}, colTo
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], colTo{r1}
        mov [r12], cl
        ; move c{r3}, c{r2}
        mov r8b, dl
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+54]
        ; load r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch r{r1} notequals row{r6}: if_40_end, and_41
        cmp cl, bl
        jne _if_40_end
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; branch c{r3} equals column{r2}: maybeRevealAround@u8@u8.no_critical_edge_29, maybeRevealAround@u8@u8.no_critical_edge_30
        cmp r8b, dl
        je _maybeRevealAround@u8@u8.no_critical_edge_29
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dl
        jmp _maybeRevealAround@u8@u8.no_critical_edge_30
_maybeRevealAround@u8@u8.no_critical_edge_29:
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], c{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, index
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], index{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], r{r1}
        mov [r12], cl
        jmp _for_39_continue
_maybeRevealAround@u8@u8.no_critical_edge_30:
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dl
_if_40_end:
        ; cast t.12{r4}(i64), index{r0}(i16)
        movsx r9, ax
        ; addrof t.11{r5}, [field]
        lea r10, [var_1]
        ; add t.11{r5}, t.11{r5}, t.12{r4}
        add r10, r9
        ; load cell{r4}, [t.11{r5}]
        mov r9b, [r10]
        ; 231:4 if cell & 2 != 0
        ; move t.13{r5}, cell{r4}
        mov r10b, r9b
        ; and t.13{r5}, t.13{r5}, 2
        and r10b, 2
        ; branch t.13{r5} equals 0: if_42_end, maybeRevealAround@u8@u8.no_critical_edge_28
        cmp r10b, 0
        je _if_42_end
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], c{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, index
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], index{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], r{r1}
        mov [r12], cl
        jmp _for_39_continue
_if_42_end:
        ; or t.14{r4}, t.14{r4}, 2
        or r9b, 2
        ; cast t.16{r5}(i64), index{r0}(i16)
        movsx r10, ax
        ; addrof memVarAddr{r7}, index
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], index{r0}
        mov [r12], ax
        ; addrof t.15{r0}, [field]
        lea rax, [var_1]
        ; add t.15{r0}, t.15{r0}, t.16{r5}
        add rax, r10
        ; store [t.15{r0}], t.14{r4}
        mov [rax], r9b
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], r{r1}
        mov [r12], cl
        ; move c{r2}, c{r3}
        mov dl, r8b
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], c{r3}
        mov [r12], r8b
        ; call maybeRevealAround@u8@u8[r{r1}, c{r2}]
        call _maybeRevealAround@u8@u8
_for_39_continue:
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+55]
        ; load c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; add c{r2}, c{r2}, 1
        add dl, 1
        ; addrof memVarAddr{r7}, index
        lea r12, [rsp+52]
        ; load index{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; add index{r0}, index{r0}, 1
        add ax, 1
_for_39:
        ; addrof memVarAddr{r7}, colTo
        lea r12, [rsp+51]
        ; load colTo{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch c{r2} lteq colTo{r1}: for_39_body, for_39_break
        cmp dl, cl
        jbe _for_39_body
        ; cast t.20{r2}(i16), colTo{r1}(u8)
        movzx dx, cl
        ; sub t.19{r0}, t.19{r0}, t.20{r2}
        sub ax, dx
        ; addrof memVarAddr{r7}, colFrom
        lea r12, [rsp+50]
        ; load colFrom{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; cast t.21{r3}(i16), colFrom{r2}(u8)
        movzx r8w, dl
        ; add t.18{r0}, t.18{r0}, t.21{r3}
        add ax, r8w
        ; add t.17{r0}, t.17{r0}, 17
        add ax, 17
        ; sub index{r0}, index{r0}, 1
        sub ax, 1
        ; addrof memVarAddr{r7}, r
        lea r12, [rsp+54]
        ; load r{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; add r{r3}, r{r3}, 1
        add r8b, 1
_for_38:
        ; addrof memVarAddr{r7}, rowTo
        lea r12, [rsp+49]
        ; load rowTo{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; branch r{r3} lteq rowTo{r4}: for_38_body, maybeRevealAround@u8@u8_ret
        cmp r8b, r9b
        jbe _for_38_body
_maybeRevealAround@u8@u8_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void main
        ;   rsp+48: var curr_c
        ;   rsp+49: var curr_r
        ;   rsp+50: var chr
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; const t.__random__{r6}, 0
        mov ebx, 0
        ; addrof a.__random__{r0}, __random__
        lea rax, [var_0]
        ; store [a.__random__{r0}], t.__random__{r6}
        mov [rax], ebx
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov ecx, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; const needsInitialize{r6}, 1
        mov bl, 1
        ; call clearField[]
        call _clearField
        ; call printField[]
        call _printField
        ; const arg.3.0{r1}, 20
        mov cx, 20
        ; const arg.3.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.3.0{r1}, arg.3.1{r2}]
        call _setCursor@i16@i16
        ; const t.8{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[t.8{r1}]
        call _printString@@u8
        ; const curr_c{r2}, 8
        mov dl, 8
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; const curr_r{r1}, 10
        mov cl, 10
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        ; 251:2 while true
        jmp _while_43
_if_44_then:
        ; 253:4 if printLeft([])
        ; call t.9{r0} = printLeft[] -> bool
        call _printLeft
        ; branch t.9{r0} notequals 0: if_45_then, if_44_end
        cmp al, 0
        jne _if_45_then
_if_44_end:
        ; const t.11{r3}, 1
        mov r8b, 1
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; call showCursor@u8@u8@bool[curr_r{r1}, curr_c{r2}, t.11{r3}]
        call _showCursor@u8@u8@bool
        ; call chr{r0} = getChar[] -> i16
        call _getChar
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], chr{r0}
        mov [r12], ax
        ; const t.12{r3}, 0
        mov r8b, 0
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; call showCursor@u8@u8@bool[curr_r{r1}, curr_c{r2}, t.12{r3}]
        call _showCursor@u8@u8@bool
        ; 262:3 if chr == 27
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+50]
        ; load chr{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; branch chr{r0} equals 27: main_ret, if_46_end
        cmp ax, 27
        je _main_ret
        ; branch chr{r0} equals 13: if_47_then, if_47_else
        cmp ax, 13
        je _if_47_then
        ; branch chr{r0} notequals -8120: if_51_else, if_51_then
        cmp ax, -8120
        jne _if_51_else
        jmp _if_51_then
_if_47_then:
        ; branch needsInitialize{r6} equals 0: main.no_critical_edge_39, if_48_then
        cmp bl, 0
        je _main.no_critical_edge_39
        jmp _if_48_then
_if_51_else:
        ; branch chr{r0} notequals -8112: if_53_else, if_53_then
        cmp ax, -8112
        jne _if_53_else
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], chr{r0}
        mov [r12], ax
        jmp _if_53_then
_if_51_then:
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch curr_r{r1} lteq 0: main.no_critical_edge_38, if_52_then
        cmp cl, 0
        jbe _main.no_critical_edge_38
        jmp _if_52_then
_main.no_critical_edge_39:
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp _if_48_end
_if_48_then:
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; const needsInitialize{r6}, 0
        mov bl, 0
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; call initField@u8@u8[curr_r{r1}, curr_c{r2}]
        call _initField@u8@u8
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp _if_48_end
_if_53_else:
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+50]
        ; load chr{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], chr{r0}
        mov [r12], ax
        ; branch chr{r0} notequals -8117: if_55_else, if_55_then
        cmp ax, -8117
        jne _if_55_else
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], chr{r0}
        mov [r12], ax
        jmp _if_55_then
_if_53_then:
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch curr_r{r1} gteq 19: main.no_critical_edge_37, if_54_then
        cmp cl, 19
        jae _main.no_critical_edge_37
        jmp _if_54_then
_main.no_critical_edge_38:
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        jmp _while_43
_if_52_then:
        ; sub curr_r{r1}, curr_r{r1}, 1
        sub cl, 1
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        jmp _while_43
_if_48_end:
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; call index{r0} = rowColumnToCell@u8@u8[curr_r{r1}, curr_c{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.14{r3}(i64), index{r0}(i16)
        movsx r8, ax
        ; addrof t.13{r4}, [field]
        lea r9, [var_1]
        ; add t.13{r4}, t.13{r4}, t.14{r3}
        add r9, r8
        ; load cell{r3}, [t.13{r4}]
        mov r8b, [r9]
        ; 273:4 if cell & 2 == 0
        ; move t.15{r4}, cell{r3}
        mov r9b, r8b
        ; and t.15{r4}, t.15{r4}, 2
        and r9b, 2
        ; branch t.15{r4} notequals 0: main.no_critical_edge_40, if_49_then
        cmp r9b, 0
        jne _main.no_critical_edge_40
        jmp _if_49_then
_if_55_else:
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+50]
        ; load chr{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], chr{r0}
        mov [r12], ax
        ; branch chr{r0} notequals -8115: if_57_else, if_57_then
        cmp ax, -8115
        jne _if_57_else
        jmp _if_57_then
_if_55_then:
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; branch curr_c{r2} lteq 0: main.no_critical_edge_36, if_56_then
        cmp dl, 0
        jbe _main.no_critical_edge_36
        jmp _if_56_then
_main.no_critical_edge_37:
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        jmp _while_43
_if_54_then:
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; add curr_r{r1}, curr_r{r1}, 1
        add cl, 1
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        jmp _while_43
_main.no_critical_edge_40:
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp _if_49_end
_if_49_then:
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; move t.16{r4}, cell{r3}
        mov r9b, r8b
        ; or t.16{r4}, t.16{r4}, 2
        or r9b, 2
        ; cast t.18{r0}(i64), index{r0}(i16)
        movsx rax, ax
        ; addrof t.17{r5}, [field]
        lea r10, [var_1]
        ; add t.17{r5}, t.17{r5}, t.18{r0}
        add r10, rax
        ; store [t.17{r5}], t.16{r4}
        mov [r10], r9b
        jmp _if_49_end
_if_57_else:
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch chr{r0} notequals 32: main.no_critical_edge_32, if_59_then
        cmp ax, 32
        jne _main.no_critical_edge_32
        jmp _if_59_then
_if_57_then:
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch curr_c{r2} gteq 16: main.no_critical_edge_35, if_58_then
        cmp dl, 16
        jae _main.no_critical_edge_35
        jmp _if_58_then
_main.no_critical_edge_36:
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        jmp _while_43
_if_56_then:
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; sub curr_c{r2}, curr_c{r2}, 1
        sub dl, 1
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        jmp _while_43
_if_49_end:
        ; 276:4 if cell & 1 != 0
        ; move t.19{r0}, cell{r3}
        mov al, r8b
        ; and t.19{r0}, t.19{r0}, 1
        and al, 1
        ; branch t.19{r0} equals 0: if_50_end, if_50_then
        cmp al, 0
        je _if_50_end
        jmp _if_50_then
_main.no_critical_edge_32:
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        jmp _while_43
_if_59_then:
        ; branch needsInitialize{r6} notequals 0: main.no_critical_edge_33, if_60_then
        cmp bl, 0
        jne _main.no_critical_edge_33
        jmp _if_60_then
_main.no_critical_edge_35:
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        jmp _while_43
_if_58_then:
        ; add curr_c{r2}, curr_c{r2}, 1
        add dl, 1
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        jmp _while_43
_if_50_end:
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; call maybeRevealAround@u8@u8[curr_r{r1}, curr_c{r2}]
        call _maybeRevealAround@u8@u8
        jmp _while_43
_main.no_critical_edge_33:
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        jmp _while_43
_if_60_then:
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; call index{r0} = rowColumnToCell@u8@u8[curr_r{r1}, curr_c{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.22{r4}(i64), index{r0}(i16)
        movsx r9, ax
        ; addrof t.21{r5}, [field]
        lea r10, [var_1]
        ; add t.21{r5}, t.21{r5}, t.22{r4}
        add r10, r9
        ; load cell{r1}, [t.21{r5}]
        mov cl, [r10]
        ; 312:5 if cell & 2 == 0
        ; move t.23{r4}, cell{r1}
        mov r9b, cl
        ; and t.23{r4}, t.23{r4}, 2
        and r9b, 2
        ; branch t.23{r4} notequals 0: while_43, if_61_then
        cmp r9b, 0
        jne _while_43
        ; xor cell{r1}, cell{r1}, 4
        xor cl, 4
        ; cast t.25{r0}(i64), index{r0}(i16)
        movsx rax, ax
        ; addrof t.24{r4}, [field]
        lea r9, [var_1]
        ; add t.24{r4}, t.24{r4}, t.25{r0}
        add r9, rax
        ; store [t.24{r4}], cell{r1}
        mov [r9], cl
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r3}
        mov [r12], r8b
        ; call printCellAt@u8@u8@u8[cell{r1}, curr_r{r2}, curr_c{r3}]
        call _printCellAt@u8@u8@u8
_while_43:
        ; branch needsInitialize{r6} notequals 0: if_44_end, if_44_then
        cmp bl, 0
        jne _if_44_end
        jmp _if_44_then
_if_45_then:
        ; const t.10{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString@@u8[t.10{r1}]
        call _printString@@u8
        jmp _main_ret
_if_50_then:
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; load curr_r{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], curr_c{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, curr_r
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], curr_r{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, curr_c
        lea r12, [rsp+48]
        ; load curr_c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; call printCellAt@u8@u8[curr_r{r1}, curr_c{r2}]
        call _printCellAt@u8@u8
        ; const t.20{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString@@u8[t.20{r1}]
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
        ; variable 1: field[] (u8*/2720)
        var_1 rb 2720

section '.data' data readable
        string_0 db ' |', 0x0a, 0x00
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
