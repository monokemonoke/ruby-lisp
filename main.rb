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
  else
    p "err: func is #{func}"
  end
end

def eval_num(ast)
  return ast.to_i
end

def eval(ast, env)
  if ast.instance_of?(Array)
    return eval_list(ast, env)
  elsif ast.instance_of?(String)
    return eval_num(ast), env
  else
    p "err: got #{ast}"
  end
end

def test_eval()
  tests = [
    { src: "(+ 1 2)", exp: 3, expenv: {} },
    { src: "(- 1 2)", exp: -1, expenv: {} },
    { src: "(* 1 2)", exp: 2, expenv: {} },
    { src: "(/ 1 2)", exp: 0, expenv: {} },
    { src: "(+ 10 2)", exp: 12, expenv: {} },
    { src: "(+ -10 2)", exp: -8, expenv: {} },
    { src: "(+ -10 252)", exp: 242, expenv: {} },
    { src: "(*  1 (+ 2 3))", exp: 5, expenv: {} },
    { src: "(*  (+ 3 2) (- 13 4))", exp: 45, expenv: {} },
    { src: "(setq a 2)", exp: nil, expenv: { a: 2 } },
  ]

  for t in tests
    ast = parse lex t[:src]
    act, envout = eval ast, {}
    if act != t[:exp]
      puts "want #{t[:exp]} but got #{act}"
    end
    if envout != t[:expenv]
      puts "want #{t[:expenv]} but got #{envout}"
    end
  end
end

test_eval

def main()
  while true
    print "> "
    text = gets
    if text == nil
      break
    end
    ast = parse lex text
    res, env = eval ast, env
    puts "#{res}"
  end
end

main
