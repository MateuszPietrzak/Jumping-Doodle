SECTION "MapGeneration", ROM0

; GenerateStripe
; Generates game stripe, using 
; wGeneratePositionY
GenerateStripe::
    ; Calculate where to put the platform x-position capped at 16
    call Rng
    and a, %00000111
    inc a
    ld [wGenerateLinePositionX], a

    xor a
    ld h, a
    ld a, [wGenerateLinePositionY]
    ld l, a

    add hl, hl ; hl*2
    add hl, hl ; hl*4
    add hl, hl ; hl*8
    add hl, hl ; hl*16
    add hl, hl ; hl*32

    push hl

    ld a, h
    add a, $98
    ld h, a
    ; Clear the stripe
    ld a, $14
.clearStripe:
    cp a, $0
    jr z, .clearStripeEnd

    ld [hl], $0
    inc hl
    dec a

    jr .clearStripe
.clearStripeEnd:
    ; free strip check
    pop hl
    ld a, l
    and a, $20
    cp a, $0

    jp nz, .normalGeneration

    ; check if generate powerup
    call Rng
    ; there is 255 - x / 255 chance for the collectible to spawn on each line
    cp a, 230
    jp c, .noPowerUP

    and a, %00001111
    add a, 2
    call GeneratePowerUP

.noPowerUP:

    ret

.normalGeneration:

    xor a    
    ld b, a
    ld a, [wGenerateLinePositionX]
    ld c, a
    add hl, bc
    ld a, h
    add a, $98
    ld h, a

    call GeneratePlatform
    inc hl
    
    ; Randomize offset between them
    call Rng
    and a, %00000111
.offsetLoop:
    cp a, $0
    jr z, .offsetLoopEnd

    dec a
    inc hl

    jr .offsetLoop
.offsetLoopEnd:

    call GeneratePlatform

    ret

; generates powerup
; @param a column of powerup
GeneratePowerUP:
    ; bc = a
    ld c, a
    xor a    
    ld b, a
    add hl, bc  ; hl += a
    ld a, h
    add a, $98  ; hl += $9800 (VRAM location)
    ld h, a
    cp a, $9c
    ret z

    ; set tile to powerup
    ld [hl], $45

    ret

; Generates platofrm
; @param hl place
GeneratePlatform::
    call Rng
    and a, $01
.caseNormal:
    cp a, $0
    jr nz, .caseFragile

    ld [hl], $40
    inc hl
    ld [hl], $41
    inc hl
    ret

.caseFragile:

    ld [hl], $42
    inc hl
    ld [hl], $43
    inc hl
    ret
    