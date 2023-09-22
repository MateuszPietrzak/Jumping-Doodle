SECTION "Arithmetic", ROM0

; ALSO DIVIDES wArythmeticVariable by wArithmeticModifier
; function calculating modulo (SHOULD be working)
; the divident goes into [wArithmeticVariable] (higher bits go first, max 2 bytes)
; the divisor goes into [wArithmeticModifier]
; the quotient will be in [wArithmeticResult] (higher bits go first, max 2 bytes)
Modulo::

    call Divide

    ; save variable for later
    ld a, [wArithmeticVariable]
    ld b, a
    ld a, [wArithmeticVariable+1]
    ld c, a

    ; move division result as a new variable
    ld a, [wArithmeticResult]
    ld [wArithmeticVariable], a
    ld a, [wArithmeticResult+1]
    ld [wArithmeticVariable+1], a

    call Multiply

    ; load multiplication result
    ld a, [wArithmeticResult]
    ld h, a
    ld a, [wArithmeticResult+1]
    ld l, a

    ; sub bc, hl
    ld a, c
    sub a, l
    ld c, a
    jp nc, Modulo.skipCarry

    dec b

.skipCarry:

    ld a, b
    sub a, h
    ld b, a

    ld a, b
    ld [wArithmeticResult], a
    ld a, c
    ld [wArithmeticResult+1], a

    ret

; saves wArythmeticVariable
; function calculating multily (SHOULD be working)
; the multiplicand goes into [wArithmeticVariable] (higher bits go first, max 2 bytes)
; the multiplier goes into [wArithmeticModifier]
; the product will be in [wArithmeticResult] (higher bits go first, max 2 bytes)
Multiply::
    ld hl, 0
    ld a, [wArithmeticVariable]
    ld d, a
    ld a, [wArithmeticVariable+1]
    ld e, a
    ld a, [wArithmeticModifier]

WhileMultiplier:
    cp a, 0
    jp z, WhileMultiplier.end

    add hl, de
    dec a
    jp WhileMultiplier
.end
    ld a, h
    ld [wArithmeticResult], a
    ld a, l
    ld [wArithmeticResult+1], a

    ret
    
; saves wArithmeticVariable
; function divides numbers (SHOULD work for any numbers)
; the divident goes into [wArithmeticVariable] (higher bits go first, max 2 bytes)
; the divisor goes into [wArithmeticModifier]
; the quotient will be in [wArithmeticResult] (higher bits go first, max 2 bytes)
; to change limit of bytes for Variable change number of reserved bytes for Variable and Result, 
; change number of repetitions near the end of divide function and clear more result positions
Divide::
    ld a, 0
    ld [wArithmeticResult], a
    ld [wArithmeticResult+1], a
    ; e counts number of passes
    ld e, 0
    ; c is a counter for the amount we currently have
    ; set c to zero
    ld c, 0
    ld d, 0

DivideAfterInit:
    ; set b to highest bit
    ld b, %10000000
    
    ; iterate over bits 
WhileBits:
    ; check if b is equal to zero
    xor a
    cp a, b
    jp z, WhileBits.end

    ; check if bit at position b is on
    ld hl, wArithmeticVariable
    add hl, de
    ld a, [hl]
    and b

    ; skip if it's not
    jp z, WhileBits.noBit

    ; add one to c if it is
    inc c

.noBit:

    ; check if c is large enough
    ; if divisor <= c
    ld a, [wArithmeticModifier]
    ; jump if a > c
    sub a, 1
    cp a, c
    jp nc, WhileBits.notBigger

    ld hl, wArithmeticResult
    add hl, de
    ld a, [hl]
    add a, b
    ld [hl], a
    
    ld a, c
    ld hl, wArithmeticModifier
    sub a, [hl]
    ld c, a
    
.notBigger:

    srl b           ; divide b by 2
    sla c           ; multiply c by 2

    jp WhileBits
