@echo off
rem Builds the story from src\ with Tweego (https://www.motoslave.net/tweego/).
rem Output: build\atlantis-play.html (play in a browser) and build\atlantis-twine.html (Library > Import in Twine).
setlocal
cd /d "%~dp0"
set "TWEEGO=tweego"
if exist "tools\tweego\tweego.exe" set "TWEEGO=tools\tweego\tweego.exe"
set "TWEEGO_PATH=%~dp0storyformats"
if not exist build mkdir build
"%TWEEGO%" -o build\atlantis-play.html src || exit /b 1
"%TWEEGO%" -a -o build\atlantis-twine.html src || exit /b 1
rem Images are referenced as img/<file> relative to the built HTML.
if exist build\img rmdir /s /q build\img
xcopy /e /i /q /y assets\img build\img >nul || exit /b 1
echo Built build\atlantis-play.html and build\atlantis-twine.html (with build\img)
