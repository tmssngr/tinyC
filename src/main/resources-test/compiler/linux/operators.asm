format ELF64 executable 3
segment executable
entry _start

_start:
        call _main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void _printString@@u8
        ;   rsp+24: arg str
_printString@@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move str{r8}, str{r1}
        mov rbx, rdi
        ; call length.1{r0} = _strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; move length.1{r2}, length.1{r0}
        mov rsi, rax
        ; call _printStringLength@@u8@i64[str{r1}, length.1{r2}]
        call _printStringLength@@u8@i64
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void _printChar@u8
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
        ; call _printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void _printUint@i64
        ;   rsp+0: arg number
        ;   rsp+20: var buffer
_printUint@i64:
        sub rsp, 40
        ; const pos.1{r0}, 20
        mov al, 20
        ; 33:2 while true
        jmp while_1
_printUint@i64.no_critical_edge_4:
        ; move pos.2{r0}, pos.3{r2}
        mov al, sil
while_1:
        ; move pos.3{r2}, pos.2{r0}
        mov sil, al
        ; sub pos.3{r2}, 1
        sub sil, 1
        ; move remainder.1{r5}, number.1{r1}
        mov r8, rdi
        ; move remainder.1{r0}, remainder.1{r5}
        mov rax, r8
        ; mod remainder.1{r3}, remainder.1{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder.1{r5}, remainder.1{r3}
        mov r8, rdx
        ; move number.2{r0}, number.2{r1}
        mov rax, rdi
        ; div number.2{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number.2{r1}, number.2{r0}
        mov rdi, rax
        ; cast t.5.1{r0}(u8), remainder.1{r5}(i64)
        mov al, r8b
        ; add digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r3}(i64), pos.3{r2}(u8)
        movzx rdx, sil
        ; addrof t.6.1{r4}, buffer
        lea rcx, [rsp+20]
        ; add t.6.2{r4}, t.7.1{r3}
        add rcx, rdx
        ; store [t.6.2{r4}], digit.1{r0}
        mov [rcx], al
        ; 39:3 if number == 0
        ; branch number.2{r1} notequals 0: _printUint@i64.no_critical_edge_4
        cmp rdi, 0
        jne _printUint@i64.no_critical_edge_4
        ; move t.8.2{r1}, t.8.2{r4}
        mov rdi, rcx
        ; const t.11.1{r0}, 20
        mov al, 20
        ; sub t.10.1{r0}, pos.3{r2}
        sub al, sil
        ; move t.10.1{r2}, t.10.1{r0}
        mov sil, al
        ; call _printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 40
        ret

        ; void _printIntLf@bool
        ;   rsp+0: arg value
_printIntLf@bool:
        sub rsp, 8
        ; const number.1{r0}, 0
        mov al, 0
        ; 48:2 if value
        ; branch value{r1} equals 0: if_3_end
        cmp dil, 0
        je if_3_end
        ; const number.3{r0}, 1
        mov al, 1
if_3_end:
        ; cast t.2.1{r1}(i64), number.2{r0}(u8)
        movzx rdi, al
        ; call _printIntLf@i64[t.2.1{r1}]
        call _printIntLf@i64
        add rsp, 8
        ret

        ; void _printIntLf@u8
        ;   rsp+0: arg number
_printIntLf@u8:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(u8)
        movzx rdi, dil
        ; call _printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 8
        ret

        ; void _printIntLf@i16
        ;   rsp+0: arg number
_printIntLf@i16:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(i16)
        movsx rdi, di
        ; call _printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 8
        ret

        ; void _printIntLf@i64
        ;   rsp+24: arg number
_printIntLf@i64:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move number{r8}, number{r1}
        mov rbx, rdi
        ; branch number{r8} gteq 0: if_4_end
        cmp rbx, 0
        jge if_4_end
        ; const arg.0.0{r1}, 45
        mov dil, 45
        ; call _printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; neg number.2{r0}, number{r8}
        mov rax, rbx
        neg rax
        ; move number.1{r8}, number.2{r0}
        mov rbx, rax
if_4_end:
        ; move number.1{r1}, number.1{r8}
        mov rdi, rbx
        ; call _printUint@i64[number.1{r1}]
        call _printUint@i64
        ; const arg.2.0{r1}, 10
        mov dil, 10
        ; call _printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; i64 _strlen@@u8
        ;   rsp+0: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length.1{r0}, 0
        mov rax, 0
        ; 73:2 for *str != 0
        jmp for_5
for_5_body:
        ; add length.3{r0}, 1
        add rax, 1
        ; add str.2{r1}, 1
        add rdi, 1
for_5:
        ; load t.2.1{r2}, [str.1{r1}]
        mov sil, [rdi]
        ; branch t.2.1{r2} notequals 0: for_5_body
        cmp sil, 0
        jne for_5_body
        ; 76:9 return length
        add rsp, 8
        ret

        ; void _printStringLength@@u8@u8
        ;   rsp+0: arg str
        ;   rsp+8: arg length
_printStringLength@@u8@u8:
        sub rsp, 24
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call _printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 24
        ret

        ; bool _getTrue
_getTrue:
        sub rsp, 8
        ; const t.0.1{r1}, [string-1]
        lea rdi, [string_1]
        ; call _printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; const {r0}, 1
        mov al, 1
        add rsp, 8
        ret

        ; bool _getFalse
_getFalse:
        sub rsp, 8
        ; const t.0.1{r1}, [string-2]
        lea rdi, [string_2]
        ; call _printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; const {r0}, 0
        mov al, 0
        add rsp, 8
        ret

        ; void _printPass
_printPass:
        sub rsp, 8
        ; const t.0.1{r1}, [string-3]
        lea rdi, [string_3]
        ; call _printString@@u8[t.0.1{r1}]
        call _printString@@u8
        add rsp, 8
        ret

        ; void _printError
_printError:
        sub rsp, 8
        ; const t.0.1{r1}, [string-4]
        lea rdi, [string_4]
        ; call _printString@@u8[t.0.1{r1}]
        call _printString@@u8
        add rsp, 8
        ret

        ; void _logicNot
_logicNot:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const t.2.1{r1}, [string-5]
        lea rdi, [string_5]
        ; call _printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; const t.1{r8}, 1
        mov bl, 1
        ; const f.1{r9}, 0
        mov r12b, 0
        ; 13:2 if !_getFalse([])
        ; call t.3.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.3.1{r0} equals 0: if_6_then
        cmp al, 0
        je if_6_then
        ; call _printError[]
        call _printError
        jmp if_6_end
if_6_then:
        ; call _printPass[]
        call _printPass
if_6_end:
        ; notlog t.4.1{r1}, f.1{r9}
        or r12b, r12b
        sete dil
        ; call _printIntLf@bool[t.4.1{r1}]
        call _printIntLf@bool
        ; 15:2 if !_getTrue([])
        ; call t.5.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.5.1{r0} equals 0: if_7_then
        cmp al, 0
        je if_7_then
        ; call _printPass[]
        call _printPass
        jmp if_7_end
if_7_then:
        ; call _printError[]
        call _printError
if_7_end:
        ; notlog t.6.1{r1}, t.1{r8}
        or bl, bl
        sete dil
        ; call _printIntLf@bool[t.6.1{r1}]
        call _printIntLf@bool
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void _logicAnd
_logicAnd:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const t.2.1{r1}, [string-6]
        lea rdi, [string_6]
        ; call _printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; const t.1{r8}, 1
        mov bl, 1
        ; const f.1{r9}, 0
        mov r12b, 0
        ; 23:2 if _getFalse([]) && _getFalse([])
        ; call t.3.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.3.1{r0} equals 0: if_8_else
        cmp al, 0
        je if_8_else
        ; call t.4.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.4.1{r0} equals 0: if_8_else
        cmp al, 0
        je if_8_else
        ; call _printError[]
        call _printError
        jmp if_8_end
if_8_else:
        ; call _printPass[]
        call _printPass
if_8_end:
        ; 24:15 logic and
        ; move t.5.1{r0}, f.1{r9}
        mov al, r12b
        ; branch t.5.1{r0} notequals 0: and_2nd_10
        cmp al, 0
        jne and_2nd_10
        ; move t.5.2{r1}, t.5.1{r0}
        mov dil, al
        jmp and_next_10
and_2nd_10:
        ; move t.5.3{r0}, f.1{r9}
        mov al, r12b
        ; move t.5.2{r1}, t.5.3{r0}
        mov dil, al
and_next_10:
        ; call _printIntLf@bool[t.5.2{r1}]
        call _printIntLf@bool
        ; 25:2 if _getFalse([]) && _getTrue([])
        ; call t.6.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.6.1{r0} equals 0: if_11_else
        cmp al, 0
        je if_11_else
        ; call t.7.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.7.1{r0} equals 0: if_11_else
        cmp al, 0
        je if_11_else
        ; call _printError[]
        call _printError
        jmp if_11_end
if_11_else:
        ; call _printPass[]
        call _printPass
if_11_end:
        ; 26:15 logic and
        ; move t.8.1{r0}, f.1{r9}
        mov al, r12b
        ; branch t.8.1{r0} notequals 0: and_2nd_13
        cmp al, 0
        jne and_2nd_13
        ; move t.8.2{r1}, t.8.1{r0}
        mov dil, al
        jmp and_next_13
and_2nd_13:
        ; move t.8.3{r0}, t.1{r8}
        mov al, bl
        ; move t.8.2{r1}, t.8.3{r0}
        mov dil, al
and_next_13:
        ; call _printIntLf@bool[t.8.2{r1}]
        call _printIntLf@bool
        ; 27:2 if _getTrue([]) && _getFalse([])
        ; call t.9.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.9.1{r0} equals 0: if_14_else
        cmp al, 0
        je if_14_else
        ; call t.10.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.10.1{r0} equals 0: if_14_else
        cmp al, 0
        je if_14_else
        ; call _printError[]
        call _printError
        jmp if_14_end
if_14_else:
        ; call _printPass[]
        call _printPass
if_14_end:
        ; 28:15 logic and
        ; move t.11.1{r0}, t.1{r8}
        mov al, bl
        ; branch t.11.1{r0} notequals 0: and_2nd_16
        cmp al, 0
        jne and_2nd_16
        ; move t.11.2{r1}, t.11.1{r0}
        mov dil, al
        jmp and_next_16
and_2nd_16:
        ; move t.11.3{r0}, f.1{r9}
        mov al, r12b
        ; move t.11.2{r1}, t.11.3{r0}
        mov dil, al
and_next_16:
        ; call _printIntLf@bool[t.11.2{r1}]
        call _printIntLf@bool
        ; 29:2 if _getTrue([]) && _getTrue([])
        ; call t.12.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.12.1{r0} equals 0: if_17_else
        cmp al, 0
        je if_17_else
        ; call t.13.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.13.1{r0} equals 0: if_17_else
        cmp al, 0
        je if_17_else
        ; call _printPass[]
        call _printPass
        jmp if_17_end
if_17_else:
        ; call _printError[]
        call _printError
if_17_end:
        ; 30:15 logic and
        ; move t.14.1{r0}, t.1{r8}
        mov al, bl
        ; branch t.14.1{r0} notequals 0: and_2nd_19
        cmp al, 0
        jne and_2nd_19
        ; move t.14.2{r1}, t.14.1{r0}
        mov dil, al
        jmp and_next_19
and_2nd_19:
        ; move t.14.3{r0}, t.1{r8}
        mov al, bl
        ; move t.14.2{r1}, t.14.3{r0}
        mov dil, al
and_next_19:
        ; call _printIntLf@bool[t.14.2{r1}]
        call _printIntLf@bool
        ; 32:2 if !_getFalse([]) && _getFalse([])
        ; call t.15.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.15.1{r0} equals 0: if_20_then
        cmp al, 0
        je if_20_then
        ; call t.16.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.16.1{r0} equals 0: if_20_then
        cmp al, 0
        je if_20_then
        ; call _printError[]
        call _printError
        jmp if_20_end
if_20_then:
        ; call _printPass[]
        call _printPass
if_20_end:
        ; 33:17 logic and
        ; move t.18.1{r0}, f.1{r9}
        mov al, r12b
        ; notlog t.17.1{r1}, t.18.2{r0}
        or al, al
        sete dil
        ; call _printIntLf@bool[t.17.1{r1}]
        call _printIntLf@bool
        ; 34:2 if !_getFalse([]) && _getTrue([])
        ; call t.19.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.19.1{r0} equals 0: if_23_then
        cmp al, 0
        je if_23_then
        ; call t.20.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.20.1{r0} equals 0: if_23_then
        cmp al, 0
        je if_23_then
        ; call _printError[]
        call _printError
        jmp if_23_end
if_23_then:
        ; call _printPass[]
        call _printPass
if_23_end:
        ; 35:17 logic and
        ; move t.22.1{r0}, f.1{r9}
        mov al, r12b
        ; branch t.22.1{r0} equals 0: and_next_25
        cmp al, 0
        je and_next_25
        ; move t.22.3{r0}, t.1{r8}
        mov al, bl
and_next_25:
        ; notlog t.21.1{r1}, t.22.2{r0}
        or al, al
        sete dil
        ; call _printIntLf@bool[t.21.1{r1}]
        call _printIntLf@bool
        ; 36:2 if !_getTrue([]) && _getFalse([])
        ; call t.23.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.23.1{r0} equals 0: if_26_then
        cmp al, 0
        je if_26_then
        ; call t.24.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.24.1{r0} equals 0: if_26_then
        cmp al, 0
        je if_26_then
        ; call _printError[]
        call _printError
        jmp if_26_end
if_26_then:
        ; call _printPass[]
        call _printPass
if_26_end:
        ; 37:17 logic and
        ; move t.26.1{r0}, t.1{r8}
        mov al, bl
        ; branch t.26.1{r0} equals 0: and_next_28
        cmp al, 0
        je and_next_28
        ; move t.26.3{r0}, f.1{r9}
        mov al, r12b
and_next_28:
        ; notlog t.25.1{r1}, t.26.2{r0}
        or al, al
        sete dil
        ; call _printIntLf@bool[t.25.1{r1}]
        call _printIntLf@bool
        ; 38:2 if !_getTrue([]) && _getTrue([])
        ; call t.27.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.27.1{r0} equals 0: if_29_then
        cmp al, 0
        je if_29_then
        ; call t.28.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.28.1{r0} equals 0: if_29_then
        cmp al, 0
        je if_29_then
        ; call _printPass[]
        call _printPass
        jmp if_29_end
if_29_then:
        ; call _printError[]
        call _printError
if_29_end:
        ; 39:17 logic and
        ; move t.30.1{r0}, t.1{r8}
        mov al, bl
        ; notlog t.29.1{r1}, t.30.2{r0}
        or al, al
        sete dil
        ; call _printIntLf@bool[t.29.1{r1}]
        call _printIntLf@bool
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void _logicOr
_logicOr:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const t.2.1{r1}, [string-7]
        lea rdi, [string_7]
        ; call _printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; const t.1{r8}, 1
        mov bl, 1
        ; const f.1{r9}, 0
        mov r12b, 0
        ; 46:2 if _getFalse([]) || _getFalse([])
        ; call t.3.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.3.1{r0} notequals 0: if_32_then
        cmp al, 0
        jne if_32_then
        ; call t.4.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.4.1{r0} notequals 0: if_32_then
        cmp al, 0
        jne if_32_then
        ; call _printPass[]
        call _printPass
        jmp if_32_end
if_32_then:
        ; call _printError[]
        call _printError
if_32_end:
        ; 47:15 logic or
        ; move t.5.1{r0}, f.1{r9}
        mov al, r12b
        ; branch t.5.1{r0} equals 0: or_2nd_34
        cmp al, 0
        je or_2nd_34
        ; move t.5.2{r1}, t.5.1{r0}
        mov dil, al
        jmp or_next_34
or_2nd_34:
        ; move t.5.3{r0}, f.1{r9}
        mov al, r12b
        ; move t.5.2{r1}, t.5.3{r0}
        mov dil, al
or_next_34:
        ; call _printIntLf@bool[t.5.2{r1}]
        call _printIntLf@bool
        ; 48:2 if _getFalse([]) || _getTrue([])
        ; call t.6.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.6.1{r0} notequals 0: if_35_then
        cmp al, 0
        jne if_35_then
        ; call t.7.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.7.1{r0} notequals 0: if_35_then
        cmp al, 0
        jne if_35_then
        ; call _printError[]
        call _printError
        jmp if_35_end
if_35_then:
        ; call _printPass[]
        call _printPass
if_35_end:
        ; 49:15 logic or
        ; move t.8.1{r0}, f.1{r9}
        mov al, r12b
        ; branch t.8.1{r0} equals 0: or_2nd_37
        cmp al, 0
        je or_2nd_37
        ; move t.8.2{r1}, t.8.1{r0}
        mov dil, al
        jmp or_next_37
or_2nd_37:
        ; move t.8.3{r0}, t.1{r8}
        mov al, bl
        ; move t.8.2{r1}, t.8.3{r0}
        mov dil, al
or_next_37:
        ; call _printIntLf@bool[t.8.2{r1}]
        call _printIntLf@bool
        ; 50:2 if _getTrue([]) || _getFalse([])
        ; call t.9.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.9.1{r0} notequals 0: if_38_then
        cmp al, 0
        jne if_38_then
        ; call t.10.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.10.1{r0} notequals 0: if_38_then
        cmp al, 0
        jne if_38_then
        ; call _printError[]
        call _printError
        jmp if_38_end
if_38_then:
        ; call _printPass[]
        call _printPass
if_38_end:
        ; 51:15 logic or
        ; move t.11.1{r0}, t.1{r8}
        mov al, bl
        ; branch t.11.1{r0} equals 0: or_2nd_40
        cmp al, 0
        je or_2nd_40
        ; move t.11.2{r1}, t.11.1{r0}
        mov dil, al
        jmp or_next_40
or_2nd_40:
        ; move t.11.3{r0}, f.1{r9}
        mov al, r12b
        ; move t.11.2{r1}, t.11.3{r0}
        mov dil, al
or_next_40:
        ; call _printIntLf@bool[t.11.2{r1}]
        call _printIntLf@bool
        ; 52:2 if _getTrue([]) || _getTrue([])
        ; call t.12.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.12.1{r0} notequals 0: if_41_then
        cmp al, 0
        jne if_41_then
        ; call t.13.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.13.1{r0} notequals 0: if_41_then
        cmp al, 0
        jne if_41_then
        ; call _printError[]
        call _printError
        jmp if_41_end
if_41_then:
        ; call _printPass[]
        call _printPass
if_41_end:
        ; 53:15 logic or
        ; move t.14.1{r0}, t.1{r8}
        mov al, bl
        ; branch t.14.1{r0} equals 0: or_2nd_43
        cmp al, 0
        je or_2nd_43
        ; move t.14.2{r1}, t.14.1{r0}
        mov dil, al
        jmp or_next_43
or_2nd_43:
        ; move t.14.3{r0}, t.1{r8}
        mov al, bl
        ; move t.14.2{r1}, t.14.3{r0}
        mov dil, al
or_next_43:
        ; call _printIntLf@bool[t.14.2{r1}]
        call _printIntLf@bool
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void _main
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
        ; const t.9.1{r1}, [string-8]
        lea rdi, [string_8]
        ; call _printString@@u8[t.9.1{r1}]
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
        ; call _printIntLf@i16[t.10.1{r1}]
        call _printIntLf@i16
        ; move t.11.1{r1}, a.1{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, b.1
        lea r12, [rsp+32]
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; and t.11.1{r1}, b.1{r0}
        and di, ax
        ; call _printIntLf@i16[t.11.1{r1}]
        call _printIntLf@i16
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.12.1{r1}, b.1{r0}
        mov di, ax
        ; and t.12.1{r1}, a.1{r8}
        and di, bx
        ; call _printIntLf@i16[t.12.1{r1}]
        call _printIntLf@i16
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.13.1{r1}, b.1{r0}
        mov di, ax
        ; and t.13.1{r1}, b.1{r0}
        and di, ax
        ; call _printIntLf@i16[t.13.1{r1}]
        call _printIntLf@i16
        ; const t.14.1{r1}, [string-9]
        lea rdi, [string_9]
        ; call _printString@@u8[t.14.1{r1}]
        call _printString@@u8
        ; move t.15.1{r1}, a.1{r8}
        mov di, bx
        ; or t.15.1{r1}, a.1{r8}
        or di, bx
        ; call _printIntLf@i16[t.15.1{r1}]
        call _printIntLf@i16
        ; move t.16.1{r1}, a.1{r8}
        mov di, bx
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; or t.16.1{r1}, b.1{r0}
        or di, ax
        ; call _printIntLf@i16[t.16.1{r1}]
        call _printIntLf@i16
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.17.1{r1}, b.1{r0}
        mov di, ax
        ; or t.17.1{r1}, a.1{r8}
        or di, bx
        ; call _printIntLf@i16[t.17.1{r1}]
        call _printIntLf@i16
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.18.1{r1}, b.1{r0}
        mov di, ax
        ; or t.18.1{r1}, b.1{r0}
        or di, ax
        ; call _printIntLf@i16[t.18.1{r1}]
        call _printIntLf@i16
        ; const t.19.1{r1}, [string-10]
        lea rdi, [string_10]
        ; call _printString@@u8[t.19.1{r1}]
        call _printString@@u8
        ; move t.20.1{r1}, a.1{r8}
        mov di, bx
        ; xor t.20.1{r1}, a.1{r8}
        xor di, bx
        ; call _printIntLf@i16[t.20.1{r1}]
        call _printIntLf@i16
        ; move t.21.1{r1}, a.1{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; xor t.21.1{r1}, c.1{r0}
        xor di, ax
        ; call _printIntLf@i16[t.21.1{r1}]
        call _printIntLf@i16
        ; addrof memVarAddr{r9}, b.1
        lea r12, [rsp+32]
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.22.1{r1}, b.1{r0}
        mov di, ax
        ; xor t.22.1{r1}, a.1{r8}
        xor di, bx
        ; call _printIntLf@i16[t.22.1{r1}]
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
        ; call _printIntLf@i16[t.23.1{r1}]
        call _printIntLf@i16
        ; call _logicNot[]
        call _logicNot
        ; call _logicAnd[]
        call _logicAnd
        ; call _logicOr[]
        call _logicOr
        ; 82:2 if !_getTrue([]) && _getTrue([]) || !_getFalse([]) && _getFalse([])
        ; call t.24.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.24.1{r0} equals 0: if_44_then
        cmp al, 0
        je if_44_then
        ; call t.25.1{r0} = _getTrue[] -> bool
        call _getTrue
        ; branch t.25.1{r0} equals 0: if_44_then
        cmp al, 0
        je if_44_then
        ; call t.26.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.26.1{r0} equals 0: if_44_then
        cmp al, 0
        je if_44_then
        ; call t.27.1{r0} = _getFalse[] -> bool
        call _getFalse
        ; branch t.27.1{r0} equals 0: if_44_then
        cmp al, 0
        je if_44_then
        ; call _printError[]
        call _printError
        jmp if_44_end
if_44_then:
        ; call _printPass[]
        call _printPass
if_44_end:
        ; 88:23 logic or
        ; 88:17 logic and
        ; addrof memVarAddr{r9}, t.1
        lea r12, [rsp+38]
        ; load t.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.29.1{r1}, t.1{r0}
        mov dil, al
        ; notlog t.28.1{r0}, t.29.2{r0}
        or al, al
        sete al
        ; branch t.28.1{r0} equals 0: or_2nd_48
        cmp al, 0
        je or_2nd_48
        ; move t.28.2{r1}, t.28.1{r0}
        mov dil, al
        jmp or_next_48
or_2nd_48:
        ; 88:30 logic and
        ; addrof memVarAddr{r9}, f.1
        lea r12, [rsp+39]
        ; load f.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; notlog t.28.3{r0}, t.30.2{r0}
        or al, al
        sete al
        ; move t.28.2{r1}, t.28.3{r0}
        mov dil, al
or_next_48:
        ; call _printIntLf@bool[t.28.2{r1}]
        call _printIntLf@bool
        ; const t.31.1{r1}, [string-11]
        lea rdi, [string_11]
        ; call _printString@@u8[t.31.1{r1}]
        call _printString@@u8
        ; const b10.1{r0}, 10
        mov al, 10
        ; const b6.1{r1}, 6
        mov dil, 6
        ; const b1.1{r2}, 1
        mov sil, 1
        ; and t.33.1{r0}, b6.1{r1}
        and al, dil
        ; move t.32.1{r1}, t.33.1{r0}
        mov dil, al
        ; or t.32.1{r1}, b1.1{r2}
        or dil, sil
        ; addrof memVarAddr{r9}, b1.1
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], b1.1{r2}
        mov [r12], sil
        ; call _printIntLf@u8[t.32.1{r1}]
        call _printIntLf@u8
        ; 95:20 logic or
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; equals t.34.1{r1}, b.1{r8}, c.1{r0}
        cmp bx, ax
        sete dil
        ; branch t.34.1{r1} notequals 0: or_next_51
        cmp dil, 0
        jne or_next_51
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+36]
        ; load d.1{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; lt t.34.3{r2}, c.1{r0}, d.1{r1}
        cmp ax, di
        setl sil
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+36]
        ; move t.34.2{r1}, t.34.3{r2}
        mov dil, sil
or_next_51:
        ; call _printIntLf@bool[t.34.2{r1}]
        call _printIntLf@bool
        ; 96:20 logic and
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; equals t.35.1{r1}, b.1{r8}, c.1{r0}
        cmp bx, ax
        sete dil
        ; branch t.35.1{r1} equals 0: and_next_52
        cmp dil, 0
        je and_next_52
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+36]
        ; load d.1{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; lt t.35.3{r0}, c.1{r0}, d.1{r1}
        cmp ax, di
        setl al
        ; move t.35.2{r1}, t.35.3{r0}
        mov dil, al
and_next_52:
        ; call _printIntLf@bool[t.35.2{r1}]
        call _printIntLf@bool
        ; const arg.29.0{r1}, -1
        mov di, -1
        ; call _printIntLf@i16[arg.29.0{r1}]
        call _printIntLf@i16
        ; neg t.36.1{r1}, b.1{r8}
        mov rdi, rbx
        neg rdi
        ; call _printIntLf@i16[t.36.1{r1}]
        call _printIntLf@i16
        ; addrof memVarAddr{r9}, b1.1
        lea r12, [rsp+40]
        ; load b1.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; not t.37.1{r1}, b1.1{r0}
        mov rdi, rax
        not rdi
        ; call _printIntLf@u8[t.37.1{r1}]
        call _printIntLf@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void _printStringLength@@u8@i64
_printStringLength@@u8@i64:
        mov rdx, rsi
        mov rsi, rdi
        mov rdi, 1
        mov rax, 1
        syscall
        ret

segment readable
        string_1 db ' true', 0x00
        string_2 db ' false', 0x00
        string_3 db ' -> pass ', 0x00
        string_4 db ' -> ERROR ', 0x00
        string_5 db 0x0a, 'Logic-!:', 0x0a, 0x00
        string_6 db 0x0a, 'Logic-&&:', 0x0a, 0x00
        string_7 db 0x0a, 'Logic-||:', 0x0a, 0x00
        string_8 db 'Bit-&:', 0x0a, 0x00
        string_9 db 0x0a, 'Bit-|:', 0x0a, 0x00
        string_10 db 0x0a, 'Bit-^:', 0x0a, 0x00
        string_11 db 0x0a, 0x0a, 'misc:', 0x0a, 0x00

