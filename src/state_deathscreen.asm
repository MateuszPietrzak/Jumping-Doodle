INCLUDE "include/hardware.inc/hardware.inc"

SECTION "statedeath", ROM0

DeathscreenText1::
    db "GAME  OVER", 0
DeathscreenText2::
    db "YOUR SCORE WAS", 0
DeathscreenText3::
    db "PRESS B TO RETURN", 0
DeathscreenText4::
    db "TO MAIN MENU", 0
DeathscreenText5::
    db "NEW HIGHSCORE", 0
DeathscreenText6::
    db "ENTER YOUR NAME", 0

StateDeathscreen::

    call LoadDeathScreenBackground

    ld a, [wAchievedHighscore]
    cp a, $0
    jp z, .deathscreenLoop

    call LoadHighscoreScreenBackground

    ; set name to AAA
    ld a, 65
    ld [wLeaderboardCurrentName], a
    ld [wLeaderboardCurrentName + 1], a
    ld [wLeaderboardCurrentName + 2], a
    ld a, 92 ; character for overscore
    ld [wLeaderboardMarker], a
    ld a, 32 ; character for space
    ld [wLeaderboardMarker + 1], a
    ld [wLeaderboardMarker + 2], a
    xor a
    ld [wLeaderboardCurrentName + 3], a
    ld [wLeaderboardMarker + 3], a
    ld [wLeaderboardSelect], a
    ld [wFramesFromButton], a

.deathscreenLoop:
    call UpdateKeys
    call WaitForVBlankStart

    ld a, [wAchievedHighscore]
    cp a, $0
    jp z, .skipName

    ld de, $9800 + $160 + $4
    ld hl, wLeaderboardCurrentName
    call WriteTextToWindow

    ld de, $9800 + $180 + $4
    ld hl, wLeaderboardMarker
    call WriteTextToWindow

.skipName:

    call PlayMusic

    ; Check for andy key except d-pad and A for convenience
    ld a, [wKeysPressed]
    ld b, PADF_B | PADF_SELECT | PADF_START
    and a, b

    jp z, .pressedBackEnd
.pressedBack:
    xor a
    ld [wKeysPressed], a

    ld a, [wAchievedHighscore]
    cp a, $0
    jp z, .noHighscore

    call SaveScore

.noHighscore:

    xor a
    ld [wAchievedHighscore], a
    ret
.pressedBackEnd:
    ; ==================================
    ld a, [wAchievedHighscore]
    cp a, $0
    jp z, .skipButtons

    ld a, [wFramesFromButton] 
    inc a
    ld [wFramesFromButton], a

    cp a, 8 ; check for letter change every [value] - 1 frames
    jp c, .skipButtons

    ld a, [wKeysPressed]
    ld b, PADF_UP
    and a, b
    jp z, .pressedUpEnd
.pressedUp:

    ld bc, SwitchLetterSoundChannel_1
    call StartSoundEffect

    xor a
    ld [wFramesFromButton], a

    ld hl, wLeaderboardCurrentName

    ld a, [wLeaderboardSelect]
    ld b, 0
    ld c, a                         

    add hl, bc      ; select current letter

    ld a, [hl]
    inc a           ; load current letter and add 1

    cp a, 91        ; check if we need modulo
    jp c, .noModulo1

    ld a, 65        ; rewind back to a

.noModulo1:

    ld [hl], a      ; load it back

.pressedUpEnd:
    ; ==================================
    ld a, [wKeysPressed]
    ld b, PADF_DOWN
    and a, b

    jp z, .pressedDownEnd
.pressedDown:

    ld bc, SwitchLetterSoundChannel_1
    call StartSoundEffect

    xor a
    ld [wFramesFromButton], a

    ld hl, wLeaderboardCurrentName

    ld a, [wLeaderboardSelect]
    ld b, 0
    ld c, a                         

    add hl, bc      ; select current letter

    ld a, [hl]
    dec a           ; load current letter and add 1

    cp a, 65        ; check if we need modulo
    jp nc, .noModulo2

    ld a, 90        ; rewind back to a

.noModulo2:

    ld [hl], a      ; load it back

.pressedDownEnd:
    ; ==================================
    ld a, [wKeysPressed]
    ld b, PADF_RIGHT
    and a, b

    jp z, .pressedRightEnd
.pressedRight:

    ld bc, SwitchLetterSoundChannel_1
    call StartSoundEffect

    xor a
    ld [wFramesFromButton], a

    ld a, [wLeaderboardSelect]
    inc a           ; load current letter and add 1

    cp a, 3         ; check if we need modulo
    jp nz, .noModulo3

    ld a, 0        ; rewind back to a

.noModulo3:
    
    ld [wLeaderboardSelect], a      ; load it back

    ; get new marker place
    ld hl, wLeaderboardMarker
    ld b, 0
    ld c, a
    add hl, bc
    ; clear marker
    ld a, 32
    ld [wLeaderboardMarker], a
    ld [wLeaderboardMarker + 1], a
    ld [wLeaderboardMarker + 2], a
    ; set marker
    ld a, 92 ; overscore
    ld [hl], a

.pressedRightEnd
    ; ==================================

.skipButtons

    jp .deathscreenLoop


SaveScore::
    ; save scores
    ; enable reading from sram
    ld a, $0A
    ld [rRAMG], a
    ld a, $0
    ld [rRAMB], a
    
    ; copy sram to wram
    ld de, wScoresInBCD
    ld hl, sScoresInBCD
    ld bc, 8 * 8
    call Memcpy

    ; copy current name to correct name on board
    ld a, [wAchievedHighscore]  ; load hs place
    dec a                       ; counting from 0
    sla a   ; a * 4
    sla a
    
    ld b, 0
    ld c, a
    ld de, wLeaderboardCurrentName
    ld hl, wLeaderboardNames
    add hl, bc
    ld bc, 4
    call Memcpy

    ; copy sram to wram
    ld de, wLeaderboardNames
    ld hl, sLeaderboardNames
    ld bc, 4 * 8
    call Memcpy

    ; add 0 to first checksum
    xor a
    ld [sCheckSum], a

    ; add sum of all digits to the second checksum
    ld c, sSRAMEnd - sSRAMStart
    ld d, 0
    ld hl, sScoresInBCD
.whileC
    ld a, [hl+]
    add a, d
    ld d, a
    
    dec c
    jp nz, .whileC

    ld a, d
    ld [sCheckSum + 1], a
    
    ; disable reading from sram
    ld a, $00
	ld [rRAMG], a


SECTION "LeaderboardName", WRAM0

wLeaderboardSelect::
    ds 1
wFramesFromButton::
    ds 1
wLeaderboardNames::
    ds 4 * 8
wLeaderboardCurrentName::
    ds 4
wLeaderboardMarker::
    ds 4
