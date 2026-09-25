        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void printUint@u8
        ; arg number (u8): r0
printUint_Pu8:
        ; cast t.1{r0}(i32), param.number{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ld   r1, #0
        ld   r0, #0
        ; call printUint@i32[t.1{r0}]
        call printUint_Pi32
        ret

        ; i64 unusedArgs@u8@bool@u8@u8
        ; arg a (u8): r0
        ; arg b (bool): r1
        ; arg c (u8): r2
        ; arg d (u8): r3
unusedArgs_Pu8_Pbool_Pu8_Pu8:
        ; 9:10 return (i64)
        ; cast t.4{r0}(i64), param.c{r2}(u8)
        ld   r7, r2
        ld   r6, #0
        ld   r5, #0
        ld   r4, #0
        ld   r3, #0
        ld   r2, #0
        ld   r1, #0
        ld   r0, #0
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; begin initialize global variables
        ; const t.zero{r8}, 48
        ld   r8, #%30
        ; addrof a.zero{r10}, zero
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; store [a.zero{r10}], t.zero{r8}
        lde  @rr10, r8
        ; const t.one{r8}, 49
        ld   r8, #%31
        ; addrof a.one{r10}, one
        ld   r10, #hi(var_1)
        ld   r11, #lo(var_1)
        ; store [a.one{r10}], t.one{r8}
        lde  @rr10, r8
        ; const t.two{r8}, 50
        ld   r8, #%32
        ; addrof a.two{r10}, two
        ld   r10, #hi(var_2)
        ld   r11, #lo(var_2)
        ; store [a.two{r10}], t.two{r8}
        lde  @rr10, r8
        ; const t.threeFour{r8}, 34
        ld   r8, #%22
        ; addrof a.threeFour{r10}, threeFour
        ld   r10, #hi(var_3)
        ld   r11, #lo(var_3)
        ; store [a.threeFour{r10}], t.threeFour{r8}
        lde  @rr10, r8
        ; end initialize global variables
        ; const t.3{r1}, 1
        ld   r1, #%01
        ; const arg.0.0{r0}, 1
        ld   r0, #%01
        ; const arg.0.2{r2}, 2
        ld   r2, #%02
        ; const arg.0.3{r3}, 3
        ld   r3, #%03
        ; call _ = unusedArgs@u8@bool@u8@u8[arg.0.0{r0}, t.3{r1}, arg.0.2{r2}, arg.0.3{r3}] -> i64
        call unusedArgs_Pu8_Pbool_Pu8_Pu8
        ; addrof a.zero1{r8}, zero
        ld   r8, #hi(var_0)
        ld   r9, #lo(var_0)
        ; load t.zero1{r0}, [a.zero1{r8}]
        lde  r0, @rr8
        ; call printChar@u8[t.zero1{r0}]
        call printChar_Pu8
        ; addrof onePtr{r8}, one
        ld   r8, #hi(var_1)
        ld   r9, #lo(var_1)
        ; load t.4{r0}, [onePtr{r8}]
        lde  r0, @rr8
        ; call printChar@u8[t.4{r0}]
        call printChar_Pu8
        ; addrof twoPtr{r8}, two
        ld   r8, #hi(var_2)
        ld   r9, #lo(var_2)
        ; const t.7{r10}, 0
        ld   r10, #%00
        ld   r11, #%00
        ; add t.6{r8}, t.6{r8}, t.7{r10}
        add  r9, r11
        adc  r8, r10
        ; load t.5{r0}, [t.6{r8}]
        lde  r0, @rr8
        ; call printChar@u8[t.5{r0}]
        call printChar_Pu8
        ; addrof a.threeFour1{r8}, threeFour
        ld   r8, #hi(var_3)
        ld   r9, #lo(var_3)
        ; load t.threeFour1{r0}, [a.threeFour1{r8}]
        lde  r0, @rr8
        ; call printUint@u8[t.threeFour1{r0}]
        call printUint_Pu8
        ; const arg.5.0{r0}, 10
        ld   r0, #%0a
        ; call printChar@u8[arg.5.0{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void printChar@u8
printChar_Pu8:
        cp    r0, #%0a
        jr    ne, .1
        ld    r0, #%0d
.1:
        ld    %15, r0
        jp    %0818

        ; void printUint@i32
printUint_Pi32:
        ld   r4, #1
        ld   r5, #%28
        ld   r6, #8
.push:
        push @r5
        inc  r5
        djnz r6, .push
        ; result
        clr     r11
        clr     r12
        clr     r13
        clr     r14
        clr     r15
        ; summand (bcd-shifted power of 2)
        clr     r6
        clr     r7
        clr     r8
        clr     r9
        ld      r10, #1
        ; counter
        ld      r5, #%20
.1:
        sra     r0
        rrc     r1
        rrc     r2
        rrc     r3
        jr      nc, .2
        add     r15, r10
        da      r15
        adc     r14, r9
        da      r14
        adc     r13, r8
        da      r13
        adc     r12, r7
        da      r12
        adc     r11, r6
        da      r11
.2:
        add     r10, r10
        da      r10
        adc     r9, r9
        da      r9
        adc     r8, r8
        da      r8
        adc     r7, r7
        da      r7
        adc     r6, r6
        da      r6
        djnz    r5, .1
        ld      r6, #%2b
        ; counter
        ld      r7, #10
.loop:
        ld      r5, @r6
        tm      r7, #1
        jr      nz, .4
        swap    r5
.4:
        and     r5, #%0f
        or      r4, r4
        jr      z, .5
        cp      r7, #1
        jr      eq, .5
        or      r5, r5
        jr      z, .6
        clr     r4
.5:
        ld      %15, r5
        add     %15, #'0'
        call    %0818
.6:
        tm      r7, #1
        jr      z, .7
        inc     r6
.7:
        djnz    r7, .loop
        ld   r5, #%2f
        ld   r6, #8
.pop:
        pop  @r5
        dec  r5
        djnz r6, .pop
        ret

        ; variable 0: zero (u8/1)
var_0:
        .data %00
        ; variable 1: one (u8/1)
var_1:
        .data %00
        ; variable 2: two (u8/1)
var_2:
        .data %00
        ; variable 3: threeFour (u8/1)
var_3:
        .data %00
