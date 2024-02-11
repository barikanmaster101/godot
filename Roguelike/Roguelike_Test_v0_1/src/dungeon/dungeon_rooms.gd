extends Node2D
# ダンジョンの自動生成（1階層）と管理を行う
# 暫定ルール
# 階層の自動生成：ランダムに部屋を生成する
#              部屋は全部つながっている。
# オブジェクトの生成：各部屋にオブジェクトを配置する
#                  モンスター、宝箱、罠、障害物などをランダムに配置する
# 生成した階層の管理をする：主にオブジェクトの配置位置とプレイヤーの位置を管理する予定
const DIRLIST = [
	Vector2(-1, 0),		# 左
	Vector2(0, -1),		# 上
	Vector2(1, 0),		# 右
	Vector2(0, 1)		# 下
	]
const TILELIST = {
	"NON" : Vector2(0, 0),
	"WALL" : Vector2(1, 0),
	"STAIRS" : Vector2(2, 0)
}

var _rooms = []						# 階層の部屋情報をまとめて所持
var _width = 0						# 階層のマスの数（横） 
var _height = 0						# 階層のマスの数（縦）
var _roomnum  = 0					# 階層に部屋を何個作るか
var _current_room_pos = Vector2(0, 0)	# プレイヤーの現在地（画面に表示されている部屋の座標）

@onready var tilemap = $TileMap

# Called when the node enters the scene tree for the first time.
func _ready():

	# 初期処理
	_width = Gamesettings.DUNGEON_WIDTH
	_height = Gamesettings.DUNGEON_HEIGHT
	_roomnum = Gamesettings.NUMBER_OF_ROOMS



func proc() -> void:

	# 現在の部屋を表示する
	_disp_current_room()



func create_rooms():
# 部屋を生成する。一応穴掘り法？で掘っていく

#	var pos : Vector2
	var currentroom = []
	var nextroom = []

	# 最初の部屋を取得
	currentroom = _create_startroom()

	# 隣接するマスに部屋を作成する
	var tmproomnum = 0		# 部屋生成カウンタ
	if _rooms.size() == 1:
		tmproomnum = 1		# さきに始点の部屋作ってたら１から始める

	while _rooms.size() < _roomnum:

		# 次の部屋を取得する
		nextroom = _create_next_room(currentroom)

		if nextroom.size() < 1:
			# 次の部屋が作成できなかったら
			# スタート地点を変えて掘りなおす
			tmproomnum = 999
		else:
			# 次の部屋が出来たら
			# 部屋と部屋をつなぐ設定をする
			_connect_rooms(currentroom, nextroom)
			
			# その部屋から次を掘る
			currentroom = nextroom
			tmproomnum += 1

		# 連続で一定数部屋を生成したら
		# 既にある部屋からランダムに選んで、そこからまた部屋を生成する
		if tmproomnum >= _roomnum:
			# ランダムに生成された部屋を取得する
			currentroom = _rooms[randi()%_rooms.size()]

	# 部屋の生成が終了したら、スタート地点とゴール地点を設定
	# スタートは最初に作成した部屋に設定
	_rooms[0].type = Gamesettings.RoomType.Start
	# 現在地をスタート地点に設定
	_current_room_pos = _rooms[0].pos
	# スタート地点の来たことあるフラグを立てる
	_rooms[0].visited = true
	# ゴールはスタート以外の部屋にランダムに設定
	_rooms[randi()%(_rooms.size()-1)+1].type = Gamesettings.RoomType.Goal
	# 部屋内のオブジェクトを生成する
	for room in _rooms:
		room.objects = _set_obj_room(room)


func _create_startroom():
# 掘り始めるマスを決める
# 部屋が一つもない場合は、ランダムに部屋を作成し返す
# 既に部屋がある場合は、既存の部屋からランダムに選択し返す

	var index = 0
	# 部屋が1つも存在しなかったら、ランダムにマスを選択する
	if _rooms.size() < 1:
		_add_room(Vector2(randi()%_width, randi()%_height), Gamesettings.RoomType.Others)
		return _rooms[0]
	else:
		index = randi()%_rooms.size()
		return _rooms[index]

func _create_next_room(room):
# 指定された部屋から次の部屋を生成
# 移動できる部屋が複数あれば、ランダムで1つのマスを選び部屋を生成する
# 生成した部屋を返す
# 移動先が無い場合は空を返す

	var nextpos : Vector2
	var tmptiles = []		# 作成可能な部屋を格納する（全部）
	for i in range(4):
		nextpos = room.pos + DIRLIST[i]
		if is_tile_open(nextpos):
			# マスが空いていたら記録する
			tmptiles.append(nextpos)

	if tmptiles.size() == 0:
		# 空いているマスが無ければ空を返す
		return []
	else:
		# 空いていたら、その中からランダムで選択したマスに部屋を作り返す
		nextpos = tmptiles[randi()%tmptiles.size()]
		_add_room(nextpos, Gamesettings.RoomType.Others)
		# 最後に追加した部屋を返す
		return _rooms[_rooms.size() - 1]


func _add_room(pos:Vector2, type:Gamesettings.RoomType):
# 部屋情報を追加する

	var room = {
		"pos" : pos,				# 部屋の座標
		"exits" : [],				# 隣の部屋につながっている出口、２次元配列になっている
									# 出口がある方向（上下左右の壁）とつながっている部屋の座標を格納
									# 壁４つ分設定（出口がある壁の情報のみ登録される）
		"type" : type,				# いまのところはスタート、ゴール、その他のみ
		"visited" : false,			# この部屋に訪れたことがあるか？
		"objects" : []				# 部屋内のオブジェクトを設定
	}
	_rooms.append(room)


