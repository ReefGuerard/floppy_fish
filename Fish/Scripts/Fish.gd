extends RigidBody3D

var camera

func _ready():
	camera = get_viewport().get_camera_3d()
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var unscaled = camera.project_position(event.position, camera.transform.origin.z) - self.transform.origin
		var scaled = unscaled.normalized()
		apply_force_direction(self, scaled, 10.0) # Adjust strength as needed

func apply_force_direction(rigid_body: RigidBody3D, direction: Vector3, strength: float) -> void:
	var force: Vector3 = direction.normalized() * strength
	rigid_body.apply_impulse(force)
