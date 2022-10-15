def parser(src)
    src.sub!('(', ' ( ')
    src.sub!(')', ' ) ')
    return src.split(' ')
end


# testsrcs = [
#     '(+ 1 2)',
#     '(- 1 2)',
#     '(* 1 2)',
#     '(/ 1 2)',
#     '(+ 10 2)',
#     '(+ -10 2)',
#     '(+ -10 252)',
# ]

# for testsrc in testsrcs do
#     p parser testsrc
# end

while true do
    print "> "
    text = gets
    if text == nil
        break
    end
    puts "#{parser text}"
end