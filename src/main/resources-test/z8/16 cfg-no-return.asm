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
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; 3:2 while true
        ; copy i(0@function,u8), r.0(0@register,u8)
@while_1:
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), i(0@function,u8)
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; copy i(0@function,u8), r.0(0@register,u8)
        ; jump @while_1
        jmp @while_1
        ; release space for local variables
        add rsp, 1
        ret


