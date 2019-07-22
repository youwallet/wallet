# youwallet众和社区
## 1、youwallet产品愿景
youwallet致力于打造一款完全去中化自由交易的非币圈人使用的钱包，没有上币的概念，任何人都可自由交易有价值的Token。以“和众”的模式来搭建贡献者社区，完全由贡献者对社区贡献衡量


## 2、社区价值观

- 尊重、信任；
- 严格的执行标准；
- 协作和为协作提供便利；
- 当你没有时间时，请告诉大家；
- 保障信息的安全；

## 3、贡献者
### 3.1、合格贡献者

- 个人，不得是组织、团队；
- 认同youwallet众和的理念和价值观；

### 3.2、如何申请成为认证贡献者
发邮件到：490854119@qq.com,格式:

```
题目：申请成为youwallet众和社区贡献者
内容：
个人简介：说明技术相关特长，并希望进行的贡献（前端、后端、产品、项目管理等等）
```

### 3.3、如何贡献

作为youwallet的认证贡献者，原则上你可以申请任何有益于youwallet的贡献内容，可以是已经提出的icp issue，也可以由自己提出。
说明：  
- “自己找”是你贡献的主要方式
- 由committer安排的任务
- 参与讨论和会议可以快速了解项目的现状和方向


### 3.4、角色

有三种角色：  

- Contributor：是指参与开发的同学   
- Committer：项目或者模块的管理者，对质量和进度负责  
- Maintainer：是社区的组织者和协调者，并有权对icp执行过程进行纠正    

说明：

- contributer对应的committer可以有一个或多个
- 在不同的repo中，contributer对应的committer可以不同
- 在同一个repo中可以同时是contributer和committer


## 4、icp

为了实现社区的目标设计了icp操作方式

icp（issue、commit/comment、pr)机制的核心原则是：

### 4.1 issue就是一切

凡没有在 issue 中记录的，都没有发生。

### 4.2 提交物是目标

一切有价值的贡献均应有对应提交物（可以是代码、设计、文档等等），并以此为衡量工作量的唯一依据；  

说明：
- 提交物可以是pr中内容，也可以在issue中包含并说明，只要EI的reviewer看得清楚即可

### 4.3 评价来自社区
issue的size是否合理由社区成员进行投票评价


## 5、icp操作流程
操作流程下图：

[icp操作流程图](https://www.processon.com/view/link/5ab0cc2ae4b0e93533948b2c)

图中的小人图表说明contributor、Committer的操作权限。

### 5.1、创建 issue
社区建议并鼓励贡献者在做任何事情时均以创建issue为开始，并@给相关committer或者contributor。

### 5.2、确定开发
只有committer才能确定某个issue应该进入开发流程，并打上 icp 的 label 作为标记。

### 5.3、申请开发
contributor或committer均可自由申请icp任务的开发，在icp issue的comment中提交下面的文字：  
```
申请开发 deadline:yyyy-mm-dd [size:xx] [@xxx] [文字]
```
注意点：
- 请严格按照这个格式填写，否则可能会无法计入统计；
- deadline是以引用pr merge的日期为准，所以建议留有一定余量进行review及修改；
- size可以在这确定，也可以后面单独申请；
- 一般不建议一个issue的size太大，如果本来工作量就很大那么建议拆分为多个issue；
- @给committer
- 申请开发comment提交的时间就是starttime
### 5.4、确认
committer在确定接受contributor的申请后，将assigness指定为该contributor，并打上size的标签。并表示该issue的任务进入开发流程。
注意：
- 一个issue只能指定一个assigness

### 5.5、变更
issue在执行过程中，在规定允许范围内contributer可向committer中提出变更申请，并由committer同意后：
- deadline变更：由committer在一个独立的comment中写
```
变更 deadline:yyyy-mm-dd [@xx] 变更原因
```
- size变更：由committer删除原来的size label后打上新的label

### 5.6、pr的引用
在pr中应该引用已经完成的issue，引用方式：在pr的正文或comment中撰写如下文字：
```
fix|for:issue-url [文字]
```
注意：
- 每一行写一个issue


### 5.7、pr的icp label
不是所有的pr的merge都表示对提交物的认可，考虑到有些merge的目的是为了使得代码以进行测试，所以社区规定只有committer才有权利打上icp label，也只有打上icp label的pr才是有效pr。

### 5.8、pr的assigness
pr的assigness由committer进行指定，并且merge只能由assigness进行操作。
说明：
- 一个pr只能指定一个assigness

### 5.9、pr的size
committer可以在pr打上size的label，以表示assigness的merge工作（一般是指review）的size。

### 5.10、review 
任何pr都必须由非提交者进行review。
说明：
- reviewer可以由contributer或committer更需要进行指定
- pr的size可以用于表示review的size
- review工作量很大的情况下，可以创建专门的review issue并在该pr中引用（同3.6）
- 理论上社区认为review耗费的size越大，提交的成果质量则越差

## 6、关于size

### 6.1、原则

假设贡献者为需求方，其愿意为实现提交物而支付的发包金额。
单位：1 size=500rmb
说明：  
- 不考虑执行的中间过程，size仅仅只与提交物有关系；
- 发包：就是通过众包平台发包的 
- 一般建议不要提交size很大的issue，如果任务工作量较多则建议拆分；

### 6.2、确定
由contributer或committer提出，经协商同意后，由committer打上size label。    
### 6.3、变更
如果实际工作量与预估要较大的出入，contributer可根据实际情况向committer提出size变更：  
变更申请需写明原因和size调整的数量，并经committer确认。


## 7、关于deadline
### 7.1、原则
deadline一经确认，原则上不能变更，应该在期限内完成。
### 7.2、变更
当出现下面情况时，contributer可以提出变更申请：
- 出现较大的技术障碍
- 协作关联方出现严重阻塞，且不可能独立解决
- 出现不可抗力的原因
变更申请需写明原因和新的deadline，并经committer确认。


## 8、奖励
社区给会以**有效的issue**和**有效pr**的size为依据进行size奖励，并根据任务完成和用户使用（挖矿）的情况进行贡献奖励。  

### 9.1、size奖励
#### 9.1.1 统计

待定

#### 9.1.2 方式
所有贡献者可选择接受奖励的方式：
- 现金形式
每月 15 日统计已经 merge 的 pr  
现金通过众包平台发放（可以自行选择），税费自负。  
- token
贡献者也可选择代表贡献奖励的token，兑换比例以www.sibbay.ai网上公布的赎回价格为准。  

#### 9.2 贡献奖励
#### 9.2.1 条件
- 本月EI>=0.8的贡献者有权利参与本月贡献奖励的分配。
#### 9.2.2 数量
- 每个月由社区根据任务完成和用户使用（挖矿）的情况确定token奖励的总数T；
- 每个人分配的数量：以个人CI*贡献者级别指数在本月总CI的比例乘以T
- 发放方式：50%是立即可兑现SHT、50%为一年锁定期SHT；

#### 9.3 统计时间
上个月16日00:00-本月16日00:00时间段进行pr merge的pr和引用issue
-社区所有的icp issue和pr的具体情况均在 [icp.sibbay.ai](http://icp.sibbay.ai) 中有详细的显示。
说明：  

- 每个贡献者应将个人的详细信息提供给社区
- 在相关的平台上登记相应的账号

#### 9.4 发放
每个月20日发放，如遇节假日顺延。

## 10、保障机制

### 10.1、效率条款

- 10.1.1、连续第二个月EI小于0.8（不包含），则该贡献者仅发放当月size奖励的50%；
- 10.1.2、连续第二个月EI小于0.4（不包含），则对其主管committer处以该贡献者当月size金额的处罚；


### 10.2、申诉和复核机制
- 10.2.1、申诉  
申诉是贡献者的权利
A、条件：在连续二、三、四个月的EI小于0.8后的20自然天内可以在public上提交申诉issue（原因是不支持远期申诉）  
B、@committer和人事  
C、简单陈述原因，原则上不超过5条
- 10.2.2、复核程序  
对所有涉及的issue评价对进行加倍评审：  
A、对每个issue pair同时交个两个人进行评价  
B、issue pair的复核人员不得与原评价人员相同  
C、安排在下一个贡献发放的评审流程中进行
D、每复核一个issue pair将获得50SHT的奖励（一个issue会有4次）
E、如复核人员未按时提交复核则扣除复核人员单月的EI（同8.2的规定），由committer代为复核
- 10.2.3、复核结果及处理  
根据复核结果计算的size奖励比原来有增加，则认为申诉成功。
复核结果是最终结果，并根据申诉决策的对称性原则，其处理规则如下：  
**A、申诉成功：**  
    *根据复核结果进行重新计算，由社区补发差额部分size奖励
    *根据复核结果进行重新计算，由社区补发差额部分token奖励（按照已发放的当月CI分配比例计算）  
    *且以后的0.8连续性也以复核结果为准  
    *复核工作SHT由社区支付（以防止复核人员的利益倾向性）  
    *提交复核结果与原投票结果进行误差分析，人事可根据情况对误差过大的原评审者提起质询   
**B、申诉失败：**  
    *对申诉者第一个EI小于0.8月份的size奖励追索扣除50%（这个月的size贡献没有扣除过）
    *申诉者承担复核工作SHT
    *半年内不得再提起申诉


### 10.3、违反社区价值观

社区要求每个贡献者均要遵循前社区的六条价值观，一旦出现一下行为：

- 坚决杜绝EI窜投行为，小白视为最恶劣之行径，一经发现以直接冻结SHT账户
- 没有时间时，未能及时告知社区
- 违反小白的版权管理规定
- 数据保密规定
- 虚报工作量
- 删除他人的issue留言
- 以及一切违反小白价值观的行为


一经证实，小白有权停止其贡献资格，并减少甚至取消其 CI 值。

## 11、社区管理模式

采取 MGM(Meritocratic Governance Model) 采取 apache 的精英治理模型，细则另定。

## 12、法律
[小白社区贡献者协议](https://shimo.im/docs/nSTirSBPk0Yf2JPI/)

## 其他

|---|---| 
|icp概念解释视频|[icp概念解释-刘宇](http://sibbay-files.oss-cn-hangzhou.aliyuncs.com/share/sibbay_introduction.mp4)|
|icp操作解释视频|[icp操作解释-李飞](http://sibbay-files.oss-cn-hangzhou.aliyuncs.com/share/sibbay_icp.mp4)|
|icp FAQ|[ICP入门FAQ文档链接](https://github.com/sibbay-ai/public/blob/master/icp%20FAQ.md)|  
|贡献者认证流程|[贡献者认证流程文档链接](https://github.com/sibbay-ai/public/blob/master/%E8%B4%A1%E7%8C%AE%E8%80%85%E8%AE%A4%E8%AF%81%E6%B5%81%E7%A8%8B.md)|  
|ICP标准流程图|[ICP标准流程图文档链接](https://www.processon.com/view/link/5ab0cc2ae4b0e93533948b2c)|  
|pull request规范|[pull request规范文档链接](https://github.com/sibbay-ai/public/blob/master/pull%20request%20%E8%A7%84%E8%8C%83.md)|  
|里程碑规范|[里程碑规范文档链接](https://github.com/sibbay-ai/public/blob/master/%E9%87%8C%E7%A8%8B%E7%A2%91%E8%A7%84%E8%8C%83.md)|  
|Github网页版操作步骤| [Github网页版操作步骤文档链接](https://shimo.im/docs/HFYnUnbIRmYGE8Hj)|  

## 说明：以上规范的内容（包含链接引用的部分），上海尘微科技有限公司拥有解释权
