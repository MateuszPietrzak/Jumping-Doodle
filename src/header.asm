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
    ld [wNumberBCD_1], a
    ld [wNumberBCD_1+1], a
    ld [wNumberBCD_1+2], a
    ld [wNumberBCD_1+3], a
    
    ld [wNumberBCD_2], a
    ld [wNumberBCD_2+1], a
    ld [wNumberBCD_2+2], a
    ld a, 1
    ld [wNumberBCD_2+3], a

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

    ld a, [wNumberBCD_3]
    ld [wNumberBCD_1], a

    ld a, [wNumberBCD_3+1]
    ld [wNumberBCD_1+1], a

    ld a, [wNumberBCD_3+2]
    ld [wNumberBCD_1+2], a

    ld a, [wNumberBCD_3+3]
    ld [wNumberBCD_1+3], a

    ; --------------------------------------------------

    ; Update player inputs
    call UpdateKeys

    jp MainLoop
