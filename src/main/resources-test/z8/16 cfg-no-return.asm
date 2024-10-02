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
        ; const r0(u8 i), 0
        ld r0, 0
        ; 3:2 while true
        ; copy i(0@function,u8), r0(u8 i)
@while_1:
        ; const r0(u8 t.1), 1
        ld r0, 1
        ; copy r1(u8 i), i(0@function,u8)
        ; add r0(u8 i), r1(u8 i), r0(u8 t.1)
        ; copy i(0@function,u8), r0(u8 i)
        ; jump @while_1
        jmp @while_1
        ; release space for local variables
        add rsp, 1
        ret


