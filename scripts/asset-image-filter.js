'use strict';
// 替代失效的 hexo-asset-image 插件：
// hexo-renderer-marked@5+ 会把 md 中的相对图片路径改写为根路径（如 /relate.png），
// 导致老插件（按“非 / 开头才处理”判断）全部跳过，图片 404。
// 这里在文章渲染后，把根路径图片重写为文章资源文件夹下的真实地址。
hexo.extend.filter.register('after_post_render', function (data) {
  if (!hexo.config.post_asset_folder) return;

  const PostAsset = hexo.model('PostAsset');
  const assets = PostAsset.find({ post: data._id }).toArray();

  if (!assets.length) return;

  const toProcess = ['excerpt', 'more', 'content'];
  const postDir = hexo.config.root + data.path.replace(/index\.html?$/, '');

  for (const key of toProcess) {
    if (!data[key]) continue;
    for (const asset of assets) {
      // marked 转出的根路径，如 "/relate.png"；中文文件名会被 URL 编码，两种形式都要匹配
      const variants = [asset.slug, encodeURI(asset.slug)].filter((v, i, a) => a.indexOf(v) === i);
      // 未转义的原始相对写法，如 "relate.png" 或 "./relate.png"
      const fromRel = new RegExp('src="(?:\\./)?' + escapeRegExp(asset.slug) + '"', 'g');
      const to = postDir + asset.slug;
      for (const variant of variants) {
        data[key] = data[key].split('src="' + hexo.config.root + variant + '"').join('src="' + to + '"');
      }
      data[key] = data[key].replace(fromRel, 'src="' + to + '"');
    }
  }
});

function escapeRegExp(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
