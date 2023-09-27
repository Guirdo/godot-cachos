extends Node2D

var floor_detected = false
var ray_cast_initial_value = 36
var safe_time_out = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$ray_cast_floor_detection.target_position.y = ray_cast_initial_value
	$safe_time.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not floor_detected && safe_time_out:
		$ray_cast_floor_detection.target_position.y += 6
		if $ray_cast_floor_detection.is_colliding():
			floor_detected = true
			$ray_cast_floor_detection.target_position.y -= 6
			init_spikeball()
			
func init_spikeball():
	var number_of_chains = ($ray_cast_floor_detection.target_position.y - ray_cast_initial_value) / 6
	$SpikedBall.position.y += (number_of_chains * 6)
	for i in range(number_of_chains):
		var new_ring = preload("res://scenes/enemies/one_chain.tscn").instantiate()
		new_ring.position = Vector2(0,(6*(i+1)))
		self.add_child(new_ring)
	
	$rotarion_animation.play("regular_move")


func _on_safe_time_timeout():
	safe_time_out = true

func _on_area_collition_with_map_body_entered(body):
	$rotarion_animation.speed_scale *= -1
