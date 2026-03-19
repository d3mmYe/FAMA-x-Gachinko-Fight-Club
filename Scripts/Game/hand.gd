extends Node2D

const CARD_WIDTH = 120
const HAND_Y_POSITION = 900

var playerHand = []
var centerScreenX

func _ready() -> void:	
	centerScreenX = get_viewport().size.x / 2

func addCardToHand(card):
	if card not in playerHand:
		playerHand.insert(0, card)
		updateHandPositions()
	else:
		animateCardToPosition(card, card.handPosition)

func updateHandPositions():
	for i in range(playerHand.size()):
		var newPosition = Vector2(calculateCardPosition(i), HAND_Y_POSITION)
		var card = playerHand[i]
		card.handPosition = newPosition
		animateCardToPosition(card, newPosition)

func calculateCardPosition(i):
	var total_width = (playerHand.size() - 1) * CARD_WIDTH
	var xOffset = centerScreenX - i * CARD_WIDTH + total_width /2
	return xOffset

func animateCardToPosition(card, newPosition):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newPosition, 0.1)

func removeCardFromHand(card):
	if card in playerHand:
		playerHand.erase(card)
		updateHandPositions()
