extends KinematicBody

onready var camera = $Camera
onready var ray = $Camera/RayCast

export var walk_speed : int = 5
export var accel : float = 0.2
export var gravity : int = -1
export var term_velocity : int = -35
export var jump_strength : int = 10

var velocity : Vector3

var state = WALKING

enum {
	WALKING,
	SPRINTING,
}


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(_delta):
	get_input()
	
func _physics_process(_delta):
	handle_movement()
	handle_jumping()
	
func get_input():
	var dir : Vector3 = Vector3.ZERO
	
	#Get base movement input
	
	if Input.is_action_pressed("forward"):
		dir += -global_transform.basis.z
	if Input.is_action_pressed("backward"):
		dir += global_transform.basis.z
	if Input.is_action_pressed("left"):
		dir += -global_transform.basis.x
	if Input.is_action_pressed("right"):
		dir += global_transform.basis.x
		
	dir = dir.normalized()
	
	#Pull X and Z values from directional input. Velocity.y will be handled in physics loop
	
	velocity.x = lerp(velocity.x, dir.x * walk_speed, accel)
	velocity.z = lerp(velocity.z, dir.z * walk_speed, accel)

func handle_movement():
	#Apply gravity
	velocity.y += gravity
	if velocity.y < term_velocity:
		velocity.y = term_velocity
		
	velocity = move_and_slide(velocity, Vector3.UP)

func _input(event):
	#Handle mouse movement for camera
	if event is InputEventMouseMotion:
		self.rotate_y(-event.relative.x * Settings.mouse_sens)
		camera.rotate_x(-event.relative.y * Settings.mouse_sens)
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)

func handle_jumping():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength
