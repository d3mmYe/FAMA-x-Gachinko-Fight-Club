extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card/card.tscn"
const COMMANDER_SCENE_PATH = "res://Scenes/commander.tscn"
const STARTING_HAND_SIZE = 4

var cardManagerReference
var playerCommander = "DeusExGambler"
var playerDeck = ["Unit5KIND", "Unit5KIND", "Unit5KIND", "LuckyStraight", "LuckyStraight", "LuckyStraight", "LuckyStraight"]
var cardDatabaseReference = preload("res://Scripts/Game/card_database.gd")
var cardDrawnName = null

func _ready() -> void:
	cardManagerReference = $"../CardManager"
	playerDeck.shuffle()
	$RichTextLabel.text = str(playerDeck.size())
	loadCommanderArt()
	for i in range(STARTING_HAND_SIZE):
		drawCard()

func drawCard():
	var cardScene = preload(CARD_SCENE_PATH)
	var newCard
	cardDrawnName = playerDeck[0]
	
	playerDeck.erase(cardDrawnName)
	if playerDeck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		#$RichTextLabel.visible = false
	$RichTextLabel.text = str(playerDeck.size())
	newCard = cardScene.instantiate()
	newCard.get_node("CardImage").texture = cardManagerReference.loadCardArt(cardDrawnName)
	newCard.health = cardDatabaseReference.CARDS[cardDrawnName][3]
	newCard.attack = cardDatabaseReference.CARDS[cardDrawnName][1]
	$"../CardManager".add_child(newCard)
	newCard.name = cardDrawnName
	newCard.cardName = cardDrawnName
	$"../Hand".addCardToHand(newCard)

func loadCommanderArt():
	var commanderScene = preload(COMMANDER_SCENE_PATH)

	#$CommanderImage.texture = load(str("res://Assets/CommanderImages/" + playerCommander + ".png"))
