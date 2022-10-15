def parse(src)
  src.sub!("(", " ( ")
  src.sub!(")", " ) ")
  return src.split(" ")
end

def test_parse()
  tests = [
    { src: "(+ 1 2)", exp: ["(", "+", "1", "2", ")"] },
    { src: "(- 1 2)", exp: ["(", "-", "1", "2", ")"] },
    { src: "(* 1 2)", exp: ["(", "*", "1", "2", ")"] },
    { src: "(/ 1 2)", exp: ["(", "/", "1", "2", ")"] },
    { src: "(+ 10 2)", exp: ["(", "+", "10", "2", ")"] },
    { src: "(+ -10 2)", exp: ["(", "+", "-10", "2", ")"] },
    { src: "(+ -10 252)", exp: ["(", "+", "-10", "252", ")"] },
  ]

  for t in tests
    act = parse t[:src]
    if act != t[:exp]
      puts "want #{t[:exp]} but got #{act}"
    end
  end
end

test_parse

def eval(ast)
  ast.shift
  ast.pop
  func = ast.shift

  case func
  when "+"
    default = ast.shift.to_i
    return ast.inject(default) { |sum, i| sum + i.to_i }
  when "-"
    default = ast.shift.to_i
    return ast.inject(default) { |res, i| res - i.to_i }
  when "*"
    default = ast.shift.to_i
    return ast.inject(default) { |mul, i| mul * i.to_i }
  when "/"
    default = ast.shift.to_i
    return ast.inject(default) { |res, i| res / i.to_i }
  else
    p "err: func is #{func}"
  end
end

def test_eval()
  testsrcs = [
    "(+ 1 2)",
    "(- 1 2)",
    "(* 1 2)",
    "(/ 1 2)",
    "(+ 10 2)",
    "(+ -10 2)",
    "(+ -10 252)",
  ]

  for testsrc in testsrcs
    p eval parse testsrc
  end
end

while true
  print "> "
  text = gets
  if text == nil
    break
  end
  puts "#{eval parse text}"
end
