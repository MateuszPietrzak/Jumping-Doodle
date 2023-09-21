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

    ; Update player inputs
    call UpdateKeys

    ; ld de, $9C08
    ; ld hl, 42069
    ; call WriteNumberToWindow
    ; ld de, $9C28
    ; ld hl, 42069
    ; call WriteNumberToWindow
    ; ld de, $9C48
    ; ld hl, 42069
    ; call WriteNumberToWindow
    ; ld de, $9C68
    ; ld hl, 42069
    ; call WriteNumberToWindow

    call HandlePlayer

    jp MainLoop
