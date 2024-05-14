def evaluate_tree(expression)
  return expression unless expression.is_a?(Array)
  expression.map! { _1.is_a?(Array) ? evaluate_tree(_1) : _1 }
  return expression[0] if expression.one?

  calculate_expression(*expression)
end

def operation_to_postfix(tree, operator)
  return tree unless tree.is_a?(Array)
  tree.map! { _1.is_a?(Array) ? operation_to_postfix(_1, operator) : _1 }

  tree
    .map.with_index { _2 if operator == _1 }
    .compact
    .reverse
    .each do |idx|
      operand1, operator, operand2 = tree.slice!(idx - 1..idx + 1)
      tree.insert(idx - 1, [operator, operand1, operand2])
    end
  tree
end

def evaluate_direct(expression)
  return expression unless expression.is_a?(Array)
  expression.map! { _1.is_a?(Array) ? evaluate_direct(_1) : _1 }

  command = nil
  stack = [expression[0]]

  expression.drop(1).each do |token|
    case token
    when Numeric then stack.push(calculate_expression(command, stack.pop, token))
    when String then command = token
    else raise "Unknown token #{token}"
    end
  end

  stack.first
end

def calculate_expression(operator, operand1, operand2)
  case operator
  when "*" then operand1 * operand2
  when "+" then operand1 + operand2
  else raise "Unknown operator #{operator}"
  end
end

def parse_parentheses(tokens)
  stack = []
  tokens.reduce([]) do |result, token|
    case token
      when "(" then stack.push(result); []
      when ")" then stack.pop << result
      else result << token
    end
  end
end

def parse_expression(example)
  example
    .chars
    .reject { _1 == " " }
    .map { _1.match?(/\d+/) ? _1.to_i : _1 }
end

def calculate1(example)
  parse_expression(example)
    .then { parse_parentheses(_1) }
    .then { evaluate_direct(_1) }
end

def calculate2(example)
  parse_expression(example)
    .then { parse_parentheses(_1) }
    .then { operation_to_postfix(_1, "+") }
    .then { operation_to_postfix(_1, "*") }
    .then { evaluate_tree(_1) }
end

examples = File.read("input.txt").split("\n")
puzzle1 = examples.map { calculate1(_1) }.sum
puzzle2 = examples.map { calculate2(_1) }.sum
p [puzzle1, puzzle2]
