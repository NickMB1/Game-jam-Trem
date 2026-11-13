extends Node3D

@export var track_start_x: float = -10.0
@export var track_end_x: float = 310.0

@export var rail_segment_length: float = 4.0
@export var rail_y: float = 0.0
@export var rail_scale: float = 1.0

const RAIL_PATH := "res://Modelos3D/Railroad/source/railroad_gav.fbx"

func _ready() -> void:
	_build_rails()

func _build_rails() -> void:
	var x: float = track_start_x
	while x < track_end_x:
		var xform := Transform3D(Basis().scaled(Vector3.ONE * rail_scale), Vector3(x, rail_y, 0.0))
		_spawn(RAIL_PATH, xform)
		x += rail_segment_length

func _spawn(path: String, xform: Transform3D) -> Node3D:
	var res: Resource = load(path)
	var node: Node3D
	if res is PackedScene:
		node = (res as PackedScene).instantiate()
	elif res is Mesh:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.mesh = res as Mesh
		node = mesh_instance
	else:
		return null
	add_child(node)
	node.transform = xform
	return node
