extends Node2D

const COLISSION_MASK_CARD = 1
const COLISSION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1

var cardBeingDragged
var screnSize
var isHoveringOnCard: bool
var playerHandReference
var deck
var selectedCard
var cardDatabaseReference

func _ready() -> void:
	screnSize = get_viewport_rect().size
	playerHandReference = $"../Hand"
	$"../InputManager".connect("leftMouseButtonReleased", onLeftClickButtonReleased)
	cardDatabaseReference = preload("res://Scripts/Game/card_database.gd")

func _process(delta: float) -> void:
	var mousePossition
	
	if cardBeingDragged:
		mousePossition = get_global_mouse_position()
		cardBeingDragged.position = Vector2(
			clamp(mousePossition.x, 0, screnSize.x), clamp(mousePossition.y, 0, screnSize.y)
		)

func cardClicked(card):
	if card.cardSlotCardIsIn:
		if $"../BattleManager".opponentCardsOnField.size() == 0:
			$"../BattleManager".directAttack(card, "Player")
			return
		else:
			selectCardForBattle(card)
	else:
		startDrag(card)

func selectCardForBattle(card):
	if selectedCard:
		if selectedCard == card:
			card.position += 20
			selectedCard = null
		else:
			selectedCard.position += 20
			selectedCard = card
			card.position -= 20
	else:
		selectedCard = card
		card.position -= 20

func startDrag(card):
	card.scale = Vector2(1, 1)
	cardBeingDragged = card

func finishDrag():
	var cardSlotFound = raycastCheckForCardSlot()
	cardBeingDragged.scale = Vector2(1.05, 1.05)
	if cardSlotFound and not cardSlotFound.cardInSlot and (cardBeingDragged.cardType == cardDatabaseReference.CARD_TYPE.PROFESSIONAL_HERO or cardBeingDragged.cardType == cardDatabaseReference.CARD_TYPE.APPRENTICE_HERO or cardBeingDragged.cardType == cardDatabaseReference.CARD_TYPE.VILLAIN):
		# Card dropped in card slot
		cardBeingDragged.z_index = -1
		isHoveringOnCard = false
		cardBeingDragged.cardSlotCardIsIn = cardSlotFound
		playerHandReference.removeCardFromHand(cardBeingDragged)
		cardBeingDragged.position = cardSlotFound.position
		cardBeingDragged.get_node("Area2D/CollisionShape2D").disabled = true
		cardSlotFound.cardInSlot = true
		$"../BattleManager".playerCardsOnField.append(cardBeingDragged)
	else:
		playerHandReference.addCardToHand(cardBeingDragged, DEFAULT_CARD_MOVE_SPEED)
	cardBeingDragged = null

func connectCardSignals(card):
	card.connect("hovered", hoveredOverCard)
	card.connect("hovered_off", hoveredOffCard)

func onLeftClickButtonReleased():
	if cardBeingDragged:
		finishDrag()

func hoveredOverCard(card):
	if card.cardSlotCardIsIn:
		return
	if !isHoveringOnCard:
		isHoveringOnCard = true
		highlightCard(card, true)

func hoveredOffCard(card):
	var newCardHovered
	if !card.cardSlotCardIsIn && !cardBeingDragged:
		highlightCard(card, false)
		newCardHovered = raycastCheckForCard()
		if newCardHovered:
			highlightCard(newCardHovered, true)
		else:
			isHoveringOnCard = false

func highlightCard(card, hovered):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
		$"../HoldedCardInfo/Sprite2D".texture = loadCardArt(card.cardName)
		
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1
		$"../HoldedCardInfo/Sprite2D".texture = null

func loadCardArt(cardName):
	return load(str("res://Assets/CardImages/" + cardName + ".png"))

func raycastCheckForCard():
	var spaceState = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	var result
	
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLISSION_MASK_CARD
	result = spaceState.intersect_point(parameters)
	if result.size() > 0:
		return getCardWithHighestZindex(result)
	return null

func raycastCheckForCardSlot():
	var spaceState = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	var result
	
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLISSION_MASK_CARD_SLOT
	result = spaceState.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func getCardWithHighestZindex(cards):
	var highestZcard = cards[0].collider.get_parent()
	var highestZindex = highestZcard.z_index
	var currentCard
	
	for i in range (1, cards.size()):
		currentCard = cards[i].collider.get_parent()
		if currentCard.z_index > highestZindex:
			highestZcard = currentCard
			highestZindex = currentCard.z_index
	return highestZcard
