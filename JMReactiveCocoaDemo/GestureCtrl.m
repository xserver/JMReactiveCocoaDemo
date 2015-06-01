//
//  GestureCtrl.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/6/1.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "GestureCtrl.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface GestureCtrl ()

@end

@implementation GestureCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - 手势 UIGestureRecognizer
- (void)testGestureRecognizer {
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    
    [[tapGesture rac_gestureSignal] subscribeNext:^(id x) {
        //        [self.viewModel.likeCommand execute:nil];
        NSLog(@"testGestureRecognizer  %@", [x class]);
    }];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [self.view addGestureRecognizer:longPress];
    [longPress.rac_gestureSignal subscribeNext:^(id x) {
        NSLog(@"%@", [x class]);
    }];
}
@end
