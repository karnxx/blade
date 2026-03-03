extends Control

func _process(delta: float) -> void:
	$ProgressBar.max_value = get_parent().get_parent().maxstm
	$ProgressBar2.max_value = get_parent().get_parent().maxstm
	$ProgressBar.value = get_parent().get_parent().stm
	$ProgressBar2.value = get_parent().get_parent().stm
	
	$ProgressBar3.max_value = get_parent().get_parent().mhealth
	$ProgressBar4.max_value = get_parent().get_parent().mhealth
	$ProgressBar3.value = get_parent().get_parent().chealth
	$ProgressBar4.value = get_parent().get_parent().chealth
	
