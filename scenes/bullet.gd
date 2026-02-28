extends Area2D

@onready var plr = get_parent().find_child('plr')

var accel := Vector2.ZERO
var velo := Vector2.ZERO
func _physics_process(delta: float) -> void:
	accel = (plr.global_position - global_position).normalized() * 1500
	velo += accel * delta
	rotation= velo.angle()
	velo = velo.limit_length(650)
	global_position += velo * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('plr') or body.is_in_group('enemy'):
		body.get_dmged(10, get_parent().find_child('rock'))
	queue_free()
