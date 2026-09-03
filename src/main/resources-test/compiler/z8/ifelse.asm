        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void printUint@i16
        ; arg number (i16): r0
printUint_Pi16:
        ; cast t.1{r0}(i32), param.number{r0}(i16)
        ld   r3, r1
        ld   r2, r0
        ld   r0, r0
        rl   r0
        sbc  r0, r0
        sbc  r1, r1
        ; call printUint@i32[t.1{r0}]
        call printUint_Pi32
        ret

        ; void printIntLf@i16
        ; arg number (i16): r0
printIntLf_Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        ; move param.number{r8}, number{r0}
        ld   r8, r0
        ld   r9, r1
        ; 127:2 if number < 0
        ; lt t.1{r10}, param.number{r8}, 0
        cp   r8, #%00
        jr   lt, .true1
        jr   ne, .false1
        cp   r9, #%00
        jr   uge, .false1
.true1:
        ld   r10, #1
        jr   .1
.false1:
        ld   r10, #0
.1:
        ; branch t.1{r10}, false, @if_1_end, @if_1_then
        or   r10, r10
        jr   z, if__1__end
        ; const arg.0.0{r0}, 45
        ld   r0, #%2d
        ; call printChar@u8[arg.0.0{r0}]
        call printChar_Pu8
        ; neg param.number{r8}, param.number{r8}
        com  r8
        com  r9
        incw r8
if__1__end:
        ; move param.number{r0}, param.number{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printUint@i16[param.number{r0}]
        call printUint_Pi16
        ; const arg.2.0{r0}, 13
        ld   r0, #%0d
        ; call printChar@u8[arg.2.0{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        ; const a{r8}, 1
        ld   r8, #%00
        ld   r9, #%01
        ; 5:2 if a > 0
        ; gt t.1{r10}, a{r8}, 0
        cp   r8, #%00
        jr   gt, .true2
        jr   ne, .false2
        cp   r9, #%00
        jr   ule, .false2
.true2:
        ld   r10, #1
        jr   .2
.false2:
        ld   r10, #0
.2:
        ; branch t.1{r10}, true, @if_2_then, @if_2_else
        or   r10, r10
        jr   nz, if__2__then
        ; neg a{r8}, a{r8}
        com  r8
        com  r9
        incw r8
        ; move a{r0}, a{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printIntLf@i16[a{r0}]
        call printIntLf_Pi16
        jr   main__ret

if__2__then:
        ; move a{r0}, a{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printIntLf@i16[a{r0}]
        call printIntLf_Pi16
main__ret:
        ; restore clobbered non-volatile registers
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
