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

@property(nonatomic, strong) UITextField *emailTextField;
@property(nonatomic, strong) UIButton *subscribeButton;
@property(nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong  ) UIButton    *commandButton;
@property (nonatomic, strong) UIButton *button;
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
    
    self.title = NSLocalizedString(@"Subscribe Example", nil);
    
    [self addViews];
    [self defineLayout];
    [self bindWithViewModel];
}

#pragma mark -

- (void)addViews {
    [self.view addSubview:self.emailTextField];
    [self.view addSubview:self.subscribeButton];
    [self.view addSubview:self.statusLabel];
}

- (void)testButton {
    
    _button.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id button) {
        NSLog(@"button was pressed!");
        return [RACSignal empty];
    }];
    
    //    _button.rac_command.executing
    //    _button.rac_command.executionSignals
    //        _button.rac_command.errors subscribeNext:<#^(id x)nextBlock#>
    
    RACSignal *signal = [RACObserve(self, name) map:^id(id x){
        return @"";
    }];
    
    //    _button.rac_command = [[RACCommand alloc] initWithEnabled:signal
    //                                                  signalBlock:^RACSignal *(id input){
    //                                                      return [RACSignal empty];
    //                                                  }];
    
    // combine  组合
    //    RACSignal combineLatest:<#(id<NSFastEnumeration>)#> reduce:<#^id(void)reduceBlock#>
    //    [_button rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:<#(RACSignal *)#>
    
    
    //  针对 UIControl 事件的 Signal
    [[_button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
        NSLog(@"events");
    }];
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

- (void)bindWithViewModel {
    RAC(self.viewModel, email) = self.emailTextField.rac_textSignal;
    self.subscribeButton.rac_command = self.viewModel.subscribeCommand;
    RAC(self.statusLabel, text) = RACObserve(self.viewModel, statusMessage);
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

#pragma mark - xx
- (void)testCommand {
    _commandButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal* (id input){
        NSLog(@"button passed");
        
        //  如何创建一个 signal 并返回
        return [RACSignal empty];
    }];
}
@end