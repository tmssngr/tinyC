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
        ; const i{r8}, 250
        ld   r8, #%fa
        ; 4:3 for i != 2
        jr   for__1

for__1__body:
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printIntLf@u8[i{r0}]
        call printIntLf_Pu8
        ; const t.4{r9}, 1
        ld   r9, #%01
        ; add i{r8}, i{r8}, t.4{r9}
        add  r8, r9
for__1:
        ; const t.3{r9}, 2
        ld   r9, #%02
        ; notequals t.2{r9}, i{r8}, t.3{r9}
        cp   r8, r9
        jr   ne, .ne1
        ld   r9, #0  ; false
        jr   .1
.ne1:
        ld   r9, #1
.1:
        ; branch t.2{r9}, true, @for_1_body, @for_1_break
        or   r9, r9
        jr   nz, for__1__body
        ; const v{r8}, 260
        ld   r8, #%01
        ld   r9, #%04
        ; cast t.5{r0}(u8), v{r8}(i16)
        ld   r0, r9
        ; call printIntLf@u8[t.5{r0}]
        call printIntLf_Pu8
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret
