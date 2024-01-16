@echo off
git add . & git commit -m "一键发布" & git push origin hexo
pause
hexo clean && hexo g && hexo d
pause