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
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; load tmp.global{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; move copy{r0}, tmp.global{r1}
        ld   r0, r1
        ; const t.1{r2}, 1
        ld   r2, #%01
        ; add tmp.global{r1}, tmp.global{r1}, t.1{r2}
        add  r1, r2
        ; 8:9 return copy
        ; addrof memVarAddr{r14}, global
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
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
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; store [memVarAddr{r14}], tmp.global{r8}
        lde  @rr14, r8
        jr   while__1

if__2__end:
        ; 19:3 if n < 2
        ; const t.5{r9}, 2
        ld   r9, #%02
        ; lt t.4{r8}, n{r8}, t.5{r9}
        cp   r8, r9
        jr   uge, .false1
.true1:
        ld   r8, #1
        jr   .1
.false1:
        ld   r8, #0
.1:
        ; branch t.4{r8}, false, @while_1, @if_3_then
        or   r8, r8
        jr   z, while__1
        ; const t.6{r0}, [string-1]
        ld   r0, #hi(string__1)
        ld   r1, #lo(string__1)
        ; call printString@@u8[t.6{r0}]
        call printString_P_Pu8
while__1:
        ; const t.1{r0}, [string-0]
        ld   r0, #hi(string__0)
        ld   r1, #lo(string__0)
        ; call printString@@u8[t.1{r0}]
        call printString_P_Pu8
        ; call n{r0} = next[] -> u8
        call next
        ; move n{r8}, n{r0}
        ld   r8, r0
        ; 15:3 if n == 3
        ; const t.3{r0}, 3
        ld   r0, #%03
        ; equals t.2{r0}, n{r8}, t.3{r0}
        cp   r8, r0
        jr   ne, .ne2
        ld   r0, #1  ; true
        jr   .2
.ne2:
        ld   r0, #0
.2:
        ; branch t.2{r0}, false, @if_2_end, @main_ret
        or   r0, r0
        jr   z, if__2__end
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
var__0:
        .data %00

string__0:
        .data "loop" %0a %00
string__1:
        .data "<2" %0a %00

