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
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; begin initialize global variables
        ; const tmp.i{r8}, 0
        ld   r8, #%00
        ; end initialize global variables
        ; addrof memVarAddr{r14}, i
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; store [memVarAddr{r14}], tmp.i{r8}
        lde  @rr14, r8
        ; call t.0{r0} = next[] -> u8
        call next
        ; move t.0{r8}, t.0{r0}
        ld   r8, r0
        ; call t.1{r0} = next[] -> u8
        call next
        ; move t.1{r9}, t.1{r0}
        ld   r9, r0
        ; call t.2{r0} = next[] -> u8
        call next
        ; move t.2{r10}, t.2{r0}
        ld   r10, r0
        ; call t.3{r0} = next[] -> u8
        call next
        ; move t.3{r11}, t.3{r0}
        ld   r11, r0
        ; call t.4{r0} = next[] -> u8
        call next
        ; move t.4{r4}, t.4{r0}
        ld   r4, r0
        ; move t.0{r0}, t.0{r8}
        ld   r0, r8
        ; move t.1{r1}, t.1{r9}
        ld   r1, r9
        ; move t.2{r2}, t.2{r10}
        ld   r2, r10
        ; move t.3{r3}, t.3{r11}
        ld   r3, r11
        ; call doPrint@u8@u8@u8@u8@u8[t.0{r0}, t.1{r1}, t.2{r2}, t.3{r3}, t.4{r4}]
        call doPrint_Pu8_Pu8_Pu8_Pu8_Pu8
        ; restore clobbered non-volatile registers
        pop  r15
        pop  r14
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; u8 next
next:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; addrof memVarAddr{r14}, i
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; load tmp.i{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; add tmp.i{r0}, tmp.i{r0}, 1
        inc  r0
        ; 11:9 return i
        ; addrof memVarAddr{r14}, i
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; store [memVarAddr{r14}], tmp.i{r0}
        lde  @rr14, r0
        ; restore clobbered non-volatile registers
        pop  r15
        pop  r14
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void doPrint@u8@u8@u8@u8@u8
        ; arg a (u8): r0
        ; arg b (u8): r1
        ; arg c (u8): r2
        ; arg d (u8): r3
        ; arg e (u8): r4
doPrint_Pu8_Pu8_Pu8_Pu8_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; move param.b{r8}, b{r1}
        ld   r8, r1
        ; move param.c{r9}, c{r2}
        ld   r9, r2
        ; move param.d{r10}, d{r3}
        ld   r10, r3
        ; move param.e{r11}, e{r4}
        ld   r11, r4
        ; call printIntLf@u8[param.a{r0}]
        call printIntLf_Pu8
        ; move param.b{r0}, param.b{r8}
        ld   r0, r8
        ; call printIntLf@u8[param.b{r0}]
        call printIntLf_Pu8
        ; move param.c{r0}, param.c{r9}
        ld   r0, r9
        ; call printIntLf@u8[param.c{r0}]
        call printIntLf_Pu8
        ; move param.d{r0}, param.d{r10}
        ld   r0, r10
        ; call printIntLf@u8[param.d{r0}]
        call printIntLf_Pu8
        ; move param.e{r0}, param.e{r11}
        ld   r0, r11
        ; call printIntLf@u8[param.e{r0}]
        call printIntLf_Pu8
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; variable 0: i (u8/1)
var__0:
        .data %00
