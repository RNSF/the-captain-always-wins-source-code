class_name MathUtils


static func sumi(a: int, b: int) -> int:
	return a + b

# inclusive on both sides
static func in_range_ii(a: float, min: float, max: float) -> bool:
	return a >= min and a <= max

# inclusive on min, exclusive on max
static func in_range_ie(a: float, min: float, max: float) -> bool:
	return a >= min and a < max

static func factorial(n: int) -> int:
	assert(n >= 0)
	if n == 0:
		return 1
	else:
		return n * factorial(n-1)


static func is_percent(p: float) -> bool:
	return p >= 0.0 and p <= 1.0


static func choose(n: int, k: int) -> int:
	assert(n >= k)
	return factorial(n) / (factorial(k) * factorial(n-k))

static func binomial_probability(k: int, n: int, p: float) -> float:
	assert(is_percent(p))
	assert(n >= k)
	return choose(n, k) * pow(p, k) * pow(1 - p, n - k)
