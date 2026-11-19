extends CharacterBody2D

const initial_speed = 400 # initial dash from a standstill
const max_speed = 1200
const acceleration = 1200 # when moving foward
const deceleration = 3500 # when moving backward
const friction_per_s = 2000 # when not moving
const air_factor = 0.5 # reduce accleration in midair

const jump_impulse = 900 # initial jump speed
const jump_end_impulse = 450 # downward impulse on jump release
const jump_duration_s = 0.6 # maximum floaty time when holding jump

const jump_input_buffer_duration = 0.1 # you can jump just before hitting the ground
const coyote_duration = 0.1 # you can jump just after walking off a ledge

const stomp_speed = 1500 # maximum floaty time when holding jump

var jump_input_held_time = 0 # how long jump button has been held
var jump_time = 0 # how long jump action has occurred
var coyote_time = 0 # how long since leaving the ground

var is_stomping = false

func _physics_process(_delta):
	if Input.is_action_just_pressed("Stomp"):
			is_stomping = true
	if is_stomping:
		velocity = stomp_speed * get_gravity().normalized()
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
		if is_stomping:
			# Land from an air stomp
			is_stomping = false
			for stompable in $StompArea.get_overlapping_areas():
				stompable.receive_stomp() # Everything in collision layer 4 should implement this!
	else:
		$AnimatedSprite2D.animation = "jump"
		coyote_time += _delta
	
	if Input.is_action_pressed("Jump"):
		# check if we are mostly on the ground, with some timing tolerance.
		if coyote_time <= coyote_duration and jump_input_held_time <= jump_input_buffer_duration:
			velocity = jump_impulse * up_direction
			jump_time = 0
			coyote_time = 999
		jump_input_held_time += _delta
	elif Input.is_action_just_released("Jump"):
		# Apply downward force on jump end, diminishing with jump duration
		velocity += get_gravity().normalized() * jump_end_impulse * max(0, 1 - jump_time / jump_duration_s)
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
