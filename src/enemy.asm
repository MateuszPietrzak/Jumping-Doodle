INCLUDE "include/hardware.inc/hardware.inc"

SECTION "Enemy", ROM0

InitEnemy::
    ld de,EnemyTiles 
    ld hl, _VRAM8000 +  $10
    ld bc, EnemyTiles.end - EnemyTiles 
    call Memcpy
    ret

ResetEnemyState:: 
    call WaitForVBlank
    
    ; Set proper tiles
    ld a, $1
    ld [_OAMRAM + 6], a
    inc a
    ld [_OAMRAM + 10], a

    ; Reset enemy position
    ld a, $A0
    ld [wActualEnemyX], a
    ld [wActualEnemyY], a
    ld [wActualEnemyYScrolled], a

    xor a
    ld [wAnimationFrame], a
    ld [wAnimationCountdwn], a
    ld [wMoveRight], a

    ; Set enemy score requirement
    xor a
    ld [wEnemyPointsThreshold], a
    ld [wEnemyPointsThreshold + 1], a
    ld [wEnemyPointsThreshold + 2], a
    ld [wEnemyPointsThreshold + 3], a
    ; +4 set to $8 below
    ld [wEnemyPointsThreshold + 5], a
    ld [wEnemyPointsThreshold + 6], a
    ld [wEnemyPointsThreshold + 7], a

    ld [wNoEnemyCountdown], a

    ld a, $8
    ld [wEnemyPointsThreshold + 4], a

    ret

HandleEnemyVBlank::
    ret

HandleEnemy::

    ; If below reqiured points, dont spawn
    ld bc, wEnemyPointsThreshold
    ld de, wNumberBCD_1
    call GreaterBCD
    cp a, $0
    ret nz

    ld a, [wNoEnemyCountdown]
    cp a, $0
    jp z, .skipNoEnemy

    dec a
    ld [wNoEnemyCountdown], a

    ld a, [rSCY]
    ld b, a
    xor a
    add a, b
    ld [wActualEnemyY], a
    ret

.skipNoEnemy:

    ; Drunk man movement
    call Rng
    and a, $3

.moveLeft:
    cp a, $0
    jp nz, .moveRight

    ld a, [wActualEnemyX]
    dec a
    ld [wActualEnemyX], a

    jp .moveEnd
.moveRight:
    cp a, $1
    jp nz, .moveUp

    ld a, [wActualEnemyX]
    inc a
    ld [wActualEnemyX], a

    jp .moveEnd
.moveUp:
    cp a, $2
    jp nz, .moveDown

    ld a, [wActualEnemyY]
    dec a
    ld [wActualEnemyY], a

    jp .moveEnd
.moveDown:
    cp a, $3
    jp nz, .moveEnd

    ld a, [wActualEnemyY]
    inc a
    ld [wActualEnemyY], a
.moveEnd:

    ld a, [wActualEnemyY]
    inc a
    ld [wActualEnemyY], a

    ld a, [wMoveRight]
    cp a, $0
    jp z, .moveToLeft
.moveToRight:
    ld a, [wActualEnemyX]
    inc a

    jp .moveToNo
.moveToLeft:
    ld a, [wActualEnemyX]
    dec a

.moveToNo:
    ld [wActualEnemyX], a

    ; Move enemy with screen
    ld a, [rSCY]
    ld b, a
    ld a, [wActualEnemyY]
    sub a, b
    ld [wActualEnemyYScrolled], a

    ld a, [wAnimationCountdwn]
    inc a
    ld [wAnimationCountdwn], a
    cp a, $4
    jp nz, .skipAnimationProgress

    ; If it is off-screen, randomize the position on X
    ld a, [wActualEnemyYScrolled]
    cp a, $90
    jp c, .noResetX

    call SlapTheFly

.noResetX:

     ; If nearing right edge, bounce to the left
     ld a, [wMoveRight]
     cp a, $1
     jp nz, .endRightBounce
 
     ld a, [wActualEnemyX]
     cp a, $90
     jp c, .endRightBounce
 
     sub a, $2
     ld [wActualEnemyX], a
 
     ld a, $0
     ld [wMoveRight], a
     jp .endRightBounce
 
 .endRightBounce:

     ; If nearing left edge, bounce to the right
     ld a, [wMoveRight]
     cp a, $0
     jp nz, .endLeftBounce
 
     ld a, [wActualEnemyX]
     cp a, $10
     jp nc, .endLeftBounce
 
     add a, $2
     ld [wActualEnemyX], a
 
     ld a, $1
     ld [wMoveRight], a
     jp .endLeftBounce
 
 .endLeftBounce:

    ; Progress animation
    ld a, [wAnimationFrame]
    add a, $2
    and a, %00000011
    ld [wAnimationFrame], a

    xor a
    ld [wAnimationCountdwn], a

.skipAnimationProgress:

    ; Collision check with player

    ; Player X
    ld a, [wActualX]
    ld b, a
    ld a, [wActualEnemyX]

    ; enemy x + 12 > player x
    add a, $C
    cp a, b
    jp c, .noCollsion

    ; enemy x + 4 < player x + 8
    sub a, $8
    push af
    ld a, b
    add a, $8
    ld b, a
    pop af
    cp a, b
    jp nc, .noCollsion

    ; Player Y
    ld a, [wActualY]
    ld b, a
    ld a, [wActualEnemyYScrolled]

    ; enemy y + 8 > player y
    add a, $8
    cp a, b
    jp c, .noCollsion

    ; enemy y < player y + 8
    sub a, $8
    push af
    ld a, b
    add a, $8
    ld b, a
    pop af
    cp a, b
    jp nc, .noCollsion

    ld a, [wShieldLength]
    cp a, 0
    jp nz, .destroyShield

    xor a
    ld [wIsAlive], a
    ret

.destroyShield:

    ; destroy shield
    xor a
    ld [wShieldLength], a

    ; respawn the fly
    call SlapTheFly

.noCollsion:

    ret

SlapTheFly::
    call Rng
    and a, %01100000
    add a, %01000000
    ld [wActualEnemyX], a

    ld a, [rSCY]
    ld b, a
    xor a
    add a, b
    ld [wActualEnemyY], a

    call Rng
    ld [wNoEnemyCountdown], a

    ; Move enemy with screen
    ld a, [rSCY]
    ld b, a
    ld a, [wActualEnemyY]
    sub a, b
    ld [wActualEnemyYScrolled], a

    ret

EnemyBufferToOAM::
    ; Y Postition
    ld a, [wActualEnemyYScrolled]
    ld [OAMBuffer + 4], a
    ld [OAMBuffer + 8], a

    ; X Position
    ld a, [wActualEnemyX]
    ld [OAMBuffer + 5], a
    add a, $8
    ld [OAMBuffer + 9], a

    ; Animation frames
    ld a, [wAnimationFrame]
    add a, $1
    ld [OAMBuffer + 6], a
    inc a
    ld [OAMBuffer + 10], a

    ; Change color palette
    ld a, %00000001
    ld [OAMBuffer + 7], a
    ld [OAMBuffer + 11], a
    ret


SECTION "EnemyData", WRAM0

wActualEnemyX:: ds 1
wActualEnemyY:: ds 1
wActualEnemyYScrolled:: ds 1
wAnimationFrame:: ds 1
wAnimationCountdwn:: ds 1
wMoveRight:: ds 1
wEnemyPointsThreshold:: ds 8
wNoEnemyCountdown:: ds 1