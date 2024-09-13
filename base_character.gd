# base_character
extends CharacterBody2D
class_name BaseCharacter

# Equipment slots
var weapon: Item = null
var armor: Item = null
var accessory: Item = null

@onready var health_label = $HP
@onready var health_progress_bar = $HealthProgressBAr

@export var move_speed: int = 80
@export var attack_range: float = 30.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.5
@export var max_health: int = 100
@export var defense: int = 5  # Base defense stat

@onready var popuploc = $PopupLocation

var current_health: int
@export var attack_timer: Timer = Timer.new()
var target: Node2D  # The character's current target (enemy or ally)

func _ready():
	current_health = max_health
	health_progress_bar.max_value = max_health  # Set max value for the progress bar
	health_progress_bar.value = current_health  # Initialize progress bar value
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))

	add_to_group("PlayerCharacters")  # This can be changed to "Enemies" if it's an enemy
	update_stats_from_items()

# Equipment handling
func equip(item: Item):
	match item.type:
		"weapon":
			weapon = item
			print("equipou arma", weapon.name)
		"armor":
			armor = item
			print("equipou armor", armor.name)
		"accessory":
			accessory = item
	update_stats_from_items()

func unequip(slot: String):
	match slot:
		"weapon":
			weapon = null
			print("desequipou arma", weapon.name)
		"armor":
			armor = null
		"accessory":
			accessory = null
	update_stats_from_items()

func update_stats_from_items():
	# Reset base stats
	attack_damage = 10
	defense = 5
	move_speed = 80
	max_health = 100

	# Apply item bonuses
	if weapon != null:
		attack_damage += weapon.attack_bonus
		defense += weapon.defense_bonus
		move_speed += weapon.speed_bonus
	if armor != null:
		defense += armor.defense_bonus
		max_health += armor.health_bonus
	if accessory != null:
		attack_damage += accessory.attack_bonus
		move_speed += accessory.speed_bonus

	current_health = min(current_health, max_health)
	update_health_label()

# Attack logic
func attack(target: Node2D):
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
		attack_timer.start()

# Damage logic
func take_damage(damage: int):
	var reduced_damage = max(damage - defense, 0)
	current_health -= reduced_damage
	popuploc.popup(-reduced_damage)  # Pass as negative for damage
	update_health_label()
	health_progress_bar.value = current_health  # Update the progress bar
	if current_health <= 0:
		die()
		
func update_health_label():
	health_label.text = str(current_health)

func move_and_attack(target: Node2D, delta: float):
	var direction = (target.global_position - global_position).normalized()
	if global_position.distance_to(target.global_position) > attack_range:
		velocity = direction * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		if attack_timer.is_stopped():
			attack(target)

func die():
	queue_free()

func _on_attack_timeout():
	pass


# Find nearest target (either enemy for attack, or ally for healing)
func find_nearest_target(group_name: String) -> Node2D:
	var nearest_node: Node2D = null
	var shortest_distance = INF

	for node in get_tree().get_nodes_in_group(group_name):
		var distance = global_position.distance_to(node.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_node = node

	return nearest_node


func get_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health


func receive_heal(heal: int):
	current_health += heal
	popuploc.popup(heal)  # Pass positive value for healing
	current_health = clamp(current_health, 0, max_health)  # Ensure health doesn't exceed max
	update_health_label()
	health_progress_bar.value = current_health  # Update the progress bar
