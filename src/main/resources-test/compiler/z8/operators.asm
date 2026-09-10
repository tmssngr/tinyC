        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void printUint@i16
        ; arg number (i16): r0
printUint__Pi16:
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
printIntLf__Pbool:
        ret

        ; void printIntLf@u8
        ; arg number (u8): r0
printIntLf__Pu8:
        ret

        ; void printIntLf@i16
        ; arg number (i16): r0
printIntLf__Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; move param.number{r8}, number{r0}
        ld   r9, r1
        ld   r8, r0
        ; 127:2 if number < 0
        ; branch param.number{r8} gteq 0: if_1_end, if_1_then
        cp   r8, #%00
        jr   ge, .1
        jr   ne, if__1__end
        cp   r9, #%00
        jr   uge, if__1__end
.1:
        ; const arg.0.0{r0}, 45
        ld   r0, #%2d
        ; call printChar@u8[arg.0.0{r0}]
        call printChar_Pu8
        ; neg param.number{r8}, param.number{r8}
        com  r8
        com  r9
        incw r8
if____1____end:
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
        ld   r0, #hi(string__0)
        ld   r1, #lo(string__0)
        ; call printString@@u8[t.0{r0}]
        call printString_P_Pu8
        ; 3:49 return true
        ; const t.1{r0}, 1
        ld   r0, #%01
        ret

        ; bool getFalse
getFalse:
        ; const t.0{r0}, [string-1]
        ld   r0, #hi(string__1)
        ld   r1, #lo(string__1)
        ; call printString@@u8[t.0{r0}]
        call printString_P_Pu8
        ; 4:49 return false
        ; const t.1{r0}, 0
        ld   r0, #%00
        ret

        ; void printPass
printPass:
        ; const t.0{r0}, [string-2]
        ld   r0, #hi(string__2)
        ld   r1, #lo(string__2)
        ; call printString@@u8[t.0{r0}]
        call printString_P_Pu8
        ret

        ; void printError
printError:
        ; const t.0{r0}, [string-3]
        ld   r0, #hi(string__3)
        ld   r1, #lo(string__3)
        ; call printString@@u8[t.0{r0}]
        call printString_P_Pu8
        ret

        ; void logicNot
logicNot:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const t.2{r0}, [string-4]
        ld   r0, #hi(string__4)
        ld   r1, #lo(string__4)
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
.2:
        ; call printError[]
        call printError
        jr   if__2__end

if____2____then:
        ; call printPass[]
        call printPass
if____2____end:
        ; notlog t.4{r0}, f{r9}
        or   r9, r9
        ld   r0, #0  ; false
        jr   nz, .3
        ld   r0, #1  ; true
