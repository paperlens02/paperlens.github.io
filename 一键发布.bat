@echo off
git add . & git commit -m "Auto Push"
pause
git push origin hexo
pause
hexo clean && hexo g && hexo d
pause
hexo clean