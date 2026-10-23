class_name DialogueBox
extends Control
## Typewriter dialogue box that "talks": every few letters it plays a syllable of the speaker's BlipVoice.
##
## Quick use:
##   await $DialogueBox.say("Hello there!", "Robo", "char_robot")
##   var pick: int = await $DialogueBox.ask("Coffee or tea?", ["Coffee", "Tea"])
##   await $DialogueBox.play([{"speaker": "Ann", "voice": "talk_soft", "text": "Hi!"}, "Next line, same speaker."])
##
## Inline tags (besides normal BBCode such as [b], [color], [wave], [shake]):
##   [speed=2] [/speed]  type faster/slower    [wait=0.5]  pause
##   [pitch=1.3] [/pitch] raise/lower the voice [emote=laugh] play an emote sound
##   [voice=char_robot]  switch voice mid-line

signal line_started(text: String)
signal blip_played(character: String)
signal line_finished
signal advanced
signal choice_made(index: int, text: String)
signal conversation_finished
signal opened
signal closed

enum State { CLOSED, IDLE, TYPING, WAITING, CHOOSING }

const VOICE_DIR := "voices"
const STYLE_DIR := "styles"

## Voice used for blips. Setting voice_name loads one of the bundled voices by name.
@export var voice: BlipVoice
@export var voice_name := "":
	set(v):
		voice_name = v
		if v != "":
			var loaded := DialogueBox.load_voice(v)
			if loaded:
				voice = loaded
## Look of the box. Setting style_name loads one of the bundled styles by name.
@export var style: DialogueStyle:
	set(v):
		style = v
		if is_node_ready():
			_apply_style()
@export var style_name := "classic":
	set(v):
		style_name = v
		var loaded := DialogueBox.load_style(v)
		if loaded:
			style = loaded

@export_group("Typing")
@export_range(1.0, 400.0, 1.0) var characters_per_second := 40.0
## Pause after , ; : and after . ! ? (seconds).
@export var comma_pause := 0.12
@export var stop_pause := 0.3
## Pitch multiplier on top of the voice's own pitch (one voice can serve several characters).
@export_range(0.25, 4.0, 0.01) var pitch_scale := 1.0
## A letter always uses the same syllable (words sound the same every time).
@export var same_syllable_per_letter := true
## How much the last word before a question mark rises in pitch.
@export_range(0.0, 0.6, 0.01) var question_rise := 0.15
## Go to the next line by itself after this delay (0 = wait for the player).
@export var auto_advance_delay := 0.0

@export_group("Input")
@export var advance_action: StringName = &"ui_accept"
@export var click_to_advance := true

@export_group("Portrait")
@export var portrait_size := 132
@export var portrait_on_right := false
## Bounce (or swap to the talking frame) on every blip.
@export var talking_portrait := true

@export_group("Box")
@export var animate_open_close := true
@export var close_when_done := true
@export var ui_sounds_enabled := true
@export var audio_bus: StringName = &"Master"
@export_range(-40.0, 12.0, 0.1) var volume_db := 0.0

var state: State = State.CLOSED

var _panel: PanelContainer
var _row: HBoxContainer
var _portrait_frame: PanelContainer
var _portrait: TextureRect
var _text: RichTextLabel
var _name_plate: PanelContainer
var _name_label: Label
var _arrow: _NextArrow
var _choice_panel: PanelContainer
var _choice_box: VBoxContainer
var _players: Array[AudioStreamPlayer] = []
var _ui_player: AudioStreamPlayer
var _next_player := 0
var _rng := RandomNumberGenerator.new()

var _plain := ""
var _events := {}
var _rise := PackedFloat32Array()
var _shown := 0
var _total := 0
var _acc := 0.0
var _wait := 0.0
var _speed := 1.0
var _tag_pitch := 1.0
var _letters := 0
var _line_voice: BlipVoice
var _portrait_idle: Texture2D
var _portrait_talk: Texture2D
var _talk_timer := 0.0
var _bounce := 0.0
var _auto_timer := 0.0
var _scale_tween: Tween
var _serial := 0


static func addon_dir() -> String:
	return (DialogueBox as Script).resource_path.get_base_dir()


## Load a bundled voice by name, e.g. "talk_soft". Returns null if it does not exist.
static func load_voice(voice_id: String) -> BlipVoice:
	var p := "%s/%s/%s.tres" % [addon_dir(), VOICE_DIR, voice_id]
	if ResourceLoader.exists(p):
		return load(p) as BlipVoice
	return null


