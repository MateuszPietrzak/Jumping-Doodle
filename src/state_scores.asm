INCLUDE "hardware.inc/hardware.inc"

SECTION "statescores", ROM0

LeaderboardText::
    db "LEADERBOARD", 0
LeaderboardNumbers::
    db "0[", 0
    db "1[", 0
    db "2[", 0
    db "3[", 0
    db "4[", 0
    db "5[", 0
    db "6[", 0
    db "7[", 0

StateScores::
    ; For now, return to Main Menu after 2s
    call LoadScoresBackground

.scoresLoop:
    call UpdateKeys
    call WaitForVBlankStart

    call PlayMusic
    ; Check for d-pad down
    ld a, [wKeysPressed]
    ld b, PADF_B
    and a, b

    ret nz
    jp .scoresLoop