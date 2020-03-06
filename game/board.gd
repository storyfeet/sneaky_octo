extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const FishMaker = preload("res://game/fish_holder.tscn")
const octo = preload("res://game/octo.tscn")
const Keeper = preload("res://game/keeper.tscn")
const TileBoard = preload("res://game/tileboard.tscn")
const mov_util = preload("res://game/movement_util.gd")
const PathPointer = preload("res://path_pointer.tscn")


var octos = {}
var keepers = {}
var fish = {}
var turn = 0;
var g_state = GSTATE.READY;
var vis_path = {}
var sel_octo = null
var sel_loc = null
#var kp_home_end_turn = false

enum TILETYPE{
	GREEN = 0,
	RED = 1,
	PURPLE =2,
	BLUE = 3,
	FISH_TANK = 4,
	PATH1 = 5
	PATH2 = 6
	SHOWER_ENT = 7
	SHOWER = 8
}

enum GSTATE {
	READY,
	SELECTED,
	ANIM,
	KEEPER_HOME,
}

func is_path(t_type):
	return t_type == 5  or t_type == 6


func next_turn():
	set_turn((turn + 1 ) % 4)
	
func set_turn(n):
	turn = n
	for cp in octos:
		var c = octos.get(cp)
		if c.col == turn:
			c.set_status(c.STATUS.READY)
		else:
			c.set_status(c.STATUS.DONE)
	mov_util.delete_children($PathView)
	de_shower()
	g_state = GSTATE.READY

func add_fish(pos,color):
	var fholder = fish.get(pos)
	if fholder !=null:
		fholder.add_fish(color)
	else:
		var nfish =FishMaker.instance()
		nfish.add_fish(color)
		nfish.move_to(pos)
		$FishArea.add_child(nfish)
		fish[pos] = nfish
		
func add_octo(col,tp):
	for x in range(11):
		for y in range(11):
			var pos = Vector2(x,y)
			if $Tilemap.get_cellv(pos) == tp and octos.get(pos) == null :
				var oc = octo.instance()
				oc.setup(col,tp,100,pos)
				$OctoArea.add_child(oc)
				octos[pos] = oc
				return 

func add_keepers():
	for x in range(11):
		for y in range(11):
			var pos = Vector2(x,y)
			if $Tilemap.get_cellv(pos) == 7 :
				var kp = Keeper.instance()
				var fc = keeper_turn_to_path(pos,2,1);
				kp.setup(100,pos,fc)
				$OctoArea.add_child(kp)
				keepers[pos] = kp
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# Add fish to all tanks
	for x in range(11):
		for y in range(11):
			var pos = Vector2(x,y)
			if $Tilemap.get_cellv(pos) == 4:
				#for n in range(0,randi()%10+1):
				add_fish(pos,randi()%5)
	
	for ncol in range(4):
		for tp in range(4):
			add_octo(ncol,tp)
	add_keepers()
	
	#$Tilemap.connect("tile_selected",self,"tile_select")
	set_turn(0)
		
		
func keeper_path(keep):
	var dice = (randi() %6)
	var turn = (dice % 2) *2 -1 
	var preturn1 = 0
	var preturn2 = 0
	if dice / 2 ==2 : #fd fd turn 
		preturn1 = turn
	if dice /2 == 1 : # fd turn fd
		preturn2 = turn
	print("dice,turn = ",dice,",",turn)
	var res = []

	var m1 =  keeper_turn_to_path(keep.pos,keep.face+ preturn1,turn)
	if m1 == null:
		return res
	res.push_back(m1)
	var npos = mov_util.mov_dir(keep.pos,m1)
	if octos.get(npos):
		return res
	var m2 = keeper_turn_to_path(npos,keep.face+preturn2,turn)
	if m2 == null:
		return res;
	res.push_back(m2)

	return res


