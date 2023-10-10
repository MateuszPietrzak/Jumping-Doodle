INCLUDE "hardware.inc/hardware.inc"

SECTION "HighscoresSave", SRAM, BANK[0]
sSRAMStart::
sScoresInBCD:: 
    ds 8 * 8
sLeaderboardNames::
    ds 4 * 8
sSRAMEnd::
sCheckSum::
    ds 2

SECTION "Highscores", WRAM0
    wScoresInBCD:: 
        ds 8 * 8

SECTION "StateScores", ROM0

ClearScores:
    ld c, sLeaderboardNames - sScoresInBCD ; sScoresInBCD length
    xor a
    ld hl, sScoresInBCD
.whileC
    ld [hl+], a
    
    dec c
    jr nz, .whileC

    ld c, 8
    ld hl, sLeaderboardNames
.whileC2
    ld a, 65
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    xor a
    ld [hl+], a
    
    dec c
    jr nz, .whileC2

    xor a
    ld [sCheckSum], a
    ld a, 24 ; (65 * 3 * 8) % 256
    ld [sCheckSum + 1], a

    ret

CheckSum:
    ld a, [sCheckSum]
    cp a, 0
    jr z, .checkCorrect

    call ClearScores
    ret

.checkCorrect:
    ld a, [sCheckSum + 1]
    ld b, a

    ld c, sSRAMEnd - sSRAMStart
    ld d, 0
    ld hl, sSRAMStart
.whileC
    ld a, [hl+]
    add a, d
    ld d, a
    
    dec c
    jr nz, .whileC

    ld a, b
    cp a, d
    call nz, ClearScores

    ret

LoadScores::
    ; load scores
    ; enable reading from sram
    ld a, $0A
    ld [rRAMG], a
    ld a, $0
    ld [rRAMB], a

    call CheckSum

    ; copy sram to wram
    ld de, sScoresInBCD
    ld hl, wScoresInBCD
    ld bc, 8 * 8
    call Memcpy

    ; copy sram to wram
    ld de, sLeaderboardNames
    ld hl, wLeaderboardNames
    ld bc, 4 * 8
    call Memcpy

    ; disable reading from sram
    ld a, $00
	ld [rRAMG], a

    ret

StateScores::
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
    jp z, .scoresLoop

    call SwitchToMainTheme

    ret
