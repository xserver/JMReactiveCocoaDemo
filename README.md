## ReactiveCocoa 

[ReactiveCocoa Cocoadocs](http://cocoadocs.org/docsets/ReactiveCocoa)
[Design Guidelines](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/DesignGuidelines.md)
[ReactiveCocoa README](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/README.md)


### 函数编程的『文化』
map      修改，重映射
filter   过滤、拦截
combine  &&  =>  A && B && C => 合成D
merge    ||  =>  A || B || C => 合成D
chaining 串联
flatten

map, filter, fold/reduce

### RAC 有哪些功能？
1. 监听视图的变化 UIView
2. 监听属性的变化 NSObject
3. 监听事件的变化（UIControlEvents）
4. 如何解除监听
5. 并行

### 内存
在 block 中引用self，需要使用 @weakify(self)和@strongify(self)来避免强引用&保护将要执行的 block。
使用时应该注意 block 的嵌套层数，不恰当的滥用多层嵌套block可能给程序的可维护性带来灾难。


### Signal 是什么
signal 是一个函数、block、事件

signal 作为 local 变量时，如果没有被subscribe，那么方法执行完后，该变量会被dealloc。
signal有被subscribe，那么subscriber会持有该signal，
    直到signal sendCompleted或sendError时，才会解除持有关系，signal才会被dealloc。


signal 和 sequence 都是streams，他们共享很多相同的方法。
signal 是 push 驱动的stream，sequence是pull驱动的stream

subscribeNext 和 sendNext 是对应的收与发



#### 扩展
| RAC Category      |         OC         |
|-------------------|--------------------|
| RACSignalSupport  | UI控件 UIControl, UIGestureRecognizer, 监听用户的输入
| RACCommandSupport | 按钮 UIButton, UIBarButtonItem
| RACSequenceAdditions | 容器类 NSArray, NSDictionary, NSString...       
| RACSupport           | 异步执行 NSData, NSNotificationCenter, NSString
| RACKeyPathUtilities  | NSString 扩展
| RACTypeParsing  | NSInvocation
| RACDeallocating | NSObject 释放
| RACDescription  | NSObject 帮助调试 
| RACKVOWrapper   | NSObject RAC 对 KVO 的封装
| RACLifting      | NSObject ?
| RACPropertySubscribing | NSObject 对 Property
| RACSelectorSignal      | NSObject


#### 类
[Framework Overview](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/FrameworkOverview.md)

| RAC Class            |         作用       |
|----------------------|--------------------|
| RACStream            | abstract class
| RACSignal            | push-driven stream
| RACSubscriber        | anything waiting events from signal, any object<Subscriber>, [subscriber send:]
| |
| RACSubject           | signal can manually controlled
| RACCommand           | some action
| RACMulticastConnection| cold -> hot 
| |
| RACSequences         | pull-driven stream. kind of collection
| RACDisposable        | used for cancellation and resource cleanup
| RACScheduler         | signal scheduler
| Value Type           | RACTuple, RACUnit, RACEvent
| RACDelegateProxy
| RACChannel   



### RACSignal+Operations.h
doNext, doError, doCompleted
take: takeLast, takeUntil
...


## 参考

http://sjpsega.com/blog/2014/02/11/yi--ios-7-best-practices-part-1/


[ReactiveCocoa Framework Overview](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/FrameworkOverview.md)
[ReactiveCocoa Framework Overview 译文](http://blog.sina.com.cn/s/blog_6591f6a20101clhv.html)

[知泉](http://www.zhiquan.me/tags/Functional-Reactive-Programming/)

[RAC macros](http://blog.sunnyxx.com/2014/03/06/rac_1_macros/)

[RAC sunny](http://blog.sunnyxx.com/tags/Reactive%20Cocoa%20Tutorial/)

[老赵 Functional Reactive Programming 把事件当作对象，基于事件的编程](http://blog.zhaojie.me/2009/09/functional-reactive-programming-for-csharp.html)


[Functional Reactive Programming，响应式编程](http://blog.csdn.net/xdrt81y/article/details/30624469)

[介绍](http://nshipster.cn/reactivecocoa/)

http://yulingtianxia.qiniudn.com/blog/2014/07/29/reactivecocoa/

[RAC 作者](https://github.com/jspahrsummers/GroceryList)
[ReactiveCocoaLayout](https://github.com/ReactiveCocoa/ReactiveCocoaLayout)

[ReactiveCocoa 入门 李忠](http://limboy.me/ios/2013/12/27/reactivecocoa-2.html)

[ReactiveCocoa 实战 李忠](http://limboy.me/ios/2014/06/06/deep-into-reactivecocoa2.html)

[视频 李忠](http://www.infoq.com/cn/presentations/practice-of-reactivecocoa-in-huabanwang-client )

[Basic Operators基本操作](http://segmentfault.com/a/1190000000408492)
##### RAC+AFNetworking
http://codeblog.shape.dk/blog/2013/12/02/transparent-oauth-token-refresh-using-reactivecocoa/
http://codeblog.shape.dk/blog/2013/11/16/wrapping-afnetworking-with-reactivecocoa/

![ReactiveCocoa](http://limboy.me/image/FRP_ReactiveCocoa_large.png)