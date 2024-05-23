FACTOR_A, FACTOR_B = 16807, 48271
PRIME = 2147483647
START_A, START_B = 591, 393

def gen(start, factor):
    val = start
    while True:
        val = (val * factor) % PRIME
        yield val

def gen_a(): return gen(START_A, FACTOR_A)
def gen_b(): return gen(START_B, FACTOR_B)

def filtered(generator, multiplier):
    return (n for n in generator if n % multiplier == 0)

mask = 2**16 - 1
print(sum(val_a & mask == val_b & mask
        for val_a, val_b, _ in zip(gen_a(), gen_b(), range(40_000_000))))

print(sum(val_a & mask == val_b & mask
        for val_a, val_b, _ in zip(filtered(gen_a(), 4), filtered(gen_b(), 8), range(5_000_000))))
