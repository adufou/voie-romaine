extends Control

class_name PopUpMessage

var _direction: Vector2
var _speed: float = 50.0

func _ready() -> void:
	_direction = Vector2(randf_range(-0.5, 0.5), randf_range(-1, -0.25)).normalized()

func _process(delta: float) -> void:
	position += _direction * _speed * delta

func init_message(message: String):
	%Message.text = message

func _on_timer_timeout() -> void:
	queue_free()
