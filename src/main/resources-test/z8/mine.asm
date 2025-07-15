format pe64 console
include 'win64ax.inc'

STD_IN_HANDLE = -10
STD_OUT_HANDLE = -11
STD_ERR_HANDLE = -12

entry start

section '.text' code readable executable

start:
        ; alignment
        and rsp, -16
        call init
        call @main
        mov rcx, 0
        sub rsp, 0x20
        call [ExitProcess]

        ; void printString
        ret

        ; void printStringLength
        ret

        ; void printUint
        ret

        ; u8 getChar
        ret

        ; void setCursor
        ret

        ; void initRandom
        ret

        ; i32 random
        ret

        ; i16 rowColumnToCell
        ret

        ; u8 getCell
        ret

        ; bool isBomb
        ret

        ; bool isOpen
        ret

        ; bool isFlag
        ret

        ; bool checkCellBounds
        ret

        ; void setCell
        ret

        ; u8 getBombCountAround
        ret

        ; u8 getSpacer
        ret

        ; void printCell
        ret

        ; void printField
        ret

        ; void printSpaces
        ret

        ; u8 getDigitCount
        ret

        ; i16 getHiddenCount
        ret

        ; bool printLeft
        ret

        ; i16 abs
        ret

        ; void clearField
        ret

        ; void initField
        ret

        ; void maybeRevealAround
        ret

        ; void main
        ret

        ; void printChar
@printChar:
        ld   r0, SPH
        ld   r1, SPL
        add  r1, 3
        adc  r0, 0
        ldc  r1, @rr0
        ld   %15, r1
        jp   %0818

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8
        ; variable 0: field[] (u8*/6400)
        var_0 rb 6400

section '.data' data readable
        string_0 db '|', 0x0a, 0x00
        string_1 db 'Left: ', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

