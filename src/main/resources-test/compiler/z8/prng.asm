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
        ; move t.5{r8}, r{r4}
        ld   r8, r4
        ld   r9, r5
        ld   r10, r6
        ld   r11, r7
        ; and t.5{r8}, t.5{r8}, 524287
        and  r9, #%07
        clr  r8
        ; mul b{r8}, b{r8}, 48271
        Not supported yet: mul/div/mod for i32
        ; shiftright t.6{r4}, t.6{r4}, 15
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        ; mul c{r4}, c{r4}, 48271
        Not supported yet: mul/div/mod for i32
        ; move t.7{r0}, c{r4}
        ld   r0, r4
        ld   r1, r5
        ld   r2, r6
        ld   r3, r7
        ; and t.7{r0}, t.7{r0}, 65535
        clr  r1
        clr  r0
        ; shiftleft d{r0}, d{r0}, 15
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        ; shiftright t.9{r4}, t.9{r4}, 16
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        ; add t.8{r4}, t.8{r4}, b{r8}
        add  r7, r11
        adc  r6, r10
        adc  r5, r9
        adc  r4, r8
        ; add e{r4}, e{r4}, d{r0}
        add  r7, r3
        adc  r6, r2
        adc  r5, r1
        adc  r4, r0
        ; move t.10{r8}, e{r4}
        ld   r8, r4
        ld   r9, r5
        ld   r10, r6
        ld   r11, r7
        ; and t.10{r8}, t.10{r8}, 2147483647
        and  r8, #%7f
        ; shiftright t.11{r4}, t.11{r4}, 31
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        ; move tmp.__random__{r0}, t.10{r8}
        ld   r0, r8
        ld   r1, r9
        ld   r2, r10
        ld   r3, r11
        ; add tmp.__random__{r0}, tmp.__random__{r0}, t.11{r4}
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
        ; const arg.0.0{r0}, 7439742
        ld   r0, #%00
        ld   r1, #%71
        ld   r2, #%85
        ld   r3, #%7e
        ; call initRandom@i32[arg.0.0{r0}]
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
        ; add i{r8}, i{r8}, 1
        inc  r8
for__1:
        ; lt t.2{r0}, i{r8}, 50
        cp   r8, #%32
        jr   uge, .false1
.true1:
        ld   r0, #1
        jr   .1
.false1:
        ld   r0, #0
.1:
        ; branch t.2{r0}, true, @for_1_body, @main_ret
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
