# shop.gd
extends Inventory

@onready var item_manager = itemmanager
@onready var close_button = $"../CloseButton"  # Reference to the Close Button
@onready var reroll_button: Button = $"../RerollButton"
@onready var item_database = ItemDB  # Item database (autoload)
@onready var manager = get_parent()
@onready var vendor = get_tree().get_root().get_node("MainGame/Vendor")

@export var items : Array[Item]

func _ready():
	# Ensure node paths exist
	if item_manager == null:
		print("ItemManager node not found!")
	if vendor == null:
		print("Vendor node not found!")

	load_items(items)

func load_items(items):
	reset()
	for item in items:
		add_item(item)

func reset():
	for slot in get_children():
		slot.item = null

func _on_close_button_pressed() -> void:
	print("Closing shop...")
	close_shop()

func close_shop():
	var path = get_tree().get_root().get_node("MainGame/Vendor")
	if path != null:
		path.close_shop()
	else:
		print("Vendor node not found!")

# Handle reroll logic when the Reroll Button is pressed
func _on_reroll_button_pressed():
	manager.currency -= 20
	var all_items = item_database.get_all_items()
	var new_items = vendor.get_random_items(all_items, 5)  # Fetch new items from item manager
	print("Rerolling items...", new_items[0].name)
	load_items(new_items)  # Load new items into the shop
