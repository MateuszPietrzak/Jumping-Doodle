DEF DOUBLE_JUMP_WEIGHT  EQU 90 ; 90
DEF DASH_WEIGHT         EQU 60 ; 150
DEF GROUND_POUND_WEIGHT EQU 50 ; 200
DEF SHIELD_WEIGHT       EQU 35 ; 235
DEF JETPACK_WEIGHT      EQU 10 ; 245
DEF REVIVE_WEIGHT       EQU 10 ; 255 (in reality this one is just the remaining weight to 255)
DEF DOUBLE_JUMP_ID      EQU $30
DEF DASH_ID             EQU $31
DEF GROUND_POUND_ID     EQU $32
DEF SHIELD_ID           EQU $33
DEF JETPACK_ID          EQU $34
DEF REVIVE_ID           EQU $35


SECTION "PowerUP", ROM0

PowerUpInit::
    ; xor a
    ld a, SHIELD_ID
    ld [wInventory], a
    ld [wInventory + 1], a

    ld a, 20
    ld [wLastPowerUp], a
    ld [wLastSwap], a

    xor a
    ld [wDashLength], a
    ld [wJetpackLength], a
    ld [wShieldLength], a
    ld [wJetpackFlags], a
    ld [wPowerJump], a

    ret

PickupPowerUP::
    ; take random number
    call Rng

.caseDoubleJump:
    cp a, DOUBLE_JUMP_WEIGHT
    jp nc, .caseDash

    ld b, DOUBLE_JUMP_ID
    call InputItem

    jp .caseEnd
.caseDash:
    cp a, DOUBLE_JUMP_WEIGHT + DASH_WEIGHT
    jp nc, .caseGroundPound

    ld b, DASH_ID
    call InputItem

    jp .caseEnd
.caseGroundPound:
    cp a, DOUBLE_JUMP_WEIGHT + DASH_WEIGHT + GROUND_POUND_WEIGHT
    jp nc, .caseShield

    ld b, GROUND_POUND_ID
    call InputItem

    jp .caseEnd
.caseShield:
    cp a, DOUBLE_JUMP_WEIGHT + DASH_WEIGHT + GROUND_POUND_WEIGHT + SHIELD_WEIGHT
    jp nc, .caseJetPack

    ld b, SHIELD_ID
    call InputItem

    jp .caseEnd
.caseJetPack:
    cp a, DOUBLE_JUMP_WEIGHT + DASH_WEIGHT + GROUND_POUND_WEIGHT + SHIELD_WEIGHT + JETPACK_WEIGHT
    jp nc, .caseRevive

    ld b, JETPACK_ID
    call InputItem

    jp .caseEnd
.caseRevive:
    ld b, REVIVE_ID
    call InputItem
.caseEnd:

    ret

; inputs item into invenotory
; @param b - powerup ID
InputItem::
    ; check if first slot empty
    ld a, [wInventory]
    cp a, $0
    jp nz, .checkSecondSlot

    ld a, b
    ld [wInventory], a

    ; PLAY DOING
    ld bc, PowerUPSoundChannel_1
    call StartSoundEffect

    jp .end
    
.checkSecondSlot:
    ; check if second slot empty
    ld a, [wInventory + 1]
    cp a, $0
    jp nz, .end
    
    ld a, b
    ld [wInventory + 1], a

    ; PLAY DOING
    ld bc, PowerUPSoundChannel_1
    call StartSoundEffect

    jp .end
    
.end:

    ret

; uses ability
; @param a, which item to use
UseAbility::
    cp a, 0
    jp nz, .secondItem
    ; first item
    ; check if player has item
    ld a, [wInventory]
    cp a, 0
    ret z

    ld b, a
    xor a
    ld [wInventory], a
    ld a, b

    jp .caseDoubleJump

.secondItem

    ; first item
    ; check if player has item
    ld a, [wInventory + 1]
    cp a, 0
    ret z

    ld b, a
    xor a
    ld [wInventory+ 1], a
    ld a, b

.caseDoubleJump:
    cp a, DOUBLE_JUMP_ID
    jp nz, .caseDash

    ; add vertical velocity
    ld a, $A0 
    ld [wPlayerVelocityY], a

    jp .caseEnd
.caseDash:
    cp a, DASH_ID
    jp nz, .caseGroundPound

    xor a
    ld [wPlayerVelocityY], a

    ld a, [wPlayerVelocityX]
    add a, $20
    ld [wPlayerVelocityX], a

    ld a, 20
    ld [wDashLength], a

    jp .caseEnd
.caseGroundPound:
    cp a, GROUND_POUND_ID
    jp nz, .caseShield

    ld a, $0A                   ; next jump will be more powerful
    ld [wPowerJump], a

    ld a, $20                   ; set negative velocity
    ld [wPlayerVelocityY], a

    jp .caseEnd
.caseShield:
    cp a, SHIELD_ID
    jp nz, .caseJetPack

    ld a, 255
    ld [wShieldLength], a

    jp .caseEnd
.caseJetPack:
    cp a, JETPACK_ID
    jp nz, .caseRevive

    ld a, 120
    ld [wJetpackLength], a

    jp .caseEnd
.caseRevive:
    cp a, REVIVE_ID
    jp nz, .caseEnd ; if this is used something went wrong

    jp .caseEnd
.caseEnd:
    
    ld a, 10
    ld [wLastPowerUp], a

    ret

SECTION "Inventory", WRAM0

wInventory::
    ds 2
wLastSwap::
    ds 1
wLastPowerUp::
    ds 1
wDashLength::
    ds 1
wJetpackLength::
    ds 1
wShieldLength::
    ds 1
wPowerJump::
    ds 1
