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
@main:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; begin initialize global variables
        ; const tmp.text{r8}, [string-0]
        not implemented
        ; end initialize global variables
        ; move text, tmp.text{r8}
        not implemented
        ; move tmp.text{r0}, tmp.text{r8}
        ld r0, r8
        ld r1, r9
        ; call printString[tmp.text{r0}]
        call printString
        ; call printLength[]
        call printLength
        ; const t.2{r10}, 1
        ld r10, #%00
        ld r11, #%01
        ; cast t.3{r10}(u8*), t.2{r10}(i16)
        not implemented
        ; move tmp.text{r8}, text
        not implemented
        ; move second{r0}, tmp.text{r8}
        ld r0, r8
        ld r1, r9
        ; add second{r0}, second{r0}, t.3{r10}
        add r1, r11
        adc r0, r10
        ; call printString[second{r0}]
        call printString
        ; move tmp.text{r8}, text
        not implemented
        ; load chr{r8}, [tmp.text{r8}]
        lde r8, rr8
        ; cast t.4{r0}(i16), chr{r8}(u8)
        not implemented
        ; call printIntLf[t.4{r0}]
        call printIntLf
        ; restore globbered non-volatile registers
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printLength
@printLength:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; const length{r0}, 0
        ld r0, #%00
        ld r1, #%00
        ; move tmp.text{r8}, text
        not implemented
        ; 16:2 for *ptr != 0
        jp @for_7
@for_7_body:
        ; inc length{r0}
        incw r0
        ; cast t.5{r10}(i16), ptr{r8}(u8*)
        not implemented
        ; const t.6{r12}, 1
        ld r12, #%00
        ld r13, #%01
        ; add t.4{r10}, t.4{r10}, t.6{r12}
        add r11, r13
        adc r10, r12
        ; cast ptr{r8}(u8*), t.4{r10}(i16)
        not implemented
@for_7:
        ; load t.3{r10}, [ptr{r8}]
        lde r10, rr8
        ; notequals t.2{r10}, t.3{r10}, 0
        cp  r10, #%00
        jr  nz, .11
        cp  r11, #%00
        jr  nz, .11
        cp  r12, #%00
        jr  nz, .11
        cp  r13, #%00
        jr  nz, .11
        cp  r14, #%00
        jr  nz, .11
        cp  r15, #%00
        jr  nz, .11
        cp  %30, #%00
        jr  nz, .11
        cp  %31, #%00
        jr  nz, .11
        cp  %32, #%00
        jr  nz, .11
        cp  %33, #%00
        jr  nz, .11
        cp  %34, #%00
        jr  nz, .11
        cp  %35, #%00
        jr  nz, .11
        cp  %36, #%00
        jr  nz, .11
        cp  %37, #%00
        jr  nz, .11
        cp  %38, #%00
        jr  nz, .11
        cp  %39, #%00
        jr  nz, .11
        ld  r10, #%00
        jr  .12
.11:
        ld  r10, #%ff
.12:
        ; branch t.2{r10}, true, @for_7_body
        or r10, r10
        jp nz, @for_7_body
        ; call printIntLf[length{r0}]
        call printIntLf
        ; restore globbered non-volatile registers
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
        ; variable 0: text (u8*/2)
        var_0 rb 2

section '.data' data readable
        string_0 db 'hello world', 0x0a, 0x00

