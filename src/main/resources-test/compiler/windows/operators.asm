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
        ;   rsp+0: var length
_printString@@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; call length = strlen@@u8[str] -> i64
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call _strlen@@u8
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@i64[str, length]
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
        ;   rsp+0: var t.1
_printChar@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof t.1, chr
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@u8[t.1, 1]
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
        ;   rsp+104: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
        ;   rsp+24: var remainder
        ;   rsp+32: var digit
        ;   rsp+33: var t.5
        ;   rsp+40: var t.6
        ;   rsp+48: var t.7
        ;   rsp+56: var t.8
        ;   rsp+64: var t.9
        ;   rsp+72: var t.10
        ;   rsp+80: var t.11
        ;   rsp+81: var t.12
_printUint@i64:
        ; reserve space for local variables
        sub rsp, 96
        ; const pos, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 28:2 while true
_while_1:
        ; sub pos, pos, 1
        lea rax, [rsp+20]
        mov bl, [rax]
        sub bl, 1
        lea rax, [rsp+20]
        mov [rax], bl
        ; move remainder, number
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; mod remainder, remainder, 10
        lea rax, [rsp+24]
        mov rbx, [rax]
        mov rax, rbx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+24]
        mov [rcx], rbx
        ; div number, number, 10
        lea rax, [rsp+104]
        mov rbx, [rax]
        mov rax, rbx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rax
        lea rcx, [rsp+104]
        mov [rcx], rbx
        ; cast t.5(u8), remainder(i64)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+33]
        mov [rax], bl
        ; move digit, t.5
        lea rax, [rsp+33]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
        ; add digit, digit, 48
        lea rax, [rsp+32]
        mov bl, [rax]
        add bl, 48
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.7(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+48]
        mov [rax], rbx
        ; addrof t.6, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; add t.6, t.6, t.7
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+48]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+40]
        mov [rax], rbx
        ; store [t.6], digit
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; 34:3 if number == 0
        ; equals t.8, number, 0
        lea rax, [rsp+104]
        mov rbx, [rax]
        cmp rbx, 0
        sete bl
        lea rax, [rsp+56]
        mov [rax], bl
        ; branch t.8, false, while_1, while_1_break
        lea rax, [rsp+56]
        mov bl, [rax]
        or bl, bl
        jz _while_1
        ; cast t.10(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+72]
        mov [rax], rbx
        ; addrof t.9, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; add t.9, t.9, t.10
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+72]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+64]
        mov [rax], rbx
        ; const t.12, 20
        mov al, 20
        lea rbx, [rsp+81]
        mov [rbx], al
        ; move t.11, t.12
        lea rax, [rsp+81]
        mov bl, [rax]
        lea rax, [rsp+80]
        mov [rax], bl
        ; sub t.11, t.11, pos
        lea rax, [rsp+80]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+80]
        mov [rax], bl
        ; call printStringLength@@u8@u8[t.9, t.11]
        lea rax, [rsp+64]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+88]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call _printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 96
        ret

        ; void printIntLf@bool
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
_printIntLf@bool:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1(i64), number(bool)
        lea rax, [rsp+24]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printIntLf@i64[t.1]
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
        ;   rsp+0: var t.1
_printIntLf@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1(i64), number(u8)
        lea rax, [rsp+24]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printIntLf@i64[t.1]
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
        ;   rsp+0: var t.1
_printIntLf@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1(i64), number(i16)
        lea rax, [rsp+24]
        mov bx, [rax]
        movsx rbx, bx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printIntLf@i64[t.1]
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
        ;   rsp+0: var t.1
_printIntLf@i64:
        ; reserve space for local variables
        sub rsp, 16
        ; 54:2 if number < 0
        ; lt t.1, number, 0
        lea rax, [rsp+24]
        mov rbx, [rax]
        cmp rbx, 0
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1, false, if_3_end, if_3_then
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz _if_3_end
        ; call printChar@u8[45]
        mov  rax, 45
        push rax
          call _printChar@u8
        add rsp, 8
        ; neg number, number
        lea rax, [rsp+24]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+24]
        mov [rax], rbx
_if_3_end:
        ; call printUint@i64[number]
        lea rax, [rsp+24]
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
        ;   rsp+24: arg str
        ;   rsp+0: var length
        ;   rsp+8: var t.2
        ;   rsp+9: var t.3
