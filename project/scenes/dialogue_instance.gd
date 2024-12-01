class_name DialogueInstance
extends Object

var rng = RandomNumberGenerator.new()

signal killed #never actually called lol
signal finished(index: Dictionary)

static var ACCUSED_i : int
static var ACCUSING_i : int
static var NPC_RESULTS_SUCCESS_i : int
static var NPC_RESULTS_FAILURE_i : int
static var PLAYER_RESULTS_FAILURE_i : int
static var PLAYER_RESULTS_SUCCESS_i : int

enum Id {
	TEST_1,
	TEST_2,
	ROUND_START_1,
	NPC_BET_1,
	NPC_CALL_1,
	NPC_LOSE_1,
	NPC_WIN_1,
	NPC_DEATH_1,
	QUERY_LIAR,
	CAPTAIN_SHOOTS,
	DIALOGUE_PROMPT,
	
	
	## INTRO
	INTRO_DIALOGUE,
	INTRO_DIALOGUE_2,
	GAME_INSTRUCTIONS,
	GOLDEN_RULE,
	
	## PIRATE DIALOGUE
	PIRATE_NAME,
	PIRATE_NAME_2,
	PIRATE_DEATH_1,
	PIRATE_DEATH_2,
	PIRATE_DEATH_3,
	PIRATE_NOW,
	PIRATE_SECRET_FAIL,
	PIRATE_SECRET,
	PIRATE_REVEAL,
	
	## NAVY DIALOGUE
	NAVY_NAME,
	NAVY_NOW_1,
	NAVY_NOW_2,
	NAVY_SHIP,
	NAVY_SHIP_2,
	NAVY_EVENT_1,
	NAVY_IS_NAVY,
	NAVY_SECRET_FAIL,
	NAVY_SECRET,
	NAVY_SECRET_2,
	
	## CAPTAIN DIALGOUE
	CAPTAIN_NAME,
	CAPTAIN_KNOW_SECRET,
	CAPTAIN_SHIP,
	CAPTAIN_SHIP_2,
	CAPTAIN_CREW,
	CAPTAIN_NOW,
	CAPTAIN_REVEAL,
	CAPTAIN_ESCAPE,
	
	# INTERIM DIALOGUE - TODO IMPLIMENT THESE AND TEST
	NO_LOOK,
	QUIET,
	FIRST_BET,
	ACCUSING,
	ACCUSED,
	PLAYER_RESULTS_SUCCESS,
	PLAYER_RESULTS_FAILURE,
	NPC_RESULTS_SUCCESS,
	NPC_RESULTS_FAILURE,
	BACK_TO_GAME,
	PLEASE_TALK_BRO,
	
	## NOT REAL DIALOGUES
	LIAR,
	PASS
}

var display : DialogueDisplay
var my_id : Id
var arguments : Dictionary
var is_playing := false

var prev_index = -1

