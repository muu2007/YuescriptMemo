# HTML

markdownとHTML直書きを使う。装飾はBeauterに任せる(記述が短いから)。
turboはmustache(HTMLテンプレートシステム)を使わずにyueのテンプレート文字列、内包表記、table.concatなどでやる
できるならCDNを使ってファイル数も減らす。

## pandocで部分HTMLを生成

`-s`オプションで全体のHTMLファイルを作ることができるが、つけないと用意したHeaderとfooterの間の部分だけを生成することができる。
pandoc markdownはpandoc gfmよりもVSCodeにあるMPE(MarkdownPreviewEnhanced)寄りの機能がある。
現在styleタグなどをbodyに書いていいことになったので(初期描画が乱れるとか速度的には…だが)、ひとまとまりにして生成する

## フォント

CDNで

```{.html}
<!-- HTML：CDNリンクを貼り付け -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/yakuhanjp@4.0.1/dist/css/yakuhanjp.css">

// CSS：font-familyを設定
.body {
  font-family: YakuHanJP, "Hiragino Sans", "Hiragino Kaku Gothic ProN", "Noto Sans JP", Meiryo, sans-serif;
}
```

## Beauterを使う。

CDNで数行書き加えれば使える
classに色々指定するとそれなりの表現になる。１つのときは囲み不要

| `class='_width100 _nightblue _alignRight'`
|
| 高さは`style=min-height:700px`などと指定。
| 他にも細かく指定するときはstyleを使うようだ。max-width:100%は効かない？

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

## chart.js

canvasを用意してそれに対して各種グラフを描くライブラリ
テーブルにtype options dataを含めたものを渡す。
luaのテーブルをjsのテーブルに変換するものを書いた。
色は#ffffff(3桁と6桁8桁も可)と`'rgb(255, 255, 255)'`や`rgba(255, 255, 255, 1.0)`という形式がある
一つのカンバスに対して複数のグラフ描画をすれば重ねて複雑なものが描けるのかも

## Mermaid

## 地図

## フォーム

fieldsetは囲み
`<form method=post onsubmit=""></form>`で入力値の検証ができる。snackbarの表示もできた(記述が短くて良い)

```

```

```

```
