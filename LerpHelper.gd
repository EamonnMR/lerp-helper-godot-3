class_name LerpHelper

# Calculates lerp/extrapolation results
var entity: Node
var time: int
var past: NetFrame
var future: NetFrame
var lerp_factor: float
var extrapolation_factor: float
var can_lerp: bool
var can_extrapolate: bool

func _init(entity: Node, id):
	self.entity = entity
	self.past = Client.get_net_frame_current(id)
	self.future = Client.get_net_frame_next(id)
	self.time = Client.time

	if (not future) or (not past):
		# At least two frames are required for lerping
		can_lerp = false
		can_extrapolate = false
		
	elif future.time > time: # Interpolate
		var time_range = future.time - past.time
		var time_offset = time - past.time
		lerp_factor = float(time_offset) / float(time_range)
		can_lerp = true
		can_extrapolate = false

	else: # Extrapolate
		# Future is in the past - extrapolate by dead reckoning
		extrapolation_factor = float(time - past.time) / float(future.time - past.time) - 1.00
		can_lerp = false
		can_extrapolate = true

func lerp_member(member: String):
	entity.set(member,
		lerp(
			past.state[member], future.state[member], lerp_factor
		)
	)

func lerp_angle_member(member: String):
	entity.set(member,
		lerp_angle(
			past.state[member], future.state[member], lerp_factor
		)
	)

func lerp_boolean_member(member: String):
	entity.set(member, past.state[member] if lerp_factor < 0.5 else future.state[member])

func lerp_transform_member(member: String):
	entity.set(member,
		past.state[member].interpolate_with(future.state[member], lerp_factor)
	)

func lerp_vector_member(member: String):
	entity.set(member,
		past.state[member].linear_interpolate(future.state[member], lerp_factor)
	)
func lerp_angle_vector2_member(member: String):
	entity.set(member,
		Vector2(
			lerp_angle(
				past.state[member].x, future.state[member].x, lerp_factor
			),
			lerp_angle(
				past.state[member].y, future.state[member].y, lerp_factor
			)
		)
	)
	
func extrapolate_member(member: String):
	var known_delta = future.state[member] - past.state[member]
	entity.set(member,
		future.state[member] + (known_delta * extrapolation_factor)
	)

func extrapolate_angle_member(member: String):
	var known_delta = future.state[member] - past.state[member]
	entity.set(member,
		Game.anglemod(future.state[member] + (known_delta * extrapolation_factor))
	)

func extrapolate_transform_member(member: String):
	# Shot in the dark
	entity.set(member,
		past.state[member].interpolate_with(future.state[member], 1 + extrapolation_factor)
	)
