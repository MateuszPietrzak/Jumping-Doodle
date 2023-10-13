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

    xor a
    ld [wAchievedHighscore], a

    call PowerUpInit

    ; Init position (which is in form pixels * 16)
    ; Position X
    ld a, $05
    ld [wPlayerX], a
    ld a, $40
    ld [wPlayerX + 1], a

    ld a, $54
    ld [wActualX], a

    ; Position Y
    ld a, $06
    ld [wPlayerY], a
    ld a, $00
    ld [wPlayerY + 1], a

    ld a, $60
    ld [wActualY], a
    
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
    ld [wCollisionFlag], a

    ld [wGenerateLine], a
    ld [wGenerateLinePositionX], a
    ld [wGenerateLinePositionY], a

    ld [wJetpackFlags], a

    ret

HandlePlayerVBlank::
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
    ld [wCollisionFlag], a
    
    ; X coordinate
    ld a, [wActualX]
    add a, $8
    ld b, a

    ; Y coordinate
    ld a, [wActualY]
    sub a, $8
    ld c, a

    call CheckCollisions
    ld b, a
    ld a, [wCollisionFlag]
    or a, b
    ld [wCollisionFlag], a

    pop hl
    pop de
    pop bc
    pop af

    ; Generate new line
    ld a, [wGenerateLine]
    cp a, $0
    ret z

    ; Setting the flag back to 0
    xor a
    ld [wGenerateLine], a

    call GenerateStripe

    ret

HandlePlayer::
    ; Fall
    ld a, [wPlayerVelocityY]
    and a, $7F ; Strip off the sign bit
    cp a, $30
    jr nc, .skipAcceleratingDown

    ld a, [wPlayerVelocityY]
    and a, $80 ; Get the sign bit
    jr z, .incAccelerate

    ld a, [wPlayerVelocityY]
    and a, $7F ; Strip off the sign bit
    dec a
    jr z, .skipAcceleratingDown ; Don't put the sign bit back on if a = 0    
    or a, $80
    jr .skipAcceleratingDown

.incAccelerate:
    ld a, [wPlayerVelocityY]
    inc a
.skipAcceleratingDown:
    ld [wPlayerVelocityY], a

    ; cancel dash after time
    ld a, [wDashLength]
    cp a, 0
    jp z, .noDash

    dec a
    ld [wDashLength], a
    cp a, 0
    jp nz, .noDash

    ; change velocity from $20 to $10 ($A0 to $90 for neg)
    ld a, [wPlayerVelocityX]
    xor a, %0011_0000
    ld [wPlayerVelocityX], a

.noDash:

    ; cancel jetpack after time
    ld a, [wJetpackLength]
    cp a, 0
    jp z, .noJetpack

    dec a
    ld [wJetpackLength], a

    ld a, $A0
    ld [wPlayerVelocityY], a

.noJetpack:

    ; Check for d-pad right
    ld a, [wKeysPressed]
    ld b, PADF_RIGHT
    and a, b

    jr z, .pressedRightEnd
.pressedRight:
    ld a, [wDashLength]
    cp a, 0
    jp z, .noDashR

    ld a, [wPlayerVelocityX]
    and a, $80
    ; if dash in the same direction
    jp z, .pressedRightEnd

    ; cancel dash
    xor a
    ld [wDashLength], a
    jp .noDashR

.noDashR:

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

    jr z, .pressedLeftEnd
.pressedLeft:
    ld a, [wDashLength]
    cp a, 0
    jp z, .noDashL

    ld a, [wPlayerVelocityX]
    and a, $80
    ; if dash in the same direction
    jp nz, .pressedLeftEnd

    ; cancel dash
    xor a
    ld [wDashLength], a
    jp .noDashL

.noDashL:

    ld a, $90 
    ld [wPlayerVelocityX], a
    ; Since going left, flip the sprite left
    ld a, $20
    ld [wPlayerFlags], a

.pressedLeftEnd:
    ; cooldown on using powerups
    ld a, [wLastPowerUp]
    cp a, $0
    jp nz, .pressedBEnd
    
    ; Check for A button
    ld a, [wKeysPressed]
    ld b, PADF_A
    and a, b

    jr z, .pressedAEnd
.pressedA:
    ; use second ability
    ld a, 1
    call UseAbility
    jp .pressedAEnd

.pressedAEnd:

    ; Check for B button
    ld a, [wKeysPressed]
    ld b, PADF_B
    and a, b

    jr z, .pressedBEnd
.pressedB:
    ; use first ability
    ld a, 0
    call UseAbility
    jp .pressedBEnd

.pressedBEnd:

    ld a, [wLastPowerUp]
    cp a, $0
    jp z, .skipDecP

    dec a
    ld [wLastPowerUp], a

.skipDecP:

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
    jr nz, .decPlayerXstart
    xor a, d
    ld d, a

.incPlayerX:
    ld a, 0
    cp a, d
    jr z, .incPlayerXend

    inc bc ; Increment x position by 1/16 of a pixel
    ld a, b
    cp a, $0A
    jr c, .noPlusTorus
    ld a, c
    cp a, $80
    jr c, .noPlusTorus

    ld h, $F5
    ld l, $7F
    add hl, bc
    ld b, h
    ld c, l
    jr .incPlayerXend


.noPlusTorus
    dec d
    jr .incPlayerX
.incPlayerXend:

    jr .decPlayerXend ; Skip decrementing

.decPlayerXstart:

    ; Decrement PlayerX
    xor a, d
    ld d, a

