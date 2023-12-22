# ffi

luajitの拡張を使うとemscriptenでWeb版には出来ない

素のままだとヘッダを手書きしなければならない。(#defineで定義してある関数もある)
ffiexでincludeもできるが、古いのでなかなかそのまま通るものはない
zigでくるむとヘッダは認識するが薄いラッパを書かなくてはならない。

---

- ffi.loadにファイル名を書くと/usr/libから
  相対パスを書くとそれをリンクする
- ffi.cdefするとffi.Cの後に関数が生えてる
  so/dll は load すると ffi.libraryname.の後に……
- 引数と戻り地は大抵そのまま出来ちゃうが変換が必要なものも。
  整数も 53bit までならそのまま。
  C文字列はffi.string()を使って変換
- luaの関数をC側に渡すことはできるが、loveの関数を渡してImageなどのobjectを作っても、lua側に戻した時cdataとなって、userdataにならずに使えない。
  よってffiとluaの境界は単純にCの関数を使ってすぐにluaに戻るようになると思う。
  戻せるものはmallocで確保したメモリならImageData→Imageとできた。
  多値は戻せないので`ffi.new('uint32_t[1]')`で作って参照を渡して埋めてもらう。(luaは多値を返せるのでこのやり方忘れている。)
