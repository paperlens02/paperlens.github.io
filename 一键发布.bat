@echo off

echo commiting...
git add . && git commit -m "一键发布" 

echo pushing...
git push origin hexo
if %errorlevel% neq 0 pause && exit /b %errorlevel%

echo hexo generating...
hexo clean && hexo g && hexo d
if %errorlevel% neq 0 pause && exit /b %errorlevel%

echo FINISHED
pause
hexo clean
pause