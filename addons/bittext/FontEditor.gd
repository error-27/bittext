tool
extends Control

# Nodes
var spritesheet_file_dialog: EditorFileDialog = EditorFileDialog.new()
var bitmapfont_file_dialog: EditorFileDialog = EditorFileDialog.new()
var save_file_dialog: EditorFileDialog = EditorFileDialog.new()

# Char range
var char_range_scene: PackedScene = preload("res://addons/pixfont/components/CharRange.tscn")
var char_ranges: Array = [range(ord("A"), ord("Z") + 1)]

# Kerning range
var kerning_scene: PackedScene = preload("res://addons/pixfont/components/KerningInput.tscn")
var kerning_pairs: Array = []

# Font data
var font_resource: BitmapFont
var font_path: String
var spritesheet: Texture
var v_chars: int = 1
var h_chars: int = 1

#Init
func _enter_tree() -> void:
	# Add file dialogs
	add_child(spritesheet_file_dialog)
	add_child(bitmapfont_file_dialog)
	add_child(save_file_dialog)
	
	# Connect char range 0
	get_node("Settings/Character Inputs/RangeList/0/FirstChar").connect("text_changed", self, "_update_ranges")
	get_node("Settings/Character Inputs/RangeList/0/SecondChar").connect("text_changed", self, "_update_ranges")

# Init
func _ready() -> void:
	# Initialize all file dialogs
	spritesheet_file_dialog.add_filter("*.png, *.jpg ; Image File")
	spritesheet_file_dialog.set_mode(EditorFileDialog.MODE_OPEN_FILE)
	
	bitmapfont_file_dialog.add_filter("*.tres, *.res ; Resource File")
	bitmapfont_file_dialog.set_mode(EditorFileDialog.MODE_OPEN_FILE)
	
	save_file_dialog.add_filter("*.tres, *.res ; Resource File")

# Regenerates the characters
func regenerate_chars() -> void:
	# Reset the font resource
	font_resource = BitmapFont.new()
	
	# Initialize important variables
	var tex: Texture = spritesheet
	font_resource.add_texture(tex)
	
	var r: int = 0
	var character: int = 0
	var rect_width: int = tex.get_width() / h_chars
	var rect_height: int = tex.get_height() / v_chars
	
	font_resource.height = rect_height
	
	# Start generation loop
	# Check each row (y axis)
	for vertical in v_chars:
		# Check each column (x axis)
		for horizontal in h_chars:
			# Move to next char range if necessary
			if character == char_ranges[r].size():
				# If we are at the last range, end the loop
				if r + 1 == char_ranges.size():
					break
				
				# Increment range number, reset character
				character = 0
				r += 1
			
			# Assign current character and increment
			var c: int = char_ranges[r][character]
			font_resource.add_char(c, 0, Rect2(rect_width * horizontal, rect_height * vertical, rect_width, rect_height))
			
			character += 1
			
			# TODO: Remove debug text once all is done
			print("Assigned Character: " + char(c))
			print("(" + str(horizontal) + "," + str(vertical) + ")")


# SIGNALED FUNCTIONS
func _on_Spritesheet_Button_pressed() -> void:
	# Open file dialog and wait
	spritesheet_file_dialog.popup_centered_ratio()
	var file = yield(spritesheet_file_dialog, "file_selected")
	
	# Load the spritesheet
	spritesheet = load(file)
	$"%TextureRect".texture = spritesheet
	
	# Correctly initalize anything if needed
	if font_resource == null:
		font_resource = BitmapFont.new()
	if font_resource.textures:
		font_resource.textures[0] = spritesheet
	else:
		font_resource.add_texture(spritesheet)
	
	$"%RangeButton".disabled = false
	$"%H Characters".editable = true
	$"%V Characters".editable = true
	$"Settings/Character Inputs/RangeList/0".visible = true

func _on_BitmapFont_Button_pressed() -> void:
	# Open file dialog and wait
	bitmapfont_file_dialog.popup_centered_ratio()
	var file = yield(bitmapfont_file_dialog, "file_selected")
	
	# Load the file
	font_resource = load(file)
	font_path = file
	print(file)
	
	# Remove all restrictions
	$"%Spritesheet Button".disabled = false
	if font_resource.textures:
		print("unlocking")
		# Load texture
		$"%TextureRect".texture = font_resource.get_texture(0)
		spritesheet = font_resource.get_texture(0)
		
		$"%RangeButton".disabled = false
		$"%H Characters".editable = true
		$"%V Characters".editable = true
		$"Settings/Character Inputs/RangeList/0".visible = true
	else:
		print("locking")
		$"%RangeButton".disabled = true
		$"%H Characters".editable = false
		$"%V Characters".editable = false
		$"Settings/Character Inputs/RangeList/0".visible = false

func _on_New_Button_pressed() -> void:
	
	font_resource = BitmapFont.new()
	
	# Remove restrictions
	$"%Spritesheet Button".disabled = false
	
	$"%RangeButton".disabled = true
	$"%H Characters".editable = false
	$"%V Characters".editable = false
	$"Settings/Character Inputs/RangeList/0".visible = false

# Save the file
func _on_Savebutton_pressed() -> void:
	save_file_dialog.popup_centered_ratio()
	font_path = yield(save_file_dialog, "file_selected")
	ResourceSaver.save(font_path, font_resource)

# Change sprite slicing
func _on_V_Characters_value_changed(value) -> void:
	v_chars = value
	regenerate_chars()

func _on_H_Characters_value_changed(value) -> void:
	h_chars = value
	regenerate_chars()

# Change character ranges
func _on_RangeButton_pressed() -> void:
	print("new range")
	var char_range: Node = char_range_scene.instance()
	char_range.name = str(char_ranges.size())
	$"%RangeList".add_child(char_range)
	
	char_ranges.append(range(
		ord(char_range.get_node("FirstChar").text), 
		ord(char_range.get_node("SecondChar").text) + 1
	))
	char_range.get_node("FirstChar").connect("text_changed", self, "_update_ranges")
	char_range.get_node("SecondChar").connect("text_changed", self, "_update_ranges")
	
	regenerate_chars()
	
	$"%RemoveButton".disabled = false

func _on_RemoveButton_pressed() -> void:
	$"%RangeList".get_node(str(char_ranges.size() - 1)).queue_free()
	char_ranges.pop_back()
	regenerate_chars()
	if char_ranges.size() == 1:
		$"%RemoveButton".disabled = true

func _update_ranges(new_text: String) -> void:
	print("ranges updated")
	var list = $"%RangeList"
	for i in range(char_ranges.size()):
		char_ranges[i] = range(
			ord(list.get_node(str(i) + "/FirstChar").text), 
			ord(list.get_node(str(i) + "/SecondChar").text) + 1
		)
	regenerate_chars()

func _on_NewKerning_pressed() -> void:
	$"%RemoveKerning".disabled = false
	var kerning_pair: Node = kerning_scene.instance()
	kerning_pair.name = str(kerning_pairs.size())
	$"%KerningList".add_child(kerning_pair)
	
	kerning_pairs.append([
		ord(kerning_pair.get_node("FirstChar").text),
		ord(kerning_pair.get_node("SecondChar").text),
		ord(kerning_pair.get_node("Kerning").value)
	])
	
	kerning_pair.get_node("FirstChar").connect("text_changed", self, "_update_kerning")
	kerning_pair.get_node("SecondChar").connect("text_changed", self, "_update_kerning")
	kerning_pair.get_node("Kerning").connect("value_changed", self, "_update_kerning")
	
	$"%RemoveKerning".disabled = false

func _on_RemoveKerning_pressed() -> void:
	$"%KerningList".get_node(str(kerning_pairs.size() - 1)).queue_free()
	kerning_pairs.pop_back()
	regenerate_chars()
	if kerning_pairs.size() == 0:
		$"%RemoveKerning".disabled = true

func _update_kerning() -> void:
	pass
