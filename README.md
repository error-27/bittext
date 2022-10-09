# BitText
 A small Godot plugin to make it easy to turn a PNG into a BitmapFont.
 
![GitHub all releases](https://img.shields.io/github/downloads/Error-In-Code/bittext/total?style=flat-square)
![GitHub](https://img.shields.io/github/license/Error-In-Code/bittext?style=flat-square)

## How to Use:
1. Open the BitText panel on the bottom dock
2. Click the "Load BitmapFont" or "New BitmapFont" button
3. If there is no spritesheet added (indicated by a preview on the right), add one with the "Load Spritesheet" button
4. Input the amount of characters horizontally and vertically there are on the spritesheet into the "H Characters" and "V Characters" fields (similar to configuring a spritesheet on a Sprite node)
5. Add ranges of characters. These are the different sets of characters in your spritesheet. These are calculated in order of the Unicode table, so make sure your spritesheet is in that order.
6. Add kerning values to modify spacing between sets of letters. This is specifically the spacing between letters when the characters are in the order the kerning pair is in. Kerning between "W" and "M" is separate from kerning between "M" and "W".
7. Press the save button in the upper right corner to save your font to your project file system. If you save it to a pre-existing resource, reload your project files (Godot bug, not a plugin bug).
