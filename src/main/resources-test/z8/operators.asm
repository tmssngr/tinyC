        .const RP  = %FD
        .const SPH = %FE
        .const SPL = %FF

        .org %E000

start:
        push RP
        srp  #%20
        call @main
        pop  RP
        ret

        ; void printString
        ;   sp+7: arg str
@printString:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; move str{r8}, str{r0}
        ld r8, r0
        ld r9, r1
        ; 2:2 while true
        jp @while_1
@if_2_end:
        ; move chr{r0}, chr{r10}
        ld r0, r10
        ; call printChar[chr{r0}]
        call printChar
@while_1:
        ; load chr{r10}, [str{r8}]
        lde r10, rr8
        ; 4:3 if chr == 0
        ; equals t.2{r0}, chr{r10}, 0
        cp  r10, #%00
        jr  nz, .1
        cp  r11, #%00
        jr  nz, .1
        cp  r12, #%00
        jr  nz, .1
        cp  r13, #%00
        jr  nz, .1
        cp  r14, #%00
        jr  nz, .1
        cp  r15, #%00
        jr  nz, .1
        cp  %30, #%00
        jr  nz, .1
        cp  %31, #%00
        jr  nz, .1
        cp  %32, #%00
        jr  nz, .1
        cp  %33, #%00
        jr  nz, .1
        cp  %34, #%00
        jr  nz, .1
        cp  %35, #%00
        jr  nz, .1
        cp  %36, #%00
        jr  nz, .1
        cp  %37, #%00
        jr  nz, .1
        cp  %38, #%00
        jr  nz, .1
        cp  %39, #%00
        jr  nz, .1
        ld  r0, #%ff
        jr  .2
.1:
        ld  r0, #%00
.2:
        ; branch t.2{r0}, false, @if_2_end
        or r0, r0
        jp z, @if_2_end
        ; restore globbered non-volatile registers
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printStringLength
        ;   sp+8: arg str
        ;   sp+6: arg length
@printStringLength:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; move str{r8}, str{r0}
        ld r8, r0
        ld r9, r1
        ; move length{r10}, length{r2}
        ld r10, r2
        ; 13:2 while length > 0
        jp @while_3
@while_3_body:
        ; load chr{r0}, [str{r8}]
        lde r0, rr8
        ; call printChar[chr{r0}]
        call printChar
        ; dec length{r10}
        dec r10
@while_3:
        ; gt t.3{r0}, length{r10}, 0
        cp  r10, #%00
        jr  uge, .3
.3:
        ld  r0, #%ff
        jr  .5
.4:
        ld  r0, #%00
.5:
        ; branch t.3{r0}, true, @while_3_body
        or r0, r0
        jp nz, @while_3_body
        ; restore globbered non-volatile registers
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printUint
        ;   sp+19: arg number
        ;   sp+9: var buffer
        ;   sp+7: var remainder
@printUint:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; reserve space for local variables
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        ; const pos{r8}, 20
        ld r8, #%14
        ; 24:2 while true
@while_4:
        ; dec pos{r8}
        dec r8
        ; const t.6{r9}, 10
        ld r9, #%00
        ld r10, #%0a
        ; move t.5{r11}, number{r0}
        ld r11, r0
        ld r12, r1
        ; mod t.5{r11}, t.5{r11}, t.6{r9}
        not implemented
        ; cast remainder(i64), t.5{r11}(i16)
        not implemented
        ; const t.7{r9}, 10
        ld r9, #%00
        ld r10, #%0a
        ; div number{r0}, number{r0}, t.7{r9}
        not implemented
        ; cast t.8{r9}(u8), remainder(i64)
        not implemented
        ; const t.9{r10}, 48
        ld r10, #%30
        ; add digit{r9}, digit{r9}, t.9{r10}
        add r9, r10
        ; cast t.11{r10}(i16), pos{r8}(u8)
        not implemented
        ; cast t.12{r10}(u8*), t.11{r10}(i16)
        not implemented
        ; addrof t.10{r12}, [buffer]
        not implemented
        ; add t.10{r12}, t.10{r12}, t.12{r10}
        add r13, r11
        adc r12, r10
        ; store [t.10{r12}], digit{r9}
        lde rr12, r9
        ; 30:3 if number == 0
        ; equals t.13{r9}, number{r0}, 0
        cp  r0, #%00
        jr  nz, .6
        cp  r1, #%00
        jr  nz, .6
        cp  r2, #%00
        jr  nz, .6
        cp  r3, #%00
        jr  nz, .6
        cp  r4, #%00
        jr  nz, .6
        cp  r5, #%00
        jr  nz, .6
        cp  r6, #%00
        jr  nz, .6
        cp  r7, #%00
        jr  nz, .6
        cp  r8, #%00
        jr  nz, .6
        cp  r9, #%00
        jr  nz, .6
        cp  r10, #%00
        jr  nz, .6
        cp  r11, #%00
        jr  nz, .6
        cp  r12, #%00
        jr  nz, .6
        cp  r13, #%00
        jr  nz, .6
        cp  r14, #%00
        jr  nz, .6
        cp  r15, #%00
        jr  nz, .6
        ld  r9, #%ff
        jr  .7
