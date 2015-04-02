//
//  README.h
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/4/2.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

在block中如果要引用self，需要使用@weakify(self)和@strongify(self)来避免强引用。
使用时应该注意block的嵌套层数，不恰当的滥用多层嵌套block可能给程序的可维护性带来灾难。

signal作为local变量时，如果没有被subscribe，那么方法执行完后，该变量会被dealloc。
signal有被subscribe，那么subscriber会持有该signal，直到signal sendCompleted或sendError时，才会解除持有关系，signal才会被dealloc。

signal 和 sequence 都是streams，他们共享很多相同的方法。
signal 是push驱动的stream，sequence是pull驱动的stream

subscribeNext 和 sendNext 是对应的收与发


RAC 有哪些功能？
1、监听视图的变化 UIView
2、监听属性的变化 NSObject
3、监听事件的变化（UIControlEvents）

4、如何解除监听
5、并行


*Signal的特性   RACSignal+Operations.h
filter   过滤
combine  && 叠加
merge    ||
map      修改
chaining 串联


*对 OC 的扩展
各个控件 和 UIControlEvents
基础的 NSObject
...
KVO Delegate
NSArray rac_sequence

@protocol RACSubscriber;   订阅者符合这个协议即可的任何对象

RAC 中 KVO 的操作隐藏在 search NSKeyValueObservingOptions
RACKVOTrampoline : RACDisposable   observeValueForKeyPath:ofObject:change:context

/*
 http://sjpsega.com/blog/2014/02/11/yi--ios-7-best-practices-part-1/
 
 http://segmentfault.com/a/1190000000408492
 http://blog.sina.com.cn/s/articlelist_1704064674_0_1.html
 http://www.zhiquan.me/tags/Functional-Reactive-Programming/
 http://blog.sunnyxx.com/2014/03/06/rac_1_macros/
 
 把事件当作对象，基于事件的编程
 http://blog.zhaojie.me/2009/09/functional-reactive-programming-for-csharp.html
 
 http://limboy.me/image/FRP_ReactiveCocoa_large.png
 http://blog.csdn.net/xdrt81y/article/details/30624469
 http://nshipster.cn/reactivecocoa/
 http://yulingtianxia.qiniudn.com/blog/2014/07/29/reactivecocoa/
 https://github.com/jspahrsummers/GroceryList RAC 作者
 https://github.com/ReactiveCocoa/ReactiveCocoaLayout   ReactiveCocoaLayout
 
 http://limboy.me/ios/2013/12/27/reactivecocoa-2.html 李忠
 http://limboy.me/ios/2014/06/06/deep-into-reactivecocoa2.html  李忠
 http://www.infoq.com/cn/presentations/practice-of-reactivecocoa-in-huabanwang-client 视频李忠
 
 AFNetworking
 http://codeblog.shape.dk/blog/2013/12/02/transparent-oauth-token-refresh-using-reactivecocoa/
 http://codeblog.shape.dk/blog/2013/11/16/wrapping-afnetworking-with-reactivecocoa/
 
 */


