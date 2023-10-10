INCLUDE "include/hardware.inc/hardware.inc"

SECTION "Enemy", ROM0

InitEnemy::
    ld de,EnemyTiles 
    ld hl, _VRAM8000 +  $10
    ld bc, EnemyTiles.end - EnemyTiles 
    call Memcpy
    ret

ResetEnemyState:: 
    call WaitForVBlank
    
    ; Set proper tiles
    ld a, $1
    ld [_OAMRAM + 6], a
    inc a
    ld [_OAMRAM + 10], a

    ret

HandleEnemyVBlank::
    ret

HandleEnemy::
    ret

EnemyBufferToOAM::
    ret

SECTION "EnemyTiles", ROM0

EnemyTiles:
   incbin "assets/Fly.2bpp"
.end:

SECTION "EnemyData", WRAM0

wAcualEnemyX: ds
wAcualEnemyY: ds