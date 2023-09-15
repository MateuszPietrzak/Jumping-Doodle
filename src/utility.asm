SECTION "Utility", ROM0

Memcpy:
    ld a, [de]
    ld [hl+], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, Memcpy
    ret

WaitForVBlank:
    ld a, [rLY]
    cp 144
    jp c, WaitForVBlank
    ret

ClearOam:
    xor a
    ld b, $A0
    ld hl, _OAMRAM
.clearOamLoop:
    ld [hl+], a
    dec b
    jp nz, ClearOam.clearOamLoop
    ret

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