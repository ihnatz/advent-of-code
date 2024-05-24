import string

content = open("input.txt").read()

DIRS = ((0, 1), (-1, 0), (0, -1), (1, 0))

def find_start(grid):
    return (grid[0].index("|"), 0)

def in_grid(grid, x, y):
    return 0 <= y < len(grid) and 0 <= x < len(grid[y])

def deadend(grid, fx, fy, x, y):
    return [(fx, fy)] == [
        (x + dx, y + dy)
        for dx, dy in DIRS
        if in_grid(grid, x + dx, y + dy) and not grid[y + dy][x + dx].isspace()
    ]

grid = [list(row) for row in content.split("\n")]
x, y = find_start(grid)
fx, fy = -1, -1
current_dir = 0
path = ""

while not deadend(grid, fx, fy, x, y):
    if grid[y][x] == "+":
        current_dir = (current_dir + 1) % 4
    dx, dy = DIRS[current_dir]
    nx, ny = x + dx, y + dy
    if (fx, fy) != (nx, ny) and in_grid(grid, nx, ny) and not grid[ny][nx].isspace():
        fx, fy = x, y
        x, y = nx, ny
        path += grid[ny][nx]

print("".join(filter(str.isalpha, path)))
print(len(path))
