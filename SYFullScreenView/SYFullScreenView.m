//
//  SYFullScreenView.m
//  SYFullScreenViewExample
//
//  Created by shenyuanluo on 2017/8/22.
//  Copyright © 2017年 shenyuanluo. All rights reserved.
//

#import "SYFullScreenView.h"

#define SY_SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SY_SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

/** 全屏切换动画时长（单位：秒） */
#define SY_TRANSFORM_DURATION 0.35f

/** 横屏旋转切换状态 枚举*/
typedef NS_ENUM(NSUInteger, SYTransformState) {
    SYTransformSmall                = 0,        // 竖屏（小屏）状态
    SYTransformAnimating            = 1,        // 正在切换状态
    SYTransformFullscreen           = 2,        // 横屏（全屏）状态
};


@interface SYFullScreenView ()

/** 保存屏幕宽度 */
@property (nonatomic, assign) CGFloat screenWidth;

/** 保存屏幕高度 */
@property (nonatomic, assign) CGFloat screenHeight;

/** 是否以获取 superview */
@property (nonatomic, assign) BOOL isGetSuperview;

/** 上一次屏幕方向 */
@property (nonatomic, assign) UIDeviceOrientation lastOrientation;

/** 竖屏时的 parentView */
@property (nonatomic, weak) UIView *parentView;

/** 竖屏时的 frame */
@property (nonatomic, assign) CGRect portraitFrame;

/** 横屏旋转切换状态 */
@property (nonatomic, assign) SYTransformState transformState;

@end


@implementation SYFullScreenView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initParam];
        [self addDevOrientationNotify];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self initParam];
        [self addDevOrientationNotify];
    }
    return self;
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}


- (void)layoutSubviews
{
    if (NO == self.isGetSuperview)
    {
        self.lastOrientation = [[UIDevice currentDevice] orientation];
        self.portraitFrame   = self.frame;
        self.parentView      = self.superview;
        self.isGetSuperview  = YES;
    }
}


#pragma mark -- 初始化参数
- (void)initParam
{
    self.isGetSuperview  = NO;
    self.transformState  = SYTransformSmall;
    self.screenWidth     = SY_SCREEN_WIDTH;
    self.screenHeight    = SY_SCREEN_HEIGHT;
    if (self.screenWidth > self.screenHeight)
    {
        self.screenWidth  = SY_SCREEN_HEIGHT;
        self.screenHeight = SY_SCREEN_WIDTH;
    }
}


