extends Node2D

const mov_util = preload("res://game/movement_util.gd")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
var tsize = 5
var face = 0
var pos = Vector2(0,0)

func _ready():
	pass # Replace with function body.
	
func setup(tsize,pos, face):
	self.tsize = tsize
	self.pos = pos
	self.face = (face +4) %4
	scale = Vector2(tsize,tsize)/200
	position = mov_util.sqr_mid(pos,tsize)
	rotation_degrees = (180+(face * 90)) %360

signal move_complete;

func my_dir_vec():
	return mov_util.dir_as_vec(self.face)




func follow_path(pp):
	print("follow_path pp = ",pp)
	for p in pp :
		if p != face :
			rot_to(p)
			yield($Tween,"tween_completed")
		move_to(pos + my_dir_vec())
		yield($Tween,"tween_completed")
	emit_signal("move_complete")

func move_to(pos):
	self.pos = pos;
	var newpos = mov_util.sqr_mid(pos,tsize)
	$Tween.interpolate_property(self,"position",position,newpos,0.6,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
	$Tween.start()
	return $Tween

func rot_to(dir):
	self.face = (dir +4) %4;
	var newface = (180 + (face * 90))%360 
	$Tween.interpolate_property(self,"rotation_degrees",rotation_degrees,newface,0.6,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
	$Tween.start()
	return $Tween

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
