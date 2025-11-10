#behavior_freecam.gd
extends Behavior
class_name Behavior_Freecam

#You need to figure out the flow of intent. Behaviors ask, "Can I go here?" in reference
#To the origin every frame. The composer should control the speed/acceleration, etc. 
#Also, you need to find a better solution for feeding inputs all the way down. 
 
var speed: float = 0.5
@onready var input_man = $"../../../GameManager/InputManager"
func update(delta: float) -> void:
	var dir_vec = input_man.get_vector("move_left","move_right","move_forward","move_back")
	intent_transform.origin += Vector3(dir_vec.x,0,dir_vec.y) * speed * delta
	var intended_delta = intent_transform.origin - reference_transform.origin
	intent_transform.origin = reference_transform.origin + intended_delta

#func handle_action(action: String, event: InputEvent) -> void:
	#print(action)
	#match action:
		#"move_forward":
			#intent_transform.origin += Vector3(0,0,-1) * speed * get_process_delta_time()
		#"move_back":
			#intent_transform.origin += Vector3(0,0,1) * speed * get_process_delta_time()
