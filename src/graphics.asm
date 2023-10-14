SECTION "Tiles", ROM0
GraphicTiles::
    incbin "assets/PlayerSprite.2bpp"
GraphicTilesEnd::

FontTiles::
    incbin "assets/font.2bpp"
FontTilesEnd::

SECTION "EnemyTiles", ROM0

EnemyTiles::
    incbin "assets/Fly.2bpp"
.end::

SECTION "BackgroundTilemap", ROM0

BackgroundTiles::
    incbin "assets/Platforms.2bpp"
.end::

MenuTiles::
    incbin "assets/ButtonsTiles.2bpp"
.end::

MenuTilemap::
    incbin "assets/MainMenuTilemap.2bpp"
.end::

PowerUpTiles::
    incbin "assets/powerups.2bpp"
.end::

ShieldTiles::
    incbin "assets/shield.2bpp"
.end::
    