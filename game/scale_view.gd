extends ViewportContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var drag_on = false;
var drag_pos  = Vector2(0,0);

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered",self,"set_mouse_over",[true]);
	
	connect("mouse_exited",self,"set_mouse_over",[false]);


func _input(event):
	#do even without mousover
	if event is InputEventMouseButton and not event.is_pressed():
		if event.button_index == BUTTON_MIDDLE:
			drag_on = false;
			return
	
	if not mouse_over():
		return
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				$Board.scale += Vector2(0.1,0.1)
				return
			if event.button_index == BUTTON_WHEEL_DOWN:
				$Board.scale -= Vector2(0.1,0.1)
				if $Board.scale.x < 0.5:
					$Board.scale = Vector2(0.5,0.5)
				return
			if event.button_index == BUTTON_MIDDLE:
				if event.doubleclick:
					$Board.scale = Vector2(0.55,0.55)
					$Board.position = Vector2(0,0)
				drag_on = true;
				drag_pos = event.position;
				return
	if event is InputEventMouseMotion:
		if drag_on:
			$Board.position += event.position - drag_pos;
			drag_pos = event.position
			return
	$Board.on_mouse_event(event)
			
	            
            # call the zoom function

func mouse_over():
	var mpos = get_local_mouse_position()
	if mpos.x < 0:
		return false
	if mpos.y < 0:
		return false
	if mpos.x > rect_size.x:
		return false
	if mpos.y > rect_size.y:
		return false
	return true	
	#mouse_over = b





# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
