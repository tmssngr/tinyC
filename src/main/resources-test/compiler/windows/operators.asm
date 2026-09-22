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
        sub rsp, 8
          call init
        add rsp, 8
          call _main
        mov rcx, 0
        sub rsp, 0x20
          call [ExitProcess]

        ; void printString@@u8
        ;   rsp+24: arg str
        ;   rsp+0: var length.1
_printString@@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; call length.1 = strlen@@u8[str] -> i64
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call _strlen@@u8
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@i64[str, length.1]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call _printStringLength@@u8@i64
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printChar@u8
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1.1
_printChar@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof t.1.1, chr
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@u8[t.1.1, 1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
        mov  rax, 1
        push rax
        sub rsp, 8
          call _printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint@i64
        ;   rsp+136: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos.1
        ;   rsp+24: var number.1
        ;   rsp+32: var pos.2
        ;   rsp+33: var pos.3
        ;   rsp+40: var remainder.1
        ;   rsp+48: var number.2
        ;   rsp+56: var t.5.1
        ;   rsp+57: var digit.1
        ;   rsp+64: var t.7.1
        ;   rsp+72: var t.6.1
        ;   rsp+80: var t.6.2
        ;   rsp+88: var t.9.1
        ;   rsp+96: var t.8.1
        ;   rsp+104: var t.8.2
        ;   rsp+112: var t.11.1
        ;   rsp+113: var t.10.1
_printUint@i64:
        ; reserve space for local variables
        sub rsp, 128
        ; const pos.1, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 28:2 while true
        ; move number.1, number
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; move pos.2, pos.1
        lea rax, [rsp+20]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
        jmp _while_1
_printUint@i64.no_critical_edge_4:
        ; move number.1, number.2
        lea rax, [rsp+48]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; move pos.2, pos.3
        lea rax, [rsp+33]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
_while_1:
        ; move pos.3, pos.2
        lea rax, [rsp+32]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov [rax], bl
        ; sub pos.3, pos.3, 1
        lea rax, [rsp+33]
        mov bl, [rax]
        sub bl, 1
        lea rax, [rsp+33]
        mov [rax], bl
        ; move remainder.1, number.1
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov [rax], rbx
        ; mod remainder.1, remainder.1, 10
        lea rax, [rsp+40]
        mov rbx, [rax]
        mov rax, rbx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+40]
        mov [rcx], rbx
        ; move number.2, number.1
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+48]
        mov [rax], rbx
        ; div number.2, number.2, 10
        lea rax, [rsp+48]
        mov rbx, [rax]
        mov rax, rbx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rax
        lea rcx, [rsp+48]
        mov [rcx], rbx
        ; cast t.5.1(u8), remainder.1(i64)
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], bl
        ; move digit.1, t.5.1
        lea rax, [rsp+56]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov [rax], bl
        ; add digit.1, digit.1, 48
        lea rax, [rsp+57]
        mov bl, [rax]
        add bl, 48
        lea rax, [rsp+57]
        mov [rax], bl
        ; cast t.7.1(i64), pos.3(u8)
        lea rax, [rsp+33]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+64]
        mov [rax], rbx
        ; addrof t.6.1, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; move t.6.2, t.6.1
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov [rax], rbx
        ; add t.6.2, t.6.2, t.7.1
        lea rax, [rsp+80]
        mov rbx, [rax]
        lea rax, [rsp+64]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+80]
        mov [rax], rbx
        ; store [t.6.2], digit.1
        lea rax, [rsp+80]
        mov rbx, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        mov [rbx], cl
        ; 34:3 if number == 0
        ; branch number.2 notequals 0: printUint@i64.no_critical_edge_4, while_1_break
        lea rax, [rsp+48]
        mov rbx, [rax]
        cmp rbx, 0
        jne _printUint@i64.no_critical_edge_4
        ; cast t.9.1(i64), pos.3(u8)
        lea rax, [rsp+33]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+88]
        mov [rax], rbx
        ; addrof t.8.1, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; move t.8.2, t.8.1
        lea rax, [rsp+96]
        mov rbx, [rax]
        lea rax, [rsp+104]
        mov [rax], rbx
        ; add t.8.2, t.8.2, t.9.1
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+88]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+104]
        mov [rax], rbx
        ; const t.11.1, 20
        mov al, 20
        lea rbx, [rsp+112]
        mov [rbx], al
        ; move t.10.1, t.11.1
        lea rax, [rsp+112]
        mov bl, [rax]
        lea rax, [rsp+113]
        mov [rax], bl
        ; sub t.10.1, t.10.1, pos.3
        lea rax, [rsp+113]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+113]
        mov [rax], bl
        ; call printStringLength@@u8@u8[t.8.2, t.10.1]
        lea rax, [rsp+104]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+121]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call _printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 128
        ret

        ; void printIntLf@bool
        ;   rsp+24: arg number
        ;   rsp+0: var t.1.1
_printIntLf@bool:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1.1(i64), number(bool)
        lea rax, [rsp+24]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printIntLf@i64[t.1.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printIntLf@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printIntLf@u8
        ;   rsp+24: arg number
        ;   rsp+0: var t.1.1
_printIntLf@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1.1(i64), number(u8)
        lea rax, [rsp+24]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printIntLf@i64[t.1.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printIntLf@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printIntLf@i16
        ;   rsp+24: arg number
        ;   rsp+0: var t.1.1
_printIntLf@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1.1(i64), number(i16)
        lea rax, [rsp+24]
        mov bx, [rax]
        movsx rbx, bx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printIntLf@i64[t.1.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printIntLf@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printIntLf@i64
        ;   rsp+24: arg number
        ;   rsp+0: var number.1
        ;   rsp+8: var number.2
_printIntLf@i64:
        ; reserve space for local variables
        sub rsp, 16
        ; branch number lt 0: if_3_then, printIntLf@i64.no_critical_edge_4
        lea rax, [rsp+24]
        mov rbx, [rax]
        cmp rbx, 0
        jl _if_3_then
        ; move number.1, number
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+0]
        mov [rax], rbx
        jmp _if_3_end
_if_3_then:
        ; call printChar@u8[45]
        mov  rax, 45
        push rax
          call _printChar@u8
        add rsp, 8
        ; neg number.2, number
        lea rax, [rsp+24]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; move number.1, number.2
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+0]
        mov [rax], rbx
_if_3_end:
        ; call printUint@i64[number.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printUint@i64
        add rsp, 8
        ; call printChar@u8[10]
        mov  rax, 10
        push rax
          call _printChar@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; i64 strlen@@u8
        ;   rsp+56: arg str
        ;   rsp+0: var length.1
        ;   rsp+8: var str.1
        ;   rsp+16: var length.2
        ;   rsp+24: var t.2.1
        ;   rsp+32: var length.3
        ;   rsp+40: var str.2
_strlen@@u8:
        ; reserve space for local variables
        sub rsp, 48
        ; const length.1, 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 64:2 for *str != 0
        ; move str.1, str
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov [rax], rbx
        ; move length.2, length.1
        lea rax, [rsp+0]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov [rax], rbx
        jmp _for_4
_for_4_body:
        ; move length.3, length.2
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov [rax], rbx
        ; add length.3, length.3, 1
        lea rax, [rsp+32]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+32]
        mov [rax], rbx
        ; move str.2, str.1
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov [rax], rbx
        ; add str.2, str.2, 1
        lea rax, [rsp+40]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+40]
        mov [rax], rbx
        ; move str.1, str.2
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov [rax], rbx
        ; move length.2, length.3
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov [rax], rbx
_for_4:
        ; load t.2.1, [str.1]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+24]
        mov [rbx], al
        ; branch t.2.1 notequals 0: for_4_body, for_4_break
        lea rax, [rsp+24]
        mov bl, [rax]
        cmp bl, 0
        jne _for_4_body
        ; 67:9 return length
        ; ret length.2
        lea rax, [rsp+16]
        mov rbx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 48
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+40: arg str
        ;   rsp+32: arg length
        ;   rsp+0: var t.2.1
_printStringLength@@u8@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.2.1(i64), length(u8)
        lea rax, [rsp+32]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printStringLength@@u8@i64[str, t.2.1]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call _printStringLength@@u8@i64
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; bool getTrue
        ;   rsp+0: var t.0.1
_getTrue:
        ; reserve space for local variables
        sub rsp, 16
        ; const t.0.1, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.0.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; 3:49 return true
        ; ret 1
        mov rax, 1
        ; release space for local variables
        add rsp, 16
        ret

        ; bool getFalse
        ;   rsp+0: var t.0.1
_getFalse:
        ; reserve space for local variables
        sub rsp, 16
        ; const t.0.1, [string-1]
        lea rax, [string_1]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.0.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; 4:49 return false
        ; ret 0
        mov rax, 0
        ; release space for local variables
        add rsp, 16
        ret

        ; void printPass
        ;   rsp+0: var t.0.1
_printPass:
        ; reserve space for local variables
        sub rsp, 16
        ; const t.0.1, [string-2]
        lea rax, [string_2]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.0.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printError
        ;   rsp+0: var t.0.1
_printError:
        ; reserve space for local variables
        sub rsp, 16
        ; const t.0.1, [string-3]
        lea rax, [string_3]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.0.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void logicNot
        ;   rsp+0: var t.2.1
        ;   rsp+8: var t.1
        ;   rsp+9: var f.1
        ;   rsp+10: var t.3.1
        ;   rsp+11: var t.4.1
        ;   rsp+12: var t.5.1
        ;   rsp+13: var t.6.1
_logicNot:
        ; reserve space for local variables
        sub rsp, 16
        ; const t.2.1, [string-4]
        lea rax, [string_4]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.2.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; const t.1, 1
        mov al, 1
        lea rbx, [rsp+8]
        mov [rbx], al
        ; const f.1, 0
        mov al, 0
        lea rbx, [rsp+9]
        mov [rbx], al
        ; 13:2 if !getFalse([])
        ; call t.3.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+10]
        mov [rbx], al
        ; branch t.3.1 equals 0: if_5_then, if_5_else
        lea rax, [rsp+10]
        mov bl, [rax]
        cmp bl, 0
        je _if_5_then
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
        jmp _if_5_end
_if_5_then:
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
_if_5_end:
        ; notlog t.4.1, f.1
        lea rax, [rsp+9]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+11]
        mov [rax], bl
        ; call printIntLf@bool[t.4.1]
        lea rax, [rsp+11]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 15:2 if !getTrue([])
        ; call t.5.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+12]
        mov [rbx], al
        ; branch t.5.1 equals 0: if_6_then, if_6_else
        lea rax, [rsp+12]
        mov bl, [rax]
        cmp bl, 0
        je _if_6_then
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
        jmp _if_6_end
_if_6_then:
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
_if_6_end:
        ; notlog t.6.1, t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+13]
        mov [rax], bl
        ; call printIntLf@bool[t.6.1]
        lea rax, [rsp+13]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void logicAnd
        ;   rsp+0: var t.2.1
        ;   rsp+8: var t.1
        ;   rsp+9: var f.1
        ;   rsp+10: var t.3.1
        ;   rsp+11: var t.4.1
        ;   rsp+12: var t.5.1
        ;   rsp+13: var t.5.2
        ;   rsp+14: var t.5.3
        ;   rsp+15: var t.6.1
        ;   rsp+16: var t.7.1
        ;   rsp+17: var t.8.1
        ;   rsp+18: var t.8.2
        ;   rsp+19: var t.8.3
        ;   rsp+20: var t.9.1
        ;   rsp+21: var t.10.1
        ;   rsp+22: var t.11.1
        ;   rsp+23: var t.11.2
        ;   rsp+24: var t.11.3
        ;   rsp+25: var t.12.1
        ;   rsp+26: var t.13.1
        ;   rsp+27: var t.14.1
        ;   rsp+28: var t.14.2
        ;   rsp+29: var t.14.3
        ;   rsp+30: var t.15.1
        ;   rsp+31: var t.16.1
        ;   rsp+32: var t.18.1
        ;   rsp+33: var t.18.2
        ;   rsp+34: var t.18.3
        ;   rsp+35: var t.17.1
        ;   rsp+36: var t.19.1
        ;   rsp+37: var t.20.1
        ;   rsp+38: var t.22.1
        ;   rsp+39: var t.22.2
        ;   rsp+40: var t.22.3
        ;   rsp+41: var t.21.1
        ;   rsp+42: var t.23.1
        ;   rsp+43: var t.24.1
        ;   rsp+44: var t.26.1
        ;   rsp+45: var t.26.2
        ;   rsp+46: var t.26.3
        ;   rsp+47: var t.25.1
        ;   rsp+48: var t.27.1
        ;   rsp+49: var t.28.1
        ;   rsp+50: var t.30.1
        ;   rsp+51: var t.30.2
        ;   rsp+52: var t.30.3
        ;   rsp+53: var t.29.1
_logicAnd:
        ; reserve space for local variables
        sub rsp, 64
        ; const t.2.1, [string-5]
        lea rax, [string_5]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.2.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; const t.1, 1
        mov al, 1
        lea rbx, [rsp+8]
        mov [rbx], al
        ; const f.1, 0
        mov al, 0
        lea rbx, [rsp+9]
        mov [rbx], al
        ; 23:2 if getFalse([]) && getFalse([])
        ; call t.3.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+10]
        mov [rbx], al
        ; branch t.3.1 equals 0: if_7_else, @and_8
        lea rax, [rsp+10]
        mov bl, [rax]
        cmp bl, 0
        je _if_7_else
        ; call t.4.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+11]
        mov [rbx], al
        ; branch t.4.1 equals 0: if_7_else, if_7_then
        lea rax, [rsp+11]
        mov bl, [rax]
        cmp bl, 0
        je _if_7_else
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
        jmp _if_7_end
_if_7_else:
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
_if_7_end:
        ; 24:15 logic and
        ; move t.5.1, f.1
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+12]
        mov [rax], bl
        ; branch t.5.1 notequals 0: and_2nd_9, logicAnd.no_critical_edge_51
        lea rax, [rsp+12]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_9
        ; move t.5.2, t.5.1
        lea rax, [rsp+12]
        mov bl, [rax]
        lea rax, [rsp+13]
        mov [rax], bl
        jmp _and_next_9
_and_2nd_9:
        ; move t.5.3, f.1
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+14]
        mov [rax], bl
        ; move t.5.2, t.5.3
        lea rax, [rsp+14]
        mov bl, [rax]
        lea rax, [rsp+13]
        mov [rax], bl
_and_next_9:
        ; call printIntLf@bool[t.5.2]
        lea rax, [rsp+13]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 25:2 if getFalse([]) && getTrue([])
        ; call t.6.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+15]
        mov [rbx], al
        ; branch t.6.1 equals 0: if_10_else, @and_11
        lea rax, [rsp+15]
        mov bl, [rax]
        cmp bl, 0
        je _if_10_else
        ; call t.7.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+16]
        mov [rbx], al
        ; branch t.7.1 equals 0: if_10_else, if_10_then
        lea rax, [rsp+16]
        mov bl, [rax]
        cmp bl, 0
        je _if_10_else
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
        jmp _if_10_end
_if_10_else:
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
_if_10_end:
        ; 26:15 logic and
        ; move t.8.1, f.1
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+17]
        mov [rax], bl
        ; branch t.8.1 notequals 0: and_2nd_12, logicAnd.no_critical_edge_53
        lea rax, [rsp+17]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_12
        ; move t.8.2, t.8.1
        lea rax, [rsp+17]
        mov bl, [rax]
        lea rax, [rsp+18]
        mov [rax], bl
        jmp _and_next_12
_and_2nd_12:
        ; move t.8.3, t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+19]
        mov [rax], bl
        ; move t.8.2, t.8.3
        lea rax, [rsp+19]
        mov bl, [rax]
        lea rax, [rsp+18]
        mov [rax], bl
_and_next_12:
        ; call printIntLf@bool[t.8.2]
        lea rax, [rsp+18]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 27:2 if getTrue([]) && getFalse([])
        ; call t.9.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+20]
        mov [rbx], al
        ; branch t.9.1 equals 0: if_13_else, @and_14
        lea rax, [rsp+20]
        mov bl, [rax]
        cmp bl, 0
        je _if_13_else
        ; call t.10.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+21]
        mov [rbx], al
        ; branch t.10.1 equals 0: if_13_else, if_13_then
        lea rax, [rsp+21]
        mov bl, [rax]
        cmp bl, 0
        je _if_13_else
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
        jmp _if_13_end
_if_13_else:
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
_if_13_end:
        ; 28:15 logic and
        ; move t.11.1, t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+22]
        mov [rax], bl
        ; branch t.11.1 notequals 0: and_2nd_15, logicAnd.no_critical_edge_55
        lea rax, [rsp+22]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_15
        ; move t.11.2, t.11.1
        lea rax, [rsp+22]
        mov bl, [rax]
        lea rax, [rsp+23]
        mov [rax], bl
        jmp _and_next_15
_and_2nd_15:
        ; move t.11.3, f.1
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+24]
        mov [rax], bl
        ; move t.11.2, t.11.3
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+23]
        mov [rax], bl
_and_next_15:
        ; call printIntLf@bool[t.11.2]
        lea rax, [rsp+23]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 29:2 if getTrue([]) && getTrue([])
        ; call t.12.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+25]
        mov [rbx], al
        ; branch t.12.1 equals 0: if_16_else, @and_17
        lea rax, [rsp+25]
        mov bl, [rax]
        cmp bl, 0
        je _if_16_else
        ; call t.13.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+26]
        mov [rbx], al
        ; branch t.13.1 equals 0: if_16_else, if_16_then
        lea rax, [rsp+26]
        mov bl, [rax]
        cmp bl, 0
        je _if_16_else
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
        jmp _if_16_end
_if_16_else:
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
_if_16_end:
        ; 30:15 logic and
        ; move t.14.1, t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+27]
        mov [rax], bl
        ; branch t.14.1 notequals 0: and_2nd_18, logicAnd.no_critical_edge_57
        lea rax, [rsp+27]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_18
        ; move t.14.2, t.14.1
        lea rax, [rsp+27]
        mov bl, [rax]
        lea rax, [rsp+28]
        mov [rax], bl
        jmp _and_next_18
_and_2nd_18:
        ; move t.14.3, t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+29]
        mov [rax], bl
        ; move t.14.2, t.14.3
        lea rax, [rsp+29]
        mov bl, [rax]
        lea rax, [rsp+28]
        mov [rax], bl
_and_next_18:
        ; call printIntLf@bool[t.14.2]
        lea rax, [rsp+28]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 32:2 if !getFalse([]) && getFalse([])
        ; call t.15.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+30]
        mov [rbx], al
        ; branch t.15.1 equals 0: if_19_then, @and_20
        lea rax, [rsp+30]
        mov bl, [rax]
        cmp bl, 0
        je _if_19_then
        ; call t.16.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+31]
        mov [rbx], al
        ; branch t.16.1 equals 0: if_19_then, if_19_else
        lea rax, [rsp+31]
        mov bl, [rax]
        cmp bl, 0
        je _if_19_then
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
        jmp _if_19_end
_if_19_then:
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
_if_19_end:
        ; 33:17 logic and
        ; move t.18.1, f.1
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
        ; branch t.18.1 notequals 0: and_2nd_21, logicAnd.no_critical_edge_59
        lea rax, [rsp+32]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_21
        ; move t.18.2, t.18.1
        lea rax, [rsp+32]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov [rax], bl
        jmp _and_next_21
_and_2nd_21:
        ; move t.18.3, f.1
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+34]
        mov [rax], bl
        ; move t.18.2, t.18.3
        lea rax, [rsp+34]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov [rax], bl
_and_next_21:
        ; notlog t.17.1, t.18.2
        lea rax, [rsp+33]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+35]
        mov [rax], bl
        ; call printIntLf@bool[t.17.1]
        lea rax, [rsp+35]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 34:2 if !getFalse([]) && getTrue([])
        ; call t.19.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+36]
        mov [rbx], al
        ; branch t.19.1 equals 0: if_22_then, @and_23
        lea rax, [rsp+36]
        mov bl, [rax]
        cmp bl, 0
        je _if_22_then
        ; call t.20.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+37]
        mov [rbx], al
        ; branch t.20.1 equals 0: if_22_then, if_22_else
        lea rax, [rsp+37]
        mov bl, [rax]
        cmp bl, 0
        je _if_22_then
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
        jmp _if_22_end
_if_22_then:
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
_if_22_end:
        ; 35:17 logic and
        ; move t.22.1, f.1
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+38]
        mov [rax], bl
        ; branch t.22.1 notequals 0: and_2nd_24, logicAnd.no_critical_edge_61
        lea rax, [rsp+38]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_24
        ; move t.22.2, t.22.1
        lea rax, [rsp+38]
        mov bl, [rax]
        lea rax, [rsp+39]
        mov [rax], bl
        jmp _and_next_24
_and_2nd_24:
        ; move t.22.3, t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+40]
        mov [rax], bl
        ; move t.22.2, t.22.3
        lea rax, [rsp+40]
        mov bl, [rax]
        lea rax, [rsp+39]
        mov [rax], bl
_and_next_24:
        ; notlog t.21.1, t.22.2
        lea rax, [rsp+39]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+41]
        mov [rax], bl
        ; call printIntLf@bool[t.21.1]
        lea rax, [rsp+41]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 36:2 if !getTrue([]) && getFalse([])
        ; call t.23.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+42]
        mov [rbx], al
        ; branch t.23.1 equals 0: if_25_then, @and_26
        lea rax, [rsp+42]
        mov bl, [rax]
        cmp bl, 0
        je _if_25_then
        ; call t.24.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+43]
        mov [rbx], al
        ; branch t.24.1 equals 0: if_25_then, if_25_else
        lea rax, [rsp+43]
        mov bl, [rax]
        cmp bl, 0
        je _if_25_then
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
        jmp _if_25_end
_if_25_then:
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
_if_25_end:
        ; 37:17 logic and
        ; move t.26.1, t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+44]
        mov [rax], bl
        ; branch t.26.1 notequals 0: and_2nd_27, logicAnd.no_critical_edge_63
        lea rax, [rsp+44]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_27
        ; move t.26.2, t.26.1
        lea rax, [rsp+44]
        mov bl, [rax]
        lea rax, [rsp+45]
        mov [rax], bl
        jmp _and_next_27
_and_2nd_27:
        ; move t.26.3, f.1
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+46]
        mov [rax], bl
        ; move t.26.2, t.26.3
        lea rax, [rsp+46]
        mov bl, [rax]
        lea rax, [rsp+45]
        mov [rax], bl
_and_next_27:
        ; notlog t.25.1, t.26.2
        lea rax, [rsp+45]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+47]
        mov [rax], bl
        ; call printIntLf@bool[t.25.1]
        lea rax, [rsp+47]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 38:2 if !getTrue([]) && getTrue([])
        ; call t.27.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+48]
        mov [rbx], al
        ; branch t.27.1 equals 0: if_28_then, @and_29
        lea rax, [rsp+48]
        mov bl, [rax]
        cmp bl, 0
        je _if_28_then
        ; call t.28.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+49]
        mov [rbx], al
        ; branch t.28.1 equals 0: if_28_then, if_28_else
        lea rax, [rsp+49]
        mov bl, [rax]
        cmp bl, 0
        je _if_28_then
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
        jmp _if_28_end
_if_28_then:
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
_if_28_end:
        ; 39:17 logic and
        ; move t.30.1, t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+50]
        mov [rax], bl
        ; branch t.30.1 notequals 0: and_2nd_30, logicAnd.no_critical_edge_65
        lea rax, [rsp+50]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_30
        ; move t.30.2, t.30.1
        lea rax, [rsp+50]
        mov bl, [rax]
        lea rax, [rsp+51]
        mov [rax], bl
        jmp _and_next_30
_and_2nd_30:
        ; move t.30.3, t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+52]
        mov [rax], bl
        ; move t.30.2, t.30.3
        lea rax, [rsp+52]
        mov bl, [rax]
        lea rax, [rsp+51]
        mov [rax], bl
_and_next_30:
        ; notlog t.29.1, t.30.2
        lea rax, [rsp+51]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+53]
        mov [rax], bl
        ; call printIntLf@bool[t.29.1]
        lea rax, [rsp+53]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; release space for local variables
        add rsp, 64
        ret

        ; void logicOr
        ;   rsp+0: var t.2.1
        ;   rsp+8: var t.1
        ;   rsp+9: var f.1
        ;   rsp+10: var t.3.1
        ;   rsp+11: var t.4.1
        ;   rsp+12: var t.5.1
        ;   rsp+13: var t.5.2
        ;   rsp+14: var t.5.3
        ;   rsp+15: var t.6.1
        ;   rsp+16: var t.7.1
        ;   rsp+17: var t.8.1
        ;   rsp+18: var t.8.2
        ;   rsp+19: var t.8.3
        ;   rsp+20: var t.9.1
        ;   rsp+21: var t.10.1
        ;   rsp+22: var t.11.1
        ;   rsp+23: var t.11.2
        ;   rsp+24: var t.11.3
        ;   rsp+25: var t.12.1
        ;   rsp+26: var t.13.1
        ;   rsp+27: var t.14.1
        ;   rsp+28: var t.14.2
        ;   rsp+29: var t.14.3
_logicOr:
        ; reserve space for local variables
        sub rsp, 32
        ; const t.2.1, [string-6]
        lea rax, [string_6]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.2.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; const t.1, 1
        mov al, 1
        lea rbx, [rsp+8]
        mov [rbx], al
        ; const f.1, 0
        mov al, 0
        lea rbx, [rsp+9]
        mov [rbx], al
        ; 46:2 if getFalse([]) || getFalse([])
        ; call t.3.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+10]
        mov [rbx], al
        ; branch t.3.1 notequals 0: if_31_then, @or_32
        lea rax, [rsp+10]
        mov bl, [rax]
        cmp bl, 0
        jne _if_31_then
        ; call t.4.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+11]
        mov [rbx], al
        ; branch t.4.1 notequals 0: if_31_then, if_31_else
        lea rax, [rsp+11]
        mov bl, [rax]
        cmp bl, 0
        jne _if_31_then
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
        jmp _if_31_end
_if_31_then:
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
_if_31_end:
        ; 47:15 logic or
        ; move t.5.1, f.1
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+12]
        mov [rax], bl
        ; branch t.5.1 equals 0: or_2nd_33, logicOr.no_critical_edge_27
        lea rax, [rsp+12]
        mov bl, [rax]
        cmp bl, 0
        je _or_2nd_33
        ; move t.5.2, t.5.1
        lea rax, [rsp+12]
        mov bl, [rax]
        lea rax, [rsp+13]
        mov [rax], bl
        jmp _or_next_33
_or_2nd_33:
        ; move t.5.3, f.1
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+14]
        mov [rax], bl
        ; move t.5.2, t.5.3
        lea rax, [rsp+14]
        mov bl, [rax]
        lea rax, [rsp+13]
        mov [rax], bl
_or_next_33:
        ; call printIntLf@bool[t.5.2]
        lea rax, [rsp+13]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 48:2 if getFalse([]) || getTrue([])
        ; call t.6.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+15]
        mov [rbx], al
        ; branch t.6.1 notequals 0: if_34_then, @or_35
        lea rax, [rsp+15]
        mov bl, [rax]
        cmp bl, 0
        jne _if_34_then
        ; call t.7.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+16]
        mov [rbx], al
        ; branch t.7.1 notequals 0: if_34_then, if_34_else
        lea rax, [rsp+16]
        mov bl, [rax]
        cmp bl, 0
        jne _if_34_then
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
        jmp _if_34_end
_if_34_then:
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
_if_34_end:
        ; 49:15 logic or
        ; move t.8.1, f.1
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+17]
        mov [rax], bl
        ; branch t.8.1 equals 0: or_2nd_36, logicOr.no_critical_edge_29
        lea rax, [rsp+17]
        mov bl, [rax]
        cmp bl, 0
        je _or_2nd_36
        ; move t.8.2, t.8.1
        lea rax, [rsp+17]
        mov bl, [rax]
        lea rax, [rsp+18]
        mov [rax], bl
        jmp _or_next_36
_or_2nd_36:
        ; move t.8.3, t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+19]
        mov [rax], bl
        ; move t.8.2, t.8.3
        lea rax, [rsp+19]
        mov bl, [rax]
        lea rax, [rsp+18]
        mov [rax], bl
_or_next_36:
        ; call printIntLf@bool[t.8.2]
        lea rax, [rsp+18]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 50:2 if getTrue([]) || getFalse([])
        ; call t.9.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+20]
        mov [rbx], al
        ; branch t.9.1 notequals 0: if_37_then, @or_38
        lea rax, [rsp+20]
        mov bl, [rax]
        cmp bl, 0
        jne _if_37_then
        ; call t.10.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+21]
        mov [rbx], al
        ; branch t.10.1 notequals 0: if_37_then, if_37_else
        lea rax, [rsp+21]
        mov bl, [rax]
        cmp bl, 0
        jne _if_37_then
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
        jmp _if_37_end
_if_37_then:
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
_if_37_end:
        ; 51:15 logic or
        ; move t.11.1, t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+22]
        mov [rax], bl
        ; branch t.11.1 equals 0: or_2nd_39, logicOr.no_critical_edge_31
        lea rax, [rsp+22]
        mov bl, [rax]
        cmp bl, 0
        je _or_2nd_39
        ; move t.11.2, t.11.1
        lea rax, [rsp+22]
        mov bl, [rax]
        lea rax, [rsp+23]
        mov [rax], bl
        jmp _or_next_39
_or_2nd_39:
        ; move t.11.3, f.1
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+24]
        mov [rax], bl
        ; move t.11.2, t.11.3
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+23]
        mov [rax], bl
_or_next_39:
        ; call printIntLf@bool[t.11.2]
        lea rax, [rsp+23]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 52:2 if getTrue([]) || getTrue([])
        ; call t.12.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+25]
        mov [rbx], al
        ; branch t.12.1 notequals 0: if_40_then, @or_41
        lea rax, [rsp+25]
        mov bl, [rax]
        cmp bl, 0
        jne _if_40_then
        ; call t.13.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+26]
        mov [rbx], al
        ; branch t.13.1 notequals 0: if_40_then, if_40_else
        lea rax, [rsp+26]
        mov bl, [rax]
        cmp bl, 0
        jne _if_40_then
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
        jmp _if_40_end
_if_40_then:
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
_if_40_end:
        ; 53:15 logic or
        ; move t.14.1, t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+27]
        mov [rax], bl
        ; branch t.14.1 equals 0: or_2nd_42, logicOr.no_critical_edge_33
        lea rax, [rsp+27]
        mov bl, [rax]
        cmp bl, 0
        je _or_2nd_42
        ; move t.14.2, t.14.1
        lea rax, [rsp+27]
        mov bl, [rax]
        lea rax, [rsp+28]
        mov [rax], bl
        jmp _or_next_42
_or_2nd_42:
        ; move t.14.3, t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+29]
        mov [rax], bl
        ; move t.14.2, t.14.3
        lea rax, [rsp+29]
        mov bl, [rax]
        lea rax, [rsp+28]
        mov [rax], bl
_or_next_42:
        ; call printIntLf@bool[t.14.2]
        lea rax, [rsp+28]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; release space for local variables
        add rsp, 32
        ret

        ; void main
        ;   rsp+0: var t.9.1
        ;   rsp+8: var a.1
        ;   rsp+10: var b.1
        ;   rsp+12: var c.1
        ;   rsp+14: var d.1
        ;   rsp+16: var t.1
        ;   rsp+17: var f.1
        ;   rsp+18: var t.10.1
        ;   rsp+20: var t.11.1
        ;   rsp+22: var t.12.1
        ;   rsp+24: var t.13.1
        ;   rsp+32: var t.14.1
        ;   rsp+40: var t.15.1
        ;   rsp+42: var t.16.1
        ;   rsp+44: var t.17.1
        ;   rsp+46: var t.18.1
        ;   rsp+48: var t.19.1
        ;   rsp+56: var t.20.1
        ;   rsp+58: var t.21.1
        ;   rsp+60: var t.22.1
        ;   rsp+62: var t.23.1
        ;   rsp+64: var t.24.1
        ;   rsp+65: var t.25.1
        ;   rsp+66: var t.26.1
        ;   rsp+67: var t.29.1
        ;   rsp+68: var t.27.1
        ;   rsp+69: var t.29.2
        ;   rsp+70: var t.29.3
        ;   rsp+71: var t.28.1
        ;   rsp+72: var t.28.2
        ;   rsp+73: var t.30.1
        ;   rsp+80: var t.31.1
        ;   rsp+88: var b10.1
        ;   rsp+89: var b6.1
        ;   rsp+90: var b1.1
        ;   rsp+91: var t.33.1
        ;   rsp+92: var t.32.1
        ;   rsp+93: var t.34.1
        ;   rsp+94: var t.30.2
        ;   rsp+95: var t.30.3
        ;   rsp+96: var t.34.2
        ;   rsp+97: var t.34.3
        ;   rsp+98: var t.28.3
        ;   rsp+99: var t.35.1
        ;   rsp+100: var t.35.2
        ;   rsp+101: var t.35.3
        ;   rsp+102: var t.36.1
        ;   rsp+104: var t.37.1
