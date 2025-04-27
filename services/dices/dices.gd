extends Node

class_name Dices

@export var dice_scene: PackedScene

const MAX_DICES = 32

var table: Table
var dices: Dictionary[int, Dice]

func init_table(table_instance: Table):
	table = table_instance

func first_available_dice_slot():
	for i in range(MAX_DICES):
		if not dices.has(i):
			return i
		
	return -1

func add_dice():
	var dice_slot = first_available_dice_slot()
	if (dice_slot == -1):
		return
		
	var dice: Dice = dice_scene.instantiate()
	table.add_child(dice)
	
	dice.position = get_dice_position(dice_slot)
	dices[dice_slot] = dice
	
func remove_dice(dice: Dice):
	for i in range(MAX_DICES):
		if not dices.has(i):
			continue
		
		if (dices[i] == dice):
			dices.erase(i)

func get_dice_position(slot: int) -> Vector2:
	if slot < 0 or slot >= MAX_DICES:
		return Vector2.ZERO
	
	# Layout configuration
	const ROWS = 4
	const COLS = 8
	const MARGIN_PERCENT = 0.1  # Margin around the grid as percentage of table size
	
	# Calculate row and column from slot index
	var row = slot / COLS
	var col = slot % COLS
	
	# Calculate usable area after applying margins
	var table_size = Vector2(table.size)
	var margin = table_size * MARGIN_PERCENT
	var usable_area = table_size - (margin * 2)
	
	# Calculate cell size and spacing
	var cell_width = usable_area.x / COLS
	var cell_height = usable_area.y / ROWS
	
	# Calculate position within the grid
	var x = margin.x + (col * cell_width) + (cell_width * 0.5)
	var y = margin.y + (row * cell_height) + (cell_height * 0.5)
	
	return Vector2(x, y)

func throw_dices(): 
	for i in range(MAX_DICES):
		if not dices.has(i):
			continue
		dices[i].throw()
