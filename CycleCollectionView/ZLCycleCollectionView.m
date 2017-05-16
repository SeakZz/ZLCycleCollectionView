//
//  ZLCycleCollectionView.m
//  CycleCollectionView
//
//  Created by long on 17/2/17.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLCycleCollectionView.h"


@interface ZLCycleCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) ZLProtrudeFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger totalPages;

@property (nonatomic, assign) NSInteger totalItems;

// 拉动前的contentoffset.x 用来判断移动方向
@property (nonatomic, assign) CGFloat offer;

@property (nonatomic, copy) void (^updatePosition)();

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation ZLCycleCollectionView {
    NSInteger _currentPage;
    BOOL _needReload;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInitialState];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupInitialState];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_needReload) {
        if (CGSizeEqualToSize(CGSizeZero, _itemSize)) {
            _itemSize = self.bounds.size;
        }
        CGFloat topMargin = (self.bounds.size.height - _itemSize.height)/2;
        self.layout.sectionInset = UIEdgeInsetsMake(topMargin, 0, topMargin, 0);
        self.layout.itemSize = _itemSize;
        self.collectionView.frame = self.bounds;
        [self reloadData];
        _needReload = NO;
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    
    if (!newWindow) {
        if (_isAutoPlay) {
            [self stopCycle];
        }
    } else {
        if (_isAutoPlay) {
            [self startCycle];
        }
    }
}


#pragma mark - method
- (void)setupInitialState {
    _waitTime = 4;
    _isAutoPlay = NO;
    _hasPage = NO;
    self.minimumLineSpacing = 0;
    _needReload = YES;
    
    [self setupCollectionView];
}
- (void)startCycle {
    [self setupTimer];
}
- (void)stopCycle {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

- (NSInteger)currentIndex {
    
    CGFloat itemWidth = _itemSize.width + _minimumLineSpacing;
    return (self.collectionView.contentOffset.x + (self.frame.size.width - _itemSize.width)/2 + itemWidth/2) / itemWidth;
}
- (NSInteger)pageControlCurrentPage {
    return _totalPages == 0 ? 0 : [self currentIndex] % _totalPages;
}
- (BOOL)isCorrectPosition {
    return (NSInteger)(self.collectionView.contentOffset.x + (self.frame.size.width - _itemSize.width)/2)%(NSInteger)(_itemSize.width + _minimumLineSpacing) == 0;
}

#pragma mark - override method
- (void)reloadData {
    [self.collectionView reloadData];
    
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInCycleView:)]) {
        _totalPages = [self.dataSource numberOfItemsInCycleView:self];
    }
    
    if (_totalPages == 0) {
        return;
    } else if (_totalPages == 1) {
        self.collectionView.scrollEnabled = NO;
        _totalItems = 1;
    }
    if (_totalPages > 1) {
        self.collectionView.scrollEnabled = YES;
        _totalItems = _totalPages * 100;
    }
    [self scrollToRow:_totalItems/2 animated:NO];
    
    if (_hasPage) {
        self.pageControl.numberOfPages = _totalPages;
    }
    if (_isAutoPlay) {
        [self setupTimer];
    }
}
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}
- (void)registerNib:(nullable UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forRow:(NSInteger)row {
    NSIndexPath *idp = [NSIndexPath indexPathForItem:row inSection:0];
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:idp];
}


