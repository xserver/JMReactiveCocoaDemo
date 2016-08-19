//
//  CommandController.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/3/30.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//
// https://github.com/olegam/RACCommandExample


#import "CommandCtrl.h"
#import "SubscribeViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <Masonry/Masonry.h>

@interface CommandCtrl ()
@property(nonatomic, strong) SubscribeViewModel *viewModel;

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UIButton    *subscribeButton;
@property (nonatomic, strong) UILabel     *statusLabel;

@property (weak, nonatomic) IBOutlet UIButton *commandButton;

@property (nonatomic, copy) NSString *name;
@end


@implementation CommandCtrl

- (id)init {
    self = [super init];
    if (self) {
        self.viewModel = [SubscribeViewModel new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addViews];
    [self defineLayout];
    [self bindData];
    
    [self testButton];
}

- (void)bindData {
    
    RAC(self.viewModel, email) = self.emailTextField.rac_textSignal;
    
    self.subscribeButton.rac_command = self.viewModel.subscribeCommand;
    
    RAC(self.statusLabel, text) = RACObserve(self.viewModel, statusMessage);
}

- (void)testButton {

    //  _commandButton.rac_command.executing
    //  _commandButton.rac_command.executionSignals
    //  _commandButton.rac_command.enabled             //  是否启动
    //  _commandButton.rac_command.errors
    //  _commandButton.rac_commandallowsConcurrentExecution
    
    _commandButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id input) {
        
        NSLog(@"button was pressed!");
        NSLog(@"input = %@", input);
        
        UIButton *btn = input;
        btn.enabled = NO;
        
//        return [RACSignal empty];
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [subscriber sendNext:@"xxxxxx"];
                [subscriber sendCompleted];
            });
            
//            [subscriber sendError:@"aaaaaaa"];
            return nil;
        }];
    }];
    
    
    //  针对 UIControl 事件的 Signal
    [[_commandButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
        NSLog(@"UIControlEventTouchUpInside  %@", [x class]);
    }];
    
    [_commandButton.rac_command.executing subscribeNext:^(id x){
        NSLog(@"executing == %@      %@", x, [x class]);
    }];
    
    [_commandButton.rac_command.executionSignals subscribeNext:^(id x){
        NSLog(@"executionSignals == %@       %@", x, [x class]);
    }];

    [_commandButton.rac_command.enabled subscribeNext:^(id x){
        NSLog(@"enabled == %@   %@", x, [x class]);
    }];

    [_commandButton.rac_command.errors subscribeNext:^(id x){
        NSLog(@"errors == %@   %@", x, [x class]);
    }];
}

- (void)requestData {
    //  模拟网络
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    });
}

- (void)testCommand {
    
    _commandButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal* (id input){
        NSLog(@"button passed");
        
        //  如何创建一个 signal 并返回
        return [RACSignal empty];
    }];
}

#pragma mark -
- (void)addViews {
    [self.view addSubview:self.emailTextField];
    [self.view addSubview:self.subscribeButton];
    [self.view addSubview:self.statusLabel];
}

- (void)defineLayout {
    @weakify(self);

    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.view).with.offset(100.f);
        make.left.equalTo(self.view).with.offset(20.f);
        make.height.equalTo(@50.f);
    }];
    
    [self.subscribeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.emailTextField);
        make.right.equalTo(self.view).with.offset(-25.f);
        make.width.equalTo(@70.f);
        make.height.equalTo(@30.f);
        make.left.equalTo(self.emailTextField.mas_right).with.offset(20.f);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.emailTextField.mas_bottom).with.offset(20.f);
        make.left.equalTo(self.emailTextField);
        make.right.equalTo(self.subscribeButton);
        make.height.equalTo(@30.f);
    }];
}


#pragma mark - Views
- (UITextField *)emailTextField {
    if (!_emailTextField) {
        _emailTextField = [UITextField new];
        _emailTextField.borderStyle = UITextBorderStyleRoundedRect;
        _emailTextField.font = [UIFont boldSystemFontOfSize:16];
        _emailTextField.placeholder = NSLocalizedString(@"Email address", nil);
        _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return _emailTextField;
}

- (UIButton *)subscribeButton {
    if (!_subscribeButton) {
        _subscribeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_subscribeButton setTitle:NSLocalizedString(@"Subscribe", nil) forState:UIControlStateNormal];
    }
    return _subscribeButton;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [UILabel new];
    }
    return _statusLabel;
}

@end