_strlen@@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; const length, 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 64:2 for *str != 0
        jmp _for_4
_for_4_body:
        ; add length, length, 1
        lea rax, [rsp+0]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+0]
        mov [rax], rbx
        ; add str, str, 1
        lea rax, [rsp+24]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+24]
        mov [rax], rbx
_for_4:
        ; load t.3, [str]
        lea rax, [rsp+24]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+9]
        mov [rbx], al
        ; notequals t.2, t.3, 0
        lea rax, [rsp+9]
        mov bl, [rax]
        cmp bl, 0
        setne bl
        lea rax, [rsp+8]
        mov [rax], bl
        ; branch t.2, true, for_4_body, for_4_break
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jnz _for_4_body
        ; 67:9 return length
        ; ret length
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+40: arg str
        ;   rsp+32: arg length
        ;   rsp+0: var t.2
_printStringLength@@u8@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.2(i64), length(u8)
        lea rax, [rsp+32]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printStringLength@@u8@i64[str, t.2]
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
        ;   rsp+0: var t.0
        ;   rsp+8: var t.1
_getTrue:
        ; reserve space for local variables
        sub rsp, 16
        ; const t.0, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.0]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; 3:49 return true
        ; const t.1, 1
        mov al, 1
        lea rbx, [rsp+8]
        mov [rbx], al
        ; ret t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool getFalse
        ;   rsp+0: var t.0
        ;   rsp+8: var t.1
_getFalse:
        ; reserve space for local variables
        sub rsp, 16
        ; const t.0, [string-1]
        lea rax, [string_1]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.0]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; 4:49 return false
        ; const t.1, 0
        mov al, 0
        lea rbx, [rsp+8]
        mov [rbx], al
        ; ret t.1
        lea rax, [rsp+8]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; void printPass
        ;   rsp+0: var t.0
_printPass:
        ; reserve space for local variables
        sub rsp, 16
        ; const t.0, [string-2]
        lea rax, [string_2]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.0]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printError
        ;   rsp+0: var t.0
_printError:
        ; reserve space for local variables
        sub rsp, 16
        ; const t.0, [string-3]
        lea rax, [string_3]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.0]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void logicNot
        ;   rsp+0: var t
        ;   rsp+1: var f
        ;   rsp+8: var t.2
        ;   rsp+16: var t.3
        ;   rsp+17: var t.4
        ;   rsp+18: var t.5
        ;   rsp+19: var t.6
        ;   rsp+20: var t.7
        ;   rsp+21: var t.8
_logicNot:
        ; reserve space for local variables
        sub rsp, 32
        ; const t.2, [string-4]
        lea rax, [string_4]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call printString@@u8[t.2]
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; const t, 1
        mov al, 1
        lea rbx, [rsp+0]
        mov [rbx], al
        ; const f, 0
        mov al, 0
        lea rbx, [rsp+1]
        mov [rbx], al
        ; 13:2 if !getFalse([])
        ; call t.4 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+17]
        mov [rbx], al
        ; notlog t.3, t.4
        lea rax, [rsp+17]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+16]
        mov [rax], bl
        ; branch t.3, true, if_5_then, if_5_else
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jnz _if_5_then
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
        ; notlog t.5, f
        lea rax, [rsp+1]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+18]
        mov [rax], bl
        ; call printIntLf@bool[t.5]
        lea rax, [rsp+18]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 15:2 if !getTrue([])
        ; call t.7 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+20]
        mov [rbx], al
        ; notlog t.6, t.7
        lea rax, [rsp+20]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+19]
        mov [rax], bl
        ; branch t.6, true, if_6_then, if_6_else
        lea rax, [rsp+19]
        mov bl, [rax]
        or bl, bl
        jnz _if_6_then
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
        ; notlog t.8, t
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+21]
        mov [rax], bl
        ; call printIntLf@bool[t.8]
        lea rax, [rsp+21]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; release space for local variables
        add rsp, 32
        ret

        ; void logicAnd
        ;   rsp+0: var t
        ;   rsp+1: var f
        ;   rsp+8: var t.2
        ;   rsp+16: var t.3
        ;   rsp+17: var t.4
        ;   rsp+18: var t.5
        ;   rsp+19: var t.6
        ;   rsp+20: var t.7
        ;   rsp+21: var t.8
        ;   rsp+22: var t.9
        ;   rsp+23: var t.10
        ;   rsp+24: var t.11
        ;   rsp+25: var t.12
        ;   rsp+26: var t.13
        ;   rsp+27: var t.14
        ;   rsp+28: var t.15
        ;   rsp+29: var t.16
        ;   rsp+30: var t.17
        ;   rsp+31: var t.18
        ;   rsp+32: var t.19
        ;   rsp+33: var t.20
        ;   rsp+34: var t.21
        ;   rsp+35: var t.22
        ;   rsp+36: var t.23
        ;   rsp+37: var t.24
        ;   rsp+38: var t.25
        ;   rsp+39: var t.26
