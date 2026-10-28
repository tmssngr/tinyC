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
        ; addrof t.8.1{r3}, buffer
        lea r8, [rsp+40]
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

        ; void printIntLf@bool
        ;   rsp+48: arg value
_printIntLf@bool:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const number.1{r6}, 0
        mov bl, 0
        ; 48:2 if value
        ; branch value{r1} equals 0: if_3_end
        cmp cl, 0
        je _if_3_end
        ; const number.3{r6}, 1
        mov bl, 1
_if_3_end:
        ; cast t.2.1{r1}(i64), number.2{r6}(u8)
        movzx rcx, bl
        ; call printIntLf@i64[t.2.1{r1}]
        call _printIntLf@i64
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
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
        ; branch number{r6} gteq 0: if_4_end
        cmp rbx, 0
        jge _if_4_end
        ; const arg.0.0{r1}, 45
        mov cl, 45
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; neg number.2{r6}, number{r6}
        neg rbx
_if_4_end:
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
        ; 73:2 for *str != 0
        ; move length.2{r0}, length.1{r2}
        mov rax, rdx
        jmp _for_5
_for_5_body:
        ; move length.3{r2}, length.2{r0}
        mov rdx, rax
        ; add length.3{r2}, 1
        add rdx, 1
        ; add str.2{r1}, 1
        add rcx, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rdx
_for_5:
        ; load t.2.1{r2}, [str.1{r1}]
        mov dl, [rcx]
        ; branch t.2.1{r2} notequals 0: for_5_body
        cmp dl, 0
        jne _for_5_body
        ; 76:9 return length
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
        ; branch t.3.1{r0} equals 0: if_6_then
        cmp al, 0
        je _if_6_then
        ; call printError[]
        call _printError
        jmp _if_6_end
_if_6_then:
        ; call printPass[]
        call _printPass
_if_6_end:
        ; notlog t.4.1{r1}, f.1{r7}
        or r12b, r12b
        sete cl
        ; call printIntLf@bool[t.4.1{r1}]
        call _printIntLf@bool
        ; 15:2 if !getTrue([])
        ; call t.5.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.5.1{r0} equals 0: if_7_then
        cmp al, 0
        je _if_7_then
        ; call printPass[]
        call _printPass
        jmp _if_7_end
_if_7_then:
        ; call printError[]
        call _printError
_if_7_end:
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
        ; branch t.3.1{r0} equals 0: if_8_else
        cmp al, 0
        je _if_8_else
        ; call t.4.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.4.1{r0} equals 0: if_8_else
        cmp al, 0
        je _if_8_else
        ; call printError[]
        call _printError
        jmp _if_8_end
_if_8_else:
        ; call printPass[]
        call _printPass
_if_8_end:
        ; 24:15 logic and
        ; move t.5.1{r0}, f.1{r7}
        mov al, r12b
        ; branch t.5.1{r0} notequals 0: and_2nd_10
        cmp al, 0
        jne _and_2nd_10
        ; move t.5.2{r1}, t.5.1{r0}
        mov cl, al
        jmp _and_next_10
_and_2nd_10:
        ; move t.5.3{r0}, f.1{r7}
        mov al, r12b
        ; move t.5.2{r1}, t.5.3{r0}
        mov cl, al
_and_next_10:
        ; call printIntLf@bool[t.5.2{r1}]
        call _printIntLf@bool
        ; 25:2 if getFalse([]) && getTrue([])
        ; call t.6.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.6.1{r0} equals 0: if_11_else
        cmp al, 0
        je _if_11_else
        ; call t.7.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.7.1{r0} equals 0: if_11_else
        cmp al, 0
        je _if_11_else
        ; call printError[]
        call _printError
        jmp _if_11_end
_if_11_else:
        ; call printPass[]
        call _printPass