.6:
        ld  r9, #%00
.7:
        ; branch t.13{r9}, false, @while_4
        or r9, r9
        jp z, @while_4
        ; cast t.15{r9}(i16), pos{r8}(u8)
        not implemented
        ; cast t.16{r10}(u8*), t.15{r9}(i16)
        not implemented
        ; addrof t.14{r0}, [buffer]
        not implemented
        ; add t.14{r0}, t.14{r0}, t.16{r10}
        add r1, r11
        adc r0, r10
        ; const t.18{r9}, 20
        ld r9, #%14
        ; move t.17{r2}, t.18{r9}
        ld r2, r9
        ; sub t.17{r2}, t.17{r2}, pos{r8}
        sub r2, r8
        ; call printStringLength[t.14{r0}, t.17{r2}]
        call printStringLength
        ; free space for local variables
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        ; restore globbered non-volatile registers
        pop r13
        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printIntLf
        ;   sp+7: arg number
@printIntLf:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; move number{r8}, number{r0}
        ld r8, r0
        ld r9, r1
        ; 38:2 if number < 0
        ; lt t.1{r10}, number{r8}, 0
        cp  r8, #%00
        jr  lt, .8
        jr  nz, .9
        cp  r9, #%00
        jr  ult, .8
.8:
        ld  r10, #%ff
        jr  .10
.9:
        ld  r10, #%00
.10:
        ; branch t.1{r10}, false, @if_6_end
        or r10, r10
        jp z, @if_6_end
        ; const t.2{r0}, 45
        ld r0, #%2d
        ; call printChar[t.2{r0}]
        call printChar
        ; neg number{r8}, number{r8}
        com r8
        com r9
        incw r8
@if_6_end:
        ; move number{r0}, number{r8}
        ld r0, r8
        ld r1, r9
        ; call printUint[number{r0}]
        call printUint
        ; const t.3{r0}, 10
        ld r0, #%0a
        ; call printChar[t.3{r0}]
        call printChar
        ; restore globbered non-volatile registers
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void main
        ;   sp+1: var t
        ;   sp+0: var f
@main:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; reserve space for local variables
        decw SPH
        decw SPH
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.9{r0}, [string-0]
        not implemented
        ; call printString[t.9{r0}]
        call printString
        ; const a{r8}, 0
        ld r8, #%00
        ld r9, #%00
        ; const b{r10}, 1
        ld r10, #%00
        ld r11, #%01
        ; const c{r12}, 2
        ld r12, #%00
        ld r13, #%02
        ; const d{r14}, 3
        ld r14, #%00
        ld r15, #%03
        ; const t{r2}, 1
        ld r2, #%01
        ; const f{r3}, 0
        ld r3, #%00
        ; move t.10{r0}, a{r8}
        ld r0, r8
        ld r1, r9
        ; and t.10{r0}, t.10{r0}, a{r8}
        and r1, r9
        and r0, r8
        ; move t, t{r2}
        not implemented
        ; move f, f{r3}
        not implemented
        ; call printIntLf[t.10{r0}]
        call printIntLf
        ; move t.11{r0}, a{r8}
        ld r0, r8
        ld r1, r9
        ; and t.11{r0}, t.11{r0}, b{r10}
        and r1, r11
        and r0, r10
        ; call printIntLf[t.11{r0}]
        call printIntLf
        ; move t.12{r0}, b{r10}
        ld r0, r10
        ld r1, r11
        ; and t.12{r0}, t.12{r0}, a{r8}
        and r1, r9
        and r0, r8
        ; call printIntLf[t.12{r0}]
        call printIntLf
        ; move t.13{r0}, b{r10}
        ld r0, r10
        ld r1, r11
        ; and t.13{r0}, t.13{r0}, b{r10}
        and r1, r11
        and r0, r10
        ; call printIntLf[t.13{r0}]
        call printIntLf
        ; const t.14{r0}, [string-1]
        not implemented
        ; call printString[t.14{r0}]
        call printString
        ; move t.15{r0}, a{r8}
        ld r0, r8
        ld r1, r9
        ; or t.15{r0}, t.15{r0}, a{r8}
        or r1, r9
        or r0, r8
        ; call printIntLf[t.15{r0}]
        call printIntLf
        ; move t.16{r0}, a{r8}
        ld r0, r8
        ld r1, r9
        ; or t.16{r0}, t.16{r0}, b{r10}
        or r1, r11
        or r0, r10
        ; call printIntLf[t.16{r0}]
        call printIntLf
        ; move t.17{r0}, b{r10}
        ld r0, r10
        ld r1, r11
        ; or t.17{r0}, t.17{r0}, a{r8}
        or r1, r9
        or r0, r8
        ; call printIntLf[t.17{r0}]
        call printIntLf
        ; move t.18{r0}, b{r10}
        ld r0, r10
        ld r1, r11
        ; or t.18{r0}, t.18{r0}, b{r10}
        or r1, r11
        or r0, r10
        ; call printIntLf[t.18{r0}]
        call printIntLf
        ; const t.19{r0}, [string-2]
        not implemented
        ; call printString[t.19{r0}]
        call printString
        ; move t.20{r0}, a{r8}
        ld r0, r8
        ld r1, r9
        ; xor t.20{r0}, t.20{r0}, a{r8}
        xor r1, r9
        xor r0, r8
        ; call printIntLf[t.20{r0}]
        call printIntLf
        ; move t.21{r0}, a{r8}
        ld r0, r8
        ld r1, r9
        ; xor t.21{r0}, t.21{r0}, c{r12}
        xor r1, r13
        xor r0, r12
        ; call printIntLf[t.21{r0}]
        call printIntLf
        ; move t.22{r0}, b{r10}
        ld r0, r10
        ld r1, r11
        ; xor t.22{r0}, t.22{r0}, a{r8}
        xor r1, r9
        xor r0, r8
        ; call printIntLf[t.22{r0}]
        call printIntLf
        ; move t.23{r0}, b{r10}
        ld r0, r10
        ld r1, r11
        ; xor t.23{r0}, t.23{r0}, c{r12}
        xor r1, r13
        xor r0, r12
        ; call printIntLf[t.23{r0}]
        call printIntLf
        ; const t.24{r0}, [string-3]
        not implemented
        ; call printString[t.24{r0}]
        call printString
        ; 26:15 logic and
        ; move f{r8}, f
        not implemented
        ; move t.26{r9}, f{r8}
        ld r9, r8
        ; branch t.26{r9}, false, @and_next_7
        or r9, r9
        jp z, @and_next_7
        ; move t.26{r9}, f{r8}
        ld r9, r8
