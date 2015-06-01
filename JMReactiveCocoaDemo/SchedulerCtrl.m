//
//  SchedulerCtrl.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/6/1.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "SchedulerCtrl.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface SchedulerCtrl ()
@property (nonatomic, weak  ) IBOutlet UILabel     *label;
@end

@implementation SchedulerCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
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
    
}@end
