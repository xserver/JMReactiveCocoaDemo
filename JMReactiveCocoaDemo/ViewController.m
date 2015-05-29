//
//  ViewController.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/3/24.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "LoginController.h"
#import "CommandCtrl.h"
#import "ExampleCtrl.h"
#import "DelegateController.h"
#import "StreamController.h"
#import "Blah.h"
#import "Apple.h"

@interface ViewController ()
@property (nonatomic, weak  ) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton    *button;
@property (nonatomic, weak  ) IBOutlet UILabel     *label;
@property (nonatomic, weak  ) IBOutlet UIButton    *loginButton;


@property (nonatomic, copy  ) NSString *name;
@property (nonatomic, strong) NSArray  *array;
@property (nonatomic, strong) Apple    *apple;

@property (nonatomic, strong) NSMutableString *releaseObj;
@property (nonatomic, strong) RACDisposable *disposable;

@end

@implementation ViewController
{
    Blah *blah;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    
//    [self testMutableArrayChange];
    
//    [self signalColdToHot];
//    [self packEvent];
    
//    [self testSequence];
//    [self bindingData];
    

//    [self testGestureRecognizer];
//    [self objectSignalCategory];

//    [self testButton];
    
//    [_name rac_deallocDisposable]

//    _loginButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id button) {
//        id ctrl = [[LoginController alloc] init];
//        [self presentViewController:ctrl animated:NO completion:nil];
//        return [RACSignal empty];
//    }];
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

#pragma mark - RACSubject
- (void)testSubject {
    RACSubject *subject = [RACSubject subject];
    [subject sendNext:@"xxx"];
//    array.rac_sequence

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

#pragma mark - RACScheduler
//  schedul 对线程的封装
- (void)testScheduler {
    
    RAC(self, label.text) = [[[RACSignal interval:1 onScheduler:[RACScheduler currentScheduler]] startWith:[NSDate date]] map:^id (NSDate *value) {
        NSLog(@"value:%@", value);
        
        NSCalendarUnit cu = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:cu fromDate:value];
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)dateComponents.hour, (long)dateComponents.minute, (long)dateComponents.second];
    }];

//    [RACSignal deliverOn] 切换线程
    
    @weakify(self);
    [[RACScheduler scheduler] schedule:^{
        sleep(1);
        //pretend we are uploading to a server on a backround thread...
        //dont ever put sleep in your code
        //upload player & points...
        
        [[RACScheduler mainThreadScheduler] schedule:^{
            //this creates a reference to weak self ( @weakify(self); )
            //makes sure self isn't retained
            //TODO: shouldn't reference a UI element in the view model. probably need an upload signal signal
            @strongify(self);
            NSString *msg = @"testScheduler";
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Successfull" message:msg delegate:nil
                                                  cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
        }];
    }];

}
#pragma mark - NSArray 等集合
- (void)testCollection {

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

#pragma mark - Binding
- (void)bindingData {
    
    RAC(self.textField, text) = [RACObserve(self, name) distinctUntilChanged];
    
    [[self.textField.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *x) {
        //this creates a reference to self that when used with @weakify(self);
        //makes sure self isn't retained
        NSLog(@"xxxx %@", x);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //  Model 改变后，反映到 View
        self.name = @"bindingData 111";
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.name = @"bindingData 222";
    });
}

- (IBAction)openExampleController:(id)sender {
    
    id ctrl = [[ExampleCtrl alloc] init];
    [self presentViewController:ctrl animated:NO completion:nil];
}

- (IBAction)openCommandExample:(id)sender {
    [self presentViewController:CommandCtrl.new animated:NO completion:nil];
}

- (IBAction)openDelegateExample:(id)sender {
    [self presentViewController:[[DelegateController alloc] init] animated:NO completion:nil];
}

- (IBAction)openStreamController:(id)sender {
    [self presentViewController:[[StreamController alloc] init] animated:NO completion:nil];
}

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
@end