_main:
        ; reserve space for local variables
        sub rsp, 112
        ; const t.9.1, [string-7]
        lea rax, [string_7]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.9.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; const a.1, 0
        mov ax, 0
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; const b.1, 1
        mov ax, 1
        lea rbx, [rsp+10]
        mov [rbx], ax
        ; const c.1, 2
        mov ax, 2
        lea rbx, [rsp+12]
        mov [rbx], ax
        ; const d.1, 3
        mov ax, 3
        lea rbx, [rsp+14]
        mov [rbx], ax
        ; const t.1, 1
        mov al, 1
        lea rbx, [rsp+16]
        mov [rbx], al
        ; const f.1, 0
        mov al, 0
        lea rbx, [rsp+17]
        mov [rbx], al
        ; move t.10.1, a.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        ; and t.10.1, t.10.1, a.1
        lea rax, [rsp+18]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+18]
        mov [rax], bx
        ; call printIntLf@i16[t.10.1]
        lea rax, [rsp+18]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.11.1, a.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov [rax], bx
        ; and t.11.1, t.11.1, b.1
        lea rax, [rsp+20]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+20]
        mov [rax], bx
        ; call printIntLf@i16[t.11.1]
        lea rax, [rsp+20]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.12.1, b.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+22]
        mov [rax], bx
        ; and t.12.1, t.12.1, a.1
        lea rax, [rsp+22]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+22]
        mov [rax], bx
        ; call printIntLf@i16[t.12.1]
        lea rax, [rsp+22]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.13.1, b.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+24]
        mov [rax], bx
        ; and t.13.1, t.13.1, b.1
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+24]
        mov [rax], bx
        ; call printIntLf@i16[t.13.1]
        lea rax, [rsp+24]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; const t.14.1, [string-8]
        lea rax, [string_8]
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; call printString@@u8[t.14.1]
        lea rax, [rsp+32]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; move t.15.1, a.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+40]
        mov [rax], bx
        ; or t.15.1, t.15.1, a.1
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+40]
        mov [rax], bx
        ; call printIntLf@i16[t.15.1]
        lea rax, [rsp+40]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.16.1, a.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+42]
        mov [rax], bx
        ; or t.16.1, t.16.1, b.1
        lea rax, [rsp+42]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+42]
        mov [rax], bx
        ; call printIntLf@i16[t.16.1]
        lea rax, [rsp+42]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.17.1, b.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+44]
        mov [rax], bx
        ; or t.17.1, t.17.1, a.1
        lea rax, [rsp+44]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+44]
        mov [rax], bx
        ; call printIntLf@i16[t.17.1]
        lea rax, [rsp+44]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.18.1, b.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+46]
        mov [rax], bx
        ; or t.18.1, t.18.1, b.1
        lea rax, [rsp+46]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+46]
        mov [rax], bx
        ; call printIntLf@i16[t.18.1]
        lea rax, [rsp+46]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; const t.19.1, [string-9]
        lea rax, [string_9]
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; call printString@@u8[t.19.1]
        lea rax, [rsp+48]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; move t.20.1, a.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+56]
        mov [rax], bx
        ; xor t.20.1, t.20.1, a.1
        lea rax, [rsp+56]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+56]
        mov [rax], bx
        ; call printIntLf@i16[t.20.1]
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.21.1, a.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+58]
        mov [rax], bx
        ; xor t.21.1, t.21.1, c.1
        lea rax, [rsp+58]
        mov bx, [rax]
        lea rax, [rsp+12]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+58]
        mov [rax], bx
        ; call printIntLf@i16[t.21.1]
        lea rax, [rsp+58]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.22.1, b.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+60]
        mov [rax], bx
        ; xor t.22.1, t.22.1, a.1
        lea rax, [rsp+60]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+60]
        mov [rax], bx
        ; call printIntLf@i16[t.22.1]
        lea rax, [rsp+60]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.23.1, b.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+62]
        mov [rax], bx
        ; xor t.23.1, t.23.1, c.1
        lea rax, [rsp+62]
        mov bx, [rax]
        lea rax, [rsp+12]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+62]
        mov [rax], bx
        ; call printIntLf@i16[t.23.1]
        lea rax, [rsp+62]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; call logicNot[]
        sub rsp, 8
          call _logicNot
        add rsp, 8
        ; call logicAnd[]
        sub rsp, 8
          call _logicAnd
        add rsp, 8
        ; call logicOr[]
        sub rsp, 8
          call _logicOr
        add rsp, 8
        ; 82:2 if !getTrue([]) && getTrue([]) || !getFalse([]) && getFalse([])
        ; call t.24.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+64]
        mov [rbx], al
        ; branch t.24.1 equals 0: if_43_then, @and_45
        lea rax, [rsp+64]
        mov bl, [rax]
        cmp bl, 0
        je _if_43_then
        ; call t.25.1 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+65]
        mov [rbx], al
        ; branch t.25.1 equals 0: if_43_then, @or_44
        lea rax, [rsp+65]
        mov bl, [rax]
        cmp bl, 0
        je _if_43_then
        ; call t.26.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+66]
        mov [rbx], al
        ; branch t.26.1 equals 0: if_43_then, @and_46
        lea rax, [rsp+66]
        mov bl, [rax]
        cmp bl, 0
        je _if_43_then
        ; call t.27.1 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+68]
        mov [rbx], al
        ; branch t.27.1 equals 0: if_43_then, if_43_else
        lea rax, [rsp+68]
        mov bl, [rax]
        cmp bl, 0
        je _if_43_then
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
        jmp _if_43_end
_if_43_then:
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
_if_43_end:
        ; 88:23 logic or
        ; 88:17 logic and
        ; move t.29.1, t.1
        lea rax, [rsp+16]
        mov bl, [rax]
        lea rax, [rsp+67]
        mov [rax], bl
        ; branch t.29.1 notequals 0: and_2nd_48, main.no_critical_edge_19
        lea rax, [rsp+67]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_48
        ; move t.29.2, t.29.1
        lea rax, [rsp+67]
        mov bl, [rax]
        lea rax, [rsp+69]
        mov [rax], bl
        jmp _and_next_48
_and_2nd_48:
        ; move t.29.3, t.1
        lea rax, [rsp+16]
        mov bl, [rax]
        lea rax, [rsp+70]
        mov [rax], bl
        ; move t.29.2, t.29.3
        lea rax, [rsp+70]
        mov bl, [rax]
        lea rax, [rsp+69]
        mov [rax], bl
_and_next_48:
        ; notlog t.28.1, t.29.2
        lea rax, [rsp+69]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+71]
        mov [rax], bl
        ; branch t.28.1 equals 0: or_2nd_47, main.no_critical_edge_20
        lea rax, [rsp+71]
        mov bl, [rax]
        cmp bl, 0
        je _or_2nd_47
        ; move t.28.2, t.28.1
        lea rax, [rsp+71]
        mov bl, [rax]
        lea rax, [rsp+72]
        mov [rax], bl
        jmp _or_next_47
