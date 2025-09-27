extends Node2D

# Grid vars
const COLS: int = 10
const ROWS: int = 20

# Movement vars
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
const start_pos := Vector2i(5, 1)
const steps_req: int = 50
var steps: Array
var cur_pos: Vector2i
var speed: float

# Game piece vars
var piece_type
var next_piece_type
var rotation_index: int = 0
var active_piece: Array

# Tilemap vars
var active_tile_id: int = 1
var piece_atlas: Vector2i
var next_piece_atlas: Vector2i

# tetrominoes
var i_0 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
var i_90 := [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]
var i_180 := [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)]
var i_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]
var i := [i_0, i_90, i_180, i_270]

var t_0 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var t_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var t := [t_0, t_90, t_180, t_270]

var o_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_90 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_180 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o := [o_0, o_90, o_180, o_270]

var z_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
var z_90 := [Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var z_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var z_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
var z := [z_0, z_90, z_180, z_270]

var s_0 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
var s_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var s_180 := [Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)]
var s_270 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var s := [s_0, s_90, s_180, s_270]

var l_0 := [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var l_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var l_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)]
var l_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
var l := [l_0, l_90, l_180, l_270]

var j_0 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var j_90 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)]
var j_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var j_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
var j := [j_0, j_90, j_180, j_270]

var shapes := [i, t, o, z, s, l, j]
var shapes_full := shapes.duplicate()

# TileMapLayer vars
@onready var board: TileMapLayer = %Board
@onready var active: TileMapLayer = %Active


func _ready() -> void:
	print("Using TileMapLayer")
	new_game()


func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		steps[0] += 10
	elif Input.is_action_pressed("ui_right"):
		steps[1] += 10
	elif Input.is_action_pressed("ui_down"):
		steps[2] += 10
	elif Input.is_action_just_pressed("rotate"):
		rotate_piece()
	
	steps[2] += speed
	for d in range(steps.size()):
		if steps[d] > steps_req:
			move_piece(directions[d])
			steps[d] = 0


func new_game() -> void:
	speed = 1.0
	steps = [0, 0, 0] # 0:left, 1:right, 2:down
	piece_type = pick_piece()
	piece_atlas = Vector2i(shapes_full.find(piece_type), 0)
	create_piece()


func pick_piece():
	if shapes.is_empty():
		shapes = shapes_full.duplicate()
	
	shapes.shuffle()
	var piece = shapes.pop_front()
	return piece


func create_piece():
	steps = [0, 0, 0]
	cur_pos = start_pos
	active_piece = piece_type[rotation_index]
	draw_piece(active_piece, cur_pos, piece_atlas)


func draw_piece(piece, pos, atlas) -> void:
	for p in piece:
		active.set_cell(pos + p, active_tile_id, atlas)


func clear_piece():
	for p in active_piece:
		active.erase_cell(cur_pos + p)


func move_piece(dir) -> void:
	if can_move(dir):
		clear_piece()
		cur_pos += dir
		draw_piece(active_piece, cur_pos, piece_atlas)


func rotate_piece():
	if can_rotate():
		clear_piece()
		rotation_index = (rotation_index + 1) % 4
		active_piece = piece_type[rotation_index]
		draw_piece(active_piece, cur_pos, piece_atlas)


func can_move(dir):
	var cm = true
	for p in active_piece:
		if not is_free(p + cur_pos + dir):
			cm = false
	return cm


func can_rotate():
	var cr = true
	var temp_rotation_index = (rotation_index + 1) % 4
	for p in piece_type[temp_rotation_index]:
		if not is_free(p + cur_pos):
			cr = false 
	return cr


func is_free(pos) -> bool:
	return board.get_cell_source_id(pos) == -1