_logicAnd:
        ; reserve space for local variables
        sub rsp, 48
        ; const t.2, [string-5]
        lea rax, [string_5]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call printString@@u8[t.2]
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; const t, 1
        mov al, 1
        lea rbx, [rsp+0]
        mov [rbx], al
        ; const f, 0
        mov al, 0
        lea rbx, [rsp+1]
        mov [rbx], al
        ; 23:2 if getFalse([]) && getFalse([])
        ; 23:17 logic and
        ; call t.3 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+16]
        mov [rbx], al
        ; branch t.3, false, and_next_8, and_2nd_8
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jz _and_next_8
        ; call t.3 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+16]
        mov [rbx], al
_and_next_8:
        ; branch t.3, true, if_7_then, if_7_else
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jnz _if_7_then
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
        jmp _if_7_end
_if_7_then:
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
_if_7_end:
        ; 24:15 logic and
        ; move t.4, f
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+17]
        mov [rax], bl
        ; branch t.4, false, and_next_9, and_2nd_9
        lea rax, [rsp+17]
        mov bl, [rax]
        or bl, bl
        jz _and_next_9
        ; move t.4, f
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+17]
        mov [rax], bl
_and_next_9:
        ; call printIntLf@bool[t.4]
        lea rax, [rsp+17]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 25:2 if getFalse([]) && getTrue([])
        ; 25:17 logic and
        ; call t.5 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+18]
        mov [rbx], al
        ; branch t.5, false, and_next_11, and_2nd_11
        lea rax, [rsp+18]
        mov bl, [rax]
        or bl, bl
        jz _and_next_11
        ; call t.5 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+18]
        mov [rbx], al
_and_next_11:
        ; branch t.5, true, if_10_then, if_10_else
        lea rax, [rsp+18]
        mov bl, [rax]
        or bl, bl
        jnz _if_10_then
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
        jmp _if_10_end
_if_10_then:
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
_if_10_end:
        ; 26:15 logic and
        ; move t.6, f
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+19]
        mov [rax], bl
        ; branch t.6, false, and_next_12, and_2nd_12
        lea rax, [rsp+19]
        mov bl, [rax]
        or bl, bl
        jz _and_next_12
        ; move t.6, t
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+19]
        mov [rax], bl
_and_next_12:
        ; call printIntLf@bool[t.6]
        lea rax, [rsp+19]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 27:2 if getTrue([]) && getFalse([])
        ; 27:16 logic and
        ; call t.7 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+20]
        mov [rbx], al
        ; branch t.7, false, and_next_14, and_2nd_14
        lea rax, [rsp+20]
        mov bl, [rax]
        or bl, bl
        jz _and_next_14
        ; call t.7 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+20]
        mov [rbx], al
_and_next_14:
        ; branch t.7, true, if_13_then, if_13_else
        lea rax, [rsp+20]
        mov bl, [rax]
        or bl, bl
        jnz _if_13_then
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
        jmp _if_13_end
_if_13_then:
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
_if_13_end:
        ; 28:15 logic and
        ; move t.8, t
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+21]
        mov [rax], bl
        ; branch t.8, false, and_next_15, and_2nd_15
        lea rax, [rsp+21]
        mov bl, [rax]
        or bl, bl
        jz _and_next_15
        ; move t.8, f
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+21]
        mov [rax], bl
