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
    ret

; GenerateStripe
; Generates game stripe, using 
; wGeneratePositionY
GenerateStripe::
    ; Calculate where to put the platform x-position capped at 16
    call Rng
    and a, %00000111
    inc a
    ld [wGenerateLinePositionX], a

    xor a
    ld h, a
    ld a, [wGenerateLinePositionY]
    ld l, a

    add hl, hl ; hl*2
    add hl, hl ; hl*4
    add hl, hl ; hl*8
    add hl, hl ; hl*16
    add hl, hl ; hl*32

    push hl

    ld a, h
    add a, $98
    ld h, a
    ; Clear the stripe
    ld a, $14
.clearStripe:
    cp a, $0
    jr z, .clearStripeEnd

    ld [hl], $0
    inc hl
    dec a

    jr .clearStripe
.clearStripeEnd:

    pop hl
    ld a, l
    and a, $20
    cp a, $0
    ret z

    xor a    
    ld b, a
    ld a, [wGenerateLinePositionX]
    ld c, a
    add hl, bc
    ld a, h
    add a, $98
    ld h, a

    call GeneratePlatform
    inc hl
    
    ; Randomize offset between them
    call Rng
    and a, %00000111
.offsetLoop:
    cp a, $0
    jr z, .offsetLoopEnd

    dec a
    inc hl

    jr .offsetLoop
.offsetLoopEnd:

    call GeneratePlatform

    ret

; Generates platofrm
; @param hl place
GeneratePlatform::
    call Rng
    and a, $01
.caseNormal:
    cp a, $0
    jr nz, .caseFragile

    ld [hl], $40
    inc hl
    ld [hl], $41
    inc hl
    ret

.caseFragile:

    ld [hl], $42
    inc hl
    ld [hl], $43
    inc hl
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

SECTION "VariablesMovement", WRAM0

wKeysPressed:: db