#pragma mark 获取 view 所在的 ViewController
- (UIViewController *)getControllerOfView:(UIView *) subView
{
    for (UIView *nextSuperview = [subView superview];
         nextSuperview;
         nextSuperview = nextSuperview.superview)
    {
        UIResponder *nextResponder = [nextSuperview nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}


#pragma mark -- 添加屏幕旋转通知
- (void)addDevOrientationNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(devOrientDidChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}


#pragma mark -- 屏幕方向监控
- (void)devOrientDidChange
{
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    
    switch (currentOrientation)
    {
        case UIDeviceOrientationUnknown:        // 未知方向
        {
            
        }
            break;
            
        case UIDeviceOrientationPortrait:       // 竖屏
        {
            [self exitFullscreen];
        }
            break;
            
        case UIDeviceOrientationLandscapeLeft:  // 横屏向左
        {
            if (UIDeviceOrientationLandscapeRight == self.lastOrientation)  // 180 旋转
            {
                [self rotateSemicircleToOrientation:UIDeviceOrientationLandscapeLeft
                                      transforAngle:M_PI_2];
            }
            else
            {
                CGRect bounds = CGRectMake(0,
                                           0,
                                           _screenHeight,
                                           _screenWidth);
                CGPoint center = CGPointMake(CGRectGetMidX([self getControllerOfView:self].view.bounds),
                                             CGRectGetMidY([self getControllerOfView:self].view.bounds));
                
                [self enterFullscreenOnOrientation:UIDeviceOrientationLandscapeLeft
                                        viewBounds:bounds
                                        viewCenter:center
                                     transforAngle:M_PI_2];
            }
        }
            break;
            
        case UIDeviceOrientationLandscapeRight: // 横屏向右
        {
            if (UIDeviceOrientationLandscapeLeft == _lastOrientation) // 180 旋转
            {
                [self rotateSemicircleToOrientation:UIDeviceOrientationLandscapeRight
                                      transforAngle:-M_PI_2];
            }
            else
            {
                CGRect bounds = CGRectMake(0,
                                           0,
                                           _screenHeight,
                                           _screenWidth);
                CGPoint center = CGPointMake(CGRectGetMidX([self getControllerOfView:self].view.bounds),
                                             CGRectGetMidY([self getControllerOfView:self].view.bounds));
                
                [self enterFullscreenOnOrientation:UIDeviceOrientationLandscapeRight
                                        viewBounds:bounds
                                        viewCenter:center
                                     transforAngle:-M_PI_2];
            }
            
        }
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
        {
            
        }
            break;
            
        case UIDeviceOrientationFaceUp:
        {
            
        }
            break;
            
        case UIDeviceOrientationFaceDown:
        {
            
        }
            break;
            
        default:
        {
            
        }
            break;
    }
}


#pragma mark -- 全屏旋转
- (void)rotateSemicircleToOrientation:(UIDeviceOrientation)devOrientation
                        transforAngle:(CGFloat)angle
{
    if (UIDeviceOrientationPortrait == self.lastOrientation
        || UIDeviceOrientationPortraitUpsideDown == self.lastOrientation
        || UIDeviceOrientationFaceUp == self.lastOrientation
        || UIDeviceOrientationFaceDown == self.lastOrientation
        || UIDeviceOrientationPortrait == devOrientation
        || UIDeviceOrientationPortraitUpsideDown == devOrientation
        || UIDeviceOrientationFaceUp == devOrientation
        || UIDeviceOrientationFaceDown == devOrientation)
    {
        self.lastOrientation = devOrientation;
        NSLog(@"当前 iOS 设备不是横屏方向，不全屏旋转！");
        return;
    }
    if (SYTransformFullscreen != self.transformState)
    {
        NSLog(@"View 不是大屏模式！");
        return;
    }
    self.transformState = SYTransformAnimating;
    
    [UIView animateWithDuration:SY_TRANSFORM_DURATION
                     animations:^{
                         
                         self.transform = CGAffineTransformMakeRotation(angle);
                         
                         [self refreshStatusBarToOrientation:(UIInterfaceOrientation)devOrientation];
                     }
                     completion:^(BOOL finished) {
                         
                         self.transformState = SYTransformFullscreen;
                         _lastOrientation = devOrientation;
                     }];
}


#pragma mark -- 进入全屏(由竖屏——>横屏时调用)
- (void)enterFullscreenOnOrientation:(UIDeviceOrientation)devOrientation
                          viewBounds:(CGRect)bounds
                          viewCenter:(CGPoint)center
                       transforAngle:(CGFloat)angle

{
    if (UIDeviceOrientationLandscapeLeft == self.lastOrientation
        || UIDeviceOrientationLandscapeRight == self.lastOrientation
        || UIDeviceOrientationPortrait == devOrientation
        || UIDeviceOrientationPortraitUpsideDown == devOrientation
        || UIDeviceOrientationFaceUp == devOrientation
        || UIDeviceOrientationFaceDown == devOrientation)
    {
        self.lastOrientation = devOrientation;
        NSLog(@"当前 iOS 设备不是横屏方向，不进入全屏模式！");
        return;
    }
    if (SYTransformSmall != self.transformState)
    {
        return;
    }
    self.transformState = SYTransformAnimating;
    
    [self removeFromSuperview];
    CGRect portraitRectInWindow = [self.parentView convertRect:self.portraitFrame
                                                        toView:[UIApplication sharedApplication].keyWindow];
    self.frame = portraitRectInWindow;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    // 执行动画
    [UIView animateWithDuration:SY_TRANSFORM_DURATION
                     animations:^{
                         
                         self.transform = CGAffineTransformMakeRotation(angle);
                         self.bounds = bounds;
                         self.center = center;
                         [self refreshStatusBarToOrientation:(UIInterfaceOrientation)devOrientation];
                     }
                     completion:^(BOOL finished) {
                         
                         self.transformState = SYTransformFullscreen;
                         self.lastOrientation = devOrientation;
                     }];
}


#pragma mark -- 退出全屏
- (void)exitFullscreen
{
    if (SYTransformFullscreen != self.transformState)
    {
        return;
    }
    self.transformState = SYTransformAnimating;
    
    CGRect viewFrame = [self.parentView convertRect:self.portraitFrame
                                             toView:[UIApplication sharedApplication].keyWindow];
    [UIView animateWithDuration:SY_TRANSFORM_DURATION
                     animations:^{
                         
                         self.transform = CGAffineTransformIdentity;
                         self.frame = viewFrame;
                         
                         // 回到竖屏位置
                         [self removeFromSuperview];
                         self.frame = self.portraitFrame;
                         [self.parentView addSubview:self];
                         
                         [self refreshStatusBarToOrientation:UIInterfaceOrientationPortrait];
                     }
                     completion:^(BOOL finished) {
                         
                         self.transformState = SYTransformSmall;
                         self.lastOrientation = UIDeviceOrientationPortrait;
                     }];
}


#pragma mark -- 设置状态栏 位置
- (void)refreshStatusBarToOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation
                                                      animated:YES];
}

@end
