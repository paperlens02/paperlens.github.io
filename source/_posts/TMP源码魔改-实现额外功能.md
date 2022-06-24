---
title: TMP源码魔改_实现额外功能（如不同字体复用同材质）
date: 2022-06-21 14:51:39
tags:
- TMP
- TextMeshPro
- 字体
categories: 
- 技术
- Unity
---

[魔改后的TMP源码(private)](https://github.com/paperlens02/customTMP)

# 魔改默认创建的TMP组件
在TMPro_CreateObjectMenu中魔改即可


# 汉字错误换行问题
编写TMP的老外似乎不是很理解汉字相关的语言逻辑，TMP的换行逻辑虽然对汉字做了特殊优化，但结果仍有错误。例如"啊abc"会被认为是一个整词，会按照英文习惯放在一起换行。此改动解决这种错误换行问题。

<!--more-->

**0.以下所有改动均在TMPro_UGUI_Private.cs的GenerateTextMesh()方法中进行。**

**1.新增局部变量 int nextCharCode = 0; 它与方法内另一个局部变量 int charCode 在逻辑意义上相近。**
```CS
...............
int charCode = 0; // Holds the character code of the currently being processed character.
int nextCharCode = 0; // by paperlens: Holds the character code of the next character of the processed character.
...............
```
**2.在源代码记录charCode的同时，记录nextCharCode。**
```CS
...............
// Parse through Character buffer to read HTML tags and begin creating mesh.
for (int i = 0; i < m_TextProcessingArray.Length && m_TextProcessingArray[i].unicode != 0; i++)
{
    charCode = m_TextProcessingArray[i].unicode;
    // by paperlens: nextCharCode
    if (m_TextProcessingArray.Length > i + 1)
        nextCharCode =  m_TextProcessingArray[i+1].unicode;
    else
        nextCharCode = 0;
...............
```
**3.在处理换行的相关逻辑中加入nextCharCode相关的判断。**
```CS
// Save State of Mesh Creation for handling of Word Wrapping
...............
if ((isWhiteSpace || charCode == 0x200B || charCode == 0x2D || charCode == 0xAD) && (!m_isNonBreakingSpace || ignoreNonBreakingSpace) && charCode != 0xA0 && charCode != 0x2007 && charCode != 0x2011 && charCode != 0x202F && charCode != 0x2060)
{
    // We store the state of numerous variables for the most recent Space, LineFeed or Carriage Return to enable them to be restored
    // for Word Wrapping.
    SaveWordWrappingState(ref m_SavedWordWrapState, i, m_characterCount);
    isFirstWordOfLine = false;
    //isLastCharacterCJK = false;

    // Reset soft line breaking point since we now have a valid hard break point.
    m_SavedSoftLineBreakState.previous_WordBreak = -1;
}
// Handling for East Asian characters
// by paperlens: 解决英文后接中文单字或中文字后接英文时，两个字被认为是一个单词而一起换行的问题
// 例如: 一二三四五6七,八九十   其中的"6七,"会被当成一个单词，若当行放不下这三个字，这三个字会一起换行
else if (m_isNonBreakingSpace == false &&
         ((charCode > 0x1100 && charCode < 0x11ff || /* Hangul Jamo */
           charCode > 0xA960 && charCode < 0xA97F || /* Hangul Jamo Extended-A */
           charCode > 0xAC00 && charCode < 0xD7FF || /* Hangul Syllables */
           nextCharCode > 0x1100 && nextCharCode < 0x11ff || 
           nextCharCode > 0xA960 && nextCharCode < 0xA97F || 
           nextCharCode > 0xAC00 && nextCharCode < 0xD7FF)&& 
          TMP_Settings.useModernHangulLineBreakingRules == false ||
          (charCode > 0x2E80 && charCode < 0x9FFF || /* CJK */
           charCode > 0xF900 && charCode < 0xFAFF || /* CJK Compatibility Ideographs */
           charCode > 0xFE30 && charCode < 0xFE4F || /* CJK Compatibility Forms */
           charCode > 0xFF00 && charCode < 0xFFEF || /* CJK Halfwidth */
           nextCharCode > 0x2E80 && nextCharCode < 0x9FFF ||
           nextCharCode > 0xF900 && nextCharCode < 0xFAFF ||
           nextCharCode > 0xFE30 && nextCharCode < 0xFE4F ||
           nextCharCode > 0xFF00 && nextCharCode < 0xFFEF))) 
{
...............
```

# 实现不同字体复用同材质

**1.为实现不同字体复用同材质，在TMP_EditorUtility的FindMaterialReferences方法中修改了材质预设的搜索方法；另外猜测强行比对mat的MainTex与自身字体Tex相同是为了保证SDF映射存在，而这在SubMeshUI应用后应该已经过时了，故删除了部分判断逻辑。**

在TMP_EditorUtility.cs的FindMaterialReferences(TMP_FontAsset fontAsset)中，修改材质预设的搜索方法：
```CS
...............
public static Material[] FindMaterialReferences(TMP_FontAsset fontAsset)
{
    List<Material> refs = new List<Material>();
    Material mat = fontAsset.material;
    refs.Add(mat);

    // Get materials matching the search pattern.
    string searchPattern = "t:Material" + " " + "TMPCommonMat";
    string[] materialAssetGUIDs = AssetDatabase.FindAssets(searchPattern);

    for (int i = 0; i < materialAssetGUIDs.Length; i++)
    {
        string materialPath = AssetDatabase.GUIDToAssetPath(materialAssetGUIDs[i]);
        Material targetMaterial = AssetDatabase.LoadAssetAtPath<Material>(materialPath);
        // by paperlens: 材质复用
        // if (targetMaterial.HasProperty(ShaderUtilities.ID_MainTex) && targetMaterial.GetTexture(ShaderUtilities.ID_MainTex) != null && mat.GetTexture(ShaderUtilities.ID_MainTex) != null && targetMaterial.GetTexture(ShaderUtilities.ID_MainTex).GetInstanceID() == mat.GetTexture(ShaderUtilities.ID_MainTex).GetInstanceID())
        // {
            if (!refs.Contains(targetMaterial))
                refs.Add(targetMaterial);
        // }
        // else
        // {
            // TODO: Find a more efficient method to unload resources.
            //Resources.UnloadAsset(targetMaterial.GetTexture(ShaderUtilities.ID_MainTex));
        // }
    }

    return refs.ToArray();
}
...............
```

在TMPro_UGUI_Private.cs的LoadFontAsset()中，删除判断逻辑: 
```CS
...............
// by paperlens: 材质复用
// If font atlas texture doesn't match the assigned material font atlas, switch back to default material specified in the Font Asset.
if (m_sharedMaterial == null) // || m_sharedMaterial.GetTexture(ShaderUtilities.ID_MainTex) == null || m_fontAsset.atlasTexture.GetInstanceID() != m_sharedMaterial.GetTexture(ShaderUtilities.ID_MainTex).GetInstanceID()
{
    if (m_fontAsset.material == null)
        Debug.LogWarning("The Font Atlas Texture of the Font Asset " + m_fontAsset.name + " assigned to " + gameObject.name + " is missing.", this);
    else
        m_sharedMaterial = m_fontAsset.material;
}
...............
```

**2.现在的多语言策略是主字库中不存放任何字，所有字分开字库排列在fallbackList中；而字体下划线的绘制必须依赖主字库中的"\_"glyph，且这是合理的：因为无论字体来源于哪个子字库，它们的下划线也都必须一致。由上述第5条改动可知，现在为实现不同字体通用材质取消了字体材质球的Texture检查，所以在使用部分材质球时，主字库中"\_"的渲染可能出错，这是因为使用了错误的texture。解决这个问题可以去修改GetUnderlineSpecialCharacter、DrawUnderlineMesh方法；但在本项目中现在选择取巧，修改了所有字体材质的默认Texture为包含"\_"那个初始字库的Atlas。**

**3.在上述改动后，完善编辑器体验：修改字体时同步重置材质**

在TMP_BaseEditorPanel.cs的DrawFont()方法中: 
```CS
...............
void DrawFont()
{
    bool isFontAssetDirty = false;

    // FONT ASSET
    EditorGUI.BeginChangeCheck();
    EditorGUILayout.PropertyField(m_FontAssetProp, k_FontAssetLabel);
    if (EditorGUI.EndChangeCheck())
    {
        m_HavePropertiesChanged = true;
        m_HasFontAssetChangedProp.boolValue = true;

        // Get new Material Presets for the new font asset
        m_MaterialPresetNames = GetMaterialPresets();
        m_MaterialPresetSelectionIndex = 0;
        // by paperlens: 修改fontAsset时标记MaterialPreset为脏，重置材质。
        m_FontSharedMaterialProp.objectReferenceValue = m_MaterialPresets[m_MaterialPresetSelectionIndex];
        m_HavePropertiesChanged = true;

        isFontAssetDirty = true;
    }
...............
```

# 创建SubMeshUIObject时，不让它置顶

TMP在创建SubMeshUI时，会自动将其置顶。这或许是为了多字体之间互相覆盖时，让更优先的字体显示在上方。但正常的字体显示是不需要有覆盖重叠的，反而在资源配置上有时会有把图片放在text组件下并自动stretch的需求，这是为了方便实现图片自动适配文字内容大小。因此我们注释掉置顶逻辑。
在TMP_SubMeshUI.cs的AddSubTextObject(...)方法中，注释掉SetAsFirstSibling()即可。
