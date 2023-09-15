INCLUDE "include/hardware.inc/hardware.inc"

SECTION "entry", ROM0[$100]
  jp EntryPoint 
  ds $150-@, 0 ; Space for the header

EntryPoint:

    call WaitForVBlank

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

    ld a, %11100100
    ld [rOBP0], a

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

    xor a
    ld [wFrameCounter], a

    call UpdateKeys

    ; Rotate sprite
    ld a, [_OAMRAM + 2]
    inc a
    cp a, 4
    jp c, skipRotationModulo
    ld a, 0
skipRotationModulo:
    ld [_OAMRAM + 2], a

    jp MainLoop 

Memcpy:
    ld a, [de]
    ld [hl+], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, Memcpy
    ret

WaitForVBlank:
    ld a, [rLY]
    cp 144
    jp c, WaitForVBlank
    ret

ClearOam:
    xor a
    ld b, $A0
    ld hl, _OAMRAM
.clearOamLoop:
    ld [hl+], a
    dec b
    jp nz, ClearOam.clearOamLoop
    ret

UpdateKeys:
    ld a, P1F_GET_BTN
    ldh [rP1], a

    call PollKeys

    or a, $F0
    ld b, a

    ld a, P1F_GET_DPAD
    ldh [rP1], a

    call PollKeys

    or a, $F0
    swap a
    xor a, b
    

    ld [wKeysPressed], a

    ld a, P1F_GET_NONE
    ldh [rP1], a

    ret

PollKeys:
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ret

SECTION "graphics", ROM0
graphicTiles:
    incbin "assets/PlayerSprite.2bpp"
.end:

SECTION "variables", wram0

wFrameCounter: db
wKeysPressed: db