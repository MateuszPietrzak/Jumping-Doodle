INCLUDE "include/hardware.inc/hardware.inc"
INCLUDE "include/utility.asm"

SECTION "entry", ROM0[$100]
  jp EntryPoint 
  ds $150-@, 0 ; Space for the header

EntryPoint:
    ; turn on volume
	ld a, %00000001
	ld [rNR52], a

	; turn on all mixing
	ld a, %11111111
	ld [rNR51], a

	; turn on everything
	ld a, %11111111
	ld [rNR50], a

    call WaitForVBlank

    ;Disable LCD before writing to VRAM
    xor a
    ld [rLCDC], a

    ld de, graphicTiles
    ld hl, _VRAM8000
    ld bc, graphicTiles.end - graphicTiles
    call Memcpy

    call ClearOam
    ld hl, _OAMRAM
    ld a, 40+16
    ld [hl+], a         ; Y       _OAMRAM + 0
    ld a, 16+8 
    ld [hl+], a         ; X       _OAMRAM + 1
    xor a
    ld [hl+], a         ; TILE ID _OAMRAM + 2
    ld [hl+], a         ; FLAGS   _OAMRAM + 3

    ld a, LCDCF_ON | LCDCF_OBJON
    ld [rLCDC], a

    ; Load palette for sprites
    ld a, %11100100
    ld [rOBP0], a

    ; Reset frame counter
    xor a
    ld [wFrameCounter], a

MainLoop:
    call WaitForVBlank

    ; Frame counter
    ld a, [wFrameCounter]
    inc a
    ld [wFrameCounter], a
    cp a,15
    jp nz, MainLoop

    ; Reset frame counter
    xor a
    ld [wFrameCounter], a

    ; Update player inputs
    call UpdateKeys


    ; Test movement
    ld a, [wKeysPressed]
    and PADF_RIGHT
    jp z, MainLoop
    ld a, [_OAMRAM + 1]
    inc a
    ld [_OAMRAM+1], a

    jp MainLoop 