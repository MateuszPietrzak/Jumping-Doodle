INCLUDE "include/hardware.inc/hardware.inc"

SECTION "Music", ROM0

InitMusic::
    ; set starting points for each channel
    ld hl, Channel_1
    ld a, h
    ld [wPositionChannel_1], a
    ld a, l
    ld [wPositionChannel_1 + 1], a

    ld hl, Channel_2
    ld a, h
    ld [wPositionChannel_2], a
    ld a, l
    ld [wPositionChannel_2 + 1], a

    ld hl, Channel_3
    ld a, h
    ld [wPositionChannel_3], a
    ld a, l
    ld [wPositionChannel_3 + 1], a

    ld hl, Channel_4
    ld a, h
    ld [wPositionChannel_4], a
    ld a, l
    ld [wPositionChannel_4 + 1], a

    ; turn on all channels
    ld a, 1
    ld [wOnChannel_1], a
    ld [wOnChannel_2], a
    ld [wOnChannel_3], a
    ld [wOnChannel_4], a

    ; turn the music on
    ld a, %10000000
    ld [rNR52], a

    ; mix every channel into every output
    ld a, $FF
    ld [rNR51], a

    ; max out the volume and give output on both
    ld a, $FF
    ld [rNR50], a

    ; max out channels volumes
    ld a, %11111000
    ld [rNR12], a
    ld [rNR22], a
    ld [rNR42], a

    ld a, %10000000
    ld [rNR32], a

    ret

PlayMusic::

    ld a, [wOnChannel_1]
    cp a, 0
    jp z, .channel_1_off
    call PlayChannel_1

.channel_1_off

    ld a, [wOnChannel_1]
    cp a, 0
    jp z, .channel_2_off
    call PlayChannel_2

.channel_2_off

    ld a, [wOnChannel_1]
    cp a, 0
    jp z, .channel_3_off
    call PlayChannel_3

.channel_3_off

    ld a, [wOnChannel_1]
    cp a, 0
    jp z, .channel_4_off
    call PlayChannel_4

.channel_4_off
    ret

; --------------------------------------------------------------------------------------------------------
SECTION "EngineChannel1", ROM0

PlayChannel_1:
    ; load position into hl
    ld a, [wPositionChannel_1]
    ld h, a
    ld a, [wPositionChannel_1 + 1]
    ld l, a

    ld a, [hl+]
    
    ; check which command it is
.case01: ; Play note
    cp a, $01
    jp nz, .caseA1
    ; Do stuff here
    ld a, [hl+] ; load note length

    ; TODO actually make it work
    ; set note length
    ld [wNoteFrameChannel_1], a

    ld a, [hl+] ; load volume and sweep

    ; set volume and sweep
    ld [rNR12], a

    ld a, [hl+] ; frequency lower
    ld c, a
    ld a, [hl+] ; frequency higher
    ld d, a

    ; set frequency
    ld a, c
    ld [rNR13], a
    ld a, d
    or a, %1000000 ; trigger channel
    ld [rNR14], a

    jp .endSwitch
.caseA1: ; Vibrato
    cp a, $A1
    jp nz, .caseEE
    ; Do stuff here
    jp .endSwitch
.caseEE: ; Loop
    cp a, $EE
    jp nz, .caseFF
    ; Do stuff here
    jp .endSwitch
.caseFF: ; music end command
    cp a, $FF
    jp nz, .endSwitch

    xor a
    ld [wOnChannel_1], a            ; turn off channel in music engine
    ld [rNR12], a                   ; set volume to 0

    ; rewind the music to the start
    ld hl, Channel_1
    ld a, h
    ld [wPositionChannel_1], a
    ld a, l
    ld [wPositionChannel_1 + 1], a

.endSwitch:

    ret

; --------------------------------------------------------------------------------------------------------
SECTION "EngineChannel2", ROM0

PlayChannel_2:
    ; load position into hl
    ld a, [wPositionChannel_2]
    ld h, a
    ld a, [wPositionChannel_2 + 1]
    ld l, a

    ld a, [hl+]
    
    ; check which command it is
.case01: ; Play note
    cp a, $01
    jp nz, .caseA1
    ; Do stuff here
    jp .endSwitch
.caseA1: ; Vibrato
    cp a, $A1
    jp nz, .caseEE
    ; Do stuff here
    jp .endSwitch
.caseEE: ; Loop
    cp a, $EE
    jp nz, .caseFF
    ; Do stuff here
    jp .endSwitch
.caseFF: ; music end command
    cp a, $FF
    jp nz, .endSwitch

    xor a
    ld [wOnChannel_2], a            ; turn off channel in music engine
    ld [rNR22], a                   ; set volume to 0

    ; rewind the music to the start
    ld hl, Channel_2
    ld a, h
    ld [wPositionChannel_2], a
    ld a, l
    ld [wPositionChannel_2 + 1], a

.endSwitch:

    ret

; --------------------------------------------------------------------------------------------------------
SECTION "EngineChannel3", ROM0

PlayChannel_3:
    ; load position into hl
    ld a, [wPositionChannel_3]
    ld h, a
    ld a, [wPositionChannel_3 + 1]
    ld l, a

    ld a, [hl+]
    
    ; check which command it is
.case01: ; Play note
    cp a, $01
    jp nz, .caseA1
    ; Do stuff here
    jp .endSwitch
.caseA1: ; Vibrato
    cp a, $A1
    jp nz, .caseEE
    ; Do stuff here
    jp .endSwitch
.caseEE: ; Loop
    cp a, $EE
    jp nz, .caseFF
    ; Do stuff here
    jp .endSwitch
.caseFF: ; music end command
    cp a, $FF
    jp nz, .endSwitch

    xor a
    ld [wOnChannel_3], a            ; turn off channel in music engine
    ld [rNR30], a                   ; set volume to 0

    ; rewind the music to the start
    ld hl, Channel_3
    ld a, h
    ld [wPositionChannel_3], a
    ld a, l
    ld [wPositionChannel_3 + 1], a

.endSwitch:

    ret

; --------------------------------------------------------------------------------------------------------
SECTION "EngineChannel4", ROM0

PlayChannel_4:
    ; load position into hl
    ld a, [wPositionChannel_1]
    ld h, a
    ld a, [wPositionChannel_1 + 1]
    ld l, a

    ld a, [hl+]
    
    ; check which command it is
.case01: ; Play note
    cp a, $01
    jp nz, .caseA1
    ; Do stuff here
    jp .endSwitch
.caseA1: ; Vibrato
    cp a, $A1
    jp nz, .caseEE
    ; Do stuff here
    jp .endSwitch
.caseEE: ; Loop
    cp a, $EE
    jp nz, .caseFF
    ; Do stuff here
    jp .endSwitch
.caseFF: ; music end command
    cp a, $FF
    jp nz, .endSwitch

    xor a
    ld [wOnChannel_1], a            ; turn off channel in music engine
    ld [rNR42], a                   ; set volume to 0

    ; rewind the music to the start
    ld hl, Channel_4
    ld a, h
    ld [wPositionChannel_4], a
    ld a, l
    ld [wPositionChannel_4 + 1], a

.endSwitch:

    ret

; sets vibrato on channel 1
; vibrato - a
SetVibratoChannel_1:
    ld b, a
    and a, %00000011
    ld [wVibratoChannel_1 + 3], a

    ld a, b
    and a, %00001100
    srl a
    srl a
    ld [wVibratoChannel_1 + 2], a

    ld a, b
    and a, %00110000
    srl a
    srl a
    srl a
    srl a
    ld [wVibratoChannel_1 + 1], a

    ld a, b
    and a, %11000000
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    ld [wVibratoChannel_1 + 0], a

    ret
; sets vibrato on channel 2
; vibrato - a
SetVibratoChannel_2:
    ld b, a
    and a, %00000011
    ld [wVibratoChannel_2 + 3], a

    ld a, b
    and a, %00001100
    srl a
    srl a
    ld [wVibratoChannel_2 + 2], a

    ld a, b
    and a, %00110000
    srl a
    srl a
    srl a
    srl a
    ld [wVibratoChannel_2 + 1], a

    ld a, b
    and a, %11000000
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    ld [wVibratoChannel_2 + 0], a

    ret



SECTION "MusicVariables", WRAM0

wOnChannel_1: ds 1               ; is channel 1 on
wOnChannel_2: ds 1               ; is channel 2 on
wOnChannel_3: ds 1               ; is channel 3 on
wOnChannel_4: ds 1               ; is channel 4 on
wPositionChannel_1: ds 2         ; pointer to current command in channel 1
wPositionChannel_2: ds 2         ; pointer to current command in channel 2
wPositionChannel_3: ds 2         ; pointer to current command in channel 3
wPositionChannel_4: ds 2         ; pointer to current command in channel 4
wNoteFrameChannel_1: ds 1        ; number of frames of last note 1
wNoteFrameChannel_2: ds 1        ; number of frames of last note 2
wNoteFrameChannel_3: ds 1        ; number of frames of last note 3
wNoteFrameChannel_4: ds 1        ; number of frames of last note 4
wLoopTimesChannel_1: ds 1        ; number times to loop back 1
wLoopTimesChannel_2: ds 1        ; number times to loop back 2
wLoopTimesChannel_3: ds 1        ; number times to loop back 3
wLoopTimesChannel_4: ds 1        ; number times to loop back 4
wVibratoChannel_1: ds 4          ; vibrato cycle of channel 1
wVibratoChannel_2: ds 4          ; vibrato cycle of channel 2
wVibratoFrameCounter: ds 1       ; place in vibrato cycle

SECTION "MusicSheets", ROM0

/*
MUSIC SHEET GUIDE:

commands: (1st byte)
    01 - play note
        1. number of frames to be played
        2. volume and sweep control
        3. note frequency lower
        4. note frequency higher
        (low frequency = 0 will not play sound and just pause)
    A1 - set vibrato
        1. 4 sets of 2 bits for duty cycle
    EE - loop
        1. address to loop back to (high)
        2. address to loop back to (low)
        3. number of times ; TODO set this to one higher then check for 1 (leave 0 to be no loop)
    FF - end of music
*/

Channel_1:
    db $01, $FF, $F0, $A4, $04
    db $FF

Channel_2:
    db $FF

Channel_3:
    db $FF

Channel_4:
    db $FF