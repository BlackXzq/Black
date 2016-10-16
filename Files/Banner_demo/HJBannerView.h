//
//  HJImagePlayerView.h
//  ImagePlayerViewDemo
//
//  Created by Donne on 12/22/14.
//  Copyright (c) 2014 Chenyanjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJBannerView : UIView

@property (nonatomic, assign) NSUInteger scrollInterval; // default is 2 seconds
@property (nonatomic, assign) BOOL hidePageControl; // default is NO
@property (nonatomic, copy) NSArray *imageURLs; // array of images url
@property (copy) void (^didLoadAllItemsBlock)(HJBannerView *bannerView);
@property (copy) void (^didTapItemBlock)(NSInteger index);

/**
 *  开启轮播计时器
 */
- (void)startTimer;

/**
 *  关闭轮播计时器
 */
- (void)stopTimer;

/**
 *  开始加载
 */
- (void)reloadData;

@end