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
        ; const i{r8}, 5
        ld   r8, #%05
        ; 5:2 while i > 0
        jr   while__1

while__1__body:
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printIntLf@u8[i{r0}]
        call printIntLf_Pu8
        ; sub i{r8}, i{r8}, 1
        dec  r8
while__1:
        ; gt t.1{r9}, i{r8}, 0
        cp   r8, #%00
        jr   ule, .false1
.true1:
        ld   r9, #1
        jr   .1
.false1:
        ld   r9, #0
.1:
        ; branch t.1{r9}, true, @while_1_body, @while_2
        or   r9, r9
        jr   nz, while__1__body
while__2:
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printIntLf@u8[i{r0}]
        call printIntLf_Pu8
        ; add i{r8}, i{r8}, 1
        inc  r8
        ; 13:3 if i < 5
        ; lt t.2{r0}, i{r8}, 5
        cp   r8, #%05
        jr   uge, .false2
.true2:
        ld   r0, #1
        jr   .2
.false2:
        ld   r0, #0
.2:
        ; branch t.2{r0}, true, @while_2, @main_ret
        or   r0, r0
        jr   nz, while__2
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret
