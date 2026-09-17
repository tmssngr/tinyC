        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

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
        ; addrof memVarAddr{r14}, global
        ld   r14, #hi(var_0)
        ld   r15, #lo(var_0)
        ; load tmp.global{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; move copy{r0}, tmp.global{r1}
        ld   r0, r1
        ; add tmp.global{r1}, tmp.global{r1}, 1
        inc  r1
        ; 8:9 return copy
        ; addrof memVarAddr{r14}, global
        ld   r14, #hi(var_0)
        ld   r15, #lo(var_0)
        ; store [memVarAddr{r14}], tmp.global{r1}
        lde  @rr14, r1
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
        ; const tmp.global{r8}, 0
        ld   r8, #%00
        ; end initialize global variables
        ; 12:2 while true
        ; addrof memVarAddr{r14}, global
        ld   r14, #hi(var_0)
        ld   r15, #lo(var_0)
        ; store [memVarAddr{r14}], tmp.global{r8}
        lde  @rr14, r8
        jr   while__1

if__2__end:
        ; branch n{r8} gteq 2: while_1, if_3_then
        cp   r8, #%02
        jr   uge, while__1
        ; const t.2{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.2{r0}]
        call printString_P_Pu8
while__1:
        ; const t.1{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString@@u8[t.1{r0}]
        call printString_P_Pu8
        ; call n{r0} = next[] -> u8
        call next
        ; move n{r8}, n{r0}
        ld   r8, r0
        ; 15:3 if n == 3
        ; branch n{r8} notequals 3: if_2_end, main_ret
        cp   r8, #%03
        jr   ne, if__2__end
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

        ; void printString@@u8
printString_P_Pu8:
        ld   r2, r0
        ld   r3, r1
        jr   .loop
.print:
        call printChar_Pu8
        incw r2
.loop:
        lde  r0, @rr2
        or   r0, r0
        jr   nz, .print
        ret

        ; variable 0: global (u8/1)
var_0:
        .data %00

string_0:
        .data "loop" %0a %00
string_1:
        .data "<2" %0a %00

