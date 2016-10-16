//
//  UIView+ShowTaskFinishedCount.m
//  hjclass
//
//  Created by nero on 15/11/5.
//  Copyright © 2015年 hujiang.com. All rights reserved.
//

#import "UIView+ShowTaskFinishedCount.h"
#import <objc/runtime.h>

static const NSString *ShowTaskFinishedCountKey = @"com.hujiang.mobile.ShowTaskFinishedCount";
static const CGFloat HJToastFadeDuration = 0.2;
static const CGFloat HJToastCornerRadius = 6.0;
static const CGFloat HJToastOpacity      =  0.8;
static const CGFloat HJToastFontSize     = 14.0;

@implementation UIView (ShowTaskFinishedCount)

- (void)showToast:(NSString *)message imageName:(NSString *)imageName duration:(NSTimeInterval)interval center:(CGPoint)position {
    UIView *toast = (UIView*)objc_getAssociatedObject(self, &ShowTaskFinishedCountKey);
    if(toast != nil){
        [self hideToast:toast];
    }
    
    toast = [self toastForMessage:message imageName:imageName];
    toast.center = position;
    toast.alpha = 0.0;
    [self addSubview:toast];
    
    [UIView animateWithDuration:HJToastFadeDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        toast.alpha = 1.0;
    } completion:^(BOOL finished) {
        objc_setAssociatedObject(self, &ShowTaskFinishedCountKey, toast, OBJC_ASSOCIATION_RETAIN);
        [self hideToast:toast delay:interval];
    }];
}


//隐藏toast
- (void)hideToast:(UIView*)toast{
    //隐藏toast，并且和self解除关联
    [self hideToast:toast delay:0.0];
}

- (void)hideToast:(UIView *)toast delay:(NSTimeInterval)delay{
    if(toast){
        [UIView animateWithDuration:HJToastFadeDuration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
            toast.alpha = 0.0;
        } completion:^(BOOL finished) {
            [toast removeFromSuperview];
            objc_setAssociatedObject(self, &ShowTaskFinishedCountKey, nil, OBJC_ASSOCIATION_RETAIN);
        }];
    }
}

- (UIView*)toastForMessage:(NSString*)message imageName:(NSString *)imageName{
    NSAssert(message, @"message can not be a nil value");
    
    if(message == nil)
        return nil;
    
    UILabel *messageLable = nil;
    UIImageView *imageView = nil;
    
    //create a contain view
    UIView *container = [[UIView alloc]init];
    container.autoresizingMask =  (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    container.layer.cornerRadius = HJToastCornerRadius;
    
    container.backgroundColor = [UIColor colorWithRed:57.0/255.0 green:57.0/255.0 blue:57.0/255.0 alpha:HJToastOpacity];
    container.frame = CGRectMake(0, 0, TRUE_SIZE_W(315), TRUE_SIZE_W(315));
    
    if (!imageView) {
        UIImage *image = [UIImage imageNamed:imageName];
        imageView = [[UIImageView alloc] initWithImage:image];//82x78
        imageView.frame = CGRectMake((container.width-image.size.width+6)*0.5, TRUE_SIZE_W(75), image.size.width, image.size.height);
        [container addSubview:imageView];
    }
    
    if(!messageLable){
        messageLable = [[UILabel alloc]init];
        messageLable.numberOfLines = 0;
        messageLable.font = [UIFont systemFontOfSize:HJToastFontSize];
        messageLable.textAlignment = NSTextAlignmentCenter;
        messageLable.lineBreakMode = NSLineBreakByWordWrapping;
        messageLable.textColor = [UIColor colorWithHexString:@"ffffff"];
        messageLable.backgroundColor = [UIColor clearColor];
        messageLable.text = message;
        messageLable.frame = CGRectMake(0, container.bottom-14-TRUE_SIZE_W(36), container.width, 14);
        [container addSubview:messageLable];
    }
    
    return container;
}

@end
