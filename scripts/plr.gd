extends CharacterBody2D

var def_stt = 1
var stam_stt = 1
var atk_stt = 1
var spd_stt = 1

var whoosh = preload("uid://du4pce7lw1t4a")
var slash = preload("uid://rker5w4y7h1t")

var whooshh = preload("uid://bmwqdsi7886pw")
var slashh = preload("uid://dolq0nl7tg50m")

var spd: float = 300.0
var atk
var def
var stm

var mousepos
var isatk = false
var ishatk = false
var isvuln = false

var combo = 0
var combo_timer = 0.0
var combo_window = 0.4
var check = false

var light_cost = 10
var heavy_cost = 25
var hold_time = 0.35
var hold_timer = 0.0

var light_lunge = 180.0
var heavy_lunge = 540.0

var light_vuln = 0.12
var heavy_vuln = 0.45

var friction = 1400.0
var accel = 1600.0

func _ready():
	atk = 10 * atk_stt
	def = def_stt * 5
	stm = stam_stt * 100
	disable_all_hitboxes()

func _process(delta):
	mousepos = get_global_mouse_position()
	stm_regen()

	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			combo = 0

	if Input.is_action_pressed("lmb") and not isatk and not isvuln:
		hold_timer += delta
		spd = 100

	if Input.is_action_just_released("lmb") and not isatk and not isvuln:
		if hold_timer >= hold_time:
			if stm >= heavy_cost:
				stm -= heavy_cost
				heavy()
		else:
			if stm >= light_cost:
				stm -= light_cost
				atkk()
		hold_timer = 0.0
		spd = 300

	if Input.is_action_just_pressed("lmb") and isatk:
		check = true

func get_snap_dir():
	var raw = mousepos - global_position
	if raw.y < 0:
		if raw.x < 0:
			return Vector2(-1, -1).normalized()
		else:
			return Vector2(1, -1).normalized()
	else:
		if raw.x < 0:
			return Vector2(-1, 1).normalized()
		else:
			return Vector2(1, 1).normalized()

func get_dir_name(dir):
	if dir.y < 0:
		if dir.x < 0:
			return "ul"
		else:
			return "ur"
	else:
		if dir.x < 0:
			return "dl"
		else:
			return "dr"

func face_snap(dir):
	if dir.y < 0:
		if dir.x < 0:
			$AnimatedSprite2D.play("walk_upleft")
		else:
			$AnimatedSprite2D.play("walk_upright")
	else:
		if dir.x < 0:
			$AnimatedSprite2D.play("walk_downleft")
		else:
			$AnimatedSprite2D.play("walk_downright")

func atkk():
	if stm < light_cost:
		return

	$adad.stream = slash
	$adad.pitch_scale = randf_range(1.0,1.3)
	$adad.play()
	$adad2.stream = whoosh
	$adad2.pitch_scale = randf_range(1.0,1.3)
	$adad2.play()

	combo += 1
	if combo > 3:
		combo = 1

	isatk = true

	var dir = get_snap_dir()
	var name = get_dir_name(dir)

	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play(name + str(combo))

	var lunge = light_lunge + (combo - 1) * 90.0
	velocity += dir * lunge

	$atk.visible = true
	disable_all_hitboxes()

	if name == "ul":
		$Node/ul.monitoring = true
	if name == "ur":
		$Node/ur.monitoring = true
	if name == "dl":
		$Node/dl.monitoring = true
	if name == "dr":
		$Node/dr.monitoring = true

	$atk.play(name + str(combo))
	await $atk.animation_finished

	disable_all_hitboxes()
	isatk = false
	$atk.visible = false

	isvuln = true
	await get_tree().create_timer(light_vuln).timeout
	isvuln = false

	if check and stm >= light_cost:
		check = false
		stm -= light_cost
		atkk()
	else:
		check = false
		combo_timer = combo_window

func heavy():
	if stm < heavy_cost:
		return

	isatk = true
	ishatk = true

	var dir = get_snap_dir()
	var name = get_dir_name(dir)

	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play(name + "1")

	$atk.visible = true
	disable_all_hitboxes()

	if name == "ul":
		$Node/ul.monitoring = true
	if name == "ur":
		$Node/ur.monitoring = true
	if name == "dl":
		$Node/dl.monitoring = true
	if name == "dr":
		$Node/dr.monitoring = true

	$atk.play("h" + name)

	$adad.stream = slashh
	$adad.pitch_scale = randf_range(1.0,1.3)
	$adad.play()
	$adad2.stream = whooshh
	$adad2.pitch_scale = randf_range(1.0,1.3)
	$adad2.play(0.4)

	await get_tree().create_timer(0.3).timeout
	velocity += dir * heavy_lunge

	await $atk.animation_finished

	disable_all_hitboxes()

	isatk = false
	ishatk = false
	$atk.visible = false
	combo = 0

	isvuln = true
	await get_tree().create_timer(heavy_vuln).timeout
	isvuln = false

func disable_all_hitboxes():
	$Node/ul.monitoring = false
	$Node/ur.monitoring = false
	$Node/dl.monitoring = false
	$Node/dr.monitoring = false

func _physics_process(delta):
	var input_vector = Vector2.ZERO

	if not isatk and not ishatk and not isvuln:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		var target = input_vector * spd
		velocity = velocity.move_toward(target, accel * delta)

		if input_vector.y < -0.5:
			if input_vector.x > 0.5:
				$AnimatedSprite2D.play("walk_upright")
			elif input_vector.x < -0.5:
				$AnimatedSprite2D.play("walk_upleft")
			else:
				$AnimatedSprite2D.play("walk_up")
		elif input_vector.y > 0.5:
			if input_vector.x > 0.5:
				$AnimatedSprite2D.play("walk_downright")
			elif input_vector.x < -0.5:
				$AnimatedSprite2D.play("walk_downleft")
			else:
				$AnimatedSprite2D.play("walk_down")
		else:
			if input_vector.x > 0:
				$AnimatedSprite2D.play("walk_right")
			elif input_vector.x < 0:
				$AnimatedSprite2D.play("walk_left")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if velocity.length() < 5 and not isatk:
			$AnimatedSprite2D.stop()

	move_and_slide()

var can_regen = true
func stm_regen():
	if can_regen == false:
		return
	can_regen = false
	await get_tree().create_timer(0.3).timeout
	stm += stam_stt
	can_regen = true

func _on_atk_body_entered(body):
	if body.is_in_group("enemy"):
		body.get_dmged(atk)
