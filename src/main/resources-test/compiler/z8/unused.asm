        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void unusedArg@u8
        ; arg a (u8): r0
unusedArg_Pu8:
        ret

        ; void main
main:
        ; const t.0{r0}, 0
        ld   r0, #%00
        ; call unusedArg@u8[t.0{r0}]
        call unusedArg_Pu8
        ret
