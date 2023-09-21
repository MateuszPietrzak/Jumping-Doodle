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
    ld a, $00
    ld [wPlayerVelocityX], a
    ld a, $00
    ld [wPlayerVelocityY], a

    ret

HandlePlayer::

    ; Check for d-pad right
    ld a, [wKeysPressed]
    ld b, PADF_RIGHT
    and a, b

    jp z, .pressedRightEnd
.pressedRight:
   ld a, $08 
   ld [wPlayerVelocityX], a
.pressedRightEnd:

    ; Check for d-pad right
    ld a, [wKeysPressed]
    ld b, PADF_LEFT
    and a, b

    jp z, .pressedLeftEnd
.pressedLeft:
   ld a, $88 
   ld [wPlayerVelocityX], a
.pressedLeftEnd:

    ; Check for B
    ld a, [wKeysPressed]
    ld b, PADF_B
    and a, b

    jp z, .pressedBeeEnd
.pressedBee:
   ld a, $88 
   ld [wPlayerVelocityY], a
.pressedBeeEnd:

    ; Update position

    ; X COORDINATE

    ; Read PlayerX
    ld a, [wPlayerX] 
    ld b, a ; High byte
    ld a, [wPlayerX + 1] 
    ld c, a ; Low byte

    ; If the highest bit of the wPlayerVelocityX is 1, the number is negative

    ; Increment PlayerX
    ld a, [wPlayerVelocityX]
    ld d, a

    ; Check the highest bit
    ld a, $80
    and a, d
    jp nz, .decPlayerXstart
    xor a, d
    ld d, a

    ; Since going right, flip the sprite right 
    xor a
    ld [_OAMRAM + 3], a

.incPlayerX:
    ld a, 0
    cp a, d
    jp z, .incPlayerXend

    inc bc ; Increment x position by 1/8 of a pixel
    dec d
    jp .incPlayerX
.incPlayerXend:

    jp .decPlayerXend ; Skip decrementing

.decPlayerXstart:

    ; Decrement PlayerX
    xor a, d
    ld d, a

    ; Since going left, flip the sprite left
    ld a, $20
    ld [_OAMRAM + 3], a

.decPlayerX:
    ld a, 0
    cp a, d
    jp z, .incPlayerXend

    dec bc ; Increment x position by 1/8 of a pixel
    dec d
    jp .decPlayerX
.decPlayerXend:

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

    ; If the highest bit of the wPlayerVelocityY is 1, the number is negative

    ; Increment PlayerY
    ld a, [wPlayerVelocityY]
    ld d, a

    ; Check the highest bit
    ld a, $80
    and a, d
    jp nz, .decPlayerYstart
    xor a, d
    ld d, a

.incPlayerY:
    ld a, 0
    cp a, d
    jp z, .incPlayerYend

    inc bc ; Increment x position by 1/8 of a pixel
    dec d
    jp .incPlayerY
.incPlayerYend:

    jp .decPlayerYend ; Skip decrementing

.decPlayerYstart:

    ; Decrement PlayerY
    xor a, d
    ld d, a
.decPlayerY:
    ld a, 0
    cp a, d
    jp z, .incPlayerYend

    dec bc ; Increment y position by 1/8 of a pixel
    dec d
    jp .decPlayerY
.decPlayerYend:

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