_or_2nd_47:
        ; 88:30 logic and
        ; move t.30.1, f.1
        lea rax, [rsp+17]
        mov bl, [rax]
        lea rax, [rsp+73]
        mov [rax], bl
        ; branch t.30.1 notequals 0: and_2nd_49, main.no_critical_edge_23
        lea rax, [rsp+73]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_49
        ; move t.30.2, t.30.1
        lea rax, [rsp+73]
        mov bl, [rax]
        lea rax, [rsp+94]
        mov [rax], bl
        jmp _and_next_49
_and_2nd_49:
        ; move t.30.3, f.1
        lea rax, [rsp+17]
        mov bl, [rax]
        lea rax, [rsp+95]
        mov [rax], bl
        ; move t.30.2, t.30.3
        lea rax, [rsp+95]
        mov bl, [rax]
        lea rax, [rsp+94]
        mov [rax], bl
_and_next_49:
        ; notlog t.28.3, t.30.2
        lea rax, [rsp+94]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+98]
        mov [rax], bl
        ; move t.28.2, t.28.3
        lea rax, [rsp+98]
        mov bl, [rax]
        lea rax, [rsp+72]
        mov [rax], bl
_or_next_47:
        ; call printIntLf@bool[t.28.2]
        lea rax, [rsp+72]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; const t.31.1, [string-10]
        lea rax, [string_10]
        lea rbx, [rsp+80]
        mov [rbx], rax
        ; call printString@@u8[t.31.1]
        lea rax, [rsp+80]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; const b10.1, 10
        mov al, 10
        lea rbx, [rsp+88]
        mov [rbx], al
        ; const b6.1, 6
        mov al, 6
        lea rbx, [rsp+89]
        mov [rbx], al
        ; const b1.1, 1
        mov al, 1
        lea rbx, [rsp+90]
        mov [rbx], al
        ; move t.33.1, b10.1
        lea rax, [rsp+88]
        mov bl, [rax]
        lea rax, [rsp+91]
        mov [rax], bl
        ; and t.33.1, t.33.1, b6.1
        lea rax, [rsp+91]
        mov bl, [rax]
        lea rax, [rsp+89]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+91]
        mov [rax], bl
        ; move t.32.1, t.33.1
        lea rax, [rsp+91]
        mov bl, [rax]
        lea rax, [rsp+92]
        mov [rax], bl
        ; or t.32.1, t.32.1, b1.1
        lea rax, [rsp+92]
        mov bl, [rax]
        lea rax, [rsp+90]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+92]
        mov [rax], bl
        ; call printIntLf@u8[t.32.1]
        lea rax, [rsp+92]
        mov bl, [rax]
        push rbx
          call _printIntLf@u8
        add rsp, 8
        ; 95:20 logic or
        ; equals t.34.1, b.1, c.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+12]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+93]
        mov [rax], bl
        ; branch t.34.1 equals 0: or_2nd_50, main.no_critical_edge_21
        lea rax, [rsp+93]
        mov bl, [rax]
        cmp bl, 0
        je _or_2nd_50
        ; move t.34.2, t.34.1
        lea rax, [rsp+93]
        mov bl, [rax]
        lea rax, [rsp+96]
        mov [rax], bl
        jmp _or_next_50
_or_2nd_50:
        ; lt t.34.3, c.1, d.1
        lea rax, [rsp+12]
        mov bx, [rax]
        lea rax, [rsp+14]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+97]
        mov [rax], bl
        ; move t.34.2, t.34.3
        lea rax, [rsp+97]
        mov bl, [rax]
        lea rax, [rsp+96]
        mov [rax], bl
_or_next_50:
        ; call printIntLf@bool[t.34.2]
        lea rax, [rsp+96]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 96:20 logic and
        ; equals t.35.1, b.1, c.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+12]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+99]
        mov [rax], bl
        ; branch t.35.1 notequals 0: and_2nd_51, main.no_critical_edge_22
        lea rax, [rsp+99]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_51
        ; move t.35.2, t.35.1
        lea rax, [rsp+99]
        mov bl, [rax]
        lea rax, [rsp+100]
        mov [rax], bl
        jmp _and_next_51
_and_2nd_51:
        ; lt t.35.3, c.1, d.1
        lea rax, [rsp+12]
        mov bx, [rax]
        lea rax, [rsp+14]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+101]
        mov [rax], bl
        ; move t.35.2, t.35.3
        lea rax, [rsp+101]
        mov bl, [rax]
        lea rax, [rsp+100]
        mov [rax], bl
_and_next_51:
        ; call printIntLf@bool[t.35.2]
        lea rax, [rsp+100]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; call printIntLf@i16[-1]
        mov  rax, -1
        push rax
          call _printIntLf@i16
        add rsp, 8
        ; neg t.36.1, b.1
        lea rax, [rsp+10]
        mov bx, [rax]
        neg rbx
        lea rax, [rsp+102]
        mov [rax], bx
        ; call printIntLf@i16[t.36.1]
        lea rax, [rsp+102]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; not t.37.1, b1.1
        lea rax, [rsp+90]
        mov bl, [rax]
        not rbx
        lea rax, [rsp+104]
        mov [rax], bl
        ; call printIntLf@u8[t.37.1]
        lea rax, [rsp+104]
        mov bl, [rax]
        push rbx
          call _printIntLf@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 112
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
        mov     rdi, rsp

        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        mov     rdx, [rdi+18h]
        mov     r8, [rdi+10h]
        xor     r9, r9
        push    0
        sub     rsp, 20h
          call    [WriteFile]
        mov     rsp, rdi
        ret
init:
        sub rsp, 20h
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
        add rsp, 20h
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
