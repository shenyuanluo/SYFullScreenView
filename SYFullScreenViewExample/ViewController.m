//
//  ViewController.m
//  SYFullScreenViewExample
//
//  Created by shenyuanluo on 2017/8/22.
//  Copyright © 2017年 http://blog.shenyuanluo.com/ All rights reserved.
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
    
    CGFloat scrHeight   = [[UIScreen mainScreen] bounds].size.height;
    CGFloat playViewW   = [[UIScreen mainScreen] bounds].size.width;
    CGFloat radio       = (CGFloat)(4.0f / 3.0f);
    CGFloat playViewH   = playViewW / radio;
    CGFloat orignY      = 812 == scrHeight ? 84 : 64;
    CGRect playViewRect = CGRectMake(0, orignY, playViewW, playViewH);
    self.playView = [[SYFullScreenView alloc] initWithFrame:playViewRect];
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
