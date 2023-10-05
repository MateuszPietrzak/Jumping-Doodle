INCLUDE "include/hardware.inc/hardware.inc"

SECTION "stategame", ROM0

StateGame::
    ; All initialization neede before a game is tarted, shuch as resetting player, should go here

    call ResetPlayerState
    call WaitForVBlank
    call HandlePlayer

    ld a, $1
    ld [wIsAlive], a
GameLoop:
    call WaitForVBlank

    ; TO DO WHILE VBLANK
    ; Set bg and window layers palette
    ld a, %11100100
    ld [rBGP], a

    call PlayerBufferToOAM

    ld bc, 8
    ld hl, $9c00 + $20 + $7              ; load second line
    ld de, wWindowTilemapCopy + 32 + 7
    call Memcpy

    call HandlePlayerVBlank
    ; TO DO WHILE VBLANK END

    ; play music
    ; RIGHT AFTER ALL MEMCOPY

    call PlayMusic

    call HandlePlayer

    ld a, [wScoreToAdd]         ; number of subpixels that screen was lowered
    cp a, 0
    jp z, .skipScoreChange      ; don't change score if it wasn't modified

    call CharToBCD              ; convert a to BCD_2
    call AddNumbersBCD          ; add BCD_1 and BCD_2

    ; copy result to score
    FOR N, 8
        ld a, [wNumberBCD_3 + N]
        ld [wNumberBCD_1 + N], a
    ENDR

    ; Write number and increment it
    ld bc, wWindowTilemapCopy + 7 + 32 + 7 ; tilemap address
    ld hl, wNumberBCD_1
    call WriteBCDToWindow

.skipScoreChange
    ; Update player inputs
    call UpdateKeys

    ld a, [wIsAlive]
    cp a, $0
    jp z, GameFinish

.waitForPaletteSwap:
    ld a, [rLY]
    cp $78
    jp c, .waitForPaletteSwap

    ; Set bg and window layers palette
    ld a, %00011011
    ld [rBGP], a

    jp GameLoop

GameFinish::
    ; Everything to do after dying, for example saving score

    ret

SECTION "gamedata", WRAM0

wIsAlive:: ds 1