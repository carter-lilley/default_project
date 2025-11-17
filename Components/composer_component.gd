#composer_component.gd
@icon("res://Icons/CharacterBody2D.svg")
extends Component
class_name ComposerComponent

@export var parent: Node3D
@export var intent_emitter : Node
var behaviors: Array[Behavior] = []

signal transform_applied(transform: Transform3D)
	
func _ready() -> void:
	parent = get_parent() as Node3D
	for child in get_children():
		if child is Behavior:
			print("[%s's %s]: %s - behavior added to list." % [parent.name, str(self), child.name])
			behaviors.append(child)
	for sibling in parent.get_children():
		if sibling.has_method("intent"):
			intent_emitter = sibling
			print("[%s COMPOSER]: FOUND INTENT EMITTER %s." % [parent.name,intent_emitter.name])

# Interpret behavior transform relative to current transform
# (the behavior’s origin is a local offset in its intent space)
func _process(delta: float) -> void:
	#print(intent_emitter.intent.move)
	var base_transform: Transform3D = parent.global_transform
	var final_transform: Transform3D = base_transform
	for behavior in behaviors:
		if not behavior.enabled:
			continue  # skip disabled behaviors
		behavior.update(delta)
		var relative := behavior.intent_transform
		final_transform.origin += base_transform.basis * relative.origin
		# If the behavior also wants to influence rotation:
		final_transform.basis = final_transform.basis * relative.basis
	# Smoothly move towards final transform
	parent.global_transform = final_transform
	emit_signal("transform_applied",parent.global_transform)
