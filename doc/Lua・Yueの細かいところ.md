# Lua・Yueの細かいところ

他の機能の場所で書いてしまうとノイズになってしまうものをまとめて。

## 識別子と代入文

- [lua] localと書かないとglobalになってしまう。
  [yue]ではlocalを省略できる。
  → globalと書くか、`_G.`と書いてより外側の変数を宣言する(ほとんど使わない)
  → 同名の変数を変数宣言のつもりで書くと上書きしてしまう。ファイルローカルな変数を使わない(例えば`love.`のなかに入れる)方針を決めるべき。(関数名はユーティリティ関数だろうから名前かぶりはしないだろう)
- [lua] static変数はないのでグローバル変数/インスタンス変数を長い名前にしてそれっぽく使う(例: `_static_foo or= true`)
  スコープが関数内ではないことに注意
- [lua] 多値代入がある(右辺全てを評価してから代入する。左側の変数を使った計算をするときは２行に分ける必要がある)
- [yue] 複合代入演算子(+= or= ..=など)がある(これは多値に対応しない)

## 予約語

予約語が増えているのでluaの予約語ではないから使えると思って変数名にするとエラーになったりする。
asを変数名に使うと字下げがおかしいというエラーになる[bug]。

## 数値

- +単項演算子はない(表示のときも+は表示されない)。sciluaライブラリでは表示するので…あってもいいのでは
  必要な場所:forのstepのところとか…
- 先頭に0が並んでも良い(なんで？)
- １０進数、１６進数表記、eを使った指数表記、pを使った１６進表記はある。２進数、８進数表記はない
- luajitにはLL,ULLを付けたものがあるが、これはluaの数値ではなくcdataを作る。
  iを付けた虚数もあるがyueのパースが通らない(使い方サンプルさえ見つからないので…)
- [yue] 数値の間にアンダースコアをはさめるようになった
- [yue] ２項演算子の左右のスペースは全く挟まないか、両方に挟むこと。さもないと関数呼び出しと認識される(例:`a -2`)
- 数値と文字列の自動変換がある。formatが必要でない場所では短く記述できて便利、添字としては`[1]`と`["1"]`は区別される

## 演算子

- yueでは`y -2`は関数呼び出しとみなされる(必ず詰めるか両方にスペースが必要)

### 整数が無いことについて

Love2D(luajit/lua5.1相当)なのでlua5.3から導入された整数関連のものは使えない
おぼえるものが少なくなって良い(ビッド演算子、シフト演算、math.typeなど)と思えるか？……
整数除算(idiv)とmath.maxintegerは使うのでyueに入れてくれないかなぁ……
math.huge(=double.inf)はluajitにもあるが、`1 == count % math.huge`ではmaxintegerの代用はできない。

### 乱数

luaのrandomはCのwrapでportableではない？luajitはportable?

| 関数名                                 | 説明                                       | 備考                         |
| -------------------------------------- | ------------------------------------------ | ---------------------------- |
| math.randomseed                        |                                            | love2dでは起動時に実行される |
| math.random()                          | 0~1の実数を返す                            |
| math.random([m,]n)                     | 1~nまたはm~nの整数を返す                   |
| lume.random([a,]b)                     | 0~bまたはa~bの実数を返す                   |
| lume.randomchoice(arr)                 | 配列から１つ選ぶ                           |
| lume.weightedchoice({key: weight,...}) | valsの合計中のvalの割合でkeyを選択して返す |                              |
| lume.uuid()                            | 文字列                                     |                              |

### 時間

love2dでは１秒は1.0で表すことが多い

### in 演算子

配列の中にあるか調べられられる。
優先順位が微妙 `if not a in {b, c}`とするとnot a が先になるのでカッコで囲むか、unlessを使う。

## 文字列

