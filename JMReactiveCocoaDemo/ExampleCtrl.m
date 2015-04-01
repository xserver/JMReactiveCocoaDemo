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





