@and_next_7:
        ; cast t.25{r0}(i16), t.26{r9}(bool)
        not implemented
        ; call printIntLf[t.25{r0}]
        call printIntLf
        ; 27:15 logic and
        ; move t.28{r9}, f{r8}
        ld r9, r8
        ; branch t.28{r9}, true, @and_2nd_8
        or r9, r9
        jp nz, @and_2nd_8
        ; move t{r2}, t
        not implemented
        jp @and_next_8
@and_2nd_8:
        ; move t{r2}, t
        not implemented
        ; move t.28{r9}, t{r2}
        ld r9, r2
@and_next_8:
        ; cast t.27{r0}(i16), t.28{r9}(bool)
        not implemented
        ; move t{r9}, t{r2}
        ld r9, r2
        ; call printIntLf[t.27{r0}]
        call printIntLf
        ; 28:15 logic and
        ; move t.30{r2}, t{r9}
        ld r2, r9
        ; branch t.30{r2}, false, @and_next_9
        or r2, r2
        jp z, @and_next_9
        ; move t.30{r2}, f{r8}
        ld r2, r8
@and_next_9:
        ; cast t.29{r0}(i16), t.30{r2}(bool)
        not implemented
        ; call printIntLf[t.29{r0}]
        call printIntLf
        ; 29:15 logic and
        ; move t.32{r2}, t{r9}
        ld r2, r9
        ; branch t.32{r2}, false, @and_next_10
        or r2, r2
        jp z, @and_next_10
        ; move t.32{r2}, t{r9}
        ld r2, r9
@and_next_10:
        ; cast t.31{r0}(i16), t.32{r2}(bool)
        not implemented
        ; call printIntLf[t.31{r0}]
        call printIntLf
        ; const t.33{r0}, [string-4]
        not implemented
        ; call printString[t.33{r0}]
        call printString
        ; 31:15 logic or
        ; move t.35{r2}, f{r8}
        ld r2, r8
        ; branch t.35{r2}, true, @or_next_11
        or r2, r2
        jp nz, @or_next_11
        ; move t.35{r2}, f{r8}
        ld r2, r8
@or_next_11:
        ; cast t.34{r0}(i16), t.35{r2}(bool)
        not implemented
        ; call printIntLf[t.34{r0}]
        call printIntLf
        ; 32:15 logic or
        ; move t.37{r2}, f{r8}
        ld r2, r8
        ; branch t.37{r2}, true, @or_next_12
        or r2, r2
        jp nz, @or_next_12
        ; move t.37{r2}, t{r9}
        ld r2, r9
