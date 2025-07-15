        .const RP  = %FD
        .const SPH = %FE
        .const SPL = %FF

        .org %E000

start:
        push RP
        srp  #%20
        call @main
        pop  RP
        ret

        ; u8 simple
@simple:
        ; const four{r1}, 4
        ld r1, #%04
        ; const three{r2}, 3
        ld r2, #%03
        ; move one{r0}, four{r1}
        ld r0, r1
        ; sub one{r0}, one{r0}, three{r2}
        sub r0, r2
        ; 5:9 return one
        ret

        ; u8 registerHint
        ;   sp+3: arg a
        ;   sp+2: arg b
@registerHint:
        ; 9:11 return a + b
        ; move t.2{r0}, a{r1}
        ld r0, r1
        ; add t.2{r0}, t.2{r0}, b{r2}
        add r0, r2
        ret

        ; u8 max
        ;   sp+3: arg a
        ;   sp+2: arg b
@max:
        ; 13:2 if a < b
        ; lt t.2{r3}, a{r1}, b{r2}
        not implemented
        ; branch t.2{r3}, true, @if_1_then
        or r3, r3
        jp nz, @if_1_then
        ; 16:9 return a
        ; move a{r0}, a{r1}
        ld r0, r1
        jp @max_ret
@if_1_then:
        ; 14:10 return b
        ; move b{r0}, b{r2}
        ld r0, r2
@max_ret:
        ret

        ; i16 fibonacci
        ;   sp+2: arg i
@fibonacci:
        ; const a{r0}, 0
        ld r0, #%00
        ld r1, #%00
        ; const b{r3}, 1
        ld r3, #%00
        ld r4, #%01
        ; 22:2 while i > 0
        jp @while_2
@while_2_body:
        ; dec i{r2}
        dec r2
        ; move c{r5}, a{r0}
        ld r5, r0
        ld r6, r1
        ; add c{r5}, c{r5}, b{r3}
        add r6, r4
        adc r5, r3
        ; move a{r0}, b{r3}
        ld r0, r3
        ld r1, r4
        ; move b{r3}, c{r5}
        ld r3, r5
        ld r4, r6
@while_2:
        ; gt t.4{r5}, i{r2}, 0
        cp  r2, #%00
        jr  uge, .1
.1:
        ld  r5, #%ff
        jr  .3
.2:
        ld  r5, #%00
.3:
        ; branch t.4{r5}, true, @while_2_body
        or r5, r5
        jp nz, @while_2_body
        ; 28:9 return a
        ret

        ; void main
@main:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        ; call one{r0} = simple[] -> u8
        call simple
        ; move one{r8}, one{r0}
        ld r8, r0
        ; const two{r9}, 2
        ld r9, #%02
        ; move one{r1}, one{r8}
        ld r1, r8
        ; move two{r2}, two{r9}
        ld r2, r9
        ; call _ = registerHint[one{r1}, two{r2}] -> u8
        call registerHint
        ; move one{r1}, one{r8}
        ld r1, r8
        ; move two{r2}, two{r9}
        ld r2, r9
        ; call _ = max[one{r1}, two{r2}] -> u8
        call max
        ; const t.4{r2}, 5
        ld r2, #%05
        ; call _ = fibonacci[t.4{r2}] -> i16
        call fibonacci
        ; restore globbered non-volatile registers
        pop r10
        pop r9
        pop r8
        ret

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8