_and_next_15:
        ; call printIntLf@bool[t.8]
        lea rax, [rsp+21]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 29:2 if getTrue([]) && getTrue([])
        ; 29:16 logic and
        ; call t.9 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+22]
        mov [rbx], al
        ; branch t.9, false, and_next_17, and_2nd_17
        lea rax, [rsp+22]
        mov bl, [rax]
        or bl, bl
        jz _and_next_17
        ; call t.9 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+22]
        mov [rbx], al
_and_next_17:
        ; branch t.9, true, if_16_then, if_16_else
        lea rax, [rsp+22]
        mov bl, [rax]
        or bl, bl
        jnz _if_16_then
        ; call printError[]
        sub rsp, 8
          call _printError
        add rsp, 8
        jmp _if_16_end
_if_16_then:
        ; call printPass[]
        sub rsp, 8
          call _printPass
        add rsp, 8
_if_16_end:
        ; 30:15 logic and
        ; move t.10, t
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+23]
        mov [rax], bl
        ; branch t.10, false, and_next_18, and_2nd_18
        lea rax, [rsp+23]
        mov bl, [rax]
        or bl, bl
        jz _and_next_18
        ; move t.10, t
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+23]
        mov [rax], bl
_and_next_18:
        ; call printIntLf@bool[t.10]
        lea rax, [rsp+23]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 32:2 if !getFalse([]) && getFalse([])
        ; 32:19 logic and
        ; call t.12 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+25]
        mov [rbx], al
        ; branch t.12, false, and_next_20, and_2nd_20
        lea rax, [rsp+25]
        mov bl, [rax]
        or bl, bl
        jz _and_next_20
        ; call t.12 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+25]
        mov [rbx], al
_and_next_20:
        ; notlog t.11, t.12
        lea rax, [rsp+25]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+24]
        mov [rax], bl
        ; branch t.11, true, if_19_then, if_19_else
        lea rax, [rsp+24]
        mov bl, [rax]
        or bl, bl
        jnz _if_19_then
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
        ; move t.14, f
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+27]
        mov [rax], bl
        ; branch t.14, false, and_next_21, and_2nd_21
        lea rax, [rsp+27]
        mov bl, [rax]
        or bl, bl
        jz _and_next_21
        ; move t.14, f
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+27]
        mov [rax], bl
_and_next_21:
        ; notlog t.13, t.14
        lea rax, [rsp+27]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+26]
        mov [rax], bl
        ; call printIntLf@bool[t.13]
        lea rax, [rsp+26]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 34:2 if !getFalse([]) && getTrue([])
        ; 34:19 logic and
        ; call t.16 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+29]
        mov [rbx], al
        ; branch t.16, false, and_next_23, and_2nd_23
        lea rax, [rsp+29]
        mov bl, [rax]
        or bl, bl
        jz _and_next_23
        ; call t.16 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+29]
        mov [rbx], al
_and_next_23:
        ; notlog t.15, t.16
        lea rax, [rsp+29]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+28]
        mov [rax], bl
        ; branch t.15, true, if_22_then, if_22_else
        lea rax, [rsp+28]
        mov bl, [rax]
        or bl, bl
        jnz _if_22_then
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
        ; move t.18, f
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+31]
        mov [rax], bl
        ; branch t.18, false, and_next_24, and_2nd_24
        lea rax, [rsp+31]
        mov bl, [rax]
        or bl, bl
        jz _and_next_24
        ; move t.18, t
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+31]
        mov [rax], bl
_and_next_24:
        ; notlog t.17, t.18
        lea rax, [rsp+31]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+30]
        mov [rax], bl
        ; call printIntLf@bool[t.17]
        lea rax, [rsp+30]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 36:2 if !getTrue([]) && getFalse([])
        ; 36:18 logic and
        ; call t.20 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+33]
        mov [rbx], al
        ; branch t.20, false, and_next_26, and_2nd_26
        lea rax, [rsp+33]
        mov bl, [rax]
        or bl, bl
        jz _and_next_26
        ; call t.20 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+33]
        mov [rbx], al
_and_next_26:
        ; notlog t.19, t.20
        lea rax, [rsp+33]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+32]
        mov [rax], bl
        ; branch t.19, true, if_25_then, if_25_else
        lea rax, [rsp+32]
        mov bl, [rax]
        or bl, bl
        jnz _if_25_then
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
        ; move t.22, t
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+35]
        mov [rax], bl
        ; branch t.22, false, and_next_27, and_2nd_27
        lea rax, [rsp+35]
        mov bl, [rax]
        or bl, bl
        jz _and_next_27
        ; move t.22, f
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+35]
        mov [rax], bl
_and_next_27:
        ; notlog t.21, t.22
        lea rax, [rsp+35]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+34]
        mov [rax], bl
        ; call printIntLf@bool[t.21]
        lea rax, [rsp+34]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 38:2 if !getTrue([]) && getTrue([])
        ; 38:18 logic and
        ; call t.24 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+37]
        mov [rbx], al
        ; branch t.24, false, and_next_29, and_2nd_29
        lea rax, [rsp+37]
        mov bl, [rax]
        or bl, bl
        jz _and_next_29
        ; call t.24 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+37]
        mov [rbx], al
_and_next_29:
        ; notlog t.23, t.24
        lea rax, [rsp+37]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+36]
        mov [rax], bl
        ; branch t.23, true, if_28_then, if_28_else
        lea rax, [rsp+36]
        mov bl, [rax]
        or bl, bl
        jnz _if_28_then
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
        ; move t.26, t
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+39]
        mov [rax], bl
        ; branch t.26, false, and_next_30, and_2nd_30
        lea rax, [rsp+39]
        mov bl, [rax]
        or bl, bl
        jz _and_next_30
        ; move t.26, t
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+39]
        mov [rax], bl
_and_next_30:
        ; notlog t.25, t.26
        lea rax, [rsp+39]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+38]
        mov [rax], bl
        ; call printIntLf@bool[t.25]
        lea rax, [rsp+38]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; release space for local variables
        add rsp, 48
        ret

        ; void logicOr
        ;   rsp+0: var t
        ;   rsp+1: var f
        ;   rsp+8: var t.2
        ;   rsp+16: var t.3
        ;   rsp+17: var t.4
        ;   rsp+18: var t.5
        ;   rsp+19: var t.6
        ;   rsp+20: var t.7
        ;   rsp+21: var t.8
        ;   rsp+22: var t.9
        ;   rsp+23: var t.10
_logicOr:
        ; reserve space for local variables
        sub rsp, 32
        ; const t.2, [string-6]
        lea rax, [string_6]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call printString@@u8[t.2]
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; const t, 1
        mov al, 1
        lea rbx, [rsp+0]
        mov [rbx], al
        ; const f, 0
        mov al, 0
        lea rbx, [rsp+1]
        mov [rbx], al
        ; 46:2 if getFalse([]) || getFalse([])
        ; 46:17 logic or
        ; call t.3 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+16]
        mov [rbx], al
        ; branch t.3, true, or_next_32, or_2nd_32
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jnz _or_next_32
        ; call t.3 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+16]
        mov [rbx], al
_or_next_32:
        ; branch t.3, true, if_31_then, if_31_else
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jnz _if_31_then
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
        ; move t.4, f
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+17]
        mov [rax], bl
        ; branch t.4, true, or_next_33, or_2nd_33
        lea rax, [rsp+17]
        mov bl, [rax]
        or bl, bl
        jnz _or_next_33
        ; move t.4, f
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+17]
        mov [rax], bl
_or_next_33:
        ; call printIntLf@bool[t.4]
        lea rax, [rsp+17]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 48:2 if getFalse([]) || getTrue([])
        ; 48:17 logic or
        ; call t.5 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+18]
        mov [rbx], al
        ; branch t.5, true, or_next_35, or_2nd_35
        lea rax, [rsp+18]
        mov bl, [rax]
        or bl, bl
        jnz _or_next_35
        ; call t.5 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+18]
        mov [rbx], al
_or_next_35:
        ; branch t.5, true, if_34_then, if_34_else
        lea rax, [rsp+18]
        mov bl, [rax]
        or bl, bl
        jnz _if_34_then
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
        ; move t.6, f
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+19]
        mov [rax], bl
        ; branch t.6, true, or_next_36, or_2nd_36
        lea rax, [rsp+19]
        mov bl, [rax]
        or bl, bl
        jnz _or_next_36
        ; move t.6, t
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+19]
        mov [rax], bl
