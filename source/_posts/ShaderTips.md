---
title: ShaderTips
date: 2022-06-23 14:43:15
tags:
- 渲染
- Shader
categories: 
- 技术
- Unity
---


# 方法/函数/库
| . | . |
| ---- | ---- |
| saturate | Saturate is a function that clamps it's input between 0 and 1.|
| normalize | float normalize(float x)  </br> vec2 normalize(vec2 x)  </br> vec3 normalize(vec3 x)  </br> vec4 normalize(vec4 x)</br> normalize() returns a vector with the same direction as its parameter, x, but with length 1. |
| dot | 点乘。 </br> float dot(float x, float y)  </br> float dot(vec2 x, vec2 y)  </br> float dot(vec3 x, vec3 y)  </br> float dot(vec4 x, vec4 y)</br> dot() returns the dot product of two vectors, x and y. i.e., x[0]⋅y[0]+x[1]⋅y[1]+... If x and y are the same the square root of the dot product is equivalent to the length of the vector. The input parameters can be floating scalars or float vectors. In case of floating scalars the dot function is trivial and returns the product of x and y.
| pow | pow(x, y) x的y次幂 |
| rcp | rcp(x) = x的倒数(1/x) 借此来优化除法运算 [shader低级优化](https://zhuanlan.zhihu.com/p/87936887) |

<!--more-->

[URPHLSL库函数](https://blog.csdn.net/qq_42115447/article/details/103934503)

[Unity Built-in shader variables](https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html)

# Tips
[世界空间 模型空间 观察空间 投影空间](https://blog.csdn.net/Motarookie/article/details/125048328)
UNITY_MATRIX_MVP  模型空间--M-->世界空间--V-->观察空间--P-->裁剪空间

[SV_POSITION vs POSITION](https://blog.csdn.net/Ling_SevoL_Y/article/details/120203081)

[NormalMap法线贴图](https://zhuanlan.zhihu.com/p/158633488)


# 经验性方法/其他项目经验类方法
