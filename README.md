# Ruby-Lisp

これは Ruby で書かれた簡易的な Lisp 処理系です.
Ruby の学習のために作成しました.

## How To Run

以下のコマンドを実行すると REPL 環境で Lisp を試すことができます.

```
$ ruby --version
ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-darwin21]
$ ruby main.rb
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
