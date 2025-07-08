
echo commiting... >> error.log
git add . && git commit -m "Auto Push" 

echo pushing... >> error.log
git push origin hexo
if %errorlevel% neq 0 (
    echo git push failed. >> error.log
    goto :end
)

echo hexo Cleaning... >> error.log
hexo clean 
if %errorlevel% neq 0 (
    echo hexo clean failed. >> error.log
    goto :end
)

echo hexo Generating... >> error.log
hexo g
if %errorlevel% neq 0 (
    echo hexo generate failed. >> error.log
    goto :end
)

echo hexo Deploying... >> error.log
hexo d
if %errorlevel% neq 0 (
    echo hexo deploy failed. >> error.log
    goto :end
)

:end
echo FINISHED >> error.log
pause
echo FINISHED >> error.log
set /p confirm=
if /i "%confirm%" neq "Y" (
    echo FINISHED >> error.log
)

pause