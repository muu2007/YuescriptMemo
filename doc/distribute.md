# distribute

開発環境(linux)では`love .`と打てばmain.luaをエントリーポイントとしてゲームが始まる
必要なファイルをzipで固めて、拡張子を.loveにするとloveファイルができる
実行時に毎回各OS用の実行ファイいるを作ってしまってもいいのではないか？
ソースからアセットを集めてくるようにした。(シングルクォート文字列からのみ→自動で直すstyluaは使えない)

## Linux

.loveファイルを配れば良い？

## Windows

- Love2Dの64bitWindowsのファイルをダウンロードしてプロジェクトのフォルダに展開しておく
- cat でくっつけると実行ファイルができる！
- upx で dll も内包させると単独.exeファイルになる
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

- luajitではない
- シンプルなものでも 60Hz 出ないことに注意
- osは'Web'と設定される
- 言語は`ja.UTF-8`でLinux Windowsと共通ではない！
  bitライブラリは使えない(互換ライブラリを読み込めばいいが…)
- goto が使えないのかも。syntax error と出る(return で代用できないか考える)
  コマンドラインオプション --target=5.1 で continueからgoto が出ないようにできる
- luajit は string format %s で true を文字列にできてしまうが、lua でも emscripten でも tostring(true)が必要
- GLSL_ES の書式は android と同じ
  x loop変数がconstantで初期化されてないというエラーが出てコンパイルできない
- love.filesystemが使えない。(コードに有ることは許される)ファイルがない時エラーで止まるという別の動作をする。これにより以下を直す tryでくるむ？
  - DEBUGMODE -- `'Web' != os`を加えた
  - autosave / load -- 〃
  - distribute -- DEBUGMODEの対応でこっちもOK
- popen非対応。(コード内に有るだけで起動しない)これにより以下が使えない
  os.capture→enet.ip
- quitやfocus(false)イベントは来ないようだ
- Clickなど操作するまで音はならない。初めて操作したときにそれまでのものがまとめて鳴る
- 文字列リテラルの中の`u{xxxx}`や`\xXX`が理解されずそのままの文字になる。半角カナも128~256の間にはならず。これらをweb版で使うなら`format%s`でやるしか無い
- 拡大描画の方法が違うのかぼける

## その他

- upxに暗号化の機能はないようだ。
- minfyしてluajit -bすることはできるが、完璧ではないし、バイトコードは32bitsと64bitsで互換性がない
