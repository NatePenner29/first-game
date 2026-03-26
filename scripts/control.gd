extends Control

@export var player_coins = 100

# Liste der Items im Shop
var items = [
	{"name": "Schwert", "price": 50},
	{"name": "Schild", "price": 30},
	{"name": "Potion", "price": 20}
]

@onready var label_coins = $LabelCoins
@onready var vbox = $Panel/VBoxContainer

func _ready():
	update_coins()
	create_shop_items()

func update_coins():
	label_coins.text = "Coins: %d" % player_coins

func create_shop_items():
	for item in items:
		var hbox = HBoxContainer.new()
		
		var name_label = Label.new()
		name_label.text = item.name
		hbox.add_child(name_label)
		
		var price_label = Label.new()
		price_label.text = str(item.price)
		hbox.add_child(price_label)
		
		var buy_button = Button.new()
		buy_button.text = "Kaufen"
		buy_button.connect("pressed", Callable(self, "_on_buy_pressed"), [item])
		hbox.add_child(buy_button)
		
		vbox.add_child(hbox)

func _on_buy_pressed(item):
	if player_coins >= item.price:
		player_coins -= item.price
		update_coins()
		print("Gekauft:", item.name)
	else:
		print("Nicht genug Coins für", item.name)
