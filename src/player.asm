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
    ld a, 40+16
    ld [hl+], a         ; Y       _OAMRAM + 0
    ld a, 16+8
    ld [hl+], a         ; X       _OAMRAM + 1
    xor a
    ld [hl+], a         ; TILE ID _OAMRAM + 2
    ld [hl+], a         ; FLAGS   _OAMRAM + 3

    ; Init position (which is in form pixels * 16)
    ld a, $01
    ld [wPlayerX], a
    ld a, $C0
    ld [wPlayerX + 1], a

    ret

HandlePlayer::
    ; Update position

    ; Read PlayerX
    ld a, [wPlayerX] 
    ld b, a ; High byte
    ld a, [wPlayerX + 1] 
    ld c, a ; Low byte

    ; Increment PlayerX
    inc bc ; Increment x position by 1/8 of a pixel
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

    ret


SECTION "PlayerData", WRAM0

wPlayerX:: ds 2
wPlayerY:: ds 2
