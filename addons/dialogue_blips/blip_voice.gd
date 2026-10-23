@tool
class_name BlipVoice
extends Resource
## A character voice for DialogueBox: a few short syllable sounds that are played while text types,
## plus optional emote sounds (laugh, surprise, hmm, sad, angry).
##
## Make your own: create a new BlipVoice resource, drop in any short sounds as syllables and set
## pitch, jitter and how often it blips.

## Name shown in menus.
@export var display_name := ""
## Group the voice belongs to (Chip, Talk, Tone, Character, Critter, Synth or your own).
@export var group := ""
## Syllable sounds. A letter always picks the same syllable, so words sound the same each time.
@export var syllables: Array[AudioStream] = []
## Emote sounds by name, e.g. {"laugh": stream}. Played with DialogueBox.play_emote() or [emote=laugh].
@export var emotes: Dictionary = {}
## Base pitch multiplier for this voice.
@export_range(0.25, 4.0, 0.01) var pitch := 1.0
## Random pitch variation per blip (0.05 = +-5 %).
@export_range(0.0, 0.5, 0.005) var pitch_jitter := 0.04
## Play a blip every N letters (1 = every letter).
@export_range(1, 6) var blip_every := 2
## Volume offset in dB.
@export_range(-40.0, 12.0, 0.1) var volume_db := 0.0
## Stop the previous blip when the next one starts (good for long, ringing sounds at high speed).
@export var interrupt := false


func get_emote(emote_name: String) -> AudioStream:
	return emotes.get(emote_name, null)


func emote_names() -> PackedStringArray:
	var out := PackedStringArray()
	for k in emotes.keys():
		out.append(str(k))
	return out
