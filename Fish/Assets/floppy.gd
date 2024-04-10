extends RigidBody3D

const skeleton_path = "Sketchfab_model/88c6adbdf2db45debc80dc1410d3ebb4_fbx/Object_2/RootNode/Fish_Rigged/Object_6/Skeleton3D"
const spine_names = [
	"bodyUpper_00",
	"bodyLower_01",
	"tail_02",
	"tail_end_07"
]

const diffusion_coefficient = 5.0
const spring_coefficient = 5.0

var camera
var skeleton
var gun_pivot # index of gun mount spinal node
var spine # indices of each spinal node
var rotational_velocities # of each spinal node

func _ready():
	skeleton = get_node(skeleton_path) as Skeleton3D
	spine = []
	rotational_velocities = []
	for s in spine_names:
		spine.append(skeleton.find_bone(s))
		rotational_velocities.append(Quaternion.IDENTITY)
	gun_pivot = spine[1]
	rotational_velocities[0] = Quaternion(Vector3(1, 0, 0), 0.5)

func _input(event):
	
	# on mouse click, blast the fish
	if event is InputEventMouseButton and event.is_pressed():
		var blast_source = skeleton.to_global(skeleton.get_bone_pose_position(gun_pivot))
		blast_source.z = 0
		var blast_target = camera.project_position(event.position, camera.transform.origin.z)
		var blast_dir = (blast_source - blast_target).normalized()
		self.apply_impulse(blast_dir * 10.0, blast_source)

func _physics_process(delta):
	
	# correct for drifting off of xy-plane
	var q = Quaternion(self.transform.basis)
	q.z = -q.x
	q.y = q.w
	self.transform.basis = Basis(q.normalized())
	
	# cap angular velocity
	if (self.angular_velocity.length() > 2 * PI):
		self.angular_velocity = self.angular_velocity.normalized() * 2 * PI
	
	# add jiggle
	for i in range(0, spine.size()):
		var s = spine[i]
		var curr_rot = skeleton.get_bone_pose_rotation(s)
		
		# solve 2nd order spring mechanics
		var displacement = curr_rot.inverse() * Quaternion(skeleton.get_bone_rest(s).basis)
		rotational_velocities[i] = rotational_velocities[i] * displacement
		var dQ = Quaternion.IDENTITY.slerp(rotational_velocities[i].normalized(), delta * spring_coefficient)
		skeleton.set_bone_pose_rotation(s, curr_rot * dQ)
		
	# diffuse velocities
	diffuse(delta, diffusion_coefficient)

# diffuses rotational velocities along the spine. Assumes the discretization
# (i.e., the spine, consisting of joints and bones) is equispaced
func diffuse(delta, c):
	var new_velocities = []
	var si = 1 - 2 * c * delta
	var so = c * delta
	var ai = 1 - c * delta
	var ao = c * delta
	new_velocities.append(ai * rotational_velocities[0] + ao * rotational_velocities[1])
	for i in range(1, rotational_velocities.size() - 1):
		new_velocities.append(so * rotational_velocities[i - 1] + si * rotational_velocities[i] + so * rotational_velocities[i + 1])
	new_velocities.append(ao * rotational_velocities[rotational_velocities.size() - 2] + ai * rotational_velocities[rotational_velocities.size() - 1])
	rotational_velocities = new_velocities

func _process(_delta):
	
	# lock camera position to fish
	camera.transform.origin.x = self.transform.origin.x
	camera.transform.origin.y = self.transform.origin.y

func _on_scene_camera_ready(cam):
	self.camera = cam
