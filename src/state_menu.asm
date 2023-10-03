INCLUDE "include/hardware.inc/hardware.inc"

SECTION "statemenu", ROM0

StateMenu::

    ; Temporarily the menu just starts the game
    call StateGame

    jp StateMenu