var dialogues : Dictionary = {
	Id.TEST_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I can talk normally,[set speed=5] I can talk slow,[set speed=200] and I can talk fast")
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I can also pause,[set pause_time=0.9] dramatically[set pause_time=2][set speed=5]...")
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Anyway what do ye think lad? Is that cool or what?", false)
		var result := await display.push_options([OptionSet.new(Dialogue.Actor.PIRATE_LEFT, ["Yes. Super Cool", "No..."])])
		match result.index:
			0: await display.say(Dialogue.Actor.PIRATE_LEFT, "That's the [wave amp=20.0 freq=5.0 connected=1]spirit[/wave]")
			1: await display.say(Dialogue.Actor.PIRATE_LEFT, "Fuck you.")
		return {},
	
	Id.TEST_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I'm talking over here on the left.")
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "I talk over here on the right.")
		await display.say(Dialogue.Actor.CAPTAIN, "And I talk in[set pause_time=0.2] the[set pause_time=0.2] middle.")
		return {},
	
	Id.ROUND_START_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		match args.round_number:
			1: await display.say(Dialogue.Actor.CAPTAIN, "Let us begin.") 
			2: await display.say(Dialogue.Actor.CAPTAIN, "Time fer the next toss.")
			3: await display.say(Dialogue.Actor.CAPTAIN, "Looks like it's down to just us, matey.")
		display.clear_speach()
		return {},
	
	Id.NPC_BET_1: func(args: Dictionary) -> Dictionary:
		var actor : Dialogue.Actor = args.actor
		var bet : LiarsDice.Round.Bet = args.bet
		
		display.clear_options()
		await display.say(actor, "I bet " + Dialogue.get_bet_string(bet), false)
		return {},
	
	Id.NPC_CALL_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(args.actor, Dialogue.get_bet_string(args.bet) + "? Ye be a liar!") # or just Liar! ?
		display.clear_speach()
		return {},
	
	Id.NPC_LOSE_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(args.actor, "Well played matey.")
		display.clear_speach()
		return {},
	
	Id.NPC_WIN_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		
		await display.say(args.actor, "I knew it.")
		
		display.clear_speach()
		return {},
	
	Id.QUERY_LIAR: func(args: Dictionary) -> Dictionary:
		var result := await display.push_options([OptionSet.new(args.actor, ["LIAR!", "Pass"])])
		display.clear_speach()
		return {"called": result.index == 0},
	
	Id.NPC_DEATH_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(args.actor, "It's time fer me to go.")
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_SHOOTS: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		
		
		if LiarsDice.physical.pirate_gun.state == Gun.State.ON_TABLE:
			## FINAL ENDING SEQUENCE
			await display.say(Dialogue.Actor.CAPTAIN, "Alas, ye just never learn.")
			await display.say(Dialogue.Actor.CAPTAIN, "Ye can try all ye want.") 
			await display.say(Dialogue.Actor.CAPTAIN, "Rile up me crew. Cause a rucuss.")
			LiarsDice.physical.pan_camera_to_pirate_gun()
			display.say(Dialogue.Actor.CAPTAIN, "But the Captain [set pause_time=0.7]always [set pause_time=0.7]wins.", false, false)
			await LiarsDice.physical.pirate_gun.picked_up
			LiarsDice.physical.pan_camera_to_npc(Dialogue.Actor.CAPTAIN)
			await display.get_tree().create_timer(0.5).timeout
			await display.say(Dialogue.Actor.CAPTAIN, "Avast their matey.")
			await display.say(Dialogue.Actor.CAPTAIN, "We don't gotta part ways like this.")
			var result := await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["Goodbye Captain"])])
			await display.get_tree().create_timer(0.5).timeout
			LiarsDice.physical.play_credits()
			await killed
		elif LiarsDice.alive_players.size() == 2 and not Progress.know_captain_secret and Progress.player_death_count > 0:
			## CAPTAIN REVEAL
			await Dialogue.play(Id.CAPTAIN_REVEAL).finished
		else:
			await display.say(Dialogue.Actor.CAPTAIN, "Well ye know the rules...")
			LiarsDice.physical.is_captain_gun_drawn = true
			await display.say(Dialogue.Actor.CAPTAIN, "Farewell ye sea dog.")
		display.clear_speach()
		return {},
	
	
	Id.DIALOGUE_PROMPT: func(args: Dictionary) -> Dictionary:
		var last_speaking_actor : Dialogue.Actor
		var result : Dictionary
		for i in args.max_dialogue_count:
			await Dialogue.get_tree().create_timer(0.1).timeout
			var options : Array[OptionSet]
			var possible_ids := {}
			for actor: Dialogue.Actor in args.actors:
				possible_ids[actor] = get_npc_dialogue_options(actor, false)
				options.append(OptionSet.new(actor, possible_ids[actor].map(get_dialogue_option_lead)))
			
			var option_result := await display.push_options(options)
			var chosen_id : DialogueInstance.Id = possible_ids[option_result.actor][option_result.index]
			last_speaking_actor = option_result.actor
			display.clear_options()
			result = await Dialogue.play(chosen_id).finished
			Progress.has_player_done_optional_dialogue = true
			if "start_new_round" in result: return result
		
		
		await display.say(last_speaking_actor, "But enough 'bout me. Time to make yer bet.") # reach randomizer
		if args.bet.amount > 0:
			await display.say(last_speaking_actor, "Up the bid from " + Dialogue.get_bet_string(args.bet))
		display.clear_speach()
		
		return {},
	
	Id.INTRO_DIALOGUE: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "Ahoy, welcome aboard the graveyard of The Siren's Wake.") 
		await display.say(Dialogue.Actor.CAPTAIN, "I expect ye traveled far to join us sorry souls.")
		await display.say(Dialogue.Actor.CAPTAIN, "What brings ye to me quarters?")
		await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["I seek an ancient secret.", "Immortality."])])
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Yar, the secret to immoralitity?")
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "The cap'n knows about that...")
		await display.say(Dialogue.Actor.CAPTAIN, "Aye, but I can't share it for nothin'.")
		await display.say(Dialogue.Actor.CAPTAIN, "How 'bout we settle this with a game.")
		await display.say(Dialogue.Actor.CAPTAIN, "If ye can best all three o' us in Liar's Dice,")
		await display.say(Dialogue.Actor.CAPTAIN, "then I'll tell ye the secret.")
		await display.say(Dialogue.Actor.CAPTAIN, "But If ye lose...")
		await display.say(Dialogue.Actor.CAPTAIN, "Ye pay with yer life.")
		await display.say(Dialogue.Actor.CAPTAIN, "Have we a deal?")
		await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["Aye", "Deal"])])
		display.clear_speach()
		GameMaster.flash_lightning()
		await Dialogue.play(Id.INTRO_DIALOGUE_2).finished
		return {},
	
	Id.INTRO_DIALOGUE_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await Dialogue.get_tree().create_timer(2.0).timeout
		if not Progress.know_captain_secret:
			await display.say(Dialogue.Actor.CAPTAIN, "Aye, matey.")
			await display.say(Dialogue.Actor.CAPTAIN, "Do ye know how to play Liars Dice?")
			if Progress.player_death_count == 0:
				await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["Remind me."])])
				await Dialogue.play(Id.GAME_INSTRUCTIONS)
			else:
				var result := await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["Yar", "Remind me."])])
				if result.index == 1:
					await Dialogue.play(Id.GAME_INSTRUCTIONS)
				else:
					await display.say(Dialogue.Actor.CAPTAIN, "Grand.")
					await Dialogue.play(Id.GOLDEN_RULE).finished
					LiarsDice.start_new_game(false)
		else:
			await display.say(Dialogue.Actor.CAPTAIN, "I'm sure ye already know how to play.")
			await Dialogue.play(Id.GOLDEN_RULE).finished
			LiarsDice.start_new_game(false)
		
		return {},
	
	Id.GAME_INSTRUCTIONS: func(args: Dictionary) -> Dictionary: 
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "I don't know a Buccaneer or a Corsair who doesn't!")
		await display.say(Dialogue.Actor.CAPTAIN, "Not to worry.")
		LiarsDice.start_new_game(true)
		await display.say(Dialogue.Actor.CAPTAIN, "We each have 5 dice.")
		LiarsDice.physical.pan_camera_to_cup()
		await display.say(Dialogue.Actor.CAPTAIN, "But ye only know the values of yer own.")
		LiarsDice.physical.pan_camera_to_npc(Dialogue.Actor.CAPTAIN)
		await display.say(Dialogue.Actor.CAPTAIN, "On ye turn, make a bet.")
		await display.say(Dialogue.Actor.CAPTAIN, "Bet how many of all the dice ye thinks share a certain value.")
		#await display.say(Dialogue.Actor.CAPTAIN, "The tricky part is yer bet includes all the dice.")
		await display.say(Dialogue.Actor.CAPTAIN, "Including the ones ye don't know.")
		await display.say(Dialogue.Actor.CAPTAIN, "I might bet 5 dices rolled six.")
		await display.say(Dialogue.Actor.CAPTAIN, "But, if ye might reckon there only be 4.")
		await display.say(Dialogue.Actor.CAPTAIN, "Ye could call me a [shake rate=20.0 level=5 connected=1]LIAR![/shake]...")
		await display.say(Dialogue.Actor.CAPTAIN, "An' then we'll settle who's right.")
		await display.say(Dialogue.Actor.CAPTAIN, "The only catch[set speed=5]...")
		await display.say(Dialogue.Actor.CAPTAIN, "Ye must always bet a bigger value than the last player.")
		await display.say(Dialogue.Actor.CAPTAIN, "Or more dice than the last player.")
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "And remember the [wave amp=20.0 freq=5.0 connected=1]Golden Rule[/wave].")
		await display.say(Dialogue.Actor.PIRATE_LEFT, "[set speed=20]The Captain [set pause_time=0.7]always [set pause_time=0.7]wins.")
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "[wave amp=20.0 freq=5.0 connected=1]Yo [set pause_time=0.4]ho [set pause_time=0.4]ho[/wave]") 
		display.clear_speach()
		LiarsDice.ready_for_game_start.emit()
		return {},
	
	Id.GOLDEN_RULE: func(args: Dictionary) -> Dictionary:
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Just remember the [wave amp=20.0 freq=5.0 connected=1]Golden Rule[/wave].")
		await display.say(Dialogue.Actor.PIRATE_LEFT, "[set speed=20]The Captain [set pause_time=0.7]always [set pause_time=0.7]wins.")
		
		if Progress.know_captain_secret:
			await display.say(Dialogue.Actor.CAPTAIN, "That's damn right.") ## SAY MY NAME (almost, kind of)
		else:
			await display.say(Dialogue.Actor.PIRATE_RIGHT, "[wave amp=20.0 freq=5.0 connected=1]Yo [set pause_time=0.4]ho [set pause_time=0.4]ho[/wave]") 
		
		display.clear_speach()
		return {},
	
	
	Id.PLEASE_TALK_BRO: func(args: Dictionary) -> Dictionary:
		Dialogue.is_betting_locked = true
		await display.say(Dialogue.Actor.CAPTAIN, "Ye be a quiet one, do ye got any tales to tell?")
		var result := await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["I'd prefer not to."])])
		await display.say(Dialogue.Actor.CAPTAIN, "Well atleast maybe ye can ask us some question then.")
		
		Dialogue.is_betting_locked = false
		return {},
	
	######################################1
	## PIRATE DIALOGUE
	######################################
	Id.PIRATE_NAME: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Anton Roberts...");
		Progress.know_pirate_name = true
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Though most just called me Snarling Roberts. ");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Proud bo's'n aboard the Scourge of Port Royal...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Till its very end.");
		display.clear_speach()
		return {},
	
	Id.PIRATE_NAME_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I earned the name 'cause I kept me crew in line...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "With a tongue sharp as me blade.");
		Progress.know_pirate_name_backstory = true
		display.clear_speach()
		return {},
	
	Id.PIRATE_DEATH_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "When I met my fate, I was bound for Davy Jones's locker.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "But Captain Reaver beckoned me to join his crew."); 
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Gave me a second chance, he did.");
		Progress.know_pirate_recruitment = true
		display.clear_speach()
		return {},
	
	Id.PIRATE_DEATH_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I wish I could say nobly. But our crew fell for greed.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "We was around Bellaforma, after some booty."); # do we wanna stick with Bellaforma as the island?
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Anchored down, and I, among a few, was left to the ship.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I hear call from above deck...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "A little boat from the lee side o' the island, guns a blazing."); 
		display.clear_speach()
		return {},
	
	Id.PIRATE_DEATH_3: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Nay. In the Quarters I was.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "A ruckus came from above,");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "And the stench of gunpowder filled the air.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Suddenly came footsteps...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Then a searing pain in my back...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "And a glint o' a [wave amp=20.0 freq=5.0 connected=1]golden cutlass[/wave] through my guts."); # glint, glimmer, flash or shine
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Wasn't much of a battle,");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "More an unfortuante turn o' events.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I never saw the freebooter who sent me to my watery grave."); # used to say "laid eyes on" nicer but too long
		Progress.know_pirate_death = true
		display.clear_speach()
		return {},
	
	Id.PIRATE_NOW: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Feels not much like a pirate life, if ye ask me.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "We be stuck on this cursed shore...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "no treasure or glory to claim.");
		Progress.know_pirate_now = true
		display.clear_speach()
		return {},
	
	Id.PIRATE_SECRET_FAIL: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		if LiarsDice.Player.PIRATE_RIGHT in LiarsDice.alive_players:
			await display.say(Dialogue.Actor.PIRATE_LEFT, "Nay...");
			await display.say(Dialogue.Actor.PIRATE_LEFT, "And I wont reveal any tricks around [wave amp=20.0 freq=5.0 connected=1]certain company[/wave] neither...");
		else:
			await Dialogue.play(Id.PIRATE_SECRET).finished
		display.clear_speach()
		return {},
	
	Id.PIRATE_SECRET: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Just between us...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I have me a set of loaded dice.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I always roll: 2, 4, 4, 5, 5");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I don't be takin' any chances no more.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Keep me flintlock close too, should trouble stir.");
		display.clear_speach()
		Progress.know_pirate_secret = true
		return {},
	
	Id.PIRATE_REVEAL: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		var dialogue_result := {}
		Dialogue.is_betting_locked = true
		await display.say(Dialogue.Actor.PIRATE_LEFT, "And what makes ye say that matey?");
		if Progress.know_pirate_death:
			var result := await display.push_options([OptionSet.new(Dialogue.Actor.PIRATE_LEFT, ["He has a golden cutlass."])]) # integrate "he be a cheat" here somewehre?
			await display.say(Dialogue.Actor.PIRATE_LEFT, "A golden cutlass[set speed=3]...");
			LiarsDice.physical.player_models[LiarsDice.Player.PIRATE_LEFT].turn_direction = 1
			await display.say(Dialogue.Actor.PIRATE_LEFT, "That true Shaw? Are ye the one?");
			LiarsDice.physical.player_models[LiarsDice.Player.PIRATE_RIGHT].turn_direction = -1
			await display.say(Dialogue.Actor.PIRATE_LEFT, "The coward who stormed an anchored boat...");
			await display.say(Dialogue.Actor.PIRATE_LEFT, "And drove a blade in me back?");
			await display.say(Dialogue.Actor.PIRATE_LEFT, "That puney crew... nay... they couldn't.");
			await display.say(Dialogue.Actor.PIRATE_LEFT, "Let me see yer sword, Elias."); 
			await display.say(Dialogue.Actor.PIRATE_RIGHT, "I don't know what this swab be blabberin' 'bout.");
			LiarsDice.physical.pirate_gun.state = Gun.State.DRAWN
			
			await display.say(Dialogue.Actor.PIRATE_LEFT, "DRAW YER SWORD NOW, YE SCURVY DOG!");
			await display.say(Dialogue.Actor.PIRATE_RIGHT, "Let's just calm down 'ere for a second.", false);
			await display.get_tree().create_timer(0.1).timeout
			display.clear_speach()
			LiarsDice.physical.pirate_shoot()
			LiarsDice.kill_npc(LiarsDice.Player.PIRATE_RIGHT)
			await display.get_tree().create_timer(1.0).timeout
			await display.say(Dialogue.Actor.CAPTAIN, "AVAST");
			LiarsDice.physical.pirate_gun.state = Gun.State.ON_TABLE
			await display.say(Dialogue.Actor.PIRATE_LEFT, "Sorry cap'n...");
			await display.say(Dialogue.Actor.CAPTAIN, "If I cant trust ye to not cause a fuss...");
			await display.say(Dialogue.Actor.CAPTAIN, "I'll be finishin' this meself, then.");
			await display.say(Dialogue.Actor.CAPTAIN, "OFF WITH YE!"); # we could possibly use gun here too
			LiarsDice.kill_npc(LiarsDice.Player.PIRATE_LEFT)
			dialogue_result.start_new_round = true
		else:
			Dialogue.is_betting_locked = false
			await display.push_options([OptionSet.new(Dialogue.Actor.PIRATE_LEFT, ["... trust me."])])
			await display.say(Dialogue.Actor.PIRATE_LEFT, "Ye be needin' more proof than that, me heartie.")
			await display.say(Dialogue.Actor.PIRATE_LEFT, "Yer just tryna district me from the game, ain't ye?")
		
		display.clear_speach()
		return dialogue_result,

	######################################
	## NAVY DIALOGUE
	######################################
	Id.NAVY_NAME: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Me name be Elias Shaw.");
		Progress.know_navy_name = true
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "A hand aboard The Skipping Hen.");
		display.clear_speach()
		return {},
	
	Id.NAVY_NOW_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Nay, I be sturdy as an anchor."); # not sure about this
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "It just be me roguish complexion that curses me now.");
		Progress.know_navy_sick = true
		display.clear_speach()
		return {},
	
	Id.NAVY_NOW_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Aye, we are... but not what we once were. ");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "We be bound by to this damned boat. ");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Thanks to Captin Reaver, we live...");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "But not truly.");
		Progress.know_navy_dead = true
		display.clear_speach()
		return {},
	
	Id.NAVY_SHIP: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "The Skipping Hen was a small ship, only 30 of us,");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "She was s'pose to be quick and unpredictable...");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Wasn't much of a ship in the end, barely held together. ");
		display.clear_speach()
		return {},
	
	Id.NAVY_SHIP_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Yar. The Skipping Hen... sunk in her second battle she was.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Not even a week after I joined the crew. ");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "But we didn't go down without a fight.");
		Progress.know_navy_ship = true
		display.clear_speach()
		return {},
	
	Id.NAVY_EVENT_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Me ship was sunk by the navy... ironic for me.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "We didn't stand a chance.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Already pushed our luck in her first scuffle.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "So rightfully, I met me end in the sea's embrace."); 
		Progress.know_navy_sink = true
		display.clear_speach()
		return {},
	
	Id.NAVY_IS_NAVY: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Arr, I sailed under the Royal Navy's flag.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "But I found it too constricting,");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "For a man of ambition like me.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "That is, they caught wind o' the rum I'd nicked from 'em.");
		Progress.know_navy_is_navy = true
		display.clear_speach()
		return {},
	
	Id.NAVY_SECRET_FAIL: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		if LiarsDice.Player.PIRATE_LEFT in LiarsDice.alive_players:
			await display.say(Dialogue.Actor.PIRATE_RIGHT, "I will say it was an infamous crew we plundered. ");
			await display.say(Dialogue.Actor.PIRATE_RIGHT, "Caught them offguard.");
			await display.say(Dialogue.Actor.PIRATE_RIGHT, "But I ain't gonna speak to who we sunk...");
			await display.say(Dialogue.Actor.PIRATE_RIGHT, "Some things are better left unsaid around [wave amp=20.0 freq=5.0 connected=1]certain company[/wave].");
		else:
			await Dialogue.play(Id.NAVY_SECRET).finished
		display.clear_speach()
		return {},
	
	Id.NAVY_SECRET: func(args: Dictionary) -> Dictionary: # Should this really be a part of the secret?
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Aye, fortunate buccaneers we were.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Ah our maiden voyage...");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "We spotted an anchored boat abouts Bellaforma..."); # add affect?
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Thrice the size o' our ship,");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "But with half their crew marooned on some wretched isle.");
		display.clear_speach()
		return {},
	
	Id.NAVY_SECRET_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "I boarded an' took 3 men myself,");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Plunged me [wave amp=20.0 freq=5.0 connected=1]golden cutlass[/wave] right through one of them's back."); # add affect?
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Yarr, we really sent the [shake rate=20.0 level=5 connected=1]Scourge o' Port Royal[/shake] to the depths."); # add affect?
		Progress.know_navy_secret = true
		display.clear_speach()
		return {},
	

	######################################
	## CAPTAIN DIALOGUE
	######################################
	Id.CAPTAIN_NAME: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "The name's Captain James Reaver.");
		await display.say(Dialogue.Actor.CAPTAIN, "Glad to have a new swashbuckler at the table.");
		Progress.know_captain_name = true
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_KNOW_SECRET: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "The question be whether I'm willin' to share it, matey.");
		await display.say(Dialogue.Actor.CAPTAIN, "Let's let such such matters rest 'til after our game");
		await display.say(Dialogue.Actor.CAPTAIN, "Okay?");
		Progress.asked_captain_about_secret = true
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_SHIP: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "The Siren's Wake... arr, she were a legend.");
		await display.say(Dialogue.Actor.CAPTAIN, "A ship feared 'cross all the seas. ");
		await display.say(Dialogue.Actor.CAPTAIN, "Nearly 200 men strong...");
		await display.say(Dialogue.Actor.CAPTAIN, "Cut through the water like a blade through flesh.");
		Progress.know_captain_ship = true
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_SHIP_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "I captained The Siren's Wake from the very start.");
		await display.say(Dialogue.Actor.CAPTAIN, "In her swan song, I took a deal,");
		await display.say(Dialogue.Actor.CAPTAIN, "I gave me life to keep her wreck and a fine crew.");
		Progress.know_captain_past = true
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_CREW: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "The rest o' my crew be here,");
		await display.say(Dialogue.Actor.CAPTAIN, "Same as us, roaming these decks.");
		await display.say(Dialogue.Actor.CAPTAIN, "These two scallywags joined me to pass the time.");
		Progress.know_captain_crew = true
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_NOW: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "I wouldn't call it a curse.");
		await display.say(Dialogue.Actor.CAPTAIN, "Me ship's me home again.");
		await display.say(Dialogue.Actor.CAPTAIN, "An' any pirate who meets the ocean floor,"); 
		await display.say(Dialogue.Actor.CAPTAIN, "May find a place among me crew."); 
		Progress.know_captain_now = true
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_REVEAL: func(args: Dictionary) -> Dictionary:
		
		await display.say(Dialogue.Actor.CAPTAIN, "Victory be mine again.")
		await display.say(Dialogue.Actor.CAPTAIN, "I s'pose there ain't no need fer the ruse.")
		await display.say(Dialogue.Actor.CAPTAIN, "It is I[set pause_timer=0.5], who be sendin ye back in time to play again.")
		await display.say(Dialogue.Actor.CAPTAIN, "Every time ye 'die', a bit more wind fills me sails.")
		await display.say(Dialogue.Actor.CAPTAIN, "So a few extra rounds don't hurt.")
		await display.say(Dialogue.Actor.CAPTAIN, "An' I must confess...")
		await display.say(Dialogue.Actor.CAPTAIN, "There be no secret to eternal life fer the likes o' ye.")
		await display.say(Dialogue.Actor.CAPTAIN, "Pretty soon ye'll be like the rest of us.")
		await display.say(Dialogue.Actor.CAPTAIN, "The only thing immortal be yer service to this crew.") # calls into question validity of other crewmates free will?
		
		LiarsDice.physical.is_captain_gun_drawn = true
		
		await display.say(Dialogue.Actor.CAPTAIN, "I'll see ye next round...")
		
		Progress.know_captain_secret = true
		
		return {},
	
	Id.CAPTAIN_ESCAPE: func(args: Dictionary) -> Dictionary:
		
		Dialogue.is_betting_locked = true
		await display.say(Dialogue.Actor.CAPTAIN, "There be no leaving now, me heartie.") # I wanna use a boat direction term somewhere
		LiarsDice.physical.is_captain_gun_drawn = true
		await display.say(Dialogue.Actor.CAPTAIN, "The game's already begun.")
		
		
		var result := await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["Fine"])])
		await display.say(Dialogue.Actor.CAPTAIN, "That's the spirit.")
		LiarsDice.physical.is_captain_gun_drawn = false
		await display.say(Dialogue.Actor.CAPTAIN, "Now make your bet.")
		display.clear_speach()
		Progress.know_captain_captive = true
		Dialogue.is_betting_locked = false
		return {},
	
	#####################################################
	
	Id.NO_LOOK: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "Bold that ye don't even look at yer dice.")
		await display.say(Dialogue.Actor.CAPTAIN, "To each there own I guess...")
		display.clear_speach()
		return {},
	
	Id.QUIET: func(args: Dictionary) -> Dictionary:
		#display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "Not one for small talk, are ye?")
		await display.say(Dialogue.Actor.CAPTAIN, "Why not entertain us a bit?")
		display.clear_speach()
		return {},
	
	Id.FIRST_BET: func(args: Dictionary) -> Dictionary:
		await display.say(args.actor, "Ye think I would lie this quick?")
		await display.say(args.actor, "I'll give ye a second chance to change yer mind.")
		display.clear_speach()
		return {"do_second_chance": true},
		
	Id.ACCUSING: func(args: Dictionary) -> Dictionary:
		var i := ACCUSING_i
		while i == ACCUSING_i: i = randi_range(0, 4)
		ACCUSING_i = i
		match i:
			0:
				await display.say(args.actor, "Ye call me a liar?")
			1:
				await display.say(args.actor, "Ye not trust my claim?")
			2:
				await display.say(args.actor, "Let's let the dice decide.")
			3:
				await display.say(args.actor, "Best ye not test me matey.")
			4:
				await display.say(args.actor, "Liar, am I?")
		
		display.clear_speach()
		
		return {},
		
	Id.ACCUSED: func(args: Dictionary) -> Dictionary:
		# display.clear_speach() #perhaps?
		# display.clear_options() #perhaps?
		
		var i := ACCUSED_i
		while i == ACCUSED_i: i = randi_range(0, 5)
		ACCUSED_i = i
		match i:
			0:
				await display.say(args.actor, Dialogue.get_bet_string(args.bet) + "? I don't trust yer claim, me heartie.")
			1:
				await display.say(args.actor, Dialogue.get_bet_string(args.bet) + "? I'm afraid ye be a liar...")
			2:
				await display.say(args.actor, Dialogue.get_bet_string(args.bet) + "? I think we be needin' to test that claim.")
			3:
				await display.say(args.actor, Dialogue.get_bet_string(args.bet) + "? Ye be full o' lies!")
			4:
				await display.say(args.actor, Dialogue.get_bet_string(args.bet) + "? Yer tongue's twisted as a sailor's knot!")
			5:
				await display.say(args.actor, "LIAR!")
		
		display.clear_speach()
		
		return {},
		
	Id.PLAYER_RESULTS_SUCCESS: func(args: Dictionary) -> Dictionary:
		var i := PLAYER_RESULTS_SUCCESS_i
		while i == PLAYER_RESULTS_SUCCESS_i: i = randi_range(0, 3)
		PLAYER_RESULTS_SUCCESS_i = i
		match i:
			0:
				await display.say(args.actor, "Shiver me timbers!")
			1:
				await display.say(args.actor, "Ye be lucky this time, buccaneer.")
			2:
				await display.say(args.actor, "I should've been more trustin' o' a picaroon like yerself")
			3:
				await display.say(args.actor, "Lady luck is on ye side, it seems.")
		
		display.clear_speach()
		
		return {},
		
	Id.PLAYER_RESULTS_FAILURE: func(args: Dictionary) -> Dictionary:
		var i := PLAYER_RESULTS_FAILURE_i
		while i == PLAYER_RESULTS_FAILURE_i: i = randi_range(0, 5)
		PLAYER_RESULTS_FAILURE_i = i
		match i:
			0:
				await display.say(args.actor, "Gotcha!")
			1:
				await display.say(args.actor, "It's time ye walk the plank.")
			2:
				await display.say(args.actor, "Ye be lying, ye sneaky scoundrel.")
			3:
				await display.say(args.actor, "I could spot that lie from the crow's nest.")
			4:
				await display.say(args.actor, "No suprise there.")
			5:
				await display.say(args.actor, "I caught ye lying through yer teeth.")
		
		display.clear_speach()
		
		return {},
	
	Id.NPC_RESULTS_SUCCESS: func(args: Dictionary) -> Dictionary:
		var i := NPC_RESULTS_SUCCESS_i
		while i == NPC_RESULTS_SUCCESS_i: i = randi_range(0, 3)
		NPC_RESULTS_SUCCESS_i = i
		match i:
			0:
				await display.say(args.actor, "The truth be in the dice!")
			1:
				await display.say(args.actor, "Seems fate favours me.")
			2:
				await display.say(args.actor, "There ye have it.")
			3:
				await display.say(args.actor, "The dice tell no lies.")
		
		display.clear_speach()
		
		return {},
	
	Id.NPC_RESULTS_FAILURE: func(args: Dictionary) -> Dictionary:
		var i := NPC_RESULTS_FAILURE_i
		while i == NPC_RESULTS_FAILURE_i: i = randi_range(0, 3)
		NPC_RESULTS_FAILURE_i = i
		match i:
			0:
				await display.say(args.actor, "So close!")
			1:
				await display.say(args.actor, "I almost snuck by ye.")
			2:
				await display.say(args.actor, "Arrgh!")
			3:
				await display.say(args.actor, "That be the way of the sea.")
		
		display.clear_speach()
		
		return {},
	
	Id.BACK_TO_GAME: func(args: Dictionary, last_speaking_actor) -> Dictionary:
		await display.say(last_speaking_actor, "But enough 'bout me. Time to make yer bet.")
		return {},
	
	Id.LIAR: func(args: Dictionary) -> Dictionary:
		await Dialogue.get_tree().create_timer(0.1).timeout
		return { "called": true },
	
	Id.PASS: func(args: Dictionary) -> Dictionary:
		await Dialogue.get_tree().create_timer(0.1).timeout
		return { "called": false },
}


