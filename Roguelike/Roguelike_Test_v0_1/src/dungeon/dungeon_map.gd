extends Node2D
## タイルレイヤー.
enum eTileLayer {
	BACKGROUND ,	# 背景レイヤー
	ROOMS,			# 部屋レイヤー
	EXIT,			# 出口用のタイル（複数出口があるときは重ねる）
	OBJECT = 6		# マップに表示するオブジェクト（今のところはスタートとゴールのみ）
}
const NONEXIT = Vector2(1, 0)
const DIRTILELIST = [
	Vector2(0, 1),		# 左向きタイル
	Vector2(1, 1),		# 上向きタイル
	Vector2(2, 1),		# 右向きタイル
	Vector2(3, 1),		# 下向きタイル
	Vector2(0, 2),		# スタート
	Vector2(1, 2)		# ゴール
]


@onready var tilemap = $TileMap

func proc(mapdata:Array) -> void:
# 1階層のマップを表示する

	for room in mapdata:
		# 来たことあるフラグが立っている部屋だけ表示する
		if room.visited:
			# 出口が無いタイル（無くてもいい）
			tilemap.set_cell(eTileLayer.ROOMS, room.pos, 0, NONEXIT)
			# 出口付きのタイルを貼る
			var exitnum = 0
			for exit in room.exits:
				tilemap.set_cell(eTileLayer.EXIT + exitnum, room.pos, 0, DIRTILELIST[exit.direction])
				exitnum += 1
			# スタート地点とゴール地点もマップに表示
			if room.type == Gamesettings.RoomType.Start:
				tilemap.set_cell(eTileLayer.OBJECT, room.pos, 0, DIRTILELIST[4])
			elif room.type == Gamesettings.RoomType.Goal:
				tilemap.set_cell(eTileLayer.OBJECT, room.pos, 0, DIRTILELIST[5])





