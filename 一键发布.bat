@echo off
git add . & git commit -m "一键发布" & git push origin hexo
hexo clean && hexo g && hexo d
pause