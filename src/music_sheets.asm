INCLUDE "include/music_symbols.inc"

SECTION "MusicSheets", ROM0

/*
MUSIC SHEET GUIDE:

NOTES must be at least of length 2 (to not make infinite loop lol)

commands channel 1,2: (1st byte)
    01 - play note
        1. number of frames to be played
        2. volume and sweep control
        3. note frequency lower
        4. note frequency higher
        (volume = 0 will not play sound and just pause)
    A1 - set vibrato
        1. 4 sets of 2 bits for duty cycle
    EE - loop
        1. address to loop back to (high)
        2. address to loop back to (low)
        3. number of times (1 makes infinite loop)
    FF - end of music

commands channel 3: (1st byte)
    01 - play note
        1. number of frames to be played
        2. volume (%0000 %0110 %0100 %0010)
        3. note frequency lower
        4. note frequency higher
        (volume = 0 will not play sound and just pause)
    25 - change wave pattern
        1. wave mode (sth from presets) (turns channel off and on causing an audio pop)
    EE - loop
        1. address to loop back to (high)
        2. address to loop back to (low)
        3. number of times (1 makes infinite loop)
    FF - end of music

commands channel 4: (1st byte)
    01 - play note
        1. number of frames to be played
        2. volume (%0000 %0110 %0100 %0010)
        3. note frequency (%11110111) and mode (%00001000)
        (volume = 0 will not play sound and just pause)
    EE - loop
        1. address to loop back to (high)
        2. address to loop back to (low)
        3. number of times (1 makes infinite loop)
    FF - end of music
*/

MainThemeChannel_1::
    db VIB, %01010101
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00

    db NOTE, NL150, VOL_24
    dw A3
    db NOTE, NL150 * 3, VOL_MUTE
    dw $00
    db NOTE, NL150, VOL_24
    dw G3
    db NOTE, NL150 * 3, VOL_MUTE
    dw $00
.start
    ; P1B1
    db NOTE, NL150, VOL_24
    dw A3
    db NOTE, NL150 * 3, VOL_MUTE
    dw $00
    ; P1B2
    db NOTE, NL150, VOL_24
    dw B3
    db NOTE, NL150 * 3, VOL_MUTE
    dw $00
    ; P1B3
    db NOTE, NL150, VOL_24
    dw G3
    db NOTE, NL150 * 3, VOL_MUTE
    dw $00
    ; P1B4
    db NOTE, NL150, VOL_24
    dw C4
    db NOTE, NL150 * 3, VOL_MUTE
    dw $00

    db LOOP
    dw .start
    db $02

    ; P2B1
    db NOTE, hNL150, VOL_14
    dw A3
    db NOTE, hNL150, VOL_14
    dw A3
    db NOTE, NL150, VOL_MUTE
    dw $00
    db NOTE, hNL150, VOL_14
    dw B3
    db NOTE, hNL150, VOL_14
    dw B3
    db NOTE, NL150, VOL_MUTE
    dw $00
    ; P2B3
    db NOTE, hNL150, VOL_14
    dw G3
    db NOTE, hNL150, VOL_14
    dw G3
    db NOTE, NL150, VOL_MUTE
    dw $00
    db NOTE, hNL150, VOL_14
    dw C4
    db NOTE, hNL150, VOL_14
    dw C4
    db NOTE, NL150, VOL_MUTE
    dw $00

    ; P3B1
    db NOTE, NL150, VOL_24
    dw A3
    db NOTE, NL150 * 3, VOL_MUTE
    dw $00
    ; P3B2
    db NOTE, NL150, VOL_24
    dw B3
    db NOTE, NL150 * 3, VOL_MUTE
    dw $00
    ; P3B3
    db NOTE, NL150, VOL_24
    dw G3
    db NOTE, NL150 * 3, VOL_MUTE
    dw $00
    ; P3B4
    db NOTE, NL150, VOL_24
    dw C4
    db NOTE, NL150 * 3, VOL_MUTE
    dw $00

    ; P4B1
    db NOTE, NL150 * 4, VOL_MUTE
    dw $00
    ; P4B2
    db NOTE, NL150 * 4, VOL_MUTE
    dw $00
    ; P4B3
    db NOTE, NL150 * 4, VOL_MUTE
    dw $00
    ; P4B4
    db NOTE, NL150 * 4, VOL_MUTE
    dw $00

    db LOOP
    dw .start
    db INFINITE

    db END

