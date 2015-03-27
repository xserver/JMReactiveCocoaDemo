//
//  Apple.h
//  JMReactiveCocoaDemo
//
//  Created by 积木.xserver.Github on 15/3/27.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Apple : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) Apple *my;

- (void)protectMyself;

@end
