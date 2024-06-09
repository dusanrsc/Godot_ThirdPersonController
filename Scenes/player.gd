extends CharacterBody3D

@onready var camera_mount = $CameraMount
@onready var animation_player = $Visuals/mixamo_base/AnimationPlayer
@onready var visuals = $Visuals

@export var horizontal_mouse_senstitivity = 0.15
@export var vertical_mouse_senstitivity = 0.15

var speed = 3.0
var jump_velocity = 4.5

var walking_speed = 3.0
var running_speed = 5.0

var is_running = false 
var is_player_locked = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
# Move player by mouse
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * horizontal_mouse_senstitivity))
		visuals.rotate_y(deg_to_rad(event.relative.x * horizontal_mouse_senstitivity))
		camera_mount.rotate_x(deg_to_rad(event.relative.y * vertical_mouse_senstitivity))

func _physics_process(delta):
	if !animation_player.is_playing():
		is_player_locked = false

	if Input.is_action_just_pressed("kick") and is_on_floor():
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			is_player_locked = true

	if Input.is_action_pressed("run"):
		speed = running_speed
		is_running = true
	else:
		speed = walking_speed
		is_running = false

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_right", "move_left", "move_back", "move_forward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_player_locked:
			if is_running:
				if animation_player.current_animation != "running":
					animation_player.play("running")
			else:
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
			visuals.look_at(position - direction)

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		if !is_player_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")

		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if !is_player_locked:
		move_and_slide()
