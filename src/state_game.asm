INCLUDE "include/hardware.inc/hardware.inc"

SECTION "stategame", ROM0

StateGame::
    ; All initialization neede before a game is tarted, shuch as resetting player, should go here

    call ResetPlayerState
    call HandlePlayer
GameLoop:
    call WaitForVBlank

    ; TO DO WHILE VBLANK
    call PlayerBufferToOAM

    ld bc, 32
    ld hl, $9c20                ; load second line
    ld de, wWindowTilemapCopy + 32
    call Memcpy
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

    jp GameLoop

GameFinish::
    ; Everything to do after dying, for example saving score

    jp StateMenu