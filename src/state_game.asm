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

    ; --------------------------------------------------
    ; Write number and increment it
    ld bc, wWindowTilemapCopy + 7 + 32 + 7 ; tilemap address
    call WriteBCDToWindow

    call AddNumbersBCD

FOR N, 8
    ld a, [wNumberBCD_3 + N]
    ld [wNumberBCD_1 + N], a
ENDR

    ; --------------------------------------------------

    ; Update player inputs
    call UpdateKeys

    ld a, [wIsAlive]
    cp a, $0
    jp z, GameFinish

    jp GameLoop

GameFinish::
    ; Everything to do after dying, for example saving score

    ret

SECTION "gamedata", WRAM0

wIsAlive:: ds 1