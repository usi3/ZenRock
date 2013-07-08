# ZenRock featuring TvRock
公式Webサイト：http://zenrock.tv

ZenRockはTvRockと連携して全番組自動録画を実現するためのソフトウェアです．
このソフトウェアは次世代テレビ研究のためのTVコンテンツの活用・分析用に開発されました．


## 主要機能
* TvRockを制御してテレビ番組を自動で全て録画
	* ※全録機能は切ることもできます
	* ※録画する放送局は限定できます
	* ※録画する放送局の数に応じて地デジチューナーが必要になります
* 録画番組に対するメタ情報（番組情報・サムネイル）を自動で付加
* ブラウザから録画した番組を閲覧・検索
	* 番組の予約を担当するプログラム（後述する tvbooker.exe）を使わなければ，ユーザが手動で録画した番組に対してメタ情報を付加し，ブラウザからその一覧を閲覧・検索することもできます


## 使い方
まずはTvRockのWeb番組表から番組を録画できるようにしてください（地デジチューナやTvRock, RecTest, TVTestの詳しい設定方法については他のWebサイトを参考にしてください）．

1. TvRockで以下の項目を設定
	* 「録画基本設定」→「ファイル名置換フォーマット」を「@CH@YY@MM@DD@SH@SM@SS」に変更
		* ![TvRock:ファイル名置換フォーマットと予約登録デフォルト値](http://usi3.com/up/TvRock_setting1.png)
		* ※録画した番組がずれる場合は「予約登録デフォルト値」を調整します
	* 「チューナー」→「録画フォルダ」をこのシステム専用の録画用ディレクトリに設定
		* 以降このディレクトリをRecordDirPathと呼びます
		* ![TvRock:録画フォルダ](http://usi3.com/up/TvRock_setting2.png)

2. setting.jsonを設定
	* RecordDirPath
		* TvRockの録画フォルダとして指定したフォルダのパスを指定します
	* TVRockURL
		* TvRockのWeb番組表のURLを指定します
	* TVRockPath
		* tvrock.exe のパスを指定します．パスが通っている場合は"tvrock"だけでも大丈夫です．
	* VLCPath
		* vlc.exe のパスを指定します．パスが通っている場合は"vlc"だけでも大丈夫です．
	* ImageMagickConvertPath
		* ImageMagick の convert.exe があるパスを指定します．パスが通っている場合は"convert"だけでも大丈夫です．
	* FFMpegPath
		* ffmpeg.exe があるパスを指定します．パスが通っている場合は"ffmpeg"だけでも大丈夫です．
	* ServiceIDs
		* このシステムで処理対象としたい放送局の名前（TvRockと同じ物，@CH）とそのサービスIDを指定します．
	* DEBUG
		* ソースコードを編集・実行したい場合にご利用ください．true，もしくは false を指定します．
3. 録画用ディレクトリにwebフォルダをRecordDirPath/web/となるように配置
4. start.batを起動
	* もし設定にエラーがあるとシステムを起動せずに終了します．エラーメッセージにしたがって，setting.json を修正してください．
	* 全録せずに見たい番組だけを録画したい場合は，start_without_tvbooker.bat を起動してください．
	* 3つ（tvbookerを使わない場合は2つ）のウィンドウが開くので，しばらく見守ります．エラーが起きていなければ，全てのプログラムが動作し続けます．
	* RecordDirPath に all.json が出力されていれば，Webインタフェースを利用可能です．http://localhost:10080/ui または http://[LAN内でのIPアドレス]:10080/ui（他のPCからもアクセス可能です）にアクセスし，録画した番組の視聴・検索を楽しんでください．


### 依存ソフトウェア
このプログラムは次のソフトウェアを利用します．各ソフトウェアはできるだけ最新のバージョンを導入してください．
* TvRock
	* Ver 0.9t8で動作確認
* RecTest
* ffmpeg
* ImageMagick(convert)
* VLC

※Rubyなしで使い始められるようにソースコードに加えて実行ファイルも配布しています

## 処理の流れ
<p align="center">
	<img src="http://usi3.com/up/ZenRockFlow.png" />
</p>
それぞれの実行ファイルの仕様は以下のとおりです．

## 仕様
放送された番組を一意に特定するために次の番組IDを定義します．
* 番組ID
	* <放送局のサービスID(4ケタ)><放送年(4ケタ)><月(2ケタ)><日(2ケタ)><時(2ケタ)><分(2ケタ)><秒(2ケタ)>
	* 例：102420130702165500, 104020130702115500 など

### checksetting.exe
setting.json の設定が正しいかどうかを確認するためのプログラムです．
TvRock のWeb番組表が有効になっていない場合にもエラーを出力します．

### start.bat
checksetting.exe が終了コード0（エラーなし）で終了した場合に，
以降のプログラム（main.exe, createthumbs.exe, tvcollector.exe, httpserver.exe, tvbooker.exe）を起動します．

### cleaner.exe
次の処理を行います．

1. RecordDirPath のあるドライブの使用容量が95%を超えた場合に，録画した番組を古いものから20件削除する
2. 録画が完了したTSファイルにメタ情報取得可能であることを表す印をつける

### tvinfocollector.exe
次の処理を行います．
* 録画が完了した番組の番組情報を，（プロジェクトが提供する）サーバに問い合わせ，json形式でダウンロードする．

### createthumbnail.exe
次の処理を行います．

1. 録画が完了したTSファイルからサムネイル画像を抽出
	* ffmpeg で番組開始10秒後のキャプチャ画像を抽出しサムネイル画像とする．
2. 何らかの理由でサムネイル画像を取得できない場合は，番組名をjpg.toに渡して得られる画像をダウンロード，ImageMagick の convert を使って 640x360 にリサイズしたものをサムネイル画像とする

### organizer.exe
次の処理を行います．

1. 録画番組のメタ情報を収集し，all.json としてまとめる

### httpserver.exe
ポート10080番でHTTPサービスを開始します．
ネットワークアダプタが複数ある場合は選択を促すメッセージが表示されるので，適切なものを選んでください．
http://localhost:10080/ または http://[LAN内でのサーバのIPアドレス]:10080/ からこのサービスを利用可能です．
このHTTPサービスの機能一覧は次の通りです．
これらの機能はLAN内の他のPCからも利用可能です．

* http://localhost:10080/hello
	* サーバの生存確認を行う．ZenRockの応用ソフトを実装する際に使う．
* http://localhost:10080/exec?cmd=getall
	* 録画した全ての番組のメタ情報を集約している all.json をダウンロードする．
* http://localhost:10080/exec?image=[番組ID]
	* 番組のサムネイル画像を取得する．
* http://localhost:10080/ui
	* 録画した全ての番組をサムネイル・番組説明とともに一覧で表示する．
* http://localhost:10080/ui?sid=[sid]&q=[検索ワード]
	* 放送局のサービスID(sid)と検索ワードにヒットする番組の一覧を表示する．
* http://localhost:10080/ui?watch=[番組ID]
	* サーバでVLCを起動し，該当する番組を再生する（現在はVLCのみに対応）．

### tvbooker.exe
3時間に1回の周期で次の処理を繰り返します．
* TvRockのWeb番組表の指定放送局の番組に対して「予約」ボタンを押す

全番組を録画するための地デジチューナが足りない場合は，
コマンドライン引数として録画したい放送局のサービスIDを渡してください（例：`tvbooker.exe 1024 1032`ではNHK総合とNHK教育のみ録画）．
コマンドライン引数に何も指定されていない場合は，setting.json の ServiceIDs で指定されている放送局の全ての番組に対して処理を行います．

見たい番組だけを予約したい場合は，このプログラムを使わないでください．


## 動作実績
* Dell XPS 8500をベースにPLEX PX-W3PE×2, PLEX PX-Q3PE, 3TB SATA HDD×2（スパンボリュームとして運用）を追加したPCにて2012年6月～現在まで運用中