## Load a bundled style by name, e.g. "parchment". Returns null if it does not exist.
static func load_style(style_id: String) -> DialogueStyle:
	var p := "%s/%s/%s/%s.tres" % [addon_dir(), STYLE_DIR, style_id, style_id]
	if ResourceLoader.exists(p):
		return load(p) as DialogueStyle
	return null


func _ready() -> void:
	_rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	if style == null:
		style = DialogueBox.load_style(style_name)
	_apply_style()
	if not Engine.is_editor_hint():
		visible = false
		state = State.CLOSED


func _build() -> void:
	for _i in 4:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	_ui_player = AudioStreamPlayer.new()
	add_child(_ui_player)

	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)
	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", 20)
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_row)
	_portrait_frame = PanelContainer.new()
	_portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_row.add_child(_portrait_frame)
	_portrait = TextureRect.new()
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_frame.add_child(_portrait)
	_portrait_frame.visible = false
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.scroll_active = false
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.add_child(_text)

	_name_plate = PanelContainer.new()
	_name_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_name_plate)
	_name_label = Label.new()
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name_plate.add_child(_name_label)
	_name_plate.visible = false

	_arrow = _NextArrow.new()
	_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_arrow)
	_arrow.visible = false

	_choice_panel = PanelContainer.new()
	add_child(_choice_panel)
	_choice_box = VBoxContainer.new()
	_choice_box.add_theme_constant_override("separation", 4)
	_choice_panel.add_child(_choice_box)
	_choice_panel.visible = false
	resized.connect(_layout)


func _stylebox(tex: Texture2D, margin: int, pad: Vector4i) -> StyleBox:
	if tex == null:
		var flat := StyleBoxFlat.new()
		flat.bg_color = Color(0.08, 0.09, 0.14, 0.92)
		flat.set_corner_radius_all(10)
		flat.set_content_margin_all(16)
		return flat
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.texture_margin_left = margin
	sb.texture_margin_top = margin
	sb.texture_margin_right = margin
	sb.texture_margin_bottom = margin
	var mode := StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT if style and style.tile else StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	sb.axis_stretch_horizontal = mode
	sb.axis_stretch_vertical = mode
	sb.content_margin_left = pad.x
	sb.content_margin_top = pad.y
	sb.content_margin_right = pad.z
	sb.content_margin_bottom = pad.w
	return sb


func _font_for(f: Font) -> Font:
	if f:
		if f is FontFile and (f as FontFile).fallbacks.is_empty():
			(f as FontFile).fallbacks = [ThemeDB.fallback_font]
		return f
	if style and style.bold:
		var fv := FontVariation.new()
		fv.base_font = ThemeDB.fallback_font
		fv.variation_embolden = 0.6
		return fv
	return null


func _apply_style() -> void:
	if _panel == null or style == null:
		return
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if style.pixel_art else CanvasItem.TEXTURE_FILTER_LINEAR
	_panel.add_theme_stylebox_override("panel", _stylebox(style.panel_texture, style.panel_margin, style.padding))
	var plate := _stylebox(style.nameplate_texture, style.nameplate_margin, style.nameplate_padding)
	_name_plate.add_theme_stylebox_override("panel", plate)
	_portrait_frame.add_theme_stylebox_override("panel", _stylebox(style.nameplate_texture, style.nameplate_margin, Vector4i(10, 10, 10, 10)))
	_choice_panel.add_theme_stylebox_override("panel", _stylebox(style.panel_texture, style.panel_margin, Vector4i(style.padding.x - 8, style.padding.y - 8, style.padding.z - 8, style.padding.w - 8)))
	var f := _font_for(style.font)
	for k in ["normal_font", "bold_font", "italics_font", "bold_italics_font"]:
		if f:
			_text.add_theme_font_override(k, f)
		else:
			_text.remove_theme_font_override(k)
	for k in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]:
		_text.add_theme_font_size_override(k, style.font_size)
	_text.add_theme_color_override("default_color", style.text_color)
	var nf := _font_for(style.name_font)
	if nf:
		_name_label.add_theme_font_override("font", nf)
	else:
		_name_label.remove_theme_font_override("font")
	_name_label.add_theme_font_size_override("font_size", style.name_font_size)
	_name_label.add_theme_color_override("font_color", style.name_color)
	_arrow.color = style.accent_color
	_arrow.pixel = style.pixel_art
	for b in _choice_box.get_children():
		_style_choice(b as Button)
	_layout()


