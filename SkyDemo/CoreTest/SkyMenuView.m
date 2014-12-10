//
//  SkyMenuView.m
//  SkyDemo
//
//  Created by SkyTree on 13. 7. 21..
//  Copyright (c) 2013년 Skytree Corporation. All rights reserved.
//

//  !!!!! IMPORTANT !!!!!
//  The Advanced Demo sources are not the part of SkyEpub SDK.
//  These sources are written only to show how to use SkyEpub SDK.
//  The bugs found in this demo do not mean that SkyEpub SDK has the related bugs
//  Developers should change and modify this Advanced Demo sources and graphics files for their purposes.
//  Any request to add/change/modify the Advanced Demo sources will be refused.


#import "SkyMenuView.h"

@implementation SkyMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void)makeUI {
    UIImageView* leftSideView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"LeftSide.png"]];
    UIImageView* rightSideView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"LeftSide.png"]];
    UIImageView* bodyView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Body.png"]];
    
    [self addSubview:leftSideView];
    [self addSubview:bodyView];
    [self addSubview:rightSideView];                             
}

@end
