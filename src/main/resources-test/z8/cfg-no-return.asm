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

        ; void main
@main:
        ; const r0, 0
        ld r0, #%00
        ; 3:2 while true
@while_1:
        ; inc r0
        inc r0
        jp @while_1
        ret

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8

