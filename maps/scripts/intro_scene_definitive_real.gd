extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enemygreeneye_enemy_killed() -> void:
	var move_out_of_sigth_vector : Vector3 = Vector3(0.0, -200.0, 0.0)
	$"NavigationRegion3D/LEVEL/START+CENTER/Structure2/FenceWillDisappear-col8".translate(move_out_of_sigth_vector)
	$"NavigationRegion3D/LEVEL/START+CENTER/Structure2/FenceWillDisappear-col10".translate(move_out_of_sigth_vector)
	$"NavigationRegion3D/LEVEL/START+CENTER/Structure2/FenceWillDisappear-col11".translate(move_out_of_sigth_vector)
	$"NavigationRegion3D/LEVEL/START+CENTER/Structure2/FenceWillDisappear-col12".translate(move_out_of_sigth_vector)
	$"NavigationRegion3D/LEVEL/START+CENTER/Structure2/FenceWillDisappear-col13".translate(move_out_of_sigth_vector)
	$"NavigationRegion3D/LEVEL/START+CENTER/Structure2/FenceWillDisappear-col14".translate(move_out_of_sigth_vector)














