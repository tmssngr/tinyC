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
        ;   rsp+48: arg chr
_printChar@u8:
        sub rsp, 8
        sub rsp, 32
        ; move chr, chr{r1}
        lea r11, [rsp+48]
        mov [r11], cl
        ; addrof t.1.1{r1}, chr
        lea rcx, [rsp+48]
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+96: arg number
        ;   rsp+60: var buffer
_printUint@i64:
        sub rsp, 40
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const pos.1{r6}, 20
        mov bl, 20
        ; 28:2 while true
        ; move number.1{r7}, number{r1}
        mov r12, rcx
_while_1:
        ; sub pos.3{r6}, pos.3{r6}, 1
        sub bl, 1
        ; move remainder.1{r3}, number.1{r7}
        mov r8, r12
        ; move remainder.1{r0}, remainder.1{r3}
        mov rax, r8
        ; mod remainder.1{r2}, remainder.1{r0}, 10
        mov cx, 10
        cqo
        idiv cx
        ; move remainder.1{r3}, remainder.1{r2}
        mov r8, rdx
        ; move number.2{r0}, number.2{r7}
        mov rax, r12
        ; div number.2{r0}, number.2{r0}, 10
        mov cx, 10
        cqo
        idiv cx
        ; move number.2{r7}, number.2{r0}
        mov r12, rax
        ; cast t.5.1{r0}(u8), remainder.1{r3}(i64)
        mov al, r8b
        ; add digit.1{r0}, digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r3}(i64), pos.3{r6}(u8)
        movzx r8, bl
        ; addrof t.6.1{r4}, [buffer]
        lea r9, [rsp+60]
        ; add t.6.2{r4}, t.6.2{r4}, t.7.1{r3}
        add r9, r8
        ; store [t.6.2{r4}], digit.1{r0}
        mov [r9], al
        ; 34:3 if number == 0
        ; branch number.2{r7} notequals 0: while_1, while_1_break
        cmp r12, 0
        jne _while_1
        ; cast t.9.1{r7}(i64), pos.3{r6}(u8)
        movzx r12, bl
        ; addrof t.8.1{r0}, [buffer]
        lea rax, [rsp+60]
        ; move t.8.2{r1}, t.8.1{r0}
        mov rcx, rax
        ; add t.8.2{r1}, t.8.2{r1}, t.9.1{r7}
        add rcx, r12
        ; const t.11.1{r7}, 20
        mov r12b, 20
        ; move t.10.1{r2}, t.11.1{r7}
        mov dl, r12b
        ; sub t.10.1{r2}, t.10.1{r2}, pos.3{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 40
        ret

        ; void printIntLf@bool
        ;   rsp+48: arg number
_printIntLf@bool:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1.1{r1}(i64), number{r1}(bool)
        movsx rcx, cl
        ; call printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printIntLf@u8
        ;   rsp+48: arg number
_printIntLf@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1.1{r1}(i64), number{r1}(u8)
        movzx rcx, cl
        ; call printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printIntLf@i16
        ;   rsp+48: arg number
_printIntLf@i16:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1.1{r1}(i64), number{r1}(i16)
        movsx rcx, cx
        ; call printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printIntLf@i64
        ;   rsp+48: arg number
_printIntLf@i64:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; branch number{r6} gteq 0: if_3_end, if_3_then
        cmp rbx, 0
        jge _if_3_end
        ; const arg.0.0{r1}, 45
        mov cl, 45
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; neg number.2{r6}, number{r6}
        neg rbx
_if_3_end:
        ; move number.1{r1}, number.1{r6}
        mov rcx, rbx
        ; call printUint@i64[number.1{r1}]
        call _printUint@i64
        ; const arg.2.0{r1}, 10
        mov cl, 10
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; i64 strlen@@u8
        ;   rsp+16: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length.1{r2}, 0
        mov rdx, 0
        ; 64:2 for *str != 0
        ; move length.2{r0}, length.1{r2}
        mov rax, rdx
        jmp _for_4
_for_4_body:
        ; move length.3{r2}, length.2{r0}
        mov rdx, rax
        ; add length.3{r2}, length.3{r2}, 1
        add rdx, 1
        ; add str.2{r1}, str.2{r1}, 1
        add rcx, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rdx
_for_4:
        ; load t.2.1{r2}, [str.1{r1}]
        mov dl, [rcx]
        ; branch t.2.1{r2} notequals 0: for_4_body, for_4_break
        cmp dl, 0
        jne _for_4_body
        ; 67:9 return length
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

        ; bool getTrue
_getTrue:
        sub rsp, 8
        sub rsp, 32
        ; const t.0.1{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; 3:49 return true
        ; const {r0}, 1
        mov al, 1
        add rsp, 32
        add rsp, 8
        ret

        ; bool getFalse
_getFalse:
        sub rsp, 8
        sub rsp, 32
        ; const t.0.1{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; 4:49 return false
        ; const {r0}, 0
        mov al, 0
        add rsp, 32
        add rsp, 8
        ret

        ; void printPass
_printPass:
        sub rsp, 8
        sub rsp, 32
        ; const t.0.1{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        add rsp, 32
        add rsp, 8
        ret

        ; void printError
_printError:
        sub rsp, 8
        sub rsp, 32
        ; const t.0.1{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        add rsp, 32
        add rsp, 8
        ret

        ; void logicNot
_logicNot:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const t.2.1{r1}, [string-4]
        lea rcx, [string_4]
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; const t.1{r6}, 1
        mov bl, 1
        ; const f.1{r7}, 0
        mov r12b, 0
        ; 13:2 if !getFalse([])
        ; call t.3.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.3.1{r0} equals 0: if_5_then, if_5_else
        cmp al, 0
        je _if_5_then
        ; call printError[]
        call _printError
        jmp _if_5_end
_if_5_then:
        ; call printPass[]
        call _printPass
_if_5_end:
        ; notlog t.4.1{r1}, f.1{r7}
        or r12b, r12b
        sete cl
        ; call printIntLf@bool[t.4.1{r1}]
        call _printIntLf@bool
        ; 15:2 if !getTrue([])
        ; call t.5.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.5.1{r0} equals 0: if_6_then, if_6_else
        cmp al, 0
        je _if_6_then
        ; call printPass[]
        call _printPass
        jmp _if_6_end
_if_6_then:
        ; call printError[]
        call _printError
_if_6_end:
        ; notlog t.6.1{r1}, t.1{r6}
        or bl, bl
        sete cl
        ; call printIntLf@bool[t.6.1{r1}]
        call _printIntLf@bool
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void logicAnd
_logicAnd:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const t.2.1{r1}, [string-5]
        lea rcx, [string_5]
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; const t.1{r6}, 1
        mov bl, 1
        ; const f.1{r7}, 0
        mov r12b, 0
        ; 23:2 if getFalse([]) && getFalse([])
        ; call t.3.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.3.1{r0} equals 0: if_7_else, and_8
        cmp al, 0
        je _if_7_else
        ; call t.4.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.4.1{r0} equals 0: if_7_else, if_7_then
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
        ; move t.5.1{r0}, f.1{r7}
        mov al, r12b
        ; branch t.5.1{r0} notequals 0: and_2nd_9, logicAnd.no_critical_edge_51
        cmp al, 0
        jne _and_2nd_9
        ; move t.5.2{r1}, t.5.1{r0}
        mov cl, al
        jmp _and_next_9
_and_2nd_9:
        ; move t.5.3{r0}, f.1{r7}
        mov al, r12b
        ; move t.5.2{r1}, t.5.3{r0}
        mov cl, al
_and_next_9:
        ; call printIntLf@bool[t.5.2{r1}]
        call _printIntLf@bool
        ; 25:2 if getFalse([]) && getTrue([])
        ; call t.6.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.6.1{r0} equals 0: if_10_else, and_11
        cmp al, 0
        je _if_10_else
        ; call t.7.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.7.1{r0} equals 0: if_10_else, if_10_then
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
        ; move t.8.1{r0}, f.1{r7}
        mov al, r12b
        ; branch t.8.1{r0} notequals 0: and_2nd_12, logicAnd.no_critical_edge_53
        cmp al, 0
        jne _and_2nd_12
        ; move t.8.2{r1}, t.8.1{r0}
        mov cl, al
        jmp _and_next_12
_and_2nd_12:
        ; move t.8.3{r0}, t.1{r6}
        mov al, bl
        ; move t.8.2{r1}, t.8.3{r0}
        mov cl, al
_and_next_12:
        ; call printIntLf@bool[t.8.2{r1}]
        call _printIntLf@bool
        ; 27:2 if getTrue([]) && getFalse([])
        ; call t.9.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.9.1{r0} equals 0: if_13_else, and_14
        cmp al, 0
        je _if_13_else
        ; call t.10.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.10.1{r0} equals 0: if_13_else, if_13_then
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
        ; move t.11.1{r0}, t.1{r6}
        mov al, bl
        ; branch t.11.1{r0} notequals 0: and_2nd_15, logicAnd.no_critical_edge_55
        cmp al, 0
        jne _and_2nd_15
        ; move t.11.2{r1}, t.11.1{r0}
        mov cl, al
        jmp _and_next_15
_and_2nd_15:
        ; move t.11.3{r0}, f.1{r7}
        mov al, r12b
        ; move t.11.2{r1}, t.11.3{r0}
        mov cl, al
_and_next_15:
        ; call printIntLf@bool[t.11.2{r1}]
        call _printIntLf@bool
        ; 29:2 if getTrue([]) && getTrue([])
        ; call t.12.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.12.1{r0} equals 0: if_16_else, and_17
        cmp al, 0
        je _if_16_else
        ; call t.13.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.13.1{r0} equals 0: if_16_else, if_16_then
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
        ; move t.14.1{r0}, t.1{r6}
        mov al, bl
        ; branch t.14.1{r0} notequals 0: and_2nd_18, logicAnd.no_critical_edge_57
        cmp al, 0
        jne _and_2nd_18
        ; move t.14.2{r1}, t.14.1{r0}
        mov cl, al
        jmp _and_next_18
_and_2nd_18:
        ; move t.14.3{r0}, t.1{r6}
        mov al, bl
        ; move t.14.2{r1}, t.14.3{r0}
        mov cl, al
_and_next_18:
        ; call printIntLf@bool[t.14.2{r1}]
        call _printIntLf@bool
        ; 32:2 if !getFalse([]) && getFalse([])
        ; call t.15.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.15.1{r0} equals 0: if_19_then, and_20
        cmp al, 0
        je _if_19_then
        ; call t.16.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.16.1{r0} equals 0: if_19_then, if_19_else
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
        ; move t.18.1{r0}, f.1{r7}
        mov al, r12b
        ; branch t.18.1{r0} equals 0: and_next_21, and_2nd_21
        cmp al, 0
        je _and_next_21
        ; move t.18.3{r0}, f.1{r7}
        mov al, r12b
_and_next_21:
        ; notlog t.17.1{r1}, t.18.2{r0}
        or al, al
        sete cl
        ; call printIntLf@bool[t.17.1{r1}]
        call _printIntLf@bool
        ; 34:2 if !getFalse([]) && getTrue([])
        ; call t.19.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.19.1{r0} equals 0: if_22_then, and_23
        cmp al, 0
        je _if_22_then
        ; call t.20.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.20.1{r0} equals 0: if_22_then, if_22_else
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
        ; move t.22.1{r0}, f.1{r7}
        mov al, r12b
        ; branch t.22.1{r0} equals 0: and_next_24, and_2nd_24
        cmp al, 0
        je _and_next_24
        ; move t.22.3{r0}, t.1{r6}
        mov al, bl
_and_next_24:
        ; notlog t.21.1{r1}, t.22.2{r0}
        or al, al
        sete cl
        ; call printIntLf@bool[t.21.1{r1}]
        call _printIntLf@bool
        ; 36:2 if !getTrue([]) && getFalse([])
        ; call t.23.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.23.1{r0} equals 0: if_25_then, and_26
        cmp al, 0
        je _if_25_then
        ; call t.24.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.24.1{r0} equals 0: if_25_then, if_25_else
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
        ; move t.26.1{r0}, t.1{r6}
        mov al, bl
        ; branch t.26.1{r0} notequals 0: and_next_27, logicAnd.no_critical_edge_63
        cmp al, 0
        jne _and_next_27
        ; move t.26.2{r7}, t.26.1{r0}
        mov r12b, al
_and_next_27:
        ; notlog t.25.1{r1}, t.26.2{r7}
        or r12b, r12b
        sete cl
        ; call printIntLf@bool[t.25.1{r1}]
        call _printIntLf@bool
        ; 38:2 if !getTrue([]) && getTrue([])
        ; call t.27.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.27.1{r0} equals 0: if_28_then, and_29
        cmp al, 0
        je _if_28_then
        ; call t.28.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.28.1{r0} equals 0: if_28_then, if_28_else
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
        ; move t.30.1{r7}, t.1{r6}
        mov r12b, bl
        ; branch t.30.1{r7} notequals 0: and_next_30, logicAnd.no_critical_edge_65
        cmp r12b, 0
        jne _and_next_30
        ; move t.30.2{r6}, t.30.1{r7}
        mov bl, r12b
_and_next_30:
        ; notlog t.29.1{r1}, t.30.2{r6}
        or bl, bl
        sete cl
        ; call printIntLf@bool[t.29.1{r1}]
        call _printIntLf@bool
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void logicOr
_logicOr:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const t.2.1{r1}, [string-6]
        lea rcx, [string_6]
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; const t.1{r6}, 1
        mov bl, 1
        ; const f.1{r7}, 0
        mov r12b, 0
        ; 46:2 if getFalse([]) || getFalse([])
        ; call t.3.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.3.1{r0} notequals 0: if_31_then, or_32
        cmp al, 0
        jne _if_31_then
        ; call t.4.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.4.1{r0} notequals 0: if_31_then, if_31_else
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
        ; move t.5.1{r0}, f.1{r7}
        mov al, r12b
        ; branch t.5.1{r0} equals 0: or_2nd_33, logicOr.no_critical_edge_27
        cmp al, 0
        je _or_2nd_33
        ; move t.5.2{r1}, t.5.1{r0}
        mov cl, al
        jmp _or_next_33
_or_2nd_33:
        ; move t.5.3{r0}, f.1{r7}
        mov al, r12b
        ; move t.5.2{r1}, t.5.3{r0}
        mov cl, al
_or_next_33:
        ; call printIntLf@bool[t.5.2{r1}]
        call _printIntLf@bool
        ; 48:2 if getFalse([]) || getTrue([])
        ; call t.6.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.6.1{r0} notequals 0: if_34_then, or_35
        cmp al, 0
        jne _if_34_then
        ; call t.7.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.7.1{r0} notequals 0: if_34_then, if_34_else
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
        ; move t.8.1{r0}, f.1{r7}
        mov al, r12b
        ; branch t.8.1{r0} equals 0: or_2nd_36, logicOr.no_critical_edge_29
        cmp al, 0
        je _or_2nd_36
        ; move t.8.2{r1}, t.8.1{r0}
        mov cl, al
        jmp _or_next_36
_or_2nd_36:
        ; move t.8.3{r0}, t.1{r6}
        mov al, bl
        ; move t.8.2{r1}, t.8.3{r0}
        mov cl, al
_or_next_36:
        ; call printIntLf@bool[t.8.2{r1}]
        call _printIntLf@bool
        ; 50:2 if getTrue([]) || getFalse([])
        ; call t.9.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.9.1{r0} notequals 0: if_37_then, or_38
        cmp al, 0
        jne _if_37_then
        ; call t.10.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.10.1{r0} notequals 0: if_37_then, if_37_else
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
        ; move t.11.1{r0}, t.1{r6}
        mov al, bl
        ; branch t.11.1{r0} equals 0: or_2nd_39, logicOr.no_critical_edge_31
        cmp al, 0
        je _or_2nd_39
        ; move t.11.2{r1}, t.11.1{r0}
        mov cl, al
        jmp _or_next_39
_or_2nd_39:
        ; move t.11.2{r1}, t.11.3{r7}
        mov cl, r12b
_or_next_39:
        ; call printIntLf@bool[t.11.2{r1}]
        call _printIntLf@bool
        ; 52:2 if getTrue([]) || getTrue([])
        ; call t.12.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.12.1{r0} notequals 0: if_40_then, or_41
        cmp al, 0
        jne _if_40_then
        ; call t.13.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.13.1{r0} notequals 0: if_40_then, if_40_else
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
        ; move t.14.1{r7}, t.1{r6}
        mov r12b, bl
        ; branch t.14.1{r7} equals 0: or_2nd_42, logicOr.no_critical_edge_33
        cmp r12b, 0
        je _or_2nd_42
        ; move t.14.2{r1}, t.14.1{r7}
        mov cl, r12b
        jmp _or_next_42
_or_2nd_42:
        ; move t.14.2{r1}, t.14.3{r6}
        mov cl, bl
_or_next_42:
        ; call printIntLf@bool[t.14.2{r1}]
        call _printIntLf@bool
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void main
        ;   rsp+48: var c.1
        ;   rsp+50: var d.1
        ;   rsp+52: var t.1
        ;   rsp+53: var f.1
        ;   rsp+54: var b1.1
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const t.9.1{r1}, [string-7]
        lea rcx, [string_7]
        ; call printString@@u8[t.9.1{r1}]
        call _printString@@u8
        ; const a.1{r6}, 0
        mov bx, 0
        ; const b.1{r7}, 1
        mov r12w, 1
        ; const c.1{r0}, 2
        mov ax, 2
        ; move c.1, c.1{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; const d.1{r0}, 3
        mov ax, 3
        ; move d.1, d.1{r0}
        lea r11, [rsp+50]
        mov [r11], ax
        ; const t.1{r0}, 1
        mov al, 1
        ; move t.1, t.1{r0}
        lea r11, [rsp+52]
        mov [r11], al
        ; const f.1{r0}, 0
        mov al, 0
        ; move f.1, f.1{r0}
        lea r11, [rsp+53]
        mov [r11], al
        ; move t.10.1{r1}, a.1{r6}
        mov cx, bx
        ; and t.10.1{r1}, t.10.1{r1}, a.1{r6}
        and cx, bx
        ; call printIntLf@i16[t.10.1{r1}]
        call _printIntLf@i16
        ; move t.11.1{r1}, a.1{r6}
        mov cx, bx
        ; and t.11.1{r1}, t.11.1{r1}, b.1{r7}
        and cx, r12w
        ; call printIntLf@i16[t.11.1{r1}]
        call _printIntLf@i16
        ; move t.12.1{r1}, b.1{r7}
        mov cx, r12w
        ; and t.12.1{r1}, t.12.1{r1}, a.1{r6}
        and cx, bx
        ; call printIntLf@i16[t.12.1{r1}]
        call _printIntLf@i16
        ; move t.13.1{r1}, b.1{r7}
        mov cx, r12w
        ; and t.13.1{r1}, t.13.1{r1}, b.1{r7}
        and cx, r12w
        ; call printIntLf@i16[t.13.1{r1}]
        call _printIntLf@i16
        ; const t.14.1{r1}, [string-8]
        lea rcx, [string_8]
        ; call printString@@u8[t.14.1{r1}]
        call _printString@@u8
        ; move t.15.1{r1}, a.1{r6}
        mov cx, bx
        ; or t.15.1{r1}, t.15.1{r1}, a.1{r6}
        or cx, bx
        ; call printIntLf@i16[t.15.1{r1}]
        call _printIntLf@i16
        ; move t.16.1{r1}, a.1{r6}
        mov cx, bx
        ; or t.16.1{r1}, t.16.1{r1}, b.1{r7}
        or cx, r12w
        ; call printIntLf@i16[t.16.1{r1}]
        call _printIntLf@i16
        ; move t.17.1{r1}, b.1{r7}
        mov cx, r12w
        ; or t.17.1{r1}, t.17.1{r1}, a.1{r6}
        or cx, bx
        ; call printIntLf@i16[t.17.1{r1}]
        call _printIntLf@i16
        ; move t.18.1{r1}, b.1{r7}
        mov cx, r12w
        ; or t.18.1{r1}, t.18.1{r1}, b.1{r7}
        or cx, r12w
        ; call printIntLf@i16[t.18.1{r1}]
        call _printIntLf@i16
        ; const t.19.1{r1}, [string-9]
        lea rcx, [string_9]
        ; call printString@@u8[t.19.1{r1}]
        call _printString@@u8
        ; move t.20.1{r1}, a.1{r6}
        mov cx, bx
        ; xor t.20.1{r1}, t.20.1{r1}, a.1{r6}
        xor cx, bx
        ; call printIntLf@i16[t.20.1{r1}]
        call _printIntLf@i16
        ; move t.21.1{r1}, a.1{r6}
        mov cx, bx
        ; move c.1{r0}, c.1
        lea r11, [rsp+48]
        mov ax, [r11]
        ; xor t.21.1{r1}, t.21.1{r1}, c.1{r0}
        xor cx, ax
        ; move c.1, c.1{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; call printIntLf@i16[t.21.1{r1}]
        call _printIntLf@i16
        ; move t.22.1{r1}, b.1{r7}
        mov cx, r12w
        ; xor t.22.1{r1}, t.22.1{r1}, a.1{r6}
        xor cx, bx
        ; call printIntLf@i16[t.22.1{r1}]
        call _printIntLf@i16
        ; move t.23.1{r1}, b.1{r7}
        mov cx, r12w
        ; move c.1{r6}, c.1
        lea r11, [rsp+48]
        mov bx, [r11]
        ; xor t.23.1{r1}, t.23.1{r1}, c.1{r6}
        xor cx, bx
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
        ; branch t.24.1{r0} equals 0: if_43_then, and_45
        cmp al, 0
        je _if_43_then
        ; call t.25.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.25.1{r0} equals 0: if_43_then, or_44
        cmp al, 0
        je _if_43_then
        ; call t.26.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.26.1{r0} equals 0: if_43_then, and_46
        cmp al, 0
        je _if_43_then
        ; call t.27.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.27.1{r0} equals 0: if_43_then, if_43_else
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
        ; move t.1{r0}, t.1
        lea r11, [rsp+52]
        mov al, [r11]
        ; move t.29.1{r2}, t.1{r0}
        mov dl, al
        ; branch t.29.1{r2} notequals 0: and_next_48, main.no_critical_edge_19
        cmp dl, 0
        jne _and_next_48
        ; move t.29.2{r0}, t.29.1{r2}
        mov al, dl
_and_next_48:
        ; notlog t.28.1{r0}, t.29.2{r0}
        or al, al
        sete al
        ; branch t.28.1{r0} equals 0: or_2nd_47, main.no_critical_edge_20
        cmp al, 0
        je _or_2nd_47
        ; move t.28.2{r1}, t.28.1{r0}
        mov cl, al
        jmp _or_next_47
_or_2nd_47:
        ; 88:30 logic and
        ; move f.1{r0}, f.1
        lea r11, [rsp+53]
        mov al, [r11]
        ; move t.30.1{r2}, f.1{r0}
        mov dl, al
        ; branch t.30.1{r2} notequals 0: and_next_49, main.no_critical_edge_23
        cmp dl, 0
        jne _and_next_49
        ; move t.30.2{r0}, t.30.1{r2}
        mov al, dl
_and_next_49:
        ; notlog t.28.3{r0}, t.30.2{r0}
        or al, al
        sete al
        ; move t.28.2{r1}, t.28.3{r0}
        mov cl, al
_or_next_47:
        ; call printIntLf@bool[t.28.2{r1}]
        call _printIntLf@bool
        ; const t.31.1{r1}, [string-10]
        lea rcx, [string_10]
        ; call printString@@u8[t.31.1{r1}]
        call _printString@@u8
        ; const b10.1{r0}, 10
        mov al, 10
        ; const b6.1{r2}, 6
        mov dl, 6
        ; const b1.1{r3}, 1
        mov r8b, 1
        ; and t.33.1{r0}, t.33.1{r0}, b6.1{r2}
        and al, dl
        ; move t.32.1{r1}, t.33.1{r0}
        mov cl, al
        ; or t.32.1{r1}, t.32.1{r1}, b1.1{r3}
        or cl, r8b
        ; move b1.1, b1.1{r3}
        lea r11, [rsp+54]
        mov [r11], r8b
        ; call printIntLf@u8[t.32.1{r1}]
        call _printIntLf@u8
        ; 95:20 logic or
        ; equals t.34.1{r0}, b.1{r7}, c.1{r6}
        cmp r12w, bx
        sete al
        ; branch t.34.1{r0} equals 0: or_2nd_50, main.no_critical_edge_21
        cmp al, 0
        je _or_2nd_50
        ; move t.34.2{r1}, t.34.1{r0}
        mov cl, al
        jmp _or_next_50
_or_2nd_50:
        ; move d.1{r0}, d.1
        lea r11, [rsp+50]
        mov ax, [r11]
        ; lt t.34.3{r2}, c.1{r6}, d.1{r0}
        cmp bx, ax
        setl dl
        ; move d.1, d.1{r0}
        lea r11, [rsp+50]
        mov [r11], ax
        ; move t.34.2{r1}, t.34.3{r2}
        mov cl, dl
_or_next_50:
        ; call printIntLf@bool[t.34.2{r1}]
        call _printIntLf@bool
        ; 96:20 logic and
        ; equals t.35.1{r0}, b.1{r7}, c.1{r6}
        cmp r12w, bx
        sete al
        ; branch t.35.1{r0} notequals 0: and_2nd_51, main.no_critical_edge_22
        cmp al, 0
        jne _and_2nd_51
        ; move t.35.2{r1}, t.35.1{r0}
        mov cl, al
        jmp _and_next_51
_and_2nd_51:
        ; move d.1{r0}, d.1
        lea r11, [rsp+50]
        mov ax, [r11]
        ; lt t.35.3{r6}, c.1{r6}, d.1{r0}
        cmp bx, ax
        setl bl
        ; move t.35.2{r1}, t.35.3{r6}
        mov cl, bl
_and_next_51:
        ; call printIntLf@bool[t.35.2{r1}]
        call _printIntLf@bool
        ; const arg.29.0{r1}, -1
        mov cx, -1
        ; call printIntLf@i16[arg.29.0{r1}]
        call _printIntLf@i16
        ; neg t.36.1{r1}, b.1{r7}
        mov rcx, r12
        neg rcx
        ; call printIntLf@i16[t.36.1{r1}]
        call _printIntLf@i16
        ; move b1.1{r6}, b1.1
        lea r11, [rsp+54]
        mov bl, [r11]
        ; not t.37.1{r1}, b1.1{r6}
        mov rcx, rbx
        not rcx
        ; call printIntLf@u8[t.37.1{r1}]
        call _printIntLf@u8
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

section '.data' data readable
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
