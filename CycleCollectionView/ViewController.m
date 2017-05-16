//
//  ViewController.m
//  CycleCollectionView
//
//  Created by long on 17/2/17.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ViewController.h"
#import "ZLCycleCollectionView.h"

@interface ViewController () <ZLCycleCollectionViewDelegate, ZLCycleCollectionViewDatasource>

@property (nonatomic, strong) NSArray *array;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.automaticallyAdjustsScrollViewInsets = NO;
    ZLCycleCollectionView *ccv = [[ZLCycleCollectionView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 240)];
    ccv.delegate = self;
    ccv.dataSource = self;
    ccv.isAutoPlay = YES;
    ccv.pageIndicatorTintColor = [UIColor redColor];
    ccv.currentPageIndicatorTintColor = [UIColor whiteColor];
    ccv.hasPage = YES;
    ccv.scaling = 0.1;
    ccv.itemSize = CGSizeMake(280, 240);
    ccv.minimumLineSpacing = 10;
    
    [self.view addSubview:ccv];
    [ccv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];

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


@end
