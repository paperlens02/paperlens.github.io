@echo off

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