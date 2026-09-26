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
        ; move param.number{r8}, number{r0}
        ld   r9, r1
        ld   r8, r0
        ; 127:2 if number < 0
        ; branch param.number{r8} gteq 0: if_1_end, if_1_then
        cp   r8, #%00
        jr   gt, if__1__end
        jr   ne, .gt1
        cp   r9, #%00
        jr   uge, if__1__end
.gt1:
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
        pop  r9
        pop  r8
        ret

        ; bool getTrue
getTrue:
        ; const t.0{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString@@u8[t.0{r0}]
        call printString_P_Pu8
        ; 3:49 return true
        ; const {r0}, 1
        ld   r0, #%01
        ret

        ; bool getFalse
getFalse:
        ; const t.0{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.0{r0}]
        call printString_P_Pu8
        ; 4:49 return false
        ; const {r0}, 0
        ld   r0, #%00
        ret

        ; void printPass
printPass:
        ; const t.0{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.0{r0}]
        call printString_P_Pu8
        ret

        ; void printError
printError:
        ; const t.0{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString@@u8[t.0{r0}]
        call printString_P_Pu8
        ret

        ; void logicNot
logicNot:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const t.2{r0}, [string-4]
        ld   r0, #hi(string_4)
        ld   r1, #lo(string_4)
        ; call printString@@u8[t.2{r0}]
        call printString_P_Pu8
        ; const t{r8}, 1
        ld   r8, #%01
        ; const f{r9}, 0
        ld   r9, #%00
        ; 13:2 if !getFalse([])
        ; call t.3{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.3{r0} equals 0: if_2_then, if_2_else
        cp   r0, #%00
        jr   eq, if__2__then
        ; call printError[]
        call printError
        jr   if__2__end

if__2__then:
        ; call printPass[]
        call printPass
if__2__end:
        ; notlog t.4{r0}, f{r9}
        or   r9, r9
        ld   r0, #0  ; false
        jr   nz, .2
        ld   r0, #1  ; true
.2:
        ; call printIntLf@bool[t.4{r0}]
        call printIntLf_Pbool
        ; 15:2 if !getTrue([])
        ; call t.5{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.5{r0} equals 0: if_3_then, if_3_else
        cp   r0, #%00
        jr   eq, if__3__then
        ; call printPass[]
        call printPass
        jr   if__3__end

if__3__then:
        ; call printError[]
        call printError
if__3__end:
        ; notlog t.6{r0}, t{r8}
        or   r8, r8
        ld   r0, #0  ; false
        jr   nz, .3
        ld   r0, #1  ; true
.3:
        ; call printIntLf@bool[t.6{r0}]
        call printIntLf_Pbool
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void logicAnd
logicAnd:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        ; const t.2{r0}, [string-5]
        ld   r0, #hi(string_5)
        ld   r1, #lo(string_5)
        ; call printString@@u8[t.2{r0}]
        call printString_P_Pu8
        ; const t{r8}, 1
        ld   r8, #%01
        ; const f{r9}, 0
        ld   r9, #%00
        ; 23:2 if getFalse([]) && getFalse([])
        ; call t.3{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.3{r0} equals 0: if_4_else, and_5
        cp   r0, #%00
        jr   eq, if__4__else
        ; call t.4{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.4{r0} equals 0: if_4_else, if_4_then
        cp   r0, #%00
        jr   eq, if__4__else
        ; call printError[]
        call printError
        jr   if__4__end

if__4__else:
        ; call printPass[]
        call printPass
if__4__end:
        ; 24:15 logic and
        ; move t.5{r0}, f{r9}
        ld   r0, r9
        ; branch t.5{r0} equals 0: and_next_6, and_2nd_6
        cp   r0, #%00
        jr   eq, and__next__6
        ; move t.5{r0}, f{r9}
        ld   r0, r9
and__next__6:
        ; call printIntLf@bool[t.5{r0}]
        call printIntLf_Pbool
        ; 25:2 if getFalse([]) && getTrue([])
        ; call t.6{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.6{r0} equals 0: if_7_else, and_8
        cp   r0, #%00
        jr   eq, if__7__else
        ; call t.7{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.7{r0} equals 0: if_7_else, if_7_then
        cp   r0, #%00
        jr   eq, if__7__else
        ; call printError[]
        call printError
        jr   if__7__end

if__7__else:
        ; call printPass[]
        call printPass
if__7__end:
        ; 26:15 logic and
        ; move t.8{r0}, f{r9}
        ld   r0, r9
        ; branch t.8{r0} equals 0: and_next_9, and_2nd_9
        cp   r0, #%00
        jr   eq, and__next__9
        ; move t.8{r0}, t{r8}
        ld   r0, r8
and__next__9:
        ; call printIntLf@bool[t.8{r0}]
        call printIntLf_Pbool
        ; 27:2 if getTrue([]) && getFalse([])
        ; call t.9{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.9{r0} equals 0: if_10_else, and_11
        cp   r0, #%00
        jr   eq, if__10__else
        ; call t.10{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.10{r0} equals 0: if_10_else, if_10_then
        cp   r0, #%00
        jr   eq, if__10__else
        ; call printError[]
        call printError
        jr   if__10__end

if__10__else:
        ; call printPass[]
        call printPass
if__10__end:
        ; 28:15 logic and
        ; move t.11{r0}, t{r8}
        ld   r0, r8
        ; branch t.11{r0} equals 0: and_next_12, and_2nd_12
        cp   r0, #%00
        jr   eq, and__next__12
        ; move t.11{r0}, f{r9}
        ld   r0, r9
and__next__12:
        ; call printIntLf@bool[t.11{r0}]
        call printIntLf_Pbool
        ; 29:2 if getTrue([]) && getTrue([])
        ; call t.12{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.12{r0} equals 0: if_13_else, and_14
        cp   r0, #%00
        jr   eq, if__13__else
        ; call t.13{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.13{r0} equals 0: if_13_else, if_13_then
        cp   r0, #%00
        jr   eq, if__13__else
        ; call printPass[]
        call printPass
        jr   if__13__end

if__13__else:
        ; call printError[]
        call printError
if__13__end:
        ; 30:15 logic and
        ; move t.14{r0}, t{r8}
        ld   r0, r8
        ; branch t.14{r0} equals 0: and_next_15, and_2nd_15
        cp   r0, #%00
        jr   eq, and__next__15
        ; move t.14{r0}, t{r8}
        ld   r0, r8
and__next__15:
        ; call printIntLf@bool[t.14{r0}]
        call printIntLf_Pbool
        ; 32:2 if !getFalse([]) && getFalse([])
        ; call t.15{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.15{r0} equals 0: if_16_then, and_17
        cp   r0, #%00
        jr   eq, if__16__then
        ; call t.16{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.16{r0} equals 0: if_16_then, if_16_else
        cp   r0, #%00
        jr   eq, if__16__then
        ; call printError[]
        call printError
        jr   if__16__end

if__16__then:
        ; call printPass[]
        call printPass
if__16__end:
        ; 33:17 logic and
        ; move t.18{r10}, f{r9}
        ld   r10, r9
        ; branch t.18{r10} equals 0: and_next_18, and_2nd_18
        cp   r10, #%00
        jr   eq, and__next__18
        ; move t.18{r10}, f{r9}
        ld   r10, r9
and__next__18:
        ; notlog t.17{r0}, t.18{r10}
        or   r10, r10
        ld   r0, #0  ; false
        jr   nz, .4
        ld   r0, #1  ; true
.4:
        ; call printIntLf@bool[t.17{r0}]
        call printIntLf_Pbool
        ; 34:2 if !getFalse([]) && getTrue([])
        ; call t.19{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.19{r0} equals 0: if_19_then, and_20
        cp   r0, #%00
        jr   eq, if__19__then
        ; call t.20{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.20{r0} equals 0: if_19_then, if_19_else
        cp   r0, #%00
        jr   eq, if__19__then
        ; call printError[]
        call printError
        jr   if__19__end

if__19__then:
        ; call printPass[]
        call printPass
if__19__end:
        ; 35:17 logic and
        ; move t.22{r10}, f{r9}
        ld   r10, r9
        ; branch t.22{r10} equals 0: and_next_21, and_2nd_21
        cp   r10, #%00
        jr   eq, and__next__21
        ; move t.22{r10}, t{r8}
        ld   r10, r8
and__next__21:
        ; notlog t.21{r0}, t.22{r10}
        or   r10, r10
        ld   r0, #0  ; false
        jr   nz, .5
        ld   r0, #1  ; true
.5:
        ; call printIntLf@bool[t.21{r0}]
        call printIntLf_Pbool
        ; 36:2 if !getTrue([]) && getFalse([])
        ; call t.23{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.23{r0} equals 0: if_22_then, and_23
        cp   r0, #%00
        jr   eq, if__22__then
        ; call t.24{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.24{r0} equals 0: if_22_then, if_22_else
        cp   r0, #%00
        jr   eq, if__22__then
        ; call printError[]
        call printError
        jr   if__22__end

if__22__then:
        ; call printPass[]
        call printPass
if__22__end:
        ; 37:17 logic and
        ; move t.26{r10}, t{r8}
        ld   r10, r8
        ; branch t.26{r10} equals 0: and_next_24, and_2nd_24
        cp   r10, #%00
        jr   eq, and__next__24
        ; move t.26{r10}, f{r9}
        ld   r10, r9
and__next__24:
        ; notlog t.25{r0}, t.26{r10}
        or   r10, r10
        ld   r0, #0  ; false
        jr   nz, .6
        ld   r0, #1  ; true
.6:
        ; call printIntLf@bool[t.25{r0}]
        call printIntLf_Pbool
        ; 38:2 if !getTrue([]) && getTrue([])
        ; call t.27{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.27{r0} equals 0: if_25_then, and_26
        cp   r0, #%00
        jr   eq, if__25__then
        ; call t.28{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.28{r0} equals 0: if_25_then, if_25_else
        cp   r0, #%00
        jr   eq, if__25__then
        ; call printPass[]
        call printPass
        jr   if__25__end

if__25__then:
        ; call printError[]
        call printError
if__25__end:
        ; 39:17 logic and
        ; move t.30{r9}, t{r8}
        ld   r9, r8
        ; branch t.30{r9} equals 0: and_next_27, and_2nd_27
        cp   r9, #%00
        jr   eq, and__next__27
        ; move t.30{r9}, t{r8}
        ld   r9, r8
and__next__27:
        ; notlog t.29{r0}, t.30{r9}
        or   r9, r9
        ld   r0, #0  ; false
        jr   nz, .7
        ld   r0, #1  ; true
.7:
        ; call printIntLf@bool[t.29{r0}]
        call printIntLf_Pbool
        ; restore clobbered non-volatile registers
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void logicOr
logicOr:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const t.2{r0}, [string-6]
        ld   r0, #hi(string_6)
        ld   r1, #lo(string_6)
        ; call printString@@u8[t.2{r0}]
        call printString_P_Pu8
        ; const t{r8}, 1
        ld   r8, #%01
        ; const f{r9}, 0
        ld   r9, #%00
        ; 46:2 if getFalse([]) || getFalse([])
        ; call t.3{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.3{r0} notequals 0: if_28_then, or_29
        cp   r0, #%00
        jr   ne, if__28__then
        ; call t.4{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.4{r0} notequals 0: if_28_then, if_28_else
        cp   r0, #%00
        jr   ne, if__28__then
        ; call printPass[]
        call printPass
        jr   if__28__end

if__28__then:
        ; call printError[]
        call printError
if__28__end:
        ; 47:15 logic or
        ; move t.5{r0}, f{r9}
        ld   r0, r9
        ; branch t.5{r0} notequals 0: or_next_30, or_2nd_30
        cp   r0, #%00
        jr   ne, or__next__30
        ; move t.5{r0}, f{r9}
        ld   r0, r9
or__next__30:
        ; call printIntLf@bool[t.5{r0}]
        call printIntLf_Pbool
        ; 48:2 if getFalse([]) || getTrue([])
        ; call t.6{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.6{r0} notequals 0: if_31_then, or_32
        cp   r0, #%00
        jr   ne, if__31__then
        ; call t.7{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.7{r0} notequals 0: if_31_then, if_31_else
        cp   r0, #%00
        jr   ne, if__31__then
        ; call printError[]
        call printError
        jr   if__31__end

if__31__then:
        ; call printPass[]
        call printPass
if__31__end:
        ; 49:15 logic or
        ; move t.8{r0}, f{r9}
        ld   r0, r9
        ; branch t.8{r0} notequals 0: or_next_33, or_2nd_33
        cp   r0, #%00
        jr   ne, or__next__33
        ; move t.8{r0}, t{r8}
        ld   r0, r8
or__next__33:
        ; call printIntLf@bool[t.8{r0}]
        call printIntLf_Pbool
        ; 50:2 if getTrue([]) || getFalse([])
        ; call t.9{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.9{r0} notequals 0: if_34_then, or_35
        cp   r0, #%00
        jr   ne, if__34__then
        ; call t.10{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.10{r0} notequals 0: if_34_then, if_34_else
        cp   r0, #%00
        jr   ne, if__34__then
        ; call printError[]
        call printError
        jr   if__34__end

if__34__then:
        ; call printPass[]
        call printPass
if__34__end:
        ; 51:15 logic or
        ; move t.11{r0}, t{r8}
        ld   r0, r8
        ; branch t.11{r0} notequals 0: or_next_36, or_2nd_36
        cp   r0, #%00
        jr   ne, or__next__36
        ; move t.11{r0}, f{r9}
        ld   r0, r9
or__next__36:
        ; call printIntLf@bool[t.11{r0}]
        call printIntLf_Pbool
        ; 52:2 if getTrue([]) || getTrue([])
        ; call t.12{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.12{r0} notequals 0: if_37_then, or_38
        cp   r0, #%00
        jr   ne, if__37__then
        ; call t.13{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.13{r0} notequals 0: if_37_then, if_37_else
        cp   r0, #%00
        jr   ne, if__37__then
        ; call printError[]
        call printError
        jr   if__37__end

if__37__then:
        ; call printPass[]
        call printPass
if__37__end:
        ; 53:15 logic or
        ; move t.14{r0}, t{r8}
        ld   r0, r8
        ; branch t.14{r0} notequals 0: or_next_39, or_2nd_39
        cp   r0, #%00
        jr   ne, or__next__39
        ; move t.14{r0}, t{r8}
        ld   r0, r8
or__next__39:
        ; call printIntLf@bool[t.14{r0}]
        call printIntLf_Pbool
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void main
        ; var d (i16): SP+8
        ; var t (bool): SP+10
        ; var f (bool): SP+11
        ; var b1 (u8): SP+12
main:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%05
        sbc  %30, #%00
        ld   SPH, %30
        ld   SPL, %31
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; const t.9{r0}, [string-7]
        ld   r0, #hi(string_7)
        ld   r1, #lo(string_7)
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
        decw r14
        ; const t{r2}, 1
        ld   r2, #%01
        ; addrof memVarAddr{r14}, t
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], t{r2}
        lde  @rr14, r2
        ; const f{r2}, 0
        ld   r2, #%00
        ; addrof memVarAddr{r14}, f
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
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
        ; const t.14{r0}, [string-8]
        ld   r0, #hi(string_8)
        ld   r1, #lo(string_8)
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
        ; const t.19{r0}, [string-9]
        ld   r0, #hi(string_9)
        ld   r1, #lo(string_9)
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
        ; call logicNot[]
        call logicNot
        ; call logicAnd[]
        call logicAnd
        ; call logicOr[]
        call logicOr
        ; 82:2 if !getTrue([]) && getTrue([]) || !getFalse([]) && getFalse([])
        ; call t.24{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.24{r0} equals 0: if_40_then, and_42
        cp   r0, #%00
        jr   eq, if__40__then
        ; call t.25{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.25{r0} equals 0: if_40_then, or_41
        cp   r0, #%00
        jr   eq, if__40__then
        ; call t.26{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.26{r0} equals 0: if_40_then, and_43
        cp   r0, #%00
        jr   eq, if__40__then
        ; call t.27{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.27{r0} equals 0: if_40_then, if_40_else
        cp   r0, #%00
        jr   eq, if__40__then
        ; call printError[]
        call printError
        jr   if__40__end

if__40__then:
        ; call printPass[]
        call printPass
if__40__end:
        ; 88:23 logic or
        ; 88:17 logic and
        ; addrof memVarAddr{r14}, t
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load t{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; move t.29{r9}, t{r8}
        ld   r9, r8
        ; branch t.29{r9} equals 0: and_next_45, and_2nd_45
        cp   r9, #%00
        jr   eq, and__next__45
        ; move t.29{r9}, t{r8}
        ld   r9, r8
and__next__45:
        ; notlog t.28{r0}, t.29{r9}
        or   r9, r9
        ld   r0, #0  ; false
        jr   nz, .8
        ld   r0, #1  ; true
.8:
        ; branch t.28{r0} notequals 0: or_next_44, or_2nd_44
        cp   r0, #%00
        jr   ne, or__next__44
        ; 88:30 logic and
        ; addrof memVarAddr{r14}, f
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; load f{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; move t.30{r9}, f{r8}
        ld   r9, r8
        ; branch t.30{r9} equals 0: and_next_46, and_2nd_46
        cp   r9, #%00
        jr   eq, and__next__46
        ; move t.30{r9}, f{r8}
        ld   r9, r8
and__next__46:
        ; notlog t.28{r0}, t.30{r9}
        or   r9, r9
        ld   r0, #0  ; false
        jr   nz, .9
        ld   r0, #1  ; true
.9:
or__next__44:
        ; call printIntLf@bool[t.28{r0}]
        call printIntLf_Pbool
        ; const t.31{r0}, [string-10]
        ld   r0, #hi(string_10)
        ld   r1, #lo(string_10)
        ; call printString@@u8[t.31{r0}]
        call printString_P_Pu8
        ; const b10{r8}, 10
        ld   r8, #%0a
        ; const b6{r9}, 6
        ld   r9, #%06
        ; const b1{r1}, 1
        ld   r1, #%01
        ; and t.33{r8}, t.33{r8}, b6{r9}
        and  r8, r9
        ; move t.32{r0}, t.33{r8}
        ld   r0, r8
        ; or t.32{r0}, t.32{r0}, b1{r1}
        or   r0, r1
        ; addrof memVarAddr{r14}, b1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], b1{r1}
        lde  @rr14, r1
        ; call printIntLf@u8[t.32{r0}]
        call printIntLf_Pu8
        ; 95:20 logic or
        ; equals t.34{r0}, b{r10}, c{r12}
        cp   r10, r12
        jr   ne, .ne10
        cp   r11, r13
        jr   ne, .ne10
        ld   r0, #1  ; true
        jr   .10
.ne10:
        ld   r0, #0
.10:
        ; branch t.34{r0} equals 0: or_2nd_47, main.no_critical_edge_21
        cp   r0, #%00
        jr   eq, or__2nd__47
        ; addrof memVarAddr{r14}, d
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load d{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        decw r14
        jr   or__next__47

or__2nd__47:
        ; addrof memVarAddr{r14}, d
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load d{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        decw r14
        ; lt t.34{r0}, c{r12}, d{r8}
        cp   r12, r8
        jr   lt, .true11
        jr   ne, .false11
        cp   r13, r9
        jr   ult, .true11
.false11:
        ld   r0, #0
        jr   .11
.true11:
        ld   r0, #1
.11:
or__next__47:
        ; call printIntLf@bool[t.34{r0}]
        call printIntLf_Pbool
        ; 96:20 logic and
        ; equals t.35{r0}, b{r10}, c{r12}
        cp   r10, r12
        jr   ne, .ne12
        cp   r11, r13
        jr   ne, .ne12
        ld   r0, #1  ; true
        jr   .12
.ne12:
        ld   r0, #0
.12:
        ; branch t.35{r0} equals 0: and_next_48, and_2nd_48
        cp   r0, #%00
        jr   eq, and__next__48
        ; lt t.35{r0}, c{r12}, d{r8}
        cp   r12, r8
        jr   lt, .true13
        jr   ne, .false13
        cp   r13, r9
        jr   ult, .true13
.false13:
        ld   r0, #0
        jr   .13
.true13:
        ld   r0, #1
.13:
and__next__48:
        ; call printIntLf@bool[t.35{r0}]
        call printIntLf_Pbool
        ; const arg.29.0{r0}, -1
        ld   r0, #%ff
        ld   r1, #%ff
        ; call printIntLf@i16[arg.29.0{r0}]
        call printIntLf_Pi16
        ; neg t.36{r0}, b{r10}
        ld   r0, #%00
        ld   r1, #%00
        sub  r1, r11
        sbc  r0, r10
        ; call printIntLf@i16[t.36{r0}]
        call printIntLf_Pi16
        ; addrof memVarAddr{r14}, b1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load b1{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; not t.37{r0}, b1{r8}
        ld   r0, r8
        com  r0
        ; call printIntLf@u8[t.37{r0}]
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
        ld   %30, SPH
        ld   %31, SPL
        add  %31, #%05
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
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

string_0:
        .data " true" %00
string_1:
        .data " false" %00
string_2:
        .data " -> pass " %00
string_3:
        .data " -> ERROR " %00
string_4:
        .data %0a "Logic-!:" %0a %00
string_5:
        .data %0a "Logic-&&:" %0a %00
string_6:
        .data %0a "Logic-||:" %0a %00
string_7:
        .data "Bit-&:" %0a %00
string_8:
        .data %0a "Bit-|:" %0a %00
string_9:
        .data %0a "Bit-^:" %0a %00
string_10:
        .data %0a %0a "misc:" %0a %00

