extends Control

@onready var string_input: LineEdit = $inputInterface/StringInput
@onready var generate_button: Button = $inputInterface/generateButton
@onready var out_put: Label = $outPut
@onready var out_put_2: RichTextLabel = $outPut2
@onready var board: ColorRect = $DrawingBoard/Board

var input_string: String
var mode_indicator: String = ""
var character_count_indicator: String = ""
var result_string: String
var fully_Encripted_Data: String = ""

var generate: bool
var can_Draw: bool = false

var generator_polynomial_org: Array = [
	1, 29, 196, 111, 163, 
	112, 74, 10, 105, 105, 
	139, 132, 151, 32, 134, 26
]

var tl_no_codewords: int = 55 # change the value later
var ECCPCW: int = 15 # Error Correction Code per codeWord # change vlaue
var galois_field: int = 256
var primary_polynomial: int = 285

var x: int = 1

var integer_logg: Array = []
var exponent_a: Array = []
var logg: Array = [] # exponent of alpha 
var antilogg: Array = [] # intiger

var constant_area: Array = []

var ec_codewords: Array = []
var data_codewords: Array = []

func _ready() -> void:
	mode_indicator = "0100"
	generate = false
	input_string = ""
	table_generator()

##----------------------GENERATOR------------------------##
func on_generate_button_pressed(recived_string: String) -> void:
	if !recived_string == "":
		
		# String Variables
		var current_input_string: String = recived_string
		var binary_string: String = ""
		var fully_encoded_data: String = ""
		var encoded_data: String = ""
		
		# Int Variables
		var nof_characters: int = current_input_string.length()
		var total_required_fillings: int = 0
		var terminator_value: int = 0
		var EC_counter: int = 0
		
		# Array Variables
		var dividend: Array = []
		var divisor: Array = generator_polynomial_org
		data_codewords = []
		ec_codewords = []
		
		#Varaible Initilizing
		out_put.text = ""
		out_put_2.text = ""
		
		result_string = ""
		
		##------------CHARACTER COUNT INDICATOR------------##
		var input_value_b = nof_characters
		while input_value_b > 0:
			binary_string = str(input_value_b % 2) + binary_string
			input_value_b /= 2
			
		if binary_string == "":
			binary_string = "0"
		
		character_count_indicator = binary_string.lpad(8, "0")
		
		##------------CHARACTER INTO BINARY------------##
		for i in range(nof_characters):
			var current_character = current_input_string[i]
			var character_buffer = current_character.to_utf8_buffer()
			var character_ascii = character_buffer[0]
			var character_binary = ""
			print(character_ascii)
			
			while character_ascii > 0:
				character_binary = str(character_ascii % 2) + character_binary
				character_ascii = character_ascii / 2
			
			character_binary = character_binary.lpad(8, "0")
			encoded_data += character_binary
		
		##--------------TERMINATOR ADDITION--------------##
		var total_nof_database_required = 55 * 8
		terminator_value = (mode_indicator.length() + character_count_indicator.length() + encoded_data.length()) % 8
		fully_encoded_data = mode_indicator + character_count_indicator + encoded_data
		total_required_fillings = fully_encoded_data.length() + terminator_value
		fully_encoded_data = fully_encoded_data.rpad(total_required_fillings, "0")
		
		##--------------FILLING UP BYTES--------------##
		if fully_encoded_data.length() != total_nof_database_required:
			fully_encoded_data += "11101100"
			
			while fully_encoded_data.length() != total_nof_database_required:
				if !fully_encoded_data.ends_with("0"):
					fully_encoded_data += "11101100"
				elif fully_encoded_data.ends_with("0"):
					fully_encoded_data += "00010001"
		
		#fully_encoded_data = split_strings(fully_encoded_data)
		##---------------ERROR CORRECTION DATA----------------##
		# All Bytes into ASCII code
		for i in range(0, total_nof_database_required, 8):
			
			EC_counter += 1
			var binary_character_string: String = fully_encoded_data.substr(i, 8)
			var decimel_ascii_value: int = binary_to_decimel(binary_character_string)
			
			dividend.append(decimel_ascii_value)
		
		#print(dividend, "\n \n \n")
		
		fully_Encripted_Data = decimel_to_binary(polynomial_division(dividend, divisor))
		#print("data code word : ", data_codewords)
		# Encripted Data to binary
		
		## Drawing
		can_Draw = true
		print("Drawing_Started")
		queue_redraw()
		
		
		##------------DEBUGGING SCREEN------------##
		result_string.strip_edges()
		
		result_string = ""
		result_string += " Error Correction code word \n\n"
		for i in range(ec_codewords.size()):
			result_string += str(ec_codewords[i]) + " "
		
		result_string += "\n\n Fully Encripted Data in Binary \n\n"
		
		result_string += fully_Encripted_Data
		print("\n\n\n", fully_Encripted_Data.length(), "\n\n\n")
		
		print(data_codewords)
		out_put_2.text = result_string
		out_put.text = "Version 3 \n mode BYTE MODE (Binary Code : 0100)" + "\n Input text = " + current_input_string + "\n Characters Count (in Binary) : " + str(character_count_indicator) + "\n \n BINARY QR CODE ---- \n" + fully_encoded_data + "\n \n lenght of the data : " + str(fully_encoded_data.length())
		
	else:
		print("Error: No String optained")

##---------Logaritham-and-Anit-Logaritham-Table---------##
func table_generator():
	logg.resize(256)
	antilogg.resize(256)
	integer_logg.resize(256)
	exponent_a.resize(256)
	
	logg[0] = 0
	antilogg[0] = 1
	for i in range(1, 256):
		
		antilogg[i] = antilogg[i - 1] * 2
		if antilogg[i] >= galois_field:
			antilogg[i] = antilogg[i] ^ primary_polynomial
			
	# intiger table generator
	integer_logg[0] = -1
	integer_logg[1] = 0
	exponent_a[0] = 1
	
	
	
	var current_value: int = 1
	for i in range(255):
		exponent_a[i] = i
		integer_logg[current_value] = i
		current_value *= 2
		
		if current_value > 255:
			current_value ^= 285

##------------Message Polynomial / Generator Polynomial------------##
func polynomial_division(MP: Array, GP: Array) -> Array:
	# initilizing
	var Message_Polynomial: Array = MP.duplicate()
	var Generator_Polynomial: Array = GP.duplicate()
	
	# S - Make message_poynomial and Generator Polynomial larger
	 # leave this to the end or when needed
	
	# variabls that gona be used in the loop
	var loop_mp: Array = Message_Polynomial.duplicate()
	var loop_gp: Array = Generator_Polynomial.duplicate()
	
	var lead_term_mp: int
	
	# Converting Generator polyonmial into alpha notation
	
	for current_step in range(tl_no_codewords):
		
		lead_term_mp = antilogg.find(loop_mp[0])
		for gp_converter in range(loop_gp.size()):
			loop_gp[gp_converter] = antilogg.find(loop_gp[gp_converter])
		
		
		# Step current_Step a
		for a in range(loop_gp.size()):
			var step_a: int
			step_a = antilogg.find(Generator_Polynomial[a]) + lead_term_mp
			if step_a >= 255:
				step_a = step_a % 255
			
			loop_gp[a] = integer_logg.find(step_a)
		
		# Step current_Step b
		var max_length = max(loop_mp.size(), loop_gp.size())
		
		var t_loop_b_mp: Array = []
		
		for b in range(max_length):
			var mp_val: int = loop_mp[b] if b < loop_mp.size() else 0
			var gp_val: int = loop_gp[b] if b < loop_gp.size() else 0
			
			t_loop_b_mp.append(mp_val ^ gp_val)
			#print(mp_val, " ^ ", gp_val, " = ", mp_val ^ gp_val)
			
		loop_mp = t_loop_b_mp
		# discarding zero
		if loop_mp[0] == 0: loop_mp.remove_at(0)
	
	ec_codewords = loop_mp
	return MP + loop_mp

##-----------------QR CODE DRAWING FUNCTION-----------------##
func _draw() -> void:
	print("Recived signal to draw")
	if can_Draw:
		print("drawn")
		
		## Constants
		var canvas_size: Vector2 = board.size
		var canvas_pos: Vector2 = board.global_position
		var modul_size: Vector2 = Vector2(15, 15)
		
		## finders paterns
		var second_fp_pos: Vector2 = (canvas_pos + Vector2(canvas_size.x, 0)) - Vector2(105, 0)
		var third_fp_pos: Vector2 = (canvas_pos + Vector2(0, canvas_size.y))  - Vector2(0, 105)
		
		var finders_patern_out: Array = [
			# Outer Position 
			canvas_pos,
			second_fp_pos,
			third_fp_pos,
			# Middles Positions
			canvas_pos + modul_size,
			second_fp_pos + modul_size,
			third_fp_pos + modul_size,
			# Inner Position
			canvas_pos + (modul_size * 2),
			second_fp_pos + (modul_size * 2),
			third_fp_pos + (modul_size * 2)
			]
		
		constant_area = [
			Rect2(canvas_pos, Vector2(135, 135)), # top left 
			Rect2(canvas_pos + Vector2(135, 90), Vector2(180, 15)), # top strip line
			Rect2(canvas_pos + Vector2(90, 135), Vector2(15, 180)), # bottom stip line
			Rect2(canvas_pos + Vector2(0, 315), Vector2(135, 120)), # bottom left
			Rect2(canvas_pos + Vector2(315, 0), Vector2(120, 135)), # top right
			Rect2(canvas_pos + Vector2(300, 300), Vector2(75, 75)) # alignment 
		]
		
		for f in range(finders_patern_out.size()):
			var fp_pos: Vector2 = finders_patern_out[f]
			if f < 3:
				draw_rect(Rect2(fp_pos, modul_size * 7), Color.BLACK, true)
			elif 3 <= f and f < 6:
				draw_rect(Rect2(fp_pos, modul_size * 5), Color.WHITE, true)
			elif f >= 6:
				draw_rect(Rect2(fp_pos, modul_size * 3), Color.BLACK, true)
		
		## alignment patern
		draw_rect(Rect2(canvas_pos + (canvas_size - Vector2(135, 135)), modul_size * 5), Color.BLACK, true)
		draw_rect(Rect2(canvas_pos + (canvas_size - Vector2(120, 120)), modul_size * 3), Color.WHITE, true)
		draw_rect(Rect2(canvas_pos + (canvas_size - Vector2(105, 105)), modul_size), Color.BLACK, true)
		
		## Timming paterns
		var binary_color_t: Color
		var int_y: int = 105
		var int_x: int = 105
		for t in range(26):
			if (t % 2) == 0:
				binary_color_t = Color.BLACK
			else:
				binary_color_t = Color.WHITE
			
			if t < 13: int_y += 15
			else: int_x += 15
			
			if t < 13:
				draw_rect(Rect2(canvas_pos + Vector2(90, int_y), modul_size), binary_color_t, true)
			else:
				if binary_color_t == Color.BLACK: binary_color_t = Color.WHITE
				else: binary_color_t = Color.BLACK
				draw_rect(Rect2(canvas_pos + Vector2(int_x, 90), modul_size), binary_color_t, true)
		
		## format String
		# Black pixels
		draw_rect(Rect2(canvas_pos + Vector2(0, 120), Vector2(135,15)), Color.BLACK, true)
		draw_rect(Rect2(canvas_pos + Vector2(120, 0), Vector2(15, 120)), Color.BLACK, true)
		draw_rect(Rect2(canvas_pos + Vector2(canvas_size.x - 120, 120), Vector2(120, 15)), Color.BLACK, true)
		draw_rect(Rect2(canvas_pos + Vector2(120, canvas_size.y - 120), Vector2(15, 120)), Color.BLACK, true)
		
		# White pixels
		draw_rect(Rect2(canvas_pos + Vector2(45, 120), Vector2(15,15)), Color.WHITE, true)
		draw_rect(Rect2(canvas_pos + Vector2(120, 0), Vector2(15, 30)), Color.WHITE, true)
		draw_rect(Rect2(canvas_pos + Vector2(120, 45), Vector2(15, 45)), Color.WHITE, true)
		draw_rect(Rect2(canvas_pos + Vector2(canvas_size.x - 90, 120), Vector2(45, 15)), Color.WHITE, true)
		draw_rect(Rect2(canvas_pos + Vector2(canvas_size.x - 30, 120), Vector2(30, 15)), Color.WHITE, true)
		draw_rect(Rect2(canvas_pos + Vector2(120, canvas_size.y - 60), Vector2(15, 15)), Color.WHITE, true)
		
		
		## Data Bits
		var bit_size: Vector2 = Vector2(15, 15)
		var first_data_pos: Vector2 = Vector2((canvas_pos + canvas_size) - bit_size)
		var bit_pos: Vector2 = first_data_pos
		
		var collision_data: Array = []
		
		var is_skipable: bool
		var is_in_area: bool 
		var move_left: bool = true
		var going_up: bool = true
		var skip: bool = false
		var invert: bool = false
		
		var bit_color: Color
		
		
		collision_data.resize(2)
		fully_Encripted_Data += "0000000"
		
		# Mask patern genarotor
		
		var mask_patern: String = "100110011001100110011001100110011001100101100110011001100110011001100110011001101001100101100110011001100110010110011001100110011001011001101001100101010011001100110011001100110010110011001101001100110010110011001100110011001100110011001100110011010011001100110011001100110011001100110011001011001100110100110011001011001100110011001100110011001100110011001101001100110011001100110011001100110011001100101100110011010011001100101100110011001100110011001100110011001100110100110011001100110011001100110011001100110011001011001100110011001100110100110011001100110011001"
		
		print(mask_patern)
		print(mask_patern.length())
		
		var repeater: int = mask_patern.length() # 567 full size
		
		var count: int = 1
		for o in range(0, repeater): 
			count += 1
			
			if o == 40 or o == 110 or o == 191 or o == 303 or o == 415 or o == 495 or o == 543:
				bit_pos += Vector2(-30, 15) # Keep to next raw Go Down
				going_up = false
			elif o == 80 or o == 140 or o == 247 or o == 359 or o == 471 or o == 519:
				bit_pos += Vector2(-30, -15)  # Keep to next raw Go Up
				going_up = true
			elif o == 88:
				bit_pos += Vector2(0, -75)
				going_up = true
			elif o == 132:
				bit_pos += Vector2(0, 75)
			
			if o == 471:
				bit_pos += Vector2(0, -120)
			elif o == 495:
				bit_pos += Vector2(-15, 0)
			
			 # horizontal Skip
			if o == 179 or o == 291 or o == 403: 
				bit_pos += Vector2(0, -15) # Up skip
			elif o == 203  or o == 315 or o == 427: 
				bit_pos += Vector2(0, 15) # Down Skip
			
			# Alignment modul Skip
			if o == 148:
				skip = true
				bit_pos += Vector2(-15, 0)
			elif o == 153:
				skip = false
				bit_pos += Vector2(15, 0)
				move_left = true
			
			var current_char: String = fully_Encripted_Data[o]
			var current_mask: String = mask_patern[o]
			
			if current_mask == "1":
				if current_char == "1": current_char = "0"
				else: current_char = "1"
			
			if current_char == "0":
				bit_color = Color.WHITE # 0 White
			elif current_char == "1":
				bit_color = Color.BLACK # 1 BLACK
			else:
				bit_color = Color.RED
				print("Unexpencted Character at : 362")
			
			draw_rect(Rect2(bit_pos, bit_size), bit_color, true)
			
			if going_up:
				if !skip:
					if move_left:
						bit_pos += Vector2(-15, 0)
					else:
						bit_pos += Vector2(15, -15)
				else:
					bit_pos += Vector2(0, -15)
			else:
				if move_left:
					bit_pos += Vector2(-15, 0)
				else:
					bit_pos += Vector2(15, 15)
			
			if !skip:
				move_left = !move_left
			else:
				move_left = false
			
		
		can_Draw = false
		
	else:
		print("The function doesnt have permmission to draw yet")

##---------Decimel Binary Convertion---------##
func binary_to_decimel(binary_string: String) -> int:
	var decimel_value: int = 0
	#print("recivied binary : ", binary_string)
	for i in range(binary_string.length()):
		var bit = binary_string[i]
		decimel_value += bit.to_int() * pow(2, binary_string.length() - i - 1)

	return decimel_value

	for i in range(256):
		logg[i] = i

func decimel_to_binary(decimel_array: Array) -> String:
	var fully_string: String
	
	for i in range(decimel_array.size()):
		var string: String = String.num_uint64(decimel_array[i], 2)
		string = string.lpad(8, "0")
		fully_string += string
	
	return fully_string

func split_strings(input_string: String) -> String:
	for i in range(0, input_string.length(), 8):
		result_string += input_string.substr(i, 8) + " "
		
	return result_string.strip_edges()

func _on_string_input_text_changed(new_text: String) -> void:
	input_string = new_text

func _on_generate_button_pressed() -> void:
	on_generate_button_pressed(input_string)


##ust after 2b Multiply the Generator Polynomial by the Lead Term of the XOR result from the previous step
