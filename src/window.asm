
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

; set 
WriteTextToWindow::


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
