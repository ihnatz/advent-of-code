# /// script
# dependencies = [
#   "ortools>=9.14.6206"
# ]
# ///


from ortools.sat.python import cp_model

class SolutionCollector(cp_model.CpSolverSolutionCallback):
    def __init__(self, button_vars):
        super().__init__()
        self.button_vars = button_vars
        self.total_presses = 0

    def on_solution_callback(self):
        self.total_presses = sum(self.value(var) for var in self.button_vars)


def solve_button_puzzle(buttons, targets):
    model = cp_model.CpModel()
    solver = cp_model.CpSolver()

    button_vars = [
        model.new_int_var(0, 300, f"button_{i}")
        for i in range(len(buttons))
    ]

    for target_idx, target_value in enumerate(targets):
        relevant_buttons = [
            button_vars[btn_idx]
            for btn_idx, button in enumerate(buttons)
            if target_idx in button
        ]
        model.add(sum(relevant_buttons) == target_value)

    model.minimize(sum(button_vars))

    callback = SolutionCollector(button_vars)
    solver.solve(model, solution_callback=callback)

    return callback.total_presses


def parse_puzzle_line(line):
    parts = line.split()

    initial_state = [1 if c == "#" else 0 for c in parts[0][1:-1]]
    targets = [int(val) for val in parts[-1][1:-1].split(",")]
    buttons = [
        [int(pos) for pos in button[1:-1].split(",")]
        for button in parts[1:-1]
    ]

    return initial_state, targets, buttons


input = open("src/input.txt").read().strip()

total_presses = 0
for line in input.split("\n"):
    initial_state, targets, buttons = parse_puzzle_line(line)
    total_presses += solve_button_puzzle(buttons, targets)

print("Part2:", total_presses)
