SECTION "Arithmetic", ROM0

; function calculating modulo (SHOULD be working)
; the divident goes into [arithmeticVariable] (higher bits go first, max 2 bytes)
; the divisor goes into [arithmeticModifier]
; the quotient will be in [arithmeticResult] (higher bits go first, max 2 bytes)
modulo:

    call divide

    ; save variable for later
    ld a, [arithmeticVariable]
    ld b, a
    ld a, [arithmeticVariable+1]
    ld c, a

    ; move division result as a new variable
    ld a, [arithmeticResult]
    ld [arithmeticVariable], a
    ld a, [arithmeticResult+1]
    ld [arithmeticVariable+1], a

    call multiply

    ; load multiplication result
    ld a, [arithmeticResult]
    ld h, a
    ld a, [arithmeticResult+1]
    ld l, a

    ; sub bc, hl
    ld a, c
    sub a, l
    ld c, a
    jp nc, modulo.skipCarry

    dec b

.skipCarry:

    ld a, b
    sub a, h
    ld b, a

    ld a, b
    ld [arithmeticResult], a
    ld a, c
    ld [arithmeticResult+1], a

    ret

; function calculating multily (SHOULD be working)
; the multiplicand goes into [arithmeticVariable] (higher bits go first, max 2 bytes)
; the multiplier goes into [arithmeticModifier]
; the product will be in [arithmeticResult] (higher bits go first, max 2 bytes)
multiply:
    ld hl, 0
    ld a, [arithmeticVariable]
    ld d, a
    ld a, [arithmeticVariable+1]
    ld e, a
    ld a, [arithmeticModifier]

whileMultiplier:
    cp a, 0
    jp z, whileMultiplier.end

    add hl, de
    dec a
    jp whileMultiplier
.end
    ld a, h
    ld [arithmeticResult], a
    ld a, l
    ld [arithmeticResult+1], a

    ret
    
; function divides numbers (SHOULD work for any numbers)
; the divident goes into [arithmeticVariable] (higher bits go first, max 2 bytes)
; the divisor goes into [arithmeticModifier]
; the quotient will be in [arithmeticResult] (higher bits go first, max 2 bytes)
; to change limit of bytes for Variable change number of reserved bytes for Variable and Result, 
; change number of repetitions near the end of divide function and clear more result positions
divide:
    ld a, 0
    ld [arithmeticResult], a
    ld [arithmeticResult+1], a
    ; e counts number of passes
    ld e, 0
    ; c is a counter for the amount we currently have
    ; set c to zero
    ld c, 0
    ld d, 0

divideAfterInit:
    ; set b to highest bit
    ld b, %10000000
    
    ; iterate over bits 
whileBits:
    ; check if b is equal to zero
    xor a
    cp a, b
    jp z, whileBits.end

    ; check if bit at position b is on
    ld hl, arithmeticVariable
    add hl, de
    ld a, [hl]
    and b

    ; skip if it's not
    jp z, whileBits.noBit

    ; add one to c if it is
    inc c

.noBit:

    ; check if c is large enough
    ; if divisor <= c
    ld a, [arithmeticModifier]
    ; jump if a > c
    sub a, 1
    cp a, c
    jp nc, whileBits.notBigger

    ld hl, arithmeticResult
    add hl, de
    ld a, [hl]
    add a, b
    ld [hl], a
    
    ld a, c
    ld hl, arithmeticModifier
    sub a, [hl]
    ld c, a
    
.notBigger:

    srl b           ; divide b by 2
    sla c           ; multiply c by 2

    jp whileBits
.end:
    ; add one to e
    inc e

    ; if 2 > e
    ld a, 1
    cp a, e
    jp nc, divideAfterInit
    
    ret


SECTION "ArithmeticVariables", WRAM0

    arithmeticVariable: ds 2
    arithmeticResult: ds 2
    arithmeticModifier: ds 1