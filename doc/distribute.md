# distribute

開発環境(linux)では`love .`と打てばmain.luaをエントリーポイントとしてゲームが始まる
必要なファイルをzipで固めて、拡張子を.loveにするとloveファイルができる
実行時に毎回各OS用の実行ファイいるを作ってしまってもいいのではないか？
ソースからアセットを集めてくるようにした。(シングルクォート文字列からのみ→自動で直すstyluaは使えない)
本来ならpostトランスパイルとして別ファイルにするべきだが、実行時にやっている。早く実行したいのと、love.threadの練習として。

## Linux

.loveファイルを配れば良い？

## Windows

- Love2Dの64bitWindowsのファイルをダウンロードしてプロジェクトのフォルダに展開しておく
- cat でくっつけると実行ファイルができる！
- ~~upx で dll も内包させると単独.exeファイルになる~~upxはまとめる機能はない模様
- wineで動いた
- getOS()→'Windows'
- パスの区切り文字 os.sep = package.config\sub(1,1)と取れた
- 改行への対応。\r\n
- ターミナルが sjis?← これは無理
- gifcat.dll

## Android

- Love2D(ver. 11.4)をサイトからダウンロードして入れて .loveファイルをテストする
- apkファイルも作れるらしい
- レトロ表現としてspritebatchでタイル描画すると汚い？
- draw中にスクリーンカンバス、maid64のカンバスを行ったり来たりするとちらつく
- GLSL_ESではconstant以外は全て関数の中に書く。また、実数を5などと書けない5.0と書く
- quitイベントが来ない?
- maid64カンバスがスクリーンより大きいとき、fpsが下がる？
- 画面回転に追従する。固定する方法が見つからない
- 画面を消してもゲームは止まらない(バッテリー消費し続ける)?

## HTML5(Web)

1. `npx love.js #{PROJECTNAME}.love html\_#{PROJECTNAME} -c -t \"#{PROJECTNAME..' -v '..VERSION}\"`
2. webサーバー起動`python -m http.server 8000`
3. ブラウザでlocalhost:8000を開く

- jitではない
- シンプルなものでも 60Hz 出ないことに注意
- osは'Web'と設定される
- 言語は`ja.UTF-8`でLinux Windowsと共通ではない！
  bitライブラリは使えない(互換ライブラリを読み込めばいいが…)
- goto が使えないのかも。syntax error と出る(return で代用できないか考える)
  コマンドラインオプション --target=5.1 で continueからgoto が出ないようにできる
- luajit は string format %s で true を文字列にできてしまうが、lua でも emscripten でも tostring(true)が必要
- GLSL_ES の書式は android と同じ
  x loop変数がconstantで初期化されてないというエラーが出てコンパイルできない
- ~~love.filesystemが使えない。~~→love-js-api-playerで使えるようにできる
  ファイルがない時エラーで止まるという別の動作をするためreadの前にgetinfoでファイルがあるか調べる必要がある。
  - DEBUGMODE -- `'Web' != os`を加えた
  - distribute -- DEBUGMODEの対応でこっちもOK
- popen非対応。(コード内に有るだけで起動しない)これにより以下が使えない
  os.capture→enet.ip
- タブを閉じる時quitイベントは来ないようだ。別のタブに移ればfocusイベントは来るようだ
- Clickなど操作するまで音はならない。初めて操作したときにそれまでのものがまとめて鳴る
- 文字列リテラルの中の`u{xxxx}`や`\xXX`が理解されずそのままの文字になる。半角カナも128~256の間にはならず。
  ~~これらをweb版で使うなら`format%s`でやるしか無い~~
  vimではインサートモード内で`<c-r>=nr2char(0xe0df)`などで打ち込める。(vimのフォントによっては違う見た目や、全く見えなかったりする)
- 拡大描画の方法が違うのかぼける(Windowもmaid64を同じ解像度(1280x720)にしたら大丈夫)
- [x] fullscreenにした時、座標が狂う
      → getOS getFullscreenなどで場合分け、getDesktopDimensionsとgetDimensionsでoffsetとscaleを計算すれば直せる

### 生成されるindex.htmlを書き換え

生成されるindex.htmlをテンプレートで変えることはできないので、生成後に書き換えるようにする。

- いくつかの行を書き換え、追加する部分はひとまとまりとしたい。
  styleタグlinkタグはbodyにも書けるそうなので、(背景色テキスト色やフォント指定など)追記するものを一箇所にまとめておける
- Beauter.cssを使うようにした。
  pandoc markdown(pandoc gfmではなく)ではid,classその他を`{#id .class key=val key=val..}`の形式でかける
  が、`.class`形式ではアンダースコアで始まるものなどを書けないので`key="val"`で`class="_primary"`などと書く。
  このvalにアンダースコアなどがある場合ダブルクオーテーションで囲まないとpandocで認識しないようで、全体を`[[]]`で囲むようにした。
  この方法でいくつかはmarkdownで書ける(いくつかはhtml直書きになる) modalimgは生成する関数を書いた。
- javascriptのquoteのエスケープがうまくできない場合(onclockの中など)は`&quot;`で代用できる。

### Github Pagesで公開

1. html_PROJECTNAMEフォルダで`git init`して、全ファイルをcommitしてgithubにpush
2. githubのページのsettingからpagesnを選びソースをmasterにしsaveを押す。
   `https://ユーザー名.github.io/PROJECTNAME/`に公開される

AndroidのFireFoxBetaで見てもspritebatchのタイル表示が汚くならない

## その他

- upxに暗号化の機能はない。
- minfyしてluajit -bすることはできるが、完璧ではないし、バイトコードはluajitの32bitsと64bitsで互換性がない
