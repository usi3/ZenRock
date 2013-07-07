set LANG=ja_JP.UTF-8
set ocrapath="C:\Program Files (x86)\Ruby-2.0.0\bin\ocra"
call %ocrapath% --no-lzma checksetting.rb
icacls checksetting.exe /grant Everyone:RX
call %ocrapath% --no-lzma main.rb
icacls main.exe /grant Everyone:RX
call %ocrapath% --no-lzma createthumbnail.rb
icacls createthumbnail.exe /grant Everyone:RX
call %ocrapath% --no-lzma httpserver.rb
icacls httpserver.exe /grant Everyone:RX
call %ocrapath% --no-lzma tvbooker.rb
icacls tvbooker.exe /grant Everyone:RX
call %ocrapath% --no-lzma tvinfocollector.rb
icacls tvinfocollector.exe /grant Everyone:RX
pause
