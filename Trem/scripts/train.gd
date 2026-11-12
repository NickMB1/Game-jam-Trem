extends Node3D

@export var min_speed: float = 0.0
@export var max_speed: float = 8.0
@export var starting_speed: float = 2.0
## Distância do pivô até a ponta da frente do asset no eixo X; ajustável no Inspector.
@export var front_offset: float = 0.5

var speed: float = 0.0
var moving: bool = false

func _ready() -> void:
	speed = starting_speed

func _process(delta: float) -> void:
	if moving:
		position.x += speed * delta

func start() -> void:
	moving = true

func stop() -> void:
	moving = false

func reset() -> void:
	moving = false
	position.x = 0.0
	speed = starting_speed

func increase_speed(amount: float) -> void:
	speed = clamp(speed + amount, min_speed, max_speed)

func decrease_speed(amount: float) -> void:
	speed = clamp(speed - amount, min_speed, max_speed)

func get_front_x() -> float:
	return position.x + front_offset

func get_progress_ratio(finish_distance: float) -> float:
	if finish_distance <= 0.0:
		return 0.0
	return clamp(get_front_x() / finish_distance, 0.0, 1.0)