_if_11_end:
        ; 26:15 logic and
        ; move t.8.1{r0}, f.1{r7}
        mov al, r12b
        ; branch t.8.1{r0} notequals 0: and_2nd_13
        cmp al, 0
        jne _and_2nd_13
        ; move t.8.2{r1}, t.8.1{r0}
        mov cl, al
        jmp _and_next_13
_and_2nd_13:
        ; move t.8.3{r0}, t.1{r6}
        mov al, bl
        ; move t.8.2{r1}, t.8.3{r0}
        mov cl, al
_and_next_13:
        ; call printIntLf@bool[t.8.2{r1}]
        call _printIntLf@bool
        ; 27:2 if getTrue([]) && getFalse([])
        ; call t.9.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.9.1{r0} equals 0: if_14_else
        cmp al, 0
        je _if_14_else
        ; call t.10.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.10.1{r0} equals 0: if_14_else
        cmp al, 0
        je _if_14_else
        ; call printError[]
        call _printError
        jmp _if_14_end
_if_14_else:
        ; call printPass[]
        call _printPass
_if_14_end:
        ; 28:15 logic and
        ; move t.11.1{r0}, t.1{r6}
        mov al, bl
        ; branch t.11.1{r0} notequals 0: and_2nd_16
        cmp al, 0
        jne _and_2nd_16
        ; move t.11.2{r1}, t.11.1{r0}
        mov cl, al
        jmp _and_next_16
_and_2nd_16:
        ; move t.11.3{r0}, f.1{r7}
        mov al, r12b
        ; move t.11.2{r1}, t.11.3{r0}
        mov cl, al
_and_next_16:
        ; call printIntLf@bool[t.11.2{r1}]
        call _printIntLf@bool
        ; 29:2 if getTrue([]) && getTrue([])
        ; call t.12.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.12.1{r0} equals 0: if_17_else
        cmp al, 0
        je _if_17_else
        ; call t.13.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.13.1{r0} equals 0: if_17_else
        cmp al, 0
        je _if_17_else
        ; call printPass[]
        call _printPass
        jmp _if_17_end
_if_17_else:
        ; call printError[]
        call _printError
_if_17_end:
        ; 30:15 logic and
        ; move t.14.1{r0}, t.1{r6}
        mov al, bl
        ; branch t.14.1{r0} notequals 0: and_2nd_19
        cmp al, 0
        jne _and_2nd_19
        ; move t.14.2{r1}, t.14.1{r0}
        mov cl, al
        jmp _and_next_19
_and_2nd_19:
        ; move t.14.3{r0}, t.1{r6}
        mov al, bl
        ; move t.14.2{r1}, t.14.3{r0}
        mov cl, al
_and_next_19:
        ; call printIntLf@bool[t.14.2{r1}]
        call _printIntLf@bool
        ; 32:2 if !getFalse([]) && getFalse([])
        ; call t.15.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.15.1{r0} equals 0: if_20_then
        cmp al, 0
        je _if_20_then
        ; call t.16.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.16.1{r0} equals 0: if_20_then
        cmp al, 0
        je _if_20_then
        ; call printError[]
        call _printError
        jmp _if_20_end
_if_20_then:
        ; call printPass[]
        call _printPass
_if_20_end:
        ; 33:17 logic and
        ; move t.18.1{r0}, f.1{r7}
        mov al, r12b
        ; notlog t.17.1{r1}, t.18.2{r0}
        or al, al
        sete cl
        ; call printIntLf@bool[t.17.1{r1}]
        call _printIntLf@bool
        ; 34:2 if !getFalse([]) && getTrue([])
        ; call t.19.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.19.1{r0} equals 0: if_23_then
        cmp al, 0
        je _if_23_then
        ; call t.20.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.20.1{r0} equals 0: if_23_then
        cmp al, 0
        je _if_23_then
        ; call printError[]
        call _printError
        jmp _if_23_end
_if_23_then:
        ; call printPass[]
        call _printPass
