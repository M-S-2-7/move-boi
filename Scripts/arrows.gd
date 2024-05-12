extends Control

var first_position

func set_text(arrows):
	$arrows.text = arrows
	$arrows.anchor_top = 0.5
	$arrows.anchor_bottom = 0.5
	$arrows.margin_left = -len(arrows) * 8
	$arrows.margin_right = len(arrows) * 8
	
func _ready():
	first_position = $arrows.rect_position
	
func _process(delta):
	if first_position.y + 25 > $arrows.rect_position.y:
		$arrows.rect_position.y += 30 * delta


func _on_Button_pressed():
	$Timer.emit_signal("timeout")

