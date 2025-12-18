extends CharacterBody3D

enum States {attack, idle, chase, die}

var state = States.idle
var hp = 20
var speed = 2
var accel = 10
var damage = 10
var gravity = 9.8
var value = 15
var target = null
	
@export var navAgent: NavigationAgent3D
@export var animationPlayer : AnimationPlayer

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity
	
	if state == States.idle:
		print("idle")
		velocity = Vector3.ZERO
		animationPlayer.play("Idle")
	elif state == States.chase:
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		navAgent.target_position = target.global_position
		var direction = navAgent.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = velocity.lerp(direction * speed, accel * delta)
		animationPlayer.play("Walk")
	elif state == States.attack:
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		print("attack")
		velocity = Vector3.ZERO
		animationPlayer.play("Punch")
	elif state == States.die:
		velocity = Vector3.ZERO
		animationPlayer.play("Die")
		
	move_and_slide()

func enemy():
	pass
	
func _process(_delta):
	if hp<=0:
		state = States.die
 
func attack():
	target.hp-=damage

func give_loot():
	target.gold += value

func _on_chase_area_body_entered(body: Node3D) -> void:
	if body.has_method("player") and state != States.die:
		target = body
		state = States.chase

func _on_chase_area_body_exited(body: Node3D) -> void:
	if body.has_method("player") and state != States.die:
		target = null
		state = States.idle

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.has_method("player") and state != States.die:
		state = States.attack

func _on_attack_area_body_exited(body: Node3D) -> void:
	if body.has_method("player") and state != States.die:
		state = States.chase
