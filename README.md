# Ruby-Lisp

これは Ruby で書かれた簡易的な Lisp 処理系です.
Ruby の学習のために作成しました.

## How To Run

1. 以下のコマンドを実行すると REPL 環境で Lisp を試すことができます.

```
$ ruby --version
ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-darwin21]
$ ruby main.rb
```

2. 以下のように、ファイルを指定して実行することもできます.
```
$ ruby main.rb example/hello.lisp
Hello
"World"
```

## Usage

簡単な四則計算ができます.

```
$ ruby main.rb
> (+ 1 2)
3
> (- 7 3)
4
> (* 3 4)
12
> (/ 30 5)
6
> (* (+ 1 2) (- 9 4))
15
```

以下は 1 から 10 までの和を求めるプログラムです.

```
$ ruby main.rb
> (setq i 0)

> (setq sum 0)

> (while (<= i 10) (do (+= sum i) (+= i 1)))

> (print sum)
55
```

また以下のように 30 番目のフィボナッチ数を求めることもできます.
```
$ ruby main.rb
> (setq i 0)

> (setq a 0)

> (setq b 1)

> (while (< i 30) (do (setq c a) (setq a b) (+= b c) (+= i 1)))

> (print b)
1346269
```

以下は FizzBuzz を行うプログラムです.

```
$ ruby main.rb
> (defun fizzbuzz (n)
    (setq i 1)
    (while (<= i n)
        (if (== (% i 15) 0)
            (print "fizzbuzz")
            (if (== (% i 3) 0)
                (print "fizz")
                (if (== (% i 5) 0)
                    (print "buzz")
                    (print i)
                )
            )
        )
        (+= i 1)
    )
)

> (fizzbuzz 30)
1
2
"fizz"
4
"buzz"
"fizz"
7
8
"fizz"
"buzz"
11
"fizz"
13
14
"fizzbuzz"
16
17
"fizz"
19
"buzz"
"fizz"
22
23
"fizz"
"buzz"
26
"fizz"
28
29
"fizzbuzz"
```
