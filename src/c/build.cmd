@echo off
call :compile print-string.c
call :compile print-uint.c
call :compile long-parameter-list.c
exit

: compile
%USERPROFILE%\Apps\TCC\tcc.exe %~1
if %errorlevel% neq 0 (
	pause
)
