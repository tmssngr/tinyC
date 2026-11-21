        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

        srp  #%20
        jr   main

        ; u8 simple
simple:
        ; const four.1{r0}, 4
        ld   r0, #%04
        ; const three.1{r1}, 3
        ld   r1, #%03
        ; sub one.1{r0}, three.1{r1}
        sub  r0, r1
        ; 5:9 return one
        ret

        ; u8 registerHint_Pu8_Pu8
        ; arg a (u8): r0
        ; arg b (u8): r1
registerHint_Pu8_Pu8:
        ; 9:11 return a + b
        ; add t.2.1{r0}, param.b{r1}
        add  r0, r1
        ret

        ; u8 max_Pu8_Pu8
        ; arg a (u8): r0
        ; arg b (u8): r1
max_Pu8_Pu8:
        ; branch param.a{r0} lt param.b{r1}: if_1_then
        cp   r0, r1
        jr   ult, if_1_then
        ; 16:9 return a
        jr   max_Pu8_Pu8_ret

if_1_then:
        ; 14:10 return b
        ; move param.b{r0}, param.b{r1}
        ld   r0, r1
max_Pu8_Pu8_ret:
        ret

        ; i16 fibonacci_Pu8
        ; arg i (u8): r0
fibonacci_Pu8:
        ; const a.1{r1}, 0
        ld   r1, #%00
        ld   r2, #%00
        ; const b.1{r3}, 1
        ld   r3, #%00
        ld   r4, #%01
        ; 22:2 while i > 0
        jr   while_2

while_2_body:
        ; sub i.2{r0}, 1
        dec  r0
        ; add c.1{r1}, b.2{r3}
        add  r2, r4
        adc  r1, r3
        ; move b.3{r5}, c.1{r1}
        ld   r6, r2
        ld   r5, r1
        ; move a.2{r1}, a.3{r3}
        ld   r1, r3
        ld   r2, r4
        ; move b.2{r3}, b.3{r5}
        ld   r3, r5
        ld   r4, r6
while_2:
        ; branch i.1{r0} gt 0: while_2_body
        cp   r0, #%00
        jr   ugt, while_2_body
        ; 28:9 return a
        ; move a.2{r0}, a.2{r1}
        ld   r0, r1
        ld   r1, r2
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
        ; call _ = registerHint_Pu8_Pu8[one.1{r0}, two.1{r1}] -> u8
        call registerHint_Pu8_Pu8
        ; move one.1{r0}, one.1{r8}
        ld   r0, r8
        ; move two.1{r1}, two.1{r9}
        ld   r1, r9
        ; call _ = max_Pu8_Pu8[one.1{r0}, two.1{r1}] -> u8
        call max_Pu8_Pu8
        ; const arg.3.0{r0}, 5
        ld   r0, #%05
        ; call _ = fibonacci_Pu8[arg.3.0{r0}] -> i16
        call fibonacci_Pu8
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret
