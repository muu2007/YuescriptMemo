# Turbo.luaでサーバーを作る

pythonのtornadoを移植したものらしい
luajitで動く。
~~非同期~~とか速度とかスケールできるかはよくわからない
tornadoと違い

- `Ctrl-C`で止まる。
- コマンドライン引数でポートの変更やconfigファイルの指定には対応してない？

## サンプルコード

```yuecode.lua
import 'turbo'

IndexHandler = with _G.class('IndexHandler', turbo.web.RequestHandler)
	.get = => @write"Hello #{@get_argument 'name', 'Santa Claus'}!"
	.post = => @write"Hello #{@get_argument 'name', 'Easter Bunny'}!"

UserHandler = with _G.class('UserHandler', turbo.web.RequestHandler)
	.get = (username)=> @write"Username is #{username}"

turbo.web.Application\new{
	{'/$', IndexHandler}
	{'/user/(.*)$', UserHandler}
	{'/add/(%d+)/(%d+)$', with _G.class(os.tmpname(), turbo.web.RequestHandler)
		.get = (a1, a2)=> @write"Result is #{a1+a2}"
	}
	{"/static/(.*)$", turbo.web.StaticFileHandler, "/var/www/"}
	{'/json$', with _G.class(os.tmpname(), turbo.web.RequestHandler)
		.get = => @write{header: 'collint'}
	}
}\listen(8888)
turbo.ioloop.instance()\start()
```

- イベントハンドラのクラス(インスタンスではない)を引っ掛けるよう設定してスタート
  - 引っ掛ける部分はurlの各部分をパターン(正規表現)で指定
  - [注意] 毎回新しいインスタンスが作られる。`.get`でプロパティを定めても`.post`で使えない
    application.instanceだけが常にある
  - `ioloop.instance()`はシングルトン。(細かく設定できるそうだが…)
  - サンプルにあったapplicationの変数へのだいにゅうも要らないようだ？
- middleclassを使っている。yueの予約後classとカブるが、`_G.class()`とすれば使える
- クラス名はfinalなら要らなそうだったので`os.tmpname()`で潰している
- getの引数は引っ掛けるときの正規表現のキャプチャに対応する
  URLの`?key=val`は`@get_argument`で取れる(URLパラメーターと言う)
- postはformのbuttonなどから呼ばれる。name,valueを設定しておき、`@get_argument(name, default_value)`で取る
  @requestから取れる情報もある(fileupload時のファイル名やmime形式、uriなど)
- writeにtableを渡すとjsonに変換しcontent-typeなどもよしなにやってくれるそうだ。
  文字列のとき、ヘッダがなくても(ブラウザが)htmlと認識するようだ
- StaticFileHandlerは画像を要求されると`set_header`をよしなに付けて返すようだ
- 応答までに時間がかかる場合coroutine.yieldを使って制御を一旦戻し仕事が終わったら戻ってくることができる
  `res = coroutine.yield turbo.async.task(fun, argument1, ..)`
  `res = coroutine.yield turbo.async.HTTPClient()\fetch(url)`
  srmdでは(上２例とは違って)応答は終わらせてしまって、htmlのタイマーで画像ができたら表示にしてみた。

  他にput/delete/head/optionsがある。
  putは更新に使う。deleteは削除

## REST Api

HTTPを利用する(getで情報を得る。postで情報を追加する。putで部分updateする(urlで情報を渡す)。deleteで情報を削除する)
ステートレスなのでキャッシュが可能
返すものはjsonで無くても良い(textやhtmlも)。jsonは受け取った側で整形する(jqや`python -m json.tools`で)
厳格なSOAPの代替として、お金などが関わらないところで使われる(httpsには対応しているので一定のセキュリティはある)

- sqlite3をネット越しに使えるようにできる
- urlに日本語(unicode)を使うとエスケープされて渡されるので(めんどくさいので)使わない。

## HTMLとCSSとjavascript

- turboはmustacheのテンプレートがついているが、yueのテンプレート文字列があるので使わない
- CDNというものでCSSやjavascript、アイコンフォントなどをダウンロードする必要もないそうだ。

### chart.js

canvasを用意してそれに対して各種グラフを描くライブラリ
テーブルにtype options dataを含めたものを渡す。
luaのテーブルをjsのテーブルに変換するものを書いた。
色は#ffffff(3桁と6桁8桁も可)と`'rgb(255, 255, 255)'`や`rgba(255, 255, 255, 1.0)`という形式がある
一つのカンバスに対して複数のグラフ描画をすれば重ねて複雑なものが描けるのかも

## cookie

- `secure_cookie`を使うためにはapplicationに設定をする必要がある
- SSLのバージョンが上がったためinitの中の３つの関数呼び出しをコメントアウトする必要があった。
- `clear_cookie`メソッドがundocumentだった。これは`secure_cookie`にも使える

### Beauter

classに位置などを指定する。１つのときは囲み不要

- `class='_width100 _nightblue _alignRight'`
- 高さは`style=min-height:700px`などと指定。
  他にも細かく指定するときはstyleを使うようだ。max-width:100%は効かない？

| 機能名           | 説明                                                   | 備考                                     |
| ---------------- | ------------------------------------------------------ | ---------------------------------------- |
| oグリッド        | div class=rowsの中でcol m8などとする                   |                                          |
| oオフセット      |                                                        |
| (タイポグラフィ) | 基本の書き方                                           | classは不要                              |
| (リスト)         | 〃                                                     |
| (テーブル)       | 〃                                                     | `class="_width100"`                      |
| oコンテナ        | これが配置か？ ジャンボは                              | 横100%では読みにくい場合絞るためなど     |
| oジャンボ        | 横いっぱい+中央寄せ(使いにくい→色々やるにはコンテナを) | style=heightが効かない。                 |
| 画像             | 画像にエフェクトを書けることができる                   |
| oボタン          | classで形などを指定                                    | デフォルトで角丸四角形になる             |
| oフォーム        |                                                        |
| モーダル画像     |                                                        |
| モーダルボックス |                                                        |
| ナビゲーション   | メニュー                                               | -fixedだとDropdownが見えないので使えない |
| 視差             | 画像はスクロールされても動かない                       |
| ~~アラート~~     |                                                        | markdownのnoteを使う                     |
| ツールチップ     | クリックでそばに出るもの                               |
| カード           |                                                        |
| oパン粉          | 斜線で区切られた横並び。                               | 初期値灰色。右が太字になる？             |
| アコーディオン   |                                                        |
| プログレスバー   |                                                        |
| タブ             |                                                        |
| スナックバー     | 画面下にポップアップで情報を出す                       |
| ~~ノート~~       |                                                        | markdownのnoteを使う                     |

- 色名が独特。grey→creamなど
- [x] 画像に文字重ねできた。containerでもjumboでも
- `width:100%;`は『親要素に対しての』の意味
  `width:100vw;`でウィンドウ幅いっぱいにできる
