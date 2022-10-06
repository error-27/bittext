tool
extends EditorPlugin

var font_dock: Node
var dock_button: ToolButton
var interface = get_editor_interface()

func _enter_tree() -> void:
#	interface.get_inspector().connect("resource_selected", self, "_on_selection_changed")
	font_dock = preload("res://addons/bittext/FontEditor.tscn").instance()
	
	dock_button = add_control_to_bottom_panel(font_dock, "BitText")


func _exit_tree() -> void:
	remove_control_from_bottom_panel(font_dock)
	font_dock.free()
#
#func _on_selection_changed(res: Object, prop: String):
#	var selected_type = interface.get_resource_filesystem(interface.get_selected_path())
#	if res is BitmapFont:
#		dock_button.show()
#	else:
#		dock_button.hide()
