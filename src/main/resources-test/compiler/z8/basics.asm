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
        push r12
        push r13
        push r14
        push r15
        ; begin initialize global variables
        ; const tmp.zero{r8}, 48
        ld   r8, #%30
        ; const tmp.one{r9}, 49
        ld   r9, #%31
        ; const tmp.two{r10}, 50
        ld   r10, #%32
        ; const tmp.threeFour{r11}, 34
        ld   r11, #%22
        ; end initialize global variables
        ; const t.3{r0}, 1
        ld   r0, #%01
        ; const t.4{r1}, 1
        ld   r1, #%01
        ; const t.5{r2}, 2
        ld   r2, #%02
        ; const t.6{r3}, 3
        ld   r3, #%03
        ; addrof memVarAddr{r14}, zero
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; store [memVarAddr{r14}], tmp.zero{r8}
        lde  @rr14, r8
        ; addrof memVarAddr{r14}, one
        ld   r14, #hi(var__1)
        ld   r15, #lo(var__1)
        ; store [memVarAddr{r14}], tmp.one{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, two
        ld   r14, #hi(var__2)
        ld   r15, #lo(var__2)
        ; store [memVarAddr{r14}], tmp.two{r10}
        lde  @rr14, r10
        ; addrof memVarAddr{r14}, threeFour
        ld   r14, #hi(var__3)
        ld   r15, #lo(var__3)
        ; store [memVarAddr{r14}], tmp.threeFour{r11}
        lde  @rr14, r11
        ; call _ = unusedArgs@u8@bool@u8@u8[t.3{r0}, t.4{r1}, t.5{r2}, t.6{r3}] -> i64
        call unusedArgs_Pu8_Pbool_Pu8_Pu8
        ; addrof memVarAddr{r14}, zero
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; load tmp.zero{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; move tmp.zero{r0}, tmp.zero{r8}
        ld   r0, r8
        ; call printChar@u8[tmp.zero{r0}]
        call printChar_Pu8
        ; addrof onePtr{r8}, one
        ld   r8, #hi(var__1)
        ld   r9, #lo(var__1)
        ; load t.7{r0}, [onePtr{r8}]
        lde  r0, @rr8
        ; call printChar@u8[t.7{r0}]
        call printChar_Pu8
        ; addrof twoPtr{r8}, two
        ld   r8, #hi(var__2)
        ld   r9, #lo(var__2)
        ; const t.10{r10}, 0
        ld   r10, #%00
        ld   r11, #%00
        ; add t.9{r8}, t.9{r8}, t.10{r10}
        add  r9, r11
        adc  r8, r10
        ; load t.8{r0}, [t.9{r8}]
        lde  r0, @rr8
        ; call printChar@u8[t.8{r0}]
        call printChar_Pu8
        ; addrof memVarAddr{r14}, threeFour
        ld   r14, #hi(var__3)
        ld   r15, #lo(var__3)
        ; load tmp.threeFour{r11}, [memVarAddr{r14}]
        lde  r11, @rr14
        ; move tmp.threeFour{r0}, tmp.threeFour{r11}
        ld   r0, r11
        ; call printUint@u8[tmp.threeFour{r0}]
        call printUint_Pu8
        ; const t.11{r0}, 10
        ld   r0, #%0a
        ; call printChar@u8[t.11{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r15
        pop  r14
        pop  r13
        pop  r12
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
var__0:
        .data %00
        ; variable 1: one (u8/1)
var__1:
        .data %00
        ; variable 2: two (u8/1)
var__2:
        .data %00
        ; variable 3: threeFour (u8/1)
var__3:
        .data %00
