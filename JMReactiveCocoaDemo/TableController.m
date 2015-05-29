//
//  TableController.m
//  JMReactiveCocoaDemo
//
//  Created by xserver on 15/5/29.
//  Copyright (c) 2015年 pitaya. All rights reserved.
//

#import "TableController.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface TableController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *table;
@end

@implementation TableController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
