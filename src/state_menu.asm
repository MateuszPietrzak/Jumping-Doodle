INCLUDE "include/hardware.inc/hardware.inc"

SECTION "statemenu", ROM0

StateMenu::
    call WaitForVBlank
    ; TO DO WHILE VBLANK
    ld bc, 32
    ld hl, $9c20                ; load second line
    ld de, wWindowTilemapCopy + 32
    call Memcpy
    ; TO DO WHILE VBLANK END

    ; play music
    ; RIGHT AFTER ALL MEMCOPY
    call PlayMusic

    ; Check for d-pad down
    ld a, [wKeysPressed]
    ld b, PADF_DOWN
    and a, b

    jp z, .pressedDownEnd
.pressedDown

.pressedDownEnd

    ; Check for d-pad up 
    ld a, [wKeysPressed]
    ld b, PADF_UP
    and a, b

    jp z, .pressedUpEnd
.pressedUp

.pressedUpEnd

    ; Check for B press
    ld a, [wKeysPressed]
    ld b, PADB_B
    and a, b

    jp z, .pressedBEnd
.pressedB
    jp StateGame
.pressedBEnd


    call UpdateKeys
    jp StateMenu

SECTION "menudata", WRAM0

wButtonSelected:: ds 1