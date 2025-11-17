# player.gd
extends Resource
class_name Player

var id: int = -1

var intent:Intent = Intent.new()
var components:Array[PlayerComponent]

var controller_id: int = -1
var has_joypad:bool = false

func unbind_controller(device_name : String, devID: int):
	controller_id = -1
	has_joypad = false
	print("[Player %d]: Controller %s [%d] unbound" % [id, device_name, controller_id])
	
func bind_controller(device_name : String, devID: int):
	controller_id = devID
	has_joypad = true
	print("[Player %d]: Controller %s [%d] bound" % [id, device_name, controller_id])
