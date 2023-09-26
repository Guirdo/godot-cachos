extends CharacterBody2D


const SPEED = 200.0
const RAY_FLOOR_POSITION_X = 20
const RAY_WALL_TARGET_POSITION_X = 20


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	velocity.x = SPEED
	$ray_cast_floor_detection.position.x = RAY_FLOOR_POSITION_X
	$ray_cast_wall_detection.target_position.x = RAY_WALL_TARGET_POSITION_X
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if not $ray_cast_floor_detection.is_colliding() || $ray_cast_wall_detection.is_colliding():
		velocity.x *= -1
		$ray_cast_floor_detection.position.x *= 1
		$ray_cast_wall_detection.target_position.x *= -1
		

	move_and_slide()
