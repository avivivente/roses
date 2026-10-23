@tool
class_name DialogueStyle
extends Resource
## Look of a DialogueBox: a nine-slice panel texture, a name plate texture, fonts and colours.

@export var display_name := ""
@export_group("Panel")
## Nine-slice texture of the main box.
@export var panel_texture: Texture2D
## Size of the nine-slice corners in pixels.
@export var panel_margin := 48
## Text padding inside the box: left, top, right, bottom.
@export var padding := Vector4i(40, 30, 40, 30)
@export_group("Name plate")
@export var nameplate_texture: Texture2D
@export var nameplate_margin := 24
@export var nameplate_padding := Vector4i(22, 10, 22, 10)
@export_group("Drawing")
## Tile the inside of the texture (textured styles) instead of stretching it.
@export var tile := false
## Use nearest-neighbour filtering (pixel-art styles).
@export var pixel_art := false
@export_group("Text")
## Leave empty to use the project's default font.
@export var font: Font
@export var font_size := 26
@export var name_font: Font
@export var name_font_size := 22
## Draw the default font a little bolder.
@export var bold := false
@export var text_color := Color.WHITE
@export var name_color := Color.WHITE
## Next-arrow and choice highlight colour.
@export var accent_color := Color.WHITE
@export_group("Sounds")
## Interface sound set: "soft", "chip" or "" for none.
@export var ui_sounds := "soft"
