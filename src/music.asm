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
    xor a
    ;ld [wOnChannel_1], a
    ;ld [wOnChannel_2], a
    ;ld [wOnChannel_3], a
    ;ld [wOnChannel_4], a

    ; prepare for the first note
    xor a
    ld [wNoteFrameChannel_1], a
    ld [wNoteFrameChannel_2], a
    ld [wNoteFrameChannel_3], a
    ld [wNoteFrameChannel_4], a
    
    ; prepare for the first loop
    xor a
    ld [wLoopTimesChannel_1], a
    ld [wLoopTimesChannel_2], a
    ld [wLoopTimesChannel_3], a
    ld [wLoopTimesChannel_4], a

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

    ld a, %00000000
    ld [rNR32], a
    ld a, %10000000
    ld [rNR30], a

    ret

PlayMusic::

    ld a, [wOnChannel_1]
    cp a, 0
    jp z, .channel_1_off
    call PlayChannel_1

.channel_1_off

    ld a, [wOnChannel_2]
    cp a, 0
    jp z, .channel_2_off
    call PlayChannel_2

.channel_2_off

    ld a, [wOnChannel_3]
    cp a, 0
    jp z, .channel_3_off
    call PlayChannel_3

.channel_3_off

    ld a, [wOnChannel_4]
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

    ld a, [hl+] ; load command (+0)
    
    ; check which command it is
.case01: ; Play note --------------------------------------------
    cp a, NOTE
    jp nz, .caseA1

    ; apply vibrato
    ld a, [wVibratoChannel_1]
    ld b, a
    and a, %1100_0000   ; get only top 2 bits
    ld [rNR11], a
    ld a, b ; load full vibrato
    ; move to next vibrato
    rlca
    rlca
    ld [wVibratoChannel_1], a
    
    ld a, [hl+] ; load note length (+1)
    ld c, a

    ld a, [wNoteFrameChannel_1]
    ld b, a
    xor a
    cp a, b
    ; if var == 0 set note length
    jp z, .initNote
.alreadySet:
    ld a, [wNoteFrameChannel_1]
    dec a
    ld [wNoteFrameChannel_1], a

    cp a, 0             ; if frame == 0
    jp nz, .endSwitch

    ld bc, 3            ; set it to next byte of music sheet
    add hl, bc
    ld a, h
    ld [wPositionChannel_1], a
    ld a, l
    ld [wPositionChannel_1 + 1], a

    jp .endSwitch
.initNote:
    ld a, c                     ; set intital note length
    dec a
    ld [wNoteFrameChannel_1], a

    ld a, [hl+] ; load volume and sweep (+2)

    ; set volume and sweep
    ld [rNR12], a

    ld a, [hl+] ; frequency lower (+3)
    ld c, a
    ld a, [hl+] ; frequency higher (+4)
    ld d, a

    ; set frequency
    ld a, c
    ld [rNR13], a
    ld a, d
    or a, %10000000 ; trigger channel
    ld [rNR14], a

    jp .endSwitch
.caseA1: ; Vibrato -------------------------------------------------
    cp a, VIB
    jp nz, .caseEE

    ld a, [hl+]
    ld [wVibratoChannel_1], a

    ld a, h
    ld [wPositionChannel_1], a
    ld a, l
    ld [wPositionChannel_1 + 1], a

    jp PlayChannel_1
.caseEE: ; Loop -----------------------------------------------------
    cp a, LOP
    jp nz, .caseFF

    ld a, [wLoopTimesChannel_1]
    cp a, 0
    jp z, .initLoop
    ; loop again
    dec a
    ld [wLoopTimesChannel_1], a
    cp a, 0
    jp nz, .noLoopEnd

    ; move sheet pointer after loop command
    ld bc, 3
    add hl, bc
    ld a, h
    ld [wPositionChannel_1], a
    ld a, l
    ld [wPositionChannel_1 + 1], a

    jp PlayChannel_1
.noLoopEnd:
    ld a, [hl+] ; add 1
    ld [wPositionChannel_1 + 1], a
    ld a, [hl+] ; add 2
    ld [wPositionChannel_1], a

    jp PlayChannel_1
.initLoop:
    ld a, [hl+] ; add 1
    ld [wPositionChannel_1 + 1], a
    ld a, [hl+] ; add 2
    ld [wPositionChannel_1], a
    ld a, [hl+] ; times
    dec a ; already did 1 time when coming here
    ld [wLoopTimesChannel_1], a

    jp PlayChannel_1
.caseFF: ; music end command --------------------------------------
    cp a, END
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

    ld a, [hl+] ; load command (+0)
    
    ; check which command it is
.case01: ; Play note --------------------------------------------
    cp a, NOTE
    jp nz, .caseA1

    ; apply vibrato
    ld a, [wVibratoChannel_2]
    ld b, a
    and a, %1100_0000   ; get only top 2 bits
    ld [rNR21], a
    ld a, b ; load full vibrato
    ; move to next vibrato
    rlca
    rlca
    ld [wVibratoChannel_2], a
    
    ld a, [hl+] ; load note length (+1)
    ld c, a

    ld a, [wNoteFrameChannel_2]
    ld b, a
    xor a
    cp a, b
    ; if var == 0 set note length
    jp z, .initNote
.alreadySet:
    ld a, [wNoteFrameChannel_2]
    dec a
    ld [wNoteFrameChannel_2], a

    cp a, 0             ; if frame == 0
    jp nz, .endSwitch

    ld bc, 3            ; set it to next byte of music sheet
    add hl, bc
    ld a, h
    ld [wPositionChannel_2], a
    ld a, l
    ld [wPositionChannel_2 + 1], a

    jp .endSwitch
.initNote:
    ld a, c                     ; set intital note length
    dec a
    ld [wNoteFrameChannel_2], a

    ld a, [hl+] ; load volume and sweep (+2)

    ; set volume and sweep
    ld [rNR22], a

    ld a, [hl+] ; frequency lower (+3)
    ld c, a
    ld a, [hl+] ; frequency higher (+4)
    ld d, a

    ; set frequency
    ld a, c
    ld [rNR23], a
    ld a, d
    or a, %10000000 ; trigger channel
    ld [rNR24], a

    jp .endSwitch
.caseA1: ; Vibrato -------------------------------------------------
    cp a, VIB
    jp nz, .caseEE

    ld a, [hl+]
    ld [wVibratoChannel_2], a

    ld a, h
    ld [wPositionChannel_2], a
    ld a, l
    ld [wPositionChannel_2 + 1], a

    jp PlayChannel_2
.caseEE: ; Loop -----------------------------------------------------
    cp a, LOP
    jp nz, .caseFF

    ld a, [wLoopTimesChannel_2]
    cp a, 0
    jp z, .initLoop
    ; loop again
    dec a
    ld [wLoopTimesChannel_2], a
    cp a, 0
    jp nz, .noLoopEnd

    ; move sheet pointer after loop command
    ld bc, 3
    add hl, bc
    ld a, h
    ld [wPositionChannel_2], a
    ld a, l
    ld [wPositionChannel_2 + 1], a

    jp PlayChannel_2
.noLoopEnd:
    ld a, [hl+] ; add 1
    ld [wPositionChannel_2 + 1], a
    ld a, [hl+] ; add 2
    ld [wPositionChannel_2], a

    jp PlayChannel_2
.initLoop:
    ld a, [hl+] ; add 1
    ld [wPositionChannel_2 + 1], a
    ld a, [hl+] ; add 2
    ld [wPositionChannel_2], a
    ld a, [hl+] ; times
    dec a ; already did 1 time when coming here
    ld [wLoopTimesChannel_2], a

    jp PlayChannel_2
.caseFF: ; music end command --------------------------------------
    cp a, END
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

    ld a, [hl+] ; load command (+0)
    
    ; check which command it is
.case01: ; Play note --------------------------------------------
    cp a, NOTE
    jp nz, .case25
    
    ld a, [hl+] ; load note length (+1)
    ld c, a

    ld a, [wNoteFrameChannel_3]
    ld b, a
    xor a
    cp a, b
    ; if var == 0 set note length
    jp z, .initNote
.alreadySet:
    ld a, [wNoteFrameChannel_3]
    dec a
    ld [wNoteFrameChannel_3], a

    cp a, 0             ; if frame == 0
    jp nz, .endSwitch

    ld bc, 3            ; set it to next byte of music sheet
    add hl, bc
    ld a, h
    ld [wPositionChannel_3], a
    ld a, l
    ld [wPositionChannel_3 + 1], a

    jp .endSwitch
.initNote:
    ld a, c                     ; set intital note length
    dec a
    ld [wNoteFrameChannel_3], a

    ld a, [hl+] ; load volume and sweep (+2)

    ; set volume
    ld [rNR32], a

    ld a, [hl+] ; frequency lower (+3)
    ld c, a
    ld a, [hl+] ; frequency higher (+4)
    ld d, a

    ; set frequency
    ld a, c
    ld [rNR33], a
    ld a, d
    or a, %10000000 ; trigger channel
    ld [rNR34], a

    jp .endSwitch
.case25: ; Set waveform ---------------------------------------------
    cp a, $25
    jp nz, .caseEE
    
    xor a
    ld [rNR30], a ; turn off channel

    ld a, [hl+] ; get waveform pattern
    sla a       ; multiply by 16
    sla a
    sla a
    sla a

    push hl
    
    ld hl, WavePatterns ; get first wave pattern
    ld c, a             ; move to the selected one
    ld b, 0
    add hl, bc
    ld d, h
    ld e, l             ; de = pattern + offset * 16

    ld bc, $10          ; len = 16
    ld hl, _AUD3WAVERAM ; destination
    call Memcpy

    pop hl

    ld a, %10000000     ; turn channel back on
    ld [rNR30], a

    ld a, h
    ld [wPositionChannel_3 + 1], a
    ld a, l
    ld [wPositionChannel_3 + 1], a

    jp PlayChannel_3
.caseEE: ; Loop -----------------------------------------------------
    cp a, LOP
    jp nz, .caseFF

    ld a, [wLoopTimesChannel_3]
    cp a, 0
    jp z, .initLoop
    ; loop again
    dec a
    ld [wLoopTimesChannel_3], a
    cp a, 0
    jp nz, .noLoopEnd

    ; move sheet pointer after loop command
    ld bc, 3
    add hl, bc
    ld a, h
    ld [wPositionChannel_3], a
    ld a, l
    ld [wPositionChannel_3 + 1], a

    jp PlayChannel_2
.noLoopEnd:
    ld a, [hl+] ; add 1
    ld [wPositionChannel_3 + 1], a
    ld a, [hl+] ; add 2
    ld [wPositionChannel_3], a

    jp PlayChannel_3
.initLoop:
    ld a, [hl+] ; add 1
    ld [wPositionChannel_3 + 1], a
    ld a, [hl+] ; add 2
    ld [wPositionChannel_3], a
    ld a, [hl+] ; times
    dec a ; already did 1 time when coming here
    ld [wLoopTimesChannel_3], a

    jp PlayChannel_3
.caseFF: ; music end command --------------------------------------
    cp a, END
    jp nz, .endSwitch

    xor a
    ld [wOnChannel_3], a            ; turn off channel in music engine
    ld [rNR32], a                   ; set volume to 0
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
    ld a, [wPositionChannel_4]
    ld h, a
    ld a, [wPositionChannel_4 + 1]
    ld l, a

    ld a, [hl+] ; load command (+0)
    
    ; check which command it is
.case01: ; Play note --------------------------------------------
    cp a, NOTE
    jp nz, .caseEE
    
    ld a, [hl+] ; load note length (+1)
    ld c, a

    ld a, [wNoteFrameChannel_4]
    ld b, a
    xor a
    cp a, b
    ; if var == 0 set note length
    jp z, .initNote
.alreadySet:
    ld a, [wNoteFrameChannel_4]
    dec a
    ld [wNoteFrameChannel_4], a

    cp a, 0             ; if frame == 0
    jp nz, .endSwitch

    ld bc, 3            ; set it to next byte of music sheet
    add hl, bc
    ld a, h
    ld [wPositionChannel_4], a
    ld a, l
    ld [wPositionChannel_4 + 1], a

    jp .endSwitch
.initNote:
    ld a, c                     ; set intital note length
    dec a
    ld [wNoteFrameChannel_4], a

    ld a, [hl+] ; load volume and sweep (+2)

    ; set volume and sweep
    ld [rNR42], a

    ld a, [hl+] ; frequency lower (+3)
    ld c, a

    ; set frequency
    ld a, c
    ld [rNR43], a
    ld a, %10000000 ; trigger channel
    ld [rNR44], a

    jp .endSwitch
.caseEE: ; Loop -----------------------------------------------------
    cp a, LOP
    jp nz, .caseFF

    ld a, [wLoopTimesChannel_4]
    cp a, 0
    jp z, .initLoop
    ; loop again
    dec a
    ld [wLoopTimesChannel_4], a
    cp a, 0
    jp nz, .noLoopEnd

    ; move sheet pointer after loop command
    ld bc, 3
    add hl, bc
    ld a, h
    ld [wPositionChannel_4], a
    ld a, l
    ld [wPositionChannel_4 + 1], a

    jp PlayChannel_4
.noLoopEnd:
    ld a, [hl+] ; add 1
    ld [wPositionChannel_4 + 1], a
    ld a, [hl+] ; add 2
    ld [wPositionChannel_4], a

    jp PlayChannel_4
.initLoop:
    ld a, [hl+] ; add 1
    ld [wPositionChannel_4 + 1], a
    ld a, [hl+] ; add 2
    ld [wPositionChannel_4], a
    ld a, [hl+] ; times
    dec a ; already did 1 time when coming here
    ld [wLoopTimesChannel_4], a

    jp PlayChannel_4
.caseFF: ; music end command --------------------------------------
    cp a, END
    jp nz, .endSwitch

    xor a
    ld [wOnChannel_4], a            ; turn off channel in music engine
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
wVibratoChannel_1: ds 1          ; vibrato cycle of channel 1
wVibratoChannel_2: ds 1          ; vibrato cycle of channel 2

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

; TODO manage volume
; TODO fix bug with wave ram changing???

Channel_1:
    db VIB, %01010101
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00
.start
    ; P1B1
    db NOTE, NL * 2, VOL_23
    dw A3
    db NOTE, NL * 6, VOL_MUTE
    dw $00
    ; P1B2
    db NOTE, NL * 2, VOL_23
    dw B3
    db NOTE, NL * 6, VOL_MUTE
    dw $00
    ; P1B3
    db NOTE, NL * 2, VOL_23
    dw G3
    db NOTE, NL * 6, VOL_MUTE
    dw $00
    ; P1B4
    db NOTE, NL * 2, VOL_23
    dw C4
    db NOTE, NL * 6, VOL_MUTE
    dw $00

    db LOP
    dw .start
    db $02

    ; P2B1
    db NOTE, NL, VOL_13
    dw A3
    db NOTE, NL, VOL_13
    dw A3
    db NOTE, NL * 2, VOL_MUTE
    dw $00
    db NOTE, NL, VOL_13
    dw B3
    db NOTE, NL, VOL_13
    dw B3
    db NOTE, NL * 2, VOL_MUTE
    dw $00
    ; P2B3
    db NOTE, NL, VOL_13
    dw G3
    db NOTE, NL, VOL_13
    dw G3
    db NOTE, NL * 2, VOL_MUTE
    dw $00
    db NOTE, NL, VOL_13
    dw C4
    db NOTE, NL, VOL_13
    dw C4
    db NOTE, NL * 2, VOL_MUTE
    dw $00

    ; P3B1
    db NOTE, NL * 2, VOL_23
    dw A3
    db NOTE, NL * 6, VOL_MUTE
    dw $00
    ; P3B2
    db NOTE, NL * 2, VOL_23
    dw B3
    db NOTE, NL * 6, VOL_MUTE
    dw $00
    ; P3B3
    db NOTE, NL * 2, VOL_23
    dw G3
    db NOTE, NL * 6, VOL_MUTE
    dw $00
    ; P3B4
    db NOTE, NL * 2, VOL_23
    dw C4
    db NOTE, NL * 6, VOL_MUTE
    dw $00

    ; P4B1
    db NOTE, NL * 8, VOL_MUTE
    dw $00
    ; P4B2
    db NOTE, NL * 8, VOL_MUTE
    dw $00
    ; P4B3
    db NOTE, NL * 8, VOL_MUTE
    dw $00
    ; P4B4
    db NOTE, NL * 8, VOL_MUTE
    dw $00

    db LOP
    dw .start
    db NOTE

    db END

Channel_2:
    db VIB, %01010101
    db NOTE, START_PAUSE, VOL_MUTE 
    dw $00
.start
    ; P1B1
    db NOTE, NL * 2, VOL_MAX
    dw C4
    db NOTE, NL, VOL_23
    dw F3
    db NOTE, NL, VOL_23
    dw A3
    db NOTE, NL, VOL_23
    dw C4
    db NOTE, NL, VOL_23
    dw A3
    db NOTE, NL, VOL_23
    dw C4
    db NOTE, NL, VOL_23
    dw F3
    ; P1B2 -------------
    db NOTE, NL * 2, VOL_MAX
    dw D4
    db NOTE, NL, VOL_23
    dw G3
    db NOTE, NL, VOL_23
    dw B3
    db NOTE, NL, VOL_23
    dw D4
    db NOTE, NL, VOL_23
    dw B3
    db NOTE, NL, VOL_23
    dw D4
    db NOTE, NL, VOL_23
    dw G3
    ; P1B3 -------------
    db NOTE, NL * 2, VOL_MAX
    dw B3
    db NOTE, NL, VOL_23
    dw E3
    db NOTE, NL, VOL_23
    dw G3
    db NOTE, NL, VOL_23
    dw B3
    db NOTE, NL, VOL_23
    dw G3
    db NOTE, NL, VOL_23
    dw B3
    db NOTE, NL, VOL_23
    dw E3
    ; P1B4 -------------
    db NOTE, NL * 2, VOL_MAX
    dw E4
    db NOTE, NL, VOL_23
    dw A3
    db NOTE, NL, VOL_23
    dw C4
    db NOTE, NL, VOL_23
    dw E4
    db NOTE, NL, VOL_23
    dw C4
    db NOTE, NL, VOL_23
    dw E4
    db NOTE, NL, VOL_23
    dw A3
    ; -------------

    db LOP 
    dw .start 
    db $02
    ; --------------------------------------------------
    ; P2B1 -----------
    db NOTE, NL, VOL_13
    dw C4
    db NOTE, NL, VOL_13
    dw C4
    db NOTE, NL, VOL_MUTE
    dw $00
    db NOTE, NL, VOL_MUTE
    dw $00
    db NOTE, NL, VOL_13
    dw D4
    db NOTE, NL, VOL_13
    dw D4
    db NOTE, NL, VOL_MUTE
    dw $00
    db NOTE, NL, VOL_MUTE
    dw $00
    ; P2B2 -----------
    db NOTE, NL, VOL_13
    dw B3
    db NOTE, NL, VOL_13
    dw B3
    db NOTE, NL, VOL_MUTE
    dw $00
    db NOTE, NL, VOL_MUTE
    dw $00
    db NOTE, NL, VOL_13
    dw E4
    db NOTE, NL, VOL_13
    dw E4
    db NOTE, NL, VOL_MUTE
    dw $00
    db NOTE, NL, VOL_MUTE
    dw $00
    ; --------------------------------------------
    ; P3B1
    db NOTE, NL * 2, VOL_23
    dw C4
    db NOTE, NL, VOL_23
    dw F3
    db NOTE, NL, VOL_23
    dw A3
    db NOTE, NL, VOL_23
    dw C4
    db NOTE, NL, VOL_23
    dw A3
    db NOTE, NL, VOL_23
    dw C4
    db NOTE, NL, VOL_23
    dw F3
    ; P3B2 -------------
    db NOTE, NL * 2, VOL_MAX
    dw D4
    db NOTE, NL, VOL_23
    dw G3
    db NOTE, NL, VOL_23
    dw B3
    db NOTE, NL, VOL_23
    dw D4
    db NOTE, NL, VOL_23
    dw B3
    db NOTE, NL, VOL_23
    dw D4
    db NOTE, NL, VOL_23
    dw G3
    ; P3B3 -------------
    db NOTE, NL * 2, VOL_MAX
    dw B3
    db NOTE, NL, VOL_23
    dw E3
    db NOTE, NL, VOL_23
    dw G3
    db NOTE, NL, VOL_23
    dw B3
    db NOTE, NL, VOL_23
    dw G3
    db NOTE, NL, VOL_23
    dw B3
    db NOTE, NL, VOL_23
    dw E3
    ; P3B4 -------------
    db NOTE, NL * 2, VOL_MAX
    dw E4
    db NOTE, NL, VOL_23
    dw A3
    db NOTE, NL, VOL_23
    dw C4
    db NOTE, NL, VOL_23
    dw E4
    db NOTE, NL, VOL_23
    dw C4
    db NOTE, NL, VOL_23
    dw E4
    db NOTE, NL, VOL_23
    dw A3
    ; -------------
    ; --------------------------------------------------------
    ; P4B1
    db NOTE, NL, VOL_23
    dw A3
    db NOTE, NL, VOL_23
    dw F3
    db NOTE, NL, VOL_23
    dw D3
    db NOTE, NL, VOL_23
    dw F3
    db NOTE, NL, VOL_23
    dw A3
    db NOTE, NL, VOL_23
    dw F3
    db NOTE, NL, VOL_23
    dw A3
    db NOTE, NL, VOL_23
    dw D3
    ; P4B2 -------------
    db NOTE, NL, VOL_23
    dw B3
    db NOTE, NL, VOL_23
    dw G3
    db NOTE, NL, VOL_23
    dw E3
    db NOTE, NL, VOL_23
    dw G3
    db NOTE, NL, VOL_23
    dw B3
    db NOTE, NL, VOL_23
    dw G3
    db NOTE, NL, VOL_23
    dw B3
    db NOTE, NL, VOL_23
    dw E3
    ; P4B3 -------------
    db NOTE, NL, VOL_23
    dw G3
    db NOTE, NL, VOL_23
    dw E3
    db NOTE, NL, VOL_23
    dw C3
    db NOTE, NL, VOL_23
    dw E3
    db NOTE, NL, VOL_23
    dw G3
    db NOTE, NL, VOL_23
    dw E3
    db NOTE, NL, VOL_23
    dw G3
    db NOTE, NL, VOL_23
    dw C3
    ; P4B4 -------------
    db NOTE, NL, VOL_23
    dw C4
    db NOTE, NL, VOL_23
    dw A3
    db NOTE, NL, VOL_23
    dw F3
    db NOTE, NL, VOL_23
    dw A3
    db NOTE, NL, VOL_23
    dw C4
    db NOTE, NL, VOL_23
    dw A3
    db NOTE, NL, VOL_23
    dw C4
    db NOTE, NL, VOL_23
    dw F3
    ; -------------

    db LOP 
    dw .start 
    db NOTE

    db END

Channel_3:
    db $25, $00
    db NOTE, START_PAUSE, VOL3_MUTE 
    dw $00
.start
    ; P1B1
    db NOTE, NL * 2, VOL3_12
    dw F4
    db NOTE, NL * 6, VOL3_MUTE
    dw $00
    ; P1B2
    db NOTE, NL * 2, VOL3_12
    dw G4
    db NOTE, NL * 6, VOL3_MUTE
    dw $00
    ; P1B3
    db NOTE, NL * 2, VOL3_12
    dw E4
    db NOTE, NL * 6, VOL3_MUTE
    dw $00
    ; P1B4
    db NOTE, NL * 2, VOL3_12
    dw A4
    db NOTE, NL * 6, VOL3_MUTE
    dw $00

    db LOP
    dw .start
    db $02

    ; P2B1
    db NOTE, NL, VOL3_12
    dw F4
    db NOTE, NL, VOL3_12
    dw F4
    db NOTE, NL * 2, VOL3_MUTE
    dw $00
    ; P2B2
    db NOTE, NL, VOL3_12
    dw G4
    db NOTE, NL, VOL3_12
    dw G4
    db NOTE, NL * 2, VOL3_MUTE
    dw $00
    ; P2B3
    db NOTE, NL, VOL3_12
    dw E4
    db NOTE, NL, VOL3_12
    dw E4
    db NOTE, NL * 2, VOL3_MUTE
    dw $00
    ; P2B4
    db NOTE, NL, VOL3_12
    dw A4
    db NOTE, NL, VOL3_12
    dw A4
    db NOTE, NL * 2, VOL3_MUTE
    dw $00

    ; P3B1
    db NOTE, NL * 2, VOL3_12
    dw F4
    db NOTE, NL * 6, VOL3_MUTE
    dw $00
    ; P3B2
    db NOTE, NL * 2, VOL3_12
    dw G4
    db NOTE, NL * 6, VOL3_MUTE
    dw $00
    ; P3B3
    db NOTE, NL * 2, VOL3_12
    dw E4
    db NOTE, NL * 6, VOL3_MUTE
    dw $00
    ; P3B4
    db NOTE, NL * 2, VOL3_12
    dw A4
    db NOTE, NL * 6, VOL3_MUTE
    dw $00

    ; P4B1
    db NOTE, NL * 8, VOL3_MUTE
    dw $00
    ; P4B2
    db NOTE, NL * 8, VOL3_MUTE
    dw $00
    ; P4B3
    db NOTE, NL * 8, VOL3_MUTE
    dw $00
    ; P4B4
    db NOTE, NL * 8, VOL3_MUTE
    dw $00

    db LOP
    dw .start
    db NOTE

    db END

Channel_4:
    db NOTE, START_PAUSE, $00
    dw $00
.start
    ; P1B1 ----------------
    db NOTE, NL, VOLD_MID_L
    dw dG7s
    db NOTE, NL, VOLD_MUTE
    dw $00
    db NOTE, NL - 2, VOLD_MID_L
    dw dD7
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, hNL, VOLD_MID_S
    dw dG7s
    db NOTE, hNL, VOLD_MUTE
    dw $00
    db NOTE, hNL, VOLD_MID_S
    dw dG8s
    db NOTE, hNL * 3, VOLD_MUTE
    dw $00
    db NOTE, NL, VOLD_MID_L
    dw dD7
    db NOTE, NL, VOLD_MUTE
    dw $00
    
    db LOP
    dw .start
    db $08
    ; --------------------
    ; P2B1-3 -------------
.part21
    db NOTE, NL - 2, VOLD_MAX_S
    dw dG7s
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, NL - 2, VOLD_MAX_S
    dw dD7
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, hNL, VOLD_MAX_S
    dw dG7s
    db NOTE, NL, VOLD_MUTE
    dw $00
    db NOTE, hNL - 2, VOLD_MAX_S
    dw dG8s
    db NOTE, 2, VOLD_MUTE
    dw $00
    
    db LOP
    dw .part21
    db $03

    ; P2B4 ---------------
    db NOTE, NL - 2, VOLD_MAX_S
    dw dG7s
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, NL - 2, VOLD_MAX_S
    dw dD7
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, hNL, VOLD_MAX_S
    dw dG7s
    db NOTE, hNL, VOLD_MUTE
    dw $00
    db NOTE, hNL, VOLD_MAX_S
    dw dG8s
    db NOTE, hNL, VOLD_MUTE
    dw $00
    ; -----------------
    ; P3B1 ------------
.part3
    db NOTE, NL, VOLD_MID_L
    dw dG7s
    db NOTE, NL, VOLD_MUTE
    dw $00
    db NOTE, NL - 2, VOLD_MID_L
    dw dD7
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, hNL, VOLD_MID_S
    dw dG7s
    db NOTE, hNL, VOLD_MUTE
    dw $00
    db NOTE, hNL, VOLD_MID_S
    dw dG8s
    db NOTE, hNL * 3, VOLD_MUTE
    dw $00
    db NOTE, NL, VOLD_MID_L
    dw dD7
    db NOTE, NL, VOLD_MUTE
    dw $00
    
    db LOP
    dw .part3
    db $04
    ; ----------------
    ; P4B1 -----------
.part4
    db NOTE, NL, VOLD_MID_L
    dw dG7s
    db NOTE, NL * 2, VOLD_MUTE
    dw $00
    db NOTE, NL, VOLD_MID_L
    dw dD7
    db NOTE, NL, VOLD_MUTE
    dw $00
    db NOTE, NL - 2, VOLD_MID_S
    dw dD8
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, NL - 2, VOLD_MID_S
    dw dD7
    db NOTE, 2, VOLD_MUTE
    dw $00
    db NOTE, hNL, VOLD_MID_S
    dw dG8s
    db NOTE, hNL, VOLD_MUTE
    dw $00

    db LOP
    dw .part4
    db $04
    ; ---------------

    db LOP
    dw .start
    db NOTE

    db END

SECTION "WavePatterns", ROM0

WavePatterns:
    db $02, $46, $8A, $CE, $FF, $FE, $ED, $DC, $CB, $A9, $87, $65, $44, $33, $22, $11
    db $01, $23, $45, $67, $8A, $CD, $EE, $F7, $7F, $EE, $DC, $A8, $76, $54, $32, $10

SECTION "Notes", ROM0

ChannelNotes:
    DEF C3  EQU 1046
    DEF C3s EQU 1102
    DEF D3  EQU 1155
    DEF D3s EQU 1205
    DEF E3  EQU 1253
    DEF F3  EQU 1297
    DEF F3s EQU 1339
    DEF G3  EQU 1379
    DEF G3s EQU 1417
    DEF A3  EQU 1452
    DEF A3s EQU 1486
    DEF B3  EQU 1517
    DEF C4  EQU 1547
    DEF C4s EQU 1575
    DEF D4  EQU 1602
    DEF D4s EQU 1627
    DEF E4  EQU 1650
    DEF F4  EQU 1673
    DEF F4s EQU 1694
    DEF G4  EQU 1714
    DEF G4s EQU 1732
    DEF A4  EQU 1750
    DEF A4s EQU 1767
    DEF B4  EQU 1783
    DEF C5  EQU 1798
    DEF C5s EQU 1812
    DEF D5  EQU 1825
    DEF D5s EQU 1837
    DEF E5  EQU 1849
    DEF F5  EQU 1860
    DEF F5s EQU 1871
    DEF G5  EQU 1881
    DEF G5s EQU 1890
    DEF A5  EQU 1899
    DEF A5s EQU 1907
    DEF B5  EQU 1915

DrumNotes:
    DEF dB8  EQU $34
    DEF dG8s EQU $35 ;
    DEF dF8  EQU $36 
    DEF dD8  EQU $37 ;
    DEF dC8  EQU $44 

    DEF dG7s EQU $45 ;
    DEF dF7  EQU $46 
    DEF dD7  EQU $47 ;
    DEF dC7  EQU $54 

    DEF dG6s EQU $55 
    DEF dF6  EQU $56 
    DEF dD6  EQU $57 
    DEF dC6  EQU $64 

    DEF dG5s EQU $65
    DEF dF5  EQU $66
    DEF dD5  EQU $67
    DEF dC5  EQU $74

    DEF dG4s EQU $75
    DEF dF4  EQU $76
    DEF dD4  EQU $77
    DEF dC4  EQU $84

    DEF dG3s EQU $85
    DEF dF3  EQU $86
    DEF dD3  EQU $87
    DEF dC3  EQU $94

    DEF dG2s EQU $95
    DEF dF2  EQU $96
    DEF dD2  EQU $97
    DEF dC2  EQU $A4


DEF NOTE            EQU $01
DEF VIB             EQU $A1
DEF LOP             EQU $EE
DEF END             EQU $FF
DEF VOL_MAX         EQU $F8
DEF VOL_23          EQU $A8
DEF VOL_13          EQU $58
DEF VOL_MUTE        EQU $08
DEF VOL3_MAX        EQU $20
DEF VOL3_12         EQU $40
DEF VOL3_14         EQU $60
DEF VOL3_MUTE       EQU $00
DEF VOLD_MAX_S      EQU $F1
DEF VOLD_MAX_L      EQU $F2
DEF VOLD_MID_S      EQU $C1
DEF VOLD_MID_L      EQU $C2
DEF VOLD_MUTE       EQU $00
DEF NL              EQU 12
DEF hNL             EQU 6
DEF START_PAUSE     EQU $30