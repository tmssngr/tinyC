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
        ; 53:10 return (u8)
        ; call t.1{r0} = random[] -> i32
        call random
        ; cast t.0{r0}(u8), t.1{r0}(i32)
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
        pop  r8
        ret

        ; void initRandom@i32
initRandom_Pi32:
        ld   %70, r0
        ld   %71, r1
        ld   %72, r2
        ld   %73, r3
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
