#behavior.gd
extends Node
class_name Behavior

#@export var priority: int = 0  # Used for blending if needed
@export var input_exclusive:bool = false
@export var enabled:bool = true
var intent_transform: Transform3D = Transform3D.IDENTITY
var reference_transform: Transform3D = Transform3D.IDENTITY
 
func _ready() -> void:
	var composer = get_parent()
	if not composer or not composer is ComposerComponent:
		push_error("Behaviors require a ComposerComponent as owner.")
	composer.connect("transform_applied", _update_reference)

func update(delta: float) -> void: pass

func handle_action(action: String, event: InputEvent) -> void: pass

func _update_reference(transform : Transform3D):
	reference_transform = transform
