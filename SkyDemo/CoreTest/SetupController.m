//
//  SetupController.m
//  SkyDemo
//
//  Created by 하늘나무 on 2013. 12. 26..
//  Copyright (c) 2013년 Skytree Corporation. All rights reserved.
//

#import "SetupController.h"

#define TH 100

#ifdef __IPHONE_6_0
# define ALIGN_CENTER NSTextAlignmentCenter
#else
# define ALIGN_CENTER UITextAlignmentCenter
#endif



@interface SetupController ()

@end

@implementation SetupController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    ad =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
    ad.setting = [ad fetchSetting];
    [super viewDidLoad];
    [self makeXIB];
	// Do any additional setup after loading the view.
}

-(BOOL)isAbove7 {
    @autoreleasepool {
        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"7.0";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
            return YES;
        }else {
            return NO;
        }
    }
}

-(void)makeNavigationBar {
    if (![self isAbove7]) {
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0)];
        UINavigationItem *titleItem = [[UINavigationItem alloc] initWithTitle:@"Setup"];
        NSDictionary *titleAttributesDictionary =  [NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIColor blackColor],
                                                    UITextAttributeTextColor,
                                                    [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0],
                                                    UITextAttributeTextShadowColor,
                                                    [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                    UITextAttributeTextShadowOffset,
                                                    [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0],
                                                    UITextAttributeFont,
                                                    nil];
        navigationBar.titleTextAttributes = titleAttributesDictionary;
        navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.view addSubview:navigationBar];
        
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Home"
                                                                       style:UIBarButtonItemStyleDone target:nil action:@selector(homePressed:)];
        
        if ([self isAbove7]) {
            leftButton.tintColor = [UIColor blueColor];
        }else {
            navigationBar.tintColor=[UIColor lightGrayColor];
        }
        titleItem.leftBarButtonItem = leftButton;
        [navigationBar pushNavigationItem:titleItem animated:NO];
    }else {
        UIView* topView = [[UIView alloc]init];
        topView.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        topView.frame = CGRectMake(0,0,self.view.bounds.size.width,38);
        topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIImageView* topImageView = [[UIImageView alloc]init];
        topImageView.image = [UIImage imageNamed:@"topblue.png"];
        topImageView.frame = topView.bounds;
        topImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        topImageView.contentMode = UIViewContentModeScaleToFill;
        [topView addSubview:topImageView];

        UIButton* homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonImage = [UIImage imageNamed:@"homewhite.png"];
        [homeButton setImage:buttonImage forState:UIControlStateNormal];
        [homeButton setImage:buttonImage forState:UIControlStateHighlighted];
        [homeButton addTarget:self action:@selector(homePressed:) forControlEvents:UIControlEventTouchUpInside];
        [homeButton setContentMode:UIViewContentModeCenter];
        homeButton.frame = CGRectMake(15,0,42,42);
        homeButton.showsTouchWhenHighlighted = YES;
        [topView addSubview:homeButton];

        //(self.view.frame.size.width-100)/2
        UILabel* titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-100)/2,2,100,38)];
        titleLabel.text =@"Setup";
        [titleLabel setNumberOfLines:1];
        [titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:19]];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = ALIGN_CENTER;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [topView addSubview:titleLabel];
        
        [self.view addSubview:topView];
    }
}

-(UIImage*)imageNamed:(NSString*) name color:(UIColor*)color {
    UIImage *image = [UIImage imageNamed:name];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage scale:1.0 orientation: UIImageOrientationDownMirrored];
    return flippedImage;
}

-(void)makeTableView {
    UIView *mainView = [[UIView alloc]init];
    mainView.frame = CGRectMake(0,44,self.view.frame.size.width, self.view.frame.size.height-44);
    mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainView];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.frame = mainView.bounds;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [mainView addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
}

-(void)makeXIB {
    self.view.backgroundColor = [UIColor whiteColor];
    [self hideStatusBar];
    [self makeNavigationBar];
    [self makeTableView];
}

