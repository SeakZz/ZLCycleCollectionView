//
//  SViewController.m
//  CycleCollectionView
//
//  Created by long on 2017/5/16.
//  Copyright © 2017年 long. All rights reserved.
//

#import "SViewController.h"
#import "ZLCycleCollectionView.h"

@interface SViewController () <ZLCycleCollectionViewDelegate, ZLCycleCollectionViewDatasource>

@property (weak, nonatomic) IBOutlet ZLCycleCollectionView *cv;
@property (nonatomic, strong) NSArray *array;

@end

@implementation SViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _cv.delegate = self;
    _cv.dataSource = self;
    _cv.isAutoPlay = YES;
    _cv.pageIndicatorTintColor = [UIColor redColor];
    _cv.currentPageIndicatorTintColor = [UIColor whiteColor];
    _cv.hasPage = YES;
    _cv.scaling = 0.1;
    _cv.itemSize = CGSizeMake(280, 240);
    _cv.minimumLineSpacing = 10;
    
    [_cv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.array = @[@"detail_0.jpg", @"detail_1.jpg", @"detail_2.jpg", @"detail_3.jpg"];
}


- (NSInteger)numberOfItemsInCycleView:(ZLCycleCollectionView *)cycleView {
    return self.array.count;
}
- (__kindof UICollectionViewCell *)cycleView:(ZLCycleCollectionView *)cycleView cellForItemAtRow:(NSInteger)row {
    UICollectionViewCell *cell = [cycleView dequeueReusableCellWithReuseIdentifier:@"cell" forRow:row];
    
    for (UIView *v in cell.contentView.subviews) {
        [v removeFromSuperview];
    }
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.bounds.size.width, 240)];
    iv.image = [UIImage imageNamed:self.array[row]];
    
    [cell.contentView addSubview:iv];
    
    return cell;
    
}
- (void)cycleView:(ZLCycleCollectionView *)cycleView didSelectItemAtRow:(NSInteger)row {
    
    NSLog(@"%ld", (long)row);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