func keeper_turn_to_path(pos,face,turn):
	print("kttp pos , face, turn =" ,pos,",",face,",",turn) 
	for i in range(4):
		var ang = (4+face + turn * i)%4
		print("kttp ang= ",ang)
		var npos = pos+mov_util.dir_as_vec(ang)
		var cv =  $Tilemap.get_cellv(npos)
		var at_pos = keepers.get(npos)
		if (cv == 5 or cv == 6):
			if (at_pos == null) :
				return ang
	return null

func de_shower():
	for kloc in keepers:
		if $Tilemap.get_cellv(kloc) == TILETYPE.SHOWER:
			de_shower_1(kloc)

func de_shower_1(kloc):
	var kp = keepers.get(kloc)
	for dir in range(4):
		var np = mov_util.mov_dir(kloc,dir)
		if $Tilemap.get_cellv(np) == TILETYPE.SHOWER_ENT:
			kp.follow_path([dir])
			yield(kp,"move_complete")
			var ang = keeper_turn_to_path(kp.pos,kp.face,1)
			if ang != kp.face and ang != null :
				var tw = kp.rot_to(ang)
				yield(tw,"tween_completed")
				keepers.erase(kloc)
				keepers[np] = kp
			return 
					
					

		
func tile_select(pos,ttype):
	match g_state :
		GSTATE.READY:
			var kp = keepers.get(pos)
			if kp != null and $Tilemap.get_cellv(pos) != TILETYPE.SHOWER:
				var k_path = keeper_path(kp)
				g_state = GSTATE.ANIM
				if k_path.size() > 0:
					keepers.erase(kp.pos)
					kp.follow_path(k_path)
					yield(kp,"move_complete")
					if octos.get(kp.pos) != null:
						send_home(kp.pos)
					keepers[kp.pos] = kp
					
				next_turn()
				return 
			var oc = octos.get(pos)
			if oc == null:
				return
			if oc.col != turn:
				return
			if oc.status != oc.STATUS.READY:
				return
			oc.set_status(oc.STATUS.ACTIVE);
			sel_octo = oc
			var paths = octo_path(oc)
			show_path(paths)
			g_state = GSTATE.SELECTED;
			
		GSTATE.SELECTED:
			var sel_path = mov_util.path_to_point(vis_path,pos)
			print("Sel Path = " ,sel_path)
			if sel_path != null:
				g_state = GSTATE.ANIM
				mov_util.delete_children($PathView)
				octos.erase(sel_octo.pos)
				sel_octo.follow_path(sel_path)
				yield(sel_octo,"move_complete")
				sel_octo.set_status(sel_octo.STATUS.DONE)
				octos[pos] = sel_octo
				if keepers.get(pos) != null:
					send_home(pos)
					return
				handle_noise(sel_path)
				g_state = GSTATE.READY
				
				
			var oc = octos.get(pos);
			
			if oc == sel_octo:
				oc.set_status(oc.STATUS.READY)
				g_state = GSTATE.READY;
				mov_util.delete_children($PathView)
		GSTATE.KEEPER_HOME:
			if is_empty_shower(pos):
				g_state = GSTATE.ANIM
				var kp = keepers.get(sel_loc)
				var tw = kp.move_to(pos);
				keepers.erase(sel_loc)
				keepers[pos] = kp
				yield(tw,"tween_completed")
				mov_util.delete_children($PathView)
				g_state = GSTATE.READY
						
					

	
func on_mouse_event(event):
	if event.is_pressed():
		var pos = get_local_mouse_position()
		var mpos = $Tilemap.world_to_map(pos)

		#var pos = event.position
		var ttype = $Tilemap.get_cellv(mpos)
		if ttype != -1:
			tile_select(mpos,ttype);
	



func octo_path(oc,dist = 3):
	var st_tile = $Tilemap.get_cellv(oc.pos)
	var res = {oc.pos:mov_util.PathNode.new(null,false)};
	var starts = [oc.pos]
	if st_tile < 4:
		while starts.size()> 0:
			var st2 = []
			for s in starts:
				for np in mov_util.all_adj(s):
					if res.get(np) == null:
						var n_tile = $Tilemap.get_cellv(np)
						var idest = is_path(n_tile) and octos.get(np) == null
						print("octopath idest = ",np,idest);
						var ppos = mov_util.PathNode.new(oc.pos,idest )
						if n_tile == st_tile:
							st2.push_back(np)
						if idest or n_tile == st_tile:
							res[np] = ppos
			starts = st2
		return res
			
	if is_path(st_tile):
		for n in range(dist):
		#	print("on_path: starts = ")
			var st2 = []
			for s in starts:
				for np in mov_util.all_adj(s):
					var n_tile = $Tilemap.get_cellv(np)
					if is_path(n_tile) and res.get(np)==null:
						res[np] = mov_util.PathNode.new(s,octos.get(np) ==null)
						if keepers.get(np) == null:
							st2.push_back(np)
			starts = st2
		return res

	return {}
	
func show_path(paths):
	vis_path = paths
	for dest in paths:
		var d_dat = paths.get(dest)
		if d_dat.is_dest:
			show_pointer(dest,d_dat.prev)
			
func send_home(loc):
	var oc = octos.get(loc)
	if oc != null:
		for x in range(11):
			for y in range(11):
				var hloc = Vector2(x,y)
				if $Tilemap.get_cellv(hloc) == oc.col and octos.get(hloc) == null:
					oc.follow_path([hloc])
					yield(oc,"move_complete")
					octos.erase(loc)
					octos[hloc] = oc
					send_keeper_home(loc)
					return

func send_keeper_home(loc):
	print("Send Keeper home")
	var kp = keepers.get(loc)
	if kp != null:
		g_state = GSTATE.KEEPER_HOME
		sel_loc = loc
		highlight_showers(loc)
	
func highlight_showers(from):
	for x in range(11):
		for y in range(11):
			var l = Vector2(x,y)
			if is_empty_shower(l):
				show_pointer(l,from)

func show_pointer(at,from):
	var ang = at.angle_to_point(from)-PI/2.0
	var pt = PathPointer.instance()
	pt.position = mov_util.sqr_mid(at,100)
	pt.rotation = ang
	$PathView.add_child(pt)
	
	

func is_empty_shower(loc):
	if $Tilemap.get_cellv(loc) != TILETYPE.SHOWER or keepers.get(loc) != null:
			return false
	for adj in mov_util.all_adj(loc):
		if $Tilemap.get_cellv(adj) ==TILETYPE.SHOWER_ENT and keepers.get(adj) != null:
			return false
	return true

func handle_noise(pp):
	var np = noise_path(pp)
	if np.size() == 0:
		return
	
	for kpos in np:
		var ndir = np[kpos]
		var kp = keepers.get(kpos)
		if kp.face == ndir:
			kp.follow_path([ndir])
			yield(kp,"move_complete")
			keepers.erase(kpos)
			keepers[mov_util.mov_dir(kpos,ndir)] = kp
			if octos.get(kp.pos)!= null:
				send_home(kp.pos)
		else:
			kp.rot_to(ndir)
		


func noise_path(pp):
	var res = {}
	for s_orig in pp:
		if not is_path($Tilemap.get_cellv(s_orig)):
			continue
		for dir in range(4):
			var cont = true
			var s_pos = s_orig
			while cont:
				s_pos = mov_util.mov_dir(s_pos,dir)
				var tile = $Tilemap.get_cellv(s_pos)
				if is_path(tile) or tile == TILETYPE.SHOWER_ENT:
					var kp = keepers.get(s_pos)
					if kp != null:
						res[s_pos] = (dir +2)%4
						cont = false
					if octos.get(s_pos) != null:
						cont = false
				else:
					cont = false
	return res

			