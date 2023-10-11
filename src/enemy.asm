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
    ld a, $20
    ld [wActualEnemyX], a
    ld [wActualEnemyY], a
    ld [wActualEnemyYScrolled], a

    xor a
    ld [wAnimationFrame], a
    ld [wAnimationCountdwn], a

    ret

HandleEnemyVBlank::
    ret

HandleEnemy::

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

    ld a, [wActualEnemyX]
    inc a
    ld b, a
    and a, %11110000
    cp a, $B0
    jp nz, .noResetPosLeft
.resetPosLeft:
    ld a, b
    ld a, $0
    sub a, $10
    ld [wActualEnemyX], a

    ld a, [rSCY]
    ld b, a
    call Rng
    and a, %11100000
    add a, b 
    ld [wActualEnemyY], a

    jp .noGoDown
.noResetPosLeft:
    ld a, b

    ld [wActualEnemyX], a


    call Rng
    and a, %00000111
    jp nz, .noGoDown

    ld a, [wActualEnemyY]
    inc a
    ld [wActualEnemyY], a
.noGoDown:

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

    ; Progress animation
    ld a, [wAnimationFrame]
    add a, $2
    and a, %00000011
    ld [wAnimationFrame], a

    xor a
    ld [wAnimationCountdwn], a

.skipAnimationProgress:

    ret

EnemyBufferToOAM::
    ; Y Postition
    ld a, [wActualEnemyYScrolled]
    ld [_OAMRAM + 4], a
    ld [_OAMRAM + 8], a

    ; X Position
    ld a, [wActualEnemyX]
    ld [_OAMRAM + 5], a
    add a, $8
    ld [_OAMRAM + 9], a

    ; Animation frames
    ld a, [wAnimationFrame]
    add a, $1
    ld [_OAMRAM + 6], a
    inc a
    ld [_OAMRAM + 10], a
    ret

SECTION "EnemyTiles", ROM0

EnemyTiles:
   incbin "assets/Fly.2bpp"
.end:

SECTION "EnemyData", WRAM0

wActualEnemyX:: ds 1
wActualEnemyY:: ds 1
wActualEnemyYScrolled:: ds 1
wAnimationFrame:: ds 1
wAnimationCountdwn:: ds 1