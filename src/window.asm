
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
    jp z, .generateStripesLoopEnd

    ld a, b
    ld [wGenerateLinePositionY], a
    push bc
    call GenerateStripe
    pop bc

    dec b
    jp .generateStripesLoop
.generateStripesLoopEnd:

    ld bc, $0014
    ld hl, $99C0

.floorTiles:
    ld a, $44
    ld [hl+], a
    dec bc
    ld a, b
    or a, c
    jp nz, .floorTiles


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

    ;Disable LCD before writing to VRAM
    xor a
    ld [rLCDC], a

    ld bc, $03FF
    ld hl, $9800

.cleanBG:
    xor a
    ld [hl+], a
    dec bc
    ld a, b
    or a, c
    jp nz, .cleanBG

    ld de, $9800 + $20 + $3
    ld hl, LeaderboardText
    call WriteTextToWindow

FOR N, 8
    ld de, $9800 + $60 + $4 + N * $20
    ld hl, LeaderboardNumbers + N * 3
    call WriteTextToWindow
ENDR

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
    jp z, .end

.caseSpace:
    cp a, 32
    jp nz, .caseNumber

    sub a, 32
    ld [de], a

    jp .switchEnd
.caseNumber:
    cp a, 65
    jp nc, .caseLetter

    sub a, 46
    ld [de], a

    jp .switchEnd
.caseLetter:
    ; A = 12 (vs 65 in ASCII)
    sub a, 53
    ld [de], a
.switchEnd:

    inc de
    dec bc

    jp WriteTextToWindow
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
    jp nz, .whileNumberIsNotZero

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
WriteBCDToWindow::
    ld e, 7
    ld d, 0             ; clear d
    
WhileDigits:

    ld hl, wNumberBCD_1 ; load number with offset
    add hl, de
    ld a, [hl]

    add a, 2            ; tile offset
    ld [bc], a          ; write to tilemap
    dec bc              ; move to next spot

    ld a, e
    cp a, 0
    jp z, .end

    dec e
    jp WhileDigits
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
