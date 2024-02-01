class_name PlayerDeathScreen
extends CanvasLayer

@export var btn_restart: Button
@export var btn_camp: Button
@export var btn_menu: Button
@export var btn_quit: Button

@onready var animator: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	connect_signals()
	play_animations()

func connect_signals() -> void:
	btn_restart.pressed.connect(restart)
	btn_camp.pressed.connect(camp)
	btn_menu.pressed.connect(menu)
	btn_quit.pressed.connect(quit)

func play_animations() -> void:
	# Basic to start... AnimationPlayer only has fade-in to start...
	animator.play("fade_in")

func restart() -> void:
	print("Pressed Restart")

func camp() -> void:
	print("Pressed Camp")

func menu() -> void:
	print("Pressed Menu")

func quit() -> void:
	print("Closing game...")
	SignalBus.quit_game.emit()
