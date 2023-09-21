INCLUDE "include/hardware.inc/hardware.inc"

SECTION "Player", ROM0

InitPlayer::
    ;; Load player sprite into tiles
    ld de, graphicTiles
    ld hl, _VRAM8000
    ld bc, graphicTiles.end - graphicTiles
    call Memcpy

    ;; OAMRAM handling
    ld hl, _OAMRAM
    ld a, 40+16
    ld [hl+], a         ; Y       _OAMRAM + 0
    ld a, 16+8
    ld [hl+], a         ; X       _OAMRAM + 1
    xor a
    ld [hl+], a         ; TILE ID _OAMRAM + 2
    ld [hl+], a         ; FLAGS   _OAMRAM + 3

    ;; Init position (which is in form pixels * 16)
    ; ld a, 40+16
    ; ld [wArithmeticVariable + 1], a
    ; ld a, 8
    ; ld [wArithmeticModifier], a
    ; call Multiply
    ; ld hl, [wArithmeticResult]
    ; ld ld [wPlayerX], hl


    ret

HandlePlayer::
    ; Test movement
    ld a, [wKeysPressed]
    and PADF_RIGHT
    jp z, .return 
    ld a, [_OAMRAM + 1]
    inc a
    ld [_OAMRAM+1], a

.return

    ret


SECTION "PlayerData", WRAM0

wPlayerX:: ds 2
wPlayerY:: ds 2
