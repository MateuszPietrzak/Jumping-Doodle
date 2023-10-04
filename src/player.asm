INCLUDE "include/hardware.inc/hardware.inc"

SECTION "Player", ROM0

InitPlayer::
    ; Load player sprite into tiles
    ld de, GraphicTiles
    ld hl, _VRAM8000
    ld bc, GraphicTilesEnd - GraphicTiles
    call Memcpy
    ret

ResetPlayerState:: 

    call WaitForVBlank
    call LoadGameBackground

    ; Init position (which is in form pixels * 16)
    ; Position X
    ld a, $05
    ld [wPlayerX], a
    ld a, $40
    ld [wPlayerX + 1], a

    ; Position Y
    ld a, $06
    ld [wPlayerY], a
    ld a, $00
    ld [wPlayerY + 1], a
    
    ; Init velocity
    ld a, $00
    ld [wPlayerVelocityX], a
    ld a, $00
    ld [wPlayerVelocityY], a

    ; Init screen Y scroll
    xor a
    ld [wScreenScrollY], a
    ld [wScreenScrollY + 1], a
    ld [rSCY], a

    ; Clear player flags
    xor a
    ld [wPlayerFlags], a
    ld [wBounceFlag], a

    ret

HandlePlayer::

    ld a, [wPlayerVelocityY]
    and a, $80
    jp nz, .endBounce

    push af
    push bc
    push de
    push hl

    ; Check if colliding with anything
    ; X coordinate
    ld a, [wActualX]
    ld b, a

    ; Y coordinate
    ld a, [wActualY]
    sub a, $8
    ld c, a

    call CheckCollisions
    cp a, $1
    jp z, .bounce
    
    ; X coordinate
    ld a, [wActualX]
    add a, $8
    ld b, a

    ; Y coordinate
    ld a, [wActualY]
    sub a, $8
    ld c, a

    call CheckCollisions
    cp a, $1
    jp z, .bounce

    jp .skipBounce

.bounce:
    ld a, $1
    ld [wBounceFlag], a

    ; TODO PLAY BOING!

.skipBounce:

    pop hl
    pop de
    pop bc
    pop af
.endBounce:

    ; Fall
    ld a, [wPlayerVelocityY]
    and a, $7F ; Strip off the sign bit
    cp a, $40
    jp nc, .skipAcceleratingDown

    ld a, [wPlayerVelocityY]
    and a, $80 ; Get the sign bit
    jp z, .incAccelerate

    ld a, [wPlayerVelocityY]
    and a, $7F ; Strip off the sign bit
    dec a
    jp z, .skipAcceleratingDown ; Don't put the sign bit back on if a = 0    
    or a, $80
    jp .skipAcceleratingDown

.incAccelerate:
    ld a, [wPlayerVelocityY]
    inc a
.skipAcceleratingDown:
    ld [wPlayerVelocityY], a

    ; Default to not moving
    ; ld a, $00 
    ; ld [wPlayerVelocityX], a

    ; Check for d-pad right
    ld a, [wKeysPressed]
    ld b, PADF_RIGHT
    and a, b

    jp z, .pressedRightEnd
.pressedRight:
    ld a, $10
    ld [wPlayerVelocityX], a
    ; Since going right, flip the sprite right 
    xor a
    ld [wPlayerFlags], a

.pressedRightEnd:

    ; Check for d-pad left
    ld a, [wKeysPressed]
    ld b, PADF_LEFT
    and a, b

    jp z, .pressedLeftEnd
.pressedLeft:
    ld a, $90 
    ld [wPlayerVelocityX], a
    ; Since going left, flip the sprite left
    ld a, $20
    ld [wPlayerFlags], a

.pressedLeftEnd:

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

.incPlayerX:
    ld a, 0
    cp a, d
    jp z, .incPlayerXend

    inc bc ; Increment x position by 1/16 of a pixel
    ld a, b
    cp a, $0A
    jp c, .noPlusTorus
    ld a, c
    cp a, $80
    jp c, .noPlusTorus

    ld h, $F5
    ld l, $7F
    add hl, bc
    ld b, h
    ld c, l
    jp .incPlayerXend


.noPlusTorus
    dec d
    jp .incPlayerX
.incPlayerXend:

    jp .decPlayerXend ; Skip decrementing

.decPlayerXstart:

    ; Decrement PlayerX
    xor a, d
    ld d, a

