INCLUDE "include/hardware.inc/hardware.inc"

SECTION "stateinit", ROM0

; THIS IS WHERE MOST OF THE GAME INITIALIZATION SHOULD GO
; This subroutine is only called once, when the game boots
; This subroutine should never be called outside "header.asm" file

StateInit::
    call WaitForVBlank

    ;Disable LCD before writing to VRAM
    xor a
    ld [rLCDC], a

    ; initialize window position and contents
    call InitializeWindow
    
    ; initialize player
    call ClearOam
    call InitPlayer
    call InitEnemy
    call LoadScores

    ; turn on the LCD
    ld a, [rLCDC]
    or a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    ; Set bg and window layers palette
    ld a, %11100100
    ld [rBGP], a

    ; Load palette for sprites
    ld a, %11100100
    ld [rOBP0], a

    ; turn on window displaying
    call SwitchWindow

    xor a
    ld [rNR52], a
    ld [rSCY], a

    ; initialize sound
    call InitMusic

    ; Enable timer
    ld a, %00000100
    ld [rTAC], a

    ; After initialization, the game should enter the main menu
    call StateMenu

    ; In practice the program counter should never reach this place, but returning to EntryPoint just in case
    ret