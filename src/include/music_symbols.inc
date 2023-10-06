; Channel Notes

DEF C3  EQU 1046
DEF C3s EQU 1102
DEF D3  EQU 1155
DEF D3s EQU 1205
DEF E3  EQU 1253
DEF F3  EQU 1297
DEF F3s EQU 1339
DEF G3  EQU 1379
DEF G3s EQU 1417
DEF A3  EQU 1452
DEF A3s EQU 1486
DEF B3  EQU 1517
DEF C4  EQU 1547
DEF C4s EQU 1575
DEF D4  EQU 1602
DEF D4s EQU 1627
DEF E4  EQU 1650
DEF F4  EQU 1673
DEF F4s EQU 1694
DEF G4  EQU 1714
DEF G4s EQU 1732
DEF A4  EQU 1750
DEF A4s EQU 1767
DEF B4  EQU 1783
DEF C5  EQU 1798
DEF C5s EQU 1812
DEF D5  EQU 1825
DEF D5s EQU 1837
DEF E5  EQU 1849
DEF F5  EQU 1860
DEF F5s EQU 1871
DEF G5  EQU 1881
DEF G5s EQU 1890
DEF A5  EQU 1899
DEF A5s EQU 1907
DEF B5  EQU 1915


; DrumNotes

DEF dB8  EQU $34
DEF dG8s EQU $35 ;
DEF dF8  EQU $36 
DEF dD8  EQU $37 ;
DEF dC8  EQU $44 
DEF dG7s EQU $45 ;
DEF dF7  EQU $46 
DEF dD7  EQU $47 ;
DEF dC7  EQU $54 
DEF dG6s EQU $55 
DEF dF6  EQU $56 
DEF dD6  EQU $57 
DEF dC6  EQU $64 
DEF dG5s EQU $65
DEF dF5  EQU $66
DEF dD5  EQU $67
DEF dC5  EQU $74
DEF dG4s EQU $75
DEF dF4  EQU $76
DEF dD4  EQU $77
DEF dC4  EQU $84
DEF dG3s EQU $85
DEF dF3  EQU $86
DEF dD3  EQU $87
DEF dC3  EQU $94
DEF dG2s EQU $95
DEF dF2  EQU $96
DEF dD2  EQU $97
DEF dC2  EQU $A4


; Music shee commands

DEF NOTE            EQU $01
DEF VIB             EQU $A1
DEF LOOP            EQU $EE
DEF END             EQU $FF
DEF VOL_MAX         EQU $F8
DEF VOL_34          EQU $C8
DEF VOL_24          EQU $88
DEF VOL_14          EQU $58
DEF VOL_MUTE        EQU $08
DEF VOL3_MAX        EQU $20
DEF VOL3_12         EQU $40
DEF VOL3_14         EQU $60
DEF VOL3_MUTE       EQU $00
DEF VOLD_MAX_S      EQU $D1
DEF VOLD_MAX_L      EQU $D2
DEF VOLD_MID_S      EQU $A1
DEF VOLD_MID_L      EQU $A2
DEF VOLD_MUTE       EQU $00

DEF NL              EQU 12      ; note length
DEF hNL             EQU 6       ; half note length
DEF START_PAUSE     EQU $30     ; pause for the music chip to initialize