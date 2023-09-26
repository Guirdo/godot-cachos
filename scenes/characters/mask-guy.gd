extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var allow_animation:bool = false
var leaved_floor:bool = false
var had_jumped:bool = false
var max_jumps:int = 2
var count_jumps:int = 0
var double_jump: bool = false
var ray_cast_direction = 10.5
var direction
var stuck_on_wall: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$AnimatedSprite2D.play("appearing")
	$ray_cast_wall_jump.target_position.x = ray_cast_direction

func _physics_process(delta):
	if is_on_floor():
		leaved_floor = false
		had_jumped = false
		count_jumps = 0
	
	# Add the gravity.
	if not is_on_floor():
		if not leaved_floor:
			$coyote_timer.start()
			leaved_floor = true
		
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and right_to_jump():
		if count_jumps == 1:
			double_jump = true
		count_jumps+=1
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if $ray_cast_wall_jump.get_collider():
		if $ray_cast_wall_jump.get_collider().is_in_group("wall_jump"):
			# Only allows to get stuck on the wall when falling
			if velocity.y > 0:
				count_jumps = 0
				velocity.y = 0
				stuck_on_wall = true
		else:
			stuck_on_wall = false
	else: stuck_on_wall = false
	
	decide_animation()
	move_and_slide()
	

func decide_animation():
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
		$ray_cast_wall_jump.target_position.x = -ray_cast_direction
	elif direction > 0:
		$AnimatedSprite2D.flip_h = false
		$ray_cast_wall_jump.target_position.x = ray_cast_direction
	
	if double_jump:
		allow_animation = false
		$AnimatedSprite2D.play("double_jump")
		double_jump = false
	
	if not allow_animation: return
	
	if stuck_on_wall:
		$AnimatedSprite2D.play("side_jump")
	else:
		if velocity.x == 0:
			$AnimatedSprite2D.play("idle")
		elif velocity.x < 0:
			$AnimatedSprite2D.play("run")
		elif velocity.x > 0:
			$AnimatedSprite2D.play("run")
		
		if velocity.y > 0:
			$AnimatedSprite2D.play("fall")
		elif velocity.y < 0:
			$AnimatedSprite2D.play("jump")
		
func right_to_jump():
	if had_jumped:
		if count_jumps < max_jumps: return true
		else: return false
	if is_on_floor() || stuck_on_wall:
		had_jumped = true
		return true
	elif not $coyote_timer.is_stopped():
		had_jumped = true
		return true


func _on_animated_sprite_2d_animation_finished():
	allow_animation = true

func _on_coyote_timer_timeout():
	pass
