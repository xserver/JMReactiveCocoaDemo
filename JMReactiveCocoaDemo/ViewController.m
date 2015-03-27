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

 */
#import "Apple.h"
@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic  ) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton    *button;
@property (weak, nonatomic  ) IBOutlet UILabel     *label;

@property (nonatomic, copy  ) NSString    *name;
@property (nonatomic, strong) NSArray     *array;
@property (nonatomic, strong) Apple       *apple;

@property (nonatomic, strong) UITableView *table;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self testObject];
//    [self testFilter];

//    [self testTable];
//    [self testFilter];

    [self testSignal];
    
//    [_name rac_deallocDisposable]
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Signal
- (void)testSignal {
//  what is signal ?
//  RACSignal : RACStream : NSObject

    //  开始时，别用宏，会更清晰
    RACSignal *signal = [self.textField rac_valuesForKeyPath:@"text" observer:self];
    [signal subscribeNext:^(id x){
        NSLog(@"subscribeNext   %@", x);
    }];
    
    //  signal 怎么触发

    
    //    [RACObserve(self.textField, text) subscribeNext:^(id x){
    //        NSLog(@"subscribeNext");
    //    }];
    
    //    [RACObserve(self.textField, text) subscribeCompleted:^(){
    //        NSLog(@"subscribeCompleted");
    //    }];
    
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        self.textField.text = @"aaa";
    });

//    RACSignal *sig = [RACSignal combineLatest:@[
//                     self.usernameTextField.rac_textSignal,
//                     self.passwordTextField.rac_textSignal,
//                     RACObserve(LoginManager.sharedManager, loggingIn),
//                     RACObserve(self, loggedIn)
//                     ] reduce:^(NSString *username, NSString *password, NSNumber *loggingIn, NSNumber *loggedIn) {
//                         return @(username.length > 0 && password.length > 0 && !loggingIn.boolValue && !loggedIn.boolValue);
//                     }];

   //-----
    
    
    /*
     RAC(self.textField, enabled) = signal;
     
     宏展开
     [[RACSubscriptingAssignmentTrampoline alloc] initWithTarget:(self.textField) nilValue:(((void *)0))][@(((void)(__objc_no && ((void)self.textField.enabled, __objc_no)), "enabled"))] = signal;

     逗号表达式
     
     意义如下
     [RACSubscriptingAssignmentTrampoline setObject:signal forKeyedSubscript:@"enabled"];
     
     */

}

#pragma mark - Signal 特性
#pragma mark - Filter
- (void)testFilter {
    //  过滤模式
    [[RACObserve(self.textField, text) filter:^(id value) {
        NSLog(@"2 filter------ %@  %p", value, value);
        return YES;
    }] subscribeNext:^(id x){
        // filter NO 就不会进来了
        NSLog(@"3 subscribe--- %@  %p", x, x);
    }];
}

#pragma mark - combine 叠加
- (void)testCombine {
    
//    RACSignal *databaseSignal = [xx subscribeOn:[RACScheduler scheduler]];
//    RACSignal *fileSignal = [RACSignal startEagerlyWithScheduler:[RACScheduler scheduler]
//                                                           block:^(id<RACSubscriber> subscriber) {
//
//        NSMutableArray *filesInProgress = [NSMutableArray array];
//        for (NSString *path in files) {
//            [filesInProgress addObject:[NSData dataWithContentsOfFile:path]];
//        }
//
//        [subscriber sendNext:[filesInProgress copy]];
//        [subscriber sendCompleted];
//    }];

//    Signals也可以被用于导出状态。不必观察属性然后设置其他属性来响应这个属性新的值，RAC可以依照signals和操作来表达属性：
    
    RACSignal *signalA = nil;
    RACSignal *signalB = nil;
    
    [[RACSignal combineLatest:@[signalA, signalB]
                       reduce:^ id (NSArray *databaseObjects, NSArray *fileContents) {

        return nil;
    }] subscribeCompleted:^{
         NSLog(@"Done processing");
    }];
}

#pragma mark - Chaining
- (void)testChaining {
    //    [client logInWithSuccess:^{
    //        [client loadCachedMessagesWithSuccess:^(NSArray *messages) {
    //            [client fetchMessagesAfterMessage:messages.lastObject success:^(NSArray *nextMessages) {
    //                NSLog(@"Fetched all messages.");
    //            } failure:^(NSError *error) {
    //                [self presentError:error];
    //            }];
    //        } failure:^(NSError *error) {
    //            [self presentError:error];
    //        }];
    //    } failure:^(NSError *error) {
    //        [self presentError:error];
    //    }];
    
    //  chain 后：
    
    //    [[[[client logIn] // logIn return RACSignal 其有 if then...
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
    
    [RACObserve(self, name) then:nil];
    
    //    [self rac_signalForSelector:@selector(test)]  then:<#^RACSignal *(void)block#>
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
    
    [[tapGesture rac_gestureSignal] subscribeNext:^(id x) {
//        [self.viewModel.likeCommand execute:nil];
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
    
    _button.rac_command = [[RACCommand alloc] initWithEnabled:signal
                                                  signalBlock:^RACSignal *(id input){
                                                      return [RACSignal empty];
                                                  }];
    
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
        
        //  取代事件 Delegate，
//        [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside]
//          takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(id x){
//            NSLog(@"cell button passed");
//        }];
        NSLog(@"%@", indexPath);
//        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
//            NSLog(@"cell button passed");
//        }];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}
@end

