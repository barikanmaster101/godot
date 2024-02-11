extends Node2D

@onready var player = $Sprite2D

# プレイヤー配置時の調整分
const POS_ADD_WIDTH = 4
const POS_ADD_HEIGHT = 4

# プレイヤーの座標(グリッド)
var _player_grid_pos = Vector2(0, 0)

func _ready():
# 初期処理
	_player_grid_pos = Gamesettings.PLAYER_START_POS


func proc() -> void:

	# プレイヤーの表示
	_dsp_player()


func _dsp_player():
# プレイヤーの表示処理（座標を変えるだけ）
# 最後の+5はMainノード上のDungeonノードの座標
	position.x = _player_grid_pos.x * Gamesettings.TILE_SIZE + POS_ADD_WIDTH
	position.y = _player_grid_pos.y * Gamesettings.TILE_SIZE + POS_ADD_HEIGHT


func _on_player_move(pos:Vector2):
	# 移動先の座標を設定する
	_player_grid_pos = pos

func get_player_grid_pos() -> Vector2:
# プレイヤーの座標を返す
	return _player_grid_pos

