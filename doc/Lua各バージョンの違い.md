# Lua各バージョンの違い

整数まわりを使わない
utf8 は互換ライブラリを使う
で大丈夫？

## 大きな違いは、Lua5.1 に対して lua5.2 は

- goto とラベル(luajit にもある)
- bit32 が入った(luajit に bit ライブラリがある)
- 環境が変わって c の関数は環境持てなくなった
- setenv がなくなった
- utf8 が識別子に使えなくなった(luajit では今でも使えます)
- 文字列で使えるエスケープシーケンスが増えたり、パターンに%g が入ったり
- module 削除(古すぎてよくわからないがluajitではあってもなくても大丈夫)

## lua5.3 は

- 整数の導入(整数除算も)、math.tointeger()やmath.type()が追加
  文字列化で1→1.0となる
- bit32 は演算子になった(operator overload も)
- utf8 ライブラリ(luajit では外部ライブラリを導入すればよい)
- math ライブラリ整理
  math.ult(unsigned lesser thanの略？)

## lua5.4 は

- const/closeアトリビュート(yueで実装されました)
- 整数の自動変換やラップアラウンドの動作の変更
- utf8 サロゲートペアは引数で指定しないとだめになった
- le と lt からエミュレートしなくなった
- io.lines の戻り値が４つになった

## luajit は

- jit ライブラリ
- ffi
  接尾辞(LL ULL )を置くことで64bit 整数も持つことができるが、これはBOX化されたものであり、どう扱えば速いのかはむづかしい
  ffi.newでdoubleの配列を持つことができる。添字は０始まり。
  64bit整数どうし、doubleの配列の中身どうしであれば計算が早くなる？
  I(複素数接尾辞)もあるがluaでは計算すら出来ない(cの複素数ライブラリに渡すだけのもの？)。yueでパース通らない
- stringbufferライブラリ
- printがキャッシュされていっぺんに出力される
- luaで少し速くしたものがluajitでは遅くなるということもある(luajitでの速度を測るときは`yue --target=5.1 sudoke.yue && luajit sudoke.lua`とする)
- love2dで半角カタカナの'ｺｺｺｺｺ'が正しく扱えなかった。Lua5.4で動くmacro版では正しく分離できるのでbugだと思う。

## emscripten-lua は

- 文字列のコードでユニコードリテラルが認識されない
- gotoは無い。

## `yue -e`での実行は

- arg[0]にファイル名が入ってない
- ライブラリで`_G.pp = `で定めたはずのものが使えない
- importでライブラリが読めなくても実行が続く
- luajitでの実行を指定出来ない
