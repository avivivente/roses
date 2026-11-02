extends Resource

class_name Inv

signal update

@export var slots: Array[InvSlot]

func insert(item: InvItem):
	var itemslots = slots.filter(func(slot): return slot.item == item)
	if !itemslots.is_empty():
		itemslots[0].amount += 1
	else:
		var emptyslots = slots.filter(func(slot): return slot.item == null)
		if !emptyslots.is_empty():
			emptyslots[0].item = item
			emptyslots[0].amount = 1
	update.emit()

func remove_item(item: InvItem, amount_to_remove: int = 1) -> void:
	for i in range(slots.size()):
		var slot = slots[i]
		
		if slot and slot.item == item:
			slot.amount -= amount_to_remove
			
			if slot.amount <= 0:
				slot.item = null
				slot.amount = 0
				
			update.emit() 
			break
