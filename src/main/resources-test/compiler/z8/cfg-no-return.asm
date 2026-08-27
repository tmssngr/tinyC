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
        ; const t.1{r1}, 1
        ld   r1, #%01
        ; add i{r0}, i{r0}, t.1{r1}
        add  r0, r1
        jr   while__1

        ret
