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

        ; i64 unusedArgs
        ;   sp+20: arg a
        ;   sp+18: arg b
        ;   sp+17: arg c
        ;   sp+9: arg d
@unusedArgs:
        ; 9:9 return c
        ret

        ; void main
        ;   sp+15: var t.5
        ;   sp+7: var t.6
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
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        ; begin initialize global variables
        ; const tmp.zero{r11}, 48
        ld r11, #%30
        ; const tmp.one{r12}, 49
        ld r12, #%31
        ; const tmp.two{r13}, 50
        ld r13, #%32
        ; const tmp.threeFour{r14}, 34
        ld r14, #%22
        ; end initialize global variables
        ; const t.3{r8}, 1
        ld r8, #%00
        ld r9, #%01
        ; const t.4{r10}, 1
        ld r10, #%01
        ; const t.5{r0}, 2
        ld r0, #%00
        ld r1, #%00
        ld r2, #%00
        ld r3, #%00
        ld r4, #%00
        ld r5, #%00
        ld r6, #%00
        ld r7, #%02
        ; const t.6, 3
        not implemented
        ; move zero, tmp.zero{r11}
        not implemented
        ; move one, tmp.one{r12}
        not implemented
        ; move two, tmp.two{r13}
        not implemented
        ; move threeFour, tmp.threeFour{r14}
        not implemented
        ; move t.5, t.5{r0}
        not implemented
        ; call _ = unusedArgs[t.3{r8}, t.4{r10}, t.5, t.6] -> i64
        ; need to push t.5
        ; need to push t.6
        call unusedArgs
        ; move tmp.zero{r11}, zero
        not implemented
        ; move tmp.zero{r0}, tmp.zero{r11}
        ld r0, r11
        ; call printChar[tmp.zero{r0}]
        call printChar
        ; addrof onePtr{r8}, one
        not implemented
        ; load t.7{r0}, [onePtr{r8}]
        lde r0, rr8
        ; call printChar[t.7{r0}]
        call printChar
        ; addrof twoPtr{r8}, two
        not implemented
        ; const t.10{r10}, 0
        ld r10, #%00
        ld r11, #%00
        ; cast t.11{r10}(u8*), t.10{r10}(i16)
        not implemented
        ; add t.9{r8}, t.9{r8}, t.11{r10}
        add r9, r11
        adc r8, r10
        ; load t.8{r0}, [t.9{r8}]
        lde r0, rr8
        ; call printChar[t.8{r0}]
        call printChar
        ; move tmp.threeFour{r14}, threeFour
        not implemented
        ; cast t.12{r0}(i16), tmp.threeFour{r14}(u8)
        not implemented
        ; call printUint[t.12{r0}]
        call printUint
        ; const t.13{r0}, 10
        ld r0, #%0a
        ; call printChar[t.13{r0}]
        call printChar
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
        incw SPH
        incw SPH
        incw SPH
        incw SPH
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
        ; variable 0: zero (u8/1)
        var_0 rb 1
        ; variable 1: one (u8/1)
        var_1 rb 1
        ; variable 2: two (u8/1)
        var_2 rb 1
        ; variable 3: threeFour (u8/1)
        var_3 rb 1

