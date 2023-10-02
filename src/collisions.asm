INCLUDE "include/hardware.inc/hardware.inc"

SECTION "Collision", ROM0

; CheckCollisions
; @param b x pixel position of the sprite
; @param c y pixel position of the sprite
; @return a == 1 when collides, 0 otherwise
CheckCollisions::
    ; Unscroll
    ld a, [rSCY]
    add a, c

    ld d, a
    ;Check if mod 8 <= 4

    and a, %00000110
    jp nz, .caseEnd
    
    ld a, d

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


.caseLeft:
    ld a, [hl]
    cp a, $41
    jp nz, .caseRight

    jp .caseTrue

.caseRight:
    ld a, [hl]
    cp a, $42
    jp nz, .caseEnd

.caseTrue:
    ld a, $1
    ret

.caseEnd:
    ld a, $0

    ret