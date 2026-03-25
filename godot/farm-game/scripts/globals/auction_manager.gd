extends Node

# NONE - for sale
# PLAYER_TEAM - players plot 
# NPC - owned by random npc
# PUBLIC - optional not interactable plots like shop or lake etc. (not for sale, for public use)
enum OwnerType { NONE, PLAYER_TEAM, NPC, PUBLIC }

signal auction_started(initial_bid)
signal auction_updated(current_bid, time_left, last_bidder)
signal auction_ended(winner_plot, winner_type, final_price)
signal npc_rised_hand()

var current_plot = null
var current_bid: int = 0
var time_left: float = 0.0
var is_active: bool = false
var last_bidder: OwnerType = OwnerType.NONE

# you can set this in AuctionWindow as on ready var
var max_time: float = 8.0
var npc_chance: float
var player_bid_amount: int = 100
var npc_bid_amount: int = 50

func select_plot(plot):
	# if other auction active return
	if is_active: return 
	
	current_plot = plot
	current_bid = plot.price 
	time_left = max_time
	last_bidder = OwnerType.NONE
	
	auction_started.emit(current_bid)
	
func start_confirmed():
	is_active = true
	time_left = max_time

func cancel_auction():
	current_plot = null
	is_active = false
	auction_ended.emit(null, OwnerType.NONE, 0)

func _process(delta):
	if not is_active: return
	
	time_left -= delta
	
	if last_bidder == OwnerType.PLAYER_TEAM and time_left < max_time / 2: 
		if randf() < (npc_chance / 100) * delta:
			npc_rised_hand.emit()
			npc_bid()

	if time_left <= 0:
		_end_auction()
	else:
		auction_updated.emit(current_bid, time_left, last_bidder)

func player_bid():
	var next_bid = current_bid + player_bid_amount
	
	if Wallet.can_afford(next_bid):
		current_bid = next_bid
		last_bidder = OwnerType.PLAYER_TEAM
		time_left = min(time_left + 1.5, max_time)


func npc_bid():
	current_bid += npc_bid_amount
	last_bidder = OwnerType.NPC
	time_left = min(time_left + 1.0, max_time)

func _end_auction():
	is_active = false
	
	var final_winner = OwnerType.NONE
	
	if last_bidder == OwnerType.PLAYER_TEAM:
		if Wallet.spend_money(current_bid):
			current_plot.set_ownership(OwnerType.PLAYER_TEAM)
			final_winner = OwnerType.PLAYER_TEAM
	elif last_bidder == OwnerType.NPC:
		current_plot.set_ownership(OwnerType.NPC)
		final_winner = OwnerType.NPC

	auction_ended.emit(current_plot.plot_id, final_winner, current_bid)
	
	current_plot = null
