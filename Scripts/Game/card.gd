extends Node2D

signal hovered
signal hovered_off

var handPosition
var cardName = ""
var health
var attack
var cardSlotCardIsIn

func _ready() -> void:
	get_parent().connectCardSignals(self)

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
