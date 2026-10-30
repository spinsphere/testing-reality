class_name LabCamera
extends Node3D
## Orbit / pan / zoom camera rig for the laboratory.
## Left or right drag = orbit, middle drag or Shift+drag = pan, wheel = zoom, F = refocus.

@export var target := Vector3(0.0, 0.1, 0.0)
@export var distance := 1.6
@export var yaw := -35.0   # degrees
@export var pitch := 28.0  # degrees
@export var min_distance := 0.25
@export var max_distance := 6.0
@export var orbit_speed := 0.35
@export var pan_speed := 0.0016
@export var zoom_factor := 1.12
@export var smoothing := 14.0

var camera: Camera3D
var _dragging := false
var _panning := false
var _target_goal: Vector3
var _distance_goal: float
var _yaw_goal: float
var _pitch_goal: float
var _home := {}


func _ready() -> void:
	camera = Camera3D.new()
	camera.fov = 45.0
	camera.near = 0.01
	camera.far = 50.0
	camera.current = true
	add_child(camera)
	_target_goal = target
	_distance_goal = distance
	_yaw_goal = yaw
	_pitch_goal = pitch
	_home = {"target": target, "distance": distance, "yaw": yaw, "pitch": pitch}
	_apply(true)


func set_home(p_target: Vector3, p_distance: float, p_yaw: float, p_pitch: float) -> void:
	_home = {"target": p_target, "distance": p_distance, "yaw": p_yaw, "pitch": p_pitch}
	go_home(true)


func go_home(instant: bool = false) -> void:
	_target_goal = _home["target"]
	_distance_goal = _home["distance"]
	_yaw_goal = _home["yaw"]
	_pitch_goal = _home["pitch"]
	if instant:
		_apply(true)


## Smoothly frame a point.
func focus_on(point: Vector3, p_distance: float = -1.0) -> void:
	_target_goal = point
	if p_distance > 0.0:
		_distance_goal = p_distance


func _process(delta: float) -> void:
	var k := clampf(smoothing * delta, 0.0, 1.0)
	target = target.lerp(_target_goal, k)
	distance = lerpf(distance, _distance_goal, k)
	yaw = lerpf(yaw, _yaw_goal, k)
	pitch = lerpf(pitch, _pitch_goal, k)
	_apply(false)


func _apply(_instant: bool) -> void:
	var rot := Basis.from_euler(Vector3(deg_to_rad(-pitch), deg_to_rad(yaw), 0.0))
	var offset := rot * Vector3(0.0, 0.0, distance)
	camera.global_position = target + offset
	camera.look_at(target, Vector3.UP)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		match mb.button_index:
			MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT:
				_dragging = mb.pressed
				_panning = mb.pressed and mb.shift_pressed
			MOUSE_BUTTON_MIDDLE:
				_panning = mb.pressed
				_dragging = false
			MOUSE_BUTTON_WHEEL_UP:
				if mb.pressed:
					_distance_goal = clampf(_distance_goal / zoom_factor, min_distance, max_distance)
			MOUSE_BUTTON_WHEEL_DOWN:
				if mb.pressed:
					_distance_goal = clampf(_distance_goal * zoom_factor, min_distance, max_distance)
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _panning:
			var right := camera.global_transform.basis.x
			var up := camera.global_transform.basis.y
			_target_goal -= (right * mm.relative.x - up * mm.relative.y) * pan_speed * distance
		elif _dragging:
			_yaw_goal -= mm.relative.x * orbit_speed
			_pitch_goal = clampf(_pitch_goal + mm.relative.y * orbit_speed, -5.0, 85.0)
	elif event is InputEventKey and event.pressed and not event.echo:
		if (event as InputEventKey).keycode == KEY_F:
			go_home()
