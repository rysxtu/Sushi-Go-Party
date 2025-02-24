extends Node3D

@export var rotation_curve: Curve

func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	transform = transform.sphere_interpolate_with(target_transform, ANIM_SPEED * delta)
	rotation.z = lerp(rotation.z, target_rotation, ANIM_SPEED * delta)
