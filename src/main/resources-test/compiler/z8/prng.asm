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

        ; u8 randomU8
randomU8:
        ; 60:10 return (u8)
        ; call t.1.1{r0} = random[] -> i32
        call random
        ; cast t.0.1{r0}(u8), t.1.1{r0}(i32)
        ld   r0, r3
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        ; const arg.0.0{r0}, 7439742
        ld   r0, #%00
        ld   r1, #%71
        ld   r2, #%85
        ld   r3, #%7e
        ; call initRandom@i32[arg.0.0{r0}]
        call initRandom_Pi32
        ; const i.1{r8}, 0
        ld   r8, #%00
        ; 6:2 for i < 50
        jr   for__1

for__1__body:
        ; call r.1{r0} = randomU8[] -> u8
        call randomU8
        ; call printIntLf@u8[r.1{r0}]
        call printIntLf_Pu8
        ; move i.3{r0}, i.2{r8}
        ld   r0, r8
        ; add i.3{r0}, 1
        inc  r0
        ; move i.2{r8}, i.3{r0}
        ld   r8, r0
for__1:
        ; branch i.2{r8} lt 50: for_1_body
        cp   r8, #%32
        jr   ult, for__1__body
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; void initRandom@i32
initRandom_Pi32:
        ld   %74, r0
        ld   %75, r1
        ld   %76, r2
        ld   %77, r3
        ld   r0, #%F7
        ld   r1, #%A8
        ld   r2, #%74
        ld   r3, #4
.1:
        ldei @rr0, @r2
        djnz r3, .1
        ret

        ; i32 random
random:
        call %0836
        ld   r0, %74
        ld   r1, %75
        call %0836
        ld   r2, %74
        ld   r3, %75
        ret
