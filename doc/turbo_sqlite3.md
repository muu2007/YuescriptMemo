# turbo_sqlite3

sciluaからのfork、turboでなくても動くようだ。
サンプルコードは動いた
ファイル名を空にすることによりメモリー上で動かすこともできる。
ファイルはlove2dのsavefolderではなく、実行したフォルダに出来るようだ。writeは無く`open(filename, 'rwc')`(cはcreate)
sqlite3は型を指定する必要がない(してもいい)
用語テーブル、カラム、レコード(row)、フィールド(cell)

- [ ] todo: 使うようになったらdistributeでimportのある無しでdll/soをloveに含めるか自動にしたい
- [注意]call演算子オーバーロードがされていることろは、`@conn()`ではなく`@.conn()`としなければならない

## 型

型を指定していないものはNONE型になる？

| lua                               | sqlite3 | 備考                                             |
| --------------------------------- | ------- | ------------------------------------------------ |
| nil                               | NULL    |
| bool                              | x       |
| cdata<int64_t>                    | INTEGER | 読むときは1LL(cdata)となりtonumberで実数に直せる |
| number                            | REAL    |
| string                            | TEXT    | 65535文字？                                      |
| luablob(`sqlite3.bloc('')`で作る) | BLOB    | Binary Large OBject 大きなバイナリデータ         |
| table                             | x       |
| function                          | x       |

NOT NULL成約など
ROWIDが自動で付く
インデックスを作ると検索が速くなる(辞書順に並んでないので総当りするため、ただし、追加はインデックス作成の分遅くなる)

## API

- 表示は`__call`にある(`@.obj()`とすることに注意)。これの第２引数(defaultはprint)を変えることで何ができる？
- 実行は`arr2d = conn\execute`にSQL文を与える
  [注意] 受け取った配列は`[x][y]`の順
  ppで表示するとゼロ番目にカラム名の配列、カラム名をキーとして値の配列を得る。→一行づつ得るならprepare/stepか？
  `, ROWID`で
- `rowexecute`レコード１つを取る
- setscaler("関数名", 関数) 取り出すときに値を整形するものを設定できる。`setscaler("関数名")`でundefする
- setaggregate("関数名", 初期化, 毎回, 結果)で集計することもできる。undefは上と同様に
  `setaggretate("MYSUM", (->{sum=0}), ((x)=>@sum+=x), (=>@sum))`
- prepare
  step
  reset
  resultset n回stepを回す？(終わりはnilを返す)
- bind1/bind/clearbind
  prepareしてbindしてstepで１レコード書き込む？

## SQLコマンド

- 予約語は多い。大文字小文字を気にしない。識別子として使いたいときはクォートで囲むなどする。
- テーブル名にunicodeの『記事』を使ったがエラーは出なかった。シングルクォートで囲まなくても良いらしい
- sqlite3では文末のセミコロンは必要ない
- コメントは`--`か`/*  */`
- テキストはシングルクォート囲み、エスケープは`'`

`create table personal(id, name);`
`VACUUM` -- デフラグ

## ブログ的なもの設計

### テーブルの生成

```
CREATE TABLE IF NOT EXISTS articles(title TEXT NOT NULL, content TEXT, date DEFAULT CURRENT_TIME)
```

タグを付けたい場合、タグの種類を格納したtagsテーブルとtag-articleマッピングテーブルを用意するようです

### レコード(row)の読み取り

レコード数は`n = sql\rowexec'SELECT COUNT(*) from t'`で得る(`*`をカラム名にするとそのカラムでnullを除いた数を得る)

レコード(row)毎に取り出す(最新のn個を最新からの並びで)

```yuecode.lua
stmt = @conn\prepare"SELECT *, ROWID FROM t ORDER BY ROWID DESC LIMIT 2;"
a = do
	row = {}
	while stmt\step(row) do lume.clone(row)
pp a
stmt\close()
```

### レコードの追加

sql\exec'INSERT INTO 記事(タイトル, 内容) VALUES('#{title}', '#{content}')'
