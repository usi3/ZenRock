set LANG=ja_JP.UTF-8
set ocrapath=%ocrapath%
call %ocrapath% --no-lzma check_setting.rb
icacls check_setting.exe /grant Everyone:RX
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