; TODO fix tempo

MainThemeChannel_2::
    db VIB, %01010101
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00

    ; B1
    db NOTE, NL150, VOL_24
    dw C4
    db NOTE, hNL150, VOL_MUTE
    dw $00
    db NOTE, hNL150, VOL_14
    dw A3
    db NOTE, hNL150, VOL_MUTE
    dw $00
    db NOTE, hNL150, VOL_14
    dw F3
    db NOTE, hNL150, VOL_MUTE
    dw $00
    db NOTE, hNL150, VOL_14
    dw A3
    ; B2
    db NOTE, NL150, VOL_34
    dw B3
    db NOTE, hNL150, VOL_MUTE
    dw $00
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_MUTE
    dw $00
    db NOTE, hNL150, VOL_24
    dw E3
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_24
    dw A3

.start
    ; P1B1
    db NOTE, NL150, VOL_34
    dw C4
    db NOTE, hNL150, VOL_24
    dw F3
    db NOTE, hNL150, VOL_24
    dw A3
    db NOTE, hNL150, VOL_24
    dw C4
    db NOTE, hNL150, VOL_24
    dw A3
    db NOTE, hNL150, VOL_24
    dw C4
    db NOTE, hNL150, VOL_24
    dw F3
    ; P1B2 -------------
    db NOTE, NL150, VOL_34
    dw D4
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_24
    dw B3
    db NOTE, hNL150, VOL_24
    dw D4
    db NOTE, hNL150, VOL_24
    dw B3
    db NOTE, hNL150, VOL_24
    dw D4
    db NOTE, hNL150, VOL_24
    dw G3
    ; P1B3 -------------
    db NOTE, NL150, VOL_34
    dw B3
    db NOTE, hNL150, VOL_24
    dw E3
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_24
    dw B3
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_24
    dw B3
    db NOTE, hNL150, VOL_24
    dw E3
    ; P1B4 -------------
    db NOTE, NL150, VOL_34
    dw E4
    db NOTE, hNL150, VOL_24
    dw A3
    db NOTE, hNL150, VOL_24
    dw C4
    db NOTE, hNL150, VOL_24
    dw E4
    db NOTE, hNL150, VOL_24
    dw C4
    db NOTE, hNL150, VOL_24
    dw E4
    db NOTE, hNL150, VOL_24
    dw A3
    ; -------------

    db LOOP 
    dw .start 
    db $02
    ; --------------------------------------------------
    ; P2B1 -----------
    db NOTE, hNL150, VOL_14
    dw C4
    db NOTE, hNL150, VOL_14
    dw C4
    db NOTE, hNL150, VOL_MUTE
    dw $00
    db NOTE, hNL150, VOL_MUTE
    dw $00
    db NOTE, hNL150, VOL_14
    dw D4
    db NOTE, hNL150, VOL_14
    dw D4
    db NOTE, hNL150, VOL_MUTE
    dw $00
    db NOTE, hNL150, VOL_MUTE
    dw $00
    ; P2B2 -----------
    db NOTE, hNL150, VOL_14
    dw B3
    db NOTE, hNL150, VOL_14
    dw B3
    db NOTE, hNL150, VOL_MUTE
    dw $00
    db NOTE, hNL150, VOL_MUTE
    dw $00
    db NOTE, hNL150, VOL_14
    dw E4
    db NOTE, hNL150, VOL_14
    dw E4
    db NOTE, hNL150, VOL_MUTE
    dw $00
    db NOTE, hNL150, VOL_MUTE
    dw $00
    ; --------------------------------------------
    ; P3B1
    db NOTE, NL150, VOL_24
    dw C4
    db NOTE, hNL150, VOL_24
    dw F3
    db NOTE, hNL150, VOL_24
    dw A3
    db NOTE, hNL150, VOL_24
    dw C4
    db NOTE, hNL150, VOL_24
    dw A3
    db NOTE, hNL150, VOL_24
    dw C4
    db NOTE, hNL150, VOL_24
    dw F3
    ; P3B2 -------------
    db NOTE, NL150, VOL_34
    dw D4
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_24
    dw B3
    db NOTE, hNL150, VOL_24
    dw D4
    db NOTE, hNL150, VOL_24
    dw B3
    db NOTE, hNL150, VOL_24
    dw D4
    db NOTE, hNL150, VOL_24
    dw G3
    ; P3B3 -------------
    db NOTE, NL150, VOL_34
    dw B3
    db NOTE, hNL150, VOL_24
    dw E3
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_24
    dw B3
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_24
    dw B3
    db NOTE, hNL150, VOL_24
    dw E3
    ; P3B4 -------------
    db NOTE, NL150, VOL_34
    dw E4
    db NOTE, hNL150, VOL_24
    dw A3
    db NOTE, hNL150, VOL_24
    dw C4
    db NOTE, hNL150, VOL_24
    dw E4
    db NOTE, hNL150, VOL_24
    dw C4
    db NOTE, hNL150, VOL_24
    dw E4
    db NOTE, hNL150, VOL_24
    dw A3
    ; -------------
    ; --------------------------------------------------------
    ; P4B1
    db NOTE, hNL150, VOL_24
    dw A3
    db NOTE, hNL150, VOL_24
    dw F3
    db NOTE, hNL150, VOL_24
    dw D3
    db NOTE, hNL150, VOL_24
    dw F3
    db NOTE, hNL150, VOL_24
    dw A3
    db NOTE, hNL150, VOL_24
    dw F3
    db NOTE, hNL150, VOL_24
    dw A3
    db NOTE, hNL150, VOL_24
    dw D3
    ; P4B2 -------------
    db NOTE, hNL150, VOL_24
    dw B3
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_24
    dw E3
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_24
    dw B3
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_24
    dw B3
    db NOTE, hNL150, VOL_24
    dw E3
    ; P4B3 -------------
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_24
    dw E3
    db NOTE, hNL150, VOL_24
    dw C3
    db NOTE, hNL150, VOL_24
    dw E3
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_24
    dw E3
    db NOTE, hNL150, VOL_24
    dw G3
    db NOTE, hNL150, VOL_24
    dw C3
    ; P4B4 -------------
    db NOTE, hNL150, VOL_24
    dw C4
    db NOTE, hNL150, VOL_24
    dw A3
    db NOTE, hNL150, VOL_24
    dw F3
    db NOTE, hNL150, VOL_24
    dw A3
    db NOTE, hNL150, VOL_24
    dw C4
    db NOTE, hNL150, VOL_24
    dw A3
    db NOTE, hNL150, VOL_24
    dw C4
    db NOTE, hNL150, VOL_24
    dw F3
    ; -------------

    db LOOP 
    dw .start 
    db INFINITE

    db END

