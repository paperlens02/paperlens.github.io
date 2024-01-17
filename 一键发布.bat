@echo off

echo commiting...
git add . && git commit -m "Auto Push" 

echo pushing...
git push origin hexo
if %errorlevel% neq 0 pause && exit /b %errorlevel%

echo hexo C...
hexo clean 
if %errorlevel% neq 0 pause && exit /b %errorlevel%

echo hexo G...
hexo g
if %errorlevel% neq 0 pause && exit /b %errorlevel%

echo hexo D...
hexo d
if %errorlevel% neq 0 pause && exit /b %errorlevel%

echo FINISHED
pause
echo FINISHED
set /p confirm=
if /i "%confirm%" neq "Y" (
    echo FINISHED
    pause
    exit
)
pause