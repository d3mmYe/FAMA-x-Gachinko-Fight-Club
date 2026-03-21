extends Node2D

signal hovered
signal hovered_off

var handPosition
var cardName = ""
var deffense
var attack
var cardType
var cardSlotCardIsIn

func _ready() -> void:
# All cards must be a child of card_manager
	get_parent().connectCardSignals(self)

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
