# Love2Dの細かい部分

- `_G.gr = love.graphics`としている
- colorはresetなどですぐ変わってしまうため描画とセットで指定(コードゴルフ的に描画命令とまとめることもある)
- drawするときはcolorが白でないと色が変わってしまう
- noiseはそのままではperlinノイズを生成すものではない
- physicsでスイカゲーム作った。面白そうな例がないと使い道が思い浮かばない
- love.mathのbezierは２次元のみ、transformは親子関係を持たないなど微妙な使い心地のものもある。

## サードパーティ製ライブラリ

maid64
: カンバス

tween.lua
: アニメーションに
delayができるようにチェックを外す改造をしてある

love-loader
: 別スレッドでのリソースの読み込み

sqlite3
: 使ってない。マルチスレッドに対応するのかな？

3DreamEngine(3D描画)、Transfrom(親子関係？)、tove(svgの描画)

## lua以外の部分

luajitのffi整数での速い計算
ffiでCやZig言語を使った速い計算
GLSLを使ったシェーダー

速度を見るときはVsyncを外して60FPS以上にする。

## hotswap

できることは確認したが、活用できてない
ほぼmain.luaになるyueファイルをいじっているだけなので
love.loadに書いたものは２回実行されない

## gifcat

画面のキャプチャがgifで保存できる
maid64.canvasを保存することにした。そうでないと暗くなる(環境による？)
60fpsのgifは開けるアプリが無い？
保存中は重くなる→12fpsにしてframe_count%5== 0にしたら、軽くなった
linuxのみ、c-f2で開始、f2かc-f2で終了にしている
init()を再度呼ばないと、２回目が使えない(一度も呼ばずに終了するとエラーなので最初の１回も必要)

## love.thread

利用は簡単。結果をchannelにいれて返す。遅い。パッケージ再読み込みが必要。

## clipboard

love.system.getClipboardTextがあるがloveでない場合
os.captureを作り、`xsel -b`コマンドの戻り値として得る

```yuecode.lua
function M.capture(cmd, raw)
	if nil == raw then raw = true end
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then return s else return s:gsub('^%s+', ''):gsub('%s+$', ''):gsub('[\n\r]+', ' ') end
end
os.capture = M.capture
```

popenはlove.jsでHTMLに出力できないので別ファイルとして書く

Windowsの場合、ffiでwinapiを呼ぶのかな？

## ファイルの高速な読み方

- 結論: luaファイルにして`luajit -b`でバイトコードにする
- [注意] 64bitと32bitでバイトコードに互換性がない
- [注意] 各行を『キーと値(string)』以上に複雑にすると`main function has more than 65535 constants`というエラーが出て読めない
- マルチスレッドにすると起動時にブロッキングされなくなるが、読み込みまでは遅い

SKK の L 辞書を読む時間

| 名前                                      | 分類     | 説明                   | 備考                                 |
| ----------------------------------------- | -------- | ---------------------- | ------------------------------------ |
| シングルスレッド                          | 1.6s     | 各候補も分解して配列に |
| マルチスレッド                            | 3.5s     | 同上                   | 起動は早くなったが準備完了までは     |
| lua ファイルに変換                        | 読めない | 同上                   | `more than 65536 constants`          |
| シングルスレッド                          | 0.8s     | 候補はつながったまま   |
| lua ファイルに変換 (require で)           | 0.4s     | 同上                   | ネストした辞書でなければ読み込める？ |
| 更に luajit -b で bytecode に (dofile で) | 0.2s     | 同上                   |

## 描画

- gr.printfでcenteringする時半角スペースでは位置調整できない。全角スペースを使うとできる
- shaderは四角のimageを描画するときは全体を描くので全体にかかるが、図形/Textを描画する時描かない部分にはかからない
- 座標は中央しか使わなくても全画面を基準とする
- scaleは必ず右、下に伸びるので、中心(ox oy)を定めたいが使えないものがある(polygonやdrawでグラデーションmeshの時)
  ox oyは絶対位置ではなく相対位置
- stencilは、例えば図鑑一覧の各モンスター事にやると遅くなる。まとめてやることになるが、描画順序を入れ替える必要がある。

## moonshineシェーダーは少し重い

## フォント

ゲーム用には０に斜線が入らない、横幅が狭めのものがいい。

解像度1280x720で

| フォント名       | 説明                                                 | 使い道                                     |
| ---------------- | ---------------------------------------------------- | ------------------------------------------ | --- |
| M+ black         | サイズが小さい(=文字数が少ない)日本語フォント。      | 小さなパズルゲームならこれ一つでなんでも   |
| BIZ-UDPGothic    | 視認性の高い日本語フォント(ゲーム向けには思えないが) | 12ptでPCゲーの小さいテキストくらいの大きさ |
| montserrat       |                                                      |                                            |
| trta_numbers     | 見やすい数字フォント                                 |
| DSEG             | セグメント数字フォント                               |
| typicons         | アイコン集                                           |
| fontopo          |                                                      |                                            |
| ニコモジ+v2      |                                                      |                                            |
| rational integer |                                                      |                                            |
| subway           |                                                      |                                            |     |
| うえまる         |                                                      |                                            |

### subsetを作った。

M+でもサイズが1.2Mくらい増えるので、softgamepadに使う矢印とasciiを抜き出したsubsetを作った。
Windowsアプリ(Wineで動いた)を使った。
他にpython-fonttoolsやfontforgeでもできそう。

## アニメーション

- 点滅はtimeを周期で割ったあまりを使えば良い。
- パレットアニメのようなものはlume.pingpongを使って数色を行ったり来たりする
- tweenでfadingなどを表す
- dtと実時間でやるとframe間のゆらぎを気にしなくていいが、ｎ秒に１回何かをするには`framecount%100==0`のほうがやりやすい。
  framecountはtime+=dtしないときもカウントアップするので、ゲームが一時停止するようなアニメを含む時は使えない。
- 何も変更しない、または変更量を０とすることもできる。onfinishも作ったので動かない(null strategyパターンに似てる？)を扱える。

tween.luaを改造してdelayできるようにした。
全てのプロパティが見えるので、待っている間ゴールを変更することができる
(ゴールに達したら外側からclockを0(もしくは負の値)にすることで繰り返し動作にすることもできる)
以下はHPゲージ(ダメージがすぐに反映するもの(hp)と、追いかけて減っていくもの(hp2)があるもの)

```yuecode.lua
		if @tween_hp2
			if @tween_hp2.clock<0 then @tween_hp2.target.hp2 = @hp
			if @tween_hp2\update(dt) then @tween_hp2 = nil
		elseif @hp != @hp2
			@tween_hp2 = with tween.new(0.4, @, {hp2: @hp}, 'outCubic')
				.clock = -0.7
```

lume.pingpongを使って心臓の鼓動のようなものを表現する
pingpongは0〜1を行ったり来たりするもので、time(dtを累計していく)を与える。
その一部だけ使って(他は０や１にする)scaleをいじれば、ドクンドクンとするようになる。
`scale = math.max(lume.pingpong(@time*2)-0.75, 0)`

### boxでレイアウト

boxを`{l,t,w,h}`と定めた。理由はいくつかのライブラリでそうなっているようだから
alignの各関数で端から切り分けていったりする。
`div_h`と`div_v`で分割し、表のような描画の助けとする。
n等分分割と、配列を渡してその比率で分割するものにした。
間に隙間を挟むとデザインの調整がしやすくなる。(N段の表示をしたい時2N+1個に分割して、偶数インデックスのみ使う)
ピクセル単位には分割しにくい、正方形などにも同じ様に

### scissorとstencil

scissorは四角形に切り抜いて描画、stencilは描画した形に切り抜いて描画する(stencilとsetStencilTestをセットで使う)
フォントは切り抜きに使えない？

| 関数名                 | 説明                                     | 備考                     |
| ---------------------- | ---------------------------------------- | ------------------------ |
| gr.setScissor(x,y,w,h) | 解除するまではそのエリアにのみ描画される | 引数なしで呼んで解除する |
| gr.stencil()           |                                          |
| gr.setStencilTest()    |                                          | 引数なしで呼んで解除する |

## input

## ui

## ネット

## アニメーション

1. timeをnで割ったあまりを使うと点滅が作れる
2. lume.pingpong/sinカーブなどを使うと、３色を行ったり来たりができる
   0.5以下を無視すると心臓の鼓動のようなものを表現することができる
3. tween.luaを使うとfill-in/fill-outのようなアニメーションを作れる
   ゴールに達したときに外からclockを戻せば繰り返しを表現できる

| 関数名              | 説明 |
| ------------------- | ---- |
| lume.pingpong(time) |

## その他
