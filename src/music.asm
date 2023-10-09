INCLUDE "include/hardware.inc/hardware.inc"
INCLUDE "include/music_symbols.inc"

SECTION "Music", ROM0

InitMusic::
    ; set starting points for each channel
    
    ld hl, MainThemeChannel_1
    ld a, h
    ld [wPositionChannel_1], a
    ld a, l
    ld [wPositionChannel_1 + 1], a

    ld hl, MainThemeChannel_2
    ld a, h
    ld [wPositionChannel_2], a
    ld a, l
    ld [wPositionChannel_2 + 1], a

    ld hl, MainThemeChannel_3
    ld a, h
    ld [wPositionChannel_3], a
    ld a, l
    ld [wPositionChannel_3 + 1], a
    
    ld hl, MainThemeChannel_4
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

    xor a
    ld [wInterruptChannel_1], a
    ld [wSkipMusicChannel_1], a

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

; TODO make this work with interrupts

SwitchToMainTheme::
    xor a
    ld [wNoteFrameChannel_1], a
    ld [wNoteFrameChannelCopy_1], a
    ld [wNoteFrameChannel_2], a
    ld [wNoteFrameChannel_3], a
    ld [wNoteFrameChannel_4], a
    ld [wLoopTimesChannel_1], a
    ld [wLoopTimesChannel_2], a
    ld [wLoopTimesChannel_3], a
    ld [wLoopTimesChannel_4], a

    ld hl, MainThemeChannel_1
    ld a, h
    ld [wPositionChannel_1], a
    ld [wPositionChannelCopy_1], a
    ld a, l
    ld [wPositionChannel_1 + 1], a
    ld [wPositionChannelCopy_1 + 1], a

    ld hl, MainThemeChannel_2
    ld a, h
    ld [wPositionChannel_2], a
    ld a, l
    ld [wPositionChannel_2 + 1], a

    ld hl, MainThemeChannel_3
    ld a, h
    ld [wPositionChannel_3], a
    ld a, l
    ld [wPositionChannel_3 + 1], a
    
    ld hl, MainThemeChannel_4
    ld a, h
    ld [wPositionChannel_4], a
    ld a, l
    ld [wPositionChannel_4 + 1], a

    ret

SwitchToDeathScreenTheme::
    xor a
    ld [wNoteFrameChannel_1], a
    ld [wNoteFrameChannelCopy_1], a
    ld [wNoteFrameChannel_2], a
    ld [wNoteFrameChannel_3], a
    ld [wNoteFrameChannel_4], a
    ld [wLoopTimesChannel_1], a
    ld [wLoopTimesChannel_2], a
    ld [wLoopTimesChannel_3], a
    ld [wLoopTimesChannel_4], a

    ld hl, DeathScreenThemeChannel_1
    ld a, h
    ld [wPositionChannel_1], a
    ld [wPositionChannelCopy_1], a
    ld a, l
    ld [wPositionChannel_1 + 1], a
    ld [wPositionChannelCopy_1 + 1], a

    ld hl, DeathScreenThemeChannel_2
    ld a, h
    ld [wPositionChannel_2], a
    ld a, l
    ld [wPositionChannel_2 + 1], a

    ld hl, DeathScreenThemeChannel_3
    ld a, h
    ld [wPositionChannel_3], a
    ld a, l
    ld [wPositionChannel_3 + 1], a
    
    ld hl, DeathScreenThemeChannel_4
    ld a, h
    ld [wPositionChannel_4], a
    ld a, l
    ld [wPositionChannel_4 + 1], a

    ret

; param @bc address of sound's music sheet
StartSoundEffect::
    ld a, [wPositionChannel_1]
    ld [wPositionChannelCopy_1], a
    ld a, [wPositionChannel_1 + 1]
    ld [wPositionChannelCopy_1 + 1], a

    ld a, [wNoteFrameChannel_1]
    ld [wNoteFrameChannelCopy_1], a

    ld a, b
    ld [wInterruptPositionChannel_1], a
    ld a, c
    ld [wInterruptPositionChannel_1 + 1], a

    ld a, 1
    ld [wInterruptChannel_1], a
    xor a
    ld [wInterruptNoteFrameChannel_1], a

    ret

