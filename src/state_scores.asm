INCLUDE "hardware.inc/hardware.inc"

SECTION "HighscoresSave", SRAM, BANK[0]
    sScoresInBCD:: 
        ds 8 * 8

SECTION "Highscores", WRAM0
    wScoresInBCD:: 
        ds 8 * 8

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

DEF MBC1SRamEnable      EQU $0000
DEF MBC1SRamBank        EQU $4000

StateScores::
    ; TODO move this to init (for highscore compares)
    ; load scores
    ; enable reading from sram
    ld a, $0A
    ld [MBC1SRamEnable], a
    ld a, $0
    ld [MBC1SRamBank], a

    ; copy sram to wram
    ld de, sScoresInBCD
    ld hl, wScoresInBCD
    ld bc, 8 * 8
    call Memcpy

    ; disable reading from sram
    ld a, $00
	ld [MBC1SRamEnable], a

    ; load background
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
