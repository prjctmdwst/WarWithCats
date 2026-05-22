## SeedManager.gd
## Autoload singleton. Balatro-style seeded RNG.
## All randomness in the game goes through this — given the same seed,
## a full run is 100% reproducible.

extends Node

# ── Public state ───────────────────────────────────────────────────────────
var current_seed: int = 0
var seed_string: String = ""     # Human-readable e.g. "PAWSOME"
var run_rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Sub-RNGs for different systems (so deck shuffle doesn't affect enemy rolls)
var _deck_rng:    RandomNumberGenerator = RandomNumberGenerator.new()
var _enemy_rng:   RandomNumberGenerator = RandomNumberGenerator.new()
var _upgrade_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _event_rng:   RandomNumberGenerator = RandomNumberGenerator.new()

# ── Seed generation ────────────────────────────────────────────────────────
const SEED_WORDS = [
	"PAWS", "MEOW", "HISS", "PURR", "CLAW", "FLOOF", "MRRP", "BOOP",
	"ZOOMIES", "SNOOT", "BISCUIT", "TABBY", "CALICO", "TUXEDO", "MAINE",
	"RAGDOLL", "SIAMESE", "BENGAL", "MUNCHKIN", "SPHINX", "NYAN", "CATTE",
	"WHISKER", "FELINE", "KITTEN", "TOMCAT", "QUEEN", "CATBOX", "SCRUFF",
	"YOWL", "CHIRP", "TRILL", "KNEAD", "LOAF", "SPLOOT"
]

func generate_random_seed() -> String:
	randomize()
	var word1 = SEED_WORDS[randi() % SEED_WORDS.size()]
	var word2 = SEED_WORDS[randi() % SEED_WORDS.size()]
	var num = randi() % 9000 + 1000
	return "%s%s%d" % [word1, word2, num]

func set_seed_from_string(s: String) -> void:
	seed_string = s.strip_edges().to_upper()
	# Hash the string to an int
	current_seed = hash(seed_string)
	_init_rngs()

func set_random_seed() -> void:
	seed_string = generate_random_seed()
	current_seed = hash(seed_string)
	_init_rngs()

func _init_rngs() -> void:
	run_rng.seed    = current_seed
	_deck_rng.seed  = current_seed ^ 0xDEADCAFE
	_enemy_rng.seed = current_seed ^ 0xCAFEBABE
	_upgrade_rng.seed = current_seed ^ 0xBEEFCATZ
	_event_rng.seed = current_seed ^ 0xF00DFEED

# ── RNG access (use these instead of randi/randf globally) ──────────────────
func deck_randi() -> int:
	return _deck_rng.randi()

func deck_randi_range(lo: int, hi: int) -> int:
	return _deck_rng.randi_range(lo, hi)

func deck_randf() -> float:
	return _deck_rng.randf()

func enemy_randi() -> int:
	return _enemy_rng.randi()

func enemy_randi_range(lo: int, hi: int) -> int:
	return _enemy_rng.randi_range(lo, hi)

func enemy_randf() -> float:
	return _enemy_rng.randf()

func upgrade_randi() -> int:
	return _upgrade_rng.randi()

func upgrade_randf() -> float:
	return _upgrade_rng.randf()

func event_randi() -> int:
	return _event_rng.randi()

func shuffle_array(arr: Array) -> Array:
	# Fisher-Yates using deck_rng
	var a = arr.duplicate()
	for i in range(a.size() - 1, 0, -1):
		var j = _deck_rng.randi_range(0, i)
		var tmp = a[i]
		a[i] = a[j]
		a[j] = tmp
	return a
