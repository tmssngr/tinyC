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

        ; void printIntLf@bool
        ;   rsp+0: arg number
_printIntLf@bool:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(bool)
        movsx rdi, dil
        ; call printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 8
        ret

        ; void printIntLf@u8
        ;   rsp+0: arg number
_printIntLf@u8:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(u8)
        movzx rdi, dil
        ; call printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 8
        ret

        ; void printIntLf@i16
        ;   rsp+0: arg number
_printIntLf@i16:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(i16)
        movsx rdi, di
        ; call printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 8
        ret

        ; void printIntLf@i64
        ;   rsp+24: arg number
_printIntLf@i64:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move number{r8}, number{r1}
        mov rbx, rdi
        ; branch number{r8} gteq 0: printIntLf@i64.no_critical_edge_4
        cmp rbx, 0
        jge _printIntLf@i64.no_critical_edge_4
        ; const arg.0.0{r1}, 45
        mov dil, 45
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; neg number.2{r8}, number{r8}
        neg rbx
        ; move number.1{r1}, number.2{r8}
        mov rdi, rbx
        jmp _if_3_end
_printIntLf@i64.no_critical_edge_4:
        ; move number.1{r1}, number{r8}
        mov rdi, rbx
_if_3_end:
        ; call printUint@i64[number.1{r1}]
        call _printUint@i64
        ; const arg.2.0{r1}, 10
        mov dil, 10
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
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
        jmp _for_4
_for_4_body:
        ; move length.3{r2}, length.2{r0}
        mov rsi, rax
        ; add length.3{r2}, 1
        add rsi, 1
        ; add str.2{r1}, 1
        add rdi, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rsi
_for_4:
        ; load t.2.1{r2}, [str.1{r1}]
        mov sil, [rdi]
        ; branch t.2.1{r2} notequals 0: for_4_body
        cmp sil, 0
        jne _for_4_body
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

        ; bool getTrue
