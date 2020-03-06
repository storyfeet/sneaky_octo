
static func mov_dir(p,d):
	return p + dir_as_vec(d)

static func dir_as_vec(d):
	match d % 4:
		0:return Vector2(0,-1)
		1:return Vector2(1,0)
		2:return Vector2(0,1)
		_:return Vector2(-1,0)
		
static func all_adj(pos, size = Vector2(11,11)):#->[pos]
	var res = []
	for d in range(4):
		var vp = dir_as_vec(d)
		var np = pos + vp
		if np.x >=0 and np.y >= 0:
			if np.x < size.x and np.y < size.y:
				res.push_back(np)
	return res
	

static func sqr_mid(pos,tsize):
	return (pos + Vector2(0.5,0.5))* tsize
	
static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
		
static func path_to_point(paths,dest):
	var res = [dest]
	var c_dest = dest
	while true:
		var n_dest = paths.get(c_dest)
		if n_dest == null or n_dest.prev== null:
			if res.size() == 1:
				return null
			return res
			
		c_dest = n_dest.prev
		res.push_front(c_dest)

		

class PathNode :
	var prev
	var is_dest = true
	func _init(p,d=true):
		prev = p
		is_dest = d
