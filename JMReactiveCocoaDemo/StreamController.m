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

//  http://segmentfault.com/a/1190000000408492
@interface StreamController ()

@end

@implementation StreamController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stream];
//    [self testSubject];
}

- (void)testSubject {
    
    RACSubject *sub = [RACSubject subject];
    [sub subscribeNext:^(id x){
        NSLog(@"%@", x);
    }];
    
    [sub sendNext:@"AAA"];
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
    
    // Outputs: 1 A  B C 2
    [flattened subscribeNext:^(NSString *x) {
        NSLog(@"%@", x);
    }];
    
    [numbers sendNext:@"1"];
    [letters sendNext:@"A"];
    [letters sendNext:@"B"];
    [letters sendNext:@"C"];
    [numbers sendNext:@"2"];
}


@end