.decPlayerX:
    ld a, 0
    cp a, d
    jp z, .incPlayerXend

    dec bc ; Decrement x position by 1/16 of a pixel
    ld a, b
    or a, c
    jp nz, .noMinusTorus

    ld h, $0A
    ld l, $80
    add hl, bc
    ld b, h
    ld c, l
    jp .decPlayerXend

.noMinusTorus
    dec d
    jp .decPlayerX
.decPlayerXend:

    ld a, b
    ld [wPlayerX], a
    ld a, c
    ld [wPlayerX + 1], a


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

    ld a, b
    cp a, $08
    jp nz, .skipNoFall
    ld a, c
    cp a, $10
    jp c, .skipNoFall

    ; When dies, set isAlive to 0
    xor a
    ld [wIsAlive], a
    ret

.skipNoFall:
    inc bc ; Increment y position by 1/16 of a pixel
    dec d
    jp .incPlayerY
.incPlayerYend:

    ld a, [wBounceFlag]
    cp a, $1
    jp nz, .noUpdateBounce

    xor a
    ld [wBounceFlag], a
    ld a, $A0 
    ld [wPlayerVelocityY], a

.noUpdateBounce

    jp .decPlayerYend ; Skip decrementing

.decPlayerYstart:

    ; Decrement PlayerY
    xor a, d
    ld d, a
.decPlayerY:
    ld a, 0
    cp a, d
    jp z, .incPlayerYend

    ld a, b
    cp a, $06
    jp nc, .skipNoRise
    ld a, c
    cp a, $00
    jp z, .skipNoRise

    ld a, [wScreenScrollY]
    ld h, a
    ld a, [wScreenScrollY+1]
    ld l, a
    dec hl
    ld a, h
    ld [wScreenScrollY], a
    ld a, l
    ld [wScreenScrollY+1], a

    jp .skipDecY

.skipNoRise:
    dec bc ; Decrement y position by 1/16 of a pixel
.skipDecY:
    dec d
    jp .decPlayerY
.decPlayerYend:

    ld a, b
    ld [wPlayerY], a
    ld a, c
    ld [wPlayerY + 1], a

    ; --------------------- ;
    ; Setup for BufferToOAM ;
    ; --------------------- ;

    ; ScreenScrollY
    ld a, [wScreenScrollY]
    ld [wArithmeticVariable], a
    ld a, [wScreenScrollY + 1]
    ld [wArithmeticVariable + 1], a
    ld a, 4
    ld [wArithmeticModifier], a

    ; Get pixel position from PlayerScrollY
    call BitShiftRight

    ; Move bg to correct position (only lower byte needed since coords <= 255)
    ld a, [wArithmeticResult + 1]
    ld [wActualSCY], a
    
    ; Player's on-screen position

    ld a, [wPlayerX]
    ld b, a
    ld a, [wPlayerX+1]
    ld c, a

    ; Setup PlayerX for division
    ld a, b
    ld [wArithmeticVariable], a
    ld a, c
    ld [wArithmeticVariable + 1], a
    ld a, 4
    ld [wArithmeticModifier], a

    ; Get pixel on-screen position from PlayerX
    call BitShiftRight

    ; Move sprite to correct position (only lower byte needed since coords <= 255)
    ld a, [wArithmeticResult + 1]
    ld [wActualX], a

    ld a, [wPlayerY]
    ld b, a
    ld a, [wPlayerY+1]
    ld c, a

    ; Setup PlayerY for division
    ld a, b
    ld [wArithmeticVariable], a
    ld a, c
    ld [wArithmeticVariable + 1], a
    ld a, 4
    ld [wArithmeticModifier], a

    ; Get pixel on-screen position from PlayerY
    call BitShiftRight

    ; Move sprite to correct position (only lower byte needed since coords <= 255)
    ld a, [wArithmeticResult + 1]
    ld [wActualY], a

    ret

PlayerBufferToOAM::


    ; Flip sprite
    ld a, [wPlayerFlags]
    ld [_OAMRAM + 3], a

    ; Move bg to correct position
    ld a, [wActualSCY]
    ld [rSCY], a

    ; X position
    ld a, [wActualX]
    ld [_OAMRAM + 1], a

    ; Y position
    ld a, [wActualY]
    ld [_OAMRAM], a

    
    ret

SECTION "PlayerData", WRAM0

wPlayerX:: ds 2
wPlayerY:: ds 2
wPlayerFlags:: ds 1

wPlayerVelocityX:: ds 1
wPlayerVelocityY:: ds 1

wScreenScrollY:: ds 2
wBounceFlag:: ds 1

wActualSCY:: ds 1
wActualX:: ds 1
wActualY:: ds 1