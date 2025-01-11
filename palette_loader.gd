@tool
extends EditorScript

@export var folder : String = "res://palettes/"

@export var res_path : String = "res://palette_manager.tres"
@export var script_path : String = "res://palette.gd"

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var manager : PaletteManager = update_resource()
	var script : Script = update_script(manager)

	ResourceSaver.save(manager, res_path)
	ResourceSaver.save(script, script_path)


func update_resource() -> PaletteManager:
	# load palatte manager
	var manager : PaletteManager = load(res_path)
	manager.textures.clear()
	manager.names.clear()

	# Open the palette folder and begin scaning
	var dir = DirAccess.open(folder)
	dir.list_dir_begin()

	manager.textures.append(null)
	manager.names.append("EMPTY")

	while true:

		# get the next palette
		var file_name : String = dir.get_next()
		if(file_name == ""):
			break

		# load as a texture
		var txt : Texture2D = load(folder + file_name)
		var name : String = file_name

		name = name.trim_suffix("-1x.png")
		name = name.replace("-", "_")
		name = name.to_upper()

		manager.textures.append(txt)
		manager.names.append(name)

		# skip .import
		dir.get_next()


	manager.num = manager.names.size()

	return manager


var content = """
class_name Palette extends RefCounted

enum Enum {
	EMPTY"""

func update_script(manager : PaletteManager):

	var script : GDScript = GDScript.new()

	for k : String in manager.names.slice(1):
		content += ",\n\t%s" % k

	content += "\n}"

	script.source_code = content
	return script
