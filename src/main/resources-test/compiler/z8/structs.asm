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
        ; var pos (u8): SP+4
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; const t.2{r8}, 1
        ld   r8, #%01
        ; 9:6 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=9:2].x
        ; addrof t.3{r10}, pos
        ld   r10, SPH
        ld   r11, SPL
        add  r11, #%04
        adc  r10, #%00
        ; store [t.3{r10}], t.2{r8}
        lde  @rr10, r8
        ; 10:14 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=10:10].x
        ; addrof t.6{r8}, pos
        ld   r8, SPH
        ld   r9, SPL
        add  r9, #%04
        adc  r8, #%00
        ; load t.5{r8}, [t.6{r8}]
        lde  r8, @rr8
        ; add t.4{r8}, t.4{r8}, 1
        inc  r8
        ; 10:6 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=10:2].y
        ; addrof t.7{r10}, pos
        ld   r10, SPH
        ld   r11, SPL
        add  r11, #%04
        adc  r10, #%00
        ; add t.7{r10}, t.7{r10}, 1
        incw r10
        ; store [t.7{r10}], t.4{r8}
        lde  @rr10, r8
        ; 11:17 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=11:13].x
        ; addrof t.9{r8}, pos
        ld   r8, SPH
        ld   r9, SPL
        add  r9, #%04
        adc  r8, #%00
        ; load t.8{r0}, [t.9{r8}]
        lde  r0, @rr8
        ; call printIntLf@u8[t.8{r0}]
        call printIntLf_Pu8
        ; 12:17 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=12:13].y
        ; addrof t.11{r8}, pos
        ld   r8, SPH
        ld   r9, SPL
        add  r9, #%04
        adc  r8, #%00
        ; add t.11{r8}, t.11{r8}, 1
        incw r8
        ; load t.10{r0}, [t.11{r8}]
        lde  r0, @rr8
        ; call printIntLf@u8[t.10{r0}]
        call printIntLf_Pu8
        ; 13:15 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=13:11].x
        ; addrof x{r8}, pos
        ld   r8, SPH
        ld   r9, SPL
        add  r9, #%04
        adc  r8, #%00
        ; load t.12{r0}, [x{r8}]
        lde  r0, @rr8
        ; call printIntLf@u8[t.12{r0}]
        call printIntLf_Pu8
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret
