@echo off
set LANG=ja_JP.UTF-8
call check_setting.exe

if not %errorlevel% == 0 (
	echo setting.json にエラーがあります。setting.json を修正してから再度起動して下さい。
	pause
) else (
	start main.exe
	start createthumbnail.exe
	start httpserver.exe
	start tvbooker.exe
	start tvinfocollector.exe
)
