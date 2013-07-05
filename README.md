# ZenRock
TvRock, RecTestと連携して全番組自動録画を実現するためのソフトウェア
（このソフトウェアはテレビコンテンツの研究を目的に開発されました）

このプロジェクトは、次世代テレビ研究のためのTVコンテンツの活用・分析用に開発された全自動放送録画システムです。


## 特徴
* 地デジを全自動で全録
* 録画ファイルに対するメタ情報（番組情報・サムネイル）を自動で付加
* ブラウザから録画した番組一覧を閲覧・検索

## 使い方
+ TvRockのWeb番組表を使えるようにする
+ 追加でTvRockに次の項目を設定する
  + 録画先
  + 録画ファイル名
+ setting.jsonを設定する
  + 録画用ディレクトリにweb.zipを解凍(<RecordDirPath>/web/となるように配置して下さい)
+ start.batを起動
  + 設定エラーがあるとシステムを起動せずに終了します

### 依存ソフトウェア
* TvRock
* RecTest
* ffmpeg
* ImageMagick(convert)

## ソフトウェア構成
（モジュール図）


## 仕様

### start.bat

### main.exe

### createthumbs.exe
### tvbooker.exe
### check_setting.exe
### httpserver.exe
### tvcollector.exe


## 動作実績
* Dell XPS 8500をベースにPLEX PX-W3PE×2, PLEX PX-Q3PE, 3TB SATA HDD×2（スパンボリュームとして運用）を追加したPC
