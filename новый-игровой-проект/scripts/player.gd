extends CharacterBody3D

@onready var head: Node3D = $head


var cur_speed = 5.0

@export var walking_speed = 4.0
@export var running_speed = 6.0
@export var crouch_speed = 1.0

@onready var spot_light_3d: SpotLight3D = $head/Torch_2/SpotLight3D

@onready var flash: AudioStreamPlayer3D = $flash


const sens = 0.4

var lerp_speed = 10.0

var direction = Vector3.ZERO


const JUMP_VELOCITY = 4.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-(event.relative.x  * sens)))
		head.rotate_x(deg_to_rad(-(event.relative.y  * sens)))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-98), deg_to_rad(98))
	if Input.is_action_just_pressed("flash"):
		spot_light_3d.visible = !spot_light_3d.visible
		flash.play()
	if Dialogic.current_timeline != null:
		return

	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		Dialogic.start('timeline')
		get_viewport().set_input_as_handled()
	
	pass
	
	

func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("sprint"):
		cur_speed = running_speed
	else:
		cur_speed = walking_speed

	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	if direction:
		velocity.x = direction.x * cur_speed
		velocity.z = direction.z * cur_speed
	else:
		velocity.x = move_toward(velocity.x, 0, cur_speed)
		velocity.z = move_toward(velocity.z, 0, cur_speed)

	move_and_slide()
