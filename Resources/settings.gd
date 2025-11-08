# settings.gd
extends Resource
class_name Settings
const State = SettingsVar.SettingState
const Type = SettingsVar.SettingType
# DEFAULTS.....................................................................

# PS. Maybe input actions should live here. 

@export_group("Settings")
@export_subgroup("Audio")
@export var dblevel_music := SettingsVar.new(Type.FLOAT,1.0,State.ENABLED,"Music Level")
@export var dblevel_sfx := SettingsVar.new(Type.FLOAT,1.0,State.ENABLED,"SFX Level")
@export_subgroup("Joypad")
enum response { LINEAR, AGGRESSIVE, RELAXED, WIDE, EXTRA_WIDE }
@export var lstick_response_choices := SettingsVar.new(Type.ENUM,response.RELAXED,State.ENABLED, "Left Stick Response", "", 0.0, 1.0, 0.1, response.keys())
@export var rstick_response_choices := SettingsVar.new(Type.ENUM,response.WIDE,State.ENABLED, "Right Stick Response", "", 0.0, 1.0, 0.1, response.keys())
var rstick_response := SettingsVar.new(Type.CURVE,null,State.INTERNAL)
var lstick_response := SettingsVar.new(Type.CURVE,null,State.INTERNAL)
@export var lstick_dz := SettingsVar.new(Type.VECTOR2,Vector2(0.05,0.95),State.ENABLED,"Left Stick Deadzone")
@export var rstick_dz := SettingsVar.new(Type.VECTOR2,Vector2(0.05,0.95),State.ENABLED,"Right Stick Deadzone")
#@export var ltrig_resp: Curve = null
#@export var rtrig_resp: Curve = null
#@export var ltrig_dz: Vector2 = Vector2(0.2,0.95)
#@export var rtrig_dz: Vector2 = Vector2(0.2,0.6)
@export_subgroup("Display")
@export var windowed := SettingsVar.new(Type.BOOL,true,State.ENABLED,"Windowed")
@export var vsync := SettingsVar.new(Type.BOOL,true,State.ENABLED,"Vsync")
enum scalers {NONE, BILINIEAR, AMD_FSR}
@export var scaler := SettingsVar.new(Type.ENUM,scalers.NONE,State.ENABLED, "Scaling Type:", "", 0.0, 1.0, 0.1, scalers.keys())
enum scales {ULTRA, QUALITY, BALANCED, PERFORMANCE}
@export var scale := SettingsVar.new(Type.ENUM,scales.QUALITY,State.DISABLED, "Scaling Preset:", "", 0.0, 1.0, 0.1, scales.keys())
@export var resolutions: Array = [
	Vector2i(2560,1080),
	Vector2i(1920,1080),
	Vector2i(1366,768),
	Vector2i(1536,864),
	Vector2i(1280,720),
	Vector2i(1440,900),
	Vector2i(1600,900),
	Vector2i(1024,600),
	Vector2i(800,600)
]
@export var resolution := SettingsVar.new(Type.ARRAY,resolutions[0],State.ENABLED, "Windowed Resolution:", "", 0.0, 1.0, 0.1, resolutions)
@export_subgroup("Mouse")
@export var mouse_sensitivity := SettingsVar.new(Type.FLOAT, 1.0,State.ENABLED, "Mouse Sensitivity", "", 0.0, 1.0, 0.1)

@export_subgroup("Controls")
var default_actions : InputActionList = load("res://Resources/default_inputs.tres")
@export var actions := SettingsVar.new(Type.INPUTACTIONLIST, default_actions, State.ENABLED, "Input Actions:")
