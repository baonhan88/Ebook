//
//  MainViewController.m
//  CoreTest
//
//  Created by SkyTree on 11. 9. 6..
//  Copyright (c) 2011 Skytree Corporation. All rights reserved.
//

//  !!!!! IMPORTANT !!!!!
//  The Advanced Demo sources are not the part of SkyEpub SDK.
//  These sources are written only to show how to use SkyEpub SDK.
//  The bugs found in this demo do not mean that SkyEpub SDK has the related bugs
//  Developers should change and modify this Advanced Demo sources for their purposes.
//  Any request to add/change/modify the Advanced Demo sources will be refused.


#import "MainViewController.h"
#import "ReflowableViewController.h"
#import "FixedViewController.h"
#import "AppDelegate.h"
#import "BookViewController.h"
#import "MagazineController.h"
#import "PDFController.h"
#import "BookInformation.h"
#import "FileProvider.h"
#import "SetupController.h"
#import "HomeViewController.h"


@implementation MainViewController
@synthesize numberOfBooks;
int currentCode = 0;

-(void)installSamples {
    [self installSample:@"UCC"];
//    [self installSample:@"Alice"];
//    [self installSample:@"Doctor"];
    [self createBookInformations];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

-(void)createBookInformations {
    bookInformations = [ad fetchBookInformations];
    self.numberOfBooks = [bookInformations count];
}


// 수정대상
-(void)changeButtonTitle {
    if (bookInformations==NULL || [bookInformations count]==0) return;
    UIButton* button = (UIButton*)[self.view viewWithTag:99];
    BookInformation* bi = [bookInformations objectAtIndex:currentCode];
    NSString* title;
    title = [bi.title copy];
    [button setTitle:title forState:UIControlStateNormal];
}

-(void)toLeftClick:(id)sender {
    if ([bookInformations count]==0) return;
    currentCode--;
    if (currentCode<0) currentCode = numberOfBooks-1;
    [self changeButtonTitle];
}
-(void)toRightClick:(id)sender {
    if ([bookInformations count]==0) return;
    currentCode++;
    if (currentCode>(numberOfBooks-1)) currentCode = 0;
    [self changeButtonTitle];    
}

-(void)makeXIB {
    self.view.backgroundColor = [UIColor whiteColor];
    float deltaX = 80;
    float deltaY = 180;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Install Books" forState:UIControlStateNormal];
    button.frame = CGRectMake(94-deltaX,204-deltaY,120,37);
    [button addTarget:self action:@selector(test01Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];	
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"None" forState:UIControlStateNormal];
    button.frame = CGRectMake(94-deltaX,315-deltaY-50,72,37);
    [button addTarget:self action:@selector(testSpecial00:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];	

    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Slide" forState:UIControlStateNormal];
    button.frame = CGRectMake(94-deltaX,380-deltaY-70,72,37);
    [button addTarget:self action:@selector(testSpecial01:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];	

    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Curl" forState:UIControlStateNormal];
    button.frame = CGRectMake(94-deltaX,425-deltaY-70,72,37);
    [button addTarget:self action:@selector(testSpecial02:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
	
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"PDF" forState:UIControlStateNormal];
    button.tag = 100;
    button.titleLabel.frame = button.frame;
    button.frame = CGRectMake(200-deltaX,425-deltaY-70,150,37);
    [button addTarget:self action:@selector(pdfClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.tag = 99;
    button.titleLabel.frame = button.frame;
    button.frame = CGRectMake(200-deltaX,544-deltaY-120,180,37);
    [button addTarget:self action:@selector(viewerClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"<" forState:UIControlStateNormal];
    button.tag = 99;
    button.titleLabel.frame = button.frame;
    button.frame = CGRectMake(94-deltaX,544-deltaY-120,45,37);
    [button addTarget:self action:@selector(toLeftClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@">" forState:UIControlStateNormal];
    button.tag = 99;
    button.titleLabel.frame = button.frame;
    button.frame = CGRectMake(140-deltaX,544-deltaY-120,45,37);
    [button addTarget:self action:@selector(toRightClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Test" forState:UIControlStateNormal];
    button.tag = 999;
    button.titleLabel.frame = button.frame;
    button.frame = CGRectMake(94-deltaX,700-deltaY-120,72,37);
    [button addTarget:self action:@selector(test00Click:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];

}



-(NSTimeInterval)getIntervalByHour:(int)hour min:(int)min sec:(int)sec {
    return hour*3600 + min * 60 + sec;
}

-(NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
}

-(NSTimeInterval)getTimeIntervalFromString:(NSString*)hhmmss {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:hhmmss];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];
   
    NSTimeInterval timeInterval = [self getIntervalByHour:hour min:minute sec:second];
    
    return timeInterval;    
}


// 테스트를 위한 루틴
-(IBAction)test00Click:(id)sender {
    NSTimeInterval timeInterval = [self getTimeIntervalFromString:@"00:21:23"];
    NSString* str = [self stringFromTimeInterval:timeInterval];
    NSLog(@"Interval %@",str);
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    ad =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [ad loadSetting];
    [ad createDirectories];
    [self createBookInformations];
    [self makeXIB];
    [self changeButtonTitle];
}

-(void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}



-(IBAction)test01Click:(id)sender {    
    BOOL ret = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isBookInstalled"] boolValue];
    if (!ret) {
        [self installSamples];   
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isBookInstalled"];
        [self createBookInformations];
        [self changeButtonTitle];
    }
}

-(NSString*)getBaseDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *baseDirectory = [NSString stringWithFormat:@"%@/%@",documentsDirectory,@"books"];
	return baseDirectory;
}

-(IBAction)viewerClick:(id)sender {
    @autoreleasepool {
        if ([bookInformations count]==0)return;
        BookInformation * bi = [bookInformations objectAtIndex:currentCode];
        NSLog(@"title   %@",bi.title);
        NSLog(@"creator %@",bi.creator);
        
        if (!bi.isFixedLayout) {
            BookViewController *bvc = [[BookViewController alloc]init];
            bvc.bookInformation = bi;
            [self presentModalViewController:bvc animated:YES];
        }else {
            MagazineController *mvc = [[MagazineController alloc]init];
            mvc.bookInformation = bi;
            [self presentModalViewController:mvc animated:YES];
        }        
    }
}

-(IBAction)pdfClick:(id)sender {
    @autoreleasepool {
//        if ([bookInformations count]==0) return;
//        PDFController *pvc = [[PDFController alloc]init];
//        [self presentModalViewController:pvc animated:YES];
        
        SetupController *cvc = [[SetupController alloc]init];
        [self presentModalViewController:cvc animated:YES];
    }
}


-(IBAction)test04Click:(id)sender {
    if ([ad isAbove5]) {
        NSLog(@"System is above 5.0");        
    }
}

-(IBAction)testSpecial00:(id)sender {
    /*
    Setting* setting = [ad fetchSetting];
    setting.transitionType = PageTransitionNone;
    [ad updateSetting:setting];
    */
    
    HomeViewController *hvc = [[HomeViewController alloc]init];
    [self presentModalViewController:hvc animated:YES];

}

-(IBAction)testSpecial01:(id)sender {
    Setting* setting = [ad fetchSetting];
    setting.transitionType = PageTransitionSlide;
    [ad updateSetting:setting];
}

-(IBAction)testSpecial02:(id)sender {
    Setting* setting = [ad fetchSetting];
    if ([ad isAbove5]) {
        setting.transitionType = PageTransitionCurl;
    }else {
        setting.transitionType = PageTransitionSlide;
    }
    [ad updateSetting:setting];
}

-(IBAction)testSpecial03:(id)sender {
  
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (![ad isAbove5]) {
        [rvc didRotateFromInterfaceOrientation:interfaceOrientation];        
        [fvc didRotateFromInterfaceOrientation:interfaceOrientation];        
    }    
}

-(void)installSample:(NSString*)name {
    NSString *fullName = [NSString stringWithFormat:@"%@.epub",name];
    [ad installEPub:fullName];
}

-(void)installPDF:(NSString*)name {
    NSString *fullName = [NSString stringWithFormat:@"%@.pdf",name];
    [ad installPDF:fullName];
}

@end
