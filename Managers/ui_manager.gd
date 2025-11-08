@icon("res://Icons/CylinderMesh.svg")
#ui_manager.gd
class_name UIManager
extends Manager

@onready var settings_man = $"../SettingsManager"
@onready var input_man = $"../InputManager"

var menus := {}
var first_tab : Button
var current_menu : Menu

var ui_container : CenterContainer = CenterContainer.new()
var menu_container : VBoxContainer = VBoxContainer.new()
var tab_container : HBoxContainer = HBoxContainer.new()

func _ready():
	# Add the container to the scene
	add_child(ui_container)
	ui_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_container.size = get_viewport().size
	ui_container.add_child(menu_container)
	menu_container.add_child(tab_container)
	initialize_settings_menus()
	input_man.connect("action_triggered", _on_action_triggered)

func _on_action_triggered(action: String, event: InputEvent):
	if event.is_pressed():
		match action:
			"pause":
				if not menu_container.visible:
					menu_container.visible = true
					tab_container.get_child(0).grab_focus()
					switch_menu(menus.values()[0])
				else: menu_container.visible = false
			"ui_cancel":
				if event is InputEventJoypadButton:
					menu_container.visible = false

func initialize_settings_menus():	
	var settings = settings_man.get_settings_by_subgroup()
	for subgroup in settings:
		var settingsvars : Array[SettingsVar] = settings[subgroup]
		var newMenu: Menu = Menu.new()
		if menus.is_empty():
			newMenu.visible = true
			current_menu = newMenu
		else: newMenu.visible = false
		
		menus[subgroup] = newMenu
		newMenu.initialize_settings_menu(subgroup, settingsvars)
		menu_container.add_child(newMenu)
		newMenu.connect("setting_changed", _on_settings_changed.bind(newMenu))
		
		# Create tabs
		var tab = Button.new()
		tab.text = subgroup
		tab.pressed.connect(_on_tab_pressed.bind(subgroup))
		tab_container.add_child(tab)
		if first_tab == null:
			first_tab = tab
			tab.grab_focus()

func _on_settings_changed(value : Variant, setting: SettingsVar, menu: Menu):
	settings_man.set_setting(value, setting)
	for property_name in menu.controls.keys():
		var control = menu.controls[property_name]
		var control_setting = settings_man.get_setting(property_name)
		if control is BaseButton: 
			control.disabled = control_setting.state 
		if control is Range: 
			control.editable = control_setting.state == 0

func _on_tab_pressed(subgroup: String):
	switch_menu(menus[subgroup])

func switch_menu(menu: Menu):
	if current_menu:
		current_menu.visible = false
	current_menu = menu
	current_menu.visible = true
