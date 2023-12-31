INCLUDE "include/hardware.inc/hardware.inc"

SECTION "Collision", ROM0

; CheckCollisions
; @param b x pixel position of the sprite
; @param c y pixel position of the sprite
; @return a
; 0 -> no collision
; 1 -> collides with block
; 2 -> collision with powerup
CheckCollisions::
    ; Unscroll
    ld a, [rSCY]
    add a, c

    ld e, a

    ; Dividing by 8 -> tile point * 32 -> Y pos
    and a, %11111000    ; Y / 8 * 8
    ld l, a
    xor a
    ld h, a

    add hl, hl          ; Y / 8 * 16
    add hl, hl          ; Y / 8 * 32
    
    ; Dividing by 8
    ld a, b
    srl a
    srl a
    srl a
    dec a

    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

    ld bc, $9800
    add hl, bc

    ld a, e
    ; Check if mod 8 <= 4
    and a, %00000100
    cp a, $4
    jp nc, .casePowerUP

    ; check platforms only on negative velocity
    ld a, [wPlayerVelocityY]
    and a, $80
    jr nz, .casePowerUP

.caseLeft:
    ld a, [hl]
    cp a, $40
    jr nz, .caseRight

    ld a, $1
    ret

.caseRight:
    ld a, [hl]
    cp a, $41
    jr nz, .caseFloor

    ld a, $1
    ret

.caseFloor:
    ld a, [hl]
    cp a, $44
    jr nz, .caseFragileLeft

    ld a, $1
    ret

.caseFragileLeft:
    ld a, [hl]
    cp a, $42
    jr nz, .caseFragileRight

    ; erase platform
    xor a
    ld [hl], a
    inc hl
    ld [hl], a

    ld a, $1
    ret

.caseFragileRight:
    ld a, [hl]
    cp a, $43
    jr nz, .casePowerUP

    ; erase platform
    xor a
    ld [hl], a
    dec hl
    ld [hl], a

    ld a, $1
    ret

.casePowerUP:
    ld a, [hl]
    cp a, $45
    jr z, .powerUPCollision

    ld a, l
    sub a, $20
    ld l, a

    ld a, [hl]
    cp a, $45
    jr z, .powerUPCollision
    jr .caseEnd
.powerUPCollision:

    ; erase powerup
    ; ld a, $1
    ; ld [rVBK], a
    xor a
    ld [hl], a
    ; ld [rVBK], a
    ; ld [hl], a

    ld a, $2
    ret

.caseEnd:
    ld a, $0

    ret