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
        push r11
        ; move param.number{r8}, number{r0}
        ld   r8, r0
        ld   r9, r1
        ; 127:2 if number < 0
        ; const t.2{r10}, 0
        ld   r10, #%00
        ld   r11, #%00
        ; lt t.1{r10}, param.number{r8}, t.2{r10}
        cp   r8, r10
        jr   lt, .true1
        jr   ne, .false1
        cp   r9, r11
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
        ; const t.3{r0}, 45
        ld   r0, #%2d
        ; call printChar@u8[t.3{r0}]
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
        ; const t.4{r0}, 13
        ld   r0, #%0d
        ; call printChar@u8[t.4{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r11
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
        push r11
        push r12
        push r13
        push r14
        push r15
        ; begin initialize global variables
        ; const tmp.space{r8}, 32
        ld   r8, #%00
        ld   r9, #%20
        ; const tmp.next{r0}, 63
        ld   r0, #%00
        ld   r1, #%3f
        ; addrof tmp.ptrToSpace{r10}, space
        ld   r10, #hi(var__0)
        ld   r11, #lo(var__0)
        ; end initialize global variables
        ; addrof memVarAddr{r14}, space
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; store [memVarAddr{r14}], tmp.space{r8}
        lde  @rr14, r8
        incw r14
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, next
        ld   r14, #hi(var__1)
        ld   r15, #lo(var__1)
        ; store [memVarAddr{r14}], tmp.next{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, ptrToSpace
        ld   r14, #hi(var__2)
        ld   r15, #lo(var__2)
        ; store [memVarAddr{r14}], tmp.ptrToSpace{r10}
        lde  @rr14, r10
        incw r14
        lde  @rr14, r11
        ; call printIntLf@i16[tmp.next{r0}]
        call printIntLf_Pi16
        ; const t.0{r8}, 2
        ld   r8, #%00
        ld   r9, #%02
        ; addrof memVarAddr{r14}, ptrToSpace
        ld   r14, #hi(var__2)
        ld   r15, #lo(var__2)
        ; load tmp.ptrToSpace{r10}, [memVarAddr{r14}]
        lde  r10, @rr14
        incw r14
        lde  r11, @rr14
        ; add tmp.ptrToSpace{r10}, tmp.ptrToSpace{r10}, t.0{r8}
        add  r11, r9
        adc  r10, r8
        ; addrof memVarAddr{r14}, ptrToSpace
        ld   r14, #hi(var__2)
        ld   r15, #lo(var__2)
        ; store [memVarAddr{r14}], tmp.ptrToSpace{r10}
        lde  @rr14, r10
        incw r14
        lde  @rr14, r11
        ; load t.1{r0}, [tmp.ptrToSpace{r10}]
        lde  r0, @rr10
        incw r10
        lde  r1, @rr10
        ; call printIntLf@i16[t.1{r0}]
        call printIntLf_Pi16
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

        ; variable 0: space (i16/2)
var__0:
        .data %00 %00
        ; variable 1: next (i16/2)
var__1:
        .data %00 %00
        ; variable 2: ptrToSpace (i16*/2)
var__2:
        .data %00 %00