PlayMusic::

    ld a, [wOnChannel_1]
    cp a, 0
    jr z, .channel_1_off

    ld a, [wInterruptChannel_1]
    cp a, 0
    jr nz, .interruptChannel_1

    call PlayChannel_1
    jr .channel_1_off

.interruptChannel_1:
    ; real position should be loaded
    ; play default with skip
    ld a, 1
    ld [wSkipMusicChannel_1], a
    call PlayChannel_1
    ; store real position
    ld a, [wPositionChannel_1]
    ld [wPositionChannelCopy_1], a
    ld a, [wPositionChannel_1 + 1]
    ld [wPositionChannelCopy_1 + 1], a
    ld a, [wNoteFrameChannel_1]
    ld [wNoteFrameChannelCopy_1], a
    
    ; load interrupt position
    ld a, [wInterruptPositionChannel_1]
    ld [wPositionChannel_1], a
    ld a, [wInterruptPositionChannel_1 + 1]
    ld [wPositionChannel_1 + 1], a
    ld a, [wInterruptNoteFrameChannel_1]
    ld [wNoteFrameChannel_1], a
    ; play interrupt without skip
    xor a
    ld [wSkipMusicChannel_1], a
    call PlayChannel_1
    ; store interrupt position
    ld a, [wPositionChannel_1]
    ld [wInterruptPositionChannel_1], a
    ld a, [wPositionChannel_1 + 1]
    ld [wInterruptPositionChannel_1 + 1], a
    ld a, [wNoteFrameChannel_1]
    ld [wInterruptNoteFrameChannel_1], a
    ; load real position (necessary here because of interrupting interrupt)
    ld a, [wPositionChannelCopy_1]
    ld [wPositionChannel_1], a
    ld a, [wPositionChannelCopy_1 + 1]
    ld [wPositionChannel_1 + 1], a
    ld a, [wNoteFrameChannelCopy_1]
    ld [wNoteFrameChannel_1], a

.channel_1_off

    ld a, [wOnChannel_2]
    cp a, 0
    jr z, .channel_2_off
    call PlayChannel_2

.channel_2_off

    ld a, [wOnChannel_3]
    cp a, 0
    jr z, .channel_3_off
    call PlayChannel_3

.channel_3_off

    ld a, [wOnChannel_4]
    cp a, 0
    jr z, .channel_4_off
    call PlayChannel_4

.channel_4_off
    ret

; --------------------------------------------------------------------------------------------------------
SECTION "EngineChannel1", ROM0
; Vibrato is DEPRECATED

RestoreSoundChannel_1:
    ; load position into hl
    ld a, [wPositionChannel_1]
    ld h, a
    ld a, [wPositionChannel_1 + 1]
    ld l, a

    ld a, [hl+] ; load command (+0)
    cp a, NOTE  ; check if a note is played
    ret nz      ; if not return

    ld a, [hl+] ; load note length
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

    ret

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
    jr nz, .caseA1

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
    jr z, .initNote
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
    ld e, a

    ld a, [wSkipMusicChannel_1]
    cp a, 0
    jr nz, .handleSkip

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

    jr .noSkip

.handleSkip

    ld bc, 3    ; adding position of program counter
    add hl, bc

.noSkip

    ld a, e
    cp a, 0
    jp nz, .endSwitch

    ld a, h
    ld [wPositionChannel_1], a
    ld a, l
    ld [wPositionChannel_1 + 1], a

    jp .endSwitch
