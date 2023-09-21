INCLUDE "include/hardware.inc/hardware.inc"
; INCLUDE "include/graphics.asm"
; INCLUDE "include/utility.asm"
; INCLUDE "include/window.asm"

SECTION "entry", ROM0[$100]
  jp EntryPoint 
  ds $150-@, 0 ; Space for the header

EntryPoint:
    call WaitForVBlank

    ;Disable LCD before writing to VRAM
    xor a
    ld [rLCDC], a


    call initializeWindow

    
    call ClearOam
    call InitPlayer

    ld a, [rLCDC]
    or a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    call switchWindow

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

    call HandlePlayer

    jp MainLoop
