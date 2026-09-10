        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void printIntLf@u8
        ; arg number (u8): r0
printIntLf__Pu8:
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const i{r8}, 250
        ld   r8, #%fa
        ; 4:3 for i != 2
        jr   for__1

for____1____body:
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printIntLf@u8[i{r0}]
        call printIntLf_Pu8
        ; add i{r8}, i{r8}, 1
        inc  r8
for____1:
        ; branch i{r8} notequals 2: for_1_body, for_1_break
        cp   r8, #%02
        jr   ne, for__1__body
.1:
        ; const v{r8}, 260
        ld   r8, #%01
        ld   r9, #%04
        ; cast t.2{r0}(u8), v{r8}(i16)
        ld   r0, r9
        ; call printIntLf@u8[t.2{r0}]
        call printIntLf_Pu8
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret
