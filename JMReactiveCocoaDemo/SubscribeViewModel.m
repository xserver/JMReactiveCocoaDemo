//
//  Created by Ole Gammelgaard Poulsen on 05/12/13.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SubscribeViewModel.h"
#import "AFHTTPRequestOperationManager+RACSupport.h"
#import "NSString+EmailAdditions.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

static NSString *const kSubscribeURL = @"http://reactivetest.apiary.io/subscribers";

@interface SubscribeViewModel ()
@property(nonatomic, strong) RACSignal *emailValidSignal;
@end

@implementation SubscribeViewModel

- (id)init {
	self = [super init];
	if (self) {
		[self mapSubscribeCommandStateToStatusMessage];
	}
	return self;
}

- (void)mapSubscribeCommandStateToStatusMessage {
    
    //  初值
	RACSignal *startedMessageSource = [self.subscribeCommand.executionSignals map:^id(RACSignal *subscribeSignal) {
		return NSLocalizedString(@"Sending request...", nil);
	}];

    //  成功
	RACSignal *completedMessageSource = [self.subscribeCommand.executionSignals flattenMap:^RACStream *(RACSignal *subscribeSignal) {
		return [[[subscribeSignal materialize] filter:^BOOL(RACEvent *event) {
			return event.eventType == RACEventTypeCompleted;
		}] map:^id(id value) {
			return NSLocalizedString(@"Thanks", nil);
		}];
	}];

    //  失败
	RACSignal *failedMessageSource = [[self.subscribeCommand.errors subscribeOn:[RACScheduler mainThreadScheduler]] map:^id(NSError *error) {
		return NSLocalizedString(@"Error :(", nil);
	}];

    //  将这几种 signal merge 合成绑定给 statusMessage
	RAC(self, statusMessage) = [RACSignal merge:@[startedMessageSource, completedMessageSource, failedMessageSource]];
}

- (RACCommand *)subscribeCommand {
    
	if (!_subscribeCommand) {
		@weakify(self);
        //  command 绑定了 email signal 和 command excute block
        //  email signal 的作用是？ 控制了 command.enabled
        //  Command 和 button 一对，因为有这些 signal 组合：executionSignals, executing, enabled, errors
		_subscribeCommand = [[RACCommand alloc] initWithEnabled:self.emailValidSignal signalBlock:^RACSignal *(id input) {
			@strongify(self);
            
			return [SubscribeViewModel postEmail:self.email];
		}];
	}
	return _subscribeCommand;
}

+ (RACSignal *)postEmail:(NSString *)email {
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.requestSerializer = [AFJSONRequestSerializer new];
	NSDictionary *body = @{@"email": email ?: @""};
	return [[[manager rac_POST:kSubscribeURL parameters:body] logError] replayLazily];
}

- (RACSignal *)emailValidSignal {
	if (!_emailValidSignal) {
		_emailValidSignal = [RACObserve(self, email) map:^id(NSString *email) {
			return @([email isValidEmail]);
            return @YES;
		}];
	}
	return _emailValidSignal;
}

@end