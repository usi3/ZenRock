# -*- coding: utf-8 -*-
require 'rubygems'
require 'open-uri'
require 'net/https'
require 'kconv'
require "./common.rb"

#puts "My process id = #{$$}"

Dir.chdir($mediaDir)
Dir.glob("*.ts").each do |tsfile|
  if tsfile =~ /(\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d)\.ts/
    id = $1
    unless File.exist?(id+".json")
      url = "http://49.212.161.165:10085/exec?tvinfo=" + id
      puts "tvinfo:#{id}"

      src = ""
      begin
        req = Net::HTTP::Get.new(url)
        req.basic_auth("YouHaveWitnessedTooMuch", "Cf3QsMXRpJ_8XCAR5BkGtNSwBj4TSDh8NNGsJJgm5uuaKe7dZ2SC5c8Acjt4-mNg")
        Net::HTTP.start("49.212.161.165", 10085) do|http|
          response = http.request(req)
          src = response.body.toutf8
        end
      rescue => e
        puts "Network connection error: #{e}"
        next
      end

      begin
        out = File.open(id+".json", "w")
        out.puts src
        out.close
      rescue => e
        puts "Can't write: #{e}"
        File.delete(id+".json") if File.exist?(id+".json")
      end
    end
  end
  #break if (defined?(Ocra))
end

