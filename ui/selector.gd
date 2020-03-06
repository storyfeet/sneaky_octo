extends VBoxContainer

const ButtMaker = preload("res://ui/select_button.tscn")

var selected = -1

export var items=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in items:
		add_text_selector(i)
		

	pass # Replace with function body.

func add_text_selector(tx):
	var nb = ButtMaker.instance()
	nb.setup(tx,false)
	nb.connect("on_toggle_button",self,"on_toggle_member",[get_children().size()])
	add_child(nb)
	
func on_toggle_member(v,n):
	var ch = self.get_children()
	for x in range(ch.size()):
		ch[x].select(x==n)


	
	
