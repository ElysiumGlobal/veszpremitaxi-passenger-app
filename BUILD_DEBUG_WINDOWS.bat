@echo off
setlocal

set "ANDROID_HOME=D:\Android\skd"
set "ANDROID_SDK_ROOT=D:\Android\skd"
set "PUB_CACHE=D:\flutter-cache\pub"
set "GRADLE_USER_HOME=D:\flutter-cache\gradle"
set "TEMP=D:\flutter-cache\temp"
set "TMP=D:\flutter-cache\temp"

if not exist "%TEMP%" mkdir "%TEMP%"

D:\flutter\bin\flutter.bat pub get
if errorlevel 1 goto :error

D:\flutter\bin\flutter.bat build apk --debug
if errorlevel 1 goto :error

echo.
echo APK kesz:
echo %CD%\build\app\outputs\flutter-apk\app-debug.apk
pause
exit /b 0

:error
echo.
echo A build hibaval leallt.
pause
exit /b 1