func _layout() -> void:
	if _panel == null:
		return
	_portrait_frame.custom_minimum_size = Vector2(portrait_size, portrait_size)
	_row.move_child(_portrait_frame, 1 if portrait_on_right else 0)
	_name_plate.reset_size()
	var ps := _name_plate.get_combined_minimum_size()
	var x := 24.0 if not portrait_on_right else size.x - ps.x - 24.0
	_name_plate.position = Vector2(x, -ps.y * 0.62)
	var a := 22.0
	var pad_r := float(style.padding.z) if style else 30.0
	var pad_b := float(style.padding.w) if style else 24.0
	_arrow.size = Vector2(a, a)
	_arrow.position = Vector2(size.x - pad_r * 0.75 - a * 0.5, size.y - pad_b * 0.7 - a * 0.5)
	_choice_panel.reset_size()
	var cs := _choice_panel.get_combined_minimum_size()
	_choice_panel.position = Vector2(size.x - cs.x - 8.0, -cs.y - 12.0)
	pivot_offset = Vector2(size.x * 0.5, size.y)


# ------------------------------------------------------------------ public API

## Show a line and wait until the player advances (or auto-advance). voice_or_name: BlipVoice, a voice name or null (keep current).
func say(text: String, speaker := "", voice_or_name: Variant = null, portrait: Texture2D = null, portrait_talk: Texture2D = null) -> void:
	await show_line(text, speaker, voice_or_name, portrait, portrait_talk)
	if state == State.TYPING:
		await line_finished
	await advanced


## Show a line with choices; returns the chosen index.
func ask(text: String, choices: Array, speaker := "", voice_or_name: Variant = null, portrait: Texture2D = null, portrait_talk: Texture2D = null) -> int:
	await show_line(text, speaker, voice_or_name, portrait, portrait_talk)
	if state == State.TYPING:
		await line_finished
	_show_choices(choices)
	var res: Array = await choice_made
	return int(res[0])


## Play a list of lines. Items are Strings or Dictionaries with keys:
## text, speaker, voice, portrait, portrait_talk, style, pitch, speed, choices, emote.
## Returns the index of the last choice made (or -1).
func play(lines: Array) -> int:
	var last := -1
	var speaker := ""
	var pt: Texture2D = null
	var pt_talk: Texture2D = null
	var cur_voice: Variant = null
	for item in lines:
		if item is String:
			await say(item, speaker, cur_voice, pt, pt_talk)
			continue
		var d: Dictionary = item
		if d.has("speaker") and d["speaker"] != speaker and not d.has("portrait"):
			pt = null
			pt_talk = null
		speaker = d.get("speaker", speaker)
		pt = d.get("portrait", pt)
		pt_talk = d.get("portrait_talk", pt_talk if d.get("portrait", null) == null else null)
		if d.has("style"):
			style_name = d["style"]
		if d.has("pitch"):
			pitch_scale = float(d["pitch"])
		if d.has("speed"):
			characters_per_second = float(d["speed"])
		if d.has("voice"):
			cur_voice = d["voice"]
		if d.has("emote"):
			_set_line_voice(cur_voice)
			play_emote(str(d["emote"]))
		if d.has("choices"):
			last = await ask(d.get("text", ""), d["choices"], speaker, cur_voice, pt, pt_talk)
		else:
			await say(d.get("text", ""), speaker, cur_voice, pt, pt_talk)
	conversation_finished.emit()
	if close_when_done:
		await close()
	return last


## Start typing a line without waiting for the player. Use the line_finished / advanced signals.
func show_line(text: String, speaker := "", voice_or_name: Variant = null, portrait: Texture2D = null, portrait_talk: Texture2D = null) -> void:
	_serial += 1
	var my := _serial
	if state == State.CLOSED:
		await open()
		if my != _serial:
			return
	_set_line_voice(voice_or_name)
	_name_label.text = speaker
	_name_plate.visible = speaker != ""
	_portrait_idle = portrait
	_portrait_talk = portrait_talk
	_portrait.texture = portrait
	_portrait_frame.visible = portrait != null
	_choice_panel.visible = false
	_arrow.visible = false
	_parse(text)
	_shown = 0
	_acc = 0.0
	_wait = 0.0
	_speed = 1.0
	_tag_pitch = 1.0
	_letters = 0
	_auto_timer = 0.0
	_text.visible_characters = 0
	state = State.TYPING
	_layout()
	line_started.emit(_plain)
	_process_events_at(0)


