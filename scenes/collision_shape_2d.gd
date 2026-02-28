extends CollisionShape2D
@onready var asd = get_parent().scale.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().get_parent().get_parent().flip_h == true:
		if get_parent().scale.x != asd:
			return
		get_parent().scale.x = -get_parent().scale.x
	else:
		if get_parent().scale.x == asd:
			return
		get_parent().scale.x = asd
