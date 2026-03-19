extends Node

const CARD_MOVE_SPEED = 0.1
const STARTING_HEALTH = 10

var battleTimer
var emptyOpponentCardSlots = []
var playerCardsOnField = []
var opponentCardsOnField = []
var opponentCardsOnField2 = []
var playerHealth
var opponentHealth

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
	opponentTurn()

func opponentTurn():
	var deffendingCard
	
	$"../EndTurnButton".disabled = true
	$"../BattleButton".disabled = true
	$"../EndTurnButton".visible = false
	$"../BattleButton".visible = false
	
	if $"../OpponentDeck".deck.size() != 0:
		$"../OpponentDeck".drawCard()
		battleTimer.start()
		await battleTimer.timeout
	
	if emptyOpponentCardSlots.size() != 0:
		tryPlayCard()
	
	if opponentCardsOnField.size() != 0:
		opponentCardsOnField2 = opponentCardsOnField.duplicate()
		for card in opponentCardsOnField2:
			if playerCardsOnField.size() != 0:
				deffendingCard = playerCardsOnField.pick_random()
				attack(card, deffendingCard, "Opponent")
			else:
				directAttack(card, "Opponent")
	
	endOpponentTurn()

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
		if card.attack > cardWithHighestAtk.attack:
			cardWithHighestAtk = card
	
	tween.tween_property(cardWithHighestAtk, "position", randomEmptyOpponentCardSlot.position, CARD_MOVE_SPEED)
	
	$"../OpponentHand".removeCardFromHand(cardWithHighestAtk)
	cardWithHighestAtk.cardSlotCardIsIn = randomEmptyOpponentCardSlot
	opponentCardsOnField.append(cardWithHighestAtk)

func attack(attackingCard, deffendingCard, attacker):
	deffendingCard.health = deffendingCard.health - attackingCard.attack
	#deffendingCard.get_node("Health").txt = str(deffendingCard.health)
	attackingCard.health = attackingCard.health - deffendingCard.attack
	#attackingCard.get_node("Health").txt = str(attackingCard.health)
	
	if attackingCard.health <= 0:
		destroyCard(attackingCard, attacker)
	if deffendingCard.health <= 0:
		if attacker == "Player":
			destroyCard(deffendingCard, "Opponent")
		else:
			destroyCard(deffendingCard, "Player")

func directAttack(attackingCard, attacker):
	if attacker == "Opponent":
		playerHealth = playerHealth - attackingCard.attack
		$"../PlayerHealth".text = str(playerHealth)
	else:
		opponentHealth = opponentHealth - attackingCard.attack
		$"../OpponentHealth".text = str(opponentHealth)

func destroyCard(card, cardOwner):
	var newPosition
	var tween = get_tree().create_tween()
	
	if cardOwner == "Player":
		newPosition = $"../Graveyard".position
		if card in playerCardsOnField:
			playerCardsOnField.erase(card)
	else:
		newPosition = $"../OpponentGraveyard".position
	
	card.cardSlotCardIsIn.cardInSlot = false
	card.cardSlotCardIsIn = null
	tween.tween_property(card, "position", newPosition, CARD_MOVE_SPEED)


func endOpponentTurn():
	$"../EndTurnButton".disabled = false
	$"../BattleButton".disabled = false
	$"../EndTurnButton".visible = true
	$"../BattleButton".visible = true
	$"../Deck".drawCard()
