extends Node3D

@export var match_duration: float = 60.0
@export var button_spawn_interval: float = 0.5
@export var button_lifetime: float = 2.0
@export var finish_distance: float = 300.0
@export var speed_increase_amount: float = 0.8
@export var speed_decrease_amount: float = 0.6

const ClickButtonScene := preload("res://Cenas/click_button.tscn")

@onready var train: Node3D = $World/Train
@onready var camera: Camera3D = $World/Train/Camera
@onready var spawn_timer: Timer = $SpawnTimer

@onready var time_label: Label = $UI/HUD/TimeLabel
@onready var speed_label: Label = $UI/HUD/SpeedLabel
@onready var progress_label: Label = $UI/HUD/ProgressLabel
@onready var button_layer: Control = $UI/HUD/ButtonLayer
@onready var result_label: Label = $UI/HUD/ResultLabel
@onready var restart_button: Button = $UI/HUD/RestartButton
@onready var start_panel: Control = $UI/HUD/StartPanel
@onready var start_button: Button = $UI/HUD/StartPanel/StartButton

var time_left: float = 0.0
var game_active: bool = false

func _ready() -> void:
	# Câmera é filha do trem (segue ele por todo o trajeto); olha um pouco
	# adiante para o jogador ver o caminho pela frente.
	camera.look_at(train.global_position + Vector3(10.0, 0.0, 0.0))
	spawn_timer.wait_time = button_spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	start_button.pressed.connect(_on_start_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	result_label.visible = false
	restart_button.visible = false
	_update_hud()

func _process(delta: float) -> void:
	if not game_active:
		return

	time_left -= delta
	if time_left < 0.0:
		time_left = 0.0
	_update_hud()

	if train.get_front_x() >= finish_distance:
		_end_match(true)
		return

	if time_left <= 0.0:
		_end_match(false)

func _on_start_pressed() -> void:
	start_panel.visible = false
	_start_match()

func _start_match() -> void:
	time_left = match_duration
	game_active = true
	train.reset()
	train.start()
	spawn_timer.start()
	result_label.visible = false
	restart_button.visible = false
	_clear_buttons()
	_update_hud()

func _end_match(won: bool) -> void:
	game_active = false
	train.stop()
	spawn_timer.stop()
	_clear_buttons()
	result_label.text = "Você chegou a tempo!" if won else "O trem não chegou a tempo..."
	result_label.visible = true
	restart_button.visible = true

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_spawn_timer_timeout() -> void:
	if game_active:
		_spawn_button()

func _spawn_button() -> void:
	var btn := ClickButtonScene.instantiate()
	btn.lifetime = button_lifetime
	btn.resolved.connect(_on_button_resolved)
	button_layer.add_child(btn)

	var layer_size: Vector2 = button_layer.size
	var btn_size: Vector2 = btn.custom_minimum_size
	var max_x: float = max(layer_size.x - btn_size.x, 0.0)
	var max_y: float = max(layer_size.y - btn_size.y, 0.0)
	btn.position = Vector2(randf_range(0.0, max_x), randf_range(0.0, max_y))

func _on_button_resolved(success: bool) -> void:
	if not game_active:
		return
	if success:
		train.increase_speed(speed_increase_amount)
	else:
		train.decrease_speed(speed_decrease_amount)

func _clear_buttons() -> void:
	for child in button_layer.get_children():
		child.queue_free()

func _update_hud() -> void:
	time_label.text = "Tempo: %d s" % int(ceil(time_left))
	speed_label.text = "Velocidade: %.1f" % train.speed
	var pct: int = int(train.get_progress_ratio(finish_distance) * 100.0)
	progress_label.text = "Progresso: %d%%" % pct
