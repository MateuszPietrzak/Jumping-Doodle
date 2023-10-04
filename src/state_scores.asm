INCLUDE "hardware.inc/hardware.inc"

SECTION "statescores", ROM0

LeaderboardText::
    db "LEADERBOARD", 0

StateScores::
    ; For now, return to Main Menu after 2s
    call LoadScoresBackground

.scoresLoop:
    call UpdateKeys
    call WaitForVBlank

    call PlayMusic
    ; Check for d-pad down
    ld a, [wKeysPressed]
    ld b, PADF_B
    and a, b

    ret nz
    jp .scoresLoop