-(void)homePressed:(id)sender {
    [ad updateSetting:ad.setting];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// for iOS7 only
-(BOOL)prefersStatusBarHidden {
    return YES;
}

// for iOS7
-(void)hideStatusBar {
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0:return 1;
			break;
		case 1:return 3;
			break;
		case 2:return 1;
			break;
		case 3:return 3;
			break;
		case 4:return 2;
			break;
		default:
			return 1;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Network";
            break;
        case 1:
            sectionName = @"Layout";
            break;
        case 2:
            sectionName = @"Theme";
            break;
        case 3:
            sectionName = @"Page Transition Effect";
            break;
        case 4:
            sectionName = @"Information";
            break;
    }
    return sectionName;
}

-(void)allow3GDownloadSwitchChanged:(id)sender {
	UISwitch *us = (UISwitch*)sender;
    ad.setting.allow3G = us.on;
}

-(void)doublePagedSwitchChanged:(id)sender {
	UISwitch *us = (UISwitch*)sender;
    ad.setting.doublePaged = us.on;
}

-(void)lockRotationSwitchChanged:(id)sender {
	UISwitch *us = (UISwitch*)sender;
    ad.setting.lockRotation = us.on;
}

-(void)gloabalPaginationSwitchChanged:(id)sender {
	UISwitch *us = (UISwitch*)sender;
    ad.setting.globalPagination = us.on;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
    
    if (section==2 && row==0) {
        return TH;
    }else {
        return 44;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	NSString *ci = [NSString stringWithFormat:@"cell-%d-%d",row,section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ci];
	if (cell==nil) {
		cell = [[UITableViewCell alloc]initWithFrame:CGRectZero reuseIdentifier:ci];
	}else {
        return cell;
    }
    
    CGRect switchRect;
    if ([self isAbove7])    switchRect = CGRectMake(cell.frame.size.width-60,10,60,25);
    else                    switchRect = CGRectMake(cell.frame.size.width-90,10,60,25);
	
	if (section==0 && row==0) {
		cell.textLabel.text = NSLocalizedString(@"3G/4G Download",nil);
		UISwitch *allow3GDownloadSwitch = [[UISwitch alloc]init];
		allow3GDownloadSwitch.frame = switchRect;
        allow3GDownloadSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
		[allow3GDownloadSwitch addTarget:self action:@selector(allow3GDownloadSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        allow3GDownloadSwitch.on = ad.setting.allow3G;
		[cell addSubview:allow3GDownloadSwitch];
	}
    
    if (section==1 && row==0) {
		cell.textLabel.text = NSLocalizedString(@"Double Paged For Landscape",nil);
		UISwitch *doublePagedSwitch = [[UISwitch alloc]init];
		doublePagedSwitch.frame = switchRect;
        doublePagedSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
		[doublePagedSwitch addTarget:self action:@selector(doublePagedSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        doublePagedSwitch.on = ad.setting.doublePaged;
		[cell addSubview:doublePagedSwitch];
	}

    if (section==1 && row==1) {
		cell.textLabel.text = NSLocalizedString(@"Lock Rotation",nil);
		UISwitch *lockRotationSwitch = [[UISwitch alloc]init];
		lockRotationSwitch.frame = switchRect;
        lockRotationSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
		[lockRotationSwitch addTarget:self action:@selector(lockRotationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        lockRotationSwitch.on = ad.setting.lockRotation;
		[cell addSubview:lockRotationSwitch];
	}

    if (section==1 && row==2) {
		cell.textLabel.text = NSLocalizedString(@"Global Pagination",nil);
		UISwitch *gloabalPaginationSwitch = [[UISwitch alloc]init];
		gloabalPaginationSwitch.frame = switchRect;
        gloabalPaginationSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
		[gloabalPaginationSwitch addTarget:self action:@selector(gloabalPaginationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        gloabalPaginationSwitch.on = ad.setting.globalPagination;
		[cell addSubview:gloabalPaginationSwitch];
	}
    
    if (section==2 && row==0) {
        double cw = cell.bounds.size.width;
        double sw = cw*0.1;
        double tw = cw*0.2;
        double th = TH*0.8;
        double tt = TH*0.1;
        tv0 = [[UIView alloc]init];
        tv0.frame = CGRectMake(sw*(1)+tw*0,tt,tw,th);
        tv0.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        tv0.backgroundColor = [UIColor whiteColor];
        UIButton *button0 = [UIButton buttonWithType:UIButtonTypeCustom];
        button0.frame = tv0.bounds;
        button0.tag = 0;
        button0.backgroundColor = tv0.backgroundColor;
        [button0 addTarget:self action:@selector(themeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [tv0 addSubview:button0];

        
        tv1 = [[UIView alloc]init];
        tv1.frame = CGRectMake(sw*(2)+tw*1,tt,tw,th);
        tv1.backgroundColor = [UIColor colorWithRed:(236/255.0) green:(227/255.0) blue:(199/255.0) alpha:(255/255.0)];
        tv1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        button1.frame = tv1.bounds;
        button1.tag = 1;
        button1.backgroundColor = tv1.backgroundColor;
        [button1 addTarget:self action:@selector(themeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [tv1 addSubview:button1];


        tv2 = [[UIView alloc]init];
        tv2.frame = CGRectMake(sw*(3)+tw*2,tt,tw,th);
        tv2.backgroundColor = [UIColor colorWithRed:(40/255.0) green:(40/255.0) blue:(40/255.0) alpha:(255/255.0)];
        tv2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        button2.frame = tv1.bounds;
        button2.tag = 2;
        button2.backgroundColor = tv2.backgroundColor;
        [button2 addTarget:self action:@selector(themeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [tv2 addSubview:button2];

        
        [cell addSubview:tv0];
        [cell addSubview:tv1];
        [cell addSubview:tv2];
        
        [self markTheme:ad.setting.theme];
    }    
    

    if (section==3 && row==0) {
        cell.textLabel.text =NSLocalizedString(@"None",nil);
        if (ad.setting.transitionType==0) [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    if (section==3 && row==1) {
        cell.textLabel.text =NSLocalizedString(@"Slide Effect",nil);
        if (ad.setting.transitionType==1) [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
        
    if (section==3 && row==2) {
        cell.textLabel.text =NSLocalizedString(@"Curl Effect",nil);
        if (ad.setting.transitionType==2) [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }


    if (section==4 && row==0) {
        cell.textLabel.text =NSLocalizedString(@"SkyReader version 1.0",nil);
    }
    
    if (section==4 && row==1) {
        cell.textLabel.text =NSLocalizedString(@"Powered By SkyEpub for iOS",nil);
    }   
	return cell;
}

-(void)themeClicked:(id)sender {
    UIView *sv = (UIView*)sender;
    int themeIndex = sv.tag;
    [self markTheme:themeIndex];
}

-(void)markTheme:(int)themeIndex {
    tv0.layer.borderColor = [UIColor lightGrayColor].CGColor;
    tv0.layer.borderWidth = 2;
    tv1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    tv1.layer.borderWidth = 2;
    tv2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    tv2.layer.borderWidth = 2;
    if (themeIndex==0) {
        tv0.layer.borderColor = [UIColor blueColor].CGColor;
        tv0.layer.borderWidth = 4;
    }else if (themeIndex==1){
        tv1.layer.borderColor = [UIColor blueColor].CGColor;
        tv1.layer.borderWidth = 4;
    }else {
        tv2.layer.borderColor = [UIColor blueColor].CGColor;
        tv2.layer.borderWidth = 4;
    }
    ad.setting.theme = themeIndex;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
    
    int oldType = ad.setting.transitionType;

    NSIndexPath* oldPath = [NSIndexPath indexPathForRow:oldType inSection:3];
    [[tableView cellForRowAtIndexPath:oldPath] setAccessoryType:UITableViewCellAccessoryNone];
    
    if (section==3 && row==0) {
        ad.setting.transitionType=0;
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    if (section==3 && row==1) {
        ad.setting.transitionType=1;
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    if (section==3 && row==2) {
        ad.setting.transitionType=2;
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}





@end
