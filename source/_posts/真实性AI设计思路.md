---
title: 真实性AI设计思路(Fishing Elite)
date: 2024-06-26 14:46:32
tags:
- 设计
categories: 
- 技术
- 设计
---


# 一、设计目标
- 真实性:
    - AI的整体行为更真实,包括对场景的认知、具体的操作等。
    - AI的行动更具有计划性、并能根据场况、对决情况、单局内曾发生过的结果制定策略。
- 工具化: AI的性格和智能度能更简单的被观测、配置和编辑。
- 热更新: AI的行为与数据分离，更好的支持热更和Lua编码，更好的支持编辑器控制。

<!--more-->
# 二、具体设计
![真实性AI框架](2024/06/26/真实性AI设计思路/1.png)

## 观察模块
AI会通过某种可配置的方式观察游戏世界。

- 观察器(Observer): 从游戏世界(World)、 复盘结果(Review)中观察自己想要的信息，并存储在记忆(Memory)中。
- 观察方法(ObserveMethod): 作为一个静态数据类，跟观察器(Observer)分离来实现数据和逻辑的解耦。

## 记忆模块
AI会通过某种可配置的方式激活观察到的记忆。

- 记忆(Memory): 作为一个静态数据类,存储AI现在已知的信息。
- 记忆检索器(Retriever): 从记忆(Memory)中找出当前最重要的数据，从而协助计划器(Planner)指定计划(Plan)，协助行动器(Actor)触发操作器(Operator)。
- 检索方法(RetrieveMethod): 作为一个静态数据类，跟记忆检索器(Retriever)分离来实现数据和逻辑的解耦。

## 计划模块
AI会根据已激活的记忆，通过某种可配置的方式指定钓鱼计划。

- 计划器(Planner): 通过检索出的记忆，制定或修改AI当前的行动计划。
- 计划方法(PlanMethod): 作为一个静态数据类，跟计划器(Planner)分离来实现数据和逻辑的解耦。
- 计划(Plan): 作为一个静态数据类，储存AI当前的行为计划。
- 预期(Expect): 是计划(Plan)的一部分。被用来与复盘结果(Review)对比，从而让AI通过评估器(Evaluator)反思执行更好的操作。

## 行动模块
AI会根据已制定的计划执行行动，操作。

- 行动器(Actor): 根据计划(Plan)和记忆检索器(Retiever)检索出的重要记忆, 决定当前正在执行的是什么抽象化的行动，并要求操作器(Operator)执行具体的操作。行为的开始和结束是可以被观测和拦截的。
- 行动(Act): 作为一个静态数据类，跟行动器(Actor)分离来实现数据和逻辑的解耦。 行动是抽象化、定义好的概念，这有助于策划编辑和使用。
- 操作器(Operator): 根据行动器(Actor)的要求执行具体操作(Operate)，从而影响游戏世界(World)。每帧操作是异步的，也是可以被观测和拦截的。
- 操作(Operate): 作为一个静态数据类, 跟操作器(Operator)分离来实现数据和逻辑的解耦。操作是具体的数据结构。

## 复盘模块
AI会对行动结果，通过某种可配置的方式进行复盘。复盘结果会作为记忆存在，并影响其它AI模块。

- 复盘器(Reviewer): 对行动(Act)或操作(Operate)执行前后的游戏世界(World)进行对比, 并得知行动(Act)或操作(Operate)产生的影响和结果
- 复盘方法(ReviewMethod): 作为一个静态数据类,跟复盘器(Reviewer)分离来实现数据和逻辑的解耦。
- 复盘结果(Review): 作为一个静态数据类，跟复盘器(Reviewer)分离来实现数据和逻辑的解耦。复盘结果是抽象化、定义好的概念，这有助于策划编辑和使用。

## 评估模块
AI的表现可以被自动或人为的评估，从而修正自身的运行方式。

- 评估器(Evaluator): AI会自动评估或受外界编辑器影响而被动评估复盘结果(Review)和预期(Expect)之间的一致性。评估后, AI会修改观察方法(ObserveMethod)、检索方法(RetieveMethod)、计划方法(PlanMethod)中的一些属性，从而修正自身的智能程度。
- 评估方法(EvaluateMethod): 作为一个静态数据类，跟评估器(Evaluator)分离来实现数据和逻辑的解耦。

## 编辑器模块
对上述各个Method模块进行软编程；在外界对AI行为进行评估。

- 方法编辑器(MethodEditor)
- 评估编辑器(EvaluateEditor)

## 关于热更
在上述提到的模块中,所有的静态数据类都将支持外部随时修改,从而允许动态修改AI状态。所有的行为都可以被观测和拦截，从而允许动态改变AI行为。

# 三、AI执行流程举例
1. 游戏开始, AI通过<font color=green>"观察器"</font>得知场景情况和自身的装备情况。这时<font color=orange>"观察方法"</font>会影响AI的认知程度。
2. 经过<font color=green>"记忆检索器"</font>和<font color=green>"计划器"</font>，AI依据<font color=orange>"检索方法"</font>、<font color=orange>"计划方法"</font>，制定了一一个钓鱼计划：如尽可能钓起最大的鱼。
3. AI依据<font color=blue>"计划"</font>，形成了一个<font color=blue>"预期"</font>：要钓起大鱼。并拆解了预期：要能找到大鱼、能吸引到大鱼、能让大鱼上钩。
4. AI通过<font color=green>"行动器"</font>进行了第一一个<font color=blue>"行动"</font>: 寻找大鱼。AI执行了来回移动视角、或者使用无人机道具之类的<font color=blue>"操作"</font>。
5. 如果AI经过这些<font color=blue>"操作"</font>，依然没有找到心仪的大鱼，<font color=green>"复盘器"</font>会生成一个消极的<font color=blue>"复盘结果"</font>。
6. AI经过<font color=green>"方法调整器"</font>，处理自身的<font color=blue>"复盘结果"</font>，并修正了自身的一些<font color=orange>"方法"</font>。
7. 修正后的<font color=orange>"方法"</font>会影响AI后续的观察、检索和计划器的结果。如：放弃自身钓起最大的鱼的计划，转而稳健的钓一条小鱼。
8. 于是AI依据<font color=blue>"计划"</font>,形成了新的<font color=blue>"预期"</font>，修改了自身的<font color=blue>"行动"</font>，转而进行向小鱼所在的点抛竿的<font color=blue>"操作"</font>。
9. ...如此循环。
10. 策划在配置AI时，发现上述的AI执行过程，可能比较蠢或不符合预期。策划可以通过<font color=green>"评估器"</font>给出一个低分，于是AI会在<font color=green>"方法调整器"</font>中调整上面所使用过的方法的权重，从而在下一次执行中更逼近设计预期或更聪明。
11. 随着多次评估，各方法的权重系数会被内部保存。策划可以将评估好的结果存为预设。

