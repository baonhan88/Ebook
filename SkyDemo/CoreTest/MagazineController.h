//
//  MagazineController.h
//  CoreTest
//
//  Created by Jiung Heo on 12. 1. 18..
//  Copyright (c) 2012년 Skytree Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FixedViewController.h"
#import "AppDelegate.h"
#import "BookInformation.h"

@interface MagazineController : UIViewController <FixedViewControllerDelegate,FixedViewControllerDataSource> {
    FixedViewController *fv;
    AppDelegate *ad;
    int count;
    double targetPos;
    BookInformation* bookInformation;
    Setting* setting;

    BOOL isCaching;
    
    UIButton* homeButton;
    
    UIButton *prevButton;
    UIButton *playButton;
    UIButton *stopButton;
    UIButton *nextButton;
    
    BOOL isAutoPlaying;
    BOOL autoStartPlayingWhenNewPagesLoaded;
    BOOL autoMovePageWhenParallesFinished;
    BOOL isLoop;
    Parallel* currentParallel;
}

@property (nonatomic, retain) BookInformation *bookInformation;

@end
