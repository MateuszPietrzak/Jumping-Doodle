# Jumping Doodle
![scr_349](https://github.com/MateuszPietrzak/Jumping-Doodle/assets/60319969/d17c590f-95ca-48d7-901e-bb499e16dfa8)
---
## Description
A clone of some other popular game, downported for a Game Boy and Game Boy Color (both supported).
Its features include:
- Physics counted in subpixels
- Powerup system
- Enemies
- Persistent scoreboard saving
## How to play
The game can be played on original hardware with a development cartridge or cartridge flasher, though an emulator could be a better choice.
Some of the tested emulators include:
- Mesen2
- Emulicious
- SkyEmu

The doodle cannot be stopped when its movement is started.
You can move left and right using the D-Pad.
You can use powerups from the two slots using B and A.

### Powerups description
#### Jetpack
Allows you to fly up freely for 2 seconds.
#### Shield
Shields you from enemies for about 4 seconds.
#### Double jump
Allows jumping mid-air.
#### Dash
Sends the player sideways. Can be canceled by reversing direction.
#### Ground-pound
Sends the player down, making the next jump a super jump!

## Building from source
Prerequisites:
- RGBDS (https://rgbds.gbdev.io/)
```
git clone https://github.com/MateuszPietrzak/Jumping-Doodle.git
cd Jumping-Doodle
make
```
The Game Boy executable will be available at `bin/jumpingDoodle.gb`.
