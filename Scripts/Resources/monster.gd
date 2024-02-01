class_name Monster
extends Resource

@export var name : String
################################## Base Stats ##################################
@export_group("Base Stats")
@export_enum("Basic", "Fire", "Water", "Ice", "Earth", "Wind") var element : String = "Basic"
@export var walk_speed : float = 50.0
@export var run_speed : float = 85.0
@export var base_hp : int = 10
# Belly is effectively "ammo" - keep the monster fed to use its ability to shoot
@export var belly_size : float = 100.0
################################## Attack Info #################################
@export_group("Attack Info")
# Most monsters probably have projectile instead of melee attack...
@export var is_melee : bool = false
@export var base_damage : int = 1
# This represents the number of projectiles per shot
@export var projectile_number : int = 1.0
@export var projectile_speed : float = 70.0
@export var projectile_speed_gain : float = 0.0 # Negative if projectile slows while midair
@export var projectile_range : float = 300.0
@export var projectile_size : float = 1.0
@export var shot_cooldown : float = 0.6
### These are flags that tell the base projectile/attack how to behave
@export_subgroup("Special Traits")
@export var following_projectiles : bool = false
@export_range(0, 1, 0.01) var follow_strength : float = 0.0
@export var can_crit : bool = true
@export_range(0, 100, 0.1) var crit_chance : float = 5.0
@export var crit_multipler : float = 2.0
@export var ignore_resistances : bool = false
@export var always_supereffective : bool = false
@export var has_end_of_move_effect : bool = false
@export var end_of_move_effect : String
@export var has_unique_trait : bool = false
@export var unique_trait : String
