extends Control
## Demo: pick a voice, an emote and a box style, type your own line, or play a short scene with a choice.
## Everything is built in code so you can read how DialogueBox is used.

const Catalog := preload("res://addons/dialogue_blips/catalog.gd")

const LINES := [
	"Hello there! I'm [b]%s[/b]. Nice to meet you, traveler.",
	"Did you hear that? [wait=0.4]Something is moving in the dark...",
	"This shop sells potions, maps and [wave amp=30 freq=4]magic beans[/wave]!",
	"[speed=0.45]Well... [/speed][speed=1.8]oh no, no, no, we have to go right now![/speed]",
	"Ha! [emote=laugh]You really thought that would work?",
	"The bridge is out, so we take the long way. Ready?",
	"Have you seen my cat? She was here a minute ago!",
	"[shake rate=18 level=6]STOP![/shake] [wait=0.3]Sorry. I mean: please wait.",
]

const PORTRAIT_FOR := {
	"Chip": "robot", "Tone": "fairy", "Synth": "wizard",
	"talk_deep": "wizard", "talk_gruff": "wizard", "talk_calm": "wizard", "talk_elder": "wizard",
	"talk_soft": "kid", "talk_bright": "kid", "talk_child": "kid", "talk_squeaky": "kid", "talk_nasal": "kid", "talk_whisper": "ghost",
	"char_robot": "robot", "char_monster": "monster", "char_ghost": "ghost", "char_alien": "monster", "char_fairy": "fairy",
	"char_typewriter": "robot", "char_terminal": "robot", "char_radio": "robot", "char_insect": "frog", "char_goblin": "monster",
	"critter_frog": "frog", "critter_slime": "frog", "critter_bubble": "frog",
}

var box: DialogueBox
var info: Label
var voice_grid: GridContainer
var group_buttons := {}
var voice_buttons := {}
var style_buttons := {}
var emote_box: HBoxContainer
var speed_slider: HSlider
var pitch_slider: HSlider
var line_edit: LineEdit
var sidebar: PanelContainer
var backdrop: Control

var current_voice := ""
var current_group := ""
var current_style := ""
var _token := 0
var _line_i := 0


func _ready() -> void:
	theme = _make_theme()
	backdrop = _Backdrop.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	box = DialogueBox.new()
	box.position = Vector2(452, 512)
	box.size = Vector2(800, 188)
	box.close_when_done = false
	add_child(box)

	info = Label.new()
	info.position = Vector2(452, 20)
	info.size = Vector2(800, 24)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	info.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	info.add_theme_constant_override("outline_size", 6)
	info.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	add_child(info)

	_build_sidebar()
	var first_voice: String = Catalog.VOICES[0]["id"]
	for v in Catalog.VOICES:
		if v["id"] == "talk_soft":
			first_voice = "talk_soft"
	_select_group(_group_of(first_voice))
	select_style(Catalog.STYLES[0]["id"])
	select_voice(first_voice, false)
	box.show_line("Click a voice on the left to hear it talk. Press [b]Enter[/b], [b]Space[/b] or click the box to skip or go on.", "Welcome", null, _portrait("kid"), _portrait("kid", true))


func _make_theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = 15
	var n := StyleBoxFlat.new()
	n.bg_color = Color(1, 1, 1, 0.07)
	n.set_corner_radius_all(6)
	n.content_margin_left = 8
	n.content_margin_right = 8
	n.content_margin_top = 4
	n.content_margin_bottom = 4
	var h := n.duplicate() as StyleBoxFlat
	h.bg_color = Color(1, 1, 1, 0.16)
	var p := n.duplicate() as StyleBoxFlat
	p.bg_color = Color(1.0, 0.42, 0.42, 0.9)
	t.set_stylebox("normal", "Button", n)
	t.set_stylebox("hover", "Button", h)
	t.set_stylebox("pressed", "Button", p)
	t.set_stylebox("hover_pressed", "Button", p)
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_color("font_color", "Button", Color(0.92, 0.93, 0.98))
	t.set_color("font_pressed_color", "Button", Color.WHITE)
	t.set_color("font_hover_pressed_color", "Button", Color.WHITE)
	var le := n.duplicate() as StyleBoxFlat
	le.bg_color = Color(0, 0, 0, 0.35)
	t.set_stylebox("normal", "LineEdit", le)
	t.set_stylebox("focus", "LineEdit", le)
	t.set_color("font_color", "Label", Color(0.92, 0.93, 0.98))
	return t


