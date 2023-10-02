
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

    ; turn on window displaying
    ld a, [rLCDC]       ; get current LCDC state
    or a, LCDCF_WIN9C00 ; or it with LCD WINON
    ld [rLCDC], a       ; set it back

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

    ; do tilemap for background
    ld de, BackgroundTilemap
    ld hl, $9800
    ld bc, BackgroundTilemap.end - BackgroundTilemap
    call MemcpyOffset

    ret

SwitchWindow::
    ; turn on window displaying
    ld a, [rLCDC]       ; get current LCDC state
    or a, LCDCF_WINON   ; or it with LCD WINON
    ld [rLCDC], a       ; set it back

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
    jp nz, .caseLetter

    sub a, 32
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

BackgroundTilemap:
    incbin "assets/BackgroundTilemap.2bpp"
.end:

BackgroundTiles:
    incbin "assets/BackgroundTiles.2bpp"
.end:

