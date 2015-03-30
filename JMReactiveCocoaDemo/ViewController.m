//
//  ViewController.m
//  JMReactiveCocoaDemo
//
//  Created by 积木.xserver.Github on 15/3/24.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "LoginController.h"
#import "CommandController.h"
/* 
 http://yulingtianxia.qiniudn.com/blog/2014/07/29/reactivecocoa/
 https://github.com/jspahrsummers/GroceryList RAC 作者
 https://github.com/ReactiveCocoa/ReactiveCocoaLayout   ReactiveCocoaLayout
 
 http://limboy.me/ios/2013/12/27/reactivecocoa-2.html 李忠
 http://limboy.me/ios/2014/06/06/deep-into-reactivecocoa2.html  李忠
 http://www.infoq.com/cn/presentations/practice-of-reactivecocoa-in-huabanwang-client 视频李忠
 
 AFNetworking
 http://codeblog.shape.dk/blog/2013/12/02/transparent-oauth-token-refresh-using-reactivecocoa/
 http://codeblog.shape.dk/blog/2013/11/16/wrapping-afnetworking-with-reactivecocoa/
 
 */

/*
 在block中如果要引用self，需要使用@weakify(self)和@strongify(self)来避免强引用。
 使用时应该注意block的嵌套层数，不恰当的滥用多层嵌套block可能给程序的可维护性带来灾难。
 
 signal作为local变量时，如果没有被subscribe，那么方法执行完后，该变量会被dealloc。
 signal有被subscribe，那么subscriber会持有该signal，直到signal sendCompleted或sendError时，才会解除持有关系，signal才会被dealloc。
 
 RAC 有哪些功能？
 1、监听视图的变化 UIView
 2、监听属性的变化 NSObject
 3、监听事件的变化（UIControlEvents）
 
 4、如何解除监听
 5、并行


*Signal的特性   RACSignal+Operations.h
 filter   过滤
 combine  && 叠加
 merge    ||
 map      修改
 chaining 串联


 
*对 OC 的扩展
 各个控件 和 UIControlEvents
 基础的 NSObject
 ...
 KVO Delegate
 NSArray rac_sequence
 
 @protocol RACSubscriber;
 
 @class RASSingal
 @class RACCommand;     表示某个Action的执行，比如点击Button。executionSignals / errors / executing。
 @class RACDisposable;
 @class RACMulticastConnection;
 @class RACScheduler;
 @class RACSequence;    顺序执行
 @class RACSubject;
 @class RACTuple;

 RAC 中 KVO 的操作隐藏在 search NSKeyValueObservingOptions
 RACKVOTrampoline : RACDisposable   observeValueForKeyPath:ofObject:change:context
 */
#import "Apple.h"
@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic  ) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UIButton    *button;
@property (weak, nonatomic  ) IBOutlet UILabel     *label;

@property (nonatomic, copy  ) NSString    *name;
@property (nonatomic, strong) NSArray     *array;
@property (nonatomic, strong) Apple       *apple;

@property (nonatomic, strong) UITableView *table;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self testGestureRecognizer];
//    NSArray *strings = @[ @"A", @"B", @"C" ];
//    RACSequence *sequence = [strings.rac_sequence map:^(NSString *str) {
//        return [str stringByAppendingString:@"_"];
//    }];
    NSArray *list = @[@"1", @"22", @"333"];
    NSArray *result = [self filterArray:list condition:^(NSString *item, BOOL *right){
        
        *right = (item.length > 2) ? YES : NO;
    }];
    
    NSLog(@"%@", result);
    
    
    @weakify(self);
    
//    [self testSignal];
    [self testBinding];
//    [self testSubscript];
//    [self testObject];
//    [self testFilter];

