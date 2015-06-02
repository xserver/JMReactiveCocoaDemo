//
//  MainCtrl.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/6/1.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "MainCtrl.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "LoginExampleCtrl.h"
#import "CommandCtrl.h"
#import "SignalOperationsCtrl.h"
#import "DelegateController.h"
#import "StreamController.h"
#import "FilterCtrl.h"
#import "Blah.h"
#import "Apple.h"

@interface MainCtrl ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tab;
@property (nonatomic, weak  ) IBOutlet UITextField *textField;
@property (nonatomic, strong) NSArray *list;

@property (nonatomic, copy  ) NSString *name;
@property (nonatomic, strong) NSArray  *array;
@property (nonatomic, strong) Apple    *apple;

@property (nonatomic, strong) NSMutableString *releaseObj;
@property (nonatomic, strong) RACDisposable *disposable;

@end

@implementation MainCtrl
{
    Blah *blah;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.list = @[
                  @"LoginExampleCtrl",
                  @"SignalOperationsCtrl",
                  @"CommandCtrl",
                  @"DelegateController",
                  @"StreamController",
                  @"FilterCtrl"
                  ];
    [self.view addSubview:self.tab];
    //    [self testMutableArrayChange];
    
    //    [self signalColdToHot];
    //    [self packEvent];
    
    //    [self testSequence];
    //    [self objectSignalCategory];
    
    //    [_name rac_deallocDisposable]
}

#pragma mark - Signal
- (void)signalCreate {
    //  通过 KV 创建一个 signal，接收其变化，然后订制事件。RACObserve
    RACSignal *signal = [self.textField rac_valuesForKeyPath:@"text" observer:self];
    
    RACObserve(self.textField, text);   //  两者等同
    
    [signal subscribeNext:^(id x){   //  subscribeCompleted
        NSLog(@"signalCreate - subscribeNext   %@", x);
    }];
    
    //  UI控件的变化
    [_textField.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"signalCreate = %@", x);
    }];
}

- (void)signalRelate {
    RACSignal *signal = nil;
    
    // signal 的结果，返回给 左边
    RAC(self.textField, enabled) = signal; // 将 signal 和 左边的 kv 关联起来
    
    /*
     宏展开, 逗号表达式
     [[RACSubscriptingAssignmentTrampoline alloc] initWithTarget:(self.textField) nilValue:(((void *)0))][@(((void)(__objc_no && ((void)self.textField.enabled, __objc_no)), "enabled"))] = signal;
     
     意义如下
     [RACSubscriptingAssignmentTrampoline setObject:signal forKeyedSubscript:@"enabled"];
     
     RAC(self.outputLabel, text) = self.inputTextField.rac_textSignal;
     RAC(self.outputLabel, text, @"收到nil时就显示我") = self.inputTextField.rac_textSignal;
     */
}
- (void)packEvent {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"准备下载"];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), queue, ^{
            id data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://www.baidu.com"]];
            [subscriber sendNext:@"下载完成，请准备接收"];
            [subscriber sendNext:data];
            [subscriber sendCompleted]; //  触发 disposable
        });
        
        return [RACDisposable disposableWithBlock:^{
            //  do something ? 这里是返回一个可以 干掉 task 的 block
            NSLog(@"?? clean up");
        }];
    }];
    
    self.disposable = [signal subscribeNext:^(id x) {
        
        //  一订阅就触发 sendNext;
        if ([x isKindOfClass:[NSString class]]) {
            NSLog(@"pack subscribeNext = %@", x);
        }else{
            NSLog(@"pack subscribeNext = 人家是数据");
        }
    }];
    
    [signal subscribeCompleted:^(){
        NSLog(@"subscribeCompleted 完成");
    }];
    
    //  log ?
    [[signal logAll] subscribeNext:^(id x){
        NSLog(@"\n******** %@\n\n", x);
    }];
    return;
    
}
- (void)whatIsSignal {
    //  what is signal ?
    //  signal = KVO + Block;  &&  Block  = Function;
    //         = KVO + Function;
    return;
}

