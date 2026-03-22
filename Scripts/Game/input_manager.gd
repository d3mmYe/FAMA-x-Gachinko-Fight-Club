extends Node2D

signal leftMouseButtonClicked
signal leftMouseButtonReleased

const COLISSION_MASK_CARD = 1
const COLISSION_MASK_DECK = 4
const COLLISION_MASK_OPPONENT_CARD = 8

var cardManagerReference
var deckReference

func _ready() -> void:
	cardManagerReference = $"../CardManager"
	deckReference = $"../Deck"

func _input(event) :
	#var card
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("leftMouseButtonClicked")
			raycastAtCursor()
		else:
			emit_signal("leftMouseButtonReleased")

func raycastAtCursor():
	var spaceState = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	var result
	var resultColisionMask
	var cardFound
	
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	result = spaceState.intersect_point(parameters)
	if result.size() > 0:
		resultColisionMask = result[0].collider.collision_mask
		if resultColisionMask == COLISSION_MASK_CARD:
			# Card clicked
			cardFound = result[0].collider.get_parent()
			if cardFound:
				cardManagerReference.cardClicked(cardFound)
		elif resultColisionMask == COLISSION_MASK_DECK:
			# Deck clicked
			deckReference.drawCard()
		elif resultColisionMask == COLLISION_MASK_OPPONENT_CARD:
			$"../BattleManager".opponentCardSelected(result[0].collider.get_parent())