.decPlayerX:
    ld a, 0
    cp a, d
    jr z, .incPlayerXend

    dec bc ; Decrement x position by 1/16 of a pixel
    ld a, b
    or a, c
    jr nz, .noMinusTorus

    ld h, $0A
    ld l, $80
    add hl, bc
    ld b, h
    ld c, l
    jr .decPlayerXend

.noMinusTorus
    dec d
    jr .decPlayerX
.decPlayerXend:

    ld a, b
    ld [wPlayerX], a
    ld a, c
    ld [wPlayerX + 1], a


    ; Y COORDINATE
    ; counter for the total bg shift
    ld e, 0

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
    jr nz, .decPlayerYstart
    xor a, d
    ld d, a

.incPlayerY:
    ld a, 0
    cp a, d
    jr z, .incPlayerYend

    ld a, b
    cp a, $08
    jr nz, .skipNoFall
    ld a, c
    cp a, $40
    jr c, .skipNoFall

    ; When dies, set isAlive to 0
    xor a
    ld [wIsAlive], a
    ret

.skipNoFall:
    inc bc ; Increment y position by 1/16 of a pixel
    dec d
    jr .incPlayerY
.incPlayerYend:

    ld a, [wCollisionFlag]
    and a, $1
    cp a, $1
    jr nz, .noUpdateBounce

    ; add vertical velocity
    ld a, [wPowerJump]
    add a, $A2
    ld [wPlayerVelocityY], a

    xor a
    ld [wPowerJump], a

    push bc

    ; PLAY BOING!
    ld bc, JumpSoundChannel_1
    call StartSoundEffect

    pop bc

.noUpdateBounce:
    
    ; check if powerup was picked up
    ld a, [wCollisionFlag]
    and a, $2
    cp a, $2
    jr nz, .noPowerUP

    push bc

    call PickupPowerUP

    pop bc

.noPowerUP:

    ; clear collision flag
    xor a
    ld [wCollisionFlag], a

    jr .decPlayerYend ; Skip decrementing

.decPlayerYstart:

    ; Decrement PlayerY
    xor a, d
    ld d, a
.decPlayerY:
    ld a, 0
    cp a, d
    jr z, .incPlayerYend

    ld a, b
    cp a, $06
    jr nc, .skipNoRise
    ld a, c
    cp a, $00
    jr z, .skipNoRise

    ld a, [wScreenScrollY]
    ld h, a
    ld a, [wScreenScrollY+1]
    ld l, a

    cp a, 0
    jr nz, .skipDecH
    dec h
.skipDecH
    dec l

    inc e          ; add one to movement
    ld a, h
    ld [wScreenScrollY], a
    ld a, l
    ld [wScreenScrollY+1], a

    ; If we have reached new line, generate next obstacle (not always detecting but whatever)
    ld a, l
    and a, %00111111
    cp a, $00
    jr nz, .noGenerateNew

    ld a, $01
    ld [wGenerateLine], a


.noGenerateNew:

    jr .skipDecY

.skipNoRise:
    dec bc ; Decrement y position by 1/16 of a pixel
.skipDecY:
    dec d
    jr .decPlayerY
.decPlayerYend:
    ; I believe this is where decrementing screenScroll ends lol - drabart
    ld a, e
    ld [wScoreToAdd], a

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

    ld a, [wGenerateLine]
    cp a, $00
    jr z, .noGenerateNewSet

    ld a, [wActualSCY]
    srl a
    srl a
    srl a
    dec a
    and a, %00011111
    ; add a, $14
    ; a now contains a position of a line to change
    ld [wGenerateLinePositionY], a


.noGenerateNewSet:
    
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

    ; Check if the player has jetpack, and on which side 
    ; it should be attached

    ld a, [wJetpackLength]
    cp a, $0
    jp z, .noJetpackShown

    ld a, [wPlayerFlags]
    and a, %00100000
    cp a, $0
    jp nz, .jetpackOnTheRight;

.jetpackOnTheLeft:
    ld a, [wActualX]
    sub a, $7

    jp .jetpackShownEnd
.jetpackOnTheRight:
    ld a, [wActualX]
    add a, $7

    jp .jetpackShownEnd
.noJetpackShown:
    xor a
.jetpackShownEnd:
    ld [wJetpackX], a



.jetpackNoBlink:
    ld a, [wJetpackLength]
    and a, $0F
    cp a, $0
    jp nz, .jetpackNoAnimation

    ld a, [wJetpackFlags]
    and a, %00100000
    xor a, %00100000
    ld [wJetpackFlags], a

.jetpackNoAnimation:

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
    ; Also jetpack always on the right position 
    ; (even if off-screen not to branch in VBlank)
    ld [_OAMRAM + 12], a

    ; Jetpack X position
    ld a, [wJetpackX]
    ld [_OAMRAM + 13], a

    ; Jetpack animation
    ld a, [wJetpackFlags]
    ld [_OAMRAM + 15], a
    
    ret

SECTION "PlayerData", WRAM0

wPlayerX:: ds 2
wPlayerY:: ds 2
wPlayerFlags:: ds 1

wPlayerVelocityX:: ds 1
wPlayerVelocityY:: ds 1

wScreenScrollY:: ds 2
wCollisionFlag:: ds 1

wActualSCY:: ds 1
wActualX:: ds 1
wActualY:: ds 1

wJetpackX:: ds 1
wJetpackFlags:: ds 1

wGenerateLine:: ds 1
wGenerateLinePositionX:: ds 1
wGenerateLinePositionY:: ds 1