extends CharacterBody2D

var plr
var isplr = false
enum states {idle, melee, laser, death, follow, homing_missle, dash, buff}

var current_state
var previous_state
var lasering = false
var can_move = true

var bulala = preload("uid://byqwfej4mhg8g")
var is_ranging =false
var can_missle = true
var dir

func _physics_process(delta: float) -> void:
	if plr:
		if lasering:
			var target_angle = (plr.global_position - $pivot.global_position).angle()
			$pivot.rotation = lerp_angle($pivot.rotation, target_angle, 2.5 * delta)
		dir = plr.global_position - global_position
		if dir.x < 0:
			$AnimatedSprite2D.flip_h= true
		else:
			$AnimatedSprite2D.flip_h = false
	match current_state:
		states.idle:
			idle()
		states.follow:
			follow()
		states.melee:
			melee()
	move_and_collide(velocity * delta)

func melee():
	velocity = Vector2.ZERO
	can_move = false
	$AnimatedSprite2D.play("attack")
	await $AnimatedSprite2D.animation_finished
	can_move = true
	if dir.length() > 80:
		var rani = randi() % 1
		if rani == 0:
			changestate(states.dash)
			dash()
		else:
			changestate(states.follow)

func _ready() -> void:
	current_state = states.idle

func changestate(stete):
	previous_state = current_state
	current_state = stete
	
func idle():
	if current_state == states.idle:
		$AnimatedSprite2D.play('idle')

func dash():
	$AnimatedSprite2D.play("glowing")
	var twen = create_tween()
	twen.tween_property(self, "global_position", plr.global_position, 0.8)
	await twen.finished

func lazer():
	if plr == null:
		return

	changestate(states.laser)

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
	changestate(states.dash)
	await dash()
	changestate(states.follow)

func stop_laser():
	lasering = false
	$pivot/AnimatedSprite2D.visible = false

func follow():
	if is_ranging or !can_move:
		return
	$AnimatedSprite2D.play('idle')
	if plr == null:
		changestate(states.idle)
		return
	velocity = dir.normalized() * 100
	if dir.length() < 80:
		changestate(states.melee)
		velocity = Vector2.ZERO
		return
	elif dir.length() > 200 and can_missle:
		var rand = randi() % 3
		match rand:
			0:
				changestate(states.homing_missle)
				missile()
			1:
				changestate(states.dash)
				dash()
			2:
				changestate(states.laser)
				lazer()
		velocity = Vector2.ZERO
		return

func missile():
	can_missle = false
	is_ranging = true
	changestate(states.homing_missle)
	$AnimatedSprite2D.play("rangedatk")
	await $AnimatedSprite2D.animation_finished
	var bullet = bulala.instantiate()
	bullet.global_position = $AnimatedSprite2D/a/Marker2D.global_position
	get_parent().add_child(bullet)
	await get_tree().create_timer(1).timeout
	is_ranging = false
	get_tree().create_timer(15).timeout.connect(camissle)
	var rand = randi() % 3
	changestate(states.dash)
	dash()

func camissle():
	can_missle = true

func _process(delta: float) -> void:
	$AnimatedSprite2D/deb.text = str(current_state)

func _on_playerdet_body_entered(body: Node2D) -> void:
	if body.is_in_group('plr'):
		plr = body
		isplr = true
		changestate(states.follow)

func _on_playerdet_body_exited(body: Node2D) -> void:
	if body.is_in_group('plr'):
		isplr = false
