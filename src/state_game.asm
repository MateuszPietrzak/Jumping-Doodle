INCLUDE "include/hardware.inc/hardware.inc"
INCLUDE "include/palettes.inc"

SECTION "StateGame", ROM0

StateGame::
    ; All initialization needed before a game is started, such as resetting player, should go here

    call ResetPlayerState
    call ResetEnemyState
    call WaitForVBlank
    call HandlePlayer

    ld a, $1
    ld [wIsAlive], a
GameLoop:

    call WaitForVBlankStart

    ; TO DO WHILE VBLANK
    ; Set bg and window layers palette
    ld hl, PaletteNormalDGB
    call SetPalette

    ld a, [rLCDC]
    or a, LCDCF_OBJON
    ld [rLCDC], a


    ld bc, 8
    ld hl, $9c00 + $20 + $7              ; load second line
    ld de, wWindowTilemapCopy + 32 + 7
    call Memcpy

    ld a, [wInventory]
    ld [$9C30], a
    ld a, [wInventory + 1]
    ld [$9C32], a

    call HandlePlayerVBlank
    call HandleEnemyVBlank
    ; TO DO WHILE VBLANK END

    call EnemyBufferToOAM
    call PlayerBufferToOAM

    ; Transfer OAM buffer to actual OAM
    ld a, $C0
    call hOAMDMA

    ; play music
    ; RIGHT AFTER ALL MEMCOPY

    call PlayMusic

    call HandleEnemy
    call HandlePlayer

    ld a, [wScoreToAdd]         ; number of subpixels that screen was lowered
    cp a, 0
    jr z, .skipScoreChange      ; don't change score if it wasn't modified

    call CharToBCD              ; convert a to BCD_2
    call AddNumbersBCD          ; add BCD_1 and BCD_2

    ; copy result to score
    FOR N, 8
        ld a, [wNumberBCD_3 + N]
        ld [wNumberBCD_1 + N], a
    ENDR

    ; Write number and increment it
    ld bc, wWindowTilemapCopy + 7 + 32 + 7 ; tilemap address
    ld hl, wNumberBCD_1
    call WriteBCDToWindow

.skipScoreChange
    ; Update player inputs
    call UpdateKeys

    ld a, [wIsAlive]
    cp a, $0
    jr nz, .allGood

    jp GameFinish

.allGood:

    call WaitForPaletteSwap

    ; Set bg and window layers palette
    ld a, [PaletteInvertedDGB]
    ld [rBGP], a
    ; ld hl, PaletteInvertedDGB
    ; call SetPalette

    ld a, [rLCDC]
    xor a, LCDCF_OBJON
    ld [rLCDC], a

    jp GameLoop

GameFinish::
    ; Everything to do after dying, for example saving score
    call EndSoundEffect

    ld bc, wNumberBCD_1             ; compare final score
    ld de, wScoresInBCD + 7 * 8     ; with last (8th) highscore
    call GreaterBCD

    cp a, 0
    jr z, .deathscreenJump          ; if score lower then just skip

    ld a, 8
    ld [wAchievedHighscore], a
    ld de, wNumberBCD_1             ; if new score is greater
    ld hl, wScoresInBCD + 7 * 8     ; set it to last highscore
    ld bc, 8
    call Memcpy

    ld bc, 7
.whileBetter:
    ; check if this it the top score
    ld a, c                    
    cp a, 0
    jr z, .deathscreenJump

    ; compare score at wScoreInBCD + c * 8 with (c-1) * 8
    ld hl, wScoresInBCD
    ; (c-1) * 8
    dec c
    sla c
    sla c
    sla c
    add hl, bc
    ld d, h
    ld e, l ; wScoresInBCD + (c - 1) * 8
    push de

    push bc

    ld bc, 8
    add hl, bc
    ld b, h
    ld c, l ; wScoresInBCD + c * 8

    call GreaterBCD

    pop bc

    pop de

    cp a, 0
    jr z, .deathscreenJump    ; no swap

    ; indicate getting higher score
    ld a, [wAchievedHighscore]
    dec a
    ld [wAchievedHighscore], a

    ; we need to preserve c
    push bc
    push bc

    ld h, d
    ld l, e
    ld bc, 8
    add hl, bc

    call Memswap

    pop bc

    srl c
    ld hl, wLeaderboardNames
    add hl, bc
    ld d, h
    ld e, l ; de = wLeaderboardNames + (c-1)*4
    ld bc, 4
    add hl, bc ; hl = wLeaderboardNames + c*4

    call Memswap

    ; restore c
    pop bc

    srl c
    srl c
    srl c

    jr .whileBetter

.deathscreenJump:
    ; Switch to deathscreen
    ; score is saved after deathscreen
    call StateDeathscreen

    ret

SECTION "GameData", WRAM0

wIsAlive:: 
    ds 1
wAchievedHighscore:: 
    ds 1