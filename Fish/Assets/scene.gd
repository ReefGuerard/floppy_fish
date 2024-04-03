extends Node3D

signal camera_ready

const fish_path = "scene/Floppy"

var camera
var fish

func _ready():
	camera = get_viewport().get_camera_3d()
	camera_ready.emit(camera)
