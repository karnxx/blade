extends CharacterBody2D

var max_hp = 500
var hp

var plr
var isplr = false
enum states {idle, melee, laser, death, follow, homing_missle, dash, buff}

var current_state
var previous_state
var lasering = false
var can_move = true
var state_running = false

var bulala = preload("uid://byqwfej4mhg8g")
var is_ranging = false
var can_missle = true
var dir

func _ready() -> void:
	current_state = states.idle
	hp = max_hp

func _physics_process(delta: float) -> void:
	if plr:
		if lasering:
			var target_angle = (plr.global_position - $pivot.global_position).angle()
			$pivot.rotation = lerp_angle($pivot.rotation, target_angle, 2.5 * delta)
		dir = plr.global_position - global_position
		if dir.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	match current_state:
		states.idle:
			if !state_running:
				state_running = true
				idle()
		states.follow:
			follow()
		states.melee:
			if !state_running:
				state_running = true
				melee()
		states.dash:
			if !state_running:
				state_running = true
				dash()
		states.laser:
			if !state_running:
				state_running = true
				lazer()
		states.homing_missle:
			if !state_running:
				state_running = true
				missile()

	move_and_collide(velocity * delta)


func changestate(stete):
	if current_state == stete:
		return
	previous_state = current_state
	current_state = stete
	state_running = false

func idle():
	$AnimatedSprite2D.play("idle")

func follow():
	if is_ranging or !can_move:
		return
	if plr == null:
		changestate(states.idle)
		return
	$AnimatedSprite2D.play("idle")
	velocity = dir.normalized() * 100
	if dir.length() < 80:
		changestate(states.melee)
		velocity = Vector2.ZERO
		return
	elif dir.length() > 200 and can_missle and !state_running:
		var rand = randi() % 3
		match rand:
			0:
				changestate(states.homing_missle)
			1:
				changestate(states.dash)
			2:
				changestate(states.laser)
		velocity = Vector2.ZERO
		return

func melee():
	state_running = true
	velocity = Vector2.ZERO
	can_move = false
	$AnimatedSprite2D.play("attack")
	await $AnimatedSprite2D.animation_finished
	can_move = true
	await get_tree().create_timer(0.2).timeout
	if plr and dir.length() > 80:
		var rani = randi() % 2
		if rani == 0:
			changestate(states.dash)
		else:
			changestate(states.follow)
	else:
		changestate(states.follow)
	state_running = false

func dash():
	if plr == null:
		changestate(states.idle)
		state_running = false
		return
	$AnimatedSprite2D.play("glowing")
	var twen = create_tween()
	twen.tween_property(self, "global_position", plr.global_position, 0.8)
	await twen.finished
	changestate(states.follow)
	state_running = false


func lazer():
	if plr == null:
		changestate(states.idle)
		state_running = false
		return
	lasering = true
	can_move = false
	velocity = Vector2.ZERO
	$pivot/AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("lasercast")
	await $AnimatedSprite2D.animation_finished
	$pivot/AnimatedSprite2D.play("laser")
	await get_tree().create_timer(5.0).timeout
	stop_laser()
	can_move = true
	changestate(states.follow)
	state_running = false

func stop_laser():
	lasering = false
	$pivot/AnimatedSprite2D.visible = false

func missile():
	can_missle = false
	is_ranging = true
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("rangedatk")
	await $AnimatedSprite2D.animation_finished
	var bullet = bulala.instantiate()
	bullet.global_position = $AnimatedSprite2D/a/Marker2D.global_position
	get_parent().add_child(bullet)
	await get_tree().create_timer(1.0).timeout
	is_ranging = false
	get_tree().create_timer(15.0).timeout.connect(camissle)
	changestate(states.follow)
	state_running = false

func camissle():
	can_missle = true

func get_dmged(dmg, who):
	hp -= dmg

func _process(delta: float) -> void:
	$CanvasLayer/ProgressBar2.max_value = max_hp
	$CanvasLayer/ProgressBar2.value = hp
	$AnimatedSprite2D/deb.text = str(current_state)

func _on_playerdet_body_entered(body: Node2D) -> void:
	if body.is_in_group("plr"):
		plr = body
		isplr = true
		changestate(states.follow)

func _on_playerdet_body_exited(body: Node2D) -> void:
	if body.is_in_group("plr"):
		isplr = false
		changestate(states.dash)
