# settings_var.gd
extends Resource
class_name SettingsVar

## Represents a single setting entry with metadata for menus, validation, etc.

enum SettingType { FLOAT, INT, BOOL, CURVE, VECTOR2, ENUM, ARRAY, INPUTACTIONLIST }
enum SettingState { ENABLED, DISABLED, INTERNAL }

var property_name: String = ""
@export var type: SettingType = SettingType.FLOAT
@export var state: SettingState = SettingState.ENABLED
@export var value: Variant
@export var display_name: String
@export var description: String = ""

# Optional numeric constraints
@export var min_value: float = 0.0
@export var max_value: float = 1.0
@export var step: float = 0.1
# Optional for dropdowns or enum-style choices
@export var options: Array = []

func _init(
	type: SettingType,
	value: Variant,
	state: SettingState = SettingState.ENABLED,
	display_name: String = "",
	description: String = "",
	min_value: float = 0.0,
	max_value: float = 1.0,
	step: float = 0.1,
	options: Array = []
):
	self.type = type
	self.value = value
	self.state = state
	self.display_name = display_name
	self.description = description
	self.min_value = min_value
	self.max_value = max_value
	self.step = step
	self.options = options
	
