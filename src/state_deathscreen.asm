INCLUDE "include/hardware.inc/hardware.inc"

SECTION "statedeath", ROM0

DeathscreenText1::
    db "YOU DIED", 0
DeathscreenText2::
    db "PRESS B TO RETURN", 0
DeathscreenText3::
    db "TO MAIN MENU", 0

StateDeathscreen::

    call LoadDeathscreenBackground
.deathscreenLoop:
    call UpdateKeys
    call WaitForVBlankStart

    ; Check for andy key except d-pad and A for convenience
    ld a, [wKeysPressed]
    ld b, PADF_B | PADF_SELECT | PADF_START
    and a, b

    jp z, .pressedEnd
.pressed
    xor a
    ld [wKeysPressed], a
    ret
.pressedEnd

    jp .deathscreenLoop
