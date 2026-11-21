        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

        srp  #%20
        jr   main

        ; void printUint_Pi16
        ; arg number (i16): r0
printUint_Pi16:
        ; cast t.1.1{r0}(i32), param.number{r0}(i16)
        ld   r3, r1
        ld   r2, r0
        ld   r1, r2
        rl   r1
        sbc  r1, r1
        sbc  r0, r0
        ; call printUint_Pi32[t.1.1{r0}]
        call printUint_Pi32
        ret

        ; void printIntLf_Pbool
        ; arg value (bool): r0
printIntLf_Pbool:
        ; const number.1{r1}, 0
        ld   r1, #%00
        ; 122:2 if value
        ; branch param.value{r0} notequals 0: if_1_then
        cp   r0, #%00
        jr   ne, if_1_then
        ; move number.2{r0}, number.1{r1}
        ld   r0, r1
        jr   if_1_end

if_1_then:
        ; const number.3{r0}, 1
        ld   r0, #%01
if_1_end:
        ; cast t.2.1{r0}(i16), number.2{r0}(u8)
        ld   r1, r0
        ld   r0, #0
        ; call printIntLf_Pi16[t.2.1{r0}]
        call printIntLf_Pi16
        ret

        ; void printIntLf_Pu8
        ; arg number (u8): r0
printIntLf_Pu8:
        ; cast t.1.1{r0}(i16), param.number{r0}(u8)
        ld   r1, r0
        ld   r0, #0
        ; call printIntLf_Pi16[t.1.1{r0}]
        call printIntLf_Pi16
        ret

        ; void printIntLf_Pi16
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
        jr   gt, if_2_end
        jr   ne, .gt1
        cp   r9, #%00
        jr   uge, if_2_end
.gt1:
        ; const arg.0.0{r0}, 45
        ld   r0, #%2d
        ; call printChar_Pu8[arg.0.0{r0}]
        call printChar_Pu8
        ; neg number.2{r0}, param.number{r8}
        ld   r0, #%00
        ld   r1, #%00
        sub  r1, r9
        sbc  r0, r8
        ; move number.1{r8}, number.2{r0}
        ld   r9, r1
        ld   r8, r0
if_2_end:
        ; move number.1{r0}, number.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printUint_Pi16[number.1{r0}]
        call printUint_Pi16
        ; const arg.2.0{r0}, 13
        ld   r0, #%0d
        ; call printChar_Pu8[arg.2.0{r0}]
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
        ; call printString_P_pu8[t.0.1{r0}]
        call printString_P_pu8
        ; const {r0}, 1
        ld   r0, #%01
        ret

        ; bool getFalse