- 一文字でも文字列、文字型はない。スライスはsub()を使う、添字でn文字目にアクセスできたりしない
- Flyweight管理
- 比較演算子は短い方に長さを揃えて比較する
- シングルクォート文字列、
  ダブルクォート文字列、
  ダブルカリー文字列(間に=がいくつか入っても良い)がある。先頭と末尾の改行は削除される。
  yueではダブルクォート文字列が複数行に対応。埋め込み式展開(テンプレート)もできるようになった。
  [注意] 式展開の式が複数行に非対応
- 連結は`..`を使う
- 文字列が作られるとstringライブラリがメタテーブルに入れられる。(レシーバー・メソッド(OOP風)呼び出し、チェインで繋げられる)
  string名前空間に関数を追加すると標準関数と同じ様にメソッド呼び出し風に使える
- str[n]は別機能(別ページ)
- luaの正規表現は機能が少ない(orや否定などがない)。なので正規表現とは呼ばないもよう。
  他言語でパターンを引数に受ける場所に同じ様に書いたら、役立たずになるかも
- yueではパイプがあるので、今luaを設計したらメタテーブルに設定する機能を付けなくてもいいかも
- utf8ライブラリが別にある(=正規表現はutf8を理解しない)
- 文字列は他言語のいくつかのものを代用する(が、それぞれの型の小さな便利関数はない)
  - 正規表現パターン
  - ファイルパス
  - 日付と時刻
  - モード(Enumのエントリ？ただしまとめたものはない)
  - バイト配列(\0も含むことができる)
  - [注意] yueのクラス名は識別子なので`issubclass(obj.__class.__name, 'ClassName')`よりも`issubclass(obj.__class, ClassName)`のほうがいい。勘違いで混ざると機能しない
    クラスであるかは`assert(A.__init)`でしらべる？

| 関数名                     | 説明 | 備考                  |
| -------------------------- | ---- | --------------------- |
| lume.split(str, delimiter) |
| table.concat(t, delimiter) |      | lume.reduceでもできる |

### 数値と文字列の自動変換

luaは文字列と数値の相互自動変換がある
しかし、`arr[1] != arr['1']`です。

```カンマ区切り数値yuecode.lua
numWithCommas =(n)-> tostring(math.floor(n))\reverse()\gsub("(%d%d%d)","%1,")\gsub(",(%-?)$","%1")\reverse()
```

### utf8

utf8はstringの様にレシーバー・メソッド形式では書けない
love2dにはutf8が付属している(lua5.1/luajitには付いてないのでユニットテスト時には互換ライブラリを使うことになる)

### 正規表現(luaではfull実装ではないので公式はパターンと呼ぶ)

### ファイルパス

## 多値

- luaには多値がある。仮引数に...が置ける。`{...}`で配列にして扱うか、selectで操作できる(そのまま計算は出来ない)
- 多値代入や多値返しなども多値と同じ。自然な記述だと思う。
- 多値(関数戻り値が多値のときも)をカッコで囲むと左の一つだけになる。
- math.min/math.maxなどは多値を引数に取る。配列をunpackでバラして渡す。
- ...にnilが無いと仮定すると、...に引数が渡ってきたかは`if (...)`で調べられる(`{...}[1]`と同じ意味)
- 多値(unpackやselectも)をテーブルコンストラクタの最後以外、引数の最後以外に書くとカッコで囲んだかのように１つになる
  `...`(テーブル展開)はそうならない
- [yue] 多値代入文の左右の数がコンパイル時にチェックされるようになった。luaでは多くても少なくても問題とはしていなかった。

## テーブル

- luaでは型の揃った配列(他言語での配列)、型の揃っていない配列(タブル？)、辞書(辞書)、構造体やクラスのインスタンスがすべてテーブルです(yueのクラスもテーブルです)。多値が別にあります。
  値にnil以外のものを持てます。値にnilを定めた場合設定していないのと同じです(開放してGCに回収してもらうときにも使う)。
  それらを参照するとエラーではなくnilが帰ります。
