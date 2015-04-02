//
//  DelegateController.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/4/2.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "DelegateController.h"
#import <objc/runtime.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/RACDelegateProxy.h>

@interface DelegateController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) RACDelegateProxy *proxy;
@end

@implementation DelegateController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testDelegateTransformBlock];
    

}

- (void)testDelegateTransformBlock {

    [[self.textField rac_signalForControlEvents:UIControlEventEditingDidEndOnExit] subscribeNext:^(id x) {
        
        NSLog(@"和下面那个一样的功能，但是不能并存，");
        NSLog(@"%s", __func__);
    }];
    
    @autoreleasepool {
        
        RACDelegateProxy *proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(UITextFieldDelegate)];
        
        [[proxy rac_signalForSelector:@selector(textFieldShouldReturn:)] subscribeNext:^(RACTuple *args) {
            
            //
            NSLog(@"------ %@", args);
            UITextField *field  = [args first];
            [field resignFirstResponder];
        }];
        
        //  textField.delegate 对应 proxy.selector
        self.textField.delegate = (id<UITextFieldDelegate>)proxy;
        //  delegate weak, proxy 无人 strong，所以要保留好。

        _proxy = proxy;
        //    objc_setAssociatedObject(self.textField, _cmd, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    


}


@end
