---
title: TMP多语言字体方案
date: 2022-06-21 14:46:54
tags:
- TMP
- TextMeshPro
- 字体
- 多语言
categories: 
- 技术
- Unity
---

# 工作流
由美术和资源策划决定需要使用的字体或向第三方直接购买字体，提供字体文件（ttf格式为优）。仅需提供原字体，无需提供黑体等特殊效果字体；字体总数不应过多。直接使用外部字体时需注意版权问题。
ttf文件提供给客户端程序，程序将ttf文件转换为项目中用的SDF文件。
资源策划根据各功能实际需求，在资源上配置对应字体的SDF文件。
<!--more-->

# 字体导入
由程序负责新字体的导入，推荐使用字体查看和编辑软件[fontforge](https://fontforge.org/en-US/)和字体子集生成软件[fontmin](https://ecomfe.github.io/fontmin/)。
#### 1）字体分类
在多语言项目中，我们使用TMP的fallbackList机制来配置字图查找的优先级：

![enter image description here](2022/06/21/TMP多语言字体方案/fallbackList.png)

我们现在会把项目中可能使用的所有字体分为：各语言字体（中日英韩德法..）、符号字体（仅存在一个）和特殊字体。
在这个前提下，我们希望各个字库间尽可能无重复（防止不同语言下看同一个字的样式不同），所以我们需要将源ttf文件进行子集筛选，让它仅存在对应语言的字，或仅存在符号字。
#### 2）生成字库
根据对应语言的UTF-8编码段，仅筛选出需要的字符，生成子集ttf文件；在Window/TextMeshPro/FontAssetCreator工具中，使用对应ttf文件生成合适大小的字图；最终保存为asset文件。

![enter image description here](2022/06/21/TMP多语言字体方案/fontSetting.png)

|可能需要关注的配置内容：|
| ---- | ---- |
| SourceFontFile | 选择对应的字体ttf文件。 | 
| SamplingPointSize | PointSize可以代表字体清晰度，一般PointSize>25才清晰。</br>**为保证描边等材质效果一致，建议所有字体的PointSize一致(本项目设定为30)；若项目无通用字体材质的需求也可直接AutoSizing**。 | 
|AtlasResolution|选择保证**PointSize合适的最小大小**。这与运行中内存占用有关。|
|CharacterSequence|填写对应UTF-8编码段。|
|RenderMode|推荐使用SDFAA_HINTED。|
|GenerateFontAtlas|点击该按钮生成字图。生成后下方会提示字图对应的PointSize（衡量单字所占像素数，若过小则会产生失真），以及缺字等提示信息。|

 ***各语言UTF-8编码段待后续补充。*** 

#### 3）确定fallbackList

创建一个仅包含默认\"\_\"字符的*预设字体asset*，**下划线的存在是因为TMP需要使用下划线来渲染underline配置的字体**。
向资源策划确认该字体应属于那一套字体预设，将其加入对应*预设字体asset*的fallbackList中，顺序按需确定。实际资源配置中仅使用带有预设fallbackList的*预设字体asset*。

# 字体配置

字体配置由资源策划进行。
#### 1）选择字体
在文本组件中TMP脚本上，选择所需的FontAsset。
#### 2）字体效果实现（加粗等）
加粗、斜体等直接在TMP组件中勾选即可；描边等复杂效果实现如下。
首先选中对应字体的材质球(保存在Resources/UI/Font目录下)：

![enter image description here](2022/06/21/TMP多语言字体方案/mat1.png)

为材质球创建新的预设：

![enter image description here](2022/06/21/TMP多语言字体方案/mat2.png)

为新的材质预设命名，**本项目中命名必须以“TMPCommonMat”开头**：

![enter image description here](2022/06/21/TMP多语言字体方案/mat3.png)

在inspector中可以编辑具体材质内容：

![enter image description here](2022/06/21/TMP多语言字体方案/mat4.png)

在TMP组件中选择对应预设即可：

![enter image description here](2022/06/21/TMP多语言字体方案/mat5.png)

![enter image description here](2022/06/21/TMP多语言字体方案/mat6.png)

# 图文混排

#### 1) 提交图片资源
图片资源提交到 *Assets\Resources\UI\HyperStyle\自定义文件夹名* 下，需要打图集。
同一图集内的图片大小应一致，以便调整适配。若大小不一致，则图集中pivot必须为bottomLeft。
#### 2) 生成emoji字体
选中图集atlas文件，在右键菜单中选择 *Create -> TextMeshPro -> Sprite Asset* ，并将生成的 *[图集名.asset]* 文件移至 *Assets\Resources\TMPRes\Resources\SpriteAssets* 目录下。
选中asset文件，在Inspector窗口中打开 *Sprite Glyph Table* ，可调整各个图片的偏移、以及全局偏移( *Global Offsets & Scale*)。
#### 3) 使用emoji字体
~~在*[TMPSettings.asset]* 文件中的 *DefaultSpriteAsset -> DefaultSpriteAsset* 配置默认emoji字体~~ 

配置文本为"测试字体<sprite="图集名" name="图片名">测试字体"，即可看到图文混排结果。
例：aaaa<sprite="Summon_tp1" name="Btn_Main_ZhaoHuan">bbbb
![enter image description here](2022/06/21/TMP多语言字体方案/sprite.png)

#缺字和字体错误等问题的修复
缺字时，由程序向对应字体文件(ttf)中新增字形，再重新生成asset即可；更方便的做法是专门创建一个用于补字的兜底字库，将它放在fallbackList的最后，其对应ttf字体包含几乎所有字形，其CharacterSequence仅按需添加。
字体错误时，多数原因是fallbackList中的字库间存在重复，导致索引到了其他字库中的字。通过运行中的SubMeshUI名称检查其字库来源，处理重复字即可。

# 一些常用额外内容的配置
#### 1) 斜体、粗体等细节配置
在字体asset文件的Font Weights中可以配置。
#### 2）默认换行、默认接受射线的初始化配置
在TMPSettings文件中，勾选对应项。（WordWrapping、EnableRaycastTarget）
#### ?）...待补充