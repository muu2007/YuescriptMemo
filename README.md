# Yuescript(トランスパイラ)でLuaに他言語の便利な記法を導入する

- Yuescriptはluaに変換するトランスコンパイラ。
  [Luaへのトランスパイラ集](https://github.com/hengestone/lua-languages)にあった。
- 他言語にある内包表記、クラス型OOP、分解代入ほか便利な記法を取り入れる
  独自のpreludeは持ってない(全てLua本体にある機能に変換する)
  型の導入、他言語の哲学の導入はしていない。
- インデントでブロックを作り最後の式を評価して返す
  複文を横に並べて書けない(コードゴルフ的なことをしなければ)
- `sudo luarocks install yuescript`で導入。
  `yue -c -l --target=5.1 program.yue`でprogram.luaを生成
  周辺ツールはほぼ無い。(トランスパイルしてluaのものを使えればつかう)

以下はYuescript、Lua、言語を拡張するライブラリ(utf8、lume.lua、tamale.luaなど)を含めたもののメモ
対応バージョン yuescript 0.21、love 11.5

## よく使う機能

- [クラス型OOP](doc/クラス型OOP.md)
- [内包表記](doc/内包表記.md)
- [分解代入](doc/分解代入.md)
- [lume.lua](doc/lume.md)でreduce any allなど高階関数を補う(ただしconcat/mergeは...をつかう)
  それに渡す無名関数リテラルが短い記述`->`(メソッドが`=>`)
- if for while switchなどが式(ifを３項演算子として使える)
- [do式で組み立て](do式で組み立て.md)
  また、ifはコメントアウトしたいがブロック/スコープは残したい時、`do -- if ..`とする
- 関数呼び出しのカッコ省略(省略したほうが見やすくなるところは使う)
- [パイプ](doc/パイプ.md)。動作順と記述順を同じにできる。
- [テンプレート文字列](doc/テンプレート文字列.md) ダブルクォート文字列が複数行と式の埋め込みに対応
- ~~localが初期値になったので省略できる~~→弊害に移行
- [?で存在チェック](doc/?で存在チェック.md)
- inspect.luaでppを作って使う
- [luacheck](doc/luacheck.md)

<details>
<summary>あまり使わない機能</summary>

- !で関数呼び出し
- gotoとラベルは使わない(emscripten-luaが対応してないので)。脱出はreturnを使うようにする
- ??オペレータ(nil専用のor。使い分けるシーンがない)
- const(テーブルの中身は変えられちゃうので)
- global(`_G`と同じ？)
- lumeにあるが内包表記で書ける高階関数・パイプがあるのでチェーン表記は使わない
- 多重代入 `a = b = 0` (多値代入があるので)
  もし代入文にカッコをつけたら式にできるなら、関数引数で使えるのにと思う。
- 後置if/for(前に置くもののただの糖衣構文。スコープを作る。前に書いたほうが見やすい)
- luajit ffiで高速計算
- luajitのi接尾辞(cdataの虚数を作る)

</details>

## 面白い機能

- [仮引数の初期値](doc/仮引数の初期値.md)
- ifの条件式の場所で変数宣言と初期化/または再代入文(luaだから多値にも対応、一番左のものを条件の対象とする)(if notのときは`unless`を使う)
  and/orの右側には書けず。
  [注意] and/orで複数の条件式を書けない。andで合わせたものが代入される
- [マクロでデータ成形](doc/マクロでデータ成形.md)。yueをそのままDSLとして使えるか？
- [クロージャで遅延評価](クロージャで遅延評価.md)
- コルーチン
- [自作イテラブルオブジェクト](自作イテラブルオブジェクト.md)
- tamale.luaで[パターンマッチ](doc/パターンマッチ.md)/switchのテーブルマッチ
- [Unicode識別子](Unicode識別子.md)
- closeアトリビュート(luajitでも使える)
- withで作ったものに多少の変更を加えて返す(全てpublicなため/constructorの単純化)
- luajit [ffi](doc/ffi.md)でC言語ライブラリをリンク
- lpeg
- [順列と組み合わせ](順列と組み合わせ.md)など

## 危険な機能

- [localが初期値になったので省略できることの弊害](doc/localが初期値になったので省略できることの弊害.md)
- 関数呼び出しのカッコが省略できるが`type x == 'number'`は間違いでカッコが必要
- [関数オーバーライド](関数オーバーライド.md)
- [テーブルに同居](doc/テーブルに同居.md)
- [壊れた配列を作らなように](doc/壊れた配列を作らなように.md)
- [str[n]は別機能](doc/str[n]は別機能.md)
- 多値(unpackやselectも)をテーブルコンストラクタの最後以外、引数の最後以外に書くとカッコで囲んだかのように１つになる
- ~~関数いくらでも太らせることができる~~(単体テストが書きにくくなる。)
- ズボラプログラミング(配列を構造体`{.x, .y}`のつもりで使い、`p.x, p.y`と参照しようとすると`nil, nil`が帰りエラーを吐かない)
- [yue][spec] forと内包表記が受け手があるかないかで動作が違う
  - 関数の最後の行でない場所に、受け手のない内包表記を書いた場合、正しく展開されない
  - 関数の最後の行が、内包表記の場合、受け手があるものとしてreturnされる
  - 関数の最後の行が、for文の場合、for式として集めて返さない(returnを明示する必要がある)
  - [bug?] 内包表記をパイプで関数に繋げた場合、受け手として認識されない？→luacheckがempty if branchと報告するので気付く
- 予約語が増えているのでluaのつもりで書いたらparser通らない(asを変数名に使うと字下げがおかしいというエラーになる)
- [bug] yue v23現在、多値代入と分解代入を組み合わせると、①左辺、②添字、③代入の計算順序が狂う。
  `{x, y}, list = lume.first(list), lume.slice(list, 2)` breaks Before the assignment rule.
- luaには破壊的関数がある。table.insert/remove/sort lumeにもpush/removeがある。
  非破壊的に書き換えようとしたら上のバグを見つけて、除去する方針をどうしようかと…
- [bug] マクロ展開後`super()`が置き換えられない。

## その他

- [selfは予約語ではない](doc/selfは予約語ではない.md)
- 引数とdebug.getLocal()
- 与える引数によって振る舞いを返る関数がある(math.randomやlume.first/lastなど)
- module/import
- try/catch
- [Lua・Yueの細かいところ](doc/Lua・Yueの細かいところ.md)
- [Lua各バージョンの違い](doc/Lua各バージョンの違い.md)
- [クリップボード](クリップボード.md)

## わかってないもの

- backcall
- ~~弱参照~~
- debugライブラリ
- 強化学習(ncnnやtensorflow liteなど)ffiで

## あったらいい機能

- ~~[コンパイル時にテーブルのキーの記述順序を保存する記法が欲しい](doc/コンパイル時にテーブルのキーの記述順序を保存する記法が欲しい.md)~~→マクロで(簡易的なものは)できた。
- [関数内の記述順序を前後させたい](関数内の記述順序を前後させたい)
  →すでにブロック内`local *`でできるのか？→出来ない
- 代入文を式にする方法が欲しい(カッコで囲むと代入したものを返すとか)
- ブロックが空になるとsyntax error(マクロ展開の結果空でも/コメントアウトでも)なので、コメントがある時だけでもトランスパイルを通して欲しい(コメントをnoopの代わりにして欲しい)
- 型チェック/nilチェック自動差し込み →tl checkのノイズを減らしてゆくことから
- `_`(変数名)は捨てるものの代入に使うが、(有効な変数名なので)その後参照できてしまう
  →毎回別名(ハイジニック)にトランスパイルして欲しい(forループ変数がconstになったのもあり)
- yue luacheck tl check bustedをwrapしてvim.ALEに繋げたい(周辺ツール)
- ~~マクロにspace(0x20)を含む**埋め込みデータ**を渡したい~~
  ダブルカリー文字列先頭と末尾の改行以外を削除しないで欲しい(luaと同じ動作)
  →ダブルクォート文字列でできる(`\sub(2,-2)`で最初と最後の改行を除く必要はある)
- lua5.1用に整数除算と~~math.maxinteger~~を、lua5.3用に~~unpackをtable.unpackに~~してほしい→lumeに書いた
- [bug?] 無名classを代入する形で書くとcore dumpを吐いて変換できない `a.b = class`
- マクロも`local *`で記述順序を前後させたい
- struct宣言でp.x→p[1]に置換

## バグ集

- [love2d] love2dのutf8は同じ文字が連続した時バグる？`ｺｺｺｺｺ`で起きた→yueのマクロで同じことをすればlua5.4でやるのでちゃんとできる。
- [yue] 多値代入と分解代入を組み合わせた時、分解代入が後回しにされる。(順序)
- [yue] マクロでyueのコードとして`super()`を返した時、継承元の同名メソッドの呼び出しにならない。

## コード

```yuecode.lua
import 'lume' as :memoize
-- local *
-- fib = {1, 1, <index>: memoize (n)=> fib[n-2] + fib[n-1]}
fib = {1, 1, <index>: memoize (n)=> @[n-2] + @[n-1]}
print fib[42]
```

1. lumeライブラリから関数1つだけimportする
2. このスコープの前方宣言を全て書いてくれる仕組み。
   次行でテーブルリテラルの中で自身の名前を使うから前方宣言が必要
3. 一部をデータから、一部を計算で返す配列を作っている
   関数呼び出しカッコを省略しているがmemoizeはただの関数。まるで新しい文法かのように見える
4. 自身は`@`(=self)で渡っているから前方宣言は不要でした
5. モジュールにするなら外へ見せるもの(fib)にexportをつけて、
   単体テスト的な部分を`if package.loaded['busted']`でスコープを付ける(トランスパイルして`busted --lang=ja --lua=luajit`を掛ける。luajitで実行も出来る。引数は渡せない。→クリップボードを読む)

- [ポーカーの役判定](code/poker.yue)
- [ポーカーの役判定(日本語識別子)](code/ポーカー.yue)、
- [テンパズル/make10](code/tenpuzzle.yue) 順列と組み合わせを使う
- [数独](code/数独.yue)
- [ターミナル版2048](code/g2048_lcurses.yue) luajit用
- [ターミナル版倉庫番](code/sokoban_lcurses.yue) luajit用
- glob luafilesystem版、love.filesyste版
- [zigマクロ](code/embedzig.yue)
- [luacheckrc](code/.luacheckrc)

## Love2d

- [Love2Dの細かい部分](doc/Love2Dの細かい部分.md)
- [各プラットフォーム向けのdistribute](doc/distribute.md)
- [GUIデバッガ](doc/vudu.md)

使いたいライブラリ

| ライブラリ名                       | 機能              | 活用できてる？       | 備考                                                                                   |
| ---------------------------------- | ----------------- | -------------------- | -------------------------------------------------------------------------------------- |
| bump                               | AABB当たり判定    | OK                   | Pico8-bump.luaの▽CodeをクリックしてC-fで検索して使い方を得た                           |
| rotLove                            | ローグライク用utl |
| ncnn                               | NN(モデル再生)    | 砂嵐しか得られてない | tensorflowliteはコンパイルさえ出来ない / luann.lua                                     |
| [turbo-sqlite3](turbo_sqlite3.yue) | データベース      | サンプルコード動いた | ハイフンをアンダースコアに、init.luaにしてluacheckで指摘されたところを変更(luajit専用) |

---

![2048](img/game2048.gif)
[2048](https://github.com/muu2007/game2048/) [▶Play](https://muu2007.github.io/game2048/)

---

![freecell](img/freecell.jpg)
[freecell](https://github.com/muu2007/freecell/) [▶Play](https://muu2007.github.io/freecell/)

---

![スイカゲーム](img/suikagame.jpg)
[suikagame](https://github.com/muu2007/suikagame/) [▶Play](https://muu2007.github.io/suikagame/)

---

![数独](img/sudoku.jpg)
[数独](https://github.com/muu2007/sudoku/) [▶Play](https://muu2007.github.io/sudoku/)

---

![DQ1](img/DQ1.jpg)
[DQ1](https://github.com/muu2007/DQ1/) [▶Play](https://muu2007.github.io/DQ1/)

---

![smario](img/smario.jpg)
[smario](https://github.com/muu2007/smario/) [▶Play](https://muu2007.github.io/smario/)
