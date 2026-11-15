        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

        srp  #%20
        jr   main

        ; void main
main:
        ; const i.1{r0}, 0
        ld   r0, #%00
        ; 3:2 while true
while_1:
        ; add i.3{r0}, 1
        inc  r0
        jr   while_1

        ret
