//
//  SequenceCtrl.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/6/1.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "SequenceCtrl.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface SequenceCtrl ()

@end

@implementation SequenceCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - RACSequence
- (void)testSequence {
    
    //    NSArray *array = @[ @"A", @"B", @"C" ];
    //    RACSequence *sequence = [array.rac_sequence map:^(NSString *str) {
    //        NSLog(@"item = %@", str);
    //        return [str stringByAppendingString:@"_"];
    //    }];
    //    NSLog(@"%@", [sequence array]);
    
    NSArray *array = @[@(1), @(2), @(3)];
    
    NSLog(@"%@", [[[array rac_sequence] map:^id(id value){
        return @(pow([value integerValue], 2));
    }] array]);
    
    NSLog(@"%@", [[[array rac_sequence] filter:^BOOL(id value){
        return [value integerValue] % 2 == 0;
    }] array]);
    
    NSLog(@"%@", [[[array rac_sequence] map:^id(id value) {
        return [value stringValue];
    }] foldLeftWithStart:@"--" reduce:^id(id accumulator, id value) {
        
        NSLog(@"：：%@", accumulator);
        return [accumulator stringByAppendingString:value];
    }]);
}

#pragma mark - Concatenating
- (void)testConcat {
    RACSequence *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence;
    RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;
    
    // Contains: A B C D E F G H I 1 2 3 4 5 6 7 8 9
    RACSequence *concatenated = [letters concat:numbers];
    NSLog(@"%@", concatenated);
    NSLog(@"%@", concatenated.array);
}

#pragma mark - Flattening
- (void)testFlatten {
    RACSequence *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence;
    RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;
    RACSequence *sequenceOfSequences = @[ letters, numbers ].rac_sequence;
    
    // Contains: A B C D E F G H I 1 2 3 4 5 6 7 8 9
    RACSequence *flattened = [sequenceOfSequences flatten];
}

@end
