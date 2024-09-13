# item_manager
extends Node
class_name ItemManager

var items: Dictionary = {

}

# Equip an item to the specified character in the correct slot
func equip_item_to_character(character: BaseCharacter, item_key: String):
	var item = items.get(item_key, null)
	if item:
		if character.can_equip(item):
			character.equip_item(item)
		else:
			print("Item cannot be equipped in the correct slot!")

# Unequip item from a specific slot
func unequip_item_from_character(character: BaseCharacter, slot: String):
	character.unequip_item(slot)
