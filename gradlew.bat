@echo off
where gradle >nul 2>nul
if %ERRORLEVEL% EQU 0 (
  gradle %*
  exit /b %ERRORLEVEL%
)
echo Gradle executable was not found in PATH. Open this project in AndroidIDE and use Quick Run/Build.
exit /b 1
