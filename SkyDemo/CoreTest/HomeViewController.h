//
//  HomeViewController.h
//  SkyDemo
//
//  Created by 하늘나무 on 2014. 1. 2..
//  Copyright (c) 2014년 Skytree Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@interface HomeViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    UIView *topView;
    UIView *mainView;
    AppDelegate* ad;
    UICollectionView* collectionView;
}

@end
