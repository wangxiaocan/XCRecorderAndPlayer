//
//  ViewController.m
//  XCRecorderAndPlayer
//
//  Created by xiao can on 2019/5/8.
//  Copyright © 2019 xiaocan. All rights reserved.
//

#import "ViewController.h"





@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (IBAction)startRecord:(UIButton *)sender{
    
}

- (IBAction)stopRecord:(UIButton *)sender{
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}


@end
