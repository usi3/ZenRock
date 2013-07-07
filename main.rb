# -*- encoding: utf-8 -*-
require 'rubygems'
require 'addressable/uri'
require 'open-uri'
require 'hpricot'
require 'kconv'
require 'json'
require "./common.rb"

def cleanUp
  Dir.chdir($mediaDir)
  
  # ディスクの使用率を調べる．Windows限定だが速い
  ma = `df #{$mediaDir}`.split("\n")[1]
  ratio = $1.to_i if /.+?(\d+)%.+?/ =~ ma
  puts "#{ratio}% used"
  
  if ratio >= 95
    puts "start auto deleting"
    # 該当ファイルをリストアップ
    list = Dir.glob("*.ts").delete_if{|x| x =~ /(\D+)(\d+)(\.ts)/ }
    # 古い順に並び替える
    list.sort!{|x, y| x[4..-1].to_i <=> y[4..-1].to_i }
    # 先頭20個を消す
    count = 0
    list.each do |ts|
      name = ts.gsub(".ts","")
      puts "delete #{name}"
      begin
        delete(name)
      rescue
      end
      count += 1
      break if count >= 20
    end
  end
end

def preProcessTSFiles
  puts "preProcessTSFiles"
  # 録画されている途中の番組を避けて処理すべき対象TSを探す
  # ファイル名は番組IDに変更する
  Dir.chdir($mediaDir)
  
  list = Dir.glob("*.ts").delete_if{|x| x =~ /^\d+\.ts/ }.reverse # Default: old order
  
  checked = Hash.new
  list.each do |file|
    # テレビ局の名前が直接含まれているファイルを列挙
    if file =~ /(\D+)(\d+)(\.ts)/
      # puts "check #{file}"
      if checked[$1] == nil
        checked[$1] = true
        
        size1 = File.size(file)
        sleep 5
        size2 = File.size(file)
        if size1 != size2
          # このファイルは録画中
          puts "#{file} recording now"
          next
        end
      end
      begin
        id = $tvnumbers[$1].to_s+$2+$3
        File.rename(file, id) unless DEBUG
        puts "File.rename(#{file}, #{id})"
      rescue Errno::EBUSY
        # ignore
      end
    end
  end
  
  puts "done renaming"
end

def combineAllJSONs
  puts "combineAllJSONs"

  list = []
  Dir.chdir($mediaDir)
  Dir.glob("*.json").each do |file|
    if !File.exist?(file)
      puts "error: can't open #{file}"
      next
    end
    
    name = file.gsub(".json","").toutf8
    tsFileName = name+".ts"
    thumbFileName = name+".png"
    
    if name == "all"
      next
    end
    
    if /(\d\d\d\d)(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/ =~ name
      tvcode = $1.to_i
      year = $2.to_i
      month = $3.to_i
      day = $4.to_i
      hour = $5.to_i
      minute = $6.to_i
      second = $7.to_i
      idday = Time.local(year, month, day, hour, minute, second)
    end
    
    f = File.open(file, "r")
    newone = f.read.toutf8
    f.close
    
    begin
      json = JSON.parse(newone)
    rescue JSON::ParserError
      puts "error: parse error #{name}"
      File.delete(file)
      next
    rescue Errno::EACCES
      puts "error: can't open #{name}"
      # 今はどうしようもないのでまたあとで
      next
    end
    if json["title"] == nil || json["duration"] == nil
      puts "error: json file is wrong #{file}"
      # jsonファイルがまともに生成されていない
      next
    end
    
    # サムネイルの存在確認
    if File.exist?(thumbFileName)
      thumbsize = File.stat(thumbFileName).size
    else
      if idday < Time.now
        # TSファイルからサムネイルを生成できない場合
        next
      else
        # 未来の番組まで含めるので、thumbsize = 0としておく
        thumbsize = 0
      end
    end
    json["thumbsize"] = thumbsize
    
    # TSファイルの存在確認
    tsFileSize = 0
    if File.exist?(tsFileName)
      tsFileSize = File.stat(tsFileName).size
    end
    json["tsfilesize"] = tsFileSize
    
    list.push json
  end
  
  puts "done"
  return list.to_json
end


cleanUp
preProcessTSFiles

out = File.open("#{$mediaDir}all.json", "w")
out.puts combineAllJSONs
out.close
