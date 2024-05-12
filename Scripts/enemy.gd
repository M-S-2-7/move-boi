extends AnimatedSprite

var cell: Vector2

func initialize(cellCount: Vector2):
	randomize()
	cell = Vector2(randi() % int(cellCount.x), randi() % int(cellCount.y))
	
func random_move(cellCount: Vector2):
	var moves = [
		Vector2.RIGHT, 
		Vector2.LEFT, 
		Vector2.UP, 
		Vector2.DOWN,
		Vector2(-1, -1), # ↖️
		Vector2(1, 1), # ↘️
		Vector2(1, -1), # ↗️
		Vector2(-1, 1) # ↙️
	]
	
	if cell.x == 0:
		moves.erase(Vector2.LEFT)
		moves.erase(Vector2(-1, -1))
		moves.erase(Vector2(-1, 1))
	if cell.y == 0:
		moves.erase(Vector2.UP)
		moves.erase(Vector2(-1, -1))
		moves.erase(Vector2(1, -1))
	if cell.x == cellCount.x - 1:
		moves.erase(Vector2.RIGHT)
		moves.erase(Vector2(1, -1))
		moves.erase(Vector2(1, 1))
	if cell.y == cellCount.y - 1:
		moves.erase(Vector2.DOWN)
		moves.erase(Vector2(1, 1))
		moves.erase(Vector2(-1, 1))
	
	# print(moves)
	# print('---------------')
	randomize()
	return moves[randi() % moves.size()]
	
	
