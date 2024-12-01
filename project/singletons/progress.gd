extends Node







## PERMANTENT PROGRESS
var player_death_count := 0
var player_death_count_since_know_captain_secret := 0
var has_player_looked_at_cup := false
var has_player_done_optional_dialogue := false
var has_player_called_liar := false

var know_pirate_name := false
var know_pirate_recruitment := false
var know_pirate_death := false
var know_pirate_now := false
var know_pirate_name_backstory := false
var know_pirate_secret := false

var know_navy_name := false
var know_navy_sick := false
var know_navy_dead := false
var know_navy_ship := false
var know_navy_sink := false
var know_navy_is_navy := false
var know_navy_secret := false

var asked_captain_about_secret := false
var know_captain_name := false
var know_captain_ship := false
var know_captain_past := false
var know_captain_crew := false
var know_captain_now := false
var know_captain_secret := false
var know_captain_captive := false


func _process(delta: float) -> void:
	if Debug.is_just_pressed("test_3"):
		know_pirate_name = true
		know_pirate_recruitment = true
		know_pirate_death = true
		know_pirate_now = true
		know_pirate_name_backstory = true
		know_pirate_secret = true
		
		know_navy_name = true
		know_navy_sick = true
		know_navy_dead = true
		know_navy_ship = true
		know_navy_sink = true
		know_navy_is_navy = true
		know_navy_secret = true
		
		asked_captain_about_secret = true
		know_captain_name = true
		know_captain_ship = true
		know_captain_past = true
		know_captain_crew = true
		know_captain_now = true
		know_captain_secret = true
	
	if Debug.is_just_pressed("test_4"):
		know_pirate_name = true
		know_pirate_recruitment = true
		know_pirate_death = true
		know_pirate_now = true
		know_pirate_name_backstory = true
		#know_pirate_secret = true
		
		know_navy_name = true
		know_navy_ship = true
		know_navy_sink = true
		know_navy_is_navy = true
		know_navy_secret = true
		
		asked_captain_about_secret = true
		know_captain_name = true
		know_captain_ship = true
		know_captain_crew = true
		know_captain_now = true
		know_captain_secret = true
		
		player_death_count = 2