//    [self testButton];
//    [self testTable];
//    [self testFilter];


    
//    [_name rac_deallocDisposable]

    _loginButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id button) {
        id ctrl = [[LoginController alloc] init];
        [self presentViewController:ctrl animated:NO completion:nil];
        return [RACSignal empty];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openCommandExample:(id)sender {

    id ctrl = [[CommandController alloc] init];
    [self presentViewController:ctrl animated:NO completion:nil];
}

#pragma mark - Signal
- (void)testSignal {
    @weakify(self);
    NSLog(@"testSignal1: %@", RACObserve(self.textField, text));
    NSLog(@"testSignal2: %@", RACObserve(self.textField, text));
    NSLog(@"testSignal3: %@", RACObserve(self.textField, text));
    
    [[RACObserve(self.textField, text) rac_willDeallocSignal] subscribeNext:^(id x){
        NSLog(@"testSignal dealloc");
    }];
    //  what is signal ?    signal = KVO + Block;

    //    开始时，别用 RACObserve 宏，会更清晰
    RACSignal *signal = [self.textField rac_valuesForKeyPath:@"text" observer:self];    //  
    [signal subscribeNext:^(id x){
        NSLog(@"subscribeNext   %@", x);
    }]; //  subscribeCompleted
    
//    [RACObserve(self.textField, text) subscribeNext:^(id x){        NSLog(@"subscribeNext");}];
    _textField.text = @"boy";
    return;

    
    //  signal 怎么触发
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        self.textField.text = @"aaa";
    });
    
    //  cold
    RACSignal *cold = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {

        //  什么时候触发这个 send ？
        [subscriber sendNext:@"这是 cold 的时候 RACSubscriber 发的"];
//        sendCompleted 和 sendError 二者只能发一个，看顺序，先进先出
        [subscriber sendCompleted];
        [subscriber sendError:[NSError errorWithDomain:@"hello, I'm subscriber error!" code:0 userInfo:nil]];
        
        return nil; //  返回 RACDisposable
    }];
    
    //  hot, cold 被 subscribe 后，hot，激活
    [cold subscribeNext:^(id x){
        NSLog(@"%@", x);
    }];
    [cold subscribeCompleted:^(){
        NSLog(@"cold completed");
    }];
    
    [cold subscribeError:^(NSError *error){
        NSLog(@"%@", error.domain);
    }];
}

#pragma mark - Subscript
- (void)testSubscript {
    /*
     RAC(self.textField, enabled) = signal; // 将 signal 和 左边的 kv 关联起来
     
     宏展开
     [[RACSubscriptingAssignmentTrampoline alloc] initWithTarget:(self.textField) nilValue:(((void *)0))][@(((void)(__objc_no && ((void)self.textField.enabled, __objc_no)), "enabled"))] = signal;
     
     逗号表达式
     
     意义如下
     [RACSubscriptingAssignmentTrampoline setObject:signal forKeyedSubscript:@"enabled"];
     
     */
    
    
//    Signals也可以被用于导出状态。不必观察属性然后设置其他属性来响应这个属性新的值，RAC可以依照signals和操作来表达属性
    
//    RAC(_textField, enabled) = [RACSignal
//                                combineLatest:@[RACObserve(self, password),
//                                                RACObserve(self, passwordConfirmation)]
//                                
//                                reduce:^(NSString *password, NSString *passwordConfirm) {
//                                    return @([passwordConfirm isEqualToString:password]);
//                                }];
    
    
    RACSignal *signal = RACObserve(self.textField, text);
    [signal subscribeNext:^(id x){
        NSLog(@"testSubscript %@", x);
    }];
    
//    RAC(self.textField, text) = signal;
    
    self.textField.text = @"kk";
}



