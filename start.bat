@echo off
set LANG=ja_JP.UTF-8
call checksetting.exe

if not %errorlevel% == 0 (
	echo setting.json �ɃG���[������܂��Bsetting.json ���C�����Ă���ēx�N�����ĉ������B
	pause
) else (
	start httpserver.exe
	start tvbooker.exe

:PROCESS
	call main.exe
	call createthumbnail.exe
	call tvinfocollector.exe
	timeout 1800
	goto :PROCESS

)