- (void)signalColdToHot {
    
    //  cold
    RACSignal *signal = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
        
        //  一个signal的生命由很多下一个(next)事件和一个错误(error)或完成(completed)事件组成（后两者不同时出现）
        //  什么时候触发这些 send ？如同 socket::accept->fork, subscribe = connect
        [subscriber sendNext:@"signalColdToHot sendNext 1"];
        [subscriber sendNext:@"signalColdToHot sendNext 2"];
        
        //  sendCompleted 和 sendError 二者只能发一个，看顺序，先进先出
        [subscriber sendCompleted];
        [subscriber sendError:[NSError errorWithDomain:@"subscriber error!" code:0 userInfo:nil]];
        
        return nil; //  返回 RACDisposable
    }];
    
    //  如果没有订阅者 (subscribe) ，signal 就不会执行，被 subscribe 后被激活，cold - hot
    [signal subscribeNext:^(id x){
        NSLog(@"signalColdToHot - next %@", x);
    }];
    [signal subscribeCompleted:^(){
        NSLog(@"signalColdToHot - completed");
    }];
    
    [signal subscribeError:^(NSError *error){
        NSLog(@"signalColdToHot - %@", error.domain);
    }];
}

#pragma mark - Object
- (void)objectSignalCategory {
    
    //  使用 string 测试会有问题，string 没有立刻执行，copy || string 的内存管理 ？
    
    @autoreleasepool {
        _releaseObj = [NSMutableString stringWithFormat:@"xx, %@", @"aaa"];
        [[_releaseObj rac_willDeallocSignal] subscribeCompleted:^(){
            
            NSLog(@"xxx release");
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _releaseObj = nil;
        });
    }
    
    @autoreleasepool {
        NSString *str = @"hello";
        [[str rac_willDeallocSignal] subscribeCompleted:^(){
            NSLog(@"aaaa");
        }];
        str = nil;
    }
    
    //    _array = @[@"~~~~"];
    //    [[_array rac_willDeallocSignal] subscribeCompleted:^(){
    //        NSLog(@"我已经 dealloc 啦：%@", _array);
    //    }];
    //    _array = nil;
}

#pragma mark - select
- (void)testSelector {
    
    //  当selector执行完时，会sendNext
    RACDisposable *disposable = [[self rac_signalForSelector:@selector(test)] subscribeNext:^(id value){
        NSLog(@"我要 hook test 这个方法");
    }];
    
    //    self rac_signalForSelector:<#(SEL)#> fromProtocol:<#(Protocol *)#>
    [self test];
    
    //  取消
    [disposable dispose];
}

#pragma mark - Notification
- (void)testNotification {
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"sky call" object:nil]
     subscribeNext:^(NSNotification *notification) {
         NSLog(@"sky call - Notification Received");
     }];
}

#pragma mark - Lifting
- (void)test {
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"A"]; //  2秒后 sendNext
        });
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1B"];
        [subscriber sendNext:@"2B"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //
    [self rac_liftSelector:@selector(doA:withB:) withSignals:signalA, signalB, nil];
}

- (void)doA:(NSString *)A withB:(NSString *)B {
    NSLog(@"A:%@\nB:%@", A, B);
}


#pragma mark -
- (void)testMutableArrayChange {
    blah = [[Blah alloc] init];
    NSLog(@"0000  %@", blah.arrayProperty);
    
    RACSignal *changeSignal = [blah rac_valuesAndChangesForKeyPath:@keypath(blah, arrayProperty)
                                                           options:NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld
                                                          observer:nil];
    
    [changeSignal subscribeNext:^(RACTuple *x){
        NSArray *wholeArray = x.first;
        NSDictionary *changeDictionary = x.second;
        
        NSLog(@"wholeArray  %@", wholeArray);
        NSLog(@"changeDictionary    %@", changeDictionary);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [blah change];
    });
}

#pragma mark - Create Table
static NSString *kCellIdentifier = @"listcell";
- (UITableView *)tab {
    
    if (_tab == nil) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _tab = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tab.dataSource = self;
        _tab.delegate = self;
        _tab.separatorStyle = UITableViewCellSelectionStyleNone;
        
        _tab.sectionIndexColor = [UIColor blueColor];
        _tab.sectionIndexBackgroundColor = [UIColor whiteColor];
        
        _tab.sectionIndexTrackingBackgroundColor = [UIColor greenColor];
        _tab.separatorColor = [UIColor purpleColor];
        
        [_tab registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    
    return _tab;
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    
    cell.textLabel.text = [self.list objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *name = cell.textLabel.text;
    [self.navigationController pushViewController:[[NSClassFromString(name) alloc] init] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
@end
