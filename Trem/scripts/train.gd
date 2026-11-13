extends Node3D

@export var min_speed: float = 0.0
@export var max_speed: float = 16.0
@export var starting_speed: float = 2.0
## Distância do pivô até a ponta da frente do asset no eixo X; ajustável no Inspector.
@export var front_offset: float = 0.5
## Multiplica a velocidade do trem para virar o speed_scale da animação das rodas.
@export var wheel_animation_speed_factor: float = 1.0
@export var engine_min_pitch: float = 0.8
@export var engine_max_pitch: float = 1.6
@export var engine_volume_db: float = -6.0

const ENGINE_SOUND_PATH := "res://SFX/Train_Move.wav"

var speed: float = 0.0
var moving: bool = false

var _anim_player: AnimationPlayer
var _wheel_animation: String = ""
var _engine_player: AudioStreamPlayer

func _ready() -> void:
	speed = starting_speed
	_anim_player = _find_animation_player(self)
	if _anim_player:
		_wheel_animation = _find_wheel_animation_name(_anim_player)
		if _wheel_animation != "":
			var anim: Animation = _anim_player.get_animation(_wheel_animation)
			anim.loop_mode = Animation.LOOP_LINEAR
			_anim_player.play(_wheel_animation)
			_anim_player.speed_scale = 0.0

	_engine_player = AudioStreamPlayer.new()
	var engine_stream: AudioStream = load(ENGINE_SOUND_PATH)
	if engine_stream is AudioStreamWAV:
		(engine_stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	_engine_player.stream = engine_stream
	_engine_player.volume_db = engine_volume_db
	add_child(_engine_player)

func _process(delta: float) -> void:
	if moving:
		position.x += speed * delta
	if _anim_player and _wheel_animation != "":
		_anim_player.speed_scale = (speed * wheel_animation_speed_factor) if moving else 0.0
	if moving:
		if not _engine_player.playing:
			_engine_player.play()
		var speed_ratio: float = clamp(speed / max_speed, 0.0, 1.0) if max_speed > 0.0 else 0.0
		_engine_player.pitch_scale = lerp(engine_min_pitch, engine_max_pitch, speed_ratio)
	elif _engine_player.playing:
		_engine_player.stop()

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

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found: AnimationPlayer = _find_animation_player(child)
		if found:
			return found
	return null

func _find_wheel_animation_name(player: AnimationPlayer) -> String:
	var names: PackedStringArray = player.get_animation_list()
	for anim_name in names:
		if "wheel" in anim_name.to_lower():
			return anim_name
	return names[0] if names.size() > 0 else ""