## Finish the current line at once (what the advance key does while typing).
func skip_typing() -> void:
	if state != State.TYPING:
		return
	while _shown < _total:
		_process_events_at(_shown, true)
		_shown += 1
	_process_events_at(_total, true)
	_text.visible_characters = -1
	_finish_line()


## Advance: finish typing, or go on to the next line.
func advance() -> void:
	if state == State.TYPING:
		skip_typing()
	elif state == State.WAITING:
		state = State.IDLE
		_arrow.visible = false
		_ui("next")
		advanced.emit()


func open() -> void:
	if state != State.CLOSED:
		return
	visible = true
	state = State.IDLE
	_text.text = ""
	_layout()
	_ui("open")
	if animate_open_close:
		_kill_tween()
		scale = Vector2(0.92, 0.6)
		modulate.a = 0.0
		_scale_tween = create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_scale_tween.tween_property(self, "scale", Vector2.ONE, 0.2)
		_scale_tween.tween_property(self, "modulate:a", 1.0, 0.12)
		await _scale_tween.finished
	opened.emit()


func close() -> void:
	if state == State.CLOSED:
		return
	state = State.CLOSED
	_choice_panel.visible = false
	_arrow.visible = false
	_ui("close")
	if animate_open_close:
		_kill_tween()
		_scale_tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		_scale_tween.tween_property(self, "scale", Vector2(0.95, 0.7), 0.14)
		_scale_tween.tween_property(self, "modulate:a", 0.0, 0.14)
		await _scale_tween.finished
	visible = false
	scale = Vector2.ONE
	modulate.a = 1.0
	closed.emit()


## Close at once, no animation or sound.
func hide_now() -> void:
	_kill_tween()
	state = State.CLOSED
	visible = false
	scale = Vector2.ONE
	modulate.a = 1.0


## Play an emote sound of the current voice: laugh, surprise, hmm, sad, angry.
func play_emote(emote_name: String) -> void:
	var v := _line_voice if _line_voice else voice
	if v == null:
		return
	var s := v.get_emote(emote_name)
	if s:
		_play(s, v.pitch * pitch_scale, v.volume_db)
		_bounce = 1.0
		_talk_timer = 0.25


## Play one blip of the current voice (for menus, previews, your own effects).
func play_blip(character := "a") -> void:
	var v := _line_voice if _line_voice else voice
	if v == null or v.syllables.is_empty():
		return
	_play(v.syllables[_syllable_index(v, character)], v.pitch * pitch_scale, v.volume_db)


func is_typing() -> bool:
	return state == State.TYPING


func is_open() -> bool:
	return state != State.CLOSED


# ------------------------------------------------------------------ internals

func _kill_tween() -> void:
	if _scale_tween and _scale_tween.is_valid():
		_scale_tween.kill()


func _set_line_voice(v: Variant) -> void:
	if v is BlipVoice:
		_line_voice = v
	elif v is String or v is StringName:
		var lv := DialogueBox.load_voice(str(v))
		_line_voice = lv if lv else voice
	else:
		_line_voice = voice


static var _re_custom: RegEx
static var _re_bb: RegEx


func _parse(text: String) -> void:
	if _re_custom == null:
		_re_custom = RegEx.create_from_string("\\[(speed|wait|emote|pitch|voice)=([^\\]]*)\\]|\\[/(speed|pitch)\\]")
		_re_bb = RegEx.create_from_string("\\[(?!lb\\]|rb\\])/?[a-zA-Z_][^\\[\\]]*\\]")
	_events = {}
	var clean := ""
	var last := 0
	for m in _re_custom.search_all(text):
		clean += text.substr(last, m.get_start() - last)
		var pos := _visible_len(clean)
		var ev: Array
		if m.get_string(1) != "":
			ev = [m.get_string(1), m.get_string(2)]
		else:
			ev = [m.get_string(3), ""]
		if not _events.has(pos):
			_events[pos] = []
		_events[pos].append(ev)
		last = m.get_end()
	clean += text.substr(last)
	_text.text = clean
	_plain = _strip(clean)
	_total = _text.get_total_character_count()
	if _total != _plain.length():
		_plain = _text.get_parsed_text()
		_total = mini(_total, _plain.length())
	_compute_rise()


func _strip(s: String) -> String:
	return _re_bb.sub(s, "", true).replace("[lb]", "[").replace("[rb]", "]")


