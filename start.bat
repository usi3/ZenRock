@echo off
set LANG=ja_JP.UTF-8
call check_setting.exe

if not %errorlevel% == 0 (
	echo setting.json �ɃG���[������܂��Bsetting.json ���C�����Ă���ēx�N�����ĉ������B
	pause
) else (
	start main.exe
	start createthumbnail.exe
	start httpserver.exe
	start tvbooker.exe
	start tvinfocollector.exe
)
