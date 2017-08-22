//
//  ViewController.m
//  SYFullScreenViewExample
//
//  Created by shenyuanluo on 2017/8/22.
//  Copyright © 2017年 shenyuanluo. All rights reserved.
//

#import "ViewController.h"
#import "SYFullScreenView.h"

@interface ViewController ()

@property (nonatomic, strong) SYFullScreenView *playView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playView = [[SYFullScreenView alloc] initWithFrame:CGRectMake(0, 64, 320, 240)];
    self.playView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.playView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
