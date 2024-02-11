# GameSettings.gd
# 共通コード
# ゲーム内の共通的な定数などを設定
extends Node

const TILE_SIZE = 16			# タイルサイズ

const DUNGEON_WIDTH = 4			# 階層の広さ（幅）
const DUNGEON_HEIGHT = 4		# 階層の広さ（高さ）
const NUMBER_OF_ROOMS = 13		# 階層の部屋数
const DIG_ROOMS_NUM = 4			# 連続して生成する部屋数

# 部屋の中の広さ（壁込み）
const ROOM_WIDTH = 11
const ROOM_HEIGHT = 9

# プレイヤーの初期位置
const PLAYER_START_POS = Vector2(5, 4)

# ゲームの状態を表す列挙型
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}
enum RoomType{		# 部屋の種類
	Start,			# スタート地点
	Goal,			# ゴール地点
	Others			# その他
}
enum RoomObj{
	NON,			# 無し
	WALL,			# 壁
	EXITL,			# 出口（左側）
	EXITU,			# 出口（上側）
	EXITR,			# 出口（右側）
	EXITD			# 出口（下側）
}
enum Direction {	# 向き
	LEFT,
	UP,
	RIGHT,
	DOWN
}
