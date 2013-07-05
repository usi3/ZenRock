# ZenRock
TvRock, RecTestと連携して全番組自動録画を実現するためのソフトウェア

（ZenRockは次世代テレビ研究のためのTVコンテンツの活用・分析用に開発されました）

http://zenrock.tv

## 特徴
* 地デジを全自動で全番組録画
  * ※録画する放送局の数に応じて地デジチューナーが必要になります
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
  * できるだけ最新のバージョンを使って下さい
* ImageMagick(convert)

## ソフトウェア構成
（モジュール図）


## 仕様
*番組ID
	* <放送局のサービスID(4ケタ)><放送年(4ケタ)><月(2ケタ)><日(2ケタ)><時(2ケタ)><分(2ケタ)><秒(2ケタ)>
	* 例：102420130702165500, 104020130702115500


### check_setting.exe
setting.json の設定が正しいかどうかを確認するためのプログラムです。
TvRock のWeb番組表が有効になっていない場合にもエラーを出力します。
これのソースコードは check_setting.rb として同梱してあります。

### start.bat
check_setting.exe が終了コード0（エラーなし）で終了した場合に、
以降のプログラム（main.exe, createthumbs.exe, tvbooker.exe, httpserver.exe, tvcollector.exe）を起動します。

### main.exe
30分に1回の周期で次の処理を繰り返します。
* <RecordDirPath>のあるドライブの使用容量が95%を超えた場合に、録画した番組を古いものから20件削除する
* 録画が完了したTSファイルにメタ情報取得可能であることを表す印をつける
* 録画番組のメタ情報を収集し、all.json としてまとめる

### createthumbnail.exe
30分に1回の周期で次の処理を繰り返します。
* 録画が完了したTSファイルからサムネイル画像を抽出
	* ffmpeg で番組開始10秒後のサムネイル画像を抽出する
	* 何らかの理由でサムネイル画像を取得できない場合は、番組名をGoogle画像検索して1番上にヒットした画像をダウンロード、ImageMagick の convert を使って 640x360 にリサイズする。

### tvbooker.exe
3時間に1回の周期で次の処理を繰り返します。
* TvRockのWeb番組表の全番組に対して「予約」ボタンを押す

### httpserver.exe
ネットワークアダプタが複数ある場合は選択を促すメッセージを表示する。
http://localhost:10080/ または http://<LAN内でのIPアドレス>:10080/ にてサービスを開始する。
（LAN内の他のPCからも操作可能）

<table>
  <tr>
    <th>URL</th>
    <th>機能</th>
  </tr>
  <tr>
    <td>http://localhost:10080/hello</td>
    <td>サーバの生存確認を行う。ZenRockの応用ソフトを実装する際に使う。</td>
  </tr>
  <tr>
    <td>http://localhost:10080/exec?cmd=getall</td>
    <td>録画した全ての番組のメタ情報を集約している all.json をダウンロードする。</td>
  </tr>
  <tr>
    <td>http://localhost:10080/exec?image=[番組ID]</td>
    <td>番組のサムネイル画像を取得する。</td>
  </tr>
  <tr>
    <td>http://localhost:10080/ui</td>
    <td>録画した全ての番組をサムネイル・番組説明とともに一覧で表示する。</td>
  </tr>
  <tr>
    <td>http://localhost:10080/ui?sid=[sid]&q=[検索ワード]</td>
    <td>放送局のサービスID(sid)と検索ワードにヒットする番組の一覧を表示する。</td>
  </tr>
  <tr>
    <td>http://localhost:10080/ui?watch=[番組ID]</td>
    <td>サーバでVLCを起動し、該当する番組を再生する（現在はVLCのみに対応）。</td>
  </tr>
</table>


### tvinfocollector.exe
30分に1回の周期で次の処理を繰り返します。
* 録画が完了した番組に対して、（プロジェクトが提供する）サーバにその番組情報を問い合わせ、json形式でダウンロードする。


## 動作実績
* Dell XPS 8500をベースにPLEX PX-W3PE×2, PLEX PX-Q3PE, 3TB SATA HDD×2（スパンボリュームとして運用）を追加したPC
