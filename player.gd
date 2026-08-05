extends CharacterBody3D

var speed
const CAMERA_HEIGHT = 1.5 
const WALK_SPEED = 5.0
const SPRINT_SPEED= 8.0
const JUMP_VELOCITY = 5.5
const SENSITIVITYX=0.002
const SENSITIVITYY=0.0005

const BOB_FREQ=2.0
const BOB_AMP=0.08
var t_bob=0.0

const BASE_FOV=75.0
const FOV_CHANGE = 1.5

@onready var head: Node3D = $Node3D

@onready var camera: Camera3D = $Node3D/Camera3D



func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITYX)
		camera.rotate_x(-event.relative.y* SENSITIVITYY)
		camera.rotation.x=clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(70) )

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed=WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("right", "left", "bacl", "forward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	t_bob+= delta * velocity.length() * float(is_on_floor())
	camera.transform.origin= _headbob(t_bob)
	
	var velocity_clamp = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov=BASE_FOV + FOV_CHANGE * velocity_clamp
	camera.fov = lerp(camera.fov, target_fov, delta *8.0)

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = (sin(time * BOB_FREQ) * BOB_AMP) + CAMERA_HEIGHT # Adds the height here
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
