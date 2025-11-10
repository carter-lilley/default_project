@icon("res://Icons/BoxMesh.svg")
#settings_manager.gd
class_name SettingsManager
extends Manager

signal setting_changed(value: Variant, setting: SettingsVar)
signal action_changed(value: InputAction)
signal settings_saved

const SAVE_PATH := "user://user_prefs.tres"
var settings: Settings
var settings_dict: Dictionary[String, SettingsVar] = {}

func _init() -> void:
	print("[SettingsManager]: initialized.")
	load_settings()
	
func _ready() -> void:
	pass
	#var res = preload("res://Resources/default_inputs.tres")

## === Accessors ===
func get_settings() -> Dictionary:
	var dictionary: Dictionary[String, SettingsVar] = {}
	if not settings:
		push_error("No settings loaded, but queried anyway.")
		return dictionary
	for property in settings.get_property_list():
		if settings.get(property.name) is SettingsVar: #Check each property for SettingsVars
			print("[SettingsManager]:",settings.get(property.name))
			#dictionary[property.name] = settings.get(property.name) #Property name is key, SettingsVAR is value. 
			#print("Storing ", property.value)
	return dictionary

# I hate this function. Its so messy. Fix pls. 
func get_settings_by_subgroup() -> Dictionary:
	var dictionary: Dictionary[String, Array] = {}
	if not settings:
		push_error("No settings loaded, but queried anyway.")
		return dictionary
	var subgroup :String = ""
	var settingsvars :Array[SettingsVar] = []
	for property in settings.get_property_list(): #					For every property in the list, 
		if property.usage == 256:  # 								If it's a @export subgroup..
			if not subgroup == "": # 								And we already have a previous subgroup
				dictionary[subgroup] = settingsvars.duplicate() 	# Save the previous settings in an array to that subgroup entry.
			subgroup = property.name
			settingsvars.clear()									# And then clear the array for re-use.
		if settings.get(property.name) is SettingsVar and not subgroup == "": 			# If we've caught a SettingsVar and we already have a previous subgroup
			var settingsvar : SettingsVar = settings.get(property.name)
			settingsvars.append(settingsvar)						# ...Store in the array!
	dictionary[subgroup] = settingsvars.duplicate()					# After checking properties, store the last subgroup pair. (Or nothing)
	return dictionary

func enable_setting(name:String):
	var settingsvar: SettingsVar = get_setting(name)
	settingsvar.state = SettingsVar.SettingState.ENABLED

func disable_setting(name:String):
	var settingsvar: SettingsVar = get_setting(name)
	settingsvar.state = SettingsVar.SettingState.DISABLED
	print("[SettingsManager]: Disabling setting ",name, settingsvar.state )

func set_action(new_action: InputAction, actions : InputActionList):
	for action in actions.list:
		if action.name == new_action.name:
			print('[SettingsManager]: Replacing action..', action.events, " with ", new_action.events)
			action.events = new_action.events
			emit_signal("action_changed", new_action)

func set_setting(value: Variant, setting: SettingsVar):
	if not settings:
		push_error("No settings loaded, cannot change setting '%s'" % setting.property_name)
		return
	if value is InputAction:
		set_action(value as InputAction, setting.value as InputActionList)
		value = setting.value
	setting.value = value
	emit_signal("setting_changed", value, setting)
	print("[SettingsManager]: Changed setting '%s' to %s" % [setting.property_name, str(value)])

func get_setting(name:String) -> SettingsVar:
	var settingsvar: SettingsVar
	if not settings:
		push_error("No settings loaded, but queried anyway.")
		return settingsvar
	settingsvar = settings.get(name)
	return settingsvar

func load_settings() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		settings = ResourceLoader.load(SAVE_PATH) as Settings
		if settings:
			print("[SettingsManager]: Loaded preferences from disk.")
			store_property_names(settings)
			return
	# fallback if load failed
	settings = Settings.new()
	store_property_names(settings)
	print("[SettingsManager]: Created new default preferences.")

# Here we're storing an internal reference to the properties the settingsvars are assigned to. 
func store_property_names(settings : Settings):
	for prop in settings.get_property_list():
		var setting = settings.get(prop.name)
		if setting is SettingsVar:
			setting.property_name = prop.name

func save_settings() -> void:
	if settings:
		var err = ResourceSaver.save(settings, SAVE_PATH)
		if err != OK:
			push_error("Failed to save preferences: %s" % err)
		else:
			print("[SettingsManager]: Preferences saved.")

func reset_settings() -> void:
	settings = Settings.new()
	save_settings()
