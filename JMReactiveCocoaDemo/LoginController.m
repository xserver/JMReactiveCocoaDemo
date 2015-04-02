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

/*
    场景案例
 用户名、密码长度
 用户名+密码合格，登录按钮可用
 提示
 
 
 https://github.com/olegam/RACCommandExample
 */

@interface LoginController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic  ) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic  ) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic  ) IBOutlet UILabel     *tipsLabel;

@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (copy, nonatomic) RACCommand *loginCommand;
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];

    [_nameTextField.rac_textSignal subscribeNext:^(NSString *text){
        if (text.length < 3) {
            _tipsLabel.text = @"ID 长度要 > 3";
        }else{
            _tipsLabel.text = @"ID 长度满足";
        }
    }];
    
    [self testMap];
    [self testCombine];
//
//
//    [_pwdTextField.rac_newTextChannel subscribeNext:^(NSString *text){
//        NSLog(@"??");
//    }];
}

#pragma mark - ----- Signal 特性 -----
#pragma mark - Filter
- (void)testFilter {
    
    //  过滤模式
    [[RACObserve(self.nameTextField, text) filter:^(id value) {
        NSLog(@"2 filter------ %@  %p", value, value);
        return YES;
    }] subscribeNext:^(id x){
        // filter NO 就不会进来了
        NSLog(@"3 subscribe--- %@  %p", x, x);
    }];
    
    
    RACSignal *validEmailSignal = [self.nameTextField.rac_textSignal map:^id(NSString *value) {
        return @([value rangeOfString:@"@"].location != NSNotFound);
    }];
    
    RAC(self.loginButton, enabled) = validEmailSignal;
    RAC(self.nameTextField, textColor) = [validEmailSignal map:^id(id value) {
        return [value boolValue] ? [UIColor greenColor] : [UIColor redColor];
    }];
}

#pragma mark - Combine
- (void)testCombine {
    
    self.loginButton.enabled = NO;
    RAC(self.loginButton, enabled) = [RACSignal combineLatest:@[self.nameTextField.rac_textSignal,
                                                                self.pwdTextField.rac_textSignal,
                                                                //RACObserve(LoginManager.sharedManager, loggingIn),
                                                                //RACObserve(self, loggedIn)
                                                                ]
                                                       reduce:^(NSString *name, NSString *password) {
                                                           
                                                           //   所有 signal 有值，才会执行，是一个 && 操作，button 比较能体现
                                                           // 每个 signal 监听一个属性，name 来至 nameTextField.rac_textSignal.text
                                                           NSLog(@"combine name:%@ - pwd:%@",name, password);
                                                           id enabled = @(name.length > 0 && password.length > 0);
                                                           
                                                           //  返回给 self.loginButton.enabled, 控制按钮的 enabled 属性
                                                           return enabled;
                                                       }];
}

#pragma mark - Merge
- (void)testMerge {
    [[RACSignal merge:@[_nameTextField.rac_textSignal,
                        _pwdTextField.rac_textSignal]] subscribeNext:^(id x) {
        
        NSLog(@"merge只能拿到 其中一个 signal 监听的值： %@", x);
        
        _tipsLabel.text = x;
    }];
}

#pragma mark - Map
- (void)testMap {

    //  改变一个 signal 的返回，string -> Color
    RACSignal *signal = [_nameTextField.rac_textSignal map:^id(NSString *text) {
        UIColor *color = (text.length > 3) ? [UIColor greenColor] : [UIColor redColor];
        return color;
     }];
    
    RAC(_tipsLabel, textColor) = signal;
}

#pragma mark - Chaining
- (void)testChaining {
    
//    [_chatTextField.rac_textSignal then:^(){
//        return _nameTextField.rac_textSignal;
//    }];
//    
//    [[[[client logIn]
//       then:^{
//           return [client loadCachedMessages];
//       }]
//      flattenMap:^(NSArray *messages) {
//          return [client fetchMessagesAfterMessage:messages.lastObject];
//      }]
//     subscribeError:^(NSError *error) {
//         [self presentError:error];
//     } completed:^{
//         NSLog(@"Fetched all messages.");
//     }];
}

- (void)xx {
    @weakify(self);    
//    id numberLimit = @(60);
//    
//    RACSignal *timeSignal = [[[[[RACSignal interval:1.0f onScheduler:[RACScheduler mainThreadScheduler]]
//                                take:numberLimit]
//                               startWith:@(1)]
//                              map:^id(NSDate *date) {
//                                @strongify(self);
//                                if (number == 0) {
//                                    [self.timeButton setTitle:@"重新发送" forState:UIControlStateNormal];
//                                    return @YES;
//                                }
//                                else{
//                                    self.timeButton.titleLabel.text = [NSString stringWithFormat:@"%d", number--];
//                                    return @NO;
//                                }
//                              }] takeUntil:self.rac_willDeallocSignal];
//    
//    self.loginButton.rac_command = [[RACCommand alloc]initWithEnabled:timeSignal signalBlock:^RACSignal *(id input) {
//        number = numberLimit;
//        return timeSignal;
//    }];
}

@end
