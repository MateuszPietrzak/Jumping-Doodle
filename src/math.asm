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
    jr nc, Modulo.skipCarry

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
    jr z, WhileMultiplier.end

    add hl, de
    dec a
    jr WhileMultiplier
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
    jr z, WhileBits.end

    ; check if bit at position b is on
    ld hl, wArithmeticVariable
    add hl, de
    ld a, [hl]
    and b

    ; skip if it's not
    jr z, WhileBits.noBit

    ; add one to c if it is
    inc c

.noBit:

    ; check if c is large enough
    ; if divisor <= c
    ld a, [wArithmeticModifier]
    ; jump if a > c
    sub a, 1
    cp a, c
    jr nc, WhileBits.notBigger

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

    jr WhileBits
.end:
    ; add one to e
    inc e

    ; if 2 > e
    ld a, 1
    cp a, e
    jr nc, DivideAfterInit
    
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
    jr z, .loopEnd 

    srl c       ; Divide lower bits by 2
    srl b       ; Divide higher bits by 2, this time caring for the carry
    jr nc, .skipAddingCarry

    ld a, $80   ; Set the mask to %10000000, the carrying bit from the higher byte
    or a, c     ; apply the bit 
    ld c, a     ; move the new value to c

.skipAddingCarry

    dec d
    jr .loop
.loopEnd:

    ld a, b
    ld [wArithmeticResult], a
    ld a, c
    ld [wArithmeticResult + 1], a

    ret

AddNumbersBCD::
    ld d, 0
    ld c, 0                 ; clear carry
    ld e, 7
    
WhileDigits:
    ld hl, wNumberBCD_1      ; get number with offset
    add hl, de
    ld a, [hl]

    ld b, a                 ; make a copy

    ld hl, wNumberBCD_2
    add hl, de
    ld a, [hl]

    add a, b                ; add 2 digits together
    add a, c                ; add carry
    ld c, 0

    cp a, 10

    jr c, .skipCarry_1

    ld c, 1
    sub a, 10

.skipCarry_1:
    ; set output
    ld hl, wNumberBCD_3
    add hl, de
    ld [hl], a

    ld a, e                 ; check if already looped 8 times
    cp a, 0
    jr z, .end              ; if so end

    dec e
    jr WhileDigits

.end

    ret
    
; param @a - value to be inputed to wNumberBCD_2
CharToBCD::
    ld b, 0
    ld c, 0
    ld d, 0

.while100:
    cp a, 100
    jr c, .while10

    inc b
    sub a, 100

    jr .while100
.while10:
    cp a, 10
    jr c, .while1

    inc c
    sub a, 10

    jr .while10
.while1:
    cp a, 1
    jr c, .whileEnd

    inc d
    dec a

    jr .while1
.whileEnd:

    ld a, b
    ld [wNumberBCD_2 + 5], a
    ld a, c
    ld [wNumberBCD_2 + 6], a
    ld a, d
    ld [wNumberBCD_2 + 7], a

    ret

; param @bc BCD1
; param @de BCD2
GreaterBCD::
    ld h, 8

.whileSame
    ld a, [bc]
    ld l, a
    ld a, [de]
    cp a, l
    jr z, .same
    jr c, .firstGreater
    ; second greater
    ld a, 0
    ret

.firstGreater
    ld a, 1
    ret

.same
    dec h
    ld a, h
    cp a, 0
    jr nz, .whileSame

    xor a
    ret


SECTION "ArithmeticVariables", WRAM0

wArithmeticVariable:: ds 2
wArithmeticResult:: ds 2
wArithmeticModifier:: ds 1

SECTION "NumbersBCD", WRAM0

wNumberBCD_1:: ds 8
wNumberBCD_2:: ds 8
wNumberBCD_3:: ds 8

SECTION "ScoreSection", WRAM0

wScoreToAdd:: ds 1
