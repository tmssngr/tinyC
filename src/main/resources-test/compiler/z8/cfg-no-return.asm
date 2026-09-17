        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void main
main:
        ; const i{r0}, 0
        ld   r0, #%00
        ; 3:2 while true
while__1:
        ; add i{r0}, i{r0}, 1
        inc  r0
        jr   while__1

        ret
