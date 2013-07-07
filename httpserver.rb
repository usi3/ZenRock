# 異常操作について考えていない & 著作権保護のため決してポート開放しないこと
require 'rubygems'
require 'cgi'
require 'webrick'
require 'kconv'
require 'socket'
require "./common.rb"

# kill -9 `ps | grep [r]uby | awk '{print $1}'`

# サーバの生存確認用
# http://localhost:10080/hello?name=zen6kun
class HelloServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    if req.query['name']
      res.body = "Hello #{req.query['name']}."
    else
      res.body = "Hello world."
    end
    res['Content-Type'] = 'text/plain'
  end
end

# 応用ソフト用
class ClientServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    puts "req.query['cmd']=#{req.query['cmd']}"

    if req.query['cmd'] == "getall"
      # http://localhost:10080/exec?cmd=getall
      # 必ずall.jsonが存在すると仮定する
      res.body = File.open($mediaDir+"all.json").read
      res.content_type = 'application/json; charset=UTF-8'
    elsif req.query['cmd'] == "rate"
      # http://localhost:10080/exec?cmd=rate&serialid=[]&videoid=[]&rate=[]
      serialid = req.query['serialid']
      videoid = req.query['videoid'].to_i
      rate = req.query['rate'].to_f
      puts "serialid=#{serialid}, videoid=#{videoid}, rate=#{rate}"
    elsif req.query['image']
      # http://localhost:10080/exec?image=[id]
      name = $mediaDir + "#{req.query['image']}.png"
      if File.exist?(name)
        res.body = File.open(name).binmode.read
        res.content_type = 'image/png'
      else
        res.status = 404 # Not Found
      end
    else
      res.body = "Hello world."
      res.content_type = 'text/plain'
    end
  end
end

# Web Interface UI
# http://localhost:10080/ui
class UIServlet < WEBrick::HTTPServlet::AbstractServlet
  def convertAllToHTML(sid, search)
    begin
      all = JSON.parse(File.open("../all.json", "r").read.toutf8)
      content = File.open("content.htm", "r").read.toutf8
      frame = File.open("frame.htm", "r").read.toutf8
    rescue
      puts "error"
      return
    end
    
    all.sort!{|a, b| b["id"].to_s[4..-1] <=> a["id"].to_s[4..-1]} # 新しい順

    lis = []
    all.each do |tv|
      # search
      if search != nil
        next unless tv["title"].include?(search) || tv["genre"].include?(search) || tv["description"].include?(search) || tv["contents"].include?(search)
      end

      # sid
      if sid != nil
        next if tv["id"].to_s[0..3] != sid.to_s
      end

      # 番組ごとのHTML
      li = ""
      li << content.gsub("%IMGURL%", "/exec?image=" + tv["id"].to_s).gsub("%TITLE%", tv["title"]).gsub("%ABSTRACT%", tv["description"]).gsub("%WATCHURL%", "/ui?watch=#{tv["id"]}")
      li << "\r\n"
      lis.push li

      break if lis.size >= 4 * 39 if DEBUG
    end

    # 番組ごとのHTMLを組み合わせる
    ret = ""
    i = 0
    while i < lis.size
      if i%4 == 0
        inner = ""
      end
      inner << lis[i]
      inner << "\r\n"
      if i%4 == 3
        ret << frame.gsub("%LIS%", inner)
        ret << "\r\n"

      end
      i += 1
    end
    if (i-1)%4 != 3
      ret << frame.gsub("%LIS%", inner)
      ret << "\r\n"
    end

    return ret
  end

  def createWeb(sid, search)
    puts "createWeb"

    Dir.chdir($mediaDir)
    Dir.mkdir("web") if !Dir.exist?("web")
    Dir.chdir("web")

    ret = ""
    nav = ""
    $tvnumbers.keys.each do |key|
      nav << "<li><a href=\"ui?sid=#{$tvnumbers[key]}\">#{key}</a></li>"
    end
    ret << File.open("head.htm", "r").read.gsub("%NAV%", nav)
    html = convertAllToHTML(sid, search)
    ret << html
    ret << File.open("tail.htm", "r").read

    return ret
  end

  def do_GET(req, res)
    # http://localhost:10080/ui?sid=[1024,1032,1040,1048,1056,1064,1072]&q=[URL encoded query words]

    if req.query['watch'] != nil
      puts "watch"
      videoid = req.query['watch']
      cmd = "#{$vlcpath} file:///#{$mediaDir}#{videoid}.ts --quiet" # 現在はVLCのみに対応
      puts cmd
      t = Thread.new{ system(cmd) }
      res.content_type = 'text/html'
      res.body = "<html><body onLoad='window.close();'></body></html>"
    else
      sid = req.query['sid'].to_i
      sid = nil unless $tvnumbers.values.include?(sid)
      puts "sid = #{sid}"

      search = req.query['q']
      search = CGI.unescape(search) if search != nil
      search = nil if search == ""
      puts "search = #{search}"

      res.content_type = 'text/html'
      res.body = createWeb(sid, search)
      res.chunked = true
    end
  end
end

addressList = Socket.getaddrinfo(Socket::gethostname, nil, Socket::AF_INET)
addressList.each_index do |i|
  puts "index:#{i}"
  p addressList[i]
end

if (defined?(Ocra))
  index = 0
else
  if addressList.size <= 0
    puts "Unknown error."
    exit
  end

  if addressList.size >= 2
    puts "select interface index[default:0]: "
    index = STDIN.gets.to_i
  else
    index = 0
  end
end

#
myIP = Socket.getaddrinfo(Socket::gethostname, nil, Socket::AF_INET)[index][3]
puts "myIP = #{myIP}"

server = WEBrick::HTTPServer.new({:DoNotReverseLookup => true, :Port => 10080, :BindAddress => myIP, :DocumentRoot => './'})
server.mount('/hello', HelloServlet)
server.mount('/exec', ClientServlet)
server.mount('/ui', UIServlet)
trap('INT') { server.shutdown }

if (defined?(Ocra))
  Thread.new {
    sleep 3
    puts "server.stop"
    server.stop
  }
end

server.start

