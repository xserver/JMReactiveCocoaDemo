//
//  StreamController.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/4/2.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "StreamController.h"
#import <ReactiveCocoa.h>
#import <RACEXTScope.h>

@interface StreamController ()

@end

@implementation StreamController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)stream {
    RACSubject *letters = [RACSubject subject];
    RACSubject *numbers = [RACSubject subject];
    RACSignal *signalOfSignals = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
        [subscriber sendNext:letters];
        [subscriber sendNext:numbers];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *flattened = [signalOfSignals flatten];
    
    // Outputs: A 1 B C 2
    [flattened subscribeNext:^(NSString *x) {
        NSLog(@"%@", x);
    }];
    
    [letters sendNext:@"A"];
    [numbers sendNext:@"1"];
    [letters sendNext:@"B"];
    [letters sendNext:@"C"];
    [numbers sendNext:@"2"];

}

@end
