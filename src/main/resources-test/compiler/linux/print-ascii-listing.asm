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

        ; i64 strlen@@u8
        ;   rsp+0: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length.1{r2}, 0
        mov rsi, 0
        ; 69:2 for *str != 0
        ; move length.2{r0}, length.1{r2}
        mov rax, rsi
        jmp _for_1
_for_1_body:
        ; move length.3{r2}, length.2{r0}
        mov rsi, rax
        ; add length.3{r2}, 1
        add rsi, 1
        ; add str.2{r1}, 1
        add rdi, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rsi
_for_1:
        ; load t.2.1{r2}, [str.1{r1}]
        mov sil, [rdi]
        ; branch t.2.1{r2} notequals 0: for_1_body
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
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 24
        ret

        ; void printNibble@u8
        ;   rsp+24: arg x
_printNibble@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move x.1{r8}, x{r1}
        mov bl, dil
        ; and x.1{r8}, 15
        and bl, 15
        ; 5:2 if x > 9
        ; branch x.1{r8} lteq 9: if_2_end
        cmp bl, 9
        jbe _if_2_end
        ; add x.3{r8}, 7
        add bl, 7
_if_2_end:
        ; move x.4{r1}, x.2{r8}
        mov dil, bl
        ; add x.4{r1}, 48
        add dil, 48
        ; call printChar@u8[x.4{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
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
        ; shiftright t.1.1{r1}, 4
        shr dil, 4
        ; call printNibble@u8[t.1.1{r1}]
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
        ; const t.2.1{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; const i.1{r8}, 0
        mov bl, 0
        ; 19:2 for i < 16
        jmp _for_3
_for_3_body:
        ; 20:3 if i & 7 == 0
        ; move t.3.1{r9}, i.2{r8}
        mov r12b, bl
        ; and t.3.1{r9}, 7
        and r12b, 7
        ; branch t.3.1{r9} notequals 0: if_4_end
        cmp r12b, 0
        jne _if_4_end
        ; const arg.1.0{r1}, 32
        mov dil, 32
        ; call printChar@u8[arg.1.0{r1}]
        call _printChar@u8
_if_4_end:
        ; move i.2{r1}, i.2{r8}
        mov dil, bl
        ; call printNibble@u8[i.2{r1}]
        call _printNibble@u8
        ; add i.7{r8}, 1
        add bl, 1
_for_3:
        ; branch i.2{r8} lt 16: for_3_body
        cmp bl, 16
        jb _for_3_body
        ; const arg.3.0{r1}, 10
        mov dil, 10
        ; call printChar@u8[arg.3.0{r1}]
        call _printChar@u8
        ; const i.3{r8}, 32
        mov bl, 32
        ; 27:2 for i < 128
        jmp _for_5
_for_5_body:
        ; 28:3 if i & 15 == 0
        ; move t.4.1{r9}, i.4{r8}
        mov r12b, bl
        ; and t.4.1{r9}, 15
        and r12b, 15
        ; branch t.4.1{r9} notequals 0: if_6_end
        cmp r12b, 0
        jne _if_6_end
        ; move i.4{r1}, i.4{r8}
        mov dil, bl
        ; call printHex2@u8[i.4{r1}]
        call _printHex2@u8
_if_6_end:
        ; 31:3 if i & 7 == 0
        ; move t.5.1{r9}, i.4{r8}
        mov r12b, bl
        ; and t.5.1{r9}, 7
        and r12b, 7
        ; branch t.5.1{r9} notequals 0: if_7_end
        cmp r12b, 0
        jne _if_7_end
        ; const arg.5.0{r1}, 32
        mov dil, 32
        ; call printChar@u8[arg.5.0{r1}]
        call _printChar@u8
_if_7_end:
        ; move i.4{r1}, i.4{r8}
        mov dil, bl
        ; call printChar@u8[i.4{r1}]
        call _printChar@u8
        ; 35:3 if i & 15 == 15
        ; move t.6.1{r9}, i.4{r8}
        mov r12b, bl
        ; and t.6.1{r9}, 15
        and r12b, 15
        ; branch t.6.1{r9} notequals 15: for_5_continue
        cmp r12b, 15
        jne _for_5_continue
        ; const arg.7.0{r1}, 10
        mov dil, 10
        ; call printChar@u8[arg.7.0{r1}]
        call _printChar@u8
_for_5_continue:
        ; move i.10{r0}, i.4{r8}
        mov al, bl
        ; add i.10{r0}, 1
        add al, 1
        ; move i.4{r8}, i.10{r0}
        mov bl, al
_for_5:
        ; branch i.4{r8} lt 128: for_5_body
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

