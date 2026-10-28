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
        ; cast t.1.1{r0}(i32), param.number{r0}(i16)
        ld   r3, r1
        ld   r2, r0
        ld   r1, r2
        rl   r1
        sbc  r1, r1
        sbc  r0, r0
        ; call printUint@i32[t.1.1{r0}]
        call printUint_Pi32
        ret

        ; void printIntLf@bool
        ; arg value (bool): r0
printIntLf_Pbool:
        ; save clobbered non-volatile registers
        push r8
        ; const number.1{r8}, 0
        ld   r8, #%00
        ; 122:2 if value
        ; branch param.value{r0} equals 0: if_1_end
        cp   r0, #%00
        jr   eq, if__1__end
        ; const number.3{r8}, 1
        ld   r8, #%01
if__1__end:
        ; cast t.2.1{r0}(i16), number.2{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; call printIntLf@i16[t.2.1{r0}]
        call printIntLf_Pi16
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; void printIntLf@u8
        ; arg number (u8): r0
printIntLf_Pu8:
        ; cast t.1.1{r0}(i16), param.number{r0}(u8)
        ld   r1, r0
        ld   r0, #0
        ; call printIntLf@i16[t.1.1{r0}]
        call printIntLf_Pi16
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
        ; branch param.number{r8} gteq 0: if_2_end
        cp   r8, #%00
        jr   gt, if__2__end
        jr   ne, .gt1
        cp   r9, #%00
        jr   uge, if__2__end
.gt1:
        ; const arg.0.0{r0}, 45
        ld   r0, #%2d
        ; call printChar@u8[arg.0.0{r0}]
        call printChar_Pu8
        ; neg number.2{r8}, param.number{r8}
        com  r8
        com  r9
        incw r8
if__2__end:
        ; move number.1{r0}, number.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printUint@i16[number.1{r0}]
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
        ; const t.0.1{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString@@u8[t.0.1{r0}]
        call printString_P_Pu8
        ; const {r0}, 1
        ld   r0, #%01
        ret

        ; bool getFalse
getFalse:
        ; const t.0.1{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.0.1{r0}]
        call printString_P_Pu8
        ; const {r0}, 0
        ld   r0, #%00
        ret

        ; void printPass
printPass:
        ; const t.0.1{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.0.1{r0}]
        call printString_P_Pu8
        ret

        ; void printError
printError:
        ; const t.0.1{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString@@u8[t.0.1{r0}]
        call printString_P_Pu8
        ret

        ; void logicNot
logicNot:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const t.2.1{r0}, [string-4]
        ld   r0, #hi(string_4)
        ld   r1, #lo(string_4)
        ; call printString@@u8[t.2.1{r0}]
        call printString_P_Pu8
        ; const t.1{r8}, 1
        ld   r8, #%01
        ; const f.1{r9}, 0
        ld   r9, #%00
        ; 13:2 if !getFalse([])
        ; call t.3.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.3.1{r0} equals 0: if_3_then
        cp   r0, #%00
        jr   eq, if__3__then
        ; call printError[]
        call printError
        jr   if__3__end

if__3__then:
        ; call printPass[]
        call printPass
if__3__end:
        ; notlog t.4.1{r0}, f.1{r9}
        or   r9, r9
        ld   r0, #0  ; false
        jr   nz, .2
        ld   r0, #1  ; true
.2:
        ; call printIntLf@bool[t.4.1{r0}]
        call printIntLf_Pbool
        ; 15:2 if !getTrue([])
        ; call t.5.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.5.1{r0} equals 0: if_4_then
        cp   r0, #%00
        jr   eq, if__4__then
        ; call printPass[]
        call printPass
        jr   if__4__end

if__4__then:
        ; call printError[]
        call printError
if__4__end:
        ; notlog t.6.1{r0}, t.1{r8}
        or   r8, r8
        ld   r0, #0  ; false
        jr   nz, .3
        ld   r0, #1  ; true
.3:
        ; call printIntLf@bool[t.6.1{r0}]
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
        ; const t.2.1{r0}, [string-5]
        ld   r0, #hi(string_5)
        ld   r1, #lo(string_5)
        ; call printString@@u8[t.2.1{r0}]
        call printString_P_Pu8
        ; const t.1{r8}, 1
        ld   r8, #%01
        ; const f.1{r9}, 0
        ld   r9, #%00
        ; 23:2 if getFalse([]) && getFalse([])
        ; call t.3.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.3.1{r0} equals 0: if_5_else
        cp   r0, #%00
        jr   eq, if__5__else
        ; call t.4.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.4.1{r0} equals 0: if_5_else
        cp   r0, #%00
        jr   eq, if__5__else
        ; call printError[]
        call printError
        jr   if__5__end

if__5__else:
        ; call printPass[]
        call printPass
if__5__end:
        ; 24:15 logic and
        ; move t.5.1{r10}, f.1{r9}
        ld   r10, r9
        ; branch t.5.1{r10} notequals 0: and_2nd_7
        cp   r10, #%00
        jr   ne, and__2nd__7
        ; move t.5.2{r0}, t.5.1{r10}
        ld   r0, r10
        jr   and__next__7

and__2nd__7:
        ; move t.5.3{r10}, f.1{r9}
        ld   r10, r9
        ; move t.5.2{r0}, t.5.3{r10}
        ld   r0, r10
and__next__7:
        ; call printIntLf@bool[t.5.2{r0}]
        call printIntLf_Pbool
        ; 25:2 if getFalse([]) && getTrue([])
        ; call t.6.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.6.1{r0} equals 0: if_8_else
        cp   r0, #%00
        jr   eq, if__8__else
        ; call t.7.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.7.1{r0} equals 0: if_8_else
        cp   r0, #%00
        jr   eq, if__8__else
        ; call printError[]
        call printError
        jr   if__8__end

if__8__else:
        ; call printPass[]
        call printPass
if__8__end:
        ; 26:15 logic and
        ; move t.8.1{r10}, f.1{r9}
        ld   r10, r9
        ; branch t.8.1{r10} notequals 0: and_2nd_10
        cp   r10, #%00
        jr   ne, and__2nd__10
        ; move t.8.2{r0}, t.8.1{r10}
        ld   r0, r10
        jr   and__next__10

and__2nd__10:
        ; move t.8.3{r10}, t.1{r8}
        ld   r10, r8
        ; move t.8.2{r0}, t.8.3{r10}
        ld   r0, r10
and__next__10:
        ; call printIntLf@bool[t.8.2{r0}]
        call printIntLf_Pbool
        ; 27:2 if getTrue([]) && getFalse([])
        ; call t.9.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.9.1{r0} equals 0: if_11_else
        cp   r0, #%00
        jr   eq, if__11__else
        ; call t.10.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.10.1{r0} equals 0: if_11_else
        cp   r0, #%00
        jr   eq, if__11__else
        ; call printError[]
        call printError
        jr   if__11__end

if__11__else:
        ; call printPass[]
        call printPass
if__11__end:
        ; 28:15 logic and
        ; move t.11.1{r10}, t.1{r8}
        ld   r10, r8
        ; branch t.11.1{r10} notequals 0: and_2nd_13
        cp   r10, #%00
        jr   ne, and__2nd__13
        ; move t.11.2{r0}, t.11.1{r10}
        ld   r0, r10
        jr   and__next__13

and__2nd__13:
        ; move t.11.3{r10}, f.1{r9}
        ld   r10, r9
        ; move t.11.2{r0}, t.11.3{r10}
        ld   r0, r10
and__next__13:
        ; call printIntLf@bool[t.11.2{r0}]
        call printIntLf_Pbool
        ; 29:2 if getTrue([]) && getTrue([])
        ; call t.12.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.12.1{r0} equals 0: if_14_else
        cp   r0, #%00
        jr   eq, if__14__else
        ; call t.13.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.13.1{r0} equals 0: if_14_else
        cp   r0, #%00
        jr   eq, if__14__else
        ; call printPass[]
        call printPass
        jr   if__14__end

if__14__else:
        ; call printError[]
        call printError
if__14__end:
        ; 30:15 logic and
        ; move t.14.1{r10}, t.1{r8}
        ld   r10, r8
        ; branch t.14.1{r10} notequals 0: and_2nd_16
        cp   r10, #%00
        jr   ne, and__2nd__16
        ; move t.14.2{r0}, t.14.1{r10}
        ld   r0, r10
        jr   and__next__16

and__2nd__16:
        ; move t.14.3{r10}, t.1{r8}
        ld   r10, r8
        ; move t.14.2{r0}, t.14.3{r10}
        ld   r0, r10
and__next__16:
        ; call printIntLf@bool[t.14.2{r0}]
        call printIntLf_Pbool
        ; 32:2 if !getFalse([]) && getFalse([])
        ; call t.15.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.15.1{r0} equals 0: if_17_then
        cp   r0, #%00
        jr   eq, if__17__then
        ; call t.16.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.16.1{r0} equals 0: if_17_then
        cp   r0, #%00
        jr   eq, if__17__then
        ; call printError[]
        call printError
        jr   if__17__end

if__17__then:
        ; call printPass[]
        call printPass
if__17__end:
        ; 33:17 logic and
        ; move t.18.1{r10}, f.1{r9}
        ld   r10, r9
        ; notlog t.17.1{r0}, t.18.2{r10}
        or   r10, r10
        ld   r0, #0  ; false
        jr   nz, .4
        ld   r0, #1  ; true
.4:
        ; call printIntLf@bool[t.17.1{r0}]
        call printIntLf_Pbool
        ; 34:2 if !getFalse([]) && getTrue([])
        ; call t.19.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.19.1{r0} equals 0: if_20_then
        cp   r0, #%00
        jr   eq, if__20__then
        ; call t.20.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.20.1{r0} equals 0: if_20_then
        cp   r0, #%00
        jr   eq, if__20__then
        ; call printError[]
        call printError
        jr   if__20__end

if__20__then:
        ; call printPass[]
        call printPass
if__20__end:
        ; 35:17 logic and
        ; move t.22.1{r10}, f.1{r9}
        ld   r10, r9
        ; branch t.22.1{r10} equals 0: and_next_22
        cp   r10, #%00
        jr   eq, and__next__22
        ; move t.22.3{r10}, t.1{r8}
        ld   r10, r8
and__next__22:
        ; notlog t.21.1{r0}, t.22.2{r10}
        or   r10, r10
        ld   r0, #0  ; false
        jr   nz, .5
        ld   r0, #1  ; true
.5:
        ; call printIntLf@bool[t.21.1{r0}]
        call printIntLf_Pbool
        ; 36:2 if !getTrue([]) && getFalse([])
        ; call t.23.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.23.1{r0} equals 0: if_23_then
        cp   r0, #%00
        jr   eq, if__23__then
        ; call t.24.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.24.1{r0} equals 0: if_23_then
        cp   r0, #%00
        jr   eq, if__23__then
        ; call printError[]
        call printError
        jr   if__23__end

if__23__then:
        ; call printPass[]
        call printPass
if__23__end:
        ; 37:17 logic and
        ; move t.26.1{r10}, t.1{r8}
        ld   r10, r8
        ; branch t.26.1{r10} notequals 0: and_next_25
        cp   r10, #%00
        jr   ne, and__next__25
        ; move t.26.2{r9}, t.26.1{r10}
        ld   r9, r10
and__next__25:
        ; notlog t.25.1{r0}, t.26.2{r9}
        or   r9, r9
        ld   r0, #0  ; false
        jr   nz, .6
        ld   r0, #1  ; true
.6:
        ; call printIntLf@bool[t.25.1{r0}]
        call printIntLf_Pbool
        ; 38:2 if !getTrue([]) && getTrue([])
        ; call t.27.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.27.1{r0} equals 0: if_26_then
        cp   r0, #%00
        jr   eq, if__26__then
        ; call t.28.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.28.1{r0} equals 0: if_26_then
        cp   r0, #%00
        jr   eq, if__26__then
        ; call printPass[]
        call printPass
        jr   if__26__end

if__26__then:
        ; call printError[]
        call printError
if__26__end:
        ; 39:17 logic and
        ; move t.30.1{r9}, t.1{r8}
        ld   r9, r8
        ; notlog t.29.1{r0}, t.30.2{r8}
        or   r8, r8
        ld   r0, #0  ; false
        jr   nz, .7
        ld   r0, #1  ; true
.7:
        ; call printIntLf@bool[t.29.1{r0}]
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
        push r10
        ; const t.2.1{r0}, [string-6]
        ld   r0, #hi(string_6)
        ld   r1, #lo(string_6)
        ; call printString@@u8[t.2.1{r0}]
        call printString_P_Pu8
        ; const t.1{r8}, 1
        ld   r8, #%01
        ; const f.1{r9}, 0
        ld   r9, #%00
        ; 46:2 if getFalse([]) || getFalse([])
        ; call t.3.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.3.1{r0} notequals 0: if_29_then
        cp   r0, #%00
        jr   ne, if__29__then
        ; call t.4.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.4.1{r0} notequals 0: if_29_then
        cp   r0, #%00
        jr   ne, if__29__then
        ; call printPass[]
        call printPass
        jr   if__29__end

if__29__then:
        ; call printError[]
        call printError
if__29__end:
        ; 47:15 logic or
        ; move t.5.1{r10}, f.1{r9}
        ld   r10, r9
        ; branch t.5.1{r10} equals 0: or_2nd_31
        cp   r10, #%00
        jr   eq, or__2nd__31
        ; move t.5.2{r0}, t.5.1{r10}
        ld   r0, r10
        jr   or__next__31

or__2nd__31:
        ; move t.5.3{r10}, f.1{r9}
        ld   r10, r9
        ; move t.5.2{r0}, t.5.3{r10}
        ld   r0, r10
or__next__31:
        ; call printIntLf@bool[t.5.2{r0}]
        call printIntLf_Pbool
        ; 48:2 if getFalse([]) || getTrue([])
        ; call t.6.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.6.1{r0} notequals 0: if_32_then
        cp   r0, #%00
        jr   ne, if__32__then
        ; call t.7.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.7.1{r0} notequals 0: if_32_then
        cp   r0, #%00
        jr   ne, if__32__then
        ; call printError[]
        call printError
        jr   if__32__end

if__32__then:
        ; call printPass[]
        call printPass
if__32__end:
        ; 49:15 logic or
        ; move t.8.1{r10}, f.1{r9}
        ld   r10, r9
        ; branch t.8.1{r10} equals 0: or_2nd_34
        cp   r10, #%00
        jr   eq, or__2nd__34
        ; move t.8.2{r0}, t.8.1{r10}
        ld   r0, r10
        jr   or__next__34

or__2nd__34:
        ; move t.8.3{r10}, t.1{r8}
        ld   r10, r8
        ; move t.8.2{r0}, t.8.3{r10}
        ld   r0, r10
or__next__34:
        ; call printIntLf@bool[t.8.2{r0}]
        call printIntLf_Pbool
        ; 50:2 if getTrue([]) || getFalse([])
        ; call t.9.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.9.1{r0} notequals 0: if_35_then
        cp   r0, #%00
        jr   ne, if__35__then
        ; call t.10.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.10.1{r0} notequals 0: if_35_then
        cp   r0, #%00
        jr   ne, if__35__then
        ; call printError[]
        call printError
        jr   if__35__end

if__35__then:
        ; call printPass[]
        call printPass
if__35__end:
        ; 51:15 logic or
        ; move t.11.1{r10}, t.1{r8}
        ld   r10, r8
        ; branch t.11.1{r10} equals 0: or_2nd_37
        cp   r10, #%00
        jr   eq, or__2nd__37
        ; move t.11.2{r0}, t.11.1{r10}
        ld   r0, r10
        jr   or__next__37

or__2nd__37:
        ; move t.11.2{r0}, t.11.3{r9}
        ld   r0, r9
or__next__37:
        ; call printIntLf@bool[t.11.2{r0}]
        call printIntLf_Pbool
        ; 52:2 if getTrue([]) || getTrue([])
        ; call t.12.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.12.1{r0} notequals 0: if_38_then
        cp   r0, #%00
        jr   ne, if__38__then
        ; call t.13.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.13.1{r0} notequals 0: if_38_then
        cp   r0, #%00
        jr   ne, if__38__then
        ; call printError[]
        call printError
        jr   if__38__end

if__38__then:
        ; call printPass[]
        call printPass
if__38__end:
        ; 53:15 logic or
        ; move t.14.1{r9}, t.1{r8}
        ld   r9, r8
        ; branch t.14.1{r9} equals 0: or_2nd_40
        cp   r9, #%00
        jr   eq, or__2nd__40
        ; move t.14.2{r0}, t.14.1{r9}
        ld   r0, r9
        jr   or__next__40

or__2nd__40:
        ; move t.14.2{r0}, t.14.3{r8}
        ld   r0, r8
or__next__40:
        ; call printIntLf@bool[t.14.2{r0}]
        call printIntLf_Pbool
        ; restore clobbered non-volatile registers
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void main
        ; var d.1 (i16): SP+8
        ; var t.1 (bool): SP+10
        ; var f.1 (bool): SP+11
        ; var b1.1 (u8): SP+12
main:
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; const t.9.1{r0}, [string-7]
        ld   r0, #hi(string_7)
        ld   r1, #lo(string_7)
        ; call printString@@u8[t.9.1{r0}]
        call printString_P_Pu8
        ; const a.1{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ; const b.1{r10}, 1
        ld   r10, #%00
        ld   r11, #%01
        ; const c.1{r12}, 2
        ld   r12, #%00
        ld   r13, #%02
        ; const d.1{r2}, 3
        ld   r2, #%00
        ld   r3, #%03
        ; addrof memVarAddr{r14}, d.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], d.1{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        decw r14
        ; const t.1{r2}, 1
        ld   r2, #%01
        ; addrof memVarAddr{r14}, t.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], t.1{r2}
        lde  @rr14, r2
        ; const f.1{r2}, 0
        ld   r2, #%00
        ; addrof memVarAddr{r14}, f.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; store [memVarAddr{r14}], f.1{r2}
        lde  @rr14, r2
        ; move t.10.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; and t.10.1{r0}, a.1{r8}
        and  r0, r8
        and  r1, r9
        ; call printIntLf@i16[t.10.1{r0}]
        call printIntLf_Pi16
        ; move t.11.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; and t.11.1{r0}, b.1{r10}
        and  r0, r10
        and  r1, r11
        ; call printIntLf@i16[t.11.1{r0}]
        call printIntLf_Pi16
        ; move t.12.1{r0}, b.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; and t.12.1{r0}, a.1{r8}
        and  r0, r8
        and  r1, r9
        ; call printIntLf@i16[t.12.1{r0}]
        call printIntLf_Pi16
        ; move t.13.1{r0}, b.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; and t.13.1{r0}, b.1{r10}
        and  r0, r10
        and  r1, r11
        ; call printIntLf@i16[t.13.1{r0}]
        call printIntLf_Pi16
        ; const t.14.1{r0}, [string-8]
        ld   r0, #hi(string_8)
        ld   r1, #lo(string_8)
        ; call printString@@u8[t.14.1{r0}]
        call printString_P_Pu8
        ; move t.15.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; or t.15.1{r0}, a.1{r8}
        or   r0, r8
        or   r1, r9
        ; call printIntLf@i16[t.15.1{r0}]
        call printIntLf_Pi16
        ; move t.16.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; or t.16.1{r0}, b.1{r10}
        or   r0, r10
        or   r1, r11
        ; call printIntLf@i16[t.16.1{r0}]
        call printIntLf_Pi16
        ; move t.17.1{r0}, b.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; or t.17.1{r0}, a.1{r8}
        or   r0, r8
        or   r1, r9
        ; call printIntLf@i16[t.17.1{r0}]
        call printIntLf_Pi16
        ; move t.18.1{r0}, b.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; or t.18.1{r0}, b.1{r10}
        or   r0, r10
        or   r1, r11
        ; call printIntLf@i16[t.18.1{r0}]
        call printIntLf_Pi16
        ; const t.19.1{r0}, [string-9]
        ld   r0, #hi(string_9)
        ld   r1, #lo(string_9)
        ; call printString@@u8[t.19.1{r0}]
        call printString_P_Pu8
        ; move t.20.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; xor t.20.1{r0}, a.1{r8}
        xor  r0, r8
        xor  r1, r9
        ; call printIntLf@i16[t.20.1{r0}]
        call printIntLf_Pi16
        ; move t.21.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; xor t.21.1{r0}, c.1{r12}
        xor  r0, r12
        xor  r1, r13
        ; call printIntLf@i16[t.21.1{r0}]
        call printIntLf_Pi16
        ; move t.22.1{r0}, b.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; xor t.22.1{r0}, a.1{r8}
        xor  r0, r8
        xor  r1, r9
        ; call printIntLf@i16[t.22.1{r0}]
        call printIntLf_Pi16
        ; move t.23.1{r0}, b.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; xor t.23.1{r0}, c.1{r12}
        xor  r0, r12
        xor  r1, r13
        ; call printIntLf@i16[t.23.1{r0}]
        call printIntLf_Pi16
        ; call logicNot[]
        call logicNot
        ; call logicAnd[]
        call logicAnd
        ; call logicOr[]
        call logicOr
        ; 82:2 if !getTrue([]) && getTrue([]) || !getFalse([]) && getFalse([])
        ; call t.24.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.24.1{r0} equals 0: if_41_then
        cp   r0, #%00
        jr   eq, if__41__then
        ; call t.25.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.25.1{r0} equals 0: if_41_then
        cp   r0, #%00
        jr   eq, if__41__then
        ; call t.26.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.26.1{r0} equals 0: if_41_then
        cp   r0, #%00
        jr   eq, if__41__then
        ; call t.27.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.27.1{r0} equals 0: if_41_then
        cp   r0, #%00
        jr   eq, if__41__then
        ; call printError[]
        call printError
        jr   if__41__end

if__41__then:
        ; call printPass[]
        call printPass
if__41__end:
        ; 88:23 logic or
        ; 88:17 logic and
        ; addrof memVarAddr{r14}, t.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load t.1{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; move t.29.1{r9}, t.1{r8}
        ld   r9, r8
        ; notlog t.28.1{r8}, t.29.2{r8}
        or   r8, r8
        ld   r8, #0  ; false
        jr   nz, .8
        ld   r8, #1  ; true
.8:
        ; branch t.28.1{r8} equals 0: or_2nd_45
        cp   r8, #%00
        jr   eq, or__2nd__45
        ; move t.28.2{r0}, t.28.1{r8}
        ld   r0, r8
        jr   or__next__45

or__2nd__45:
        ; 88:30 logic and
        ; addrof memVarAddr{r14}, f.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; load f.1{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; move t.30.1{r9}, f.1{r8}
        ld   r9, r8
        ; notlog t.28.3{r8}, t.30.2{r8}
        or   r8, r8
        ld   r8, #0  ; false
        jr   nz, .9
        ld   r8, #1  ; true
.9:
        ; move t.28.2{r0}, t.28.3{r8}
        ld   r0, r8
or__next__45:
        ; call printIntLf@bool[t.28.2{r0}]
        call printIntLf_Pbool
        ; const t.31.1{r0}, [string-10]
        ld   r0, #hi(string_10)
        ld   r1, #lo(string_10)
        ; call printString@@u8[t.31.1{r0}]
        call printString_P_Pu8
        ; const b10.1{r8}, 10
        ld   r8, #%0a
        ; const b6.1{r9}, 6
        ld   r9, #%06
        ; const b1.1{r1}, 1
        ld   r1, #%01
        ; and t.33.1{r8}, b6.1{r9}
        and  r8, r9
        ; move t.32.1{r0}, t.33.1{r8}
        ld   r0, r8
        ; or t.32.1{r0}, b1.1{r1}
        or   r0, r1
        ; addrof memVarAddr{r14}, b1.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], b1.1{r1}
        lde  @rr14, r1
        ; call printIntLf@u8[t.32.1{r0}]
        call printIntLf_Pu8
        ; 95:20 logic or
        ; equals t.34.1{r8}, b.1{r10}, c.1{r12}
        cp   r10, r12
        jr   ne, .ne10
        cp   r11, r13
        jr   ne, .ne10
        ld   r8, #1  ; true
        jr   .10
.ne10:
        ld   r8, #0
.10:
        ; branch t.34.1{r8} equals 0: or_2nd_48
        cp   r8, #%00
        jr   eq, or__2nd__48
        ; move t.34.2{r0}, t.34.1{r8}
        ld   r0, r8
        ; addrof memVarAddr{r14}, d.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load d.1{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        decw r14
        jr   or__next__48

or__2nd__48:
        ; addrof memVarAddr{r14}, d.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load d.1{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        decw r14
        ; lt t.34.3{r1}, c.1{r12}, d.1{r8}
        cp   r12, r8
        jr   lt, .true11
        jr   ne, .false11
        cp   r13, r9
        jr   ult, .true11
.false11:
        ld   r1, #0
        jr   .11
.true11:
        ld   r1, #1
.11:
        ; move t.34.2{r0}, t.34.3{r1}
        ld   r0, r1
or__next__48:
        ; call printIntLf@bool[t.34.2{r0}]
        call printIntLf_Pbool
        ; 96:20 logic and
        ; equals t.35.1{r1}, b.1{r10}, c.1{r12}
        cp   r10, r12
        jr   ne, .ne12
        cp   r11, r13
        jr   ne, .ne12
        ld   r1, #1  ; true
        jr   .12
.ne12:
        ld   r1, #0
.12:
        ; branch t.35.1{r1} notequals 0: and_2nd_49
        cp   r1, #%00
        jr   ne, and__2nd__49
        ; move t.35.2{r0}, t.35.1{r1}
        ld   r0, r1
        jr   and__next__49

and__2nd__49:
        ; lt t.35.3{r8}, c.1{r12}, d.1{r8}
        cp   r12, r8
        jr   lt, .true13
        jr   ne, .false13
        cp   r13, r9
        jr   ult, .true13
.false13:
        ld   r8, #0
        jr   .13
.true13:
        ld   r8, #1
.13:
        ; move t.35.2{r0}, t.35.3{r8}
        ld   r0, r8
and__next__49:
        ; call printIntLf@bool[t.35.2{r0}]
        call printIntLf_Pbool
        ; const arg.29.0{r0}, -1
        ld   r0, #%ff
        ld   r1, #%ff
        ; call printIntLf@i16[arg.29.0{r0}]
        call printIntLf_Pi16
        ; neg t.36.1{r0}, b.1{r10}
        ld   r0, #%00
        ld   r1, #%00
        sub  r1, r11
        sbc  r0, r10
        ; call printIntLf@i16[t.36.1{r0}]
        call printIntLf_Pi16
        ; addrof memVarAddr{r14}, b1.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load b1.1{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; not t.37.1{r0}, b1.1{r8}
        ld   r0, r8
        com  r0
        ; call printIntLf@u8[t.37.1{r0}]
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
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
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

