extends CharacterBody2D

var vit_stt = 1
var def_stt = 1
var stam_stt = 1
var atk_stt = 1
var spd_stt = 1

var whoosh = preload("uid://du4pce7lw1t4a")
var slash = preload("uid://rker5w4y7h1t")
var whooshh = preload("uid://bmwqdsi7886pw")
var slashh = preload("uid://dolq0nl7tg50m")

var chealth = 100
var spd: float = 300.0
var atk
var def
var stm

var maxstm

var mousepos
var isatk = false
var ishatk = false
var isvuln = false
var isshield = false

var facing = "r"

var combo = 0
var combo_timer = 0.0
var combo_window = 1
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

var can_regen = true
var can_parry = true
var is_parry = false
func _ready():
	atk = 10 * atk_stt
	def = def_stt * 5
	maxstm = stam_stt * 100
	chealth = vit_stt * 100
	stm = maxstm
	disable_all_hitboxes()

func _process(delta):
	mousepos = get_global_mouse_position()
	stm_regen()
	if stm > maxstm:
		stm = maxstm
	
	if Input.is_action_pressed("rmb") and not isatk and not isvuln:
		isshield = true
		velocity = Vector2.ZERO
		
		var anim = ""
		
		if facing == "l" or facing == "ul" or facing == "dl":
			anim = "sl"
		elif facing == "r" or facing == "ur" or facing == "dr":
			anim = "sr"
		elif facing == "u":
			anim = "su"
		elif facing == "d":
			anim = "sd"
		is_parry = true
		await get_tree().create_timer(0.3).timeout
		is_parry = false
		if $AnimatedSprite2D.animation != anim + "i":
			$AnimatedSprite2D.play(anim)
			await $AnimatedSprite2D.animation_finished
			if isshield:
				$AnimatedSprite2D.play(anim + "i")
	else:
		isshield = false
	
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

func update_facing_from_input(input_vector):
	if input_vector == Vector2.ZERO:
		return

	if input_vector.y < -0.5:
		if input_vector.x > 0.5:
			facing = "ur"
		elif input_vector.x < -0.5:
			facing = "ul"
		else:
			facing = "u"
	elif input_vector.y > 0.5:
		if input_vector.x > 0.5:
			facing = "dr"
		elif input_vector.x < -0.5:
			facing = "dl"
		else:
			facing = "d"
	else:
		if input_vector.x > 0:
			facing = "r"
		elif input_vector.x < 0:
			facing = "l"

func play_walk_anim():
	if facing == "u":
		$AnimatedSprite2D.play("walk_up")
	elif facing == "d":
		$AnimatedSprite2D.play("walk_down")
	elif facing == "l":
		$AnimatedSprite2D.play("walk_left")
	elif facing == "r":
		$AnimatedSprite2D.play("walk_right")
	elif facing == "ul":
		$AnimatedSprite2D.play("walk_upleft")
	elif facing == "ur":
		$AnimatedSprite2D.play("walk_upright")
	elif facing == "dl":
		$AnimatedSprite2D.play("walk_downleft")
	elif facing == "dr":
		$AnimatedSprite2D.play("walk_downright")

func get_dmged(dmg, dmger):
	if is_parry:
		dmger.stun()
	elif isshield:
		stm -= (dmg * 2) * def_stt
	else:
		chealth -= dmg

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

func atkk():
	if stm < light_cost:
		return
	can_regen = false
	$adad.stream = slash
	$adad.pitch_scale = randf_range(1.0, 1.3)
	$adad.play()

	$adad2.stream = whoosh
	$adad2.pitch_scale = randf_range(1.0, 1.3)
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
	elif name == "ur":
		$Node/ur.monitoring = true
	elif name == "dl":
		$Node/dl.monitoring = true
	elif name == "dr":
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
	await get_tree().create_timer(0.4).timeout
	can_regen = true

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
	elif name == "ur":
		$Node/ur.monitoring = true
	elif name == "dl":
		$Node/dl.monitoring = true
	elif name == "dr":
		$Node/dr.monitoring = true

	$atk.play("h" + name)

	$adad.stream = slashh
	$adad.pitch_scale = randf_range(1.0, 1.3)
	$adad.play()

	$adad2.stream = whooshh
	$adad2.pitch_scale = randf_range(1.0, 1.3)
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

	if not isatk and not ishatk and not isvuln and not isshield:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		var target = input_vector * spd
		velocity = velocity.move_toward(target, accel * delta)

		update_facing_from_input(input_vector)
		play_walk_anim()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if velocity.length() < 5 and not isatk and not isshield:
			$AnimatedSprite2D.stop()

	move_and_slide()

func stm_regen():
	if can_regen == false:
		return
	can_regen = false
	await get_tree().create_timer(0.1).timeout
	stm += stam_stt
	can_regen = true

func _on_atk_body_entered(body):
	if body.is_in_group("enemy"):
		body.get_dmged(atk)
