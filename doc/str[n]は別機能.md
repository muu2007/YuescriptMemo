# str[n]は別機能

文字列は作られるとmetatable.indexにstringライブラリをセットされる。
これによってオブジェクト指向風の呼び出しができるのだが、
弊害として、str[n]という表記が多言語とは別機能で、塞ぐことは出来ない(ほぼ使わないのに)、
luacheckも何も言わない状態になっている。
他言語からのコピペ移植のときは注意
