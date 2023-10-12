DEF DOUBLE_JUMP_WEIGHT  EQU 80 ; 80
DEF DASH_WEIGHT         EQU 80 ; 160
DEF GROUND_POUND_WEIGHT EQU 40 ; 200
DEF SHIELD_WEIGHT       EQU 20 ; 220
DEF JETPACK_WEIGHT      EQU 20 ; 240
DEF REVIVE_WEIGHT       EQU 15 ; 255 (in reality this one is just the remaining weight to 255)
DEF DOUBLE_JUMP_ID      EQU 01
DEF DASH_ID             EQU 02
DEF GROUND_POUND_ID     EQU 03
DEF SHIELD_ID           EQU 04
DEF JETPACK_ID          EQU 05
DEF REVIVE_ID           EQU 06


SECTION "PowerUP", ROM0

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
    ld [wInventory], a
    jp .end
    
.end:

    ret


SECTION "Inventory", WRAM0

wInventory::
    ds 2