#pragma mark - Object
- (void)testObject {
    //  将要 dealloc
    
//    NSArray *array = @[@"foo"];
//    [[array rac_willDeallocSignal] subscribeCompleted:^{
//        NSLog(@"oops, i will be gone");
//    }];
//    array = nil;
//    
//    return;
    
    _array = @[@"~~~~"];    //  使用 string 测试会有问题，string 没有立刻执行，copy || string 的内存管理 ？
    NSLog(@"%@", _array);
    
    [[_array rac_willDeallocSignal] subscribeCompleted:^(){
        NSLog(@"我已经 dealloc 啦：%@", _array);
    }];
    _array = nil;
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

#pragma mark - 控件
- (void)testView {
    //  change 后立马调用，针对 text
    [RACObserve(self.textField, text) subscribeNext:^(id x){
        NSLog(@"2--- %@", x);
    }];
    
    [RACObserve(self.textField, text) subscribeNext:^(id x){
        NSLog(@"2.1--- %@", x);
    } completed:^(){
        NSLog(@"2.2 completed");
    }];
    
    //  针对 view 里面的内容
    [self.textField.rac_textSignal subscribeNext:^(id x){
        NSLog(@"4--- %@", x);
    }];
}

#pragma mark - 手势 UIGestureRecognizer
- (void)testGestureRecognizer {
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    
    [[tapGesture rac_gestureSignal] subscribeNext:^(id x) {
//        [self.viewModel.likeCommand execute:nil];
        NSLog(@"testGestureRecognizer  %@", [x class]);
    }];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [self.view addGestureRecognizer:longPress];
    [longPress.rac_gestureSignal subscribeNext:^(id x) {
        NSLog(@"%@", [x class]);
    }];
}

#pragma mark - UIControl RACCommand
- (void)testButton {

    _button.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id button) {
        NSLog(@"button was pressed!");
        return [RACSignal empty];
    }];

    //    _button.rac_command.executing
    //    _button.rac_command.executionSignals
//        _button.rac_command.errors subscribeNext:<#^(id x)nextBlock#>
    
    RACSignal *signal = [RACObserve(self, name)
                         map:^id(id x){
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

- (IBAction)changeButtonAction:(id)sender {
    
    NSLog(@"%@", _textField.text);
    _textField.text = @"123";
}

#pragma mark - Notification
- (void)testNotification {

    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"sky call" object:nil]
     subscribeNext:^(NSNotification *notification) {
         NSLog(@"sky call - Notification Received");
    }];
}

#pragma mark - NSArray 等集合
- (void)testCollection {
    
    //    RACSequence : RACStream
    
    _array = @[@"A", @"B"];
//    _array.rac_sequence = nil;
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

- (void)doA:(NSString *)A withB:(NSString *)B
{
    NSLog(@"A:%@\nB:%@", A, B);
}

#pragma mark - Binding
- (void)testBinding {
    
    @weakify(self);
    //Start Binding our properties
    RAC(self.textField, text) = [RACObserve(self, name) distinctUntilChanged];
    
    [[self.textField.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *x) {
        //this creates a reference to self that when used with @weakify(self);
        //makes sure self isn't retained
        @strongify(self);
//        self.name = x;
        NSLog(@"xxxx %@", x);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //  Model 改变后，反映到 View
        self.name = @"testBinding ---";
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.name = @"testBinding aaa";
    });
}

#pragma mark - protect
- (void)testProtectMyself {
    _apple = [[Apple alloc] init];
    _apple.name = @"积木";
    //    [_apple protectMyself];
    
    NSLog(@"%@  %@", _apple, _apple.name);
    [[_apple rac_willDeallocSignal] subscribeCompleted:^(){
        NSLog(@"Apple 被释放啦 %@", _apple);
    }];
    _apple = nil;
}

#pragma mark - Table
- (UITableView *)table {
    if (_table == nil) {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(20, 80, 200, 200)];
        _table.dataSource = self;
        _table.delegate = self;
//        _table.backgroundColor = [UIColor brownColor];
    }
    return _table;
}

- (void)testTable {
    [self.view addSubview:self.table];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ide = @"~~";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ide];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ide];
        cell.contentView.backgroundColor = [UIColor greenColor];
        
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(100, 4, 80, 36);
        btn.backgroundColor = [UIColor purpleColor];
        [cell addSubview:btn];
        
        [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside]
          takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(id x){
            NSLog(@"cell button passed");
        }];
        
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
            NSLog(@"cell button passed");
        }];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ide];
//    if (cell == nil) {
//        UIButton *btn;
//        [cell addSubview:btn];
//        
//        [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside]
//          takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(id x){
//            NSLog(@"cell button passed");
//        }];
//        
//        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
//            NSLog(@"cell button passed");
//        }];
//    }
//    
//    return cell;
//}

- (NSArray *)filterArray:(NSArray *)list condition:(void (^)(NSString *x, BOOL *right))block {
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:5];
    BOOL right;
    for (int i = 0; i < list.count; i++) {
        block(list[i], &right);
        if (right) {
            [result addObject:@(i)];
        }
    }
    
    return result;
}
@end