.caseA1: ; Vibrato -------------------------------------------------
    cp a, VIB
    jr nz, .caseEE

    ld a, [hl+]
    ld [wVibratoChannel_1], a

    ld a, h
    ld [wPositionChannel_1], a
    ld a, l
    ld [wPositionChannel_1 + 1], a

    jp PlayChannel_1
.caseEE: ; Loop -----------------------------------------------------
    cp a, LOOP
    jr nz, .caseFF

    ld a, [wLoopTimesChannel_1]
    cp a, 0
    jr z, .initLoop
    ; loop again
    dec a
    ld [wLoopTimesChannel_1], a
    cp a, 0
    jr nz, .noLoopEnd

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
    jr nz, .endSwitch

    ld a, [wInterruptChannel_1]
    cp a, 0
    jr nz, .interruptEnded

    xor a
    ld [wOnChannel_1], a            ; turn off channel in music engine
    ld [rNR12], a                   ; set volume to 0

    ; rewind the music to the start
    ld hl, MainThemeChannel_1
    ld a, h
    ld [wPositionChannel_1], a
    ld a, l
    ld [wPositionChannel_1 + 1], a

    jr .endSwitch

.interruptEnded:

    xor a
    ld [wInterruptChannel_1], a
    ; load real position back
    ld a, [wPositionChannelCopy_1]
    ld [wPositionChannel_1], a
    ld a, [wPositionChannelCopy_1 + 1]
    ld [wPositionChannel_1 + 1], a
    ld a, [wNoteFrameChannelCopy_1]
    ld [wNoteFrameChannel_1], a

    call RestoreSoundChannel_1

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
    jr nz, .caseA1

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
    jr z, .initNote
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

    jr .endSwitch
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

    jr .endSwitch
.caseA1: ; Vibrato -------------------------------------------------
    cp a, VIB
    jr nz, .caseEE

    ld a, [hl+]
    ld [wVibratoChannel_2], a

    ld a, h
    ld [wPositionChannel_2], a
    ld a, l
    ld [wPositionChannel_2 + 1], a

    jr PlayChannel_2
.caseEE: ; Loop -----------------------------------------------------
    cp a, LOOP
    jr nz, .caseFF

    ld a, [wLoopTimesChannel_2]
    cp a, 0
    jr z, .initLoop
    ; loop again
    dec a
    ld [wLoopTimesChannel_2], a
    cp a, 0
    jr nz, .noLoopEnd

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
    jr nz, .endSwitch

    xor a
    ld [wOnChannel_2], a            ; turn off channel in music engine
    ld [rNR22], a                   ; set volume to 0

    ; rewind the music to the start
    ld hl, MainThemeChannel_2
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
    jr nz, .case25
    
    ld a, [hl+] ; load note length (+1)
    ld c, a

    ld a, [wNoteFrameChannel_3]
    ld b, a
    xor a
    cp a, b
    ; if var == 0 set note length
    jr z, .initNote
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
    jr nz, .caseEE
    
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

    jr PlayChannel_3
.caseEE: ; Loop -----------------------------------------------------
    cp a, LOOP
    jr nz, .caseFF

    ld a, [wLoopTimesChannel_3]
    cp a, 0
    jr z, .initLoop
    ; loop again
    dec a
    ld [wLoopTimesChannel_3], a
    cp a, 0
    jr nz, .noLoopEnd

    ; move sheet pointer after loop command
    ld bc, 3
    add hl, bc
    ld a, h
    ld [wPositionChannel_3], a
    ld a, l
    ld [wPositionChannel_3 + 1], a

    jp PlayChannel_3
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
    jr nz, .endSwitch

    xor a
    ld [wOnChannel_3], a            ; turn off channel in music engine
    ld [rNR32], a                   ; set volume to 0
    ld [rNR30], a                   ; set volume to 0

    ; rewind the music to the start
    ld hl, MainThemeChannel_3
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
    jr nz, .caseEE
    
    ld a, [hl+] ; load note length (+1)
    ld c, a

    ld a, [wNoteFrameChannel_4]
    ld b, a
    xor a
    cp a, b
    ; if var == 0 set note length
    jr z, .initNote
