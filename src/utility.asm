INCLUDE "hardware.inc/hardware.inc"

SECTION "Utility", ROM0

; Memcpy
; Copies data
; @param de Beginning of source data
; @param hl Beginning of target space
; @param bc data size
Memcpy::
    ld a, [de]      ; 2
    ld [hl+], a     ; 2
    inc de          ; 2
    dec bc          ; 2
    ld a, b         ; 1
    or a, c         ; 1
    jr nz, Memcpy   ; 3
    ret             ; 4

; Soubrouting to copy soublroutine into HRAM
; https://gbdev.gg8.se/wiki/articles/OAM_DMA_tutorial
; (Cursed as hell)
CopyDMATransfer::
    ld hl, DMATransfer
    ld b, DMATransferEnd - DMATransfer
    ld c, LOW(hOAMDMA)
.copy:
    ld  a, [hli]
    ldh [c], a
    inc c
    dec b
    jr  nz, .copy
    ret

; DMATransfer
; Copies OAM data from high RAM
; @param a Place in high ram divided by $100
; https://gbdev.io/pandocs/OAM_DMA_Transfer.html
DMATransfer::
    ldh [rDMA], a  ; start DMA transfer (starts right after instruction)
    ld a, 40        ; delay for a total of 4×40 = 160 cycles
.wait:
    dec a
    jr nz, .wait
    ret
DMATransferEnd::

; Zero
; Sets bytes to 0
; @param hl start of data
; @param bc length
Zero::
    xor a           ; 1
    ld [hl+], a     ; 2
    dec bc          ; 2
    ld a, b         ; 1
    or a, c         ; 1
    jr nz, Zero   ; 3
    ret             ; 4


; Memswap
; Swaps data
; @param de Beginning of source data
; @param hl Beginning of target space
; @param bc data size
Memswap::
    push bc         ; 4
    ld a, [de]      ; 2
    ld b, a         ; 1
    ld a, [hl]      ; 2
    ld [de], a      ; 2
    ld a, b         ; 1
    ld [hl+], a     ; 2
    pop bc          ; 3

    dec bc          ; 2
    inc de          ; 2

    ld a, b         ; 1
    or a, c         ; 1
    jr nz, Memswap  ; 3
    ret             ; 4

; MemcpyOffsetGame
; Copies data from ROM to RAM and adds $40 (Game Assets)
; @param de Beginning of data in ROM
; @param hl Beginning of target space in RAM
; @param bc data size
MemcpyOffsetGame::
    ld a, [de]
    add a, $40
    ld [hl+], a
    inc de
    dec bc
    ld a, b
    or a, c
    jr nz, MemcpyOffsetGame
    ret

; MemcpyOffsetMenu
; Copies data from ROM to RAM and adds $50 (Game Assets)
; @param de Beginning of data in ROM
; @param hl Deginning of target space in RAM
; @param bc data size
MemcpyOffsetMenu::
    ld a, [de]
    add a, $4F
    ld [hl+], a
    inc de
    dec bc
    ld a, b
    or a, c
    jr nz, MemcpyOffsetMenu
    ret

; Sub16
; Decreases all values at a given range by $10
; @param hl Beginning of data
; @param b length
Sub16::
    ld a, b
    cp a, $0
    ret z
    ld a, [hl]
    sub a, $10     
    ld [hl+], a
    dec b
    jr Sub16

; Add16
; Increases all values at a given range by $10
; @param hl Beginning of data
; @param b length
Add16::
    ld a, b
    cp a, $0
    ret z
    ld a, [hl]
    add a, $10     
    ld [hl+], a
    dec b
    jr Add16

; WaitPorVBlank
; Waits until VBlank (duh)
WaitForVBlank::
    ld a, [rLY]
    cp 144
    jr c, WaitForVBlank
    ret

; WaitPorVBlankStart
; Wait for the start of the VBlank
WaitForVBlankStart::
    ld a, [rLY]
    cp 144
    jr nz, WaitForVBlankStart
    ret

WaitForPaletteSwap::
    ld a, [rLY]
    cp $78
    jr c, WaitForPaletteSwap
    ret


; ClearOam
; Resets all OAM values to 0
ClearOam::
    xor a
    ld b, $A0
    ld hl, _OAMRAM
.clearOamLoop:
    ld [hl+], a
    dec b
    jr nz, ClearOam.clearOamLoop

    ld b, $A0
    ld hl, OAMBuffer
.clearOamBufferLoop:
    ld [hl+], a
    dec b
    jr nz, ClearOam.clearOamBufferLoop
    ret

InitPalettes:: 
    ; set palette loader to auto increment
    ld a, BCPSF_AUTOINC
    ld [rBCPS], a

    ; colors are at that label
    ld hl, BgPaletteData

    ; load 2 palettes of 4 colors
    ld c, 2 * 4

.rep:
    ; load full color
    ld a, [hl+]
    ld [rBCPD], a
    ld a, [hl+]
    ld [rBCPD], a

    dec c
    ld a, c
    cp a, 0
    jr nz, .rep

    ; set palette loader to auto increment
    ld a, OCPSF_AUTOINC
    ld [rOCPS], a

    ; colors are at that label
    ld hl, SpritePaletteData

    ; load 4 palettes of 4 colors
    ld c, 4 * 4

