//
//  Blah.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/5/21.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "Blah.h"

@interface Blah ()
@property (copy) NSMutableArray *arrayProperty;

@end


@implementation Blah

- (instancetype)init {
    if (self = [super init]) {
//        _arrayProperty = @[@"xxxxx"];
                _arrayProperty = [NSMutableArray arrayWithArray:@[@"xxxxx"]];
    }
    return self;
}
- (void)change {
    [self.arrayProperty addObjectsFromArray:@[@"A", @"BBBBBB"]];
    
}
@end
