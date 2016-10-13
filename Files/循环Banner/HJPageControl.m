//
//  HJPageControl.m
//  HJUIKit
//
//  Created by ChenJianjun on 14-9-22.
//  Copyright (c) 2014年 hujiang.com. All rights reserved.
//

#import "HJPageControl.h"

@interface HJPageControl ()

@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation HJPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.hidesForSinglePage = YES;
    self.pageIndicatorTintColor = [UIColor whiteColor];
    self.currentPageIndicatorTintColor = [UIColor whiteColor];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.hidesForSinglePage
        && self.numberOfPages == 1) {
        return;
    }
    
    rect = self.bounds;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    UIImage *imageNormal = self.normalImage;
    UIImage *imageSelected = self.selectedImage;
    UIImage *image = nil;
    CGSize normalSize = CGSizeMake(imageNormal.size.width / 2, imageNormal.size.height / 2);
    CGSize selectedSize = CGSizeMake(imageSelected.size.width / 2, imageSelected.size.height / 2);
    CGSize imageSize = CGSizeZero;
    CGRect imageRect = CGRectZero;
    CGFloat interval = 12.0f;
    CGFloat originX = floorf((rect.size.width - self.numberOfPages * normalSize.width - (self.numberOfPages - 1) * interval) / 2.0);
    
    for (NSInteger index = 0; index < self.numberOfPages; index++) {
        if (index == self.currentPage) {
            image = imageSelected;
            imageSize = selectedSize;
        } else {
            image = imageNormal;
            imageSize = normalSize;
        }
        imageRect = CGRectMake(originX, floorf((rect.size.height - imageSize.height) / 2.0), imageSize.width, imageSize.height);
        originX += imageSize.width + interval;
        [image drawInRect:imageRect];
    }
}

#pragma mark -

- (UIImage *)normalImage
{
    if (!_normalImage) {
        _normalImage = [self imageWithSize:CGSizeMake(8, 8) color:self.pageIndicatorTintColor];
    }
    return _normalImage;
}

- (UIImage *)selectedImage
{
    if (!_selectedImage) {
        _selectedImage = [self imageWithSize:CGSizeMake(20, 8) color:self.currentPageIndicatorTintColor];
    }
    return _selectedImage;
}

- (UIImage *)imageWithSize:(CGSize)size color:(UIColor *)color
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    view.backgroundColor = color;
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = (CGFloat)size.height / 2;
    
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    CGContextSetAllowsAntialiasing(ctx, YES);//去锯齿
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
