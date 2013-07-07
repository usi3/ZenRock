# -*- encoding: utf-8 -*-
require 'rubygems'
require 'addressable/uri'
require 'open-uri'
require 'hpricot'
require 'kconv'
require 'json'
require "./common.rb"

# 番組名から邪魔な要素を消して、純粋な番組の名前だけを抽出する
# 本当はきちんと品詞分類すべき
def normalizeProgramTitle(title)
  # 意味のない文字列は除く
  title = title.gsub(/^アニメ　/, "")
  title = title.split("　")[0] if title.include?("　")
  title = title.gsub(/「.*$/, "")
  title = title.gsub(/\(.*\)/, " ").gsub(/\[.*\]/, " ").gsub(/（.*）/, " ").gsub(/【.*】/, " ").gsub(/第.*話/, " ").gsub(/～.*～/, " ").gsub(/<.*>/, " ")
  title = title.gsub(/#\S+/, " ").gsub("！", " ").gsub("!", " ").gsub("？", " ").gsub("?", " ").gsub("＆", " ").gsub("&", " ").gsub(":", " ").gsub("・", " ").gsub("☆", " ").gsub("．"," ").gsub("."," ").gsub("～"," ").gsub("＜"," ").gsub("＞"," ").gsub("【"," ").gsub("】"," ").gsub("…"," ").gsub("+"," ").gsub("＋"," ")
  title = title.split(" ")[0] if title.include?(" ")
  
  title
end

def downloadImageFromJPGTO(keyword, filename)
  keyword = "empty" if keyword == nil || keyword == ""
  url = Addressable::URI.parse("http://"+keyword+".jpg.to/").normalize.to_s
  #
  begin
    src = open(url).read.toutf8.strip
  rescue => e
    p e
    puts keyword
    puts url
  end
  doc = Hpricot(src)
  doc.search("img") do |img|
    # puts img[:src]
    written = false
    open(filename, 'wb') do |file|
      data = open(img[:src]).read
      if data && data.size != 0
        file.write data
        written = true
      end
    end
    if written
      comm = "#{$convpath} #{filename} -gravity center -resize 640x360^ -extent 640x360 #{filename}"
      puts comm
      system(comm)
    end
  end
end

def createThumbnail(id)
  unless File.exist?(id+".png")
    puts "createThumbnail(#{id})"
    comt = Thread.new{
      # 開始から10秒後のキャプチャ画像をサムネイルとする
      # ffmpegのバージョンによってはこのコマンドライン引数は通らないかもしれない
      system("#{$ffmpegpath} -loglevel 0 -i #{id}.ts -f image2 -ss 00:00:10 -vframes 1 -s 640x360 -an -deinterlace #{id}.png")
    }
    # ffmepg が暴走するケースがある
    checkt = Thread.new{
      sleep 5 * 60
      if !File.exist?(id+".png") || File.stat(id+".png").size == 0
        puts "5分経ってもサムネイルを生成できていないので停止 #{id}"
        comt.kill
      end
    }
    comt.join
    checkt.kill
    
    if !File.exist?(id+".png") || File.stat(id+".png").size == 0
      puts("サムネイルを作れないのでマッチする画像をjpg.toからダウンロードする")
      
      begin
        f = File.open(id+".json", "r")
        json = JSON.parse(f.read.toutf8)
        newTitle = normalizeProgramTitle(json["title"])
      rescue Errno::ENOENT
        puts "JSONファイルが存在しない"
        delete(id)
      rescue JSON::ParserError
        puts "JSON::ParserError #{id}"
      ensure
        f.close if f != nil
      end
      
      begin
        downloadImageFromJPGTO(newTitle, id+".png")
      rescue Addressable::URI::InvalidURIError
        puts("アドレスがおかしい #{newTitle}")
      rescue ArgumentError
        puts("対応する画像がない #{newTitle}")
      rescue => e
        puts "error: #{id} #{newTitle}"
        p e
      end    
    end
  end
end


# TSファイルからサムネイル画像を生成する
Dir.chdir($mediaDir)
Dir.glob("*.ts").each do |tsfile|
  if tsfile =~ /(\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d)\.ts/
    id = $1
    createThumbnail(id)
  end
end
