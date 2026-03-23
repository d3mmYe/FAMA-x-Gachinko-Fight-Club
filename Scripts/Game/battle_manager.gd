extends Node

const CARD_MOVE_SPEED: float = 0.25
const STARTING_HEALTH: int = 10
const BATTLE_POSSITION_OFFSET: int = 25

var battleTimer
var emptyOpponentCardSlots = []
var playerCardsOnField = []
var opponentCardsOnField = []
var opponentAttackingCards = []
var playerCardsThatAttackedThisTurn = []
var playerHealth: int
var opponentHealth: int
var isOpponentsTurn = false
var playerIsAttacking = false

func _ready() -> void:
	battleTimer = $"../BattleTimer"
	battleTimer.one_shot = true
	battleTimer.wait_time = 1.0
	
	emptyOpponentCardSlots.append($"../CardSlots/OpponentCardSlots/OpponentFrontLeft")
	emptyOpponentCardSlots.append($"../CardSlots/OpponentCardSlots/OpponentFrontCenter")
	emptyOpponentCardSlots.append($"../CardSlots/OpponentCardSlots/OpponentFrontRight")
	emptyOpponentCardSlots.append($"../CardSlots/OpponentCardSlots/OpponentBackLeft")
	emptyOpponentCardSlots.append($"../CardSlots/OpponentCardSlots/OpponentBackCenter")
	emptyOpponentCardSlots.append($"../CardSlots/OpponentCardSlots/OpponentBackRight")
	
	playerHealth = STARTING_HEALTH
	$"../PlayerHealth".text = str(playerHealth)
	opponentHealth = STARTING_HEALTH
	$"../OpponentHealth".text = str(opponentHealth)

func _onEndTurnButtonPressed() -> void:
	isOpponentsTurn = true
	$"../CardManager".unselectSelectedCards()
	playerCardsThatAttackedThisTurn = []
	opponentTurn()

func opponentTurn():
	var deffendingCard
	
	$"../EndTurnButton".disabled = true
	$"../BattleButton".disabled = true
	$"../EndTurnButton".visible = false
	$"../BattleButton".visible = false
	
	if $"../OpponentDeck".deck.size() != 0:
		$"../OpponentDeck".drawCard()
		await wait(1)
	
	if emptyOpponentCardSlots.size() != 0:
		await tryPlayCard()
	
	if opponentCardsOnField.size() != 0:
		opponentAttackingCards = opponentCardsOnField.duplicate()
		for card in opponentAttackingCards:
			if playerCardsOnField.size() != 0:
				deffendingCard = playerCardsOnField.pick_random()
				await attack(card, deffendingCard, "Opponent")
			else:
				await directAttack(card, "Opponent")
	endOpponentTurn()

func opponentCardSelected(deffendingCard):
	var attackingCard = $"../CardManager".selectedCard
	if attackingCard and deffendingCard in opponentCardsOnField and not playerIsAttacking:
		$"../CardManager".selectedCard = null
		attack(attackingCard, deffendingCard, "Player")

func tryPlayCard():
	var opponentHand = $"../OpponentHand".hand
	var randomEmptyOpponentCardSlot = emptyOpponentCardSlots.pick_random()
	var cardWithHighestAtk = opponentHand[0]
	var tween = get_tree().create_tween()
	
	if opponentHand.size() == 0:
		endOpponentTurn()
		return
	
	emptyOpponentCardSlots.erase(randomEmptyOpponentCardSlot)
	
	for card in opponentHand:
		if card.attack:
			if card.attack > cardWithHighestAtk.attack:
				cardWithHighestAtk = card
	
	tween.tween_property(cardWithHighestAtk, "position", randomEmptyOpponentCardSlot.position, CARD_MOVE_SPEED)
	cardWithHighestAtk.get_node("AnimationPlayer").play("card_flip")

	$"../OpponentHand".removeCardFromHand(cardWithHighestAtk)
	cardWithHighestAtk.cardSlotCardIsIn = randomEmptyOpponentCardSlot
	opponentCardsOnField.append(cardWithHighestAtk)
	
	await wait(CARD_MOVE_SPEED)

