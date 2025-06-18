extends CardBase
class_name CardInSeedChooser

@onready var card: Card = $Card

func card_init(card_type: Global.PlantType):
	super.card_init(card_type)
	card.card_init(card_type)
