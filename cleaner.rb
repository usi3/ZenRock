# -*- encoding: utf-8 -*-
require 'rubygems'
require 'addressable/uri'
require 'open-uri'
require 'hpricot'
require 'kconv'
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

cleanUp
preProcessTSFiles
