extends Node2D
# ダンジョンの自動生成（1階層）と管理を行う

enum RoomType{		# 部屋の種類
	Start,			# スタート地点
	Goal,			# ゴール地点
	Others			# その他
}

@onready var dungeonmap = $Dungeon_map
@onready var dungeonrooms = $Dungeon_rooms
@onready var mappin = $Mappin


signal player_move(pos:Vector2)		# プレイヤーを移動させる

var _width = 0			# 階層のマスの数（横） 
var _height = 0			# 階層のマスの数（縦）
var _roomnum  = 0		# 階層に部屋を何個作るか


func _ready():

	# 初期処理
	_width = Gamesettings.DUNGEON_WIDTH
	_height = Gamesettings.DUNGEON_HEIGHT
	_roomnum = Gamesettings.NUMBER_OF_ROOMS

	# 部屋の生成
	dungeonrooms.create_rooms()

	# 確認用
	var temp = dungeonrooms.get_dungeon2d()
	for i in range(temp.size()):
		print(temp[i])
	# 確認用
	temp = dungeonrooms.get_rooms()
	for i in range(temp[0].objects.size()):
		print(temp[0].objects[i])



func proc() -> void:

	# 現在の部屋を表示
	dungeonrooms.proc()
	# ダンジョンマップの表示
	dungeonmap.proc(dungeonrooms.get_rooms())
	# マップピンの表示
	mappin.dsp_pin(dungeonrooms.get_current_room_pos())


func _on_check_action_possibility(pos):
# プレイヤーノードから発行されたシグナルを受ける
# プレイヤーが移動しようとしたときに発行される
# 移動可能ならプレイヤーノードへシグナルを発行しプレイヤーを移動させる

	var tmppos : Vector2

	# 座標が有効か確認
	if pos.x < 0 or pos.x >= Gamesettings.ROOM_WIDTH \
		or pos.y < 0 or pos.y >= Gamesettings.ROOM_HEIGHT:
		return

	# 移動先の確認
	var next_tile = dungeonrooms.get_object_from_room(pos)
	if next_tile == Gamesettings.RoomObj.NON:
		# 何もなければ移動する
		# プレイヤーノードにシグナルを発行、移動先に移動
		emit_signal("player_move", pos)
	elif next_tile >= Gamesettings.RoomObj.EXITL and next_tile <= Gamesettings.RoomObj.EXITD:
		# 出口だったら部屋を移動する
		dungeonrooms.change_room(next_tile - 2)
		# プレイヤーノードにシグナルを発行、隣の部屋での座標に移動させる
		if next_tile - 2 == Gamesettings.Direction.LEFT:
			tmppos = Vector2(9, 4)
		elif next_tile - 2 == Gamesettings.Direction.UP:
			tmppos = Vector2(5, 7)
		elif next_tile - 2 == Gamesettings.Direction.RIGHT:
			tmppos = Vector2(1, 4)
		elif next_tile - 2 == Gamesettings.Direction.DOWN:
			tmppos = Vector2(5, 1)

		emit_signal("player_move", tmppos)





