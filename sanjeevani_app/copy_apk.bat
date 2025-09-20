@echo off
mkdir build\app\outputs\flutter-apk 2>nul
copy android\app\build\outputs\apk\debug\app-debug.apk build\app\outputs\flutter-apk\app-debug.apk
echo APK copied to Flutter expected location

