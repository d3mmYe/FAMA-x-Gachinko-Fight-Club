extends Node2D

const CARD_WIDTH = 120
const HAND_Y_POSITION = 900
const DEFAULT_CARD_MOVE_SPEED = 0.1

var hand = []
var centerScreenX

func _ready() -> void:
	centerScreenX = get_viewport().size.x / 2


func addCardToHand(card, speed):
	if card not in hand:
		hand.insert(0, card)
		updateHandPositions(speed)
	else:
		animateCardToPosition(card, card.handPosition, DEFAULT_CARD_MOVE_SPEED)

func updateHandPositions(speed):
	var newPosition
	var card
	
	for i in range(hand.size()):
		newPosition = Vector2(calculateCardPosition(i), HAND_Y_POSITION)
		card = hand[i]
		card.handPosition = newPosition
		animateCardToPosition(card, newPosition, speed)

func calculateCardPosition(index):
	var xOffset = (hand.size() - 1) * CARD_WIDTH
	var xPosition = centerScreenX - index * CARD_WIDTH + xOffset /2
	return xPosition

func animateCardToPosition(card, newPosition, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newPosition, speed)

func removeCardFromHand(card):
	if card in hand:
		hand.erase(card)
		updateHandPositions(DEFAULT_CARD_MOVE_SPEED)