_getTrue:
        sub rsp, 8
        ; const t.0.1{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; 3:49 return true
        ; const {r0}, 1
        mov al, 1
        add rsp, 8
        ret

        ; bool getFalse
_getFalse:
        sub rsp, 8
        ; const t.0.1{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; 4:49 return false
        ; const {r0}, 0
        mov al, 0
        add rsp, 8
        ret

        ; void printPass
_printPass:
        sub rsp, 8
        ; const t.0.1{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        add rsp, 8
        ret

        ; void printError
_printError:
        sub rsp, 8
        ; const t.0.1{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        add rsp, 8
        ret

        ; void logicNot
_logicNot:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const t.2.1{r1}, [string-4]
        lea rdi, [string_4]
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; const t.1{r8}, 1
        mov bl, 1
        ; const f.1{r9}, 0
        mov r12b, 0
        ; 13:2 if !getFalse([])
        ; call t.3.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.3.1{r0} notequals 0: if_5_else
        cmp al, 0
        jne _if_5_else
        ; call printPass[]
        call _printPass
        jmp _if_5_end
_if_5_else:
        ; call printError[]
        call _printError
_if_5_end:
        ; notlog t.4.1{r1}, f.1{r9}
        or r12b, r12b
        sete dil
        ; call printIntLf@bool[t.4.1{r1}]
        call _printIntLf@bool
        ; 15:2 if !getTrue([])
        ; call t.5.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.5.1{r0} notequals 0: if_6_else
        cmp al, 0
        jne _if_6_else
        ; call printError[]
        call _printError
        jmp _if_6_end
_if_6_else:
        ; call printPass[]
        call _printPass
_if_6_end:
        ; notlog t.6.1{r1}, t.1{r8}
        or bl, bl
        sete dil
        ; call printIntLf@bool[t.6.1{r1}]
        call _printIntLf@bool
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void logicAnd
_logicAnd:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const t.2.1{r1}, [string-5]
        lea rdi, [string_5]
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; const t.1{r8}, 1
        mov bl, 1
        ; const f.1{r9}, 0
        mov r12b, 0
        ; 23:2 if getFalse([]) && getFalse([])
        ; call t.3.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.3.1{r0} equals 0: if_7_else
        cmp al, 0
        je _if_7_else
        ; call t.4.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.4.1{r0} equals 0: if_7_else
        cmp al, 0
        je _if_7_else
        ; call printError[]
        call _printError
        jmp _if_7_end
_if_7_else:
        ; call printPass[]
        call _printPass
_if_7_end:
        ; 24:15 logic and
        ; move t.5.1{r0}, f.1{r9}
        mov al, r12b
        ; branch t.5.1{r0} equals 0: logicAnd.no_critical_edge_51
        cmp al, 0
        je _logicAnd.no_critical_edge_51
        ; move t.5.2{r1}, t.5.3{r0}
        mov dil, al
        jmp _and_next_9
_logicAnd.no_critical_edge_51:
        ; move t.5.2{r1}, t.5.1{r0}
        mov dil, al
_and_next_9:
        ; call printIntLf@bool[t.5.2{r1}]
        call _printIntLf@bool
        ; 25:2 if getFalse([]) && getTrue([])
        ; call t.6.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.6.1{r0} equals 0: if_10_else
        cmp al, 0
        je _if_10_else
        ; call t.7.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.7.1{r0} equals 0: if_10_else
        cmp al, 0
        je _if_10_else
        ; call printError[]
        call _printError
        jmp _if_10_end
_if_10_else:
        ; call printPass[]
        call _printPass
_if_10_end:
        ; 26:15 logic and
        ; move t.8.1{r0}, f.1{r9}
        mov al, r12b
        ; branch t.8.1{r0} equals 0: logicAnd.no_critical_edge_53
        cmp al, 0
        je _logicAnd.no_critical_edge_53
        ; move t.8.3{r0}, t.1{r8}
        mov al, bl
        ; move t.8.2{r1}, t.8.3{r0}
        mov dil, al
        jmp _and_next_12
_logicAnd.no_critical_edge_53:
        ; move t.8.2{r1}, t.8.1{r0}
        mov dil, al
_and_next_12:
        ; call printIntLf@bool[t.8.2{r1}]
        call _printIntLf@bool
        ; 27:2 if getTrue([]) && getFalse([])
        ; call t.9.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.9.1{r0} equals 0: if_13_else
        cmp al, 0
        je _if_13_else
        ; call t.10.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.10.1{r0} equals 0: if_13_else
        cmp al, 0
        je _if_13_else
        ; call printError[]
        call _printError
        jmp _if_13_end
_if_13_else:
        ; call printPass[]
        call _printPass
_if_13_end:
        ; 28:15 logic and
        ; move t.11.1{r0}, t.1{r8}
        mov al, bl
        ; branch t.11.1{r0} equals 0: logicAnd.no_critical_edge_55
        cmp al, 0
        je _logicAnd.no_critical_edge_55
        ; move t.11.3{r0}, f.1{r9}
        mov al, r12b
        ; move t.11.2{r1}, t.11.3{r0}
        mov dil, al
        jmp _and_next_15
_logicAnd.no_critical_edge_55:
        ; move t.11.2{r1}, t.11.1{r0}
        mov dil, al
_and_next_15:
        ; call printIntLf@bool[t.11.2{r1}]
        call _printIntLf@bool
        ; 29:2 if getTrue([]) && getTrue([])
        ; call t.12.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.12.1{r0} equals 0: if_16_else
        cmp al, 0
        je _if_16_else
        ; call t.13.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.13.1{r0} equals 0: if_16_else
        cmp al, 0
        je _if_16_else
        ; call printPass[]
        call _printPass
        jmp _if_16_end
_if_16_else:
        ; call printError[]
        call _printError
_if_16_end:
        ; 30:15 logic and
        ; move t.14.1{r0}, t.1{r8}
        mov al, bl
        ; branch t.14.1{r0} equals 0: logicAnd.no_critical_edge_57
        cmp al, 0
        je _logicAnd.no_critical_edge_57
        ; move t.14.2{r1}, t.14.3{r0}
        mov dil, al
        jmp _and_next_18
_logicAnd.no_critical_edge_57:
        ; move t.14.2{r1}, t.14.1{r0}
        mov dil, al
_and_next_18:
        ; call printIntLf@bool[t.14.2{r1}]
        call _printIntLf@bool
        ; 32:2 if !getFalse([]) && getFalse([])
        ; call t.15.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.15.1{r0} equals 0: if_19_then
        cmp al, 0
        je _if_19_then
        ; call t.16.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.16.1{r0} equals 0: if_19_then
        cmp al, 0
        je _if_19_then
        ; call printError[]
        call _printError
        jmp _if_19_end
_if_19_then:
        ; call printPass[]
        call _printPass
_if_19_end:
        ; 33:17 logic and
        ; move t.18.1{r0}, f.1{r9}
        mov al, r12b
        ; notlog t.17.1{r1}, t.18.2{r0}
        or al, al
        sete dil
        ; call printIntLf@bool[t.17.1{r1}]
        call _printIntLf@bool
        ; 34:2 if !getFalse([]) && getTrue([])
        ; call t.19.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.19.1{r0} equals 0: if_22_then
        cmp al, 0
        je _if_22_then
        ; call t.20.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.20.1{r0} equals 0: if_22_then
        cmp al, 0
        je _if_22_then
        ; call printError[]
        call _printError
        jmp _if_22_end
_if_22_then:
        ; call printPass[]
        call _printPass
_if_22_end:
        ; 35:17 logic and
        ; move t.22.1{r0}, f.1{r9}
        mov al, r12b
        ; branch t.22.1{r0} equals 0: and_next_24
        cmp al, 0
        je _and_next_24
        ; move t.22.3{r0}, t.1{r8}
        mov al, bl
_and_next_24:
        ; notlog t.21.1{r1}, t.22.2{r0}
        or al, al
        sete dil
        ; call printIntLf@bool[t.21.1{r1}]
        call _printIntLf@bool
        ; 36:2 if !getTrue([]) && getFalse([])
        ; call t.23.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.23.1{r0} equals 0: if_25_then
        cmp al, 0
        je _if_25_then
        ; call t.24.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.24.1{r0} equals 0: if_25_then
        cmp al, 0
        je _if_25_then
        ; call printError[]
        call _printError
        jmp _if_25_end
_if_25_then:
        ; call printPass[]
        call _printPass
_if_25_end:
        ; 37:17 logic and
        ; move t.26.1{r0}, t.1{r8}
        mov al, bl
        ; branch t.26.1{r0} notequals 0: and_next_27
        cmp al, 0
        jne _and_next_27
        ; move t.26.2{r9}, t.26.1{r0}
        mov r12b, al
_and_next_27:
        ; notlog t.25.1{r1}, t.26.2{r9}
        or r12b, r12b
        sete dil
        ; call printIntLf@bool[t.25.1{r1}]
        call _printIntLf@bool
        ; 38:2 if !getTrue([]) && getTrue([])
        ; call t.27.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.27.1{r0} equals 0: if_28_then
        cmp al, 0
        je _if_28_then
        ; call t.28.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.28.1{r0} equals 0: if_28_then
        cmp al, 0
        je _if_28_then
        ; call printPass[]
        call _printPass
        jmp _if_28_end
_if_28_then:
        ; call printError[]
        call _printError
_if_28_end:
        ; 39:17 logic and
        ; move t.30.1{r9}, t.1{r8}
        mov r12b, bl
        ; notlog t.29.1{r1}, t.30.2{r8}
        or bl, bl
        sete dil
        ; call printIntLf@bool[t.29.1{r1}]
        call _printIntLf@bool
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void logicOr
_logicOr:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const t.2.1{r1}, [string-6]
        lea rdi, [string_6]
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; const t.1{r8}, 1
        mov bl, 1
        ; const f.1{r9}, 0
        mov r12b, 0
        ; 46:2 if getFalse([]) || getFalse([])
        ; call t.3.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.3.1{r0} notequals 0: if_31_then
        cmp al, 0
        jne _if_31_then
        ; call t.4.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.4.1{r0} notequals 0: if_31_then
        cmp al, 0
        jne _if_31_then
        ; call printPass[]
        call _printPass
        jmp _if_31_end
_if_31_then:
        ; call printError[]
        call _printError
_if_31_end:
        ; 47:15 logic or
        ; move t.5.1{r0}, f.1{r9}
        mov al, r12b
        ; branch t.5.1{r0} notequals 0: logicOr.no_critical_edge_27
        cmp al, 0
        jne _logicOr.no_critical_edge_27
        ; move t.5.2{r1}, t.5.3{r0}
        mov dil, al
        jmp _or_next_33
_logicOr.no_critical_edge_27:
        ; move t.5.2{r1}, t.5.1{r0}
        mov dil, al
_or_next_33:
        ; call printIntLf@bool[t.5.2{r1}]
        call _printIntLf@bool
        ; 48:2 if getFalse([]) || getTrue([])
        ; call t.6.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.6.1{r0} notequals 0: if_34_then
        cmp al, 0
        jne _if_34_then
        ; call t.7.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.7.1{r0} notequals 0: if_34_then
        cmp al, 0
        jne _if_34_then
        ; call printError[]
        call _printError
        jmp _if_34_end
_if_34_then:
        ; call printPass[]
        call _printPass
_if_34_end:
        ; 49:15 logic or
        ; move t.8.1{r0}, f.1{r9}
        mov al, r12b
        ; branch t.8.1{r0} notequals 0: logicOr.no_critical_edge_29
        cmp al, 0
        jne _logicOr.no_critical_edge_29
        ; move t.8.3{r0}, t.1{r8}
        mov al, bl
        ; move t.8.2{r1}, t.8.3{r0}
        mov dil, al
        jmp _or_next_36
_logicOr.no_critical_edge_29:
        ; move t.8.2{r1}, t.8.1{r0}
        mov dil, al
_or_next_36:
        ; call printIntLf@bool[t.8.2{r1}]
        call _printIntLf@bool
        ; 50:2 if getTrue([]) || getFalse([])
        ; call t.9.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.9.1{r0} notequals 0: if_37_then
        cmp al, 0
        jne _if_37_then
        ; call t.10.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.10.1{r0} notequals 0: if_37_then
        cmp al, 0
        jne _if_37_then
        ; call printError[]
        call _printError
        jmp _if_37_end
_if_37_then:
        ; call printPass[]
        call _printPass
_if_37_end:
        ; 51:15 logic or
        ; move t.11.1{r0}, t.1{r8}
        mov al, bl
        ; branch t.11.1{r0} notequals 0: logicOr.no_critical_edge_31
        cmp al, 0
        jne _logicOr.no_critical_edge_31
        ; move t.11.2{r1}, t.11.3{r9}
        mov dil, r12b
        jmp _or_next_39
_logicOr.no_critical_edge_31:
        ; move t.11.2{r1}, t.11.1{r0}
        mov dil, al
_or_next_39:
        ; call printIntLf@bool[t.11.2{r1}]
        call _printIntLf@bool
        ; 52:2 if getTrue([]) || getTrue([])
        ; call t.12.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.12.1{r0} notequals 0: if_40_then
        cmp al, 0
        jne _if_40_then
        ; call t.13.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.13.1{r0} notequals 0: if_40_then
        cmp al, 0
        jne _if_40_then
        ; call printError[]
        call _printError
        jmp _if_40_end
_if_40_then:
        ; call printPass[]
        call _printPass
_if_40_end:
        ; 53:15 logic or
        ; move t.14.1{r9}, t.1{r8}
        mov r12b, bl
        ; branch t.14.1{r9} notequals 0: logicOr.no_critical_edge_33
        cmp r12b, 0
        jne _logicOr.no_critical_edge_33
        ; move t.14.2{r1}, t.14.3{r8}
        mov dil, bl
        jmp _or_next_42
_logicOr.no_critical_edge_33:
        ; move t.14.2{r1}, t.14.1{r9}
        mov dil, r12b
_or_next_42:
        ; call printIntLf@bool[t.14.2{r1}]
        call _printIntLf@bool
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void main
        ;   rsp+32: var b.1
        ;   rsp+34: var c.1
        ;   rsp+36: var d.1
        ;   rsp+38: var t.1
        ;   rsp+39: var f.1
        ;   rsp+40: var b1.1
_main:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const t.9.1{r1}, [string-7]
        lea rdi, [string_7]
        ; call printString@@u8[t.9.1{r1}]
        call _printString@@u8
        ; const a.1{r8}, 0
        mov bx, 0
        ; const b.1{r0}, 1
        mov ax, 1
        ; addrof memVarAddr{r9}, b.1
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b.1{r0}
        mov [r12], ax
        ; const c.1{r0}, 2
        mov ax, 2
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c.1{r0}
        mov [r12], ax
        ; const d.1{r0}, 3
        mov ax, 3
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], d.1{r0}
        mov [r12], ax
        ; const t.1{r0}, 1
        mov al, 1
        ; addrof memVarAddr{r9}, t.1
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], t.1{r0}
        mov [r12], al
        ; const f.1{r0}, 0
        mov al, 0
        ; addrof memVarAddr{r9}, f.1
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], f.1{r0}
        mov [r12], al
        ; move t.10.1{r1}, a.1{r8}
        mov di, bx
        ; and t.10.1{r1}, a.1{r8}
        and di, bx
        ; call printIntLf@i16[t.10.1{r1}]
        call _printIntLf@i16
        ; move t.11.1{r1}, a.1{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, b.1
        lea r12, [rsp+32]
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; and t.11.1{r1}, b.1{r0}
        and di, ax
        ; call printIntLf@i16[t.11.1{r1}]
        call _printIntLf@i16
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.12.1{r1}, b.1{r0}
        mov di, ax
        ; and t.12.1{r1}, a.1{r8}
        and di, bx
        ; call printIntLf@i16[t.12.1{r1}]
        call _printIntLf@i16
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.13.1{r1}, b.1{r0}
        mov di, ax
        ; and t.13.1{r1}, b.1{r0}
        and di, ax
        ; call printIntLf@i16[t.13.1{r1}]
        call _printIntLf@i16
        ; const t.14.1{r1}, [string-8]
        lea rdi, [string_8]
        ; call printString@@u8[t.14.1{r1}]
        call _printString@@u8
        ; move t.15.1{r1}, a.1{r8}
        mov di, bx
        ; or t.15.1{r1}, a.1{r8}
        or di, bx
        ; call printIntLf@i16[t.15.1{r1}]
        call _printIntLf@i16
        ; move t.16.1{r1}, a.1{r8}
        mov di, bx
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; or t.16.1{r1}, b.1{r0}
        or di, ax
        ; call printIntLf@i16[t.16.1{r1}]
        call _printIntLf@i16
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.17.1{r1}, b.1{r0}
        mov di, ax
        ; or t.17.1{r1}, a.1{r8}
        or di, bx
        ; call printIntLf@i16[t.17.1{r1}]
        call _printIntLf@i16
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.18.1{r1}, b.1{r0}
        mov di, ax
        ; or t.18.1{r1}, b.1{r0}
        or di, ax
        ; call printIntLf@i16[t.18.1{r1}]
        call _printIntLf@i16
        ; const t.19.1{r1}, [string-9]
        lea rdi, [string_9]
        ; call printString@@u8[t.19.1{r1}]
        call _printString@@u8
        ; move t.20.1{r1}, a.1{r8}
        mov di, bx
        ; xor t.20.1{r1}, a.1{r8}
        xor di, bx
        ; call printIntLf@i16[t.20.1{r1}]
        call _printIntLf@i16
        ; move t.21.1{r1}, a.1{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; xor t.21.1{r1}, c.1{r0}
        xor di, ax
        ; call printIntLf@i16[t.21.1{r1}]
        call _printIntLf@i16
        ; addrof memVarAddr{r9}, b.1
        lea r12, [rsp+32]
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.22.1{r1}, b.1{r0}
        mov di, ax
        ; xor t.22.1{r1}, a.1{r8}
        xor di, bx
        ; call printIntLf@i16[t.22.1{r1}]
        call _printIntLf@i16
        ; load b.1{r8}, [memVarAddr{r9}]
        mov bx, [r12]
        ; move t.23.1{r1}, b.1{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; xor t.23.1{r1}, c.1{r0}
        xor di, ax
        ; call printIntLf@i16[t.23.1{r1}]
        call _printIntLf@i16
        ; call logicNot[]
        call _logicNot
        ; call logicAnd[]
        call _logicAnd
        ; call logicOr[]
        call _logicOr
        ; 82:2 if !getTrue([]) && getTrue([]) || !getFalse([]) && getFalse([])
        ; call t.24.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.24.1{r0} equals 0: if_43_then
        cmp al, 0
        je _if_43_then
        ; call t.25.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.25.1{r0} equals 0: if_43_then
        cmp al, 0
        je _if_43_then
        ; call t.26.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.26.1{r0} equals 0: if_43_then
        cmp al, 0
        je _if_43_then
        ; call t.27.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.27.1{r0} equals 0: if_43_then
        cmp al, 0
        je _if_43_then
        ; call printError[]
        call _printError
        jmp _if_43_end
_if_43_then:
        ; call printPass[]
        call _printPass
_if_43_end:
        ; 88:23 logic or
        ; 88:17 logic and
        ; addrof memVarAddr{r9}, t.1
        lea r12, [rsp+38]
        ; load t.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.29.1{r2}, t.1{r0}
        mov sil, al
        ; notlog t.28.1{r0}, t.29.2{r0}
        or al, al
        sete al
        ; branch t.28.1{r0} notequals 0: main.no_critical_edge_20
        cmp al, 0
        jne _main.no_critical_edge_20
        ; 88:30 logic and
        ; addrof memVarAddr{r9}, f.1
        lea r12, [rsp+39]
        ; load f.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.30.1{r2}, f.1{r0}
        mov sil, al
        ; notlog t.28.3{r0}, t.30.2{r0}
        or al, al
        sete al
        ; move t.28.2{r1}, t.28.3{r0}
        mov dil, al
        jmp _or_next_47
_main.no_critical_edge_20:
        ; move t.28.2{r1}, t.28.1{r0}
        mov dil, al
_or_next_47:
        ; call printIntLf@bool[t.28.2{r1}]
        call _printIntLf@bool
        ; const t.31.1{r1}, [string-10]
        lea rdi, [string_10]
        ; call printString@@u8[t.31.1{r1}]
        call _printString@@u8
        ; const b10.1{r0}, 10
        mov al, 10
        ; const b6.1{r2}, 6
        mov sil, 6
        ; const b1.1{r3}, 1
        mov dl, 1
        ; and t.33.1{r0}, b6.1{r2}
        and al, sil
        ; move t.32.1{r1}, t.33.1{r0}
        mov dil, al
        ; or t.32.1{r1}, b1.1{r3}
        or dil, dl
        ; addrof memVarAddr{r9}, b1.1
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], b1.1{r3}
        mov [r12], dl
        ; call printIntLf@u8[t.32.1{r1}]
        call _printIntLf@u8
        ; 95:20 logic or
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; equals t.34.1{r2}, b.1{r8}, c.1{r0}
        cmp bx, ax
        sete sil
        ; branch t.34.1{r2} notequals 0: main.no_critical_edge_21
        cmp sil, 0
        jne _main.no_critical_edge_21
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+36]
        ; load d.1{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; lt t.34.3{r2}, c.1{r0}, d.1{r3}
        cmp ax, dx
        setl sil
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+36]
        ; move t.34.2{r1}, t.34.3{r2}
        mov dil, sil
        jmp _or_next_50
_main.no_critical_edge_21:
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c.1{r0}
        mov [r12], ax
        ; move t.34.2{r1}, t.34.1{r2}
        mov dil, sil
_or_next_50:
        ; call printIntLf@bool[t.34.2{r1}]
        call _printIntLf@bool
        ; 96:20 logic and
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; equals t.35.1{r2}, b.1{r8}, c.1{r0}
        cmp bx, ax
        sete sil
        ; branch t.35.1{r2} equals 0: main.no_critical_edge_22
        cmp sil, 0
        je _main.no_critical_edge_22
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+36]
        ; load d.1{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; lt t.35.3{r0}, c.1{r0}, d.1{r2}
        cmp ax, si
        setl al
        ; move t.35.2{r1}, t.35.3{r0}
        mov dil, al
        jmp _and_next_51
_main.no_critical_edge_22:
        ; move t.35.2{r1}, t.35.1{r2}
        mov dil, sil
_and_next_51:
        ; call printIntLf@bool[t.35.2{r1}]
        call _printIntLf@bool
        ; const arg.29.0{r1}, -1
        mov di, -1
        ; call printIntLf@i16[arg.29.0{r1}]
        call _printIntLf@i16
        ; neg t.36.1{r1}, b.1{r8}
        mov rdi, rbx
        neg rdi
        ; call printIntLf@i16[t.36.1{r1}]
        call _printIntLf@i16
        ; addrof memVarAddr{r9}, b1.1
        lea r12, [rsp+40]
        ; load b1.1{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        ; not t.37.1{r1}, b1.1{r8}
        mov rdi, rbx
        not rdi
        ; call printIntLf@u8[t.37.1{r1}]
        call _printIntLf@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
        mov rdx, rsi
        mov rsi, rdi
        mov rdi, 1
        mov rax, 1
        syscall
        ret

segment readable
        string_0 db ' true', 0x00
        string_1 db ' false', 0x00
        string_2 db ' -> pass ', 0x00
        string_3 db ' -> ERROR ', 0x00
        string_4 db 0x0a, 'Logic-!:', 0x0a, 0x00
        string_5 db 0x0a, 'Logic-&&:', 0x0a, 0x00
        string_6 db 0x0a, 'Logic-||:', 0x0a, 0x00
        string_7 db 'Bit-&:', 0x0a, 0x00
        string_8 db 0x0a, 'Bit-|:', 0x0a, 0x00
        string_9 db 0x0a, 'Bit-^:', 0x0a, 0x00
        string_10 db 0x0a, 0x0a, 'misc:', 0x0a, 0x00