_or_next_36:
        ; call printIntLf@bool[t.6]
        lea rax, [rsp+19]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 50:2 if getTrue([]) || getFalse([])
        ; 50:16 logic or
        ; call t.7 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+20]
        mov [rbx], al
        ; branch t.7, true, or_next_38, or_2nd_38
        lea rax, [rsp+20]
        mov bl, [rax]
        or bl, bl
        jnz _or_next_38
        ; call t.7 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+20]
        mov [rbx], al
_or_next_38:
        ; branch t.7, true, if_37_then, if_37_else
        lea rax, [rsp+20]
        mov bl, [rax]
        or bl, bl
        jnz _if_37_then
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
        ; move t.8, t
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+21]
        mov [rax], bl
        ; branch t.8, true, or_next_39, or_2nd_39
        lea rax, [rsp+21]
        mov bl, [rax]
        or bl, bl
        jnz _or_next_39
        ; move t.8, f
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+21]
        mov [rax], bl
_or_next_39:
        ; call printIntLf@bool[t.8]
        lea rax, [rsp+21]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 52:2 if getTrue([]) || getTrue([])
        ; 52:16 logic or
        ; call t.9 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+22]
        mov [rbx], al
        ; branch t.9, true, or_next_41, or_2nd_41
        lea rax, [rsp+22]
        mov bl, [rax]
        or bl, bl
        jnz _or_next_41
        ; call t.9 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+22]
        mov [rbx], al
_or_next_41:
        ; branch t.9, true, if_40_then, if_40_else
        lea rax, [rsp+22]
        mov bl, [rax]
        or bl, bl
        jnz _if_40_then
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
        ; move t.10, t
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+23]
        mov [rax], bl
        ; branch t.10, true, or_next_42, or_2nd_42
        lea rax, [rsp+23]
        mov bl, [rax]
        or bl, bl
        jnz _or_next_42
        ; move t.10, t
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+23]
        mov [rax], bl
_or_next_42:
        ; call printIntLf@bool[t.10]
        lea rax, [rsp+23]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; release space for local variables
        add rsp, 32
        ret

        ; void main
        ;   rsp+0: var a
        ;   rsp+2: var b
        ;   rsp+4: var c
        ;   rsp+6: var d
        ;   rsp+8: var t
        ;   rsp+9: var f
        ;   rsp+10: var b10
        ;   rsp+11: var b6
        ;   rsp+12: var b1
        ;   rsp+16: var t.9
        ;   rsp+24: var t.10
        ;   rsp+26: var t.11
        ;   rsp+28: var t.12
        ;   rsp+30: var t.13
        ;   rsp+32: var t.14
        ;   rsp+40: var t.15
        ;   rsp+42: var t.16
        ;   rsp+44: var t.17
        ;   rsp+46: var t.18
        ;   rsp+48: var t.19
        ;   rsp+56: var t.20
        ;   rsp+58: var t.21
        ;   rsp+60: var t.22
        ;   rsp+62: var t.23
        ;   rsp+64: var t.24
        ;   rsp+65: var t.25
        ;   rsp+66: var t.26
        ;   rsp+67: var t.27
        ;   rsp+68: var t.28
        ;   rsp+69: var t.29
        ;   rsp+72: var t.30
        ;   rsp+80: var t.31
        ;   rsp+81: var t.32
        ;   rsp+82: var t.33
        ;   rsp+83: var t.34
        ;   rsp+84: var t.35
        ;   rsp+86: var t.36