.rep2:
    ; load full color
    ld a, [hl+]
    ld [rOCPD], a
    ld a, [hl+]
    ld [rOCPD], a

    dec c
    ld a, c
    cp a, 0
    jr nz, .rep2

    ret

BgPaletteData::
    ; palette 1
    ; color 1
    ; GGGRRRRR
    db %10111100
    ; XBBBBBGG
    db %01110111
    ; color 2
    ; GGGRRRRR
    db %101_11101
    ; XBBBBBGG
    db %0_01001_11
    ; color 3
    ; GGGRRRRR
    db %000_10001
    ; XBBBBBGG
    db %0_01001_11
    ; color 4
    ; GGGRRRRR
    db %000_00000
    ; XBBBBBGG
    db %0_00000_00
    ; palette 2
    ; color 1
    ; GGGRRRRR
    db %000_00000
    ; XBBBBBGG
    db %0_00000_00
    ; color 2
    ; GGGRRRRR
    db %000_00000
    ; XBBBBBGG
    db %0_00000_00
    ; color 3
    ; GGGRRRRR
    db %000_00000
    ; XBBBBBGG
    db %0_00000_00
    ; color 4
    ; GGGRRRRR
    db %000_00000
    ; XBBBBBGG
    db %0_00000_00

SpritePaletteData::
    ; palette 1 (player)
    ; color 1 (transparent)
    ; GGGRRRRR
    db %00000000
    ; XBBBBBGG
    db %00000000
    ; color 2
    ; GGGRRRRR
    db %01011000
    ; XBBBBBGG
    db %01000011
    ; color 3
    ; GGGRRRRR
    db %000_10001
    ; XBBBBBGG
    db %0_01001_11
    ; color 4
    ; GGGRRRRR
    db %000_00000
    ; XBBBBBGG
    db %0_00000_00

    ; palette 2 (enemy)
    ; color 1 (transparent)
    ; GGGRRRRR
    db %00000000
    ; XBBBBBGG
    db %00000000
    ; color 2
    ; GGGRRRRR
    db %01111001
    ; XBBBBBGG
    db %01010010
    ; color 3
    ; GGGRRRRR
    db %11011110
    ; XBBBBBGG
    db %00101000
    ; color 4
    ; GGGRRRRR
    db %01000011
    ; XBBBBBGG
    db %00001000

    ; palette 3 (shield)
    ; color 1 (transparent)
    ; GGGRRRRR
    db %00000000
    ; XBBBBBGG
    db %00000000
    ; color 2
    ; GGGRRRRR
    db %00000111
    ; XBBBBBGG
    db %01101111
    ; color 3
    ; GGGRRRRR
    db %01100010
    ; XBBBBBGG
    db %01100000
    ; color 4 (not used)
    ; GGGRRRRR
    db %00000000
    ; XBBBBBGG
    db %00000000

    ; palette 4 (effects)
    ; color 1 (transparent)
    ; GGGRRRRR
    db %00000000
    ; XBBBBBGG
    db %00000000
    ; color 2
    ; GGGRRRRR
    db %10110011
    ; XBBBBBGG
    db %01010010
    ; color 3 (not used)
    ; GGGRRRRR
    db %00000000
    ; XBBBBBGG
    db %00000000
    ; color 4 (not used)
    ; GGGRRRRR
    db %00000000
    ; XBBBBBGG
    db %00000000



; @param hl - palette id
SetPalette::
    ld a, [wGameboyColor]
    cp a, 1
    jp z, .color
    ; gameboy classic here

    ; load palette from id
    ld a, [hl]
    ; set current palette
    ld [rBGP], a

    jp .end
.color
    ; gameboy color here

.end
    ret

; UpdateKeys
; Updates wKeysPressed variable, storing information about keys pressed to bits:
; %000000001 ($01) - A key
; %000000010 ($02) - B key
; %000000100 ($04) - START key
; %000001000 ($08) - SELECT key
; %000010000 ($10) - RIGHT key
; %000100000 ($20) - LEFT key
; %001000000 ($40) - UP key
; %010000000 ($80) - DOWN key
; use PADF_{key} define from hardware.inc
UpdateKeys::
    ld a, P1F_GET_BTN
    ldh [rP1], a

    call PollKeys

    or a, $F0
    ld b, a

    ld a, P1F_GET_DPAD
    ldh [rP1], a

    call PollKeys

    or a, $F0
    swap a
    xor a, b
    

    ld [wKeysPressed], a

    ld a, P1F_GET_NONE
    ldh [rP1], a
    ret

; PollKeys
; Polls keys enough times
PollKeys::
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ret

; Rng
; @return a the random number
Rng::
    ld a, [rTIMA] ; xD
    ret

PaletteNormalDGB::
    db %11100100
PaletteInvertedDGB::
    db %00011011
PaletteDarkDGB::
    db %1111_0101

SECTION "HardwareInfo", WRAM0

wGameboyColor:: db

SECTION "VariablesMovement", WRAM0

wKeysPressed:: db

SECTION "OAM DMA", HRAM

hOAMDMA:: ds DMATransferEnd - DMATransfer