func _init(p_id: Id, p_display: DialogueDisplay, p_args := {}) -> void:
	display = p_display
	my_id = p_id
	arguments = p_args


func play() -> void:
	assert(not is_playing)
	is_playing = true
	var result : Dictionary = await dialogues[my_id].call(arguments)
	Dialogue.mark_completed(my_id)
	finished.emit(result)
	call_deferred("free")


func end() -> void:
	finished.emit({})
	call_deferred("free")



func get_npc_dialogue_options(actor: Dialogue.Actor, is_better: bool) -> Array[Id]:
	var result : Array[Id] = []
	if is_better:
		result.append(Id.LIAR)
	
	var possible_options : Array = {
		Dialogue.Actor.PIRATE_LEFT: 	[Id.PIRATE_NAME, Id.PIRATE_NAME_2, Id.PIRATE_DEATH_1, Id.PIRATE_DEATH_2, Id.PIRATE_DEATH_3, Id.PIRATE_NOW, Id.PIRATE_SECRET_FAIL, Id.PIRATE_SECRET, Id.PIRATE_REVEAL],
		Dialogue.Actor.PIRATE_RIGHT: 	[Id.NAVY_NAME, Id.NAVY_NOW_1, Id.NAVY_NOW_2, Id.NAVY_SHIP, Id.NAVY_SHIP_2, Id.NAVY_EVENT_1, Id.NAVY_IS_NAVY, Id.NAVY_SECRET_FAIL, Id.NAVY_SECRET, Id.NAVY_SECRET_2,],
		Dialogue.Actor.CAPTAIN: 		[Id.CAPTAIN_ESCAPE, Id.CAPTAIN_NAME, Id.CAPTAIN_KNOW_SECRET, Id.CAPTAIN_SHIP, Id.CAPTAIN_SHIP_2, Id.CAPTAIN_CREW, Id.CAPTAIN_NOW,],
	}[actor]
	
	for id: Id in possible_options:
		if can_give_option(id):
			result.append(id)

	if result.size() <= 1 and is_better:
		result.append(Id.PASS)
	
	result.resize(min(result.size(), Dialogue.MAX_OPTIONS))

	return result


func can_give_option(id: Id) -> bool:
	if Dialogue.is_completed(id):
		return false
	
	match id:
		Id.PIRATE_NAME: 		return not Progress.know_pirate_name # should be not know_pirate_name_backstory
		Id.PIRATE_NAME_2: 		return not Progress.know_pirate_name_backstory and Progress.know_pirate_name # follow up # I think this will cause issues since PIRATE_NAME has a unique progress tag
		Id.PIRATE_DEATH_1: 		return not Progress.know_pirate_recruitment and Progress.know_pirate_name
		Id.PIRATE_DEATH_2: 		return Progress.know_pirate_recruitment and not Progress.know_pirate_death
		Id.PIRATE_DEATH_3: 		return Dialogue.is_completed(Id.PIRATE_DEATH_2) and not Progress.know_pirate_death # follow up
		Id.PIRATE_NOW: 			return	not Progress.know_pirate_now and Progress.know_pirate_recruitment
		Id.PIRATE_SECRET_FAIL: 	return	not Progress.know_pirate_secret and Progress.know_pirate_name and Progress.know_pirate_recruitment
		Id.PIRATE_SECRET: 		return	not Progress.know_pirate_secret and Progress.know_pirate_name and Progress.know_pirate_recruitment and LiarsDice.is_out(LiarsDice.Player.PIRATE_RIGHT) and Dialogue.is_completed(Id.PIRATE_SECRET_FAIL)
		Id.PIRATE_REVEAL:		return Progress.know_captain_secret and Progress.know_navy_secret and not LiarsDice.is_out(LiarsDice.Player.PIRATE_RIGHT) and Progress.know_pirate_death # Added so we need to know both sides # do we also need to know pirate secret, he keeps a gun on him? Why do we NEED to know captain secret. means we have to get to 1v1 once before we can cause the fight! We also need to hear about his death
		
		Id.NAVY_NAME: 			return	not Progress.know_navy_name
		Id.NAVY_NOW_1: 			return	not Progress.know_navy_sick and Progress.know_navy_name
		Id.NAVY_NOW_2: 			return	not Progress.know_navy_dead 
		Id.NAVY_SHIP: 			return	not Progress.know_navy_ship and Progress.know_navy_name
		Id.NAVY_SHIP_2: 		return	not Progress.know_navy_ship and Dialogue.is_completed(Id.NAVY_SHIP) # follow up
		Id.NAVY_EVENT_1: 		return	not Progress.know_navy_sink and Progress.know_navy_ship
		Id.NAVY_IS_NAVY: 		return	not Progress.know_navy_is_navy and Progress.know_navy_sink
		Id.NAVY_SECRET_FAIL: 	return	Progress.know_navy_ship
		Id.NAVY_SECRET: 		return	Progress.know_navy_ship and LiarsDice.is_out(LiarsDice.Player.PIRATE_LEFT) and Dialogue.is_completed(Id.NAVY_SECRET_FAIL)
		Id.NAVY_SECRET_2: 		return	Dialogue.is_completed(Id.NAVY_SECRET)
		
		Id.CAPTAIN_NAME: 		return	not Progress.know_captain_secret and not Progress.know_captain_name
		Id.CAPTAIN_KNOW_SECRET: return	not Progress.know_captain_secret and not Progress.asked_captain_about_secret and Progress.know_captain_name
		Id.CAPTAIN_SHIP: 		return	not Progress.know_captain_secret and not Progress.know_captain_ship and Progress.know_captain_name
		Id.CAPTAIN_SHIP_2: 		return	not Progress.know_captain_secret and Progress.know_captain_ship and not Progress.know_captain_past
		Id.CAPTAIN_CREW: 		return	not Progress.know_captain_secret and not Progress.know_captain_crew and Progress.know_captain_name
		Id.CAPTAIN_NOW: 		return	not Progress.know_captain_secret and not Progress.know_captain_now and Progress.know_captain_name 
		Id.CAPTAIN_ESCAPE: 		return	Progress.know_captain_secret and not Progress.know_captain_captive # do we need to make sure its also the next round?  double checl memclean. should be fine - ahren
	return true


func get_dialogue_option_lead(id: Id) -> String:
	match id:
		Id.PIRATE_REVEAL:		return "Shaw killed ye."
		Id.PIRATE_NAME: 		return "What be yer name?"
		Id.PIRATE_NAME_2: 		return "Why 'Snarling'?"
		Id.PIRATE_DEATH_1: 		return "Do ye call this home?"
		Id.PIRATE_DEATH_2: 		return "How'd ye meet yer fate?"
		Id.PIRATE_DEATH_3: 		return "So ye died in battle?"
		Id.PIRATE_NOW: 			return "Is this a fine crew?"
		Id.PIRATE_SECRET_FAIL: 	return "Do ye have a tell?"
		Id.PIRATE_SECRET: 		return "So.. yer trick?"
		
		Id.NAVY_NAME: 			return "What shall I call ye?"
		Id.NAVY_NOW_1: 			return "Ye look sick"
		Id.NAVY_NOW_2: 			return "Ye still flesh n' bone?"
		Id.NAVY_SHIP: 			return "Tell me 'bout yer ship." # rephrase memclean
		Id.NAVY_SHIP_2: 		return "Did ye sink?"
		Id.NAVY_EVENT_1: 		return "So how'd ye sink?"
		Id.NAVY_IS_NAVY: 		return "Ye be a Navy man?"
		Id.NAVY_SECRET_FAIL: 	return "So yer first battle?"
		Id.NAVY_SECRET: 		return "So... yer first clash."
		Id.NAVY_SECRET_2: 		return "Ye sunk a Galleon?" # this one is iffy
		
		Id.CAPTAIN_NAME: 		return "Ye be the Captain?"
		Id.CAPTAIN_KNOW_SECRET: return "So... the secret?"
		Id.CAPTAIN_SHIP: 		return "Tell me 'bout yer ship."
		Id.CAPTAIN_SHIP_2: 		return "How'd ye become captain?"
		Id.CAPTAIN_CREW: 		return "Is this yer whole crew?"
		Id.CAPTAIN_NOW: 		return "Are ye cursed?"
		Id.CAPTAIN_ESCAPE:		return "Let me go, ye knave!"
		
		Id.PASS: 				return "Pass"
		Id.LIAR:				return "LIAR!"
	
	assert(false, "Missing dialogue lead")
	return ""


class OptionSet:
	var actor : Dialogue.Actor
	var options : Array
	
	func _init(p_actor: Dialogue.Actor, p_options: Array) -> void:
		actor = p_actor
		assert(options.size() <= Dialogue.MAX_OPTIONS)
		options = p_options

class OptionResult:
	var actor : Dialogue.Actor
	var index : int
	
	func _init(p_actor: Dialogue.Actor, p_index: int) -> void:
		actor = p_actor
		index = p_index
