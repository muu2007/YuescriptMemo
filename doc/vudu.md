# vudu.lua(Love2d用デバッガ)

## 使い方

```yuecode.lua
vudu = if DEBUGMODE then require 'lib.vudu' else nil
として
love.load = ->
	vudu?.initialize()
	vudu?.initializeDefaultHotkeys()
	Game()\attach()
```

`alt-space`がウィンドウメニュー表示になっているのでPCの設定から削った。

## 変数の表示と変更

@キーでデバッガGUIの表示/非表示
日本語キーボードに`\``が無いので`@`に変更した

## ゲームのスピード変更

`a-,`でslow

## コマンドの実行

## ゲーム内でコンソールの表示

printにたちが渡された場合１個しか表示しない

## ホットキーの設定

とりあえずデフォルトでやってみる

## 物理エンジンのワイヤーフレーム表示

## デバッグ用表示

update(など)内にvudu.graphics.drawTextを書くと**後から**表示する
フォントが指定できないので、love.draw1の最後にgr.reset()を追記した
自作Sceneでは下のSceneのdrawに書くと上まで書かれてしまう(drawに書いてはいけない)

## 日本語フォントを使う

inconsolata.ttfでは日本語(ユニコード)が表示できないのでRictyDiscord-Regular.ttfをvuduのフォルダにコピー
vudu.luaを変更して表示できるようにした。