func _label(text: String, size := 15, color := Color(1, 0.82, 0.4)) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


func _button(text: String, cb: Callable, toggle := false) -> Button:
	var b := Button.new()
	b.text = text
	b.toggle_mode = toggle
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(0, 26)
	b.pressed.connect(cb)
	return b


func _build_sidebar() -> void:
	sidebar = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.06, 0.12, 0.82)
	sb.set_corner_radius_all(14)
	sb.set_content_margin_all(14)
	sidebar.add_theme_stylebox_override("panel", sb)
	sidebar.position = Vector2(14, 14)
	sidebar.size = Vector2(412, 692)
	add_child(sidebar)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	sidebar.add_child(v)

	var title := _label("Dialogue Voice Blips", 24, Color.WHITE)
	v.add_child(title)
	var sub := "%d voices, %d box styles, Godot 4 DialogueBox" % [Catalog.VOICES.size(), Catalog.STYLES.size()]
	if Catalog.PACK == "sample":
		sub = "Free sample: %d of %d voices, %d of %d styles" % [Catalog.VOICES.size(), Catalog.FULL_VOICE_COUNT, Catalog.STYLES.size(), Catalog.FULL_STYLE_COUNT]
	v.add_child(_label(sub, 14, Color(0.7, 0.75, 0.9)))

	v.add_child(_label("VOICE"))
	var groups := HFlowContainer.new()
	groups.add_theme_constant_override("h_separation", 4)
	groups.add_theme_constant_override("v_separation", 4)
	v.add_child(groups)
	for g in Catalog.GROUPS:
		var gb := _button(g, _select_group.bind(g), true)
		groups.add_child(gb)
		group_buttons[g] = gb
	voice_grid = GridContainer.new()
	voice_grid.columns = 3
	voice_grid.add_theme_constant_override("h_separation", 4)
	voice_grid.add_theme_constant_override("v_separation", 4)
	v.add_child(voice_grid)

	v.add_child(_label("EMOTE"))
	emote_box = HBoxContainer.new()
	emote_box.add_theme_constant_override("separation", 4)
	v.add_child(emote_box)
	for e in Catalog.EMOTES:
		var eb := _button(e, _emote.bind(e))
		eb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		emote_box.add_child(eb)

	v.add_child(_label("BOX STYLE"))
	var sg := GridContainer.new()
	sg.columns = 3
	sg.add_theme_constant_override("h_separation", 4)
	sg.add_theme_constant_override("v_separation", 4)
	v.add_child(sg)
	for s in Catalog.STYLES:
		var b := _button(s["label"], _style_clicked.bind(s["id"]), true)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sg.add_child(b)
		style_buttons[s["id"]] = b

	var sl := GridContainer.new()
	sl.columns = 2
	v.add_child(sl)
	sl.add_child(_label("Speed", 14, Color(0.8, 0.82, 0.92)))
	speed_slider = HSlider.new()
	speed_slider.min_value = 10
	speed_slider.max_value = 120
	speed_slider.value = 40
	speed_slider.focus_mode = Control.FOCUS_NONE
	speed_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	speed_slider.value_changed.connect(func(x: float) -> void: box.characters_per_second = x)
	sl.add_child(speed_slider)
	sl.add_child(_label("Pitch", 14, Color(0.8, 0.82, 0.92)))
	pitch_slider = HSlider.new()
	pitch_slider.min_value = 0.5
	pitch_slider.max_value = 2.0
	pitch_slider.step = 0.01
	pitch_slider.value = 1.0
	pitch_slider.focus_mode = Control.FOCUS_NONE
	pitch_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pitch_slider.value_changed.connect(func(x: float) -> void: box.pitch_scale = x)
	sl.add_child(pitch_slider)

	var row := HBoxContainer.new()
	v.add_child(row)
	line_edit = LineEdit.new()
	line_edit.placeholder_text = "Type your own line..."
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_edit.text_submitted.connect(func(_t: String) -> void: _say_own())
	row.add_child(line_edit)
	row.add_child(_button("Say it", _say_own))

	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 4)
	v.add_child(row2)
	var sc := _button("Play a scene with a choice", play_scene)
	sc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row2.add_child(sc)
	var nx := _button("Next line", _next_line)
	row2.add_child(nx)

	var foot := RichTextLabel.new()
	foot.bbcode_enabled = true
	foot.fit_content = true
	foot.scroll_active = false
	foot.add_theme_font_size_override("normal_font_size", 13)
	foot.add_theme_color_override("default_color", Color(0.7, 0.75, 0.9))
	if Catalog.PACK == "sample":
		foot.text = "Full pack (%d voices, %d styles, %s): [url]%s[/url]" % [Catalog.FULL_VOICE_COUNT, Catalog.FULL_STYLE_COUNT, Catalog.PRICE, Catalog.PAID_URL]
	else:
		foot.text = "Every voice: 8 syllables + 5 emotes. REEBOO Labs - [url]%s[/url]" % Catalog.PAID_URL
	foot.meta_clicked.connect(func(m: Variant) -> void: OS.shell_open(str(m)))
	v.add_child(foot)


func _group_of(voice_id: String) -> String:
	for v in Catalog.VOICES:
		if v["id"] == voice_id:
			return v["group"]
	return ""


func _label_of(voice_id: String) -> String:
	for v in Catalog.VOICES:
		if v["id"] == voice_id:
			return v["label"]
	return voice_id


func _select_group(g: String) -> void:
	current_group = g
	for k in group_buttons:
		group_buttons[k].button_pressed = k == g
	for c in voice_grid.get_children():
		c.queue_free()
	voice_buttons.clear()
	for v in Catalog.VOICES:
		if v["group"] != g:
			continue
		var b := _button(v["label"], select_voice.bind(v["id"]), true)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.button_pressed = v["id"] == current_voice
		voice_grid.add_child(b)
		voice_buttons[v["id"]] = b


func _portrait(p_name: String, talk := false) -> Texture2D:
	var p := "res://demo/portraits/%s%s.png" % [p_name, "_talk" if talk else ""]
	return load(p) if ResourceLoader.exists(p) else null


func _portrait_name(voice_id: String) -> String:
	if PORTRAIT_FOR.has(voice_id):
		return PORTRAIT_FOR[voice_id]
	var g := _group_of(voice_id)
	if PORTRAIT_FOR.has(g):
		return PORTRAIT_FOR[g]
	return "cat"


func _update_info() -> void:
	info.text = "Voice: %s (%s)    Style: %s" % [_label_of(current_voice), current_group, _style_label(current_style)]


func _style_label(id: String) -> String:
	for s in Catalog.STYLES:
		if s["id"] == id:
			return s["label"]
	return id


## Select a voice and (optionally) let it say a line.
func select_voice(voice_id: String, speak := true) -> void:
	current_voice = voice_id
	box.voice_name = voice_id
	var g := _group_of(voice_id)
	if g != current_group:
		_select_group(g)
	for k in voice_buttons:
		voice_buttons[k].button_pressed = k == voice_id
	_update_info()
	if speak:
		_token += 1
		_line_i = (_line_i + 1) % LINES.size()
		say_line(_line_text(_line_i))


func _line_text(i: int) -> String:
	var t: String = LINES[i]
	return t % _label_of(current_voice) if t.contains("%s") else t


func _next_line() -> void:
	_token += 1
	_line_i = (_line_i + 1) % LINES.size()
	say_line(_line_text(_line_i))


## Type a line with the current voice and its portrait (no waiting).
func say_line(text: String) -> void:
	var pn := _portrait_name(current_voice)
	box.show_line(text, _label_of(current_voice), current_voice, _portrait(pn), _portrait(pn, true))


func _style_clicked(id: String) -> void:
	select_style(id)
	if box.state == DialogueBox.State.WAITING or box.state == DialogueBox.State.TYPING:
		box.play_blip("a")


func select_style(id: String) -> void:
	current_style = id
	box.style_name = id
	for k in style_buttons:
		style_buttons[k].button_pressed = k == id
	_update_info()


func _emote(e: String) -> void:
	box.play_emote(e)


func _say_own() -> void:
	var t := line_edit.text.strip_edges()
	if t == "":
		t = "You can type anything here, even [wave]BBCode[/wave] and [speed=0.4]slow parts[/speed]."
	_token += 1
	say_line(t)


## A short conversation between the current voice and a second voice, with a choice.
func play_scene() -> void:
	_token += 1
	var my := _token
	var a := current_voice
	var b := "critter_cat" if a != "critter_cat" else "talk_soft"
	if DialogueBox.load_voice(b) == null:
		b = Catalog.VOICES[(_index_of(a) + 1) % Catalog.VOICES.size()]["id"]
	var an := _label_of(a)
	var bn := _label_of(b)
	var pa := _portrait_name(a)
	var pb := _portrait_name(b) if _portrait_name(b) != pa else "cat"
	await box.say("Psst! Over here. Can you keep a secret?", an, a, _portrait(pa), _portrait(pa, true))
	if my != _token:
		return
	await box.say("Of course! [wait=0.3]I think...", bn, b, _portrait(pb), _portrait(pb, true))
	if my != _token:
		return
	var pick: int = await box.ask("There is a [b]treasure[/b] under the old bridge. Do we go tonight?", ["Yes, let's go!", "No, it's too dangerous.", "What treasure?"], an, a, _portrait(pa), _portrait(pa, true))
	if my != _token:
		return
	match pick:
		0:
			box.play_emote("laugh")
			await box.say("[emote=laugh]Ha! I knew you would say that. [speed=1.6]Bring a lamp and meet me at midnight![/speed]", an, a, _portrait(pa), _portrait(pa, true))
		1:
			await box.say("[emote=sad]Oh... [wait=0.3]okay. [speed=0.6]Maybe another time.[/speed]", an, a, _portrait(pa), _portrait(pa, true))
		_:
			await box.say("[emote=surprise]What treasure? [wait=0.3]THE treasure! The one everybody talks about?", bn, b, _portrait(pb), _portrait(pb, true))
	if my != _token:
		return
	box.show_line("(Scene over. Pick another voice or style, or play the scene again.)", "", a)


func _index_of(voice_id: String) -> int:
	for i in Catalog.VOICES.size():
		if Catalog.VOICES[i]["id"] == voice_id:
			return i
	return 0


## Used by the capture tool: hide the sidebar and centre the box.
func showcase_layout(on: bool) -> void:
	sidebar.visible = not on
	info.visible = not on
	if on:
		box.position = Vector2(140, 500)
		box.size = Vector2(1000, 190)
	else:
		box.position = Vector2(452, 512)
		box.size = Vector2(800, 188)


class _Backdrop:
	extends Control

	func _draw() -> void:
		var w := size.x
		var h := size.y
		var top := Color("1b1f45")
		var bottom := Color("f4a581")
		var steps := 240
		for i in steps:
			var t := float(i) / float(steps - 1)
			var c := top.lerp(Color("8a5a9e"), clampf(t * 1.6, 0.0, 1.0)).lerp(bottom, clampf((t - 0.55) * 2.2, 0.0, 1.0))
			draw_rect(Rect2(0, h * float(i) / float(steps), w, h / float(steps) + 1.0), c)
		var rng := RandomNumberGenerator.new()
		rng.seed = 7
		for i in 70:
			var p := Vector2(rng.randf() * w, rng.randf() * h * 0.45)
			draw_circle(p, rng.randf_range(0.8, 1.8), Color(1, 1, 1, rng.randf_range(0.3, 0.9)))
		draw_circle(Vector2(w * 0.78, h * 0.52), 70.0, Color("ffd9a0"))
		draw_circle(Vector2(w * 0.78, h * 0.52), 96.0, Color(1.0, 0.85, 0.6, 0.18))
		_hills(h * 0.62, 70.0, 0.004, Color("6b4a7e"), 1.3)
		_hills(h * 0.72, 55.0, 0.006, Color("4a3566"), 2.1)
		_hills(h * 0.84, 40.0, 0.009, Color("2e2348"), 0.4)

	func _hills(base: float, amp: float, freq: float, c: Color, ph: float) -> void:
		var pts := PackedVector2Array()
		var w := size.x
		pts.append(Vector2(0, size.y))
		var x := 0.0
		while x <= w + 8.0:
			pts.append(Vector2(x, base - amp * (0.6 * sin(x * freq + ph) + 0.4 * sin(x * freq * 2.3 + ph * 1.7))))
			x += 8.0
		pts.append(Vector2(w, size.y))
		draw_colored_polygon(pts, c)