_if_23_end:
        ; 35:17 logic and
        ; move t.22.1{r0}, f.1{r7}
        mov al, r12b
        ; branch t.22.1{r0} equals 0: and_next_25
        cmp al, 0
        je _and_next_25
        ; move t.22.3{r0}, t.1{r6}
        mov al, bl
_and_next_25:
        ; notlog t.21.1{r1}, t.22.2{r0}
        or al, al
        sete cl
        ; call printIntLf@bool[t.21.1{r1}]
        call _printIntLf@bool
        ; 36:2 if !getTrue([]) && getFalse([])
        ; call t.23.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.23.1{r0} equals 0: if_26_then
        cmp al, 0
        je _if_26_then
        ; call t.24.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.24.1{r0} equals 0: if_26_then
        cmp al, 0
        je _if_26_then
        ; call printError[]
        call _printError
        jmp _if_26_end
_if_26_then:
        ; call printPass[]
        call _printPass
_if_26_end:
        ; 37:17 logic and
        ; move t.26.1{r0}, t.1{r6}
        mov al, bl
        ; branch t.26.1{r0} notequals 0: and_next_28
        cmp al, 0
        jne _and_next_28
        ; move t.26.2{r7}, t.26.1{r0}
        mov r12b, al
_and_next_28:
        ; notlog t.25.1{r1}, t.26.2{r7}
        or r12b, r12b
        sete cl
        ; call printIntLf@bool[t.25.1{r1}]
        call _printIntLf@bool
        ; 38:2 if !getTrue([]) && getTrue([])
        ; call t.27.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.27.1{r0} equals 0: if_29_then
        cmp al, 0
        je _if_29_then
        ; call t.28.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.28.1{r0} equals 0: if_29_then
        cmp al, 0
        je _if_29_then
        ; call printPass[]
        call _printPass
        jmp _if_29_end
_if_29_then:
        ; call printError[]
        call _printError
_if_29_end:
        ; 39:17 logic and
        ; move t.30.1{r7}, t.1{r6}
        mov r12b, bl
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
        ; branch t.3.1{r0} notequals 0: if_32_then
        cmp al, 0
        jne _if_32_then
        ; call t.4.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.4.1{r0} notequals 0: if_32_then
        cmp al, 0
        jne _if_32_then
        ; call printPass[]
        call _printPass
        jmp _if_32_end
_if_32_then:
        ; call printError[]
        call _printError
_if_32_end:
        ; 47:15 logic or
        ; move t.5.1{r0}, f.1{r7}
        mov al, r12b
        ; branch t.5.1{r0} equals 0: or_2nd_34
        cmp al, 0
        je _or_2nd_34
        ; move t.5.2{r1}, t.5.1{r0}
        mov cl, al
        jmp _or_next_34
_or_2nd_34:
        ; move t.5.3{r0}, f.1{r7}
        mov al, r12b
        ; move t.5.2{r1}, t.5.3{r0}
        mov cl, al
_or_next_34:
        ; call printIntLf@bool[t.5.2{r1}]
        call _printIntLf@bool
        ; 48:2 if getFalse([]) || getTrue([])
        ; call t.6.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.6.1{r0} notequals 0: if_35_then
        cmp al, 0
        jne _if_35_then
        ; call t.7.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.7.1{r0} notequals 0: if_35_then
        cmp al, 0
        jne _if_35_then
        ; call printError[]
        call _printError
        jmp _if_35_end
_if_35_then:
        ; call printPass[]
        call _printPass
_if_35_end:
        ; 49:15 logic or
        ; move t.8.1{r0}, f.1{r7}
        mov al, r12b
        ; branch t.8.1{r0} equals 0: or_2nd_37
        cmp al, 0
        je _or_2nd_37
        ; move t.8.2{r1}, t.8.1{r0}
        mov cl, al
        jmp _or_next_37
_or_2nd_37:
        ; move t.8.3{r0}, t.1{r6}
        mov al, bl
        ; move t.8.2{r1}, t.8.3{r0}
        mov cl, al
