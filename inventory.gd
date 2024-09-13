# inventory.gd
extends GridContainer
class_name Inventory

@onready var slots = get_children()

func add_item(item: Item):
	for slot in slots:
		if slot.item == null:
			slot.item = item
			# Try to find the player/knight node
			var player = get_tree().current_scene.find_child("Knight")
			
			# Check if the player instance was found
			if player != null:
				player.equip(item)
				print("item?", player.equip(item))
			else:
				print("Player character not found in scene tree!")
			return

func remove_item(item: Item):
	for slot in slots:
		if slot.item == item:
			slot.item = null
			return
