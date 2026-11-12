extends Button

## Botão placeholder redondo: aparece na tela, precisa ser clicado antes do
## tempo de vida (lifetime) acabar. Começa branco e vai ficando vermelho
## conforme o tempo dele se esgota. Emite "resolved(true)" se clicado a
## tempo, "resolved(false)" se expirar sem clique.
signal resolved(success: bool)

@export var lifetime: float = 1.0

@onready var _timer: Timer = $Lifetime

var _style: StyleBoxFlat

func _ready() -> void:
	text = ""
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	_style = StyleBoxFlat.new()
	_style.bg_color = Color.WHITE
	var radius: int = int(custom_minimum_size.x / 2.0)
	_style.corner_radius_top_left = radius
	_style.corner_radius_top_right = radius
	_style.corner_radius_bottom_left = radius
	_style.corner_radius_bottom_right = radius
	add_theme_stylebox_override("normal", _style)
	add_theme_stylebox_override("hover", _style)
	add_theme_stylebox_override("pressed", _style)
	add_theme_stylebox_override("disabled", _style)
	add_theme_stylebox_override("focus", _style)

	pressed.connect(_on_pressed)
	_timer.wait_time = lifetime
	_timer.timeout.connect(_on_timeout)
	_timer.start()

func _process(_delta: float) -> void:
	var ratio: float = 1.0
	if lifetime > 0.0:
		ratio = 1.0 - clamp(_timer.time_left / lifetime, 0.0, 1.0)
	_style.bg_color = Color.WHITE.lerp(Color.RED, ratio)

func _on_pressed() -> void:
	_timer.stop()
	resolved.emit(true)
	queue_free()

func _on_timeout() -> void:
	resolved.emit(false)
	queue_free()
