INCLUDE "hardware.inc/hardware.inc"

SECTION "statescores", ROM0

StateScores::
    ; For now, return to Main Menu after 2s
    call LoadScoresBackground
    ld bc, $0078
.scoresLoop:
    call WaitForVBlank

FOR N, 1000
    dec bc
    inc bc
ENDR
    dec bc
    ld a, b
    or a, c
    jp z, StateMenu
    jp .scoresLoop