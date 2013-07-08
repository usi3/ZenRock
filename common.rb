# -*- encoding: utf-8 -*-
require 'rubygems'
require 'json'
require 'kconv'
require 'open-uri'

# 設定ファイルが正しい状態にあるかどうか確認
unless File.exist?("setting.json")
  puts "setting.json doesn't exist"
  exit
end
begin
  config = JSON.parse(File.open('setting.json').read.toutf8)
rescue JSON::ParserError => e
  puts "JSON::ParserError #{e}"
  exit
end

DEBUG = config["DEBUG"]

$mediaDir = config["RecordDirPath"]
$tvnumbers = config["ServiceIDs"] # テレビ局の名前（TVRockの@CH）とテレビのサービスIDの対応
$tvrockurl = config["TVRockURL"]
$tvrockpath = config["TVRockPath"]
$vlcpath = config["VLCPath"]
$convpath = config["ImageMagickConvertPath"]
$ffmpegpath = config["FFMpegPath"]

def delete(id)
  puts "delete #{id}"
  File.delete(id+".ts") if File.exist?(id+".ts")
  File.delete(id+".json") if File.exist?(id+".json")
  File.delete(id+".png") if File.exist?(id+".png")
  File.delete(id+"_字幕.txt") if File.exist?(id+"_字幕.txt")
end

def formatString(str)
  str.toutf8.gsub("\"","").gsub(",","").gsub("\r\n","").gsub("＞","").gsub("　","").gsub(" ","")
end
