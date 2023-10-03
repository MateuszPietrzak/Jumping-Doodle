INCLUDE "include/hardware.inc/hardware.inc"

SECTION "statemenu", ROM0

StateMenu::
    ; Init all stuff for menu rendering
    call LoadMenuBackground
    xor a
    ld [rSCY], a
    xor a
    ld [wButtonSelected], a

.menuLoop:
    call UpdateKeys
    call WaitForVBlank
    ; To do while VBlank

    ; If we need to reload buttons
    ld a, [wRefreshButtonsFlag]
    cp a, $0
    jp z, .noRefreshButtons

    ; Reset the flag back to zero
    xor a
    ld [wRefreshButtonsFlag], a

    ld a, [wButtonSelected]
    cp a, $0
    jp nz, .caseOne 
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

    jp .noRefreshButtons
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

    ld bc, 32
    ld hl, $9c20                ; load second line
    ld de, wWindowTilemapCopy + 32
    call Memcpy
    ; TO do while VBlank end

    ; play music
    ; RIGHT AFTER ALL MEMCOPY
    call PlayMusic

    ; Check for d-pad down
    ld a, [wKeysPressed]
    ld b, PADF_DOWN
    and a, b

    jp z, .pressedDownEnd
.pressedDown
    ; Only go down if you can
    ld a, [wButtonSelected]
    cp a, $0
    jp nz, .pressedDownEnd

    ; Increment button state
    inc a
    ld [wButtonSelected], a

    ld a, $1
    ld [wRefreshButtonsFlag], a
    
.pressedDownEnd

    ; Check for d-pad up 
    ld a, [wKeysPressed]
    ld b, PADF_UP
    and a, b

    jp z, .pressedUpEnd
.pressedUp
    ; Only go up if you can
    ld a, [wButtonSelected]
    cp a, $1
    jp nz, .pressedUpEnd

    ; Decrement button state
    dec a
    ld [wButtonSelected], a
    
    ld a, $1
    ld [wRefreshButtonsFlag], a

.pressedUpEnd

    ; Check for A press
    ld a, [wKeysPressed]
    ld b, PADF_A
    and a, b

    jp z, .pressedAEnd
.pressedA
    ld a, [wButtonSelected]
    cp a, $0
    ; If "PLAY" selected
    jp z, StateGame
    ; Else, "SCORES must be selected
    jp StateScores
.pressedAEnd


    jp .menuLoop

SECTION "menudata", WRAM0

wButtonSelected:: ds 1
wRefreshButtonsFlag:: ds 1