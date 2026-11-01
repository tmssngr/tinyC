        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; u8 simple
simple:
        ; const four.1{r1}, 4
        ld   r1, #%04
        ; const three.1{r2}, 3
        ld   r2, #%03
        ; move one.1{r0}, four.1{r1}
        ld   r0, r1
        ; sub one.1{r0}, three.1{r2}
        sub  r0, r2
        ; 5:9 return one
        ret

        ; u8 registerHint@u8@u8
        ; arg a (u8): r0
        ; arg b (u8): r1
registerHint_Pu8_Pu8:
        ; 9:11 return a + b
        ; add t.2.1{r0}, param.b{r1}
        add  r0, r1
        ret

        ; u8 max@u8@u8
        ; arg a (u8): r0
        ; arg b (u8): r1
max_Pu8_Pu8:
        ; branch param.a{r0} lt param.b{r1}: if_1_then
        cp   r0, r1
        jr   ult, if__1__then
        ; 16:9 return a
        jr   max_Pu8_Pu8__ret

if__1__then:
        ; 14:10 return b
        ; move param.b{r0}, param.b{r1}
        ld   r0, r1
max_Pu8_Pu8__ret:
        ret

        ; i16 fibonacci@u8
        ; arg i (u8): r0
fibonacci_Pu8:
        ; save clobbered non-volatile registers
        push r8
        ; const a.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; const b.1{r4}, 1
        ld   r4, #%00
        ld   r5, #%01
        ; 22:2 while i > 0
        ; move i.1{r6}, param.i{r0}
        ld   r6, r0
        ; move a.2{r0}, a.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; move b.2{r2}, b.1{r4}
        ld   r2, r4
        ld   r3, r5
        jr   while__2

while__2__body:
        ; move i.2{r4}, i.1{r6}
        ld   r4, r6
        ; sub i.2{r4}, 1
        dec  r4
        ; move c.1{r5}, a.2{r0}
        ld   r6, r1
        ld   r5, r0
        ; add c.1{r5}, b.2{r2}
        add  r6, r3
        adc  r5, r2
        ; move b.3{r7}, c.1{r5}
        ld   r8, r6
        ld   r7, r5
        ; move i.1{r6}, i.2{r4}
        ld   r6, r4
        ; move a.2{r0}, a.3{r2}
        ld   r0, r2
        ld   r1, r3
        ; move b.2{r2}, b.3{r7}
        ld   r2, r7
        ld   r3, r8
while__2:
        ; branch i.1{r6} gt 0: while_2_body
        cp   r6, #%00
        jr   ugt, while__2__body
        ; 28:9 return a
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; call one.1{r0} = simple[] -> u8
        call simple
        ; move one.1{r8}, one.1{r0}
        ld   r8, r0
        ; const two.1{r9}, 2
        ld   r9, #%02
        ; move two.1{r1}, two.1{r9}
        ld   r1, r9
        ; call _ = registerHint@u8@u8[one.1{r0}, two.1{r1}] -> u8
        call registerHint_Pu8_Pu8
        ; move one.1{r0}, one.1{r8}
        ld   r0, r8
        ; move two.1{r1}, two.1{r9}
        ld   r1, r9
        ; call _ = max@u8@u8[one.1{r0}, two.1{r1}] -> u8
        call max_Pu8_Pu8
        ; const arg.3.0{r0}, 5
        ld   r0, #%05
        ; call _ = fibonacci@u8[arg.3.0{r0}] -> i16
        call fibonacci_Pu8
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret
