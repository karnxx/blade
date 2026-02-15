extends CharacterBody2D

var def_stt = 1
var stam_stt = 1
var atk_stt = 1
var spd_stt = 1


var spd: float = 300.0
var atk
var def
var stm

var mousepos
var isatk = false
var ishatk = false

var combo = 0
var combo_timer = 0.0
var combo_window = 0.4
var buffer = false

var light_cost = 10
var heavy_cost = 25
var hold_time = 0.35
var hold_timer = 0.0

func _ready():
	atk = 10 * atk_stt
	def = def_stt * 5
	stm = stam_stt * 100
	disable_all_hitboxes()

func _process(delta: float) -> void:
	mousepos = get_global_mouse_position()
	
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			combo = 0
	
	if Input.is_action_pressed("lmb") and not isatk and not ishatk:
		hold_timer += delta
		spd = 100.0
	
	if Input.is_action_just_released("lmb") and not isatk and not ishatk:
		if hold_timer >= hold_time:
			if stm >= heavy_cost:
				stm -= heavy_cost
				heavy()
		else:
			if stm >= light_cost:
				stm -= light_cost
				atkk()
		hold_timer = 0.0
		spd = 300.0
	
	if Input.is_action_just_pressed("lmb") and isatk:
		buffer = true

func atkk():
	if stm < light_cost:
		return
	
	combo += 1
	if combo > 3:
		combo = 1
	
	isatk = true
	
	$atk.visible = true
	disable_all_hitboxes()
	
	var dir = (mousepos - global_position).normalized()
	var anim = ""
	
	if dir.y < 0:
		if dir.x < 0:
			anim = "ul" + str(combo)
			$Node/ul.monitoring = true
		else:
			anim = "ur" + str(combo)
			$Node/ur.monitoring = true
	else:
		if dir.x < 0:
			anim = "dl" + str(combo)
			$Node/dl.monitoring = true
		else:
			anim = "dr" + str(combo)
			$Node/dr.monitoring = true
	
	$atk.play(anim)
	await $atk.animation_finished
	
	disable_all_hitboxes()
	isatk = false
	$atk.visible = false
	
	if buffer and stm >= light_cost:
		buffer = false
		stm -= light_cost
		atkk()
	else:
		buffer = false
		combo_timer = combo_window

func heavy():
	if stm < heavy_cost:
		return
	
	isatk = true
	ishatk = true
	velocity = Vector2.ZERO
	
	$atk.visible = true
	disable_all_hitboxes()
	
	var dir = (mousepos - global_position).normalized()
	var anim
	
	if dir.y < 0:
		if dir.x < 0:
			anim = "hul"
			$Node/ul.monitoring = true
		else:
			anim = "hur"
			$Node/ur.monitoring = true
	else:
		if dir.x < 0:
			anim = "hdl"
			$Node/dl.monitoring = true
		else:
			anim = "hdr"
			$Node/dr.monitoring = true
	
	$atk.play(anim)
	await $atk.animation_finished
	
	disable_all_hitboxes()
	
	isatk = false
	ishatk = false
	$atk.visible = false
	combo = 0

func disable_all_hitboxes():
	$Node/ul.monitoring = false
	$Node/ur.monitoring = false
	$Node/dl.monitoring = false
	$Node/dr.monitoring = false

func _physics_process(delta):
	if ishatk:
		move_and_slide()
		return
	
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * spd
		
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
		velocity = Vector2.ZERO
		$AnimatedSprite2D.stop()
	
	move_and_slide()

func _on_atk_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.get_dmged(atk)
