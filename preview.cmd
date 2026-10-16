@echo off
rem Double-click to build the game and open it in your browser.
cd /d "%~dp0"
call "%~dp0build.cmd"
if errorlevel 1 (
  echo.
  echo The game could not be built. The message above names the file and line to fix.
  pause
  exit /b 1
)
start "" "%~dp0build\atlantis-play.html"
