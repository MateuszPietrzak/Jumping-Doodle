INCLUDE "include/hardware.inc/hardware.inc"

SECTION "entry", ROM0[$100]
  jp EntryPoint 
  ds $150-@, 0 ; Space for the header

EntryPoint::
    call StateInit

    ; The program counter should neve reach here. In case it ever does, resetting the game.
    call EntryPoint