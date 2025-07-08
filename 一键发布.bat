@echo off

echo commiting...
git add . && git commit -m "Auto Push" 

echo pushing...
git push origin hexo
if %errorlevel% neq 0 (
    echo git push failed.
    pause
    goto :end
)

echo hexo Cleaning...
hexo clean 
if %errorlevel% neq 0 (
    echo hexo clean failed.
    pause
    goto :end
)

echo hexo Generating...
hexo g
if %errorlevel% neq 0 (
    echo hexo generate failed.
    pause
    goto :end
)

echo hexo Deploying...
hexo d
if %errorlevel% neq 0 (
    echo hexo deploy failed.
    pause
    goto :end
)

echo FINISHED
pause
echo FINISHED
set /p confirm=
if /i "%confirm%" neq "Y" (
    echo FINISHED
    pause
    goto :end
)

:end
pause