.3:
        ; call printIntLf@bool[t.4{r0}]
        call printIntLf_Pbool
        ; 15:2 if !getTrue([])
        ; call t.5{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.5{r0} equals 0: if_3_then, if_3_else
        cp   r0, #%00
        jr   eq, if__3__then
.4:
        ; call printPass[]
        call printPass
        jr   if__3__end

if____3____then:
        ; call printError[]
        call printError
if____3____end:
        ; notlog t.6{r0}, t{r8}
        or   r8, r8
        ld   r0, #0  ; false
        jr   nz, .5
        ld   r0, #1  ; true
.5:
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
        ld   r0, #hi(string__5)
        ld   r1, #lo(string__5)
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
.6:
        ; call t.4{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.4{r0} equals 0: if_4_else, if_4_then
        cp   r0, #%00
        jr   eq, if__4__else
.7:
        ; call printError[]
        call printError
        jr   if__4__end

if____4____else:
        ; call printPass[]
        call printPass
if____4____end:
        ; 24:15 logic and
        ; move t.5{r0}, f{r9}
        ld   r0, r9
        ; branch t.5{r0} equals 0: and_next_6, and_2nd_6
        cp   r0, #%00
        jr   eq, and__next__6
.8:
        ; move t.5{r0}, f{r9}
        ld   r0, r9
and____next____6:
        ; call printIntLf@bool[t.5{r0}]
        call printIntLf_Pbool
        ; 25:2 if getFalse([]) && getTrue([])
        ; call t.6{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.6{r0} equals 0: if_7_else, and_8
        cp   r0, #%00
        jr   eq, if__7__else
.9:
        ; call t.7{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.7{r0} equals 0: if_7_else, if_7_then
        cp   r0, #%00
        jr   eq, if__7__else
.10:
        ; call printError[]
        call printError
        jr   if__7__end

if____7____else:
        ; call printPass[]
        call printPass
if____7____end:
        ; 26:15 logic and
        ; move t.8{r0}, f{r9}
        ld   r0, r9
        ; branch t.8{r0} equals 0: and_next_9, and_2nd_9
        cp   r0, #%00
        jr   eq, and__next__9
.11:
        ; move t.8{r0}, t{r8}
        ld   r0, r8
and____next____9:
        ; call printIntLf@bool[t.8{r0}]
        call printIntLf_Pbool
        ; 27:2 if getTrue([]) && getFalse([])
        ; call t.9{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.9{r0} equals 0: if_10_else, and_11
        cp   r0, #%00
        jr   eq, if__10__else
.12:
        ; call t.10{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.10{r0} equals 0: if_10_else, if_10_then
        cp   r0, #%00
        jr   eq, if__10__else
.13:
        ; call printError[]
        call printError
        jr   if__10__end

if____10____else:
        ; call printPass[]
        call printPass
if____10____end:
        ; 28:15 logic and
        ; move t.11{r0}, t{r8}
        ld   r0, r8
        ; branch t.11{r0} equals 0: and_next_12, and_2nd_12
        cp   r0, #%00
        jr   eq, and__next__12
.14:
        ; move t.11{r0}, f{r9}
        ld   r0, r9
and____next____12:
        ; call printIntLf@bool[t.11{r0}]
        call printIntLf_Pbool
        ; 29:2 if getTrue([]) && getTrue([])
        ; call t.12{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.12{r0} equals 0: if_13_else, and_14
        cp   r0, #%00
        jr   eq, if__13__else
.15:
        ; call t.13{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.13{r0} equals 0: if_13_else, if_13_then
        cp   r0, #%00
        jr   eq, if__13__else
.16:
        ; call printPass[]
        call printPass
        jr   if__13__end

if____13____else:
        ; call printError[]
        call printError
if____13____end:
        ; 30:15 logic and
        ; move t.14{r0}, t{r8}
        ld   r0, r8
        ; branch t.14{r0} equals 0: and_next_15, and_2nd_15
        cp   r0, #%00
        jr   eq, and__next__15
.17:
        ; move t.14{r0}, t{r8}
        ld   r0, r8
and____next____15:
        ; call printIntLf@bool[t.14{r0}]
        call printIntLf_Pbool
        ; 32:2 if !getFalse([]) && getFalse([])
        ; call t.15{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.15{r0} equals 0: if_16_then, and_17
        cp   r0, #%00
        jr   eq, if__16__then
.18:
        ; call t.16{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.16{r0} equals 0: if_16_then, if_16_else
        cp   r0, #%00
        jr   eq, if__16__then
.19:
        ; call printError[]
        call printError
        jr   if__16__end

if____16____then:
        ; call printPass[]
        call printPass
if____16____end:
        ; 33:17 logic and
        ; move t.18{r10}, f{r9}
        ld   r10, r9
        ; branch t.18{r10} equals 0: and_next_18, and_2nd_18
        cp   r10, #%00
        jr   eq, and__next__18
.20:
        ; move t.18{r10}, f{r9}
        ld   r10, r9
and____next____18:
        ; notlog t.17{r0}, t.18{r10}
        or   r10, r10
        ld   r0, #0  ; false
        jr   nz, .21
        ld   r0, #1  ; true
.21:
        ; call printIntLf@bool[t.17{r0}]
        call printIntLf_Pbool
        ; 34:2 if !getFalse([]) && getTrue([])
        ; call t.19{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.19{r0} equals 0: if_19_then, and_20
        cp   r0, #%00
        jr   eq, if__19__then
.22:
        ; call t.20{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.20{r0} equals 0: if_19_then, if_19_else
        cp   r0, #%00
        jr   eq, if__19__then
.23:
        ; call printError[]
        call printError
        jr   if__19__end

if____19____then:
        ; call printPass[]
        call printPass
if____19____end:
        ; 35:17 logic and
        ; move t.22{r10}, f{r9}
        ld   r10, r9
        ; branch t.22{r10} equals 0: and_next_21, and_2nd_21
        cp   r10, #%00
        jr   eq, and__next__21
.24:
        ; move t.22{r10}, t{r8}
        ld   r10, r8
and____next____21:
        ; notlog t.21{r0}, t.22{r10}
        or   r10, r10
        ld   r0, #0  ; false
        jr   nz, .25
        ld   r0, #1  ; true
.25:
        ; call printIntLf@bool[t.21{r0}]
        call printIntLf_Pbool
        ; 36:2 if !getTrue([]) && getFalse([])
        ; call t.23{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.23{r0} equals 0: if_22_then, and_23
        cp   r0, #%00
        jr   eq, if__22__then
.26:
        ; call t.24{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.24{r0} equals 0: if_22_then, if_22_else
        cp   r0, #%00
        jr   eq, if__22__then
.27:
        ; call printError[]
        call printError
        jr   if__22__end

if____22____then:
        ; call printPass[]
        call printPass
if____22____end:
        ; 37:17 logic and
        ; move t.26{r10}, t{r8}
        ld   r10, r8
        ; branch t.26{r10} equals 0: and_next_24, and_2nd_24
        cp   r10, #%00
        jr   eq, and__next__24
.28:
        ; move t.26{r10}, f{r9}
        ld   r10, r9
and____next____24:
        ; notlog t.25{r0}, t.26{r10}
        or   r10, r10
        ld   r0, #0  ; false
        jr   nz, .29
        ld   r0, #1  ; true
.29:
        ; call printIntLf@bool[t.25{r0}]
        call printIntLf_Pbool
        ; 38:2 if !getTrue([]) && getTrue([])
        ; call t.27{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.27{r0} equals 0: if_25_then, and_26
        cp   r0, #%00
        jr   eq, if__25__then
.30:
        ; call t.28{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.28{r0} equals 0: if_25_then, if_25_else
        cp   r0, #%00
        jr   eq, if__25__then
.31:
        ; call printPass[]
        call printPass
        jr   if__25__end

if____25____then:
        ; call printError[]
        call printError
if____25____end:
        ; 39:17 logic and
        ; move t.30{r9}, t{r8}
        ld   r9, r8
        ; branch t.30{r9} equals 0: and_next_27, and_2nd_27
        cp   r9, #%00
        jr   eq, and__next__27
.32:
        ; move t.30{r9}, t{r8}
        ld   r9, r8
and____next____27:
        ; notlog t.29{r0}, t.30{r9}
        or   r9, r9
        ld   r0, #0  ; false
        jr   nz, .33
        ld   r0, #1  ; true
.33:
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
        ld   r0, #hi(string__6)
        ld   r1, #lo(string__6)
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
.34:
        ; call t.4{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.4{r0} notequals 0: if_28_then, if_28_else
        cp   r0, #%00
        jr   ne, if__28__then
.35:
        ; call printPass[]
        call printPass
        jr   if__28__end

if____28____then:
        ; call printError[]
        call printError
if____28____end:
        ; 47:15 logic or
        ; move t.5{r0}, f{r9}
        ld   r0, r9
        ; branch t.5{r0} notequals 0: or_next_30, or_2nd_30
        cp   r0, #%00
        jr   ne, or__next__30
.36:
        ; move t.5{r0}, f{r9}
        ld   r0, r9
or____next____30:
        ; call printIntLf@bool[t.5{r0}]
        call printIntLf_Pbool
        ; 48:2 if getFalse([]) || getTrue([])
        ; call t.6{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.6{r0} notequals 0: if_31_then, or_32
        cp   r0, #%00
        jr   ne, if__31__then
.37:
        ; call t.7{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.7{r0} notequals 0: if_31_then, if_31_else
        cp   r0, #%00
        jr   ne, if__31__then
.38:
        ; call printError[]
        call printError
        jr   if__31__end

if____31____then:
        ; call printPass[]
        call printPass
if____31____end:
        ; 49:15 logic or
        ; move t.8{r0}, f{r9}
        ld   r0, r9
        ; branch t.8{r0} notequals 0: or_next_33, or_2nd_33
        cp   r0, #%00
        jr   ne, or__next__33
.39:
        ; move t.8{r0}, t{r8}
        ld   r0, r8
or____next____33:
        ; call printIntLf@bool[t.8{r0}]
        call printIntLf_Pbool
        ; 50:2 if getTrue([]) || getFalse([])
        ; call t.9{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.9{r0} notequals 0: if_34_then, or_35
        cp   r0, #%00
        jr   ne, if__34__then
.40:
        ; call t.10{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.10{r0} notequals 0: if_34_then, if_34_else
        cp   r0, #%00
        jr   ne, if__34__then
.41:
        ; call printError[]
        call printError
        jr   if__34__end

if____34____then:
        ; call printPass[]
        call printPass
if____34____end:
        ; 51:15 logic or
        ; move t.11{r0}, t{r8}
        ld   r0, r8
        ; branch t.11{r0} notequals 0: or_next_36, or_2nd_36
        cp   r0, #%00
        jr   ne, or__next__36
.42:
        ; move t.11{r0}, f{r9}
        ld   r0, r9
or____next____36:
        ; call printIntLf@bool[t.11{r0}]
        call printIntLf_Pbool
        ; 52:2 if getTrue([]) || getTrue([])
        ; call t.12{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.12{r0} notequals 0: if_37_then, or_38
        cp   r0, #%00
        jr   ne, if__37__then
.43:
        ; call t.13{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.13{r0} notequals 0: if_37_then, if_37_else
        cp   r0, #%00
        jr   ne, if__37__then
.44:
        ; call printError[]
        call printError
        jr   if__37__end

if____37____then:
        ; call printPass[]
        call printPass
if____37____end:
        ; 53:15 logic or
        ; move t.14{r0}, t{r8}
        ld   r0, r8
        ; branch t.14{r0} notequals 0: or_next_39, or_2nd_39
        cp   r0, #%00
        jr   ne, or__next__39
.45:
        ; move t.14{r0}, t{r8}
        ld   r0, r8
or____next____39:
        ; call printIntLf@bool[t.14{r0}]
        call printIntLf_Pbool
        ; restore clobbered non-volatile registers
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
        ; const t.9{r0}, [string-7]
        ld   r0, #hi(string__7)
        ld   r1, #lo(string__7)
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
        ; const t.14{r0}, [string-8]
        ld   r0, #hi(string__8)
        ld   r1, #lo(string__8)
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
        ld   r0, #hi(string__9)
        ld   r1, #lo(string__9)
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
.46:
        ; call t.25{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.25{r0} equals 0: if_40_then, or_41
        cp   r0, #%00
        jr   eq, if__40__then
.47:
        ; call t.26{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.26{r0} equals 0: if_40_then, and_43
        cp   r0, #%00
        jr   eq, if__40__then
.48:
        ; call t.27{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.27{r0} equals 0: if_40_then, if_40_else
        cp   r0, #%00
        jr   eq, if__40__then
.49:
        ; call printError[]
        call printError
        jr   if__40__end

if____40____then:
        ; call printPass[]
        call printPass
if____40____end:
        ; 88:23 logic or
        ; 88:17 logic and
        ; move t.29{r8}, t{r14}
        ld   r8, r14
        ; branch t.29{r8} equals 0: and_next_45, and_2nd_45
        cp   r8, #%00
        jr   eq, and__next__45
.50:
        ; move t.29{r8}, t{r14}
        ld   r8, r14
and____next____45:
        ; notlog t.28{r0}, t.29{r8}
        or   r8, r8
        ld   r0, #0  ; false
        jr   nz, .51
        ld   r0, #1  ; true
.51:
        ; branch t.28{r0} notequals 0: or_next_44, or_2nd_44
        cp   r0, #%00
        jr   ne, or__next__44
.52:
        ; 88:30 logic and
        ; addrof memVarAddr{r14}, f
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load f{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; move t.30{r9}, f{r8}
        ld   r9, r8
        ; branch t.30{r9} equals 0: and_next_46, and_2nd_46
        cp   r9, #%00
        jr   eq, and__next__46
.53:
        ; move t.30{r9}, f{r8}
        ld   r9, r8
and____next____46:
        ; notlog t.28{r0}, t.30{r9}
        or   r9, r9
        ld   r0, #0  ; false
        jr   nz, .54
        ld   r0, #1  ; true
.54:
or____next____44:
        ; call printIntLf@bool[t.28{r0}]
        call printIntLf_Pbool
        ; const t.31{r0}, [string-10]
        ld   r0, #hi(string__10)
        ld   r1, #lo(string__10)
        ; call printString@@u8[t.31{r0}]
        call printString_P_Pu8
        ; const b10{r8}, 10
        ld   r8, #%0a
        ; const b6{r9}, 6
        ld   r9, #%06
        ; const b1{r14}, 1
        ld   r14, #%01
        ; and t.33{r8}, t.33{r8}, b6{r9}
        and  r8, r9
        ; move t.32{r0}, t.33{r8}
        ld   r0, r8
        ; or t.32{r0}, t.32{r0}, b1{r14}
        or   r0, r14
        ; call printIntLf@u8[t.32{r0}]
        call printIntLf_Pu8
        ; 95:20 logic or
        ; equals t.34{r0}, b{r10}, c{r12}
        cp   r10, r12
        jr   ne, .ne55
        cp   r11, r13
        jr   ne, .ne55
        ld   r0, #1  ; true
        jr   .55
.ne55:
        ld   r0, #0
.55:
        ; branch t.34{r0} equals 0: or_2nd_47, main.no_critical_edge_21
        cp   r0, #%00
        jr   eq, or__2nd__47
.56:
        ; addrof memVarAddr{r14}, d
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load d{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        jr   or__next__47

or____2nd____47:
        ; addrof memVarAddr{r14}, d
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load d{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        ; lt t.34{r0}, c{r12}, d{r8}
        cp   r12, r8
        jr   lt, .true57
        jr   ne, .false57
        cp   r13, r9
        jr   uge, .false57
.true57:
        ld   r0, #1
        jr   .57
.false57:
        ld   r0, #0
.57:
or____next____47:
        ; call printIntLf@bool[t.34{r0}]
        call printIntLf_Pbool
        ; 96:20 logic and
        ; equals t.35{r0}, b{r10}, c{r12}
        cp   r10, r12
        jr   ne, .ne58
        cp   r11, r13
        jr   ne, .ne58
        ld   r0, #1  ; true
        jr   .58
.ne58:
        ld   r0, #0
.58:
        ; branch t.35{r0} equals 0: and_next_48, and_2nd_48
        cp   r0, #%00
        jr   eq, and__next__48
.59:
        ; lt t.35{r0}, c{r12}, d{r8}
        cp   r12, r8
        jr   lt, .true60
        jr   ne, .false60
        cp   r13, r9
        jr   uge, .false60
.true60:
        ld   r0, #1
        jr   .60
.false60:
        ld   r0, #0
.60:
and____next____48:
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
        ; not t.37{r0}, b1{r14}
        ld   r0, r14
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
        ret

        ; void printString@@u8
printString__P__Pu8:
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
printChar__Pu8:
        cp    r0, #%0a
        jr    ne, .1
        ld    r0, #%0d
.1:
        ld    %15, r0
        jp    %0818

        ; void printUint@i32
printUint__Pi32:
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
        .data " true" %00
string__1:
        .data " false" %00
string__2:
        .data " -> pass " %00
string__3:
        .data " -> ERROR " %00
string__4:
        .data %0a "Logic-!:" %0a %00
string__5:
        .data %0a "Logic-&&:" %0a %00
string__6:
        .data %0a "Logic-||:" %0a %00
string__7:
        .data "Bit-&:" %0a %00
string__8:
        .data %0a "Bit-|:" %0a %00
string__9:
        .data %0a "Bit-^:" %0a %00
string__10:
        .data %0a %0a "misc:" %0a %00

