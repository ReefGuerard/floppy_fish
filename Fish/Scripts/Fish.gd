extends RigidBody3D

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.is_pressed():
		apply_force_direction(self, Vector3(0,1,0), 10.0) # Adjust strength as needed

func apply_force_direction(rigid_body: RigidBody3D, direction: Vector3, strength: float) -> void:
	var force: Vector3 = direction.normalized() * strength
	rigid_body.apply_impulse(force)
