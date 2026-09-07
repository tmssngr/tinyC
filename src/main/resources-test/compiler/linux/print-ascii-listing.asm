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
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; call length{r0} = strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; move length{r2}, length{r0}
        mov rsi, rax
        ; call printStringLength@@u8@i64[str{r1}, length{r2}]
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
        ; addrof t.1{r1}, chr
        lea rdi, [rsp+32]
        ; const arg.0.1{r2}, 1
        mov sil, 1
        ; call printStringLength@@u8@u8[t.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i64 strlen@@u8
        ;   rsp+0: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 69:2 for *str != 0
        jmp _for_1
_for_1_body:
        ; add length{r0}, length{r0}, 1
        add rax, 1
        ; add str{r1}, str{r1}, 1
        add rdi, 1
_for_1:
        ; load t.2{r2}, [str{r1}]
        mov sil, [rdi]
        ; branch t.2{r2} notequals 0: for_1_body, for_1_break
        cmp sil, 0
        jne _for_1_body
        ; 72:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+0: arg str
        ;   rsp+8: arg length
_printStringLength@@u8@u8:
        sub rsp, 24
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call _printStringLength@@u8@i64
        add rsp, 24
        ret

        ; void printNibble@u8
        ;   rsp+0: arg x
_printNibble@u8:
        sub rsp, 8
        ; and x{r1}, x{r1}, 15
        and dil, 15
        ; 5:2 if x > 9
        ; branch x{r1} lteq 9: if_2_end, if_2_then
        cmp dil, 9
        jbe _if_2_end
        ; add x{r1}, x{r1}, 7
        add dil, 7
_if_2_end:
        ; add x{r1}, x{r1}, 48
        add dil, 48
        ; call printChar@u8[x{r1}]
        call _printChar@u8
        add rsp, 8
        ret

        ; void printHex2@u8
        ;   rsp+24: arg x
_printHex2@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move x{r8}, x{r1}
        mov bl, dil
        ; move t.1{r1}, x{r8}
        mov dil, bl
        ; shiftright t.1{r1}, t.1{r1}, 4
        shr dil, 4
        ; call printNibble@u8[t.1{r1}]
        call _printNibble@u8
        ; move x{r1}, x{r8}
        mov dil, bl
        ; call printNibble@u8[x{r1}]
        call _printNibble@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void main
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const t.2{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.2{r1}]
        call _printString@@u8
        ; const i{r8}, 0
        mov bl, 0
        ; 19:2 for i < 16
        jmp _for_3
_for_3_body:
        ; 20:3 if i & 7 == 0
        ; move t.3{r9}, i{r8}
        mov r12b, bl
        ; and t.3{r9}, t.3{r9}, 7
        and r12b, 7
        ; branch t.3{r9} notequals 0: if_4_end, if_4_then
        cmp r12b, 0
        jne _if_4_end
        ; const arg.1.0{r1}, 32
        mov dil, 32
        ; call printChar@u8[arg.1.0{r1}]
        call _printChar@u8
_if_4_end:
        ; move i{r1}, i{r8}
        mov dil, bl
        ; call printNibble@u8[i{r1}]
        call _printNibble@u8
        ; add i{r8}, i{r8}, 1
        add bl, 1
_for_3:
        ; branch i{r8} lt 16: for_3_body, for_3_break
        cmp bl, 16
        jb _for_3_body
        ; const arg.3.0{r1}, 10
        mov dil, 10
        ; call printChar@u8[arg.3.0{r1}]
        call _printChar@u8
        ; const i{r8}, 32
        mov bl, 32
        ; 27:2 for i < 128
        jmp _for_5
_for_5_body:
        ; 28:3 if i & 15 == 0
        ; move t.4{r9}, i{r8}
        mov r12b, bl
        ; and t.4{r9}, t.4{r9}, 15
        and r12b, 15
        ; branch t.4{r9} notequals 0: if_6_end, if_6_then
        cmp r12b, 0
        jne _if_6_end
        ; move i{r1}, i{r8}
        mov dil, bl
        ; call printHex2@u8[i{r1}]
        call _printHex2@u8
_if_6_end:
        ; 31:3 if i & 7 == 0
        ; move t.5{r9}, i{r8}
        mov r12b, bl
        ; and t.5{r9}, t.5{r9}, 7
        and r12b, 7
        ; branch t.5{r9} notequals 0: if_7_end, if_7_then
        cmp r12b, 0
        jne _if_7_end
        ; const arg.5.0{r1}, 32
        mov dil, 32
        ; call printChar@u8[arg.5.0{r1}]
        call _printChar@u8
_if_7_end:
        ; move i{r1}, i{r8}
        mov dil, bl
        ; call printChar@u8[i{r1}]
        call _printChar@u8
        ; 35:3 if i & 15 == 15
        ; move t.6{r9}, i{r8}
        mov r12b, bl
        ; and t.6{r9}, t.6{r9}, 15
        and r12b, 15
        ; branch t.6{r9} notequals 15: for_5_continue, if_8_then
        cmp r12b, 15
        jne _for_5_continue
        ; const arg.7.0{r1}, 10
        mov dil, 10
        ; call printChar@u8[arg.7.0{r1}]
        call _printChar@u8
_for_5_continue:
        ; add i{r8}, i{r8}, 1
        add bl, 1
_for_5:
        ; branch i{r8} lt 128: for_5_body, main_ret
        cmp bl, 128
        jb _for_5_body
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

segment readable
        string_0 db ' x', 0x00

