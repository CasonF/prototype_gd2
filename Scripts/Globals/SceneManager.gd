extends Node

var game_over_screen: PackedScene = preload("res://Scenes/player_death_screen.tscn")

func _ready() -> void:
	SignalBus.game_over.connect(handle_game_over)
	SignalBus.quit_game.connect(handle_quit_game)

func handle_game_over(player_death_pos: Vector2) -> void:
	var game_over := game_over_screen.instantiate()
	get_tree().root.add_child(game_over)

func handle_quit_game() -> void:
	# Save game stats, etc.
	get_tree().quit() # Actually quit the game
