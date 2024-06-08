# lume.lua

love2dなどゲームで使われる関数を集めたもの。他の目的だとpenlight.luaなどがある。

## 高階関数

- any/all
- ~~each~~/~~map~~
- reduce(yueに無いので重要)
- ~~filter~~/~~reject~~
- find(関数は取らない)
- count
- sort
- unique
- match

## 配列用関数

- clone
- first/last(引数なしの時先頭の値を、引数ありの時先頭からn個の配列を返す)
- invert
- ~~push~~ yueでは[] =で
- remove (table.removeはインデックス指定。こちらは値)
- ~~clear~~
- sort
- ~~concat~~

## 辞書用関数

- keys
- pick
- ~~merge~~
- ~~extend~~ yueでは{...t, additional}で

## 数学関数

- clamp
- sign
- lerp
- smooth
- pingpong
- distance
- angle
- vector
- random(math.randomは引数を指定した時整数を返す。こちらは実数)
- randomchoice(配列から一つ選ぶ)
- weightedchoice(出目をキー、出る割合をvalueで設定する)
- shuffle
- uuid

## 文字列

- spit
- trim
- format
- color

## 言語の拡張

- memoize
- time 呼び出した関数の時間を測る
- once
- ~~combine~~
- ~~call~~ fnがnilでもエラーにならない呼び出し(yueで?があるので)
- serialize/deserialize
- hotswap

## あまり使ってない
