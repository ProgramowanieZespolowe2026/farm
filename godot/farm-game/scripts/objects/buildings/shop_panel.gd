extends Node2D
const SlotClass = preload("res://scripts/ui/slot.gd")
const ItemClass = preload("res://scripts/items/item.gd")

@onready var shop_panel: Node2D = $"."
@onready var slot_product_to_sell: Panel = $Slot21
@onready var product_price: Label = $ProductPrice
@onready var shop_slots: GridContainer = $Control2/GridContainer
@onready var page_number: Label = $PageNumber

signal shop_panel_open(is_open: bool)

var product_to_sell: SlotClass
var page = 0;

var items_not_for_sale=[
	"Chicken_Adult",
	"Chicken_Died",
	"Cow_Adult",
	"Cow_Died",
	"Pig_Adult",
	"Pig_Died",
	"Sheep_Adult",
	"Sheep_Adult_HairCut",
	"Sheep_Died"
	]

func _ready():
	var slots = shop_slots.get_children()
	for i in range(slots.size()):
		var slot = slots[i]
		slot.gui_input.connect(slot_gui_input.bind(slot))
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.SHOP
	#InventoryManager.inventory_updated.connect(initialize_inventory)
	
	slot_product_to_sell.gui_input.connect(slot_gui_input.bind(slot_product_to_sell))
	slot_product_to_sell.slot_index = 0
	slot_product_to_sell.slot_type = SlotClass.SlotType.CHICKENCOOP_FOOD

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if find_parent("GameScreen").holding_item != null:
				if !slot.item:
					left_click_empty_slot(slot)
				else:
					if find_parent("GameScreen").holding_item.item_name != slot.item.item_name:
						left_click_different_item(event, slot)
						AudioManager.put_in_slot.play()
					else:
						left_click_same_item(slot)
						AudioManager.put_in_slot.play()
			elif slot.item:
				left_click_not_holding(slot)

func left_click_empty_slot(slot: SlotClass):
	if slot.slot_type != 4:
		slot.putIntoSlot(find_parent("GameScreen").holding_item)
		
		find_parent("GameScreen").holding_item = null
		product_to_sell = slot
		calc_product_price()

func left_click_different_item(event: InputEvent, slot: SlotClass):
	if slot.slot_type != 4:
		InventoryManager.remove_item(slot)
		InventoryManager.add_item_to_empty_slot(find_parent("GameScreen").holding_item, slot)
		var temp_item = slot.item
		slot.pickFromSlot()
		temp_item.global_position = event.global_position
		slot.putIntoSlot(find_parent("GameScreen").holding_item)
		find_parent("GameScreen").holding_item = temp_item
		product_to_sell = slot
		calc_product_price()

func left_click_same_item(slot: SlotClass):
	if slot.slot_type != 4:
		var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
		var able_to_add = stack_size - slot.item.item_value
		if able_to_add >= find_parent("GameScreen").holding_item.item_value:
			InventoryManager.add_item_value(slot, find_parent("GameScreen").holding_item.item_value)
			slot.item.add_item_value(find_parent("GameScreen").holding_item.item_value)
			find_parent("GameScreen").holding_item.queue_free()
			find_parent("GameScreen").holding_item = null
		else:
			InventoryManager.add_item_value(slot, able_to_add)
			slot.item.add_item_value(able_to_add)
			find_parent("GameScreen").holding_item.decrease_item_value(able_to_add)
		product_to_sell = slot
		calc_product_price()

func left_click_not_holding(slot: SlotClass):
	if slot.slot_type != 4:
		find_parent("GameScreen").holding_item = slot.item
		slot.pickFromSlot()
		InventoryManager.remove_item(slot)
		if find_parent("GameScreen").holding_item != null:
			find_parent("GameScreen").holding_item.global_position = get_global_mouse_position()
		product_to_sell = null
		calc_product_price()
	

func open_panel(coop_pos: Vector2i):
	fetch_products_price()
	setVisiblePanel(true)

func close_panel():
	setVisiblePanel(false)
			
func setVisiblePanel(is_open = null):
	if is_open == null:
		shop_panel.visible = !shop_panel.visible
	else:
		shop_panel.visible = is_open
	shop_panel_open.emit(shop_panel.visible)

#func calc_product_price():
	#if product_to_sell:
		#print(product_to_sell.item.item_name)
		#for i in JsonData.item_data:
			#var item = JsonData.item_data[i]
			#if i == product_to_sell.item.item_name:
				#product_price.text = str(item["SellPrice"]*product_to_sell.item.item_value,"$")
				#break
	#else:
		#product_price.text = "0$"
		
func calc_product_price():
	if product_to_sell and product_to_sell.item:
		var item_name = product_to_sell.item.item_name
		var base_sell_price = JsonData.item_data[item_name]["SellPrice"]
		var final_unit_price = MarketManager.get_price(item_name, base_sell_price)
		var total_price = final_unit_price * product_to_sell.item.item_value
		
		product_price.text = str(total_price, " $")
		
		print("Przedmiot: ", item_name, " | Cena jedn.: ", final_unit_price, " | Suma: ", total_price)
	else:
		product_price.text = "0$"
	
func fetch_products_price():
	var slots = shop_slots.get_children()
	var all_item_keys = JsonData.item_data.keys()
	
	var items_to_show = []
	for key in all_item_keys:
		if key not in items_not_for_sale:
			items_to_show.append(key)

	for i in range(20):
		var index_na_liscie = i + (page * 20)
		
		if index_na_liscie < items_to_show.size():
			var item_id = items_to_show[index_na_liscie]
			
			slots[i].initialize_item(item_id, 1)
			# te 3 linijki dodane a nastepna zakomentowana
			var base_buy_price = JsonData.item_data[item_id]["BuyPrice"]
			var final_buy_price = MarketManager.get_price(item_id, base_buy_price)
			slots[i].update_product_price_label(final_buy_price)
			
			#slots[i].update_product_price_label(JsonData.item_data[item_id]["BuyPrice"])
			slots[i].hide_label_visibility()
			slots[i].change_visibility_buy_button(true)
		else:
			slots[i].remove_item()
			slots[i].change_visibility_buy_button(false)

#func _on_sell_button_pressed() -> void:
	#if product_to_sell:
		#for i in JsonData.item_data:
			#var item = JsonData.item_data[i]
			#if i == product_to_sell.item.item_name:
				#Wallet.add_money(item["SellPrice"]*product_to_sell.item.item_value)
				#product_to_sell.remove_item()
				#product_to_sell = null
				#product_price.text = "0$"
				#break
				
func _on_sell_button_pressed() -> void:

	if product_to_sell and product_to_sell.item:
		var item_name = product_to_sell.item.item_name
		var item_qty = product_to_sell.item.item_value
		
		var base_price = JsonData.item_data[item_name]["SellPrice"]
		var final_unit_price = MarketManager.get_price(item_name, base_price)
		var total_profit = final_unit_price * item_qty
		
		Wallet.add_money(total_profit)
		
		product_to_sell.remove_item()
		product_to_sell = null
		product_price.text = "0$"
		AudioManager.cha_ching.play()
		print("Sprzedano ", item_qty, "x ", item_name, " za ", total_profit, "$")
	else:
		print("Brak przedmiotu do sprzedaży!")
	

#func _on_buy_button_pressed() -> void:
	#var button = get_viewport().gui_get_focus_owner()
	#var slot = button.get_parent()
	#if not slot.item == null:
		#InventoryManager.add_item(slot.item.item_name,1)
		#fetch_products_price()
		#Wallet.spend_money(slot.get_buy_product_price())
		
func _on_buy_button_pressed() -> void:
	var button = get_viewport().gui_get_focus_owner()
	var slot = button.get_parent()
	
	if slot.item != null:
		var item_name = slot.item.item_name
		
		var base_buy_price = JsonData.item_data[item_name]["BuyPrice"]
		var final_buy_price = MarketManager.get_price(item_name, base_buy_price)
		
		if Wallet.balance >= final_buy_price:
			InventoryManager.add_item(item_name, 1)
			Wallet.spend_money(final_buy_price)
			
			fetch_products_price()
			AudioManager.cha_ching.play()
			print("Kupiono ", item_name, " za ", final_buy_price, "$ (Cena bazowa: ", base_buy_price, ")")
		else:
			print("Nie masz wystarczająco pieniędzy!")


func _on_previous_page_pressed() -> void:
	if not page == 0:
		AudioManager.next_prev_sound.play()
		page -= 1
		fetch_products_price()
		page_number.text = str("Page ", page+1)


func _on_next_page_pressed() -> void:
	if ((page+1)*20) < (JsonData.item_data.size()-items_not_for_sale.size()):
		AudioManager.next_prev_sound.play()
		page += 1
		fetch_products_price()
		page_number.text = str("Page ", page+1)
