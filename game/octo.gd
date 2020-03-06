extends Node2D

const mov_util = preload("res://game/movement_util.gd")

var pos = Vector2(0,0)
var otype = 0
var col = 0
var twidth = 1
var status = STATUS.DONE

signal move_complete

enum STATUS{
	ACTIVE,
	READY,
	DONE,
}

enum COLOR {
	GREEN = 0,
	RED = 1,
	PURPLE =2,
	BLUE = 3,
}

enum OTYPE{
	SPEED = 0,
	SQUEEZE =1,
	SHOOT = 2,
	STEALTH = 3,
}

func col_str(c):
	match c :
		COLOR.GREEN:
			return "green"
		COLOR.RED:
			return "red"
		COLOR.BLUE:
			return "blue"
		COLOR.PURPLE:
			return "purple"
	return "__NO_COLOR__"

func otype_str(t):
	match t:
		OTYPE.SPEED:
			return "Speed"
		OTYPE.STEALTH:
			return "Sneaks"
		OTYPE.SQUEEZE:
			return "Squeez"
		OTYPE.SHOOT:
			return "Sniper"
		
func f_str():
	return str("res://pics/chars/",otype_str(otype),"-",col_str(col),".png")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(otype,ocol,twidth,pos):
	self.pos = pos
	self.col = ocol
	self.otype = otype
	self.twidth = 0
	$Scalebox/Sprite.texture = load(f_str())
	$Scalebox.scale = Vector2(1,1) * (twidth/200.0)
	position = mov_util.sqr_mid(pos , twidth);

func set_status(ns):
	self.status = ns
	match status:
		STATUS.DONE:
			$Scalebox/GBut.visible = false;
			$Scalebox/BBut.visible = false;
		STATUS.READY:
			$Scalebox/GBut.visible = true;
			$Scalebox/BBut.visible = false;
		STATUS.ACTIVE:
			$Scalebox/GBut.visible = true;
			$Scalebox/BBut.visible = true;


func follow_path(pp):
	for p in pp :
		pos = p
		var np = mov_util.sqr_mid(p,100)
		$Tween.interpolate_property(self,"position",position,np,0.6,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
		$Tween.start()
		yield($Tween,"tween_completed")
	emit_signal("move_complete")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
