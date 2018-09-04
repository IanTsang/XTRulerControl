//
//  ViewController.m
//  XTRulerControl
//
//  Created by ZengYuYing on 2018/8/27.
//  Copyright © 2018 ZengYuYing. All rights reserved.
//

#import "ViewController.h"
#import "XTRulerControl.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    XTRulerControl *rulerControl = [[XTRulerControl alloc] initWithFrame:CGRectMake(10, 100, 300, 80)];
    rulerControl.rulerBackgroundColor = [UIColor blackColor];
    NSLog(@"%@",@"addSubview");
    [self.view addSubview:rulerControl];

    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
