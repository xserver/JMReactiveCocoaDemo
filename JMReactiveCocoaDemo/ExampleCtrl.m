//
//  ExampleCtrl.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/3/31.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "ExampleCtrl.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
//  http://blog.sunnyxx.com/2014/03/06/rac_3_racsignal/
//  http://blog.sunnyxx.com/2014/04/19/rac_4_filters/
@interface ExampleCtrl ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (copy, nonatomic) NSString *name;
@end

@implementation ExampleCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self testReplay];
//    [self testReplayLazily];
}

#pragma mark - replay
- (void)testReplay {
    RACSignal *numberSignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"replay 我只执行一次，并且会缓存 sendNext 的结果");
        
        [subscriber sendNext:@(random() % 10)];
        [subscriber sendNext:@(random() % 10  + 10)];
        [subscriber sendNext:@(random() % 10  + 20)];
        return nil;
    }] replayLast];
    
//    - (RACSignal *)replay
//    - (RACSignal *)replayLast    在 replay 的基础上，获取sendnext中的最后一次的数据
//    - (RACSignal *)replayLazily
//    lazily 有人 subscriber 的时候再执行，replay 和 replayLast 是先执行，lazily 的意思正式如此
    
    NSLog(@"注意 start 和 signal 中的 subscriber 执行顺序");
    
    [numberSignal subscribeNext:^(id x) {
        NSLog(@"A %@", x);
    }];
    [numberSignal subscribeNext:^(id x) {
        NSLog(@"B %@", x);
    }];
}

- (void)testReplayLazily {
//    http://spin.atomicobject.com/2014/06/29/replay-replaylast-replaylazily/
//    https://www.evernote.com/shard/s147/sh/611d1793-5087-4bfd-814b-bf2d53f988d8/4a67343fdcdfba71
    __block int num = 0;
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id subscriber) {
        num++;
        NSLog(@"Increment num to: %i", num);
        [subscriber sendNext:@(num)];
        return nil;
    }] replayLazily];
    
    NSLog(@"Start subscriptions");
    
    // Subscriber 1 (S1)
    [signal subscribeNext:^(id x) {
        NSLog(@"S1: %@", x);
    }];
    
    // Subscriber 2 (S2)
    [signal subscribeNext:^(id x) {
        NSLog(@"S2: %@", x);
    }];
    
    // Subscriber 3 (S3)
    [signal subscribeNext:^(id x) {
        NSLog(@"S3: %@", x);
    }];
}

- (void)testDoxx {
    __block unsigned subscriptions = 0;
    
    RACSignal *signal = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
        NSLog(@"1");
        subscriptions++;
        [subscriber sendNext:@(8)];
        [subscriber sendCompleted];
        NSLog(@"2");
        return nil;
    }];
    
    
    //doxxx 方法将side effects添加到信号中而不实际地订阅它
    [signal doNext:^(id x) {
        NSLog(@"3-1 %@", x);
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"3-2 %@", x);
    }];
    
    
    // Does not output anything yet
    //    signal = [signal doCompleted:^{
    //        NSLog(@"5 about to complete subscription %u", subscriptions);
    //    }];
    //
    //    [signal subscribeCompleted:^{
    //        NSLog(@"4 subscription %u", subscriptions);
    //    }];  

}

- (void)testTakeStartFilterMap {
    //    RAC(_label, text) = [[self.textField.rac_textSignal
    //                                    startWith:@"key is >3"] /* startWith 一开始返回的初始值 */
    //                                   filter:^BOOL(NSString *value) {
    //                                       return value.length > 3; /* filter使满足条件的值才能传出 */
    //                                   }];
    
    //    RAC(_label, text) = [[[self.textField.rac_textSignal
    //                                    startWith:@"key is >3"] // startWith 一开始返回的初始值
    //                                   filter:^BOOL(NSString *value) { // filter使满足条件的值才能传出
    //                                       return value.length > 3;
    //                                   }] map:^id(NSString *value){// map将一个值转化为另一个值输出
    //                                       return [value isEqualToString:@"123123"] ? @"bingo!" : value;
    //                                   }];
    //
    //  takeUntil 一直取 UITextField rac_textSignal 就是
}
#pragma mark - filter
- (void)distinctUntilChanged {
    //    RAC(self.label, text) = RACObserve(self, name);
    //    RAC(self.label, text) = [RACObserve(self, name) distinctUntilChanged];
    [RACObserve(_label, text) subscribeNext:^(id x){
        //  重复的时候, 有distinctUntilChanged 拦截
        NSLog(@"%@", x);
    }];
    self.name = @"sunnyxx"; // 1st
    self.name = @"sunnyxx"; // 2nd
    self.name = @"sunnyxx"; // 3rd
}

#pragma mark - take
- (void)takeCount {
    
    //  take 前几次
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        [subscriber sendCompleted];
        return nil;
    }] take:2] subscribeNext:^(id x) {
        NSLog(@"11 only 1 and 2 will be print: %@", x);
    }];
    
    //  take 后几次
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        [subscriber sendCompleted];
        return nil;
    }] takeLast:2] subscribeNext:^(id x) {
        NSLog(@"22 only 1 and 2 will be print: %@", x);
    }];
}

- (void)takeSome {
    [[self.textField.rac_textSignal takeUntilBlock:^BOOL(NSString *value) {
        //  NO -> subscribeNext, YES 就停止了 ，和 takeWhileBlock 相反
        return [value isEqualToString:@"stop"];
    }] subscribeNext:^(NSString *value) {
        NSString *str = [NSString stringWithFormat:@"current value is not `stop`: %@", value];
        _label.text = str;
        NSLog(@"%@", str);
    }];
    
    //    [[self.textField.rac_textSignal takeWhileBlock:^BOOL(NSString *value) {
    //
    //        BOOL result = ![value isEqualToString:@"stop"];
    //        NSLog(@"==%@  %@",result?@"YES":@"NO", value);
    //
    //        //  YES 就 subscribeNext，一个 NO 之后就终止了 Complete
    //        return result;
    //    }] subscribeNext:^(NSString *value) {
    //        NSLog(@"value = %@", value);
    //        NSString *str = [NSString stringWithFormat:@"current value : %@", value];
    //        _label.text = str;
    //        NSLog(@"%@", str);
    //    }];
}

#pragma mark - skip
- (void)testSkip {
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        [subscriber sendCompleted];
        return nil;
    }] skip:1] subscribeNext:^(id x) {
        NSLog(@"only 2 and 3 will be print: %@", x);
    }];
    
    
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        [subscriber sendCompleted];
        return nil;
    }] skipUntilBlock:^BOOL (id x){
        //  一直跳，直到block为YES
        //  - skipWhileBlock:(BOOL (^)(id x)) 一直跳，直到block为NO
        return YES;
    }] subscribeNext:^(id x) {
        NSLog(@"only 2 and 3 will be print: %@", x);
    }];
    
    
}
@end





















