def lex(src)
  src.gsub!("(", " ( ")
  src.gsub!(")", " ) ")
  return src.split(" ")
end

def test_lex()
  tests = [
    { src: "(+ 1 2)", exp: ["(", "+", "1", "2", ")"] },
    { src: "(- 1 2)", exp: ["(", "-", "1", "2", ")"] },
    { src: "(* 1 2)", exp: ["(", "*", "1", "2", ")"] },
    { src: "(/ 1 2)", exp: ["(", "/", "1", "2", ")"] },
    { src: "(+ 10 2)", exp: ["(", "+", "10", "2", ")"] },
    { src: "(+ -10 2)", exp: ["(", "+", "-10", "2", ")"] },
    { src: "(+ -10 252)", exp: ["(", "+", "-10", "252", ")"] },
    { src: "(*  1 (+ 2 3))", exp: ["(", "*", "1", "(", "+", "2", "3", ")", ")"] },
    { src: "(setq a 2)", exp: ["(", "setq", "a", "2", ")"] },
    { src: "(+ a 2)", exp: ["(", "+", "a", "2", ")"] },
    { src: "(if 0 1 2)", exp: ["(", "if", "0", "1", "2", ")"] },
    { src: "(while i (setq i (- i 1)))", exp: ["(", "while", "i", "(", "setq", "i", "(", "-", "i", "1", ")", ")", ")"] },
    { src: "(print a 2)", exp: ["(", "print", "a", "2", ")"] },
    { src: "(do (setq i 0) (+ i 1))", exp: ["(", "do", "(", "setq", "i", "0", ")", "(", "+", "i", "1", ")", ")"] },
    { src: "(+= a 2)", exp: ["(", "+=", "a", "2", ")"] },
    { src: "(-= a 2)", exp: ["(", "-=", "a", "2", ")"] },
    { src: "(< a 2)", exp: ["(", "<", "a", "2", ")"] },
    { src: "(> a 2)", exp: ["(", ">", "a", "2", ")"] },
    { src: "(<= a 2)", exp: ["(", "<=", "a", "2", ")"] },
    { src: "(>= a 2)", exp: ["(", ">=", "a", "2", ")"] },
    { src: "(defun hoge () (print 100))", exp: ["(", "defun", "hoge", "(", ")", "(", "print", "100", ")", ")"] },
  ]

  for t in tests
    act = lex t[:src]
    if act != t[:exp]
      puts "want #{t[:exp]} but got #{act}"
    end
  end
end

test_lex

def parse(tokens)
  ast = []

  symbol = tokens.shift
  if symbol != "("
    puts "err: expect left paren"
    return ast
  end

  while true
    symbol = tokens.shift
    case symbol
    when ")"
      break
    when "("
      tokens.unshift "("
      ast.push(parse tokens)
    else
      ast.push(symbol)
    end
  end

  return ast
end

def test_parse()
  tests = [
    { src: "(+ 1 2)", exp: ["+", "1", "2"] },
    { src: "(- 1 2)", exp: ["-", "1", "2"] },
    { src: "(* 1 2)", exp: ["*", "1", "2"] },
    { src: "(/ 1 2)", exp: ["/", "1", "2"] },
    { src: "(+ 10 2)", exp: ["+", "10", "2"] },
    { src: "(+ -10 2)", exp: ["+", "-10", "2"] },
    { src: "(+ -10 252)", exp: ["+", "-10", "252"] },
    { src: "(*  1 (+ 2 3))", exp: ["*", "1", ["+", "2", "3"]] },
    { src: "(*  (+ 3 2) (- 13 4))", exp: ["*", ["+", "3", "2"], ["-", "13", "4"]] },
    { src: "(setq a 2)", exp: ["setq", "a", "2"] },
    { src: "(+ a 2)", exp: ["+", "a", "2"] },
    { src: "(if 0 1 2)", exp: ["if", "0", "1", "2"] },
    { src: "(while i (setq i (- i 1)))", exp: ["while", "i", ["setq", "i", ["-", "i", "1"]]] },
    { src: "(print a 2)", exp: ["print", "a", "2"] },
    { src: "(do (setq i 0) (+ i 1))", exp: ["do", ["setq", "i", "0"], ["+", "i", "1"]] },
    { src: "(+= a 2)", exp: ["+=", "a", "2"] },
    { src: "(-= a 2)", exp: ["-=", "a", "2"] },
    { src: "(< a 2)", exp: ["<", "a", "2"] },
    { src: "(> a 2)", exp: [">", "a", "2"] },
    { src: "(<= a 2)", exp: ["<=", "a", "2"] },
    { src: "(>= a 2)", exp: [">=", "a", "2"] },
    { src: "(defun hoge () (print 100))", exp: ["defun", "hoge", [], ["print", "100"]] },
  ]

  for t in tests
    act = parse lex t[:src]
    if act != t[:exp]
      puts "want #{t[:exp]} but got #{act}"
    end
  end
end

test_parse

def eval_list(ast, env)
  ast = Marshal.load(Marshal.dump(ast))

  func = ast.shift

  case func
  when "+"
    default, env = eval(ast.shift, env)
    res = ast.inject(default) do |sum, i|
      val, env = eval(i, env)
      sum += val
    end
    return res, env
  when "-"
    default, env = eval(ast.shift, env)
    res = ast.inject(default) do |sum, i|
      val, env = eval(i, env)
      sum -= val
    end
    return res, env
  when "*"
    default, env = eval(ast.shift, env)
    res = ast.inject(default) do |sum, i|
      val, env = eval(i, env)
      sum *= val
    end
    return res, env
  when "/"
    default, env = eval(ast.shift, env)
    res = ast.inject(default) do |sum, i|
      val, env = eval(i, env)
      sum /= val
    end
    return res, env
  when "setq"
    symbol = ast.shift
    val, env = eval(ast.shift, env)
    env[symbol.intern] = val
    return nil, env
  when "if"
    condition, env = eval(ast.shift, env)
    if condition != 0
      return eval(ast.shift, env)
    else
      ast.shift
      return eval(ast.shift, env)
    end
  when "while"
    cond, statement = ast
    while true
      condval, env = eval(cond, env)
      if condval == 0
        return nil, env
      else
        _, env = eval(statement.clone, env)
      end
    end
  when "print"
    for leaf in ast
      val, env = eval(leaf, env)
      print "#{val}"
    end
    puts
    return nil, env
  when "do"
    for statement in ast
      _, env = eval(statement, env)
    end
    return nil, env
  when "+="
    symbol = ast.shift
    default, env = eval(symbol, env)
    res = ast.inject(default) do |sum, i|
      val, env = eval(i, env)
      sum += val
    end
    env[symbol.intern] = res
    return nil, env
  when "-="
    symbol = ast.shift
    default, env = eval(symbol, env)
    res = ast.inject(default) do |sum, i|
      val, env = eval(i, env)
      sum -= val
    end
    env[symbol.intern] = res
    return nil, env
  when "<"
    left, env = eval(ast.shift, env)
    right, env = eval(ast.shift, env)
    res = if left < right then 1 else 0 end
    return res, env
  when ">"
    left, env = eval(ast.shift, env)
    right, env = eval(ast.shift, env)
    res = if left > right then 1 else 0 end
    return res, env
  when "<="
    left, env = eval(ast.shift, env)
    right, env = eval(ast.shift, env)
    res = if left <= right then 1 else 0 end
    return res, env
  when ">="
    left, env = eval(ast.shift, env)
    right, env = eval(ast.shift, env)
    res = if left >= right then 1 else 0 end
    return res, env
  when "defun"
    symbol = ast.shift
    args = ast.shift
    env[symbol.intern] = { args: args, codes: ast }
    return nil, env
  else
    funcinfo = env[func.intern]
    if funcinfo == nil
      p "err: func  #{func} is not found"
      return nil, env
    end

    for statement in funcinfo[:codes]
      _, env = eval(statement, env)
    end
    return nil, env
  end
end

def eval_num(ast, env)
  if /^[+-]?\d+.?\d*$/.match?(ast)
    return ast.to_i
  end

  return env[ast.intern]
end

def eval(ast, env)
  if ast.instance_of?(Array)
    return eval_list(ast, env)
  elsif ast.instance_of?(String)
    return eval_num(ast, env), env
  else
    p "err: got #{ast}"
    return nil, env
  end
end

def test_eval()
  tests = [
    { src: "(+ 1 2)", srcenv: {}, exp: 3, expenv: {} },
    { src: "(- 1 2)", srcenv: {}, exp: -1, expenv: {} },
    { src: "(* 1 2)", srcenv: {}, exp: 2, expenv: {} },
    { src: "(/ 1 2)", srcenv: {}, exp: 0, expenv: {} },
    { src: "(+ 10 2)", srcenv: {}, exp: 12, expenv: {} },
    { src: "(+ -10 2)", srcenv: {}, exp: -8, expenv: {} },
    { src: "(+ -10 252)", srcenv: {}, exp: 242, expenv: {} },
    { src: "(*  1 (+ 2 3))", srcenv: {}, exp: 5, expenv: {} },
    { src: "(*  (+ 3 2) (- 13 4))", srcenv: {}, exp: 45, expenv: {} },
    { src: "(setq a 2)", srcenv: {}, exp: nil, expenv: { a: 2 } },
    { src: "(+ a 2)", srcenv: { a: 2 }, exp: 4, expenv: { a: 2 } },
    { src: "(if 0 1 2)", srcenv: {}, exp: 2, expenv: {} },
    { src: "(if 1 1 2)", srcenv: {}, exp: 1, expenv: {} },
    { src: "(while i (setq i (- i 1)))", srcenv: { i: 10 }, exp: nil, expenv: { i: 0 } },
    { src: "(do (setq i 0) (setq i (+ i 1)))", srcenv: {}, exp: nil, expenv: { i: 1 } },
    { src: "(do (setq i 0) (+= i 3))", srcenv: {}, exp: nil, expenv: { i: 3 } },
    { src: "(do (setq i 10) (-= i 1))", srcenv: {}, exp: nil, expenv: { i: 9 } },
    { src: "(< a 2)", srcenv: { a: 1 }, exp: 1, expenv: { a: 1 } },
    { src: "(< a 2)", srcenv: { a: 2 }, exp: 0, expenv: { a: 2 } },
    { src: "(> a 2)", srcenv: { a: 2 }, exp: 0, expenv: { a: 2 } },
    { src: "(> a 2)", srcenv: { a: 3 }, exp: 1, expenv: { a: 3 } },
    { src: "(<= a 2)", srcenv: { a: 1 }, exp: 1, expenv: { a: 1 } },
    { src: "(<= a 2)", srcenv: { a: 2 }, exp: 1, expenv: { a: 2 } },
    { src: "(<= a 2)", srcenv: { a: 3 }, exp: 0, expenv: { a: 3 } },
    { src: "(>= a 2)", srcenv: { a: 1 }, exp: 0, expenv: { a: 1 } },
    { src: "(>= a 2)", srcenv: { a: 2 }, exp: 1, expenv: { a: 2 } },
    { src: "(>= a 2)", srcenv: { a: 3 }, exp: 1, expenv: { a: 3 } },
    { src: "(defun hoge () (print 100))", srcenv: {}, exp: nil, expenv: { hoge: { args: [], codes: [["print", "100"]] } } },
    { src: "(hoge)", srcenv: { hoge: { args: [], codes: [["setq", "a", "100"]] } },
      exp: nil, expenv: { a: 100, hoge: { args: [], codes: [["setq", "a", "100"]] } } },
  ]

  for t in tests
    ast = parse lex t[:src]
    act, envout = eval ast, t[:srcenv]
    if act != t[:exp]
      puts "want #{t[:exp]} but got #{act}"
      puts "#{t}"
    end
    if envout != t[:expenv]
      puts "want #{t[:expenv]} but got #{envout}"
      puts "#{t}"
    end
  end
end

test_eval

def get_text()
  print "> "
  text = ""
  while true
    line = gets
    if line == nil
      return nil
    end
    text = text + line

    leftparen = text.count("(")
    rightparen = text.count(")")
    if leftparen == rightparen && line.end_with?(")\n")
      return text
    end

    if leftparen > rightparen
      print "  " * (leftparen - rightparen + 1)
    else
      print "  "
    end
  end
end

def main()
  env = {}
  while true
    text = get_text
    if text == nil
      break
    end
    ast = parse lex text
    res, env = eval ast, env
    puts "#{res}"
  end
end

main