func attack(attackingCard, deffendingCard, attacker):
	if attacker == "Player":
		playerIsAttacking = true
		$"../CardManager".selectedCard = null
		playerCardsThatAttackedThisTurn.append(attackingCard)
	var newPosition = Vector2(deffendingCard.position.x, deffendingCard.position.y + BATTLE_POSSITION_OFFSET) 
	attackingCard.z_index = 5
	var tween = get_tree().create_tween()
	tween.tween_property(attackingCard, "position", newPosition, CARD_MOVE_SPEED)
	await wait(CARD_MOVE_SPEED)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attackingCard, "position", attackingCard.cardSlotCardIsIn.position, CARD_MOVE_SPEED)
	deffendingCard.deffense = max(0, deffendingCard.deffense - attackingCard.attack)
	deffendingCard.get_node("Deffense").text = str(deffendingCard.deffense)
	attackingCard.deffense = max(0, attackingCard.deffense - deffendingCard.attack)
	attackingCard.get_node("Deffense").text = str(attackingCard.deffense)
	
	attackingCard.z_index = 0
	var cardWasDestroyed = false
	
	if attackingCard.deffense <= 0:
		destroyCard(attackingCard, attacker)
		cardWasDestroyed = true
	if deffendingCard.deffense <= 0:
		if attacker == "Player":
			destroyCard(deffendingCard, "Opponent")
		else:
			destroyCard(deffendingCard, "Player")
		cardWasDestroyed = true
	if cardWasDestroyed:
		await wait(1)
	playerIsAttacking = false

func directAttack(attackingCard, attacker):
	var newPosition
	var newPositionY
	var tween = get_tree().create_tween()
	
	if attacker == "Opponent":
		playerHealth = playerHealth - attackingCard.attack
		$"../PlayerHealth".text = str(playerHealth)
		newPositionY = 900
	else:
		playerIsAttacking = true
		opponentHealth = opponentHealth - attackingCard.attack
		$"../OpponentHealth".text = str(opponentHealth)
		newPositionY = 0
		playerCardsThatAttackedThisTurn.append(attackingCard)
	newPosition = Vector2(attackingCard.position.x, newPositionY)
	attackingCard.z_index = 5
	tween.tween_property(attackingCard, "position", newPosition, CARD_MOVE_SPEED)
	await wait(CARD_MOVE_SPEED)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attackingCard, "position", attackingCard.cardSlotCardIsIn.position, CARD_MOVE_SPEED)
	attackingCard.z_index = 0
	await wait(CARD_MOVE_SPEED)
	playerIsAttacking = false
	

func destroyCard(card, cardOwner):
	var newPosition
	var tween = get_tree().create_tween()
	
	if cardOwner == "Player":
		card.defeated = true
		card.get_node("Area2D/CollisionShape2D").disabled = true
		newPosition = $"../Graveyard".position
		if card in playerCardsOnField:
			playerCardsOnField.erase(card)
		card.cardSlotCardIsIn.get_node("Area2D/CollisionShape2D").disabled = false
	else:
		newPosition = $"../OpponentGraveyard".position
		if card in opponentCardsOnField:
			opponentCardsOnField.erase(card)
	
	card.cardSlotCardIsIn.cardInSlot = false
	card.cardSlotCardIsIn = null
	tween.tween_property(card, "position", newPosition, CARD_MOVE_SPEED)

func wait(wait_time):
	battleTimer.wait_time = wait_time
	battleTimer.start()
	await battleTimer.timeout

func endOpponentTurn():
	isOpponentsTurn = false
	$"../EndTurnButton".disabled = false
	$"../BattleButton".disabled = false
	$"../EndTurnButton".visible = true
	$"../BattleButton".visible = true
	$"../Deck".drawCard()
