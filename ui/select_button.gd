extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal on_toggle_button(nv)

var selected=false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(tx,selected=false):
	$Button.text = tx
	select( selected)
	
	
func toggle():
	select(!selected)

func select(b):
	selected = b
	color = "#ffffff" if selected else "#000000"
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	toggle()
	emit_signal("on_toggle_button",selected)
