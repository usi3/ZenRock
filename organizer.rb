# -*- encoding: utf-8 -*-
require 'rubygems'
require 'kconv'
require 'json'
require "./common.rb"

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

out = File.open("#{$mediaDir}all.json", "w")
out.puts combineAllJSONs
out.close
