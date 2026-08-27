        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void printIntLf@u8
        ; arg number (u8): r0
printIntLf_Pu8:
        ret

        ; void main
        ; var pos (u8): SP+6
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; const t.2{r8}, 1
        ld   r8, #%01
        ; 9:6 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=9:2].x
        ; addrof t.3{r10}, pos
        ld   r10, SPH
        ld   r11, SPL
        add  r11, #%06
        adc  r10, #%00
        ; store [t.3{r10}], t.2{r8}
        lde  @rr10, r8
        ; 10:14 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=10:10].x
        ; addrof t.6{r8}, pos
        ld   r8, SPH
        ld   r9, SPL
        add  r9, #%06
        adc  r8, #%00
        ; load t.5{r8}, [t.6{r8}]
        lde  r8, @rr8
        ; const t.7{r9}, 1
        ld   r9, #%01
        ; add t.4{r8}, t.4{r8}, t.7{r9}
        add  r8, r9
        ; 10:6 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=10:2].y
        ; addrof t.8{r10}, pos
        ld   r10, SPH
        ld   r11, SPL
        add  r11, #%06
        adc  r10, #%00
        ; const t.9{r12}, 1
        ld   r12, #%00
        ld   r13, #%01
        ; add t.8{r10}, t.8{r10}, t.9{r12}
        add  r11, r13
        adc  r10, r12
        ; store [t.8{r10}], t.4{r8}
        lde  @rr10, r8
        ; 11:17 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=11:13].x
        ; addrof t.11{r8}, pos
        ld   r8, SPH
        ld   r9, SPL
        add  r9, #%06
        adc  r8, #%00
        ; load t.10{r0}, [t.11{r8}]
        lde  r0, @rr8
        ; call printIntLf@u8[t.10{r0}]
        call printIntLf_Pu8
        ; 12:17 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=12:13].y
        ; addrof t.13{r8}, pos
        ld   r8, SPH
        ld   r9, SPL
        add  r9, #%06
        adc  r8, #%00
        ; const t.14{r10}, 1
        ld   r10, #%00
        ld   r11, #%01
        ; add t.13{r8}, t.13{r8}, t.14{r10}
        add  r9, r11
        adc  r8, r10
        ; load t.12{r0}, [t.13{r8}]
        lde  r0, @rr8
        ; call printIntLf@u8[t.12{r0}]
        call printIntLf_Pu8
        ; 13:15 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=13:11].x
        ; addrof x{r8}, pos
        ld   r8, SPH
        ld   r9, SPL
        add  r9, #%06
        adc  r8, #%00
        ; load t.15{r0}, [x{r8}]
        lde  r0, @rr8
        ; call printIntLf@u8[t.15{r0}]
        call printIntLf_Pu8
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret
