extends CharacterBody2D

var max_hp = 500
var hp

var phase = 1
var phase2_triggered = false

var stunda = false

var activetwen

var plr
var isplr = false
enum states {idle, melee, laser, death, follow, homing_missle, dash, buff, shockwave}

var current_state
var previous_state
var lasering = false
var can_move = true
var state_running = false

var bulala = preload("uid://byqwfej4mhg8g")
var is_ranging = false
var can_missle = true
var can_laser = true
var can_dash = true
var can_buff = true

var dir

func _ready() -> void:
	current_state = states.idle
	hp = max_hp
	randomize()

func _physics_process(delta: float) -> void:
	if stunda:
		modulate = Color(255,255,255, 0.6)
		return
	else:
		modulate = Color(1,1,1, 1)
	if hp <= max_hp / 2 and phase == 1 and !phase2_triggered:
		enter_phase2()
	if hp <= 0 and current_state != states.death:
		changestate(states.death)
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
		states.buff:
			if !state_running:
				state_running = true
				buff()
		states.shockwave:
			if !state_running:
				state_running = true
				shockwave()
		states.death:
			if !state_running:
				state_running = true
				death()

	move_and_collide(velocity * delta)

func enter_phase2():
	phase = 2
	phase2_triggered = true
	changestate(states.buff)

func changestate(stete):
	if current_state == stete:
		return
	if activetwen and activetwen.is_running():
		activetwen.kill()
		activetwen = null
	previous_state = current_state
	current_state = stete
	state_running = false

func idle():
	$AnimatedSprite2D.play("idle")

func follow():
	if current_state != states.follow: 
		return
	if is_ranging or !can_move or stunda:
		return
	if plr == null:
		changestate(states.idle)
		return
	$AnimatedSprite2D.play("idle")
	var spd = 100 if phase == 1 else 300
	velocity = dir.normalized() * spd
	if dir.length() < 130:
		changestate(states.melee)
		velocity = Vector2.ZERO
		return
	if dir.length() > 200 and !state_running:
		var moves = []
		if can_dash:
			moves.append(states.dash)
		if can_missle:
			moves.append(states.homing_missle)
		if can_laser:
			moves.append(states.laser)
		if phase == 2 and can_buff:
			moves.append(states.buff)
		if phase == 2:
			moves.append(states.shockwave)
		if moves.size() > 0:
			var pick = moves[randi() % moves.size()]
			changestate(pick)
			velocity = Vector2.ZERO

func melee():
	state_running = true
	velocity = Vector2.ZERO
	can_move = false
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play("attack")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D/a/Area2D.monitoring = true
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D/a/Area2D.monitoring = false
	can_move = true
	await get_tree().create_timer(0.2 if phase == 1 else 0.1).timeout
	changestate(states.follow)
	state_running = false

func dash():
	can_dash = false
	if plr == null:
		changestate(states.idle)
		state_running = false
		return
	$AnimatedSprite2D.play("glowing")
	activetwen = create_tween()
	var t = 0.8 if phase == 1 else 0.5
	activetwen.tween_property(self, "global_position", plr.global_position, t)
	await activetwen.finished
	get_tree().create_timer(3.0 if phase == 1 else 2.0).timeout.connect(func(): can_dash = true)
	changestate(states.follow)
	state_running = false

func lazer():
	state_running = true 
	can_laser = false
	can_move = false
	velocity = Vector2.ZERO
	$pivot.visible = true
	$pivot/AnimatedSprite2D.visible = true
	$pivot/Area2D.monitoring = false
	$AnimatedSprite2D.play("lasercast")
	await $AnimatedSprite2D.animation_finished
	if current_state != states.laser:
		stop_laser()
		return
	lasering = true 
	$pivot/AnimatedSprite2D.play("laser")
	$pivot/Area2D.monitoring = true
	
	var dur = 5.0 if phase == 1 else 7.0
	await get_tree().create_timer(dur).timeout
	stop_laser()
	can_move = true
	changestate(states.follow)
	var cooldown = 6.0 if phase == 1 else 4.0
	get_tree().create_timer(cooldown).timeout.connect(func(): can_laser = true)

func stop_laser():
	lasering = false
	$pivot/Area2D.monitoring = false
	$pivot/AnimatedSprite2D.stop()
	$pivot/AnimatedSprite2D.visible = false
	$pivot.visible = false

func missile():
	can_missle = false
	is_ranging = true
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("rangedatk")
	await $AnimatedSprite2D.animation_finished
	var count = 1 if phase == 1 else 3
	for i in count:
		var bullet = bulala.instantiate()
		bullet.global_position = $AnimatedSprite2D/a/Marker2D.global_position
		get_parent().add_child(bullet)
		await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(1.0).timeout
	is_ranging = false
	get_tree().create_timer(10.0 if phase == 1 else 6.0).timeout.connect(camissle)
	changestate(states.follow)
	state_running = false

func buff():
	can_buff = false
	can_move = false
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("glowing")
	await $AnimatedSprite2D.animation_finished
	get_tree().create_timer(8.0).timeout.connect(func(): can_buff = true)
	can_move = true
	changestate(states.follow)
	state_running = false

func shockwave():
	can_move = false
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("attack")
	await $AnimatedSprite2D.animation_finished
	for i in 6:
		var bullet = bulala.instantiate()
		bullet.global_position = global_position
		bullet.rotation = deg_to_rad(i * 60)
		get_parent().add_child(bullet)
	await get_tree().create_timer(1.0).timeout
	can_move = true
	changestate(states.follow)
	state_running = false

func camissle():
	can_missle = true

func death():
	velocity = Vector2.ZERO
	can_move = false
	$AnimatedSprite2D.play("death")
	await $AnimatedSprite2D.animation_finished

func stun():
	if current_state == states.death:
		return
	can_move = false
	stunda = true
	await get_tree().create_timer(2 if phase == 1 else 1).timeout
	can_move = true
	stunda = false
	if hp > 0:
		changestate(states.follow)

func get_dmged(dmg, who = self):
	if current_state == states.death:
		return
	hp -= dmg
	if hp <= 0:
		death()

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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("plr"):
		body.get_dmged(20, self)

func _on_area_2fd_body_entered(body: Node2D) -> void:
	if body.is_in_group('plr'):
		laserdmgplr(body)

func laserdmgplr(body):
	while lasering and is_instance_valid(body) and $pivot/Area2D.overlaps_body(body):
		body.get_dmged(2, self)	
		await get_tree().create_timer(0.2).timeout