getFalse:
        ; const t.0.1{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString_P_pu8[t.0.1{r0}]
        call printString_P_pu8
        ; const {r0}, 0
        ld   r0, #%00
        ret

        ; void printPass
printPass:
        ; const t.0.1{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString_P_pu8[t.0.1{r0}]
        call printString_P_pu8
        ret

        ; void printError
printError:
        ; const t.0.1{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString_P_pu8[t.0.1{r0}]
        call printString_P_pu8
        ret

        ; void logicNot
logicNot:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const t.2.1{r0}, [string-4]
        ld   r0, #hi(string_4)
        ld   r1, #lo(string_4)
        ; call printString_P_pu8[t.2.1{r0}]
        call printString_P_pu8
        ; const t.1{r8}, 1
        ld   r8, #%01
        ; const f.1{r9}, 0
        ld   r9, #%00
        ; 13:2 if !getFalse([])
        ; call t.3.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.3.1{r0} equals 0: if_3_then
        cp   r0, #%00
        jr   eq, if_3_then
        ; call printError[]
        call printError
        jr   if_3_end

if_3_then:
        ; call printPass[]
        call printPass
if_3_end:
        ; notlog t.4.1{r0}, f.1{r9}
        or   r9, r9
        ld   r0, #0  ; false
        jr   nz, .2
        ld   r0, #1  ; true
.2:
        ; call printIntLf_Pbool[t.4.1{r0}]
        call printIntLf_Pbool
        ; 15:2 if !getTrue([])
        ; call t.5.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.5.1{r0} equals 0: if_4_then
        cp   r0, #%00
        jr   eq, if_4_then
        ; call printPass[]
        call printPass
        jr   if_4_end

if_4_then:
        ; call printError[]
        call printError
if_4_end:
        ; notlog t.6.1{r0}, t.1{r8}
        or   r8, r8
        ld   r0, #0  ; false
        jr   nz, .3
        ld   r0, #1  ; true
.3:
        ; call printIntLf_Pbool[t.6.1{r0}]
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
        ; const t.2.1{r0}, [string-5]
        ld   r0, #hi(string_5)
        ld   r1, #lo(string_5)
        ; call printString_P_pu8[t.2.1{r0}]
        call printString_P_pu8
        ; const t.1{r8}, 1
        ld   r8, #%01
        ; const f.1{r9}, 0
        ld   r9, #%00
        ; 23:2 if getFalse([]) && getFalse([])
        ; call t.3.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.3.1{r0} equals 0: if_5_else
        cp   r0, #%00
        jr   eq, if_5_else
        ; call t.4.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.4.1{r0} equals 0: if_5_else
        cp   r0, #%00
        jr   eq, if_5_else
        ; call printError[]
        call printError
        jr   if_5_end

if_5_else:
        ; call printPass[]
        call printPass
if_5_end:
        ; 24:15 logic and
        ; move t.5.1{r0}, f.1{r9}
        ld   r0, r9
        ; call printIntLf_Pbool[t.5.2{r0}]
        call printIntLf_Pbool
        ; 25:2 if getFalse([]) && getTrue([])
        ; call t.6.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.6.1{r0} equals 0: if_8_else
        cp   r0, #%00
        jr   eq, if_8_else
        ; call t.7.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.7.1{r0} equals 0: if_8_else
        cp   r0, #%00
        jr   eq, if_8_else
        ; call printError[]
        call printError
        jr   if_8_end

if_8_else:
        ; call printPass[]
        call printPass
if_8_end:
        ; 26:15 logic and
        ; move t.8.1{r0}, f.1{r9}
        ld   r0, r9
        ; branch t.8.1{r0} equals 0: and_next_10
        cp   r0, #%00
        jr   eq, and_next_10
        ; move t.8.3{r0}, t.1{r8}
        ld   r0, r8
and_next_10:
        ; call printIntLf_Pbool[t.8.2{r0}]
        call printIntLf_Pbool
        ; 27:2 if getTrue([]) && getFalse([])
        ; call t.9.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.9.1{r0} equals 0: if_11_else
        cp   r0, #%00
        jr   eq, if_11_else
        ; call t.10.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.10.1{r0} equals 0: if_11_else
        cp   r0, #%00
        jr   eq, if_11_else
        ; call printError[]
        call printError
        jr   if_11_end

if_11_else:
        ; call printPass[]
        call printPass
if_11_end:
        ; 28:15 logic and
        ; move t.11.1{r0}, t.1{r8}
        ld   r0, r8
        ; branch t.11.1{r0} equals 0: and_next_13
        cp   r0, #%00
        jr   eq, and_next_13
        ; move t.11.3{r0}, f.1{r9}
        ld   r0, r9
and_next_13:
        ; call printIntLf_Pbool[t.11.2{r0}]
        call printIntLf_Pbool
        ; 29:2 if getTrue([]) && getTrue([])
        ; call t.12.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.12.1{r0} equals 0: if_14_else
        cp   r0, #%00
        jr   eq, if_14_else
        ; call t.13.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.13.1{r0} equals 0: if_14_else
        cp   r0, #%00
        jr   eq, if_14_else
        ; call printPass[]
        call printPass
        jr   if_14_end

if_14_else:
        ; call printError[]
        call printError
if_14_end:
        ; 30:15 logic and
        ; move t.14.1{r0}, t.1{r8}
        ld   r0, r8
        ; call printIntLf_Pbool[t.14.2{r0}]
        call printIntLf_Pbool
        ; 32:2 if !getFalse([]) && getFalse([])
        ; call t.15.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.15.1{r0} equals 0: if_17_then
        cp   r0, #%00
        jr   eq, if_17_then
        ; call t.16.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.16.1{r0} equals 0: if_17_then
        cp   r0, #%00
        jr   eq, if_17_then
        ; call printError[]
        call printError
        jr   if_17_end

if_17_then:
        ; call printPass[]
        call printPass
if_17_end:
        ; 33:17 logic and
        ; move t.18.1{r0}, f.1{r9}
        ld   r0, r9
        ; notlog t.17.1{r0}, t.18.2{r0}
        or   r0, r0
        ld   r0, #0  ; false
        jr   nz, .4
        ld   r0, #1  ; true
.4:
        ; call printIntLf_Pbool[t.17.1{r0}]
        call printIntLf_Pbool
        ; 34:2 if !getFalse([]) && getTrue([])
        ; call t.19.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.19.1{r0} equals 0: if_20_then
        cp   r0, #%00
        jr   eq, if_20_then
        ; call t.20.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.20.1{r0} equals 0: if_20_then
        cp   r0, #%00
        jr   eq, if_20_then
        ; call printError[]
        call printError
        jr   if_20_end

if_20_then:
        ; call printPass[]
        call printPass
if_20_end:
        ; 35:17 logic and
        ; move t.22.1{r0}, f.1{r9}
        ld   r0, r9
        ; branch t.22.1{r0} equals 0: and_next_22
        cp   r0, #%00
        jr   eq, and_next_22
        ; move t.22.3{r0}, t.1{r8}
        ld   r0, r8
and_next_22:
        ; notlog t.21.1{r0}, t.22.2{r0}
        or   r0, r0
        ld   r0, #0  ; false
        jr   nz, .5
        ld   r0, #1  ; true
.5:
        ; call printIntLf_Pbool[t.21.1{r0}]
        call printIntLf_Pbool
        ; 36:2 if !getTrue([]) && getFalse([])
        ; call t.23.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.23.1{r0} equals 0: if_23_then
        cp   r0, #%00
        jr   eq, if_23_then
        ; call t.24.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.24.1{r0} equals 0: if_23_then
        cp   r0, #%00
        jr   eq, if_23_then
        ; call printError[]
        call printError
        jr   if_23_end

if_23_then:
        ; call printPass[]
        call printPass
if_23_end:
        ; 37:17 logic and
        ; move t.26.1{r0}, t.1{r8}
        ld   r0, r8
        ; branch t.26.1{r0} equals 0: and_next_25
        cp   r0, #%00
        jr   eq, and_next_25
        ; move t.26.3{r0}, f.1{r9}
        ld   r0, r9
and_next_25:
        ; notlog t.25.1{r0}, t.26.2{r0}
        or   r0, r0
        ld   r0, #0  ; false
        jr   nz, .6
        ld   r0, #1  ; true
.6:
        ; call printIntLf_Pbool[t.25.1{r0}]
        call printIntLf_Pbool
        ; 38:2 if !getTrue([]) && getTrue([])
        ; call t.27.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.27.1{r0} equals 0: if_26_then
        cp   r0, #%00
        jr   eq, if_26_then
        ; call t.28.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.28.1{r0} equals 0: if_26_then
        cp   r0, #%00
        jr   eq, if_26_then
        ; call printPass[]
        call printPass
        jr   if_26_end

if_26_then:
        ; call printError[]
        call printError
if_26_end:
        ; 39:17 logic and
        ; move t.30.1{r0}, t.1{r8}
        ld   r0, r8
        ; notlog t.29.1{r0}, t.30.2{r0}
        or   r0, r0
        ld   r0, #0  ; false
        jr   nz, .7
        ld   r0, #1  ; true
.7:
        ; call printIntLf_Pbool[t.29.1{r0}]
        call printIntLf_Pbool
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void logicOr
logicOr:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const t.2.1{r0}, [string-6]
        ld   r0, #hi(string_6)
        ld   r1, #lo(string_6)
        ; call printString_P_pu8[t.2.1{r0}]
        call printString_P_pu8
        ; const t.1{r8}, 1
        ld   r8, #%01
        ; const f.1{r9}, 0
        ld   r9, #%00
        ; 46:2 if getFalse([]) || getFalse([])
        ; call t.3.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.3.1{r0} notequals 0: if_29_then
        cp   r0, #%00
        jr   ne, if_29_then
        ; call t.4.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.4.1{r0} notequals 0: if_29_then
        cp   r0, #%00
        jr   ne, if_29_then
        ; call printPass[]
        call printPass
        jr   if_29_end

if_29_then:
        ; call printError[]
        call printError
if_29_end:
        ; 47:15 logic or
        ; move t.5.1{r0}, f.1{r9}
        ld   r0, r9
        ; call printIntLf_Pbool[t.5.2{r0}]
        call printIntLf_Pbool
        ; 48:2 if getFalse([]) || getTrue([])
        ; call t.6.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.6.1{r0} notequals 0: if_32_then
        cp   r0, #%00
        jr   ne, if_32_then
        ; call t.7.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.7.1{r0} notequals 0: if_32_then
        cp   r0, #%00
        jr   ne, if_32_then
        ; call printError[]
        call printError
        jr   if_32_end

if_32_then:
        ; call printPass[]
        call printPass
if_32_end:
        ; 49:15 logic or
        ; move t.8.1{r0}, f.1{r9}
        ld   r0, r9
        ; branch t.8.1{r0} notequals 0: or_next_34
        cp   r0, #%00
        jr   ne, or_next_34
        ; move t.8.3{r0}, t.1{r8}
        ld   r0, r8
or_next_34:
        ; call printIntLf_Pbool[t.8.2{r0}]
        call printIntLf_Pbool
        ; 50:2 if getTrue([]) || getFalse([])
        ; call t.9.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.9.1{r0} notequals 0: if_35_then
        cp   r0, #%00
        jr   ne, if_35_then
        ; call t.10.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.10.1{r0} notequals 0: if_35_then
        cp   r0, #%00
        jr   ne, if_35_then
        ; call printError[]
        call printError
        jr   if_35_end

if_35_then:
        ; call printPass[]
        call printPass
if_35_end:
        ; 51:15 logic or
        ; move t.11.1{r0}, t.1{r8}
        ld   r0, r8
        ; branch t.11.1{r0} notequals 0: or_next_37
        cp   r0, #%00
        jr   ne, or_next_37
        ; move t.11.3{r0}, f.1{r9}
        ld   r0, r9
or_next_37:
        ; call printIntLf_Pbool[t.11.2{r0}]
        call printIntLf_Pbool
        ; 52:2 if getTrue([]) || getTrue([])
        ; call t.12.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.12.1{r0} notequals 0: if_38_then
        cp   r0, #%00
        jr   ne, if_38_then
        ; call t.13.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.13.1{r0} notequals 0: if_38_then
        cp   r0, #%00
        jr   ne, if_38_then
        ; call printError[]
        call printError
        jr   if_38_end

if_38_then:
        ; call printPass[]
        call printPass
if_38_end:
        ; 53:15 logic or
        ; move t.14.1{r0}, t.1{r8}
        ld   r0, r8
        ; call printIntLf_Pbool[t.14.2{r0}]
        call printIntLf_Pbool
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void main
        ; var d.1 (i16): SP+8
        ; var t.1 (bool): SP+10
        ; var f.1 (bool): SP+11
main:
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
        ; call printString_P_pu8[t.9.1{r0}]
        call printString_P_pu8
        ; const a.1{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ; const b.1{r10}, 1
        ld   r10, #%00
        ld   r11, #%01
        ; const c.1{r12}, 2
        ld   r12, #%00
        ld   r13, #%02
        ; const d.1{r0}, 3
        ld   r0, #%00
        ld   r1, #%03
        ; addrof memVarAddr{r14}, d.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], d.1{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        ; const t.1{r0}, 1
        ld   r0, #%01
        ; addrof memVarAddr{r14}, t.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], t.1{r0}
        lde  @rr14, r0
        ; const f.1{r0}, 0
        ld   r0, #%00
        ; addrof memVarAddr{r14}, f.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; store [memVarAddr{r14}], f.1{r0}
        lde  @rr14, r0
        ; move t.10.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; and t.10.1{r0}, a.1{r8}
        and  r0, r8
        and  r1, r9
        ; call printIntLf_Pi16[t.10.1{r0}]
        call printIntLf_Pi16
        ; move t.11.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; and t.11.1{r0}, b.1{r10}
        and  r0, r10
        and  r1, r11
        ; call printIntLf_Pi16[t.11.1{r0}]
        call printIntLf_Pi16
        ; move t.12.1{r0}, b.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; and t.12.1{r0}, a.1{r8}
        and  r0, r8
        and  r1, r9
        ; call printIntLf_Pi16[t.12.1{r0}]
        call printIntLf_Pi16
        ; move t.13.1{r0}, b.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; and t.13.1{r0}, b.1{r10}
        and  r0, r10
        and  r1, r11
        ; call printIntLf_Pi16[t.13.1{r0}]
        call printIntLf_Pi16
        ; const t.14.1{r0}, [string-8]
        ld   r0, #hi(string_8)
        ld   r1, #lo(string_8)
        ; call printString_P_pu8[t.14.1{r0}]
        call printString_P_pu8
        ; move t.15.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; or t.15.1{r0}, a.1{r8}
        or   r0, r8
        or   r1, r9
        ; call printIntLf_Pi16[t.15.1{r0}]
        call printIntLf_Pi16
        ; move t.16.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; or t.16.1{r0}, b.1{r10}
        or   r0, r10
        or   r1, r11
        ; call printIntLf_Pi16[t.16.1{r0}]
        call printIntLf_Pi16
        ; move t.17.1{r0}, b.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; or t.17.1{r0}, a.1{r8}
        or   r0, r8
        or   r1, r9
        ; call printIntLf_Pi16[t.17.1{r0}]
        call printIntLf_Pi16
        ; move t.18.1{r0}, b.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; or t.18.1{r0}, b.1{r10}
        or   r0, r10
        or   r1, r11
        ; call printIntLf_Pi16[t.18.1{r0}]
        call printIntLf_Pi16
        ; const t.19.1{r0}, [string-9]
        ld   r0, #hi(string_9)
        ld   r1, #lo(string_9)
        ; call printString_P_pu8[t.19.1{r0}]
        call printString_P_pu8
        ; move t.20.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; xor t.20.1{r0}, a.1{r8}
        xor  r0, r8
        xor  r1, r9
        ; call printIntLf_Pi16[t.20.1{r0}]
        call printIntLf_Pi16
        ; move t.21.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; xor t.21.1{r0}, c.1{r12}
        xor  r0, r12
        xor  r1, r13
        ; call printIntLf_Pi16[t.21.1{r0}]
        call printIntLf_Pi16
        ; move t.22.1{r0}, b.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; xor t.22.1{r0}, a.1{r8}
        xor  r0, r8
        xor  r1, r9
        ; call printIntLf_Pi16[t.22.1{r0}]
        call printIntLf_Pi16
        ; move t.23.1{r0}, b.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; xor t.23.1{r0}, c.1{r12}
        xor  r0, r12
        xor  r1, r13
        ; call printIntLf_Pi16[t.23.1{r0}]
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
        jr   eq, if_41_then
        ; call t.25.1{r0} = getTrue[] -> bool
        call getTrue
        ; branch t.25.1{r0} equals 0: if_41_then
        cp   r0, #%00
        jr   eq, if_41_then
        ; call t.26.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.26.1{r0} equals 0: if_41_then
        cp   r0, #%00
        jr   eq, if_41_then
        ; call t.27.1{r0} = getFalse[] -> bool
        call getFalse
        ; branch t.27.1{r0} equals 0: if_41_then
        cp   r0, #%00
        jr   eq, if_41_then
        ; call printError[]
        call printError
        jr   if_41_end

if_41_then:
        ; call printPass[]
        call printPass
if_41_end:
        ; 88:23 logic or
        ; 88:17 logic and
        ; addrof memVarAddr{r14}, t.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load t.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; move t.29.1{r1}, t.1{r0}
        ld   r1, r0
        ; notlog t.28.1{r0}, t.29.2{r0}
        or   r0, r0
        ld   r0, #0  ; false
        jr   nz, .8
        ld   r0, #1  ; true
.8:
        ; branch t.28.1{r0} notequals 0: or_next_45
        cp   r0, #%00
        jr   ne, or_next_45
        ; 88:30 logic and
        ; addrof memVarAddr{r14}, f.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; load f.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; move t.30.1{r1}, f.1{r0}
        ld   r1, r0
        ; notlog t.28.3{r0}, t.30.2{r0}
        or   r0, r0
        ld   r0, #0  ; false
        jr   nz, .9
        ld   r0, #1  ; true
.9:
or_next_45:
        ; call printIntLf_Pbool[t.28.2{r0}]
        call printIntLf_Pbool
        ; const t.31.1{r0}, [string-10]
        ld   r0, #hi(string_10)
        ld   r1, #lo(string_10)
        ; call printString_P_pu8[t.31.1{r0}]
        call printString_P_pu8
        ; const b10.1{r0}, 10
        ld   r0, #%0a
        ; const b6.1{r1}, 6
        ld   r1, #%06
        ; const b1.1{r8}, 1
        ld   r8, #%01
        ; and t.33.1{r0}, b6.1{r1}
        and  r0, r1
        ; or t.32.1{r0}, b1.1{r8}
        or   r0, r8
        ; call printIntLf_Pu8[t.32.1{r0}]
        call printIntLf_Pu8
        ; 95:20 logic or
        ; equals t.34.1{r0}, b.1{r10}, c.1{r12}
        cp   r10, r12
        jr   ne, .ne10
        cp   r11, r13
        jr   ne, .ne10
        ld   r0, #1  ; true
        jr   .10
.ne10:
        ld   r0, #0
.10:
        ; branch t.34.1{r0} notequals 0: or_next_48
        cp   r0, #%00
        jr   ne, or_next_48
        ; addrof memVarAddr{r14}, d.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load d.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        decw r14
        ; lt t.34.3{r2}, c.1{r12}, d.1{r0}
        cp   r12, r0
        jr   lt, .true11
        jr   ne, .false11
        cp   r13, r1
        jr   ult, .true11
.false11:
        ld   r2, #0
        jr   .11
.true11:
        ld   r2, #1
.11:
        ; move t.34.2{r0}, t.34.3{r2}
        ld   r0, r2
or_next_48:
        ; call printIntLf_Pbool[t.34.2{r0}]
        call printIntLf_Pbool
        ; 96:20 logic and
        ; equals t.35.1{r0}, b.1{r10}, c.1{r12}
        cp   r10, r12
        jr   ne, .ne12
        cp   r11, r13
        jr   ne, .ne12
        ld   r0, #1  ; true
        jr   .12
.ne12:
        ld   r0, #0
.12:
        ; branch t.35.1{r0} equals 0: and_next_49
        cp   r0, #%00
        jr   eq, and_next_49
        ; addrof memVarAddr{r14}, d.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load d.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        decw r14
        ; lt t.35.3{r0}, c.1{r12}, d.1{r0}
        cp   r12, r0
        jr   lt, .true13
        jr   ne, .false13
        cp   r13, r1
        jr   ult, .true13
.false13:
        ld   r0, #0
        jr   .13
.true13:
        ld   r0, #1
.13:
and_next_49:
        ; call printIntLf_Pbool[t.35.2{r0}]
        call printIntLf_Pbool
        ; const arg.29.0{r0}, -1
        ld   r0, #%ff
        ld   r1, #%ff
        ; call printIntLf_Pi16[arg.29.0{r0}]
        call printIntLf_Pi16
        ; neg t.36.1{r0}, b.1{r10}
        ld   r0, #%00
        ld   r1, #%00
        sub  r1, r11
        sbc  r0, r10
        ; call printIntLf_Pi16[t.36.1{r0}]
        call printIntLf_Pi16
        ; not t.37.1{r0}, b1.1{r8}
        ld   r0, r8
        com  r0
        ; call printIntLf_Pu8[t.37.1{r0}]
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
        ret

        ; void printString_P_pu8
printString_P_pu8:
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

