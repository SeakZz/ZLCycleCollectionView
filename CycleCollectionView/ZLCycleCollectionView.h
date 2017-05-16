//
//  ZLCycleCollectionView.h
//  CycleCollectionView
//
//  Created by long on 17/2/17.
//  Copyright © 2017年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZLCycleCollectionView;

@protocol ZLCycleCollectionViewDelegate <NSObject>

@optional
- (void)cycleView:(ZLCycleCollectionView *)cycleView didSelectItemAtRow:(NSInteger)row;

@end

@protocol ZLCycleCollectionViewDatasource <NSObject>

@required
- (NSInteger)numberOfItemsInCycleView:(ZLCycleCollectionView *)cycleView;
- (__kindof UICollectionViewCell *)cycleView:(ZLCycleCollectionView *)cycleView cellForItemAtRow:(NSInteger)row;


@end

@interface ZLCycleCollectionView : UIView


@property (nonatomic, weak) id <ZLCycleCollectionViewDelegate> delegate;
@property (nonatomic, weak) id <ZLCycleCollectionViewDatasource> dataSource;

/**
 每个cell大小  default  self.frame.size
 */
@property (nonatomic, assign) CGSize itemSize;
/**
 cell间距  default 0
 */
@property (nonatomic, assign) CGFloat minimumLineSpacing;
/**
 缩放比例 default 0
 */
@property (nonatomic, assign) CGFloat scaling;
/**
 自动播放 default NO
 */
@property (nonatomic, assign) BOOL isAutoPlay;
/**
 播放间隔时间 default 4
 */
@property (nonatomic, assign) NSInteger waitTime;
/**
 显示pageControl default NO
 */
@property (nonatomic, assign) BOOL hasPage;
/**
 pageControl颜色
 */
@property (nonatomic, assign) UIColor *pageIndicatorTintColor;
/**
 pageControl被选中的颜色
 */
@property (nonatomic, assign) UIColor *currentPageIndicatorTintColor;
/** 
 滑动换页距离 default itemsize.width/2 
 */
@property (nonatomic, assign) CGFloat judgeWidth;

- (void)reloadData;

- (void)startCycle;
- (void)stopCycle;

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forRow:(NSInteger)row;

@end



/**
 自定义布局
 */
@interface ZLProtrudeFlowLayout : UICollectionViewFlowLayout

/** 缩放比例 */    //default 0
@property (nonatomic, assign) CGFloat scaling;

@end
