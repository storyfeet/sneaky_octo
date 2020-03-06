extends Node2D



# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const fpic = preload("res://pics/board/fish.png")

var fishes = []


func move_to(pos):
	position = pos*100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func add_fish(color):
	var nfish = Sprite.new()
	nfish.centered = true
	nfish.texture = fpic
	nfish.region_enabled=true
	nfish.region_rect = Rect2(color*50,0,50,50)
	fishes.push_back(color)
	add_child(nfish)
	position_fish()
	
func take_fish(color):
	for x in range(fishes.size()):
		if fishes[x] == color:
			fishes.erase(x)
			remove_child(get_child(x))
			position_fish()
			return true
	return false
	
func position_fish():
	var ch = get_children()
	var tot = ch.size()
	for x in range(tot):
		var p = 10 + 20*(x*2 +1) /tot*2.0
		ch[x].position = Vector2(p,p)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
