# -*- coding: utf-8 -*-
require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'kconv'
require "./common.rb"

# 現在時刻から12h分の番組表を読み込んで
# channel_list に含まれている放送局の予約リンク全てにアクセスする
def bookTVPrograms(channel_list)
  url = $tvrockurl
  begin
    doc = Hpricot(open(url+"now?h=12").read().toutf8)
  rescue => e
    p e
  end

  doc.search("/html/body/table")[3].search("td/table").each do |celltable|
    #cell.search("/table/")
    #puts celltable.inner_html.toutf8
    top = celltable.search("/tbody/tr/td/small/b")
    
    if top[0] != nil
      time = top[0].inner_text.toutf8
      nyoro = "～"
      time = time.toutf8.split(nyoro)[0] if time.length >= 6
      timeh = time.split(":")[0].to_i
      timem = time.split(":")[1].to_i
    end
    
    title = top[1].inner_text.toutf8 if top[1] != nil
    next if time == nil || title == nil
    
    # 録画中ではないリンク一覧
    # 既に予約したものは二重のtableになっている
    links = celltable.search("/tbody/tr/td//a")
    links.each do |link|
      if link.inner_html.include?("n=67")
        #puts "Twitterリンク"
      elsif link.inner_html.include?("n=24")
        #puts "検索リンク"
      elsif link.inner_html.include?("n=16")
        #puts "停止リンク"
      elsif link.inner_html.include?("n=6")
        #puts "予約リンク"
        nowh = Time.now.strftime("%H").to_i
        nowm = Time.now.strftime("%M").to_i

        hit = false
        channel_list.each do |c|
          if link[:href].include?("c=#{c}")
            hit = true
          end
        end
        next if hit == false
        
        #puts title
        if !title.include?("放送休止")
          if (timeh == nowh && timem > nowm) || timeh > nowh || timeh < nowh-1
            # (time.length > now.length || time > now || time >= hstrPlus+":00"
            puts "-----------------------------------------------------------------------"
            puts "time = #{timeh}:#{timem}, now = #{nowh}:#{nowm}"
            puts title
            puts url+link[:href]
            begin
              open(url+link[:href]) if !DEBUG && !(defined?(Ocra))
            rescue Timeout::Error
              sleep 30
            rescue Errno::ECONNREFUSED
              puts "TvRockが異常終了したのでTvRockを起動する"
              system($tvrockpath)
              puts("5分様子を見る")
              sleep 300
            rescue
              puts "Unknown error"
            end
            # TvRockが落ちないようにゆっくりアクセスする
            sleep 20 if !DEBUG && !(defined?(Ocra))
          end
        end
      else
        #puts "タイトルリンク(?)"
      end
      
    end
    #link = reglinka[0][:href] if reglinka[0] != nil
    #next if link == nil

  end
end


channel_list = ARGV.size == 0 ? $tvnumbers.values : ARGV

while true
  bookTVPrograms(channel_list)

  break if (defined?(Ocra))
  break if DEBUG
  sleep 3*60*60
end

=begin
# 予約を全て削除したいとき
url = "http://localhost:8969/nobody/"
doc = Hpricot(open(url+"now?h=12").read().toutf8)
(doc/:a).each do |link|
	href = link[:href]
	if href != nil
		if href.include?("r=2")
			puts "remove href: #{href}\n"
			open(url+href).read()
		end
	end
end
=end
