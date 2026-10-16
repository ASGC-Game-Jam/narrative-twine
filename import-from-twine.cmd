@echo off
rem Double-click after saving a Twine "Export As Twee" file into this folder.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\import-from-twine.ps1"
