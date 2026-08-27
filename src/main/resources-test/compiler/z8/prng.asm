        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void printIntLf@u8
        ; arg number (u8): r0
printIntLf_Pu8:
        ret

        ; void initRandom@i32
        ; arg salt (i32): r0
initRandom_Pi32:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; addrof memVarAddr{r14}, __random__
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; store [memVarAddr{r14}], tmp.__random__{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        incw r14
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
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

        ; i32 random
        ; var b (i32): SP+8
random:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; addrof memVarAddr{r14}, __random__
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; load tmp.__random__{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        incw r14
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        ; move r{r4}, tmp.__random__{r0}
        ld   r4, r0
        ld   r5, r1
        ld   r6, r2
        ld   r7, r3
        ; const t.6{r8}, 524287
        ld   r8, #%00
        ld   r9, #%07
        ld   r10, #%ff
        ld   r11, #%ff
        ; move t.5{r0}, r{r4}
        ld   r0, r4
        ld   r1, r5
        ld   r2, r6
        ld   r3, r7
        ; and t.5{r0}, t.5{r0}, t.6{r8}
        and  r0, r8
        and  r1, r9
        and  r2, r10
        and  r3, r11
        ; const t.7{r8}, 48271
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%bc
        ld   r11, #%8f
        ; mul b{r0}, b{r0}, t.7{r8}
        Not supported yet: mul/div/mod for i32
        ; const t.9{r8}, 15
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%0f
        ; shiftright t.8{r4}, t.8{r4}, t.9{r8}
        or   r11, r11
        jr   z, .next1
        push r11
.shift1:
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        djnz r11, .shift1
        pop  r11
.next1:
        ; const t.10{r8}, 48271
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%bc
        ld   r11, #%8f
        ; mul c{r4}, c{r4}, t.10{r8}
        Not supported yet: mul/div/mod for i32
        ; const t.12{r8}, 65535
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%ff
        ld   r11, #%ff
        ; addrof memVarAddr{r14}, b
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], b{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        incw r14
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        ; move t.11{r0}, c{r4}
        ld   r0, r4
        ld   r1, r5
        ld   r2, r6
        ld   r3, r7
        ; and t.11{r0}, t.11{r0}, t.12{r8}
        and  r0, r8
        and  r1, r9
        and  r2, r10
        and  r3, r11
        ; const t.13{r8}, 15
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%0f
        ; shiftleft d{r0}, d{r0}, t.13{r8}
        or   r11, r11
        jr   z, .next2
        push r11
.shift2:
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        djnz r11, .shift2
        pop  r11
.next2:
        ; const t.16{r8}, 16
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%10
        ; shiftright t.15{r4}, t.15{r4}, t.16{r8}
        or   r11, r11
        jr   z, .next3
        push r11
.shift3:
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        djnz r11, .shift3
        pop  r11
.next3:
        ; addrof memVarAddr{r14}, b
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load b{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        incw r14
        lde  r10, @rr14
        incw r14
        lde  r11, @rr14
        ; add t.14{r4}, t.14{r4}, b{r8}
        add  r7, r11
        adc  r6, r10
        adc  r5, r9
        adc  r4, r8
        ; add e{r4}, e{r4}, d{r0}
        add  r7, r3
        adc  r6, r2
        adc  r5, r1
        adc  r4, r0
        ; const t.18{r8}, 2147483647
        ld   r8, #%7f
        ld   r9, #%ff
        ld   r10, #%ff
        ld   r11, #%ff
        ; move t.17{r0}, e{r4}
        ld   r0, r4
        ld   r1, r5
        ld   r2, r6
        ld   r3, r7
        ; and t.17{r0}, t.17{r0}, t.18{r8}
        and  r0, r8
        and  r1, r9
        and  r2, r10
        and  r3, r11
        ; const t.20{r8}, 31
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%1f
        ; shiftright t.19{r4}, t.19{r4}, t.20{r8}
        or   r11, r11
        jr   z, .next4
        push r11
.shift4:
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        djnz r11, .shift4
        pop  r11
.next4:
        ; add tmp.__random__{r0}, tmp.__random__{r0}, t.19{r4}
        add  r3, r7
        adc  r2, r6
        adc  r1, r5
        adc  r0, r4
        ; 15:9 return __random__
        ; addrof memVarAddr{r14}, __random__
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; store [memVarAddr{r14}], tmp.__random__{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        incw r14
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
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

        ; u8 randomU8
randomU8:
        ; 19:10 return (u8)
        ; call t.1{r0} = random[] -> i32
        call random
        ; cast t.0{r0}(u8), t.1{r0}(i32)
        ld   r0, r3
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
        ; const tmp.__random__{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%00
        ; end initialize global variables
        ; const t.2{r0}, 7439742
        ld   r0, #%00
        ld   r1, #%71
        ld   r2, #%85
        ld   r3, #%7e
        ; addrof memVarAddr{r14}, __random__
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; store [memVarAddr{r14}], tmp.__random__{r8}
        lde  @rr14, r8
        incw r14
        lde  @rr14, r9
        incw r14
        lde  @rr14, r10
        incw r14
        lde  @rr14, r11
        ; call initRandom@i32[t.2{r0}]
        call initRandom_Pi32
        ; const i{r8}, 0
        ld   r8, #%00
        ; 6:2 for i < 50
        jr   for__1

for__1__body:
        ; call r{r0} = randomU8[] -> u8
        call randomU8
        ; call printIntLf@u8[r{r0}]
        call printIntLf_Pu8
        ; const t.5{r0}, 1
        ld   r0, #%01
        ; add i{r8}, i{r8}, t.5{r0}
        add  r8, r0
for__1:
        ; const t.4{r0}, 50
        ld   r0, #%32
        ; lt t.3{r0}, i{r8}, t.4{r0}
        cp   r8, r0
        jr   uge, .false5
.true5:
        ld   r0, #1
        jr   .5
.false5:
        ld   r0, #0
.5:
        ; branch t.3{r0}, true, @for_1_body, @main_ret
        or   r0, r0
        jr   nz, for__1__body
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

        ; variable 0: __random__ (i32/4)
var__0:
        .data %00 %00 %00 %00
