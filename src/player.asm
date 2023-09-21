INCLUDE "include/hardware.inc/hardware.inc"

SECTION "Player", ROM0

InitPlayer::
    ; Load player sprite into tiles
    ld de, graphicTiles
    ld hl, _VRAM8000
    ld bc, graphicTiles.end - graphicTiles
    call Memcpy

    ; OAMRAM handling
    ld hl, _OAMRAM
    ld a, 60+16
    ld [hl+], a         ; Y       _OAMRAM + 0
    ld a, 16+8
    ld [hl+], a         ; X       _OAMRAM + 1
    xor a
    ld [hl+], a         ; TILE ID _OAMRAM + 2
    ld [hl+], a         ; FLAGS   _OAMRAM + 3

    ; Init position (which is in form pixels * 16)
    ; Position X
    ld a, $01
    ld [wPlayerX], a
    ld a, $C0
    ld [wPlayerX + 1], a

    ; Position Y
    ld a, $01
    ld [wPlayerY], a
    ld a, $C0
    ld [wPlayerY + 1], a
    
    ; Init velocity
    ld a, 8
    ld [wPlayerVelocityX], a
    ld a, 2
    ld [wPlayerVelocityY], a

    ret

HandlePlayer::
    ; Update position

    ; X COORDINATE

    ; Read PlayerX
    ld a, [wPlayerX] 
    ld b, a ; High byte
    ld a, [wPlayerX + 1] 
    ld c, a ; Low byte

    ; Increment PlayerX
    ld a, [wPlayerVelocityX]
    ld d, a
.incPlayerX:
    ld a, 0
    cp a, d
    jp z, .incPlayerXend

    inc bc ; Increment x position by 1/8 of a pixel
    dec d
    jp .incPlayerX
.incPlayerXend:

    ld a, b
    ld [wPlayerX], a
    ld a, c
    ld [wPlayerX + 1], a

    ; Setup PlayerX for division
    ld a, b
    ld [wArithmeticVariable], a
    ld a, c
    ld [wArithmeticVariable + 1], a
    ld a, 8
    ld [wArithmeticModifier], a

    ; Get pixel on-screen position from PlayerX
    call Divide

    ; Move sprite to correct position (only lower byte needed since coords <= 255)
    ld a, [wArithmeticResult + 1]
    ld [_OAMRAM + 1], a

    ; Y COORDINATE

    ; Read PlayerY
    ld a, [wPlayerY] 
    ld b, a ; High byte
    ld a, [wPlayerY + 1] 
    ld c, a ; Low byte

    ; Increment PlayerY
    ld a, [wPlayerVelocityY]
    ld d, a
.incPlayerY:
    ld a, 0
    cp a, d
    jp z, .incPlayerYend

    inc bc ; Increment x position by 1/8 of a pixel
    dec d
    jp .incPlayerY
.incPlayerYend:

    ld a, b
    ld [wPlayerY], a
    ld a, c
    ld [wPlayerY + 1], a

    ; Setup PlayerY for division
    ld a, b
    ld [wArithmeticVariable], a
    ld a, c
    ld [wArithmeticVariable + 1], a
    ld a, 8
    ld [wArithmeticModifier], a

    ; Get pixel on-screen position from PlayerY
    call Divide

    ; Move sprite to correct position (only lower byte needed since coords <= 255)
    ld a, [wArithmeticResult + 1]
    ld [_OAMRAM], a

    ret


SECTION "PlayerData", WRAM0

wPlayerX:: ds 2
wPlayerY:: ds 2

wPlayerVelocityX:: ds 1
wPlayerVelocityY:: ds 1