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

    ; ---------------------------------------------------------------------------
    ; PRE MAIN TESTING GORUNDS

    xor a
FOR N, 8
    ld [wNumberBCD_1 + N], a
    ld [wNumberBCD_2 + N], a
ENDR
    
    ld a, 1
    ld [wNumberBCD_2 + 7], a

    ; END
    ; ---------------------------------------------------------------------------

    ; Load palette for sprites
    ld a, %11100100
    ld [rOBP0], a

    ; Reset frame counter
    xor a
    ld [wFrameCounter], a

MainLoop:
    call WaitForVBlank

    ld bc, 11
    ld hl, $9c00
    ld de, wWindowTilemapCopy
    call Memcpy

    call HandlePlayer

    ; --------------------------------------------------
    ; Write number and increment it
    ld bc, wWindowTilemapCopy + 10 ; tilemap address
    call WriteBCDToWindow

    call AddNumbersBCD

FOR N, 8
    ld a, [wNumberBCD_3 + N]
    ld [wNumberBCD_1 + N], a
ENDR

    ; --------------------------------------------------

    ; Update player inputs
    call UpdateKeys

    jp MainLoop
