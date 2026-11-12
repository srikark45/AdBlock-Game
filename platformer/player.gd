extends CharacterBody2D

const initial_speed = 100 # initial dash from a standstill
const max_speed = 200
const acceleration = 200 # when moving foward
const deceleration = 700 # when moving backward
const friction_per_s = 300 # when not moving
const air_factor = 0.5 # reduce accleration in midair

const jump_impulse = 150 # initial jump speed
const jump_duration_s = 1.0 # maximum floaty time when holding jump

const jump_input_buffer_duration = 0.1 # you can jump just before hitting the ground
const coyote_duration = 0.1 # you can jump just after walking off a ledge
const postponed_gravity_factor = .5 # how fast you descend after releasing jump

var jump_input_held_time = 0 # how long jump button has been held
var jump_time = 0 # how long jump action has occurred
var coyote_time = 0 # how long since leaving the ground
var postponed_gravity = 0 # downward force applied after releasing jump

func _physics_process(_delta):
	var right_direction = -up_direction.orthogonal()
	var velocity_r = velocity.dot(right_direction)
	var input_r = Input.get_axis("Left", "Right")
	var accel_mult = 1.0 if is_on_floor() or jump_time < coyote_time else air_factor
	
	match [int(sign(velocity_r)), int(sign(input_r))]:
		[_, 0]:
			# when passively sliding to a stop
			velocity_r = move_toward(velocity_r, 0, friction_per_s * _delta * accel_mult)
		[1, -1], [-1, 1]:
			# when actively reversing direction
			velocity_r = move_toward(velocity_r, 0, deceleration * _delta * accel_mult)
		_:
			if abs(velocity_r) < initial_speed:
				# initial burst of speed from a standstill
				velocity_r = input_r * initial_speed * accel_mult
			else:
				# accelerating forward up to max speed
				velocity_r = move_toward(velocity_r, input_r * max_speed, acceleration * _delta * accel_mult)
	velocity = velocity.project(up_direction) + velocity_r * right_direction
	
	if is_on_floor():
		coyote_time = 0
		jump_time = 999
		postponed_gravity = 0
	else:
		coyote_time += _delta
	
	if Input.is_action_pressed("Jump"):
		# check if we are mostly on the ground, with some timing tolerance.
		if coyote_time <= coyote_duration and jump_input_held_time <= jump_input_buffer_duration:
			velocity = jump_impulse * up_direction
			jump_time = 0
			coyote_time = 999
		jump_input_held_time += _delta
	elif Input.is_action_just_released("Jump"):
		jump_input_held_time = 0
		jump_time = 999
		# Apply downward force proportional to gravity ignored while holding the jump.
		velocity += get_gravity() * postponed_gravity * postponed_gravity_factor
		postponed_gravity = 0
	
	if jump_input_held_time >= jump_time:
		# We have been holding jump since we left the ground.
		if jump_time < jump_duration_s:
			# Gravity is decreased early in the jump but increased later in the jump.
			var jump_completion = jump_time / jump_duration_s
			velocity += get_gravity() * _delta * jump_completion * 2
			postponed_gravity += (1 - jump_completion * 2) * _delta
		jump_time += _delta
	else:
		velocity += get_gravity() * _delta

	move_and_slide()