func _visible_len(bb: String) -> int:
	return _strip(bb).length()


func _compute_rise() -> void:
	_rise = PackedFloat32Array()
	_rise.resize(_plain.length())
	_rise.fill(1.0)
	if question_rise <= 0.0:
		return
	for q in _plain.length():
		if _plain[q] != "?":
			continue
		var e := q - 1
		while e >= 0 and not _is_letter(_plain[e]):
			e -= 1
		var w := e
		while w > 0 and _is_letter(_plain[w - 1]):
			w -= 1
		if e < 0:
			continue
		var n := e - w + 1
		for k in range(w, e + 1):
			_rise[k] = 1.0 + question_rise * float(k - w + 1) / float(n)


static func _is_letter(c: String) -> bool:
	if c.is_empty():
		return false
	var u := c.unicode_at(0)
	return c.to_lower() != c.to_upper() or (u >= 48 and u <= 57) or u > 0x2E80


func _process_events_at(pos: int, skipping := false) -> void:
	if not _events.has(pos):
		return
	for ev in _events[pos]:
		match ev[0]:
			"speed":
				_speed = maxf(0.05, float(ev[1])) if ev[1] != "" else 1.0
			"wait":
				if not skipping:
					_wait += float(ev[1])
			"pitch":
				_tag_pitch = float(ev[1]) if ev[1] != "" else 1.0
			"emote":
				if not skipping:
					play_emote(ev[1])
			"voice":
				var lv := DialogueBox.load_voice(ev[1])
				if lv:
					_line_voice = lv
	_events.erase(pos)


func _process(delta: float) -> void:
	if _arrow and _arrow.visible:
		_arrow.queue_redraw()
	_animate_portrait(delta)
	if state == State.WAITING and auto_advance_delay > 0.0:
		_auto_timer += delta
		if _auto_timer >= auto_advance_delay:
			advance()
		return
	if state != State.TYPING:
		return
	if _wait > 0.0:
		_wait -= delta
		if _wait > 0.0:
			return
		delta = -_wait
		_wait = 0.0
	_acc += delta * characters_per_second * _speed
	while _acc >= 1.0 and _shown < _total:
		_acc -= 1.0
		var c := _plain[_shown]
		_shown += 1
		_text.visible_characters = _shown
		if _is_letter(c):
			_blip(c, _shown - 1)
		var nxt := _plain[_shown] if _shown < _total else ""
		var at_break := nxt == "" or nxt == " " or nxt == "\n" or nxt == "\"" or nxt == ")"
		if _shown < _total and at_break:
			if c in [",", ";", ":"]:
				_wait = comma_pause
			elif c in [".", "!", "?", "…"]:
				_wait = stop_pause
		_process_events_at(_shown)
		if _wait > 0.0:
			_acc = 0.0
			return
	if _shown >= _total:
		_process_events_at(_total)
		_finish_line()


func _finish_line() -> void:
	if state != State.TYPING:
		return
	_text.visible_characters = -1
	state = State.WAITING
	_auto_timer = 0.0
	_arrow.visible = true
	_portrait.texture = _portrait_idle
	line_finished.emit()


func _syllable_index(v: BlipVoice, c: String) -> int:
	var n := v.syllables.size()
	if same_syllable_per_letter:
		var u := c.to_lower().unicode_at(0)
		return (u * 7 + 3) % n
	return _rng.randi() % n


func _blip(c: String, idx: int) -> void:
	var v := _line_voice if _line_voice else voice
	if v == null or v.syllables.is_empty():
		return
	_letters += 1
	if (_letters - 1) % maxi(1, v.blip_every) != 0:
		return
	var p := v.pitch * pitch_scale * _tag_pitch * (1.0 + _rng.randf_range(-v.pitch_jitter, v.pitch_jitter))
	if idx < _rise.size():
		p *= _rise[idx]
	if v.interrupt:
		for pl in _players:
			pl.stop()
	_play(v.syllables[_syllable_index(v, c)], p, v.volume_db)
	_bounce = 1.0
	_talk_timer = 0.09
	blip_played.emit(c)


func _play(s: AudioStream, p: float, vol: float) -> void:
	var pl := _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	pl.stream = s
	pl.pitch_scale = clampf(p, 0.05, 8.0)
	pl.volume_db = volume_db + vol
	pl.bus = audio_bus
	pl.play()


