---
title: 相关外链
date: 2022-06-20 11:08:47
tags:
- hexo
- git
categories: 
- 技术
---

[菜鸟教程_Markdown](https://www.runoob.com/markdown/md-tutorial.html)

[hexo发布文章](https://www.cnblogs.com/anthony-wang0228/articles/11461321.html)

[hexo博客同步管理及迁移](https://www.jianshu.com/p/fceaf373d797)

[git host文件相关](https://raw.hellogithub.com/hosts)

[hexo显示不出图片](https://juejin.cn/post/7006594302604214280)

/node_modules/hexo-asset-image/index.js

'use strict';
var cheerio = require('cheerio');

// http://stackoverflow.com/questions/14480345/how-to-get-the-nth-occurrence-in-a-string
function getPosition(str, m, i) {
  return str.split(m, i).join(m).length;
}

var version = String(hexo.version).split('.');
hexo.extend.filter.register('after_post_render', function(data){
  var config = hexo.config;
  if(config.post_asset_folder){
      var link = data.permalink;
  if(version.length > 0 && Number(version[0]) == 3)
     var beginPos = getPosition(link, '/', 1) + 1;
  else
     var beginPos = getPosition(link, '/', 3) + 1;
  // In hexo 3.1.1, the permalink of "about" page is like ".../about/index.html".
  var endPos = link.lastIndexOf('/') + 1;
    link = link.substring(beginPos, endPos);

    var toprocess = ['excerpt', 'more', 'content'];
    for(var i = 0; i < toprocess.length; i++){
      var key = toprocess[i];
 
      var $ = cheerio.load(data[key], {
        ignoreWhitespace: false,
        xmlMode: false,
        lowerCaseTags: false,
        decodeEntities: false
      });

      $('img').each(function(){
    if ($(this).attr('src')){
      // For windows style path, we replace '\' to '/'.
      var src = $(this).attr('src').replace('\\', '/');
      if(!/http[s]*.*|\/\/.*/.test(src) &&
         !/^\s*\//.test(src)) {
        // For "about" page, the first part of "src" can't be removed.
        // In addition, to support multi-level local directory.
        var linkArray = link.split('/').filter(function(elem){
        return elem != '';
        });
        var srcArray = src.split('/').filter(function(elem){
        return elem != '' && elem != '.';
        });
        if(srcArray.length > 1)
        srcArray.shift();
        src = srcArray.join('/');
        $(this).attr('src', config.root + link + src);
        console.info&&console.info("update link as:-->"+config.root + link + src);
      }
    }else{
      console.info&&console.info("no src attr, skipped...");
      console.info&&console.info($(this));
    }
      });
      data[key] = $.html();
    }
  }
});