- 構造を表すものが一つしか無いことは、言語やライブラリをシンプルにする長所であるとともに、テーブルリテラルの記述からではそれをどのように扱うがが書かれないということが短所なのかもしれないです。
- 比較はアドレス比較。printでテーブルを表示させるとアドレスが表示されるのもこれを示している
  bustedの`assert.are.same`では内容で比較できるが、普段は使えない
- 配列の**添字１始まり**
  `{[0]: 0}`とすれば0から使えるが、1からnilが出るまでを配列として使うので(忘れてしまうので)使わないほうが良い
- 値にnilを持てない。`{nil, nil}`は空配列になる。(nilを入れるとキーがなかったことにされる)
- [危険] 無いキーにアクセスするとnilを返す(エラーではない)→luacheckを使う
- yueでは`{}`の他に`[]`でも配列を表記できるようになった(が値１つの時後ろにカンマが必要)
  他言語ではpythonのタプルで必要だが、配列では必要ないのでコピペ時注意
- テーブルコンストラクタの中だけ`...`で分解できる。一部を更新したデータを作りたい時など
- [yue] テーブル/クラスの中では`=`の替わりに`: `を使う必要がある
- [yue] 行末のカンマが無くてもよい、最後のカンマは余っても良い。
- ２重の内包表記を書くときは(ダブルカリー文字列に認識されないよう)スペースを入れて書く必要がある。
- pythonのようにテーブルのすぐ後ろに添え字を書くことは出来ない→`{1,2,3}|>rawget(n)`とすればできる
- 関数呼び出しを添え字アクセスに偽装(他と揃える時使う)
- メタテーブルのキーも他のキーと並べて書けるが、その記法の活用法が特に無い
- メタテーブルを`<index>`などと書けるが、種類が少ないので他のキーも同様にかけて欲しいです
  `<index>`と`<>.key`→`<__index>`と`<key>`で
- [注意] table.removeは引数として渡した先で配列を変更しても、元のものも変更される。(lume.removeも同じ)←使っちゃだめだろ！

| 関数名      | 引数           | 戻り値     | 備考                                                 |
| ----------- | -------------- | ---------- | ---------------------------------------------------- |
| lume.sort   | 配列, 比較関数 | 新しい配列 | table.sortは破壊的関数(戻り値はnil) 両方非安定ソート |
| lume.remove | table, 値      | 値         | table.removeはindexで指定                            |
| lume.find   | table, 値      | index      | 高階関数でないため、先に変形することも               |

### 配列

- luaではtableの１からnilが現れるまでの整数のキーの場所を配列として扱う
- lume.ripairsは１で止まらないという違いがある
- yueにreduceは無いのでlume.reduceを使う(math.＋を定義してみたが使うかな？)
  文字列の連結はtable.concatが使える
- 多値を返す関数に長さ演算子`#`を使うとカッコで囲んだように先頭を使うようだ。
- [lua] [注意] [仕様] 配列をスライドさせ後ろに挿入するには`a[#a] = table.remove(a, 1)`のようだ。`#a`の評価されるタイミングはtable.removeより前？
- [lua] [注意] [仕様] unpackは1024個まで。それ以上はtoo many results to unpackというエラーで止まる。

#### 順列と組み合わせ

combnライブラリ

### 辞書

- 純粋なデータ表現(javascriptのようにconstructorやtostringが埋まっていない)
  metatableをセットするかも任意
  →だからpairs/ipairsを使ってイテレーターにする。

### 破壊的関数

使ってはいけない
ローカル変数でstackとわかっていればpopとしてtable.removeを使うか？
(removeを下の置き換えをする時、分解代入と組み合わせると、計算順序が狂いうまく行かない yue v23現在)

| 関数名       | 引数              | 戻り値     | 備考                                                                                       |
| ------------ | ----------------- | ---------- | ------------------------------------------------------------------------------------------ |
| table.insert | list [, pos], val |            | `lume.concat(list, {val})`、{展開演算子}で新しい配列を作るべき                             |
| lume.push    | list, val1, ...   | nil        | これも破壊的                                                                               |
| table.move   |                   | nil        | 使わないからいいや                                                                         |
| table.remove | table, 位置       | 除かれた値 | popであれば、`entry, new_array = lume.first(arr), lume.slice(arr, 2)` などで置き換えるべき |
| lume.remove  | table, 値         | 除かれた値 | lume版も破壊的関数                                                                         |
| table.sort   | list, 比較関数    | nil        | lume.sortは非破壊的(新しい配列を作って返す)。こちらを使うべき。 両方とも非安定sort         |

### パターンマッチ(tamale.lua)

## 関数の記述

- 引数の数が不足すればnilが渡る。余れば使われない
  型も無いので関数のオーバーロードは出来ない
  余る部分に計算を書けば呼び出し前に評価される[CodeGolf]
- nilとfalse以外は全て真(空文字、空テーブルも真)
- 比較。
  - 文字列までは等値比較、テーブルからは同一オブジェクトかを比較(アドレスを比較する)
  - 文字列の大小比較できること忘れがち
  - 型が違うものの`==`と`!=`での比較はfalseが返る(in-expressionでの比較でも使われる。配列の中のゴミデータを無視する的な)
- `~=`が`!=`とも表記できるようになった
- forが２種類ある(数値forとforeach)、レンジオブジェクトはない
- 他言語でdo-whileは`repeat-unitl`
- [lua] returnブロックの最後の文としてしか書けない。途中で必要なときはdoでブロックを作る
  yueでは普通に書ける
- [yue] switch
  `when in [1,9]`という表記が使えたが今はなくなった
- [yue] continue(`--target=5.1`でgotoを使わないものを生成する)
- [yue] [注意] 関数引数に無名関数を書く時、最後の引数でなければカッコで囲む必要がある(関数の終わりがわからないため)
- [lua]では３項演算子は無く、andとorで代用していたが
  [yue]ではifが式なのでこちらを使う
  luaでtrueなどを返さなくてはならなかった部分は使わなく(discard)なった
- if notにはunlessがあるがwhen notにはない(条件式の場所で変数宣言をするためだけにunlessがある？)
  not は演算子の優先順位が高いので注意
- インデントがあるものが関数の続きとみなされる(データ表記と区別)
- インデントはタブ１つでも２つでも構わない。以下の２行目のように同じインデントでもパースは通るが人間が読みにくい場合に使える
  ```yuecode.lua
  if f := switch id
  		when 'a' then -> lume.noop()
  	f()
  ```

## クロージャ

- luaの用語: スコープの外側の変数をupvalueと言う
- 遅延評価として
  いま計算しておくことはクロージャの外に、後で計算するものはクロージャにして返す
- lume.memoiseはクロージャで出来ているっぽいのでもう一度flyweightを作れば前のやつはGCが回収する？

## コルーチン

- 非対称(親子関係)コルーチン。ライブラリに分離されていて、何重もの呼び出しができる。
- ゲームでは一時的なアニメーションに使って元のupdateに戻すという使い方をしています。

## io/file

- love2dではプロジェクトフォルダ以下とセーブフォルダのみ読み込める。セーブフォルダのみ書き込める
  nativefsを使えばそれ以外も可
- `io.lines`は改行がcrlfのときcrが残る。
- ファイル全読み込みは`io.lines(fn, '*a')()`
  説明: io.linesはイテレータを返すが、イテレータは関数なので呼び出せば良い。

## エラー処理

pcall/xpcallを yueではtry/catchにまとめている

## 構造体?

テーブルで表現する
boxは配列で表現している
Vector/Matrixにはメタテーブルで演算子オーバーロードがついてる(自分で書いたものではない)

## [クラス型OOP](クラス型OOP.md)

