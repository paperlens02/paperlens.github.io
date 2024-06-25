@echo off

echo commiting...
git add . && git commit -m "Auto Push" 

echo pushing...
git push origin hexo
if %errorlevel% neq 0 (
    echo git push failed.
    pause
    exit /b %errorlevel%
)

echo hexo Cleaning...
hexo clean 
if %errorlevel% neq 0 (
    echo hexo clean failed.
    pause
    exit /b %errorlevel%
)

echo hexo Generating...
hexo g
if %errorlevel% neq 0 (
    echo hexo generate failed.
    pause
    exit /b %errorlevel%
)

echo hexo Deploying...
hexo d
if %errorlevel% neq 0 (
    echo hexo deploy failed.
    pause
    exit /b %errorlevel%
)

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