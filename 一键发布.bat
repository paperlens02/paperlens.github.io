@echo off

echo commiting...
git add . && git commit -m "Auto Push" 

echo pushing...
git push origin hexo
if %errorlevel% neq 0 pause && exit /b %errorlevel%

echo hexo Cleaning...
hexo clean 

pause

echo hexo Generating...
hexo g

pause

echo hexo Deploying...
hexo d

pause

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