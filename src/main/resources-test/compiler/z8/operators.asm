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

        ; void printIntLf@bool
        ; arg number (bool): r0
printIntLf_Pbool:
        ret

        ; void printIntLf@u8
        ; arg number (u8): r0
printIntLf_Pu8:
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
        ; var d (i16): SP+8
        ; var f (bool): SP+10
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
        ; const t.9{r0}, [string-0]
        ld   r0, #hi(string__0)
        ld   r1, #lo(string__0)
        ; call printString@@u8[t.9{r0}]
        call printString_P_Pu8
        ; const a{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ; const b{r10}, 1
        ld   r10, #%00
        ld   r11, #%01
        ; const c{r12}, 2
        ld   r12, #%00
        ld   r13, #%02
        ; const d{r2}, 3
        ld   r2, #%00
        ld   r3, #%03
        ; addrof memVarAddr{r14}, d
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], d{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        ; const t{r14}, 1
        ld   r14, #%01
        ; const f{r2}, 0
        ld   r2, #%00
        ; addrof memVarAddr{r14}, f
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], f{r2}
        lde  @rr14, r2
        ; move t.10{r0}, a{r8}
        ld   r0, r8
        ld   r1, r9
        ; and t.10{r0}, t.10{r0}, a{r8}
        and  r0, r8
        and  r1, r9
        ; call printIntLf@i16[t.10{r0}]
        call printIntLf_Pi16
        ; move t.11{r0}, a{r8}
        ld   r0, r8
        ld   r1, r9
        ; and t.11{r0}, t.11{r0}, b{r10}
        and  r0, r10
        and  r1, r11
        ; call printIntLf@i16[t.11{r0}]
        call printIntLf_Pi16
        ; move t.12{r0}, b{r10}
        ld   r0, r10
        ld   r1, r11
        ; and t.12{r0}, t.12{r0}, a{r8}
        and  r0, r8
        and  r1, r9
        ; call printIntLf@i16[t.12{r0}]
        call printIntLf_Pi16
        ; move t.13{r0}, b{r10}
        ld   r0, r10
        ld   r1, r11
        ; and t.13{r0}, t.13{r0}, b{r10}
        and  r0, r10
        and  r1, r11
        ; call printIntLf@i16[t.13{r0}]
        call printIntLf_Pi16
        ; const t.14{r0}, [string-1]
        ld   r0, #hi(string__1)
        ld   r1, #lo(string__1)
        ; call printString@@u8[t.14{r0}]
        call printString_P_Pu8
        ; move t.15{r0}, a{r8}
        ld   r0, r8
        ld   r1, r9
        ; or t.15{r0}, t.15{r0}, a{r8}
        or   r0, r8
        or   r1, r9
        ; call printIntLf@i16[t.15{r0}]
        call printIntLf_Pi16
        ; move t.16{r0}, a{r8}
        ld   r0, r8
        ld   r1, r9
        ; or t.16{r0}, t.16{r0}, b{r10}
        or   r0, r10
        or   r1, r11
        ; call printIntLf@i16[t.16{r0}]
        call printIntLf_Pi16
        ; move t.17{r0}, b{r10}
        ld   r0, r10
        ld   r1, r11
        ; or t.17{r0}, t.17{r0}, a{r8}
        or   r0, r8
        or   r1, r9
        ; call printIntLf@i16[t.17{r0}]
        call printIntLf_Pi16
        ; move t.18{r0}, b{r10}
        ld   r0, r10
        ld   r1, r11
        ; or t.18{r0}, t.18{r0}, b{r10}
        or   r0, r10
        or   r1, r11
        ; call printIntLf@i16[t.18{r0}]
        call printIntLf_Pi16
        ; const t.19{r0}, [string-2]
        ld   r0, #hi(string__2)
        ld   r1, #lo(string__2)
        ; call printString@@u8[t.19{r0}]
        call printString_P_Pu8
        ; move t.20{r0}, a{r8}
        ld   r0, r8
        ld   r1, r9
        ; xor t.20{r0}, t.20{r0}, a{r8}
        xor  r0, r8
        xor  r1, r9
        ; call printIntLf@i16[t.20{r0}]
        call printIntLf_Pi16
        ; move t.21{r0}, a{r8}
        ld   r0, r8
        ld   r1, r9
        ; xor t.21{r0}, t.21{r0}, c{r12}
        xor  r0, r12
        xor  r1, r13
        ; call printIntLf@i16[t.21{r0}]
        call printIntLf_Pi16
        ; move t.22{r0}, b{r10}
        ld   r0, r10
        ld   r1, r11
        ; xor t.22{r0}, t.22{r0}, a{r8}
        xor  r0, r8
        xor  r1, r9
        ; call printIntLf@i16[t.22{r0}]
        call printIntLf_Pi16
        ; move t.23{r0}, b{r10}
        ld   r0, r10
        ld   r1, r11
        ; xor t.23{r0}, t.23{r0}, c{r12}
        xor  r0, r12
        xor  r1, r13
        ; call printIntLf@i16[t.23{r0}]
        call printIntLf_Pi16
        ; const t.24{r0}, [string-3]
        ld   r0, #hi(string__3)
        ld   r1, #lo(string__3)
        ; call printString@@u8[t.24{r0}]
        call printString_P_Pu8
        ; 26:15 logic and
        ; addrof memVarAddr{r14}, f
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load f{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; move t.25{r0}, f{r8}
        ld   r0, r8
        ; branch t.25{r0}, false, @and_next_2, @and_2nd_2
        or   r0, r0
        jr   z, and__next__2
        ; move t.25{r0}, f{r8}
        ld   r0, r8
and__next__2:
        ; call printIntLf@bool[t.25{r0}]
        call printIntLf_Pbool
        ; 27:15 logic and
        ; move t.26{r0}, f{r8}
        ld   r0, r8
        ; branch t.26{r0}, false, @and_next_3, @and_2nd_3
        or   r0, r0
        jr   z, and__next__3
        ; move t.26{r0}, t{r14}
        ld   r0, r14
and__next__3:
        ; call printIntLf@bool[t.26{r0}]
        call printIntLf_Pbool
        ; 28:15 logic and
        ; move t.27{r0}, t{r14}
        ld   r0, r14
        ; branch t.27{r0}, false, @and_next_4, @and_2nd_4
        or   r0, r0
        jr   z, and__next__4
        ; move t.27{r0}, f{r8}
        ld   r0, r8
and__next__4:
        ; call printIntLf@bool[t.27{r0}]
        call printIntLf_Pbool
        ; 29:15 logic and
        ; move t.28{r0}, t{r14}
        ld   r0, r14
        ; branch t.28{r0}, false, @and_next_5, @and_2nd_5
        or   r0, r0
        jr   z, and__next__5
        ; move t.28{r0}, t{r14}
        ld   r0, r14
and__next__5:
        ; call printIntLf@bool[t.28{r0}]
        call printIntLf_Pbool
        ; const t.29{r0}, [string-4]
        ld   r0, #hi(string__4)
        ld   r1, #lo(string__4)
        ; call printString@@u8[t.29{r0}]
        call printString_P_Pu8
        ; 31:15 logic or
        ; move t.30{r0}, f{r8}
        ld   r0, r8
        ; branch t.30{r0}, true, @or_next_6, @or_2nd_6
        or   r0, r0
        jr   nz, or__next__6
        ; move t.30{r0}, f{r8}
        ld   r0, r8
or__next__6:
        ; call printIntLf@bool[t.30{r0}]
        call printIntLf_Pbool
        ; 32:15 logic or
        ; move t.31{r0}, f{r8}
        ld   r0, r8
        ; branch t.31{r0}, true, @or_next_7, @or_2nd_7
        or   r0, r0
        jr   nz, or__next__7
        ; move t.31{r0}, t{r14}
        ld   r0, r14
or__next__7:
        ; call printIntLf@bool[t.31{r0}]
        call printIntLf_Pbool
        ; 33:15 logic or
        ; move t.32{r0}, t{r14}
        ld   r0, r14
        ; branch t.32{r0}, true, @or_next_8, @or_2nd_8
        or   r0, r0
        jr   nz, or__next__8
        ; move t.32{r0}, f{r8}
        ld   r0, r8
or__next__8:
        ; call printIntLf@bool[t.32{r0}]
        call printIntLf_Pbool
        ; 34:15 logic or
        ; move t.33{r0}, t{r14}
        ld   r0, r14
        ; branch t.33{r0}, true, @or_next_9, @or_2nd_9
        or   r0, r0
        jr   nz, or__next__9
        ; move t.33{r0}, t{r14}
        ld   r0, r14
or__next__9:
        ; call printIntLf@bool[t.33{r0}]
        call printIntLf_Pbool
        ; const t.34{r0}, [string-5]
        ld   r0, #hi(string__5)
        ld   r1, #lo(string__5)
        ; call printString@@u8[t.34{r0}]
        call printString_P_Pu8
        ; notlog t.35{r0}, f{r8}
        or   r8, r8
        ld   r0, #0  ; false
        jr   nz, .2
        ld   r0, #1  ; true
.2:
        ; call printIntLf@bool[t.35{r0}]
        call printIntLf_Pbool
        ; notlog t.36{r0}, t{r14}
        or   r14, r14
        ld   r0, #0  ; false
        jr   nz, .3
        ld   r0, #1  ; true
.3:
        ; call printIntLf@bool[t.36{r0}]
        call printIntLf_Pbool
        ; const t.37{r0}, [string-6]
        ld   r0, #hi(string__6)
        ld   r1, #lo(string__6)
        ; call printString@@u8[t.37{r0}]
        call printString_P_Pu8
        ; const b10{r8}, 10
        ld   r8, #%0a
        ; const b6{r9}, 6
        ld   r9, #%06
        ; const b1{r14}, 1
        ld   r14, #%01
        ; and t.39{r8}, t.39{r8}, b6{r9}
        and  r8, r9
        ; move t.38{r0}, t.39{r8}
        ld   r0, r8
        ; or t.38{r0}, t.38{r0}, b1{r14}
        or   r0, r14
        ; call printIntLf@u8[t.38{r0}]
        call printIntLf_Pu8
        ; 43:20 logic or
        ; equals t.40{r0}, b{r10}, c{r12}
        cp   r10, r12
        jr   ne, .ne4
        cp   r11, r13
        jr   ne, .ne4
        ld   r0, #1  ; true
        jr   .4
.ne4:
        ld   r0, #0
.4:
        ; branch t.40{r0}, false, @or_2nd_10, @no_critical_edge_30
        or   r0, r0
        jr   z, or__2nd__10
        ; addrof memVarAddr{r14}, d
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load d{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        jr   or__next__10

or__2nd__10:
        ; addrof memVarAddr{r14}, d
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load d{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        ; lt t.40{r0}, c{r12}, d{r8}
        cp   r12, r8
        jr   lt, .true5
        jr   ne, .false5
        cp   r13, r9
        jr   uge, .false5
.true5:
        ld   r0, #1
        jr   .5
.false5:
        ld   r0, #0
.5:
or__next__10:
        ; call printIntLf@bool[t.40{r0}]
        call printIntLf_Pbool
        ; 44:20 logic and
        ; equals t.41{r0}, b{r10}, c{r12}
        cp   r10, r12
        jr   ne, .ne6
        cp   r11, r13
        jr   ne, .ne6
        ld   r0, #1  ; true
        jr   .6
.ne6:
        ld   r0, #0
.6:
        ; branch t.41{r0}, false, @and_next_11, @and_2nd_11
        or   r0, r0
        jr   z, and__next__11
        ; lt t.41{r0}, c{r12}, d{r8}
        cp   r12, r8
        jr   lt, .true7
        jr   ne, .false7
        cp   r13, r9
        jr   uge, .false7
.true7:
        ld   r0, #1
        jr   .7
.false7:
        ld   r0, #0
.7:
and__next__11:
        ; call printIntLf@bool[t.41{r0}]
        call printIntLf_Pbool
        ; const t.42{r0}, -1
        ld   r0, #%ff
        ld   r1, #%ff
        ; call printIntLf@i16[t.42{r0}]
        call printIntLf_Pi16
        ; neg t.43{r0}, b{r10}
        ld   r0, #%00
        ld   r1, #%00
        sub  r1, r11
        sbc  r0, r10
        ; call printIntLf@i16[t.43{r0}]
        call printIntLf_Pi16
        ; not t.44{r0}, b1{r14}
        ld   r0, r14
        com  r0
        ; call printIntLf@u8[t.44{r0}]
        call printIntLf_Pu8
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

        ; void printString@@u8
printString_P_Pu8:
        ld   r2, r0
        ld   r3, r1
        jr   .loop
.print:
        call printChar_Pu8
        incw r2
.loop:
        lde  r0, @rr2
        or   r0, r0
        jr   nz, .print
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

string__0:
        .data "Bit-&:" %0a %00
string__1:
        .data %0a "Bit-|:" %0a %00
string__2:
        .data %0a "Bit-^:" %0a %00
string__3:
        .data %0a "Logic-&&:" %0a %00
string__4:
        .data %0a "Logic-||:" %0a %00
string__5:
        .data %0a "Logic-!:" %0a %00
string__6:
        .data %0a "misc:" %0a %00

