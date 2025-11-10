# menu.gd
extends VBoxContainer
class_name Menu

var subgroup_name: String
var variables: Array

const State = SettingsVar.SettingState
const Type = SettingsVar.SettingType
signal setting_changed(value: Variant, setting: SettingsVar)

func initialize_settings_menu(subgroup : String, settingsvars : Array[SettingsVar]):
	var menu_name_label = Label.new()
	menu_name_label.text = subgroup
	add_child(menu_name_label)
	for settingsvar in settingsvars:
		if not settingsvar.state == State.INTERNAL:
			match_var_type(settingsvar)
			#var reset_defaults = Button.new()
			#reset_defaults.text = "RESET TO DEFAULT"
			##reset_defaults.connect("pressed", reset_variables.bind(menu_vars))
			#add_child(reset_defaults)

var controls: Dictionary[String, Control] = {}
func match_var_type(settingsvar : SettingsVar):
	match settingsvar.type:
		Type.BOOL:
			var check_box = CheckBox.new()
			check_box.text = settingsvar.display_name
			check_box.button_pressed = settingsvar.value
			add_child(check_box)
			check_box.disabled = settingsvar.state
			controls[settingsvar.property_name] = check_box
			check_box.toggled.connect(func(pressed: bool):
				emit_signal("setting_changed", pressed, settingsvar)
			)
		Type.ENUM, Type.ARRAY:
			var option_button = OptionButton.new()
			var option_label = Label.new()
			option_label.text = settingsvar.display_name
			var id = 0
			for option in settingsvar.options:
				option_button.add_item(str(option), id)
				# For enums (ints), match by index
				if settingsvar.type == Type.ENUM and settingsvar.value == id:
					option_button.select(id)
				# For arrays, match by actual value (string or Vector2)
				elif settingsvar.type == Type.ARRAY and str(option) == str(settingsvar.value):
					option_button.select(id)
				id += 1
			add_child(option_label)
			add_child(option_button)
			option_button.disabled = settingsvar.state
			controls[settingsvar.property_name] = option_button
			option_button.item_selected.connect(func(value: int):
				emit_signal("setting_changed", value, settingsvar)
			)
		Type.FLOAT, Type.INT:
			var slider = HSlider.new()
			slider.focus_mode = 2
			slider.min_value = settingsvar.min_value
			slider.max_value = settingsvar.max_value
			slider.step = settingsvar.step
			slider.value = settingsvar.value  # Default value if not provided
			var slider_label = Label.new()
			slider_label.text = settingsvar.display_name
			add_child(slider_label)
			add_child(slider)
			slider.editable = settingsvar.state == 0
			controls[settingsvar.property_name] = slider
			slider.value_changed.connect(func(value: float):
				emit_signal("setting_changed", value, settingsvar)
			)
		Type.VECTOR2: # Replace with a real range slider eventually
			var rangeslider = RangeSlider.new(settingsvar.value.x, settingsvar.value.y, 0.05)
			#fix setting after creation
			rangeslider.set("_step",0.05)
			rangeslider.set("range_start",settingsvar.value.x)
			#print("SETTING RANGE START ", settingsvar.value.x)
			rangeslider.set("range_end",settingsvar.value.y)
			var rangeslider_label = Label.new()
			rangeslider_label.text = settingsvar.display_name
			add_child(rangeslider_label)
			add_child(rangeslider.min)
			add_child(rangeslider.max)
			rangeslider.min.editable = settingsvar.state == 0
			rangeslider.max.editable = settingsvar.state == 0
			controls[settingsvar.property_name] = rangeslider
			rangeslider.value_changed.connect(func(value: Vector2):
				emit_signal("setting_changed", value, settingsvar)
			)
		Type.INPUTACTIONLIST:
			var controlgroup_label = Label.new()
			controlgroup_label.text = settingsvar.display_name
			add_child(controlgroup_label)
			var actions = settingsvar.value as InputActionList
			for action in actions.list:
				var action_row_hbox = HBoxContainer.new()
				action_row_hbox.size_flags_horizontal = SIZE_EXPAND_FILL
				action_row_hbox.custom_minimum_size = Vector2(325,25)
				add_child(action_row_hbox)	
		#	Generate input labels.
				var action_label = Label.new()
				action_label.text = action.name
				var label_panel = Panel.new()
				label_panel.size_flags_horizontal = SIZE_EXPAND_FILL
				label_panel.size_flags_vertical = SIZE_FILL
				action_row_hbox.add_child(label_panel)
				label_panel.add_child(action_label)
				var input_buttons = InputButtons.new(action)
				action_row_hbox.add_child(input_buttons)
				input_buttons.action_changed.connect(func(value: InputAction):
					emit_signal("setting_changed", value, settingsvar)
				)
		_:
			var button = Button.new()
			button.text = settingsvar.display_name
			add_child(button)
