//
//  LoginController.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/3/28.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "LoginController.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface LoginController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.nameTextField.rac_textSignal = RACObserve(<#TARGET#>, <#KEYPATH#>)
    self.loginButton.enabled = NO;
    RAC(self.loginButton, enabled) = [RACSignal combineLatest:@[self.nameTextField.rac_textSignal,
                                                                self.pwdTextField.rac_textSignal,
//                                                                RACObserve(LoginManager.sharedManager, loggingIn),
                                                                //RACObserve(self, loggedIn)
                                                                ]
                                                       reduce:^(NSString *name, NSString *password) {
                                                          
                                                          // 每个 signal 监听一个属性，name 来至 nameTextField.rac_textSignal.text
                                                           NSLog(@"combine 里的 signals 其中一个改变就触发");
                                                          id enabled = @(name.length > 0 && password.length > 0);

                                                          //  返回给 self.loginButton.enabled, 控制按钮的 enabled 属性
                                                          return enabled;
                                                      }];
    
    
    [_nameTextField.rac_textSignal subscribeNext:^(NSString *text){
        NSLog(@"---- %@", text);
        if (text.length < 3) {
            _tipsLabel.text = @"ID 长度要 > 3";
        }else{
            _tipsLabel.text = @"ID 长度满足";
        }
    }];
    

    [_pwdTextField.rac_textSignal subscribeNext:^(NSString *text){
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
