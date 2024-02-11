extends Node2D

@onready var player = $Player
@onready var dungeon = $Dungeon

signal check_action_possibility(pos:Vector2)		# プレイヤーのとるべき行動を確認する

var _current_state		# 現在のゲームの状態

# Called when the node enters the scene tree for the first time.
func _ready():

	# イベントの接続
	# プレイヤーのアクションを確認
	self.connect("check_action_possibility", Callable(dungeon, "_on_check_action_possibility"))
	# プレイヤーを移動させるとき
	dungeon.connect("player_move", Callable(player, "_on_player_move"))

	# ゲームの状態の設定。（とりあえずプレイ状態）
	_current_state = Gamesettings.GameState.PLAYING



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	# 入力の受付
	_handle_input()

	# ダンジョンの表示
	dungeon.proc()

	# プレイヤー移動処理
	player.proc()



func _handle_input():
# イベントなどを受け取り、各種操作を行う

	# ゲームの状態毎の入力受付
	if _current_state == Gamesettings.GameState.PLAYING:
		# ゲームプレイ中
		# 方向キー：プレイヤーの移動または、アクションを行う
		var playerpos = player.get_player_grid_pos()		# プレイヤーの座標を取得
		if Input.is_action_just_pressed("ui_left"):
			playerpos = playerpos + Vector2(-1, 0)
			emit_signal("check_action_possibility", playerpos)
		elif Input.is_action_just_pressed("ui_up"):
			playerpos = playerpos + Vector2(0, -1)
			emit_signal("check_action_possibility", playerpos)
		elif Input.is_action_just_pressed("ui_right"):
			playerpos = playerpos + Vector2(1, 0)
			emit_signal("check_action_possibility", playerpos)
		elif Input.is_action_just_pressed("ui_down"):
			playerpos = playerpos + Vector2(0, 1)
			emit_signal("check_action_possibility", playerpos)

