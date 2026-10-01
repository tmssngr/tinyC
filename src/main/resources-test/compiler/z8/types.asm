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
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const i.1{r8}, 250
        ld   r8, #%fa
        ; 4:3 for i != 2
        jr   for__1

for__1__body:
        ; move i.2{r0}, i.2{r8}
        ld   r0, r8
        ; call printIntLf@u8[i.2{r0}]
        call printIntLf_Pu8
        ; add i.3{r8}, 1
        inc  r8
for__1:
        ; branch i.2{r8} notequals 2: for_1_body
        cp   r8, #%02
        jr   ne, for__1__body
        ; const v.1{r8}, 260
        ld   r8, #%01
        ld   r9, #%04
        ; cast t.2.1{r0}(u8), v.1{r8}(i16)
        ld   r0, r9
        ; call printIntLf@u8[t.2.1{r0}]
        call printIntLf_Pu8
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret
