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

def eval_list(ast)
  func = ast.shift

  case func
  when "+"
    default = eval(ast.shift)
    return ast.inject(default) { |sum, i| sum + eval(i) }
  when "-"
    default = eval(ast.shift)
    return ast.inject(default) { |res, i| res - eval(i) }
  when "*"
    default = eval(ast.shift)
    return ast.inject(default) { |mul, i| mul * eval(i) }
  when "/"
    default = eval(ast.shift)
    return ast.inject(default) { |res, i| res / eval(i) }
  else
    p "err: func is #{func}"
  end
end

def eval_num(ast)
  return ast.to_i
end

def eval(ast)
  if ast.instance_of?(Array)
    return eval_list(ast)
  elsif ast.instance_of?(String)
    return eval_num(ast)
  else
    p "err: got #{ast}"
  end
end

def test_eval()
  tests = [
    { src: "(+ 1 2)", exp: 3 },
    { src: "(- 1 2)", exp: -1 },
    { src: "(* 1 2)", exp: 2 },
    { src: "(/ 1 2)", exp: 0 },
    { src: "(+ 10 2)", exp: 12 },
    { src: "(+ -10 2)", exp: -8 },
    { src: "(+ -10 252)", exp: 242 },
    { src: "(*  1 (+ 2 3))", exp: 5 },
    { src: "(*  (+ 3 2) (- 13 4))", exp: 45 },
    { src: "(setq a 2)", exp: nil },
  ]

  for t in tests
    act = eval parse lex t[:src]
    if act != t[:exp]
      puts "want #{t[:exp]} but got #{act}"
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
    puts "#{eval parse lex text}"
  end
end

main