.alreadySet:
    ld a, [wNoteFrameChannel_4]
    dec a
    ld [wNoteFrameChannel_4], a

    cp a, 0             ; if frame == 0
    jr nz, .endSwitch

    ld bc, 3            ; set it to next byte of music sheet
    add hl, bc
    ld a, h
    ld [wPositionChannel_4], a
    ld a, l
    ld [wPositionChannel_4 + 1], a

    jr .endSwitch
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

    jr .endSwitch
.caseEE: ; Loop -----------------------------------------------------
    cp a, LOOP
    jr nz, .caseFF

    ld a, [wLoopTimesChannel_4]
    cp a, 0
    jr z, .initLoop
    ; loop again
    dec a
    ld [wLoopTimesChannel_4], a
    cp a, 0
    jr nz, .noLoopEnd

    ; move sheet pointer after loop command
    ld bc, 3
    add hl, bc
    ld a, h
    ld [wPositionChannel_4], a
    ld a, l
    ld [wPositionChannel_4 + 1], a

    jr PlayChannel_4
.noLoopEnd:
    ld a, [hl+] ; add 1
    ld [wPositionChannel_4 + 1], a
    ld a, [hl+] ; add 2
    ld [wPositionChannel_4], a

    jr PlayChannel_4
.initLoop:
    ld a, [hl+] ; add 1
    ld [wPositionChannel_4 + 1], a
    ld a, [hl+] ; add 2
    ld [wPositionChannel_4], a
    ld a, [hl+] ; times
    dec a ; already did 1 time when coming here
    ld [wLoopTimesChannel_4], a

    jr PlayChannel_4
.caseFF: ; music end command --------------------------------------
    cp a, END
    jr nz, .endSwitch

    xor a
    ld [wOnChannel_4], a            ; turn off channel in music engine
    ld [rNR42], a                   ; set volume to 0

    ; rewind the music to the start
    ld hl, MainThemeChannel_4
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
wPositionChannelCopy_1: ds 2     ; pointer to current command in channel 1
wPositionChannel_2: ds 2         ; pointer to current command in channel 2
wPositionChannel_3: ds 2         ; pointer to current command in channel 3
wPositionChannel_4: ds 2         ; pointer to current command in channel 4
wInterruptChannel_1: ds 1        ; flag for the interrupt being carried out
wSkipMusicChannel_1: ds 1        ; flag for the interrupt being carried out
wInterruptPositionChannel_1: ds 2  ; position of the current interrupt 
wInterruptNoteFrameChannel_1: ds 1  ; number of frames of last note 1
wNoteFrameChannel_1: ds 1        ; number of frames of last note 1
wNoteFrameChannelCopy_1: ds 1        ; number of frames of last note 1
wNoteFrameChannel_2: ds 1        ; number of frames of last note 2
wNoteFrameChannel_3: ds 1        ; number of frames of last note 3
wNoteFrameChannel_4: ds 1        ; number of frames of last note 4
wLoopTimesChannel_1: ds 1        ; number times to loop back 1
wLoopTimesChannel_2: ds 1        ; number times to loop back 2
wLoopTimesChannel_3: ds 1        ; number times to loop back 3
wLoopTimesChannel_4: ds 1        ; number times to loop back 4
wVibratoChannel_1: ds 1          ; vibrato cycle of channel 1
wVibratoChannel_2: ds 1          ; vibrato cycle of channel 2

SECTION "WavePatterns", ROM0

WavePatterns:
    db $02, $46, $8A, $CE, $FF, $FE, $ED, $DC, $CB, $A9, $87, $65, $44, $33, $22, $11
    db $31, $23, $45, $67, $8A, $CD, $EE, $FA, $AF, $EE, $DC, $A8, $76, $54, $32, $13