#pragma mark - scrollviewdelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!_hasPage) {
        return;
    }
    
    if (_currentPage == [self pageControlCurrentPage]) {
        return;
    }
    self.pageControl.currentPage = [self pageControlCurrentPage];
    _currentPage = [self pageControlCurrentPage];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _offer = scrollView.contentOffset.x;
    
    if (_isAutoPlay) {
        [self stopCycle];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (!decelerate) {
        [self scrollToMiddleItem:scrollView];
    }
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
    [self scrollToNextItemWhenDecelerating:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    if (![self isCorrectPosition]) {
        [self stopCycle];
        
        __weak __typeof(self)weakSelf = self;
        self.updatePosition = ^{
            [weakSelf scrollToRow:[weakSelf currentIndex] animated:YES];
            if (weakSelf.isAutoPlay) {
                [weakSelf startCycle];
            }
        };
        if (_isAutoPlay) {
            [self startCycle];
        }
    } else {
        
        if (_isAutoPlay) {
            [self startCycle];
        }
    }
    
}



#pragma mark - scrollmethod
- (void)scrollToMiddleItem: (UIScrollView *)scrollView {
    
    [self scrollToRow:[self currentIndex] animated:YES];
}

- (void)scrollToNextItemWhenDecelerating:(UIScrollView *)scrollView {
    if (_offer < scrollView.contentOffset.x) {
        if (scrollView.contentOffset.x < _offer + (_itemSize.width + _minimumLineSpacing)/2) {
            [self scrollToRow:[self currentIndex] + 1 animated:YES];
        } else {
            [self scrollToRow:[self currentIndex] animated:YES];
        }
    } else {
        if (scrollView.contentOffset.x > _offer - (_itemSize.width + _minimumLineSpacing)/2) {
            [self scrollToRow:[self currentIndex] - 1 animated:YES];
        } else {
            [self scrollToRow:[self currentIndex] animated:YES];
        }
    }
}

- (void)scrollToRow:(NSInteger)row animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}
- (void)scrollToNextItem {
    
    [self scrollToRow:[self currentIndex] + 1 animated:YES];
}


#pragma mark - collectionviewdatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _totalItems;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.dataSource respondsToSelector:@selector(cycleView:cellForItemAtRow:)]) {
        
        UICollectionViewCell *cell = [self.dataSource cycleView:self cellForItemAtRow:indexPath.row % _totalPages];
        cell.clipsToBounds = YES;
        return cell;
    }
    
    return nil;
}


#pragma mark - collectionviewdelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.updatePosition) {
        self.updatePosition();
        self.updatePosition = nil;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(cycleView:didSelectItemAtRow:)]) {
        [self.delegate cycleView:self didSelectItemAtRow:indexPath.row % _totalPages];
    }
}

#pragma mark - init
- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30)];
        _pageControl.userInteractionEnabled = NO;
        [self addSubview:_pageControl];
    }
    return _pageControl;
}
- (void)setupCollectionView {
    self.layout = [[ZLProtrudeFlowLayout alloc] init];
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.layout.itemSize = self.frame.size;
    self.layout.scaling = 0;
    self.layout.minimumLineSpacing = 0;
    self.layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _judgeWidth = self.frame.size.width/2;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
    
    self.collectionView.bounces = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.collectionView];
    
}
- (void)setupTimer {
    [self stopCycle];
    if (_totalPages <= 1) {
        return;
    }
    
    dispatch_queue_t queue = dispatch_queue_create("com.timer.zl", DISPATCH_QUEUE_CONCURRENT);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_walltime(DISPATCH_TIME_NOW, _waitTime * NSEC_PER_SEC), _waitTime * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToNextItem];
            if (self.updatePosition) {
                self.updatePosition = nil;
            }
        });
    });
    dispatch_resume(self.timer);
}

- (void)setItemSize:(CGSize)itemSize {
    _itemSize = itemSize;
    
    self.layout.itemSize = itemSize;
}
- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing {
    _minimumLineSpacing = minimumLineSpacing;
    
    self.layout.minimumLineSpacing = minimumLineSpacing;
}
- (void)setScaling:(CGFloat)scaling {
    _scaling = scaling;
    
    self.layout.scaling = scaling;
}
- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}
- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}


@end



/**
 自定义布局
 */
@implementation ZLProtrudeFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        _scaling = 0;
    }
    return self;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *arr = [super layoutAttributesForElementsInRect:rect];
    NSArray *attrs = [[NSArray alloc] initWithArray:arr copyItems:YES];
    
    if (attrs.count == 1) {
        UICollectionViewLayoutAttributes *attr = attrs.firstObject;
        attr.center = CGPointMake(self.collectionView.bounds.size.width/2, self.collectionView.bounds.size.height/2);
        return attrs;
    }
    
    CGRect visiableRect = {self.collectionView.contentOffset, self.collectionView.bounds.size};
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        CGFloat distance = CGRectGetMidX(visiableRect) - attr.center.x;
        CGFloat normalizedDistance = fabs(distance/self.itemSize.width);
        CGFloat zoom = 1 - _scaling * normalizedDistance;
        attr.transform3D = CATransform3DMakeScale(1, zoom, 1.0);
        attr.zIndex = 1;
    }
    return attrs;
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return !CGRectEqualToRect(newBounds, self.collectionView.bounds);
}

@end