.end:
    ; add one to e
    inc e

    ; if 2 > e
    ld a, 1
    cp a, e
    jp nc, DivideAfterInit
    
    ret

; saves wArithmeticVariable
; function bitshifts right (divides by 2^n) numbers (16-bit)
; the number goes into [wArithmeticVariable] (higher bits go first, max 2 bytes)
; the number of shifts goes into [wArithmeticModifier]
; the result will be in [wArithmeticResult] (higher bits go first, max 2 bytes)
BitShiftRight:: 
    xor a
    ld [wArithmeticResult], a
    ld [wArithmeticResult + 1], a

    ld a, [wArithmeticVariable]
    ld b, a
    ld a, [wArithmeticVariable + 1]
    ld c, a

    ld a, [wArithmeticModifier]
    ld d, a

.loop:
    xor a
    cp a, d
    jp z, .loopEnd 

    srl c       ; Divide lower bits by 2
    srl b       ; Divide higher bits by 2, this time caring for the carry
    jp nc, .skipAddingCarry

    ld a, $80   ; Set the mask to %10000000, the carrying bit from the higher byte
    or a, c     ; apply the bit 
    ld c, a     ; move the new value to c

.skipAddingCarry

    dec d
    jp .loop
.loopEnd:

    ld a, b
    ld [wArithmeticResult], a
    ld a, c
    ld [wArithmeticResult + 1], a

    ret

AddNumbersBCD::
    ld d, 0
    ld c, 0                 ; clear carry
    ld e, 3
    
WhileDigits:
    ld hl, wNumberBCD_1      ; get number with offset
    add hl, de
    ld a, [hl]

    ld b, a
    ld a, %00001111
    and a, b                ; get last digit of 1
    ld b, a                 ; copy it

    ld hl, wNumberBCD_2
    add hl, de
    ld a, [hl]

    ld d, b                 ; copy again

    ld b, a
    ld a, %00001111
    and a, b                ; get last digit of 2

    add a, d                ; add 2 digits together
    add a, c                ; add carry
    ld c, 0

    ld d, 0                 ; clear d

    cp a, 10

    jp c, .skipCarry_1

    ld c, %00010000
    sub a, 10

.skipCarry_1:
    ; set output
    ld hl, wNumberBCD_3
    add hl, de
    ld [hl], a


    ld hl, wNumberBCD_1      ; get number with offset
    add hl, de
    ld a, [hl]

    ld b, a
    ld a, %11110000
    and a, b                ; get second last digit of 1
    ld b, a                 ; copy it

    ld hl, wNumberBCD_2      ; get number with offset
    add hl, de
    ld a, [hl]

    ld d, b                 ; copy again

    ld b, a
    ld a, %11110000
    and a, b                ; get second last digit of 2

    ld h, a                 ; save a
    ld a, c                 ; a = c
    ld c, 0                 ; c = 0
    add a, d                ; a = c + d
    ld d, a                 ; d = a
    ld a, h                 ; load a
    
    add a, d                ; add 2 digits together
    jp c, .carry_2          ; a is already -16
    
    ld d, 0                 ; clear d

    cp a, %10100000         ; 10 << 4              
    jp c, .skipCarry_2      ; if a < 10

    sub a, %10100000        ; 10 << 4
    ld c, 1
    jp .skipCarry_2

.carry_2                    ; if a overflown and was -16

    add a, %01100000        ; 6 << 4
    ld c, 1

.skipCarry_2:
    ; set output
    ld hl, wNumberBCD_3
    add hl, de
    ld b, a                 ; save a
    ld a, [hl]              ; load from ram
    or a, b                 ; [hl] or a
    ld [hl], a              ; load back into ram

    ld a, e                 ; check if already looped 4 times
    cp a, 0
    jp z, .end              ; if so end

    dec e
    jp WhileDigits

.end

    ret
    

SECTION "ArithmeticVariables", WRAM0

wArithmeticVariable:: ds 2
wArithmeticResult:: ds 2
wArithmeticModifier:: ds 1