func _set_obj_room(room):
# 生成した部屋の中にオブジェクトを設置する
# 今のところは壁のみ
# ２次元配列を返す
	var room2d = []
	# 部屋と壁を作成
	for i in range(Gamesettings.ROOM_HEIGHT):
		var tmp = []
		for j in range(Gamesettings.ROOM_WIDTH):
			if i == 0 or i == Gamesettings.ROOM_HEIGHT - 1:
				tmp.append(Gamesettings.RoomObj.WALL)
			elif j == 0 or j == Gamesettings.ROOM_WIDTH - 1:
				tmp.append(Gamesettings.RoomObj.WALL)
			else:
				tmp.append(Gamesettings.RoomObj.NON)
		room2d.append(tmp)

	# 出口を作成する
	for exit in room.exits:
		if exit.direction == Gamesettings.Direction.LEFT:
			room2d[4][0] = exit.direction + 2
		elif exit.direction == Gamesettings.Direction.UP:
			room2d[0][5] = exit.direction + 2
		elif exit.direction == Gamesettings.Direction.RIGHT:
			room2d[4][10] = exit.direction + 2
		elif exit.direction == Gamesettings.Direction.DOWN:
			room2d[8][5] = exit.direction + 2

	return room2d

func _connect_rooms(room1, room2):
# 隣り合っている二つの部屋がつながっているという情報をそれぞれの部屋に設定する

	if room1.pos == room2.pos - DIRLIST[Gamesettings.Direction.LEFT]:
		# １が左側２が右側
		room1.exits.append({"direction" : Gamesettings.Direction.LEFT, "pos" : room2.pos})
		room2.exits.append({"direction" : Gamesettings.Direction.RIGHT, "pos" : room1.pos})
	elif room1.pos == room2.pos - DIRLIST[Gamesettings.Direction.UP]:
		# １が上側２が下側
		room1.exits.append({"direction" : Gamesettings.Direction.UP, "pos" : room2.pos})
		room2.exits.append({"direction" : Gamesettings.Direction.DOWN, "pos" : room1.pos})
	elif room1.pos == room2.pos - DIRLIST[Gamesettings.Direction.RIGHT]:
		# １が右側２が左側
		room1.exits.append({"direction" : Gamesettings.Direction.RIGHT, "pos" : room2.pos})
		room2.exits.append({"direction" : Gamesettings.Direction.LEFT, "pos" : room1.pos})
	elif room1.pos == room2.pos - DIRLIST[Gamesettings.Direction.DOWN]:
		# １が下側２が上側
		room1.exits.append({"direction" : Gamesettings.Direction.DOWN, "pos" : room2.pos})
		room2.exits.append({"direction" : Gamesettings.Direction.UP, "pos" : room1.pos})

func _disp_current_room():
# 現在部屋を表示する
# オブジェクトもいろいろ表示する予定だが、現在は出口しか出すものが無い

	# 現在の部屋情報を取得
	var room = get_room_from_pos(_current_room_pos)

	# objectレイヤーのオブジェクトを設置
	for y in range(len(room.objects)):
		for x in range(len(room.objects[y])):
			# 何もない。タイルを消す
			if room.objects[y][x] == Gamesettings.RoomObj.NON:
				tilemap.erase_cell(1, Vector2(x, y))
			# 壁
			elif room.objects[y][x] == Gamesettings.RoomObj.WALL:
				tilemap.set_cell(1, Vector2(x, y), 0, TILELIST.WALL)
			# 出口。タイルを消す
			elif room.objects[y][x] >= Gamesettings.RoomObj.EXITL\
				 and room.objects[y][x] <= Gamesettings.RoomObj.EXITD:
				tilemap.erase_cell(1, Vector2(x, y))



func get_room_from_pos(pos:Vector2):
# 指定された座標の部屋を返す
# 部屋が存在しない場合は空の配列を返す
	for room in _rooms:
		if room.pos == pos:
			return room
	# 一致する部屋が無かったら空で返す
	return []

func is_tile_open(pos:Vector2) -> bool:
# 指定した座標のマスに何もないか確認する
# 座標が有効化も確認する
	
	# 座標が有効か確認
	if 0 <= pos.x and pos.x < _width and 0 <= pos.y and pos.y < _height:
		# 座標に部屋が存在しないか確認
		if get_room_from_pos(pos).size() == 0:
			return true
	
	return false

func get_object_from_room(pos:Vector2):
# 部屋内のオブジェクトを返す

	var room = get_room_from_pos(_current_room_pos)
	return room.objects[pos.y][pos.x]

func change_room(direction):
# 方向を指定したら、現在の部屋の指定された方向の隣の部屋に移動（_current_room_posの更新）

	var pos = Vector2(-1, -1)
	var room = get_room_from_pos(_current_room_pos)
	for exit in room.exits:
		if exit.direction == direction:
			pos =  exit.pos

	_current_room_pos = pos
	# 移動先の部屋の来たことあるフラグを立てる
	room = get_room_from_pos(_current_room_pos)
	room.visited = true
	


func get_dungeon2d() -> Array:
# 一階層の部屋の配置を２次元配列で返す
# デバッグ用？

	var retdungeon = []

	# 0でクリアする
	for i in range(_height):
		var tmprow = []
		for j in range(_width):
			tmprow.append(0)
		retdungeon.append(tmprow)

	# 部屋があるところに1を入れる
	for room in _rooms:
		retdungeon[room.pos.y][room.pos.x] = 1

	return retdungeon

func get_rooms() -> Array:
# １階層の部屋情報を返す（２次元配列ではない）
	return _rooms

func get_current_room_pos() -> Vector2:
# プレイヤーがいる部屋（画面に表示する部屋）の座標を返す
	return _current_room_pos




