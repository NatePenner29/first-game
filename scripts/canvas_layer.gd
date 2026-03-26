extends CanvasLayer

@onready var label = $Label

func _ready():
	print("🟢 UI READY")
	add_to_group("wave_ui")
	label.text = "Wave 1"


func show_wave(wave_number):
	print("📊 UI bekommt Wave:", wave_number)
	label.text = "Wave " + str(wave_number)
