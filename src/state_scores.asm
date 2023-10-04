INCLUDE "hardware.inc/hardware.inc"

SECTION "statescores", ROM0

LeaderboardText:
    db "LEADERBOARD", 0

StateScores::
    ; For now, return to Main Menu after 2s
    call LoadScoresBackground

    ld de, $9800 + $20 + $3
    ld hl, LeaderboardText
    call WriteTextToWindow

.scoresLoop:
    call UpdateKeys
    call WaitForVBlank

    call PlayMusic
    ; Check for d-pad down
    ld a, [wKeysPressed]
    ld b, PADF_A
    and a, b

    ret nz
    jp .scoresLoop