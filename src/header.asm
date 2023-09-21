INCLUDE "include/hardware.inc/hardware.inc"

SECTION "entry", ROM0[$100]
  jp EntryPoint 
  ds $150-@, 0 ; Space for the header

EntryPoint:
    call WaitForVBlank

    ;Disable LCD before writing to VRAM
    xor a
    ld [rLCDC], a


    call InitializeWindow
    
    call ClearOam
    call InitPlayer

    ld a, [rLCDC]
    or a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    call SwitchWindow

    ; Load palette for sprites
    ld a, %11100100
    ld [rOBP0], a

    ; Reset frame counter
    xor a
    ld [wFrameCounter], a

MainLoop:
    call WaitForVBlank

    ld bc, 10
    ld hl, $9c00
    ld de, WindowTilemapCopy
    call Memcpy

    ld de, $0008
    ld hl, 42069
    call WriteNumberToWindow

    ; Update player inputs
    call UpdateKeys

    call WaitForVBlank

    call HandlePlayer


    jp MainLoop