MainThemeChannel_3::
    db $25, $00
    db NOTE, START_PAUSE, VOL3_MUTE 
    dw $00

    db NOTE, NL150, VOL3_12
    dw F4
    db NOTE, NL150 * 3, VOL3_MUTE
    dw $00
    db NOTE, NL150, VOL3_12
    dw E4
    db NOTE, NL150 * 3, VOL3_MUTE
    dw $00
.start
    ; P1B1
    db NOTE, NL150, VOL3_12
    dw F4
    db NOTE, NL150 * 3, VOL3_MUTE
    dw $00
    ; P1B2
    db NOTE, NL150, VOL3_12
    dw G4
    db NOTE, NL150 * 3, VOL3_MUTE
    dw $00
    ; P1B3
    db NOTE, NL150, VOL3_12
    dw E4
    db NOTE, NL150 * 3, VOL3_MUTE
    dw $00
    ; P1B4
    db NOTE, NL150, VOL3_12
    dw A4
    db NOTE, NL150 * 3, VOL3_MUTE
    dw $00

    db LOOP
    dw .start
    db $02

    ; P2B1
    db NOTE, hNL150, VOL3_12
    dw F4
    db NOTE, hNL150, VOL3_12
    dw F4
    db NOTE, NL150, VOL3_MUTE
    dw $00
    ; P2B2
    db NOTE, hNL150, VOL3_12
    dw G4
    db NOTE, hNL150, VOL3_12
    dw G4
    db NOTE, NL150, VOL3_MUTE
    dw $00
    ; P2B3
    db NOTE, hNL150, VOL3_12
    dw E4
    db NOTE, hNL150, VOL3_12
    dw E4
    db NOTE, NL150, VOL3_MUTE
    dw $00
    ; P2B4
    db NOTE, hNL150, VOL3_12
    dw A4
    db NOTE, hNL150, VOL3_12
    dw A4
    db NOTE, NL150, VOL3_MUTE
    dw $00

    ; P3B1
    db NOTE, NL150, VOL3_12
    dw F4
    db NOTE, NL150 * 3, VOL3_MUTE
    dw $00
    ; P3B2
    db NOTE, NL150, VOL3_12
    dw G4
    db NOTE, NL150 * 3, VOL3_MUTE
    dw $00
    ; P3B3
    db NOTE, NL150, VOL3_12
    dw E4
    db NOTE, NL150 * 3, VOL3_MUTE
    dw $00
    ; P3B4
    db NOTE, NL150, VOL3_12
    dw A4
    db NOTE, NL150 * 3, VOL3_MUTE
    dw $00

    ; P4B1
    db NOTE, NL150 * 4, VOL3_MUTE
    dw $00
    ; P4B2
    db NOTE, NL150 * 4, VOL3_MUTE
    dw $00
    ; P4B3
    db NOTE, NL150 * 4, VOL3_MUTE
    dw $00
    ; P4B4
    db NOTE, NL150 * 4, VOL3_MUTE
    dw $00

    db LOOP
    dw .start
    db INFINITE

    db END

MainThemeChannel_4::
    db NOTE, START_PAUSE, $00
    dw $00

    db NOTE, NL150 * 8, VOL_MUTE
    dw $00
.start
    ; P1B1 ----------------
    db NOTE, hNL150, VOLD_MID_L
    dw dG7s
    db NOTE, hNL150, VOLD_MUTE
    dw $00
    db NOTE, hNL150 - 2, VOLD_MID_L
    dw dD7
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, hNL150 / 2, VOLD_MID_S
    dw dG7s
    db NOTE, hNL150 / 2, VOLD_MUTE
    dw $00
    db NOTE, hNL150 / 2, VOLD_MID_S
    dw dG8s
    db NOTE, hNL150 / 2 * 3, VOLD_MUTE
    dw $00
    db NOTE, hNL150, VOLD_MID_L
    dw dD7
    db NOTE, hNL150, VOLD_MUTE
    dw $00
    
    db LOOP
    dw .start
    db $08
    ; --------------------
    ; P2B1-3 -------------
.part21
    db NOTE, hNL150 - 2, VOLD_MAX_S
    dw dG7s
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, hNL150 - 2, VOLD_MAX_S
    dw dD7
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, hNL150 / 2, VOLD_MAX_S
    dw dG7s
    db NOTE, hNL150, VOLD_MUTE
    dw $00
    db NOTE, hNL150 / 2 - 2, VOLD_MAX_S
    dw dG8s
    db NOTE, 2, VOLD_MUTE
    dw $00
    
    db LOOP
    dw .part21
    db $03

    ; P2B4 ---------------
    db NOTE, hNL150 - 2, VOLD_MAX_S
    dw dG7s
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, hNL150 - 2, VOLD_MAX_S
    dw dD7
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, hNL150 / 2, VOLD_MAX_S
    dw dG7s
    db NOTE, hNL150 / 2, VOLD_MUTE
    dw $00
    db NOTE, hNL150 / 2, VOLD_MAX_S
    dw dG8s
    db NOTE, hNL150 / 2, VOLD_MUTE
    dw $00
    ; -----------------
    ; P3B1 ------------
.part3
    db NOTE, hNL150, VOLD_MID_L
    dw dG7s
    db NOTE, hNL150, VOLD_MUTE
    dw $00
    db NOTE, hNL150 - 2, VOLD_MID_L
    dw dD7
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, hNL150 / 2, VOLD_MID_S
    dw dG7s
    db NOTE, hNL150 / 2, VOLD_MUTE
    dw $00
    db NOTE, hNL150 / 2, VOLD_MID_S
    dw dG8s
    db NOTE, hNL150 / 2 * 3, VOLD_MUTE
    dw $00
    db NOTE, hNL150, VOLD_MID_L
    dw dD7
    db NOTE, hNL150, VOLD_MUTE
    dw $00
    
    db LOOP
    dw .part3
    db $04
    ; ----------------
    ; P4B1 -----------
.part4
    db NOTE, hNL150, VOLD_MID_L
    dw dG7s
    db NOTE, NL150, VOLD_MUTE
    dw $00
    db NOTE, hNL150, VOLD_MID_L
    dw dD7
    db NOTE, hNL150, VOLD_MUTE
    dw $00
    db NOTE, hNL150 - 2, VOLD_MID_S
    dw dD8
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, hNL150 - 2, VOLD_MID_S
    dw dD7
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, hNL150 / 2, VOLD_MID_S
    dw dG8s
    db NOTE, hNL150 / 2, VOLD_MUTE
    dw $00

    db LOOP
    dw .part4
    db $04
    ; ---------------

    db LOOP
    dw .start
    db INFINITE

    db END

DeathScreenThemeChannel_1::
    db VIB, %01010101
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00
.start
    db NOTE, NL113, VOL_24F
    dw G3s
    db NOTE, NL113 * 3, VOL_MUTE
    dw $00
    db NOTE, NL113, VOL_24F
    dw C4s
    db NOTE, NL113 * 3, VOL_MUTE
    dw $00
    db NOTE, NL113, VOL_24F
    dw B3
    db NOTE, NL113 * 3, VOL_MUTE
    dw $00

    db LOOP
    dw .start
    db INFINITE

    db END

DeathScreenThemeChannel_2::
    db VIB, %01010101
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00
.start
    db NOTE, NL113, VOL_24F
    dw C3s
    db NOTE, NL113 * 3, VOL_MUTE
    dw $00
    db NOTE, NL113, VOL_24F
    dw F3s
    db NOTE, NL113 * 3, VOL_MUTE
    dw $00
    db NOTE, NL113, VOL_24F
    dw D3s
    db NOTE, NL113 * 3, VOL_MUTE
    dw $00

    db LOOP
    dw .start
    db INFINITE

    db END

DeathScreenThemeChannel_3::
    db $25, $01
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00
.start
    ; B1
    db NOTE, NL113, VOL3_MAX
    dw E2
    db NOTE, hNL113, VOL3_MAX
    dw D2s
    db NOTE, hNL113, VOL3_MUTE
    dw $00
    db NOTE, hNL113-2, VOL3_MAX
    dw C2s
    db NOTE, 2, VOL3_MUTE
    dw $00
    db NOTE, hNL113, VOL3_MAX
    dw C2s
    db NOTE, hNL113, VOL3_MAX
    dw E2
    db NOTE, hNL113, VOL3_MUTE
    dw $00
    ; B2
    db NOTE, NL113, VOL3_MAX
    dw A2
    db NOTE, hNL113, VOL3_MAX
    dw B2
    db NOTE, hNL113, VOL3_MUTE
    dw $00
    db NOTE, hNL113-2, VOL3_MAX
    dw A2
    db NOTE, 2, VOL3_MUTE
    dw $00
    db NOTE, hNL113, VOL3_MAX
    dw A2
    db NOTE, hNL113, VOL3_MAX
    dw F2s
    db NOTE, hNL113, VOL3_MUTE
    dw $00
    ; B3
    db NOTE, NL113, VOL3_MAX
    dw F2s
    db NOTE, hNL113, VOL3_MAX
    dw E2
    db NOTE, hNL113, VOL3_MUTE
    dw $00
    db NOTE, hNL113-2, VOL3_MAX
    dw D2s
    db NOTE, 2, VOL3_MUTE
    dw $00
    db NOTE, hNL113, VOL3_MAX
    dw D2s
    db NOTE, hNL113, VOL3_MUTE
    dw $00
    db NOTE, hNL113, VOL3_MAX
    dw E2

    db LOOP
    dw .start
    db INFINITE

    db END

DeathScreenThemeChannel_4::
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00
.start
    db NOTE, hNL113, VOLD_LOW_S
    dw dG7s
    db NOTE, hNL113, VOLD_LOW_S
    dw dD8
    db NOTE, NL113, VOLD_MUTE
    dw $00
    db NOTE, hNL113, VOLD_LOW_S
    dw dG7s
    db NOTE, hNL113 * 3, VOLD_MUTE
    dw $00

    db LOOP
    dw .start
    db INFINITE

    db END

