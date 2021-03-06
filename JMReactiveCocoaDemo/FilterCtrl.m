//
//  FilterCtrl.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/6/1.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "FilterCtrl.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface FilterCtrl ()
@property (nonatomic, weak  ) IBOutlet UITextField *textField;
@property (nonatomic, copy  ) NSString *name;
@end

@implementation FilterCtrl

- (void)viewDidLoad {
    [super viewDidLoad];

    [[RACObserve(self, name)
      filter:^(NSString *newName) {
          return [newName hasPrefix:@"j"];
      }]
     subscribeNext:^(NSString *newName) {
         NSLog(@"%@", newName);
     }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.name = @"j~~~";
    });
    
//    //  过滤模式
//    [[RACObserve(self.textField, text) filter:^(id value) {
//        NSLog(@"2 filter------ %@  %p", value, value);
//        return YES;
//    }] subscribeNext:^(id x){
//        // filter NO 就不会进来了
//        NSLog(@"3 subscribe--- %@  %p", x, x);
//    }];
}

#pragma mark - Binding, distinctUntilChanged
- (void)bindingData {
    //  distinctUntilChanged    连续的相同的输入值就会有不必要的处理，
    //  遇到如写数据库，发网络请求的情况时，代价就不能购忽略了
    RAC(self.textField, text) = [RACObserve(self, name) distinctUntilChanged];
    
    [[self.textField.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *x) {
        //this creates a reference to self that when used with @weakify(self);
        //makes sure self isn't retained
        NSLog(@"xxxx %@", x);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //  Model 改变后，反映到 View
        self.name = @"bindingData 111";
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.name = @"bindingData 222";
    });
}

@end
