extends CharacterBody2D

const initial_speed = 400 # initial dash from a standstill
const max_speed = 1200
const acceleration = 1200 # when moving foward
const deceleration = 3500 # when moving backward
const friction_per_s = 2000 # when not moving
const air_factor = 0.5 # reduce accleration in midair

const floor_jump_impulse = 700 # initial jump speed
const wall_jump_impulse_vertical = 500 # initial jump speed
const wall_jump_impulse_horizontal = 500 # initial jump speed
const jump_end_impulse = 350 # downward impulse on jump release
const jump_duration_s = 0.6 # maximum floaty time when holding jump

const jump_input_buffer_duration = 0.1 # you can jump just before hitting the ground
const coyote_duration = 0.1 # you can jump just after walking off a ledge

const stomp_speed = 1500 # maximum floaty time when holding jump

var jump_input_held_time = 0 # how long jump button has been held
var jump_time = 0 # how long jump action has occurred
var coyote_time = 0 # how long since leaving the ground
var last_surface_normal = Vector2.UP # last touched a wall vs. a floor

var is_stomping = false

func _physics_process(_delta):
	if Input.is_action_just_pressed("Stomp"):
			is_stomping = true
	if is_stomping:
		velocity = stomp_speed * -up_direction
	else:
		var right_direction = -up_direction.orthogonal()
		var velocity_r = velocity.dot(right_direction)
		var input_r = Input.get_axis("Left", "Right")
		var accel_mult = 1.0 if is_on_floor() or jump_time < coyote_time else air_factor
		
		match [int(sign(velocity_r)), int(sign(input_r))]:
			[_, 0]:
				# when passively sliding to a stop
				$AnimatedSprite2D.animation = "stand"
				velocity_r = move_toward(velocity_r, 0, friction_per_s * _delta * accel_mult)
			[1, -1], [-1, 1]:
				# when actively reversing direction
				$AnimatedSprite2D.animation = "walk"
				$AnimatedSprite2D.flip_h = input_r < 0
				velocity_r = move_toward(velocity_r, 0, deceleration * _delta * accel_mult)
			_:
				# accelerating
				$AnimatedSprite2D.animation = "walk"
				$AnimatedSprite2D.flip_h = input_r < 0
				if abs(velocity_r) < initial_speed * accel_mult:
					# initial burst of speed from a standstill
					velocity_r = input_r * initial_speed * accel_mult
				else:
					# accelerating forward up to max speed
					velocity_r = move_toward(velocity_r, input_r * max_speed, acceleration * _delta * accel_mult)
		velocity = velocity.project(up_direction) + velocity_r * right_direction
	
	if is_on_floor():
		coyote_time = 0
		jump_time = 999
		last_surface_normal = get_floor_normal()
		if is_stomping:
			# Land from an air stomp
			is_stomping = false
			for stompable in $StompArea.get_overlapping_areas():
				stompable.receive_stomp() # Everything in collision layer 4 should implement this!
	elif is_on_wall():
		last_surface_normal = get_wall_normal()
		coyote_time = 0
	else:
		$AnimatedSprite2D.animation = "jump"
		coyote_time += _delta
	
	if Input.is_action_pressed("Jump"):
		# check if we are mostly on the ground, with some timing tolerance.
		if coyote_time <= coyote_duration and jump_input_held_time <= jump_input_buffer_duration:
			if last_surface_normal.y < -.7: # floor jump
				velocity = velocity.slide(up_direction) + floor_jump_impulse * up_direction
			else: # wall jump
				var x_dir = sign(last_surface_normal.x)
				velocity = wall_jump_impulse_horizontal * x_dir * Vector2.RIGHT \
						+ wall_jump_impulse_vertical * up_direction
			jump_time = 0
			coyote_time = 999
			jump_input_held_time = 2 # prevents wall jump from instantly triggering
		jump_input_held_time += _delta
	elif Input.is_action_just_released("Jump"):
		# Apply downward force on jump end, diminishing with jump duration
		velocity += up_direction * -jump_end_impulse * max(0, 1 - jump_time / jump_duration_s)
		jump_input_held_time = 0
		jump_time = 999
	
	if jump_input_held_time >= jump_time and jump_time < jump_duration_s:
		# We are holding a jump and have been since we left the ground.
		# Gravity is decreased early in the jump.
		var jump_completion = jump_time / jump_duration_s
		velocity += get_gravity() * jump_completion * _delta
		jump_time += _delta
	else:
		velocity += get_gravity() * _delta

	move_and_slide()