_or_next_37:
        ; call printIntLf@bool[t.8.2{r1}]
        call _printIntLf@bool
        ; 50:2 if getTrue([]) || getFalse([])
        ; call t.9.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.9.1{r0} notequals 0: if_38_then
        cmp al, 0
        jne _if_38_then
        ; call t.10.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.10.1{r0} notequals 0: if_38_then
        cmp al, 0
        jne _if_38_then
        ; call printError[]
        call _printError
        jmp _if_38_end
_if_38_then:
        ; call printPass[]
        call _printPass
_if_38_end:
        ; 51:15 logic or
        ; move t.11.1{r0}, t.1{r6}
        mov al, bl
        ; branch t.11.1{r0} equals 0: or_2nd_40
        cmp al, 0
        je _or_2nd_40
        ; move t.11.2{r1}, t.11.1{r0}
        mov cl, al
        jmp _or_next_40
_or_2nd_40:
        ; move t.11.2{r1}, t.11.3{r7}
        mov cl, r12b
_or_next_40:
        ; call printIntLf@bool[t.11.2{r1}]
        call _printIntLf@bool
        ; 52:2 if getTrue([]) || getTrue([])
        ; call t.12.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.12.1{r0} notequals 0: if_41_then
        cmp al, 0
        jne _if_41_then
        ; call t.13.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.13.1{r0} notequals 0: if_41_then
        cmp al, 0
        jne _if_41_then
        ; call printError[]
        call _printError
        jmp _if_41_end
_if_41_then:
        ; call printPass[]
        call _printPass
_if_41_end:
        ; 53:15 logic or
        ; move t.14.1{r7}, t.1{r6}
        mov r12b, bl
        ; branch t.14.1{r7} equals 0: or_2nd_43
        cmp r12b, 0
        je _or_2nd_43
        ; move t.14.2{r1}, t.14.1{r7}
        mov cl, r12b
        jmp _or_next_43
_or_2nd_43:
        ; move t.14.2{r1}, t.14.3{r6}
        mov cl, bl
_or_next_43:
        ; call printIntLf@bool[t.14.2{r1}]
        call _printIntLf@bool
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void main
        ;   rsp+48: var b.1
        ;   rsp+50: var c.1
        ;   rsp+52: var d.1
        ;   rsp+54: var t.1
        ;   rsp+55: var f.1
        ;   rsp+56: var b1.1
_main:
        sub rsp, 24
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
        ; const b.1{r0}, 1
        mov ax, 1
        ; addrof memVarAddr{r7}, b.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b.1{r0}
        mov [r12], ax
        ; const c.1{r0}, 2
        mov ax, 2
        ; addrof memVarAddr{r7}, c.1
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c.1{r0}
        mov [r12], ax
        ; const d.1{r0}, 3
        mov ax, 3
        ; addrof memVarAddr{r7}, d.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], d.1{r0}
        mov [r12], ax
        ; const t.1{r0}, 1
        mov al, 1
        ; addrof memVarAddr{r7}, t.1
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], t.1{r0}
        mov [r12], al
        ; const f.1{r0}, 0
        mov al, 0
        ; addrof memVarAddr{r7}, f.1
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], f.1{r0}
        mov [r12], al
        ; move t.10.1{r1}, a.1{r6}
        mov cx, bx
        ; and t.10.1{r1}, a.1{r6}
        and cx, bx
        ; call printIntLf@i16[t.10.1{r1}]
        call _printIntLf@i16
        ; move t.11.1{r1}, a.1{r6}
        mov cx, bx
        ; addrof memVarAddr{r7}, b.1
        lea r12, [rsp+48]
        ; load b.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; and t.11.1{r1}, b.1{r0}
        and cx, ax
        ; call printIntLf@i16[t.11.1{r1}]
        call _printIntLf@i16
        ; load b.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.12.1{r1}, b.1{r0}
        mov cx, ax
        ; and t.12.1{r1}, a.1{r6}
        and cx, bx
        ; call printIntLf@i16[t.12.1{r1}]
        call _printIntLf@i16
        ; load b.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.13.1{r1}, b.1{r0}
        mov cx, ax
        ; and t.13.1{r1}, b.1{r0}
        and cx, ax
        ; call printIntLf@i16[t.13.1{r1}]
        call _printIntLf@i16
        ; const t.14.1{r1}, [string-8]
        lea rcx, [string_8]
        ; call printString@@u8[t.14.1{r1}]
        call _printString@@u8
        ; move t.15.1{r1}, a.1{r6}
        mov cx, bx
        ; or t.15.1{r1}, a.1{r6}
        or cx, bx
        ; call printIntLf@i16[t.15.1{r1}]
        call _printIntLf@i16
        ; move t.16.1{r1}, a.1{r6}
        mov cx, bx
        ; load b.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; or t.16.1{r1}, b.1{r0}
        or cx, ax
        ; call printIntLf@i16[t.16.1{r1}]
        call _printIntLf@i16
        ; load b.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.17.1{r1}, b.1{r0}
        mov cx, ax
        ; or t.17.1{r1}, a.1{r6}
        or cx, bx
        ; call printIntLf@i16[t.17.1{r1}]
        call _printIntLf@i16
        ; load b.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.18.1{r1}, b.1{r0}
        mov cx, ax
        ; or t.18.1{r1}, b.1{r0}
        or cx, ax
        ; call printIntLf@i16[t.18.1{r1}]
        call _printIntLf@i16
        ; const t.19.1{r1}, [string-9]
        lea rcx, [string_9]
        ; call printString@@u8[t.19.1{r1}]
        call _printString@@u8
        ; move t.20.1{r1}, a.1{r6}
        mov cx, bx
        ; xor t.20.1{r1}, a.1{r6}
        xor cx, bx
        ; call printIntLf@i16[t.20.1{r1}]
        call _printIntLf@i16
        ; move t.21.1{r1}, a.1{r6}
        mov cx, bx
        ; addrof memVarAddr{r7}, c.1
        lea r12, [rsp+50]
        ; load c.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; xor t.21.1{r1}, c.1{r0}
        xor cx, ax
        ; call printIntLf@i16[t.21.1{r1}]
        call _printIntLf@i16
        ; addrof memVarAddr{r7}, b.1
        lea r12, [rsp+48]
        ; load b.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.22.1{r1}, b.1{r0}
        mov cx, ax
        ; xor t.22.1{r1}, a.1{r6}
        xor cx, bx
        ; call printIntLf@i16[t.22.1{r1}]
        call _printIntLf@i16
        ; load b.1{r6}, [memVarAddr{r7}]
        mov bx, [r12]
        ; move t.23.1{r1}, b.1{r6}
        mov cx, bx
        ; addrof memVarAddr{r7}, c.1
        lea r12, [rsp+50]
        ; load c.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; xor t.23.1{r1}, c.1{r0}
        xor cx, ax
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
        ; branch t.24.1{r0} equals 0: if_44_then
        cmp al, 0
        je _if_44_then
        ; call t.25.1{r0} = getTrue[] -> bool
        call _getTrue
        ; branch t.25.1{r0} equals 0: if_44_then
        cmp al, 0
        je _if_44_then
        ; call t.26.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.26.1{r0} equals 0: if_44_then
        cmp al, 0
        je _if_44_then
        ; call t.27.1{r0} = getFalse[] -> bool
        call _getFalse
        ; branch t.27.1{r0} equals 0: if_44_then
        cmp al, 0
        je _if_44_then
        ; call printError[]
        call _printError
        jmp _if_44_end
_if_44_then:
        ; call printPass[]
        call _printPass
_if_44_end:
        ; 88:23 logic or
        ; 88:17 logic and
        ; addrof memVarAddr{r7}, t.1
        lea r12, [rsp+54]
        ; load t.1{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move t.29.1{r2}, t.1{r0}
        mov dl, al
        ; notlog t.28.1{r0}, t.29.2{r0}
        or al, al
        sete al
        ; branch t.28.1{r0} equals 0: or_2nd_48
        cmp al, 0
        je _or_2nd_48
        ; move t.28.2{r1}, t.28.1{r0}
        mov cl, al
        jmp _or_next_48
_or_2nd_48:
        ; 88:30 logic and
        ; addrof memVarAddr{r7}, f.1
        lea r12, [rsp+55]
        ; load f.1{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move t.30.1{r2}, f.1{r0}
        mov dl, al
        ; notlog t.28.3{r0}, t.30.2{r0}
        or al, al
        sete al
        ; move t.28.2{r1}, t.28.3{r0}
        mov cl, al
_or_next_48:
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
        ; and t.33.1{r0}, b6.1{r2}
        and al, dl
        ; move t.32.1{r1}, t.33.1{r0}
        mov cl, al
        ; or t.32.1{r1}, b1.1{r3}
        or cl, r8b
        ; addrof memVarAddr{r7}, b1.1
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], b1.1{r3}
        mov [r12], r8b
        ; call printIntLf@u8[t.32.1{r1}]
        call _printIntLf@u8
        ; 95:20 logic or
        ; addrof memVarAddr{r7}, c.1
        lea r12, [rsp+50]
        ; load c.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; equals t.34.1{r2}, b.1{r6}, c.1{r0}
        cmp bx, ax
        sete dl
        ; branch t.34.1{r2} equals 0: or_2nd_51
        cmp dl, 0
        je _or_2nd_51
        ; move t.34.2{r1}, t.34.1{r2}
        mov cl, dl
        jmp _or_next_51
_or_2nd_51:
        ; addrof memVarAddr{r7}, d.1
        lea r12, [rsp+52]
        ; load d.1{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; lt t.34.3{r3}, c.1{r0}, d.1{r2}
        cmp ax, dx
        setl r8b
        ; addrof memVarAddr{r7}, c.1
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c.1{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, d.1
        lea r12, [rsp+52]
        ; move t.34.2{r1}, t.34.3{r3}
        mov cl, r8b
_or_next_51:
        ; call printIntLf@bool[t.34.2{r1}]
        call _printIntLf@bool
        ; 96:20 logic and
        ; addrof memVarAddr{r7}, c.1
        lea r12, [rsp+50]
        ; load c.1{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; equals t.35.1{r2}, b.1{r6}, c.1{r0}
        cmp bx, ax
        sete dl
        ; branch t.35.1{r2} notequals 0: and_2nd_52
        cmp dl, 0
        jne _and_2nd_52
        ; move t.35.2{r1}, t.35.1{r2}
        mov cl, dl
        jmp _and_next_52
_and_2nd_52:
        ; addrof memVarAddr{r7}, d.1
        lea r12, [rsp+52]
        ; load d.1{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; lt t.35.3{r0}, c.1{r0}, d.1{r2}
        cmp ax, dx
        setl al
        ; move t.35.2{r1}, t.35.3{r0}
        mov cl, al
_and_next_52:
        ; call printIntLf@bool[t.35.2{r1}]
        call _printIntLf@bool
        ; const arg.29.0{r1}, -1
        mov cx, -1
        ; call printIntLf@i16[arg.29.0{r1}]
        call _printIntLf@i16
        ; neg t.36.1{r1}, b.1{r6}
        mov rcx, rbx
        neg rcx
        ; call printIntLf@i16[t.36.1{r1}]
        call _printIntLf@i16
        ; addrof memVarAddr{r7}, b1.1
        lea r12, [rsp+56]
        ; load b1.1{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; not t.37.1{r1}, b1.1{r6}
        mov rcx, rbx
        not rcx
        ; call printIntLf@u8[t.37.1{r1}]
        call _printIntLf@u8
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
       Sleep,'Sleep',\
       WriteFile,'WriteFile'

import msvcrt,\
       _getch,'_getch'
