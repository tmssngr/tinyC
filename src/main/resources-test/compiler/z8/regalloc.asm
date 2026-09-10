        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; u8 simple
simple:
        ; const four{r1}, 4
        ld   r1, #%04
        ; const three{r2}, 3
        ld   r2, #%03
        ; move one{r0}, four{r1}
        ld   r0, r1
        ; sub one{r0}, one{r0}, three{r2}
        sub  r0, r2
        ; 5:9 return one
        ret

        ; u8 registerHint@u8@u8
        ; arg a (u8): r0
        ; arg b (u8): r1
registerHint__Pu8__Pu8:
        ; 9:11 return a + b
        ; add t.2{r0}, t.2{r0}, param.b{r1}
        add  r0, r1
        ret

        ; u8 max@u8@u8
        ; arg a (u8): r0
        ; arg b (u8): r1
max__Pu8__Pu8:
        ; 13:2 if a < b
        ; branch param.a{r0} lt param.b{r1}: if_1_then, if_1_end
        cp   r0, r1
        jr   ult, if__1__then
.1:
        ; 16:9 return a
        jr   max_Pu8_Pu8__ret

if____1____then:
        ; 14:10 return b
        ; move param.b{r0}, param.b{r1}
        ld   r0, r1
max__Pu8__Pu8____ret:
        ret

        ; i16 fibonacci@u8
        ; arg i (u8): r0
fibonacci__Pu8:
        ; const a{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; const b{r4}, 1
        ld   r4, #%00
        ld   r5, #%01
        ; 22:2 while i > 0
        jr   while__2

while____2____body:
        ; sub param.i{r0}, param.i{r0}, 1
        dec  r0
        ; move c{r6}, a{r2}
        ld   r7, r3
        ld   r6, r2
        ; add c{r6}, c{r6}, b{r4}
        add  r7, r5
        adc  r6, r4
        ; move a{r2}, b{r4}
        ld   r2, r4
        ld   r3, r5
        ; move b{r4}, c{r6}
        ld   r4, r6
        ld   r5, r7
while____2:
        ; branch param.i{r0} gt 0: while_2_body, while_2_break
        cp   r0, #%00
        jr   ugt, while__2__body
.2:
        ; 28:9 return a
        ; move a{r0}, a{r2}
        ld   r0, r2
        ld   r1, r3
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; call one{r0} = simple[] -> u8
        call simple
        ; move one{r8}, one{r0}
        ld   r8, r0
        ; const two{r9}, 2
        ld   r9, #%02
        ; move one{r0}, one{r8}
        ld   r0, r8
        ; move two{r1}, two{r9}
        ld   r1, r9
        ; call _ = registerHint@u8@u8[one{r0}, two{r1}] -> u8
        call registerHint_Pu8_Pu8
        ; move one{r0}, one{r8}
        ld   r0, r8
        ; move two{r1}, two{r9}
        ld   r1, r9
        ; call _ = max@u8@u8[one{r0}, two{r1}] -> u8
        call max_Pu8_Pu8
        ; const arg.3.0{r0}, 5
        ld   r0, #%05
        ; call _ = fibonacci@u8[arg.3.0{r0}] -> i16
        call fibonacci_Pu8
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret
