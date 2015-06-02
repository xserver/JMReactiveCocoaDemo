//
//  LoginExampleCtrl.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/3/28.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "LoginExampleCtrl.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

/*
 场景案例
 
 用户名、密码长度
 用户名+密码合格，登录按钮可用
 提示
 
 https://github.com/olegam/RACCommandExample
 */

@interface LoginExampleCtrl ()
@property (weak, nonatomic) IBOutlet UIButton    *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UILabel     *tipsLabel;

@property (copy, nonatomic) RACCommand *loginCommand;
@end

@implementation LoginExampleCtrl

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [_nameTextField.rac_textSignal subscribeNext:^(NSString *text){
        if (text.length < 3) {
            _tipsLabel.text = @"ID 长度要 > 3";
        }else{
            _tipsLabel.text = @"ID 长度满足";
        }
    }];
    
    //  改变一个 signal 的返回，string -> Color
    RACSignal *colorSignal = [_nameTextField.rac_textSignal map:^id(NSString *text) {
        UIColor *color = (text.length > 3) ? [UIColor greenColor] : [UIColor redColor];
        
        return color;
    }];
    RAC(_tipsLabel, textColor) = colorSignal;
    

    self.loginButton.enabled = NO;
    RAC(self.loginButton, enabled) =
        [RACSignal combineLatest:@[self.nameTextField.rac_textSignal,
                                   self.pwdTextField.rac_textSignal,
                                //RACObserve(LoginManager.sharedManager, loggingIn),
                                //RACObserve(self, loggedIn)
                                ]
                          reduce:^(NSString *name, NSString *password) {
     
                              //    所有 signal 有值，才会执行，是一个 && 操作，button 比较能体现
                              //    每个 signal 监听一个属性，
                              //    name 来至 nameTextField.rac_textSignal.text

                           id enabled = @(name.length > 0 && password.length > 0);
                           
                           //  返回给 self.loginButton.enabled, 控制按钮的 enabled 属性
                           return enabled;
                       }];
}


#pragma mark - Filter
- (void)testFilter {
    
    RACSignal *validEmailSignal = [self.nameTextField.rac_textSignal map:^id(NSString *value) {
        return @([value rangeOfString:@"@"].location != NSNotFound);
    }];
    
    RAC(self.nameTextField, textColor) = [validEmailSignal map:^id(id value) {
        return [value boolValue] ? [UIColor greenColor] : [UIColor redColor];
    }];
    
    RAC(self.loginButton, enabled) = validEmailSignal;
}

#pragma mark - Merge
- (void)testMerge {
    [[RACSignal merge:@[_nameTextField.rac_textSignal,
                        _pwdTextField.rac_textSignal]] subscribeNext:^(id x) {
        
        NSLog(@"merge只能拿到 其中一个 signal 监听的值： %@", x);
        _tipsLabel.text = x;
    }];
}

@end