_main:
        ; reserve space for local variables
        sub rsp, 96
        ; const t.9, [string-7]
        lea rax, [string_7]
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; call printString@@u8[t.9]
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; const a, 0
        mov ax, 0
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; const b, 1
        mov ax, 1
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; const c, 2
        mov ax, 2
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; const d, 3
        mov ax, 3
        lea rbx, [rsp+6]
        mov [rbx], ax
        ; const t, 1
        mov al, 1
        lea rbx, [rsp+8]
        mov [rbx], al
        ; const f, 0
        mov al, 0
        lea rbx, [rsp+9]
        mov [rbx], al
        ; move t.10, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+24]
        mov [rax], bx
        ; and t.10, t.10, a
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+24]
        mov [rax], bx
        ; call printIntLf@i16[t.10]
        lea rax, [rsp+24]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.11, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+26]
        mov [rax], bx
        ; and t.11, t.11, b
        lea rax, [rsp+26]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+26]
        mov [rax], bx
        ; call printIntLf@i16[t.11]
        lea rax, [rsp+26]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.12, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+28]
        mov [rax], bx
        ; and t.12, t.12, a
        lea rax, [rsp+28]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+28]
        mov [rax], bx
        ; call printIntLf@i16[t.12]
        lea rax, [rsp+28]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.13, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+30]
        mov [rax], bx
        ; and t.13, t.13, b
        lea rax, [rsp+30]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+30]
        mov [rax], bx
        ; call printIntLf@i16[t.13]
        lea rax, [rsp+30]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; const t.14, [string-8]
        lea rax, [string_8]
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; call printString@@u8[t.14]
        lea rax, [rsp+32]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; move t.15, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+40]
        mov [rax], bx
        ; or t.15, t.15, a
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+40]
        mov [rax], bx
        ; call printIntLf@i16[t.15]
        lea rax, [rsp+40]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.16, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+42]
        mov [rax], bx
        ; or t.16, t.16, b
        lea rax, [rsp+42]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+42]
        mov [rax], bx
        ; call printIntLf@i16[t.16]
        lea rax, [rsp+42]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.17, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+44]
        mov [rax], bx
        ; or t.17, t.17, a
        lea rax, [rsp+44]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+44]
        mov [rax], bx
        ; call printIntLf@i16[t.17]
        lea rax, [rsp+44]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.18, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+46]
        mov [rax], bx
        ; or t.18, t.18, b
        lea rax, [rsp+46]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+46]
        mov [rax], bx
        ; call printIntLf@i16[t.18]
        lea rax, [rsp+46]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; const t.19, [string-9]
        lea rax, [string_9]
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; call printString@@u8[t.19]
        lea rax, [rsp+48]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; move t.20, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+56]
        mov [rax], bx
        ; xor t.20, t.20, a
        lea rax, [rsp+56]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+56]
        mov [rax], bx
        ; call printIntLf@i16[t.20]
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.21, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+58]
        mov [rax], bx
        ; xor t.21, t.21, c
        lea rax, [rsp+58]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+58]
        mov [rax], bx
        ; call printIntLf@i16[t.21]
        lea rax, [rsp+58]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.22, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+60]
        mov [rax], bx
        ; xor t.22, t.22, a
        lea rax, [rsp+60]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+60]
        mov [rax], bx
        ; call printIntLf@i16[t.22]
        lea rax, [rsp+60]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.23, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+62]
        mov [rax], bx
        ; xor t.23, t.23, c
        lea rax, [rsp+62]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+62]
        mov [rax], bx
        ; call printIntLf@i16[t.23]
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
        ; 82:32 logic or
        ; 82:18 logic and
        ; call t.25 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+65]
        mov [rbx], al
        ; branch t.25, false, and_next_45, and_2nd_45
        lea rax, [rsp+65]
        mov bl, [rax]
        or bl, bl
        jz _and_next_45
        ; call t.25 = getTrue[] -> bool
        sub rsp, 8
          call _getTrue
        add rsp, 8
        lea rbx, [rsp+65]
        mov [rbx], al
_and_next_45:
        ; notlog t.24, t.25
        lea rax, [rsp+65]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+64]
        mov [rax], bl
        ; branch t.24, true, or_next_44, or_2nd_44
        lea rax, [rsp+64]
        mov bl, [rax]
        or bl, bl
        jnz _or_next_44
        ; 82:48 logic and
        ; call t.26 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+66]
        mov [rbx], al
        ; branch t.26, false, and_next_46, and_2nd_46
        lea rax, [rsp+66]
        mov bl, [rax]
        or bl, bl
        jz _and_next_46
        ; call t.26 = getFalse[] -> bool
        sub rsp, 8
          call _getFalse
        add rsp, 8
        lea rbx, [rsp+66]
        mov [rbx], al
_and_next_46:
        ; notlog t.24, t.26
        lea rax, [rsp+66]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+64]
        mov [rax], bl