func _ui(what: String) -> void:
	if not ui_sounds_enabled or style == null or style.ui_sounds == "":
		return
	var p := "%s/ui/ui_%s_%s.wav" % [DialogueBox.addon_dir(), style.ui_sounds, what]
	if not ResourceLoader.exists(p):
		return
	_ui_player.stream = load(p)
	_ui_player.volume_db = volume_db - 4.0
	_ui_player.bus = audio_bus
	_ui_player.play()


func _animate_portrait(delta: float) -> void:
	if _portrait == null or not _portrait_frame.visible:
		return
	if _talk_timer > 0.0:
		_talk_timer -= delta
		if talking_portrait and _portrait_talk:
			_portrait.texture = _portrait_talk if _talk_timer > 0.0 else _portrait_idle
	if talking_portrait and _bounce > 0.0:
		_bounce = maxf(0.0, _bounce - delta * 9.0)
		_portrait.pivot_offset = _portrait.size * Vector2(0.5, 1.0)
		var s := 1.0 + 0.045 * sin(_bounce * PI)
		_portrait.scale = Vector2(1.0 / s, s)
	else:
		_portrait.scale = Vector2.ONE


func _show_choices(choices: Array) -> void:
	for c in _choice_box.get_children():
		c.queue_free()
	var first: Button = null
	for i in choices.size():
		var b := Button.new()
		b.text = str(choices[i])
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_style_choice(b)
		b.pressed.connect(_on_choice.bind(i, str(choices[i])))
		b.focus_entered.connect(_ui.bind("move"))
		b.mouse_entered.connect(b.grab_focus)
		_choice_box.add_child(b)
		if first == null:
			first = b
	state = State.CHOOSING
	_arrow.visible = false
	_choice_panel.visible = true
	_choice_panel.reset_size()
	_layout()
	if first:
		first.grab_focus.call_deferred()


func _style_choice(b: Button) -> void:
	if style == null:
		return
	var f := _font_for(style.font)
	if f:
		b.add_theme_font_override("font", f)
	b.add_theme_font_size_override("font_size", style.font_size)
	for k in ["font_color", "font_pressed_color"]:
		b.add_theme_color_override(k, style.text_color)
	for k in ["font_hover_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(k, style.accent_color)
	var empty := StyleBoxEmpty.new()
	empty.content_margin_left = 14
	empty.content_margin_right = 14
	empty.content_margin_top = 4
	empty.content_margin_bottom = 4
	var hi := StyleBoxFlat.new()
	hi.bg_color = Color(style.accent_color, 0.22)
	hi.border_color = Color(style.accent_color, 0.9)
	hi.border_width_left = 4
	hi.set_corner_radius_all(0 if style.pixel_art else 6)
	hi.content_margin_left = 14
	hi.content_margin_right = 14
	hi.content_margin_top = 4
	hi.content_margin_bottom = 4
	b.add_theme_stylebox_override("normal", empty)
	b.add_theme_stylebox_override("pressed", hi)
	b.add_theme_stylebox_override("hover", hi)
	b.add_theme_stylebox_override("focus", hi)
	b.add_theme_stylebox_override("hover_pressed", hi)


func _on_choice(i: int, t: String) -> void:
	if state != State.CHOOSING:
		return
	_ui("select")
	_choice_panel.visible = false
	state = State.IDLE
	choice_made.emit(i, t)


func _gui_input(event: InputEvent) -> void:
	if not click_to_advance:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if state == State.TYPING or state == State.WAITING:
			advance()
			accept_event()


func _unhandled_input(event: InputEvent) -> void:
	if state != State.TYPING and state != State.WAITING:
		return
	if advance_action != &"" and InputMap.has_action(advance_action) and event.is_action_pressed(advance_action):
		advance()
		get_viewport().set_input_as_handled()


class _NextArrow:
	extends Control
	var color := Color.WHITE
	var pixel := false

	func _draw() -> void:
		var t := Time.get_ticks_msec() / 1000.0
		var off := sin(t * 6.0) * 3.0
		if pixel:
			off = roundf(off / 3.0) * 3.0
		var w := size.x
		var pts := PackedVector2Array([Vector2(0, off), Vector2(w, off), Vector2(w * 0.5, w * 0.62 + off)])
		draw_colored_polygon(PackedVector2Array([pts[0] + Vector2(2, 3), pts[1] + Vector2(2, 3), pts[2] + Vector2(2, 3)]), Color(0, 0, 0, 0.35))
		draw_colored_polygon(pts, color)
