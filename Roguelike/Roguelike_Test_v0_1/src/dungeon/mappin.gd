extends Node2D


func dsp_pin(pos):
# マップにピンを表示する（座標を変えるだけ）
# 最後の＋はdungeon_mapの座標

	position.x = (pos.x * Gamesettings.TILE_SIZE) + 180
	position.y = (pos.y * Gamesettings.TILE_SIZE) + 0

