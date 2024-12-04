        .const SPH = %FE
        .const SPL = %FF

        .org %C000

        srp %20
        jp @main

        ; void main
        ;   rsp+0: var i
@main:
        ; reserve space for local variables
        sub rsp, 1
        ; const r0, 0
        ld r0, 0
        ; 3:2 while true
        ; move i, r0
@while_1:
        ; const r0, 1
        ld r0, 1
        ; move r1, i
        ; add r0, r1, r0
        ; move i, r0
        ; jump @while_1
        jmp @while_1
        ; release space for local variables
        add rsp, 1
        ret


