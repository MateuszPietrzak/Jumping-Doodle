INCLUDE "include/hardware.inc/hardware.inc"
INCLUDE "include/palettes.inc"

SECTION "StateMenu", ROM0

StateMenu::
    ; Init all stuff for menu rendering
    call LoadMenuBackground
    xor a
    ld [rSCY], a
    xor a
    ld [wButtonSelected], a
    ld [wRefreshButtonsFlag], a

.menuLoop:
    call UpdateKeys
    call WaitForVBlankStart
    ; To do while VBlank

    ; If we need to reload buttons
    ld a, [wRefreshButtonsFlag]
    cp a, $0
    jr z, .noRefreshButtons

    ; Reset the flag back to zero
    xor a
    ld [wRefreshButtonsFlag], a

    ld a, [wButtonSelected]
    cp a, $0
    jr nz, .caseOne 
.caseZero:

    ld hl, $9928 
    ld b, $4
    call Sub16

    ld hl, $9948 
    ld b, $4
    call Sub16

    ld hl, $99A8 
    ld b, $4
    call Sub16

    ld hl, $99C8 
    ld b, $4
    call Sub16

    jr .noRefreshButtons
.caseOne:

    ld hl, $9928 
    ld b, $4
    call Add16

    ld hl, $9948 
    ld b, $4
    call Add16

    ld hl, $99A8 
    ld b, $4
    call Add16

    ld hl, $99C8 
    ld b, $4
    call Add16

.noRefreshButtons:
    ; play music
    ; RIGHT AFTER ALL MEMCOPY
    call PlayMusic
    
    ; Check for d-pad down
    ld a, [wKeysPressed]
    ld b, PADF_DOWN
    and a, b

    jr z, .pressedDownEnd
.pressedDown
    ; Only go down if you can
    ld a, [wButtonSelected]
    cp a, $0
    jr nz, .pressedDownEnd

    ; Increment button state
    inc a
    ld [wButtonSelected], a

    ld a, $1
    ld [wRefreshButtonsFlag], a

    ld bc, SwitchButtonSoundChannel_1
    call StartSoundEffect
    
.pressedDownEnd

    ; Check for d-pad up 
    ld a, [wKeysPressed]
    ld b, PADF_UP
    and a, b

    jr z, .pressedUpEnd
.pressedUp
    ; Only go up if you can
    ld a, [wButtonSelected]
    cp a, $1
    jr nz, .pressedUpEnd

    ; Decrement button state
    dec a
    ld [wButtonSelected], a
    
    ld a, $1
    ld [wRefreshButtonsFlag], a

    ld bc, SwitchButtonSoundChannel_1
    call StartSoundEffect

.pressedUpEnd

    ; Check for A press
    ld a, [wKeysPressed]
    ld b, PADF_A
    and a, b

    jr z, .pressedAEnd
.pressedA
    ld a, [wButtonSelected]
    cp a, $0
    jr nz, .scoreSelected
    ; If "PLAY" selected
    call SwitchToMainTheme
    call StateGame

    ; reload default color palette
    ld hl, PaletteNormalDGB
    call SetPalette

    jp StateMenu
.scoreSelected
    ; Else, "SCORES must be selected
    call SwitchToLeaderboardTheme
    call StateScores

    ; reload default color palette
    ld hl, PaletteNormalDGB
    call SetPalette

    jp StateMenu
.pressedAEnd


    jp .menuLoop

SECTION "MenuData", WRAM0

wButtonSelected:: ds 1
wRefreshButtonsFlag:: ds 1