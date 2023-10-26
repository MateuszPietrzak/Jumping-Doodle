INCLUDE "include/hardware.inc/hardware.inc"

; TODO move music to the end of frame

SECTION "Entry", ROM0[$100]
  nop

  jp EntryPoint 
  ds $150-@, 0 ; Space for the header

EntryPoint::
    cp a, $11
    jr nz, .gameboyClassic
    
    ld a, 1
    ld [wGameboyColor], a
    
.gameboyClassic:
    
    xor a
    ld [wGameboyColor], a

.endCheck:

    call StateInit

    ; The program counter should neve reach here. In case it ever does, resetting the game.
    call EntryPoint
