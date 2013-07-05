# -*- encoding: utf-8 -*-
require 'rubygems'
require 'json'
require 'kconv'
require 'open-uri'

def checkString(str)
	return false if str == nil
	return false if str == ""
	return true
end

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

wrong = false

if checkString(config["RecordDirPath"]) == false
	puts "RecordDirPath is wrong: #{config['RecordDirPath']}" 
	wrong = true
end
if config["ServiceIDs"] == nil
	puts "ServiceIDs is nil"
	wrong = true
end

if checkString(config["TVRockURL"]) == false
	puts "TVRockURL is wrong"
	wrong = true
end

begin
	open(config["TVRockURL"])
rescue
	puts "TVRock is not available. Please launch it."
	wrong = true
end

if File.exist?(config["TVRockPath"]) == false
	puts "TVRockPath is wrong. File.exist?(config['TVRockPath']) = false"
	wrong = true
end

if File.exist?(config["VLCPath"]) == false
	puts "VLCPath is wrong. File.exist?(config['VLCPath']) = false"
	wrong = true
end

if !`#{config["ImageMagickConvertPath"]} -v`.include?("ImageMagick")
	puts "ImageMagickConvertPath is wrong. I can't start it."
	wrong = true
end

if !`#{config["FFMpegPath"]} -version`.include?("ffmpeg")
	puts "FFMpegPath is wrong. I can't start it."
	wrong = true
end

exit 1 if wrong

puts "All settings are correct."
exit 0


