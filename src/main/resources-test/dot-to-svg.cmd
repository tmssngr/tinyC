@echo off
set FILE=%1
echo %FILE%
"C:\Users\user\Apps\graphviz\bin\dot.exe" -Tsvg %FILE% -o %FILE%.svg
"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" %FILE%.svg

