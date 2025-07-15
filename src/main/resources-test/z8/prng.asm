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
        jp @while_1
@while_1_body:
        ; load chr{r0}, [str{r8}]
        lde r0, rr8
        ; call printChar[chr{r0}]
        call printChar
        ; dec length{r10}
        dec r10
@while_1:
        ; gt t.3{r0}, length{r10}, 0
        cp  r10, #%00
        jr  uge, .1
.1:
        ld  r0, #%ff
        jr  .3
.2:
        ld  r0, #%00
.3:
        ; branch t.3{r0}, true, @while_1_body
        or r0, r0
        jp nz, @while_1_body
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
@while_2:
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
        jr  nz, .4
        cp  r1, #%00
        jr  nz, .4
        cp  r2, #%00
        jr  nz, .4
        cp  r3, #%00
        jr  nz, .4
        cp  r4, #%00
        jr  nz, .4
        cp  r5, #%00
        jr  nz, .4
        cp  r6, #%00
        jr  nz, .4
        cp  r7, #%00
        jr  nz, .4
        cp  r8, #%00
        jr  nz, .4
        cp  r9, #%00
        jr  nz, .4
        cp  r10, #%00
        jr  nz, .4
        cp  r11, #%00
        jr  nz, .4
        cp  r12, #%00
        jr  nz, .4
        cp  r13, #%00
        jr  nz, .4
        cp  r14, #%00
        jr  nz, .4
        cp  r15, #%00
        jr  nz, .4
        ld  r9, #%ff
        jr  .5
.4:
        ld  r9, #%00
.5:
        ; branch t.13{r9}, false, @while_2
        or r9, r9
        jp z, @while_2
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
        jr  lt, .6
        jr  nz, .7
        cp  r9, #%00
        jr  ult, .6
.6:
        ld  r10, #%ff
        jr  .8
.7:
        ld  r10, #%00
.8:
        ; branch t.1{r10}, false, @if_4_end
        or r10, r10
        jp z, @if_4_end
        ; const t.2{r0}, 45
        ld r0, #%2d
        ; call printChar[t.2{r0}]
        call printChar
        ; neg number{r8}, number{r8}
        com r8
        com r9
        incw r8
@if_4_end:
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

        ; void initRandom
        ;   sp+5: arg salt
@initRandom:
        ret

        ; i32 random
@random:
        ; 70:9 return 0
        ; const t.0{r0}, 0
        ld r0, #%00
        ld r1, #%00
        ld r2, #%00
        ld r3, #%00
        ret

        ; u8 randomU8
@randomU8:
        ; 74:10 return (u8)
        ; call t.1{r0} = random[] -> i32
        call random
        ; cast t.0{r0}(u8), t.1{r0}(i32)
        not implemented
        ret

        ; void main
@main:
        ; save globbered non-volatile registers
        push r8
        push r9
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.2{r0}, 7439742
        ld r0, #%00
        ld r1, #%71
        ld r2, #%85
        ld r3, #%7e
        ; call initRandom[t.2{r0}]
        call initRandom
        ; const i{r8}, 0
        ld r8, #%00
        ; 5:2 for i < 50
        jp @for_5
@for_5_body:
        ; call r{r0} = randomU8[] -> u8
        call randomU8
        ; cast t.4{r0}(i16), r{r0}(u8)
        not implemented
        ; call printIntLf[t.4{r0}]
        call printIntLf
        ; inc i{r8}
        inc r8
@for_5:
        ; lt t.3{r0}, i{r8}, 50
        cp  r8, #%32
        jr  ult, .9
.9:
        ld  r0, #%ff
        jr  .11
.10:
        ld  r0, #%00
.11:
        ; branch t.3{r0}, true, @for_5_body
        or r0, r0
        jp nz, @for_5_body
        ; restore globbered non-volatile registers
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