MenuThemeChannel_1::
    db VIB, %01010101
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00
.start
    ; B1
    db NOTE, NL95 * 2, VOL_14
    dw C4s
    db NOTE, NL95, VOL_MUTE
    dw $00
    db NOTE, NL95, VOL_24
    dw C4s
    db NOTE, hNL95, VOL_24
    dw D4s
    db NOTE, hNL95 + 1, VOL_MUTE
    dw $00
    db NOTE, NL95, VOL_24
    dw F4
    db NOTE, hNL95, VOL_24
    dw A4s
    db NOTE, hNL95 + 1, VOL_MUTE
    dw $00
    db NOTE, NL95, VOL_24
    dw G4s
    ; B2
    db NOTE, NL95 * 2, VOL_14
    dw C5s
    db NOTE, NL95, VOL_MUTE
    dw $00
    db NOTE, NL95, VOL_24
    dw C5s
    db NOTE, hNL95, VOL_24
    dw A4s
    db NOTE, hNL95 + 1, VOL_MUTE
    dw $00
    db NOTE, NL95, VOL_24
    dw G4s
    db NOTE, hNL95, VOL_24
    dw A4s
    db NOTE, hNL95 + 1, VOL_MUTE
    dw $00
    db NOTE, NL95, VOL_24
    dw D4s
    ; B3
    db NOTE, NL95 * 2, VOL_14
    dw A4s
    db NOTE, NL95, VOL_MUTE
    dw $00
    db NOTE, NL95, VOL_24
    dw A4s
    db NOTE, hNL95, VOL_24
    dw G4s
    db NOTE, hNL95 + 1, VOL_MUTE
    dw $00
    db NOTE, NL95, VOL_24
    dw F4
    db NOTE, hNL95, VOL_24
    dw D4s
    db NOTE, hNL95 + 1, VOL_MUTE
    dw $00
    db NOTE, NL95, VOL_24
    dw A4s
    ; B4
    db NOTE, NL95 * 2, VOL_14
    dw F4s
    db NOTE, NL95, VOL_MUTE
    dw $00
    db NOTE, NL95, VOL_24
    dw F4s
    db NOTE, hNL95, VOL_24
    dw G4s
    db NOTE, hNL95 + 1, VOL_MUTE
    dw $00
    db NOTE, NL95, VOL_24
    dw A4s
    db NOTE, hNL95, VOL_24
    dw C5
    db NOTE, hNL95 + 1, VOL_MUTE
    dw $00
    db NOTE, NL95, VOL_24
    dw F4s

    db LOOP
    dw .start
    db INFINITE

    db END

MenuThemeChannel_2::
    db VIB, %01010101
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00
.start
    ; B1
    db NOTE, NL95 * 2, VOL_14
    dw F4
    db NOTE, NL95 * 6, VOL_MUTE
    dw $00
    ; B2
    db NOTE, NL95 * 2, VOL_14
    dw G4s
    db NOTE, NL95 * 6, VOL_MUTE
    dw $00
    ; B3
    db NOTE, NL95 * 2, VOL_14
    dw F4
    db NOTE, NL95 * 6, VOL_MUTE
    dw $00
    ; B4
    db NOTE, NL95 * 2, VOL_14
    dw C4s
    db NOTE, NL95 * 6, VOL_MUTE
    dw $00

    db LOOP
    dw .start
    db INFINITE

    db END

MenuThemeChannel_3::
    db $25, $00
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00
.start
    ; B1
    db NOTE, NL95 * 2, VOL3_12
    dw G4s
    db NOTE, NL95 * 6, VOL3_MUTE
    dw $00
    ; B2
    db NOTE, NL95 * 2, VOL3_12
    dw D4s
    db NOTE, NL95 * 6, VOL3_MUTE
    dw $00
    ; B3
    db NOTE, NL95 * 2, VOL3_12
    dw C4s
    db NOTE, NL95 * 6, VOL3_MUTE
    dw $00
    ; B4
    db NOTE, NL95 * 2, VOL3_12
    dw A4s
    db NOTE, NL95 * 6, VOL3_MUTE
    dw $00

    db LOOP
    dw .start
    db INFINITE

    db END

MenuThemeChannel_4::
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00
.start
    ; B1
    db NOTE, NL95, VOLD_LOW_L
    dw dG7s
    db NOTE, NL95 * 3, VOLD_MUTE
    dw $00
    ; B2
    db NOTE, NL95, VOLD_LOW_L
    dw dD7
    db NOTE, NL95 * 3, VOLD_MUTE
    dw $00

    db LOOP
    dw .start
    db INFINITE

    db END

    
LeaderboardThemeChannel_1::
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00
    
    db NOTE, NL113 * 3 / 4, VOL_14
    dw C4s
    db NOTE, NL113 * 13 / 4, VOL_MUTE
    dw $00
.start
    ; B1
    db NOTE, NL113, VOL_24
    dw E4
    db NOTE, NL113 * 3, VOL_MUTE
    dw $00
    ; B2
    db NOTE, NL113, VOL_24
    dw E4
    db NOTE, NL113 * 3, VOL_MUTE
    dw $00
    ; B3
    db NOTE, NL113, VOL_24
    dw F4
    db NOTE, NL113 * 3, VOL_MUTE
    dw $00
    ; B4
    db NOTE, NL113, VOL_24
    dw G4
    db NOTE, NL113 * 3, VOL_MUTE
    dw $00
    
    db LOOP
    dw .start
    db INFINITE
    
    db END

LeaderboardThemeChannel_2::
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00

    db NOTE, NL113 * 3 / 4, VOL_14
    dw C4s
    db NOTE, hNL113 / 4, VOL_MUTE
    dw $00
    db NOTE, hNL113, VOL_24
    dw C4
    db NOTE, hNL113, VOL_24
    dw D4
    db NOTE, hNL113, VOL_24
    dw E4
    db NOTE, hNL113, VOL_24
    dw F4
    db NOTE, hNL113, VOL_24
    dw G4
    db NOTE, hNL113, VOL_24
    dw E4
.start
    ; B1
    db NOTE, NL113, VOL_24
    dw G4
    db NOTE, hNL113, VOL_MUTE
    dw $00
    db NOTE, hNL113 / 2, VOL_24
    dw C4
    db NOTE, hNL113 / 2, VOL_24
    dw E4
    db NOTE, hNL113 / 2, VOL_24
    dw G4
    db NOTE, hNL113 / 2, VOL_24
    dw E4
    db NOTE, hNL113 / 2, VOL_24
    dw C4
    db NOTE, hNL113 / 2, VOL_MUTE
    dw $00
    db NOTE, hNL113, VOL_24
    dw G4
    db NOTE, hNL113, VOL_24
    dw E4
    ; B2
    db NOTE, NL113, VOL_24
    dw A4
    db NOTE, hNL113, VOL_MUTE
    dw $00
    db NOTE, hNL113 / 2, VOL_24
    dw E4
    db NOTE, hNL113 / 2, VOL_24
    dw A4
    db NOTE, hNL113 / 2, VOL_24
    dw E4
    db NOTE, hNL113 / 2, VOL_24
    dw A4
    db NOTE, hNL113, VOL_MUTE
    dw $00
    db NOTE, hNL113, VOL_24
    dw A4
    db NOTE, hNL113, VOL_24
    dw E4
    ; B3
    db NOTE, NL113, VOL_24
    dw A4
    db NOTE, hNL113 / 2, VOL_MUTE
    dw $00
    db NOTE, hNL113 / 2, VOL_24
    dw C4
    db NOTE, hNL113 / 2, VOL_24
    dw F4
    db NOTE, hNL113 / 2, VOL_24
    dw A4
    db NOTE, hNL113 / 2, VOL_24
    dw C4
    db NOTE, hNL113 / 2, VOL_24
    dw F4
    db NOTE, hNL113 / 2, VOL_24
    dw A4
    db NOTE, hNL113, VOL_MUTE
    dw F4
    db NOTE, hNL113 / 2, VOL_24
    dw G4
    db NOTE, hNL113, VOL_24
    dw A4
    ; B4
    db NOTE, NL113, VOL_24
    dw B4
    db NOTE, hNL113, VOL_MUTE
    dw $00
    db NOTE, hNL113 / 2, VOL_24
    dw B4
    db NOTE, hNL113 / 2, VOL_24
    dw G4
    db NOTE, hNL113 / 2, VOL_24
    dw D4
    db NOTE, hNL113 / 2, VOL_24
    dw B4
    db NOTE, hNL113, VOL_24
    dw G4
    db NOTE, hNL113 - 2, VOL_24
    dw D4
    db NOTE, 2, VOL_MUTE
    dw $00
    db NOTE, hNL113, VOL_MUTE
    dw D4

    db LOOP
    dw .start
    db INFINITE

    db END

LeaderboardThemeChannel_3::
    db $25, $00
    db NOTE, START_PAUSE, VOL3_MUTE 
    dw $00

    db NOTE, NL113 * 3 / 4, VOL3_12
    dw G4s
    db NOTE, NL113 * 13 / 4, VOL3_MUTE
    dw $00
.start
    ; B1
    db NOTE, NL113, VOL3_12
    dw C5
    db NOTE, NL113 * 3, VOL3_MUTE
    dw $00
    ; B2
    db NOTE, NL113, VOL3_12
    dw C5
    db NOTE, NL113 * 3, VOL3_MUTE
    dw $00
    ; B3
    db NOTE, NL113, VOL3_12
    dw C5
    db NOTE, NL113 * 3, VOL3_MUTE
    dw $00
    ; B4
    db NOTE, NL113, VOL3_12
    dw D5
    db NOTE, NL113 * 3, VOL3_MUTE
    dw $00


    db LOOP
    dw .start
    db INFINITE

    db END

LeaderboardThemeChannel_4::
    db NOTE, START_PAUSE, VOLD_MUTE 
    dw $00

    db NOTE, NL113 * 4, VOLD_MUTE 
    dw $00
.start
    db NOTE, hNL113, VOLD_MID_S
    dw dG7s
    db NOTE, hNL113 * 3, VOLD_MUTE 
    dw $00
    db NOTE, hNL113, VOLD_MID_S
    dw dG7s
    db NOTE, hNL113, VOLD_MUTE 
    dw $00
    db NOTE, hNL113 / 2, VOLD_LOW_S
    dw dG7s
    db NOTE, hNL113, VOLD_MUTE 
    dw $00
    db NOTE, hNL113 / 2, VOLD_LOW_L
    dw dG7s
    
    db LOOP
    dw .start
    db INFINITE

    db END


JumpSoundChannel_1::
    db NOTE, 1, VOL_MAX
    dw C5
    db NOTE, 1, VOL_MAX
    dw B4
    db NOTE, 1, VOL_MAX
    dw A4s
    db NOTE, 1, VOL_MAX
    dw A4
    db NOTE, 1, VOL_MAX
    dw A4s
    db NOTE, 1, VOL_MAX
    dw B4
    db NOTE, 1, VOL_MAX
    dw C5
    db NOTE, 1, VOL_MAX
    dw C5s
    db NOTE, 1, VOL_MAX
    dw D5
    db NOTE, 2, VOL_MAX
    dw D5s

    db END

SwitchButtonSoundChannel_1::
    db NOTE, 1, VOL_MAX
    dw D3
    db NOTE, 1, VOL_MAX
    dw D3s
    db NOTE, 1, VOL_MAX
    dw E3
    db NOTE, 1, VOL_MAX
    dw F3
    db NOTE, 1, VOL_MAX
    dw F3s
    db NOTE, 1, VOL_MAX
    dw G3
    db NOTE, 1, VOL_MAX
    dw G3s

    db END

SwitchLetterSoundChannel_1::
    db NOTE, 1, VOL_MAX
    dw C3
    db NOTE, 1, VOL_MAX
    dw C3s
    db NOTE, 1, VOL_MAX
    dw D3

    db END

PowerUPSoundChannel_1::
    db NOTE, 2, VOL_MAX
    dw D5
    db NOTE, 2, VOL_MAX
    dw E5
    db NOTE, 2, VOL_MAX
    dw F5s
    db NOTE, 2, VOL_MAX
    dw D5
    db NOTE, 2, VOL_MAX
    dw E5
    db NOTE, 2, VOL_MAX
    dw F5s
    db NOTE, 2, VOL_MAX
    dw D5
    db NOTE, 2, VOL_MAX
    dw E5
    db NOTE, 2, VOL_MAX
    dw F5s
    db NOTE, 2, VOL_MAX
    dw D5
    db NOTE, 2, VOL_MAX
    dw E5
    db NOTE, 2, VOL_MAX
    dw F5s

    db END
