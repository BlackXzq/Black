//
//  HJImagePlayerView.m
//  ImagePlayerViewDemo
//
//  Created by Donne on 12/22/14.
//  Copyright (c) 2014 Chenyanjun. All rights reserved.
//

#import "HJBannerView.h"
#import "HJPageControl.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access

static NSString * const kHJImagePlayerViewCell = @"HJImagePlayerViewCell";
#define kDefaultScrollInterval  5

NSString *md5(NSString *str);

#pragma mark - HJBannerViewCell Part

@interface HJBannerViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) HJBannerView *collectionView;
@end

@interface HJBannerViewCell ()
@property (nonatomic, strong) NSArray *imageConstraints;
@end

@implementation HJBannerViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.clipsToBounds = YES;
        [self addSubview:_imageView];
    }
    return self;
}


@end

#pragma mark - HJBannerView Part

@interface HJBannerView ()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer *autoScrollTimer;
@property (nonatomic, strong) HJPageControl *pageControl;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadStatusMap;

@property (atomic, strong) NSMutableDictionary *reconnectLog;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation HJBannerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _init];
    }
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _init];
    }
    return nil;
}

- (void)_init
{

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0.f;
    flowLayout.minimumLineSpacing = 0.f;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.itemSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:flowLayout];
    
    [self addSubview:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.directionalLockEnabled = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.scrollsToTop = NO;
    [self.collectionView registerClass:[HJBannerViewCell class] forCellWithReuseIdentifier:kHJImagePlayerViewCell];
    
    [self addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0],
                           [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0],
                           [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0],
                           [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeHeight multiplier:1.f constant:0],
                           ]];
    
    self.pageControl = [[HJPageControl alloc] init];
    self.pageControl.userInteractionEnabled = YES;
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.pageControl.numberOfPages = self.count;
    self.pageControl.currentPage = 0;
    self.pageControl.userInteractionEnabled = NO;
    [self addSubview:self.pageControl];
    
    [self addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.pageControl attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0],
                           [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.pageControl attribute:NSLayoutAttributeBottom multiplier:1.f constant:0],
                           [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.pageControl attribute:NSLayoutAttributeWidth multiplier:1.f constant:0],
                           [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:12],
                           ]];
}

- (void)reloadData
{
    if (!self.imageURLs || !self.imageURLs.count || self.frame.size.width == 0.f || self.frame.size.height == 0.f) {
        return;
    }
    
    ((UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout).itemSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    self.count = self.imageURLs.count;
    self.reconnectLog = [[NSMutableDictionary alloc] init];
    
    self.imageDownloadStatusMap = [[NSMutableDictionary alloc] initWithCapacity:self.count];
    self.pageControl.numberOfPages = self.count;
    [self reloadDataCollectionView];
}


- (void)reloadDataCollectionView {
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    self.pageControl.currentPage = 0;
    
    self.collectionView.scrollEnabled = self.count > 1;
    
    if (self.didLoadAllItemsBlock) {
        self.didLoadAllItemsBlock(self);
    }
}

- (void)setScrollInterval:(NSUInteger)scrollInterval
{
    _scrollInterval = scrollInterval;
    [self startTimer];
}

- (void)handleScrollTimer:(NSTimer *)timer
{
    if (self.count == 0 || self.count == 1 ) {
        return;
    }
    NSInteger currentPage = self.collectionView.contentOffset.x/CGRectGetWidth(UIScreenBounds);
    if (currentPage >= self.count + 1) currentPage = 1;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentPage + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

#pragma mark - settings
- (void)setHidePageControl:(BOOL)hidePageControl
{
    self.pageControl.hidden = hidePageControl;
}

- (void)stopTimer
{
    if (self.autoScrollTimer && self.autoScrollTimer.isValid) {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
    }
}

- (void)startTimer
{
    [self stopTimer];
    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval target:self selector:@selector(handleScrollTimer:) userInfo:nil repeats:YES];
}

#pragma mark - scroll delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.autoScrollTimer && self.autoScrollTimer.isValid) {
        [self.autoScrollTimer invalidate];
    }
    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval target:self selector:@selector(handleScrollTimer:) userInfo:nil repeats:YES];
    [self handleScroll];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self handleScroll];
}

- (void)handleScroll
{
    NSInteger actualIndex = self.collectionView.contentOffset.x/CGRectGetWidth(UIScreenBounds);
    if (actualIndex == 0) {
        self.pageControl.currentPage = self.count - 1;
    } else if (actualIndex == self.count + 1) {
        self.pageControl.currentPage = 0;
    } else {
        self.pageControl.currentPage = actualIndex - 1;
    }
    if (actualIndex == 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.count inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    } else if (actualIndex == self.count + 1) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}


#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.imageURLs.count == 0) {
        return 0;
    }
    return self.imageURLs.count + 2;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self convertIndex:indexPath.row];
    HJBannerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHJImagePlayerViewCell forIndexPath:indexPath];
    cell.collectionView = self;
    NSURL *ImageUrl = [NSURL URLWithString:[self.imageURLs[index] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [cell.imageView sd_setImageWithURL:ImageUrl placeholderImage:[UIImage imageNamed:@"hj_classcenter_banner_default"]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didTapItemBlock) {
        NSInteger index = [self convertIndex:indexPath.row];
        self.didTapItemBlock(index);
    }
}

- (NSInteger)convertIndex:(NSInteger)index {
    if (index == 0) {
        return self.count - 1;
    } else if (index == self.count + 1) {
        return 0;
    }
    return index - 1;
}

@end

