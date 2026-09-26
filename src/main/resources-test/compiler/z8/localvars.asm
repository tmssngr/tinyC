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

        ; void main
main:
        ; const a{r0}, 10
        ld   r0, #%0a
        ; call printIntLf@u8[a{r0}]
        call printIntLf_Pu8
        ret
