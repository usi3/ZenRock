@echo off
set LANG=ja_JP.UTF-8
call check_setting.exe

if not %errorlevel% == 0 (
	echo setting.json にエラーがあります。setting.json を修正してから再度起動して下さい。
	pause
) else (
	start httpserver.exe

:PROCESS
	call main.exe
	call createthumbnail.exe
	call tvinfocollector.exe
	timeout 1800
	goto :PROCESS

)
