//
//  ViewController.m
//  AliPayCredit
//
//  Created by 施澍 on 16/10/21.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import "ViewController.h"
#import "DashBoardView.h"
#import <POP.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    DashBoardView *db = [[DashBoardView alloc]initWithFrame:self.view.bounds];
    db.backgroundColor = [UIColor whiteColor];
    db.currentExp = 10000;
    [self.view addSubview:db];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
