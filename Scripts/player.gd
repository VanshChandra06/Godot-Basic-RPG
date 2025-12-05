extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var sensitivity = 0.001
var onCooldown = false
var controller_sensitivity = 2.0

var gold = 15
var hp = 50
var maxHp = 50

@onready var hpBar = $HUD/HPBar
@onready var goldLabel = $HUD/GoldLabel
@onready var camera = $Camera3D
@onready var animationPlayer = $AnimationPlayer
@onready var cooldown = $AttackCooldown

func _ready() -> void:
	hpBar.max_value = maxHp
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func attack():
	if Input.is_action_just_pressed("attack") and onCooldown == false:
		animationPlayer.play("SwordSwing")
		onCooldown = true
		cooldown.start()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(70))

func update_HUD():
	hpBar.value = hp
	goldLabel.text = str(gold)

func _controller_look(delta: float) -> void:
	var look_vector = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if abs(look_vector.x) > 0.0 or abs(look_vector.y) > 0.0:
		rotate_y(-look_vector.x * controller_sensitivity * delta)
		camera.rotate_x(-look_vector.y * controller_sensitivity * delta)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(70))


func _process(delta: float) -> void:
	update_HUD()
	attack()
	_controller_look(delta)
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_attack_cooldown_timeout() -> void:
	onCooldown = false
