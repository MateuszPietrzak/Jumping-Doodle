INCLUDE "include/hardware.inc/hardware.inc"

SECTION "entry", ROM0[$100]
  jp EntryPoint 
  ds $150-@, 0 ; Space for the header

EntryPoint::
    call WaitForVBlank

    ;Disable LCD before writing to VRAM
    xor a
    ld [rLCDC], a

    ; initialize window position and contents
    call InitializeWindow
    
    ; initialize player
    call ClearOam
    call InitPlayer

    ; turn on the LCD
    ld a, [rLCDC]
    or a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a
    ; palette
    ld a, %11100100
    ld [rBGP], a


    ; turn on window displaying
    call SwitchWindow

    xor a
    ld [rNR52], a

    ; initialize sound
    call InitMusic

    ; clear wNumberBCD 
    ; TODO maybe move to standalone function
    xor a
FOR N, 8
    ld [wNumberBCD_1 + N], a
    ld [wNumberBCD_2 + N], a
ENDR
    
    ld a, 1
    ld [wNumberBCD_2 + 7], a

    ; Load palette for sprites
    ld a, %11100100
    ld [rOBP0], a

    ; Reset frame counter
    xor a
    ld [wFrameCounter], a

    ld hl, ScoreText
    ld de, wWindowTilemapCopy + 32 + 1
    call WriteTextToWindow

; -------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------
; Main loop
    ; call HandlePlayer
MainLoop:
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

    ; call HandlePlayer

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

    jp MainLoop