@or_next_12:
        ; cast t.36{r0}(i16), t.37{r2}(bool)
        not implemented
        ; call printIntLf[t.36{r0}]
        call printIntLf
        ; 33:15 logic or
        ; move t.39{r2}, t{r9}
        ld r2, r9
        ; branch t.39{r2}, true, @or_next_13
        or r2, r2
        jp nz, @or_next_13
        ; move t.39{r2}, f{r8}
        ld r2, r8
@or_next_13:
        ; cast t.38{r0}(i16), t.39{r2}(bool)
        not implemented
        ; call printIntLf[t.38{r0}]
        call printIntLf
        ; 34:15 logic or
        ; move t.41{r2}, t{r9}
        ld r2, r9
        ; branch t.41{r2}, true, @or_next_14
        or r2, r2
        jp nz, @or_next_14
        ; move t.41{r2}, t{r9}
        ld r2, r9
@or_next_14:
        ; cast t.40{r0}(i16), t.41{r2}(bool)
        not implemented
        ; call printIntLf[t.40{r0}]
        call printIntLf
        ; const t.42{r0}, [string-5]
        not implemented
        ; call printString[t.42{r0}]
        call printString
        ; notlog t.44{r8}, f{r8}
        not implemented
        ; cast t.43{r0}(i16), t.44{r8}(bool)
        not implemented
        ; call printIntLf[t.43{r0}]
        call printIntLf
        ; notlog t.46{r8}, t{r9}
        not implemented
        ; cast t.45{r0}(i16), t.46{r8}(bool)
        not implemented
        ; call printIntLf[t.45{r0}]
        call printIntLf
        ; const t.47{r0}, [string-6]
        not implemented
        ; call printString[t.47{r0}]
        call printString
        ; const b10{r8}, 10
        ld r8, #%0a
        ; const b6{r9}, 6
        ld r9, #%06
        ; const b1{r2}, 1
        ld r2, #%01
        ; and t.50{r8}, t.50{r8}, b6{r9}
        and r8, r9
        ; or t.49{r8}, t.49{r8}, b1{r2}
        or r8, r2
        ; cast t.48{r0}(i16), t.49{r8}(u8)
        not implemented
        ; move b1{r8}, b1{r2}
        ld r8, r2
        ; call printIntLf[t.48{r0}]
        call printIntLf
        ; 43:20 logic or
        ; equals t.52{r9}, b{r10}, c{r12}
        not implemented
        ; branch t.52{r9}, true, @or_next_15
        or r9, r9
        jp nz, @or_next_15
        ; lt t.52{r9}, c{r12}, d{r14}
        not implemented
@or_next_15:
        ; cast t.51{r0}(i16), t.52{r9}(bool)
        not implemented
        ; call printIntLf[t.51{r0}]
        call printIntLf
        ; 44:20 logic and
        ; equals t.54{r9}, b{r10}, c{r12}
        not implemented
        ; branch t.54{r9}, false, @and_next_16
        or r9, r9
        jp z, @and_next_16
        ; lt t.54{r9}, c{r12}, d{r14}
        not implemented
@and_next_16:
        ; cast t.53{r0}(i16), t.54{r9}(bool)
        not implemented
        ; call printIntLf[t.53{r0}]
        call printIntLf
        ; const t.55{r0}, -1
        ld r0, #%ff
        ld r1, #%ff
        ; call printIntLf[t.55{r0}]
        call printIntLf
        ; neg t.56{r0}, b{r10}
        ld r0, #%00
        ld r1, #%00
        sub r1, r11
        sbc r0, r10
        ; call printIntLf[t.56{r0}]
        call printIntLf
        ; not t.58{r8}, b1{r8}
        com r8
        ; cast t.57{r0}(i16), t.58{r8}(u8)
        not implemented
        ; call printIntLf[t.57{r0}]
        call printIntLf
        ; free space for local variables
        incw SPH
        incw SPH
        ; restore globbered non-volatile registers
        pop r15
        pop r14
        pop r13
        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printChar
@printChar:
        ld   r0, SPH
        ld   r1, SPL
        add  r1, 3
        adc  r0, 0
        ldc  r1, @rr0
        ld   %15, r1
        jp   %0818

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8

section '.data' data readable
        string_0 db 'Bit-&:', 0x0a, 0x00
        string_1 db 0x0a, 'Bit-|:', 0x0a, 0x00
        string_2 db 0x0a, 'Bit-^:', 0x0a, 0x00
        string_3 db 0x0a, 'Logic-&&:', 0x0a, 0x00
        string_4 db 0x0a, 'Logic-||:', 0x0a, 0x00
        string_5 db 0x0a, 'Logic-!:', 0x0a, 0x00
        string_6 db 0x0a, 'misc:', 0x0a, 0x00

