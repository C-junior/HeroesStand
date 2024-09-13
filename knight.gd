# knight.gd
extends BaseCharacter

@onready var sprite = $KnightSprite  # Sprite node for knight animations

@export var knight_max_health: int = 300
@export var knight_attack_damage: int = 85
@export var knight_defense: int = 10
@export var knight_move_speed: int = 60
@export var knight_attack_cooldown: float = 1.0

@onready var knight_health_progress_bar = $HealthProgressBAr

@export var current_item: Item:
	set(value):
		current_item = value
		if current_item != null:
			knight_attack_damage += current_item.attack_bonus 

func _ready():
	max_health = knight_max_health
	attack_damage = knight_attack_damage
	defense = knight_defense
	move_speed = knight_move_speed
	current_health = max_health
	current_item = null  # Start without any item equipped

	health_progress_bar.max_value = max_health  # Set max value for the progress bar
	health_progress_bar.value = current_health  # Initialize progress bar value

	attack_timer.wait_time = knight_attack_cooldown  # Ensure attack_timer is initialized in BaseCharacter
	attack_timer.start()  # Start the timer

	sprite.play("Idle")
	update_health_label()

	add_to_group("PlayerCharacters")

func _process(delta: float):
	# Find nearest enemy to attack
	target = find_nearest_target("Enemies")
	if target:
		move_and_attack(target, delta)
