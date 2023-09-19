SECTION "Utility", ROM0

; Memcpy
; Copies data from ROM to RAM
; @param de Beginning of data in ROM
; @param hl Deginning of target space in RAM
; @param bc data size
Memcpy:
    ld a, [de]
    ld [hl+], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, Memcpy
    ret

; WaitPorVBlank
; Waits until VBlank (duh)
WaitForVBlank:
    ld a, [rLY]
    cp 144
    jp c, WaitForVBlank
    ret


; ClearOam
; Resets all OAM values to 0
ClearOam:
    xor a
    ld b, $A0
    ld hl, _OAMRAM
.clearOamLoop:
    ld [hl+], a
    dec b
    jp nz, ClearOam.clearOamLoop
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
UpdateKeys:
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
PollKeys:
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

SECTION "Graphics", ROM0
graphicTiles:
    incbin "assets/PlayerSprite.2bpp"
.end:

SECTION "variables", wram0

wFrameCounter: db
wKeysPressed: db