_or_next_44:
        ; branch t.24, true, if_43_then, if_43_else
        lea rax, [rsp+64]
        mov bl, [rax]
        or bl, bl
        jnz _if_43_then
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
        ; move t.28, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+68]
        mov [rax], bl
        ; branch t.28, false, and_next_48, and_2nd_48
        lea rax, [rsp+68]
        mov bl, [rax]
        or bl, bl
        jz _and_next_48
        ; move t.28, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+68]
        mov [rax], bl
_and_next_48:
        ; notlog t.27, t.28
        lea rax, [rsp+68]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+67]
        mov [rax], bl
        ; branch t.27, true, or_next_47, or_2nd_47
        lea rax, [rsp+67]
        mov bl, [rax]
        or bl, bl
        jnz _or_next_47
        ; 88:30 logic and
        ; move t.29, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+69]
        mov [rax], bl
        ; branch t.29, false, and_next_49, and_2nd_49
        lea rax, [rsp+69]
        mov bl, [rax]
        or bl, bl
        jz _and_next_49
        ; move t.29, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+69]
        mov [rax], bl
_and_next_49:
        ; notlog t.27, t.29
        lea rax, [rsp+69]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+67]
        mov [rax], bl
_or_next_47:
        ; call printIntLf@bool[t.27]
        lea rax, [rsp+67]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; const t.30, [string-10]
        lea rax, [string_10]
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; call printString@@u8[t.30]
        lea rax, [rsp+72]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; const b10, 10
        mov al, 10
        lea rbx, [rsp+10]
        mov [rbx], al
        ; const b6, 6
        mov al, 6
        lea rbx, [rsp+11]
        mov [rbx], al
        ; const b1, 1
        mov al, 1
        lea rbx, [rsp+12]
        mov [rbx], al
        ; move t.32, b10
        lea rax, [rsp+10]
        mov bl, [rax]
        lea rax, [rsp+81]
        mov [rax], bl
        ; and t.32, t.32, b6
        lea rax, [rsp+81]
        mov bl, [rax]
        lea rax, [rsp+11]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+81]
        mov [rax], bl
        ; move t.31, t.32
        lea rax, [rsp+81]
        mov bl, [rax]
        lea rax, [rsp+80]
        mov [rax], bl
        ; or t.31, t.31, b1
        lea rax, [rsp+80]
        mov bl, [rax]
        lea rax, [rsp+12]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+80]
        mov [rax], bl
        ; call printIntLf@u8[t.31]
        lea rax, [rsp+80]
        mov bl, [rax]
        push rbx
          call _printIntLf@u8
        add rsp, 8
        ; 95:20 logic or
        ; equals t.33, b, c
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+82]
        mov [rax], bl
        ; branch t.33, true, or_next_50, or_2nd_50
        lea rax, [rsp+82]
        mov bl, [rax]
        or bl, bl
        jnz _or_next_50
        ; lt t.33, c, d
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+82]
        mov [rax], bl
_or_next_50:
        ; call printIntLf@bool[t.33]
        lea rax, [rsp+82]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; 96:20 logic and
        ; equals t.34, b, c
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+83]
        mov [rax], bl
        ; branch t.34, false, and_next_51, and_2nd_51
        lea rax, [rsp+83]
        mov bl, [rax]
        or bl, bl
        jz _and_next_51
        ; lt t.34, c, d
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+83]
        mov [rax], bl
_and_next_51:
        ; call printIntLf@bool[t.34]
        lea rax, [rsp+83]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; call printIntLf@i16[-1]
        mov  rax, -1
        push rax
          call _printIntLf@i16
        add rsp, 8
        ; neg t.35, b
        lea rax, [rsp+2]
        mov bx, [rax]
        neg rbx
        lea rax, [rsp+84]
        mov [rax], bx
        ; call printIntLf@i16[t.35]
        lea rax, [rsp+84]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; not t.36, b1
        lea rax, [rsp+12]
        mov bl, [rax]
        not rbx
        lea rax, [rsp+86]
        mov [rax], bl
        ; call printIntLf@u8[t.36]
        lea rax, [rsp+86]
        mov bl, [rax]
        push rbx
          call _printIntLf@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 96
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
