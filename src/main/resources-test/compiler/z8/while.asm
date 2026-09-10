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
        ; const i{r8}, 5
        ld   r8, #%05
        ; 5:2 while i > 0
        jr   while__1

while____1____body:
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printIntLf@u8[i{r0}]
        call printIntLf_Pu8
        ; sub i{r8}, i{r8}, 1
        dec  r8
while____1:
        ; branch i{r8} gt 0: while_1_body, while_2
        cp   r8, #%00
        jr   ugt, while__1__body
.1:
while____2:
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printIntLf@u8[i{r0}]
        call printIntLf_Pu8
        ; add i{r8}, i{r8}, 1
        inc  r8
        ; 13:3 if i < 5
        ; branch i{r8} lt 5: while_2, main_ret
        cp   r8, #%05
        jr   ult, while__2
.2:
        ; restore clobbered non-volatile registers
        pop  r8
        ret
