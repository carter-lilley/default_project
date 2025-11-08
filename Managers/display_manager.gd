@icon("res://Icons/ArrayMesh.svg")
#display_manager.gd
class_name DisplayManager
extends Manager

@onready var settings_man = $"../SettingsManager"

func _ready() -> void:
	settings_man.connect("setting_changed", _on_setting_changed)

func _on_setting_changed(value: Variant, setting: SettingsVar):
	match setting.property_name:
		"windowed":
			windowed_toggle(value)
		"scale":
			set_viewport_scale(value)
		"scaler":
			set_viewport_scaler(value)
		"resolution":
			set_resolution(value)

func set_resolution(choice : Vector2i):
	#var chosen_res : Vector2i = settings_man.settings.resolutions[choice]
	DisplayServer.window_set_size(choice)
	DisplayServer.window_set_position((DisplayServer.screen_get_position()+DisplayServer.screen_get_size()/2)-choice/2)

func set_viewport_scaler(choice : Settings.scalers):
	match choice:
		Settings.scalers.NONE:
			get_viewport().set_scaling_3d_scale(1.0)
			print("Set viewport scale to: ", 1.0)
			settings_man.disable_setting("scale")
		Settings.scalers.BILINIEAR:
			get_viewport().set_scaling_3d_mode(Viewport.SCALING_3D_MODE_BILINEAR)
			set_viewport_scale(settings_man.get_setting("scale").value)
			settings_man.enable_setting("scale")
		Settings.scalers.AMD_FSR:
			get_viewport().set_scaling_3d_mode(Viewport.SCALING_3D_MODE_FSR2)
			set_viewport_scale(settings_man.get_setting("scale").value)
			settings_man.enable_setting("scale")
	
func set_viewport_scale(choice : Settings.scales):
	var scale: float
	match choice:
		Settings.scales.ULTRA:
			scale = .77
			get_viewport().set_scaling_3d_scale(.77)
		Settings.scales.QUALITY:
			scale = .67
			get_viewport().set_scaling_3d_scale(.67)
		Settings.scales.BALANCED:
			scale = .59
			get_viewport().set_scaling_3d_scale(.59)
		Settings.scales.PERFORMANCE:
			scale = .50
	get_viewport().set_scaling_3d_scale(scale)
	print("Set viewport scale to: ", scale)

func windowed_toggle(value : bool):
	if value:
		print("Windowed mode.")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		set_resolution(settings_man.get_setting("resolution").value)
		settings_man.enable_setting("resolution")
	else:
		print("Fullscreen mode.")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		settings_man.disable_setting("resolution")
