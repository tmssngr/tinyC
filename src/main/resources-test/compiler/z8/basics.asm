        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

        srp  #%20
        jr   main

        ; void printUint_Pu8
        ; arg number (u8): r0
printUint_Pu8:
        ; cast t.1.1{r0}(i32), param.number{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ld   r1, #0
        ld   r0, #0
        ; call printUint_Pi32[t.1.1{r0}]
        call printUint_Pi32
        ret

        ; i64 unusedArgs_Pu8_Pbool_Pu8_Pu8
        ; arg a (u8): r0
        ; arg b (bool): r1
        ; arg c (u8): r2
        ; arg d (u8): r3
unusedArgs_Pu8_Pbool_Pu8_Pu8:
        ; 9:14 return (i64)
        ; cast t.4.1{r0}(i64), param.c{r2}(u8)
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
        ; begin initialize global variables
        ; const t.3.1{r0}, 48
        ld   r0, #%30
        ; addrof a.4.1{r2}, zero
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; store [a.4.1{r2}], t.3.1{r0}
        lde  @rr2, r0
        ; const t.5.1{r0}, 49
        ld   r0, #%31
        ; addrof a.6.1{r2}, one
        ld   r2, #hi(var_1)
        ld   r3, #lo(var_1)
        ; store [a.6.1{r2}], t.5.1{r0}
        lde  @rr2, r0
        ; const t.7.1{r0}, 50
        ld   r0, #%32
        ; addrof a.8.1{r2}, two
        ld   r2, #hi(var_2)
        ld   r3, #lo(var_2)
        ; store [a.8.1{r2}], t.7.1{r0}
        lde  @rr2, r0
        ; const t.9.1{r0}, 34
        ld   r0, #%22
        ; addrof a.10.1{r2}, threeFour
        ld   r2, #hi(var_3)
        ld   r3, #lo(var_3)
        ; store [a.10.1{r2}], t.9.1{r0}
        lde  @rr2, r0
        ; end initialize global variables
        ; const t.11.1{r1}, 1
        ld   r1, #%01
        ; const arg.0.0{r0}, 1
        ld   r0, #%01
        ; const arg.0.2{r2}, 2
        ld   r2, #%02
        ; const arg.0.3{r3}, 3
        ld   r3, #%03
        ; call _ = unusedArgs_Pu8_Pbool_Pu8_Pu8[arg.0.0{r0}, t.11.1{r1}, arg.0.2{r2}, arg.0.3{r3}] -> i64
        call unusedArgs_Pu8_Pbool_Pu8_Pu8
        ; addrof a.12.1{r0}, zero
        ld   r0, #hi(var_0)
        ld   r1, #lo(var_0)
        ; load t.13.1{r2}, [a.12.1{r0}]
        lde  r2, @rr0
        ; move t.13.1{r0}, t.13.1{r2}
        ld   r0, r2
        ; call printChar_Pu8[t.13.1{r0}]
        call printChar_Pu8
        ; addrof onePtr.1{r0}, one
        ld   r0, #hi(var_1)
        ld   r1, #lo(var_1)
        ; load t.14.1{r2}, [onePtr.1{r0}]
        lde  r2, @rr0
        ; move t.14.1{r0}, t.14.1{r2}
        ld   r0, r2
        ; call printChar_Pu8[t.14.1{r0}]
        call printChar_Pu8
        ; addrof twoPtr.1{r0}, two
        ld   r0, #hi(var_2)
        ld   r1, #lo(var_2)
        ; const t.17.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; add t.16.2{r0}, t.17.1{r2}
        add  r1, r3
        adc  r0, r2
        ; load t.15.1{r2}, [t.16.2{r0}]
        lde  r2, @rr0
        ; move t.15.1{r0}, t.15.1{r2}
        ld   r0, r2
        ; call printChar_Pu8[t.15.1{r0}]
        call printChar_Pu8
        ; addrof a.18.1{r0}, threeFour
        ld   r0, #hi(var_3)
        ld   r1, #lo(var_3)
        ; load t.19.1{r2}, [a.18.1{r0}]
        lde  r2, @rr0
        ; move t.19.1{r0}, t.19.1{r2}
        ld   r0, r2
        ; call printUint_Pu8[t.19.1{r0}]
        call printUint_Pu8
        ; const arg.5.0{r0}, 10
        ld   r0, #%0a
        ; call printChar_Pu8[arg.5.0{r0}]
        call printChar_Pu8
        ret

        ; void printChar_Pu8
printChar_Pu8:
        cp    r0, #%0a
        jr    ne, .1
        ld    r0, #%0d
.1:
        ld    %15, r0
        jp    %0818

        ; void printUint_Pi32
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
