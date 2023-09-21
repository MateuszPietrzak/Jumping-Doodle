
INCLUDE "hardware.inc/hardware.inc"

SECTION "windowFunctions", ROM0

; function initializing window position
; it also turns window on
InitializeWindow::
    ; WX = 7
    ld a, 7
    ld [rWX], a
    ; WY = 100
    ld a, 100
    ld [rWY], a

    ; turn on window displaying
    ld a, [rLCDC]       ; get current LCDC state
    or a, LCDCF_WIN9C00 ; or it with LCD WINON
    ld [rLCDC], a       ; set it back

    ; do tiles for window
    ld de, fontTiles
    ld hl, $9010
    ld bc, fontTiles.end - fontTiles
    call Memcpy

    ; do tilemap for window
    ld de, windowInitialState
    ld hl, $9C00
    ld bc, windowInitialState.end - windowInitialState
    call Memcpy

    ; do tilemap for background
    ld de, BackgroundInitialState
    ld hl, $9800
    ld bc, BackgroundInitialState.end - BackgroundInitialState
    call Memcpy

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
; @param hl Source in RAM
; @param bc data size
WriteTextToWindow::
    ld a, b
    or a, c
    jp z, WriteTextToWindow.end

    ; A = 12 (vs 65)
    ld a, [hl+]
    sub a, 53
    ld [de], a

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
WhileNumberIsNotZero:
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
    ; load tile id into tilemap
    ld [de], a

    ; move one tile back
    dec de

    ; copy from parameters to the ram
    ld a, h;
    ld [wArithmeticVariable], a
    ld a, l
    ld [wArithmeticVariable+1], a

    push de
    push hl

    ; get rid of last digit
    call Divide

    pop hl
    pop de

    ; move result to input and save copy in hl (copy needed because Modulo changes input)
    ld a, [wArithmeticResult]
    ld [wArithmeticVariable], a
    ld h, a
    ld a, [wArithmeticResult+1]
    ld [wArithmeticVariable+1], a
    ld l, a

    ; check if loop should end
    ld a, l
    or a, h
    jp nz, WhileNumberIsNotZero

    ret

SECTION "WindowTilemap", ROM0

windowInitialState:
REPT 32
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
ENDR
.end:

SECTION "BackgroundTilemap", ROM0

BackgroundInitialState:
REPT 32
    db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
ENDR
.end:
