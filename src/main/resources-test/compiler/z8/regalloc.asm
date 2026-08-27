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
registerHint_Pu8_Pu8:
        ; 9:11 return a + b
        ; add t.2{r0}, t.2{r0}, param.b{r1}
        add  r0, r1
        ret

        ; u8 max@u8@u8
        ; arg a (u8): r0
        ; arg b (u8): r1
max_Pu8_Pu8:
        ; 13:2 if a < b
        ; lt t.2{r2}, param.a{r0}, param.b{r1}
        cp   r0, r1
        jr   uge, .false1
.true1:
        ld   r2, #1
        jr   .1
.false1:
        ld   r2, #0
.1:
        ; branch t.2{r2}, true, @if_1_then, @if_1_end
        or   r2, r2
        jr   nz, if__1__then
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
        ; const a{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; const b{r4}, 1
        ld   r4, #%00
        ld   r5, #%01
        ; 22:2 while i > 0
        jr   while__2

while__2__body:
        ; const t.6{r6}, 1
        ld   r6, #%01
        ; sub param.i{r0}, param.i{r0}, t.6{r6}
        sub  r0, r6
        ; move c{r6}, a{r2}
        ld   r6, r2
        ld   r7, r3
        ; add c{r6}, c{r6}, b{r4}
        add  r7, r5
        adc  r6, r4
        ; move a{r2}, b{r4}
        ld   r2, r4
        ld   r3, r5
        ; move b{r4}, c{r6}
        ld   r4, r6
        ld   r5, r7
while__2:
        ; const t.5{r6}, 0
        ld   r6, #%00
        ; gt t.4{r6}, param.i{r0}, t.5{r6}
        cp   r0, r6
        jr   ule, .false2
.true2:
        ld   r6, #1
        jr   .2
.false2:
        ld   r6, #0
.2:
        ; branch t.4{r6}, true, @while_2_body, @while_2_break
        or   r6, r6
        jr   nz, while__2__body
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
        ; const t.4{r0}, 5
        ld   r0, #%05
        ; call _ = fibonacci@u8[t.4{r0}] -> i16
        call fibonacci_Pu8
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret
