
INCLUDE "hardware.inc/hardware.inc"

SECTION "windowFunctions", ROM0

; function initializing window position
InitializeWindow::
    ; WX = 7
    ld a, 7
    ld [rWX], a
    ; WY = 100
    ld a, 120
    ld [rWY], a

    ld a, [rLCDC]
    push af
    
    ; do tiles for window
    ld de, FontTiles
    ld hl, $9010
    ld bc, FontTilesEnd - FontTiles
    call Memcpy

    ; background tiles
    ld de, BackgroundTiles
    ld hl, $9400
    ld bc, BackgroundTiles.end - BackgroundTiles
    call Memcpy
    
    ; menu buttons tiles
    ld de, MenuTiles
    ld hl, $9500
    ld bc, MenuTiles.end - MenuTiles
    call Memcpy
    
    ; do tilemap for window
    ld de, WindowInitialState
    ld hl, $9C00
    ld bc, WindowInitialState.end - WindowInitialState
    call Memcpy
    
    ; do tilemap for window
    ld de, WindowInitialState
    ld hl, wWindowTilemapCopy
    ld bc, WindowInitialState.end - WindowInitialState
    call Memcpy
    
    pop af
    ; turn on window displaying
    or a, LCDCF_WIN9C00 ; or it with LCD WINON
    ld [rLCDC], a       ; set it back

    ret

SwitchWindow::
    ; turn on window displaying
    ld a, [rLCDC]       ; get current LCDC state
    or a, LCDCF_WIN9C00 ; or it with LCD WINON
    or a, LCDCF_WINON   ; or it with LCD WINON
    ld [rLCDC], a       ; set it back

    ret

LoadGameBackground::
    call WaitForVBlank

    ;Disable LCD before writing to VRAM
    xor a
    ld [rLCDC], a

    call ClearOam

    ld b, $20
.generateStripesLoop:
    ld a, b
    cp a, $0
    jr z, .generateStripesLoopEnd

    ld a, b
    ld [wGenerateLinePositionY], a
    push bc
    call GenerateStripe
    pop bc

    dec b
    jr .generateStripesLoop
.generateStripesLoopEnd:
    ld a, $1F
    ld [wGenerateLinePositionY], a
    call GenerateStripe

    ld bc, $0014
    ld hl, $99C0

.floorTiles:
    ld a, $44
    ld [hl+], a
    dec bc
    ld a, b
    or a, c
    jr nz, .floorTiles


    ; write text to window
    ld hl, ScoreText
    ld de, $9c00 + $20 + $1
    call WriteTextToWindow

    ; numbers
    xor a
FOR N, 8
    ld [wNumberBCD_1 + N], a
    ld [wNumberBCD_2 + N], a
ENDR
    
    ld a, 1
    ld [wNumberBCD_2 + 7], a

    ; write initial score
    ld bc, wWindowTilemapCopy + 7 + 32 + 7 ; tilemap address
    ld hl, wNumberBCD_1
    call WriteBCDToWindow

    ; turn on the LCD
    ld a, [rLCDC]
    or a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_WINON | LCDCF_WIN9C00
    ld [rLCDC], a

    ret 

LoadMenuBackground::
    call WaitForVBlank

    ;Disable LCD before writing to VRAM
    xor a
    ld [rLCDC], a

    ; do tilemap for background
    ld de, MenuTilemap
    ld hl, $9800
    ld bc, MenuTilemap.end - MenuTilemap
    call MemcpyOffsetMenu

    ld de, $9800 + $60 + $6
    ld hl, GameTitle1
    call WriteTextToWindow

    ld de, $9800 + $A0 + $8
    ld hl, GameTitle2
    call WriteTextToWindow

    ; turn on the LCD
    ld a, [rLCDC]
    or a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a

    ret

LoadScoresBackground::
    call WaitForVBlank

    ;Disable LCD before writing to VRAM
    xor a
    ld [rLCDC], a

    ld a, %1111_0101
    ld [rBGP], a

    ld bc, $03FF
    ld hl, $9800

.cleanBG:
    xor a
    ld [hl+], a
    dec bc
    ld a, b
    or a, c
    jr nz, .cleanBG

    ld de, $9800 + $20 + $3
    ld hl, LeaderboardText
    call WriteTextToWindow

FOR N, 8
    ld de, $9800 + $80 + $3 + N * $20
    ld hl, LeaderboardNumbers + N * 3
    call WriteTextToWindow

    ld de, $9800 + $80 + $5 + N * $20
    ld hl, wLeaderboardNames + N * 4
    call WriteTextToWindow

    ld bc, $9800 + $80 + $8 + $8 + N * $20
    ld hl, wScoresInBCD + N * 8
    call WriteBCDToWindow
ENDR

    ; turn on the LCD
    ld a, [rLCDC]
    or a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a

    ret

LoadDeathScreenBackground::
    call WaitForVBlank

    ;Disable LCD before writing to VRAM
    xor a
    ld [rLCDC], a

    ; load darker palette
    ld a, %1111_0101
    ld [rBGP], a

    ; Clear screen
    ld bc, $03FF
    ld hl, $9800

.cleanBG:
    xor a
    ld [hl+], a
    dec bc
    ld a, b
    or a, c
    jr nz, .cleanBG

    ld de, $9800 + $20 + $5
    ld hl, DeathscreenText1
    call WriteTextToWindow

    ld de, $9800 + $80 + $3
    ld hl, DeathscreenText2
    call WriteTextToWindow

    ld bc, $9800 + $C0 + $D
    ld hl, wNumberBCD_1
    call WriteBCDToWindow

    ld de, $9800 + $1E0
    ld hl, DeathscreenText3
    call WriteTextToWindow

    ld de, $9800 + $200
    ld hl, DeathscreenText4
    call WriteTextToWindow

    xor a
    ld [rSCY], a

    ; turn on the LCD
    ld a, [rLCDC]
    or a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a

    ret

LoadHighscoreScreenBackground::
    call WaitForVBlank

    ;Disable LCD before writing to VRAM
    xor a
    ld [rLCDC], a

    ld de, $9800 + $100 + $3
    ld hl, DeathscreenText5
    call WriteTextToWindow

    ld de, $9800 + $120 + $3
    ld hl, DeathscreenText6
    call WriteTextToWindow

    xor a
    ld [rSCY], a

    ; turn on the LCD
    ld a, [rLCDC]
    or a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a

    ret

; WriteTextToWindow
; writes text on window
; @param de First index of tile
; @param hl Source
WriteTextToWindow::
    ld a, [hl+]             ; load next char

.caseEnd:
    cp a, 0
    jr z, .end

.caseSpace:
    cp a, 32
    jr nz, .caseNumber

    sub a, 32
    ld [de], a

    jr .switchEnd
.caseNumber:
    cp a, 65
    jr nc, .caseLetter

    sub a, 46
    ld [de], a

    jr .switchEnd
.caseLetter:
    ; A = 12 (vs 65 in ASCII)
    sub a, 53
    ld [de], a
.switchEnd:

    inc de
    dec bc

    jr WriteTextToWindow
.end:
    ret

; DEPRECATED
; WriteNumberToWindow
; writes number on window
; @param de First index of tile
; @param hl Number to be printed
WriteNumberToWindow::
    
    ; copy from parameters to the ram
    ld a, h;
    ld [wArithmeticVariable], a
    ld a, l
    ld [wArithmeticVariable+1], a
    ; we do this modulo 10
    ld a, 10
    ld [wArithmeticModifier], a

    ; loop until the number becomes 0
.whileNumberIsNotZero:
    push de
    push hl

    ; get least significant digit (number % 10)
    call Modulo

    pop hl
    pop de

    ; load only last byte since it's in [0-9]
    ld a, [wArithmeticResult+1]

    ; add 2 to a, because font tiles start from id 2
    add a, 2
    ; load tile id into tilemap copy
    ld hl, wWindowTilemapCopy
    add hl, de
    ld [hl], a

    ; move one tile back
    dec de

    ; move result to input and save copy in hl (copy needed because Modulo changes input)
    ld a, [wArithmeticVariable]
    ld h, a
    ld a, [wArithmeticVariable+1]
    ld l, a

    ; check if loop should end
    ld a, l
    or a, h
    jr nz, .whileNumberIsNotZero

    ret

UpdateWindow::
    ld hl, $9c00
    ld de, wWindowTilemapCopy
    ld bc, wWindowTilemapCopy - wWindowTilemapCopy.end
    call Memcpy

    ret

; WriteNumberToWindow
; writes number on window
; @param bc First index of tile
; @param hl address of first digit
WriteBCDToWindow::
    ld e, 7
    ld d, 0
    add hl, de
    
WhileDigits:

    ld a, [hl-]

    add a, 2            ; tile offset
    ld [bc], a          ; write to tilemap
    dec bc              ; move to next spot

    ld a, e
    cp a, 0
    jr z, .end

    dec e
    jr WhileDigits
.end
    ret

SECTION "WindowTilemapCopy", WRAM0

wWindowTilemapCopy:: 
    ds 32*32
.end:

SECTION "WindowTilemap", ROM0

WindowInitialState:
REPT 32
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
ENDR
.end:

SECTION "BackgroundTilemap", ROM0

BackgroundTiles:
    incbin "assets/Platforms.2bpp"
.end:

MenuTiles:
    incbin "assets/ButtonsTiles.2bpp"
.end:

MenuTilemap:
    incbin "assets/MainMenuTilemap.2bpp"
.end:
