//
//  UIView+ShowTaskFinishedCount.h
//  hjclass
//
//  Created by nero on 15/11/5.
//  Copyright © 2015年 hujiang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ShowTaskFinishedCount)

/**
 *  在定点展示message一段时间
 *
 *  @param message  要展示的文本
 *  @param imageName 图片名称
 *  @param interval 要展示的时长
 *  @param position 展示坐标
 */

- (void)showToast:(NSString *)message imageName:(NSString *)imageName duration:(NSTimeInterval)interval center:(CGPoint)position;

@end
