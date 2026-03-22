extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card/opponent_card.tscn"
const COMMANDER_SCENE_PATH = "res://Scenes/commander.tscn"
const STARTING_HAND_SIZE = 4
const CARD_DRAW_SPEED = 0.25

var cardManagerReference
var commander = "Hakari Kinji"
var deck = ["Restless Gambler", "Mila Muzari", "Barnie Steel", "Building Looker", "Restless Gambler", "Mila Muzari", "Barnie Steel", "Building Looker", "Restless Gambler", "Mila Muzari", "Barnie Steel", "Building Looker"]
var cardDatabaseReference = preload("res://Scripts/Game/card_database.gd")
var cardDrawnName = null

func _ready() -> void:
	cardManagerReference = $"../CardManager"
	deck.shuffle()
	$RichTextLabel.text = str(deck.size())
	loadCommanderArt()
	for i in range(STARTING_HAND_SIZE):
		drawCard()

func drawCard():
	var cardScene = preload(CARD_SCENE_PATH)
	var newCard
	cardDrawnName = deck[0]
	
	deck.erase(cardDrawnName)
	if deck.size() == 0:
		$Sprite2D.visible = false
		#$RichTextLabel.visible = false #Disables the deck count when it reaches 0
	$RichTextLabel.text = str(deck.size())
	cardScene = preload(CARD_SCENE_PATH)
	newCard = cardScene.instantiate()
	newCard.name = cardDrawnName
	#newCard.get_node("CardImage").texture = cardManagerReference.loadCardArt(cardDrawnName)
	var cardImagePath = str("res://Assets/CardImages/" + cardDrawnName + ".png")
	newCard.attack = cardDatabaseReference.CHARACTER_CARDS[cardDrawnName][cardDatabaseReference.CARD_STATS.ATTACK]
	newCard.deffense = cardDatabaseReference.CHARACTER_CARDS[cardDrawnName][cardDatabaseReference.CARD_STATS.DEFFENSE]
	newCard.cardType = cardDatabaseReference.CHARACTER_CARDS[cardDrawnName][cardDatabaseReference.CARD_STATS.TYPE]
	newCard.get_node("CardImage").texture = load(cardImagePath)
	newCard.get_node("Attack").text = str(cardDatabaseReference.CHARACTER_CARDS[cardDrawnName][cardDatabaseReference.CARD_STATS.ATTACK])
	newCard.get_node("Deffense").text = str(cardDatabaseReference.CHARACTER_CARDS[cardDrawnName][cardDatabaseReference.CARD_STATS.DEFFENSE])
	$"../CardManager".add_child(newCard)
	$"../OpponentHand".addCardToHand(newCard, CARD_DRAW_SPEED)
	#newCard.get_node("AnimationPlayer").play("card_flip")

func loadCommanderArt() -> void:
	var commanderScene = preload(COMMANDER_SCENE_PATH)

	#$CommanderImage.texture = load(str("res://Assets/CommanderImages/" + playerCommander + ".png"))
