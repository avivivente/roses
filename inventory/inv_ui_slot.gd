extends Panel

@onready var item_display: Sprite2D = $CenterContainer/Panel/Item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label


func update(slots: InvSlot):
	if !slots.item:
		item_display.visible = false
		amount_text.visible = false
	else:
		item_display.visible = true
		amount_text.visible = true
		item_display.texture = slots.item.texture
		amount_text.text = str(slots.amount)