- luaには決まったクラス作成法が存在しないのが欠点だそうだが、yueで標準的な方法を定めていることになる。
- 自分ではクラスのインデントの中にクラス変数とメソッドを並べて書くのがシンプルだと思っているが、
  別な書き方もできる
  - インスタンス変数は使用するまでに用意されていれば良い。
    ついついnewに全て書いてしまうけれど
  - クラス変数も使用するまでに用意されていれば良い。
    メソッドの中で宣言することも出来、その場合は構築のタイミングが起動時→インスタンス作成時になる(はず)
  - クラスの宣言が一度終わった後で変数やメソッドを加えることもできる(メソッドを加える場合は`__base.`に加える(はず))
- lua用ライブラリで独自クラスを持つものが結構あり、共存する必要がある(classという関数がある場合、`_G.class()`と呼び出せば良い)
  withを使ってこれらをclass宣言風にインデントを付けて書くことができる。
- withがあるので完璧なコンストラクタを書く必要はない(newした後に調整できる)
- [注意] typeで型を調べるとき、辞書がtableであることは認識と一致しているが、配列や、クラスのインスタンスもtableになってしまう
- [bug] new内で継承元クラスメソッドを呼ぶためにsuperと書くと、その後のsuper呼び出しが正しく展開されない(継承元クラスメソッドはクラス名.メソッド名で呼べは大丈夫[super_test.yue](super_test.yue)

## モジュール

- フォルダ名をモジュールにするにはinit.luaとすれば良い
- importはルートブロックにしか書けない。(それ以外のときはrequireを使う)
- importでは最初の文字が数字のフォルダを扱えない。requireでは大丈夫なのに(途中のものでもだめ)
- `package.loaded['モジュール名']`ですでに読み込んでいるかチェックできる。
  これを使って分岐できる(importする順序が重要になる) bustedとか
- `local *`や`local ^`で関数を上から書かなくても良くなる(前方宣言をまとめてやってくれる)
- `local name`(前方宣言)でテーブルコンストラクタの中でこれからそれを代入する名前をつかえるようになる
  これはそのブロックのみ有効(`local *`すれば関数の中も有効だと思ってたが違った)
  tamale.matcherを再帰関数にするのに使った
- モジュールの拡張は[関数オーバーライド](関数オーバーライド)に書いた。

## マクロ

- 渡す引数は
  - lua/yueの値を渡すと文字列になる。関数リテラルも
  - シングルクォート文字列はシングルクォートがついたまま渡る。\nは\\nとなる
  - ダブルクォート文字列は複数行が渡せる(\nになる)。これも先頭と末尾にクォートがついたまま、
  - ダブルカリー文字列はluaの動作とは違い先頭と末尾以外のスペースもトリミングしてしまう
  - [重要] テーブルを渡すと整形されて文字列になる
  - 渡ってくる引数はyueのコードなので、luaのライブラリを使うためにはトランスパイルしなければならない。
- 戻り値は文字列で返す。戻すのが文字列一つならば、２重に囲まなくてはならない
- macroをexportする場合、macroだけのファイルにしなければならない
- マクロをネストしようとしたらうまくかなかった。出来ない？
- luaに残すマクロ使い道がない
  `-c`コマンドラインオプションがあるので
  変換後のluaファイルの行末にコメントが残せないぐらい
- comptimeマクロを作るよりは近くに一回の専用マクロを定義するほうが良い。
  理由はマクロは文字列になってしまうからエディタの色付けがされない
  テーブルを返す場合は`lume.serizlize(table)\gsub('=',': ')`とする。inspectではダメ
  ただ、起動後の情報を使うものは先に計算できないし、loveについているライブラリは使えないのでなかなか使いどころがない。普通に計算してもほぼ一瞬だったり。

## コードゴルフ的な記述

yueでは文を横に並べて書けないが、次のようにすると横に並べて書くことができる。

- nilを返す関数は??/orを挟んでつなげて書ける
- 多値代入の文は受け手の変数名を`_`にして、複数の式を左辺に書ける(左から右に実行されるはず。)
  この時関数呼び出しのカッコを省略すると、引数が複数あるかのように解釈されるためカッコを外せない(が、文字列一つ、テーブル一つの時は関数のあとにスペースを開けずに書けばカッコがなくてもきちんと解釈される。)
- 同じく、使っていない関数引数の部分で先に評価させることはできる(←危険か？)

`gr = love.graphics`とし、略記する

チェイン記述できるものはする。
stringやrequire()の戻り地など

ベースクラスを外から改造できてしまう。(本来なら一段派生クラスを作ってそれをベースとするべき)
同じ考えで、ポインタやボックス(これも構造体を作らずにテーブル！)に、情報を追加して運ばせる(本来なら２つのオブジェクトを持ち運ぶべき)

## サードパーティ製ライブラリ

lume.lua
: 高階関数やmemoiseなど言語を拡張する関数がある。
いくつかはyueの機能と重なるので使ってない

lcurses
: 小さなゲームライブラリとして利用

luafilesystem
: フォルダ内の全ファイル名を得るのに必要

tamale.lua
: パターンマッチングライブラリ。
moduleがあるが、lua5.4用に修正はできる。全体をテーブルに入れてreturnでそれを返す

luacombine
: 順列、組み合わせ
table.getnを長さ演算子に書き換えが必要
`print inspect [{a,b,c} for a,b,c in combine.combn(s, 3)]`(多値を返すイテレータを返す)
tenpuzzleで、combn(順列)は並べ替えたもの(競馬で言う連単)を作らないので、更にpermute(組み合わせ)をする必要があった

luasort
: 使ってない。安定ソートか？

[bump.lua](bump.md)
: AABB当たり判定ライブラリ

## 周辺ツール

### luacheck

トランスパイルしたluaファイルに掛ける。とても便利。
vimでluaファイルを(左右に並べて)開くと自動で掛かり`ctrl-e`で一つづつエラーを潰してゆく。
`yue -l`オプションで対応する行番号を得る
selfがshadowingする部分は無視するようにした
クラス内クラスや引数一つの関数を短く書くのにメソッド記法を使ってる

### busted

`if arg[0] == 'ProgramName'`とする代わりに`if packaged.loaded['busted']`として、
モジュールと同じファイルにテストを書けるかやってみる。
実行するときは`yue ModuleName.yue && busted --lang=ja ModuleName.lua`で行う
luajitで速度を見るときはbusted.luaという空ファイルを作れば`luajit -lbusted`で実行できる(bustedでluajitを指定することは出来ない)

### その他

tl check
LDoc
静的コールグラフを書いてくれるものもあったが、関数定義が`name = function()`だと使えなかった

## 型

## FFI整数

luajitでは`ffi.new()`で8~64bit整数を作ることができる。
普通の演算子とbitライブラリで計算できる(高速らしい)

## FFI(ダイナミックリンクライブラリとの連携)

他の言語で作られたCインターフェースのあるライブラリをリンクすることができる。
luaの文字列で連携しにくいときはstring.bufferライブラリがある

## jsonを読む。

- 配列、キー、nullをluaの文法に直してloadで読む
- loadは関数を返すので"return "を付ける。関数なので呼び出して戻り値を得る。
- マクロにすれば動的に読む→静的に展開するにできるはず。

```
c = io.file_read('assets/2d/little guys/strawberry kitty.save')
c = c\gsub('%[(.-)%]', '{%1}')\gsub('"([^"]-)":', '["%1"]=')\gsub('null', 'nil')
print c
l = assert(load('return ' .. c))()
pp l
```

## その他

- playgroundではライブラリの読み込み、luajitでの実行は出来ない
- デバックモード/static if はない
  コマンドラインからも指定できない
  Love2Dでの制作ではmacros.yueがあるかどうかでDEBUGMODEを作っている
  `gcc -E`を使ってstatic ifを実現する方法がlua-userにあった。

## 速度について

同じソースを使ってluaと比較すると、ときに何十倍も早く実行されるが、
luaはprintを毎回flushする。luajitはキャッシュして一気に出力するなど動作の違う部分があり、単純な実行速度を比べたことにはならないことに注意。
