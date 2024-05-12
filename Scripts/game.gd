extends Node

export var enemyScene: PackedScene
export var arrowScene: PackedScene
export var crossScene: PackedScene

export var cellCount = Vector2(6, 6)
export var firstCellPosition = Vector2(95, 95)
export var cellDistance = 65

var cellPositions = [[]]
var arrow_directions = ""
var moves = []
var enemyNode: Node
var enemyCell: Vector2
var clickCell = Vector2(-1, -1)
var inGame = false
var score = 0
const arrowCountByScore = [2, 2, 3, 3, 3, 4, 4, 5, 6, 7, 7, 8, 8, 8, 9, 9, 9]


func start_arrows():
	init_enemy(false)
	for i in range(arrowCountByScore[score] if score <= 16 else 10):
		var random_move = enemyNode.random_move(cellCount)
		enemyNode.cell += random_move
		moves.append(random_move)
		match random_move:
			Vector2.RIGHT:
				arrow_directions += "➡️"
			Vector2.LEFT:
				arrow_directions += "⬅️"
			Vector2.UP:
				arrow_directions += "⬆️"
			Vector2.DOWN:
				arrow_directions += "⬇️"
			Vector2(-1, -1):
				arrow_directions += "↖️️"
			Vector2(1, 1):
				arrow_directions += "↘️️"
			Vector2(1, -1):
				arrow_directions += "↗️️"
			Vector2(-1, 1):
				arrow_directions += "↙️️"
	var arrows = arrowScene.instance()
	arrows.set_text(arrow_directions)
	arrows.get_node("Timer").connect("timeout", self, "_on_timer_animation_finished")
	add_child(arrows)
	
		

func start_game():
	for i in range(cellCount.x):
		for j in range(cellCount.y):
			var cellPosition = Vector2(
				firstCellPosition.x + i * cellDistance, 
				firstCellPosition.y + j * cellDistance
			)
			cellPositions[-1].append(cellPosition)
		cellPositions.append([])
		
func init_enemy(add_if, init_cell = null):
	var enemy = enemyScene.instance()
	
	enemy.initialize(cellCount)
	if (init_cell != null):
		enemy.cell = init_cell
	enemy.position = cellPositions[enemy.cell.x][enemy.cell.y]
	
	enemyNode = enemy
	if add_if:
		add_child(enemy)
	else:
		enemyCell = enemy.cell
	


func _on_StartButton_pressed():
	$UI/StartScreen.hide()
	if $UI/StartScreen/PlaySound.pressed:
		$StartSound.play()
	start_game()
	start_arrows()
	
func _on_timer_animation_finished():
	$Map.show()
	init_enemy(true, enemyCell)
	$Line.add_point(enemyNode.position)
	get_node("Control").queue_free()
	$UI/GameUI.show()
	$UI/GameUI/SkipButton.show()
	$TimerAnimation.play("timer")
	inGame = true
	

func _on_TimerAnimation_animation_finished(anim_name):
	inGame = false
	$UI/GameUI/SkipButton.hide()
	for move in moves:
		$Line.add_point(enemyNode.position)
		for i in range(int(cellDistance / 7)):
			enemyNode.position += move * 7
			$Line.points[-1] = enemyNode.position
			if $UI/StartScreen/PlaySound.pressed and not $MoveSound.playing:
				$MoveSound.play()
			yield(get_tree().create_timer(0.03), "timeout")
		yield(get_tree().create_timer(0.20), "timeout")
		
	var enemy_cell = enemyNode.position / 65
	enemy_cell = Vector2(int(enemy_cell.x)-1, int(enemy_cell.y)-1)
	if clickCell != Vector2(-1, -1) and enemy_cell == clickCell:
		$UI/GameUI/NextButton.show()
	else:
		JavaScript.eval("fetch('https://games-bot-skfs.onrender.com/submitpayload?payload=' + window.location.search.substring(6) + '&score=%s');" % score)
		get_tree().reload_current_scene()
		
	
		
	
func _on_SkipButton_pressed():
	$TimerAnimation.stop()
	$TimerAnimation.emit_signal("animation_finished", "timer")
	$UI/GameUI/SkipButton.hide()
	
func _on_NextButton_pressed():
	score += 1
	set_score(score)
	$Map.hide()
	$UI/GameUI.hide()
	enemyNode.queue_free()
	for cross in $Crosses.get_children():
		cross.queue_free()
	clickCell = Vector2(-1, -1)
	arrow_directions = ""
	moves = []
	_on_StartButton_pressed()
	
	$Line.points = []
	$UI/GameUI/NextButton.hide()
	
func _input(event):
	if event.is_action_pressed("left_click") and inGame:
		var mouse_cell = $Node2D.get_global_mouse_position() / 65
		if mouse_cell.x >= 1 and \
		mouse_cell.y >= 1 and \
		mouse_cell.x <= 7 and \
		mouse_cell.y <= 7:
			clickCell = Vector2(int(mouse_cell.x)-1, int(mouse_cell.y)-1)
			for cross in $Crosses.get_children():
				cross.queue_free()
			var cross = crossScene.instance()
			cross.position = cellPositions[clickCell.x][clickCell.y]
			cross.z_index = 1
			$Crosses.add_child(cross)
		
func set_score(score):
	$UI/GameUI/ScoreUI.text = "Score: %s" % score


func _on_TextureButton_pressed():
	JavaScript.eval("TelegramGameProxy.shareScore();")


func _on_InfoLink_pressed():
	OS.shell_open("https://t.me/MS27Games/2")
