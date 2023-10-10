INCLUDE "include/hardware.inc/hardware.inc"

; TODO move music to the end of frame

SECTION "Entry", ROM0[$100]
  jr EntryPoint 
  ds $150-@, 0 ; Space for the header

EntryPoint::
    call StateInit

    ; The program counter should neve reach here. In case it ever does, resetting the game.
    call EntryPoint
