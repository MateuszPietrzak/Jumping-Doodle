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
    xor a
    ; ld a, JETPACK_ID
    ld [wInventory], a
    ld [wInventory + 1], a

    ld a, 20
    ld [wLastPowerUp], a
    ld [wLastSwap], a

    xor a
    ld [wDashLength], a
    ld [wJetpackLength], a

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
    jp .end
    
.checkSecondSlot:
    ; check if second slot empty
    ld a, [wInventory + 1]
    cp a, $0
    jp nz, .end
    
    ld a, b
    ld [wInventory + 1], a
    jp .end
    
.end:

    ret


UseAbility::
    ; check if player has item
    ld a, [wInventory]
    cp a, 0
    ret z

.caseDoubleJump:
    cp a, DOUBLE_JUMP_ID
    jp nz, .caseDash

    ld a, [wCollisionFlag] ; set the flag for jump
    or a, $1
    ld [wCollisionFlag], a

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

    ld a, $20                   ; set negative velocity
    ld [wPlayerVelocityY], a

    jp .caseEnd
.caseShield:
    cp a, SHIELD_ID
    jp nz, .caseJetPack

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
    
    ; remove that powerup and move second slot to first
    ld a, [wInventory + 1]
    ld [wInventory], a
    xor a
    ld [wInventory + 1], a
    
    ld a, 20
    ld [wLastPowerUp], a

    ret

SwitchAbilities::
    ; check for first slot
    ld a, [wInventory]
    cp a, 0
    ret z

    ; save first
    ld b, a
    ; check for second
    ld a, [wInventory + 1]
    cp a, 0
    ret z

    ; swap items if both present
    ld [wInventory], a
    ld a, b
    ld [wInventory + 1], a

    ld a, 20
    ld [wLastSwap], a

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
