//
//  MagazineController.m
//  CoreTest
//
//  Created by Jiung Heo on 12. 1. 18..
//  Copyright (c) 2012년 Skytree Corporation. All rights reserved.
//

//  !!!!! IMPORTANT !!!!!
//  The Advanced Demo sources are not the part of SkyEpub SDK.
//  These sources are written only to show how to use SkyEpub SDK.
//  The bugs found in this demo do not mean that SkyEpub SDK has the related bugs
//  Developers should change and modify this Advanced Demo sources for their purposes.
//  Any request to add/change/modify the Advanced Demo sources will be refused.


#import "MagazineController.h"
#import "FileProvider.h"

@implementation MagazineController
@synthesize bookInformation;

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
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

-(void)fixedViewController:(FixedViewController*)fvc pageMoved:(FixedPageInformation*)fixedPageInformation {
    NSLog(@"%d/%d = %f %@",fixedPageInformation.pageIndex,fixedPageInformation.numberOfPages,fixedPageInformation.pagePosition,fixedPageInformation.cachedImagePath);
    self.bookInformation.position = fixedPageInformation.pagePosition; // 0~1
        if ([fvc isMediaOverlayAvailable]) {
            [self showMediaUI];
            if (isAutoPlaying) {
                [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
                [fvc playFirstParallel];
            }
        }else {
            [self hideMediaUI];
        }
/*
    int pc = [fv pageCountInBook];
    int pi = [fv currentPageIndex];
    
    NSLog(@"%d/%d",pi,pc);
 */   
}


-(void)fixedViewController:(FixedViewController*)fvc didDetectTapAtPositionInView:(CGPoint)positionInView positionInPage:(CGPoint)positionInPage {
    NSLog(@"tap Detected at %f,%f in View and %f,%f in Page",positionInView.x,positionInView.y,positionInPage.x,positionInPage.y);        
}

-(void)fixedViewController:(FixedViewController*)fvc didDetectDoubleTapAtPositionInView:(CGPoint)positionInView positionInPage:(CGPoint)positionInPage {
    NSLog(@"doubleTap Detected at %f,%f in View and %f,%f in Page",positionInView.x,positionInView.y,positionInPage.x,positionInPage.y);        
}

-(NSString*)getBooksDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *booksDirectory = [NSString stringWithFormat:@"%@/%@",documentsDirectory,@"books"];
    return booksDirectory;
}

-(BOOL)isPad {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }else {
        return NO;
    }
}

-(BOOL)isPortrait {
    return UIDeviceOrientationIsPortrait(self.interfaceOrientation);
}


-(void)makeBookViewer {
    fv = [[FixedViewController alloc]initWithStartPageIndex:0 spread:bookInformation.spread];
//    fv = [[FixedViewController alloc]initWithStartPosition:self.bookInformation.position spread:SpreadAuto];
//    fv = [[FixedViewController alloc]initWithStartPosition:self.bookInformation.position spread:SpreadNone];
    Book *book = [[Book alloc]init];
    book.bookCode = bookInformation.bookCode;
    book.fileName = bookInformation.fileName;
    book.isFixedLayout = YES;
    [fv setLicenseKey:@"0000-0000-0000-0000"];
    fv.book = book;
    fv.transitionType = setting.transitionType;
    fv.dataSource = self;
    fv.delegate =self;
    fv.baseDirectory = [self getBooksDirectory];
    fv.view.frame = self.view.bounds;
    [fv setContentProviderClass:[FileProvider self]];
    fv.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:fv];
    [self.view addSubview:fv.view];
    self.view.autoresizesSubviews = YES;
    // set delay time to show page after loading. if this value is too small, loading and rendering process will be exposed to user.
    [fv setTimeForRendering:2.0f];
    // set delay time to capture page image after loading. if this value is too small, blank or incomplete image will be captured
    [fv setTimeForCaching:2.0f];
    [fv setPagesCenterImage:[UIImage imageNamed:@"PagesCenter.png"]];
    [fv setPagesStackImage:[UIImage imageNamed:@"PagesStack.png"]];
    // enable/diable navigation areas on both side. 
    [fv setNavigationAreaEnabled:YES];
}

-(void)makeMediaUI {
    prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [prevButton setImage:[UIImage imageNamed:@"prev.png"] forState:UIControlStateNormal];
    [prevButton addTarget:self action:@selector(prevPressed0:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:prevButton];
    
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playPressed1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:playButton];
    
    stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopButton setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(stopPressed2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopButton];
    
    nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextPressed3:) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:nextButton];
}


-(void)makeUI {
    homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setImage:[UIImage imageNamed:@"home.png"] forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(homePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:homeButton];
}

-(void)recalcFrames {
    float bw = 24,bh = 24;
    float vw = self.view.bounds.size.width;
    float vh = self.view.bounds.size.height;
    float lm = 50;
    float rm = 100;
    float tm = 10;
//    float bm = vh*.085f;
    
    float mx = 200;
    
    NSLog(@"view width %f height %f",vw,vh);
    
    if ([self isPad]) {
        if ([self isPortrait]) {
            homeButton.frame    = CGRectMake(lm+40*0,tm,bw,bh);
            prevButton.frame    = CGRectMake(mx+40*0,tm,bw,bh);
            playButton.frame    = CGRectMake(mx+40*1,tm,bw,bh);
            stopButton.frame    = CGRectMake(mx+40*2,tm,bw,bh);
            nextButton.frame    = CGRectMake(mx+40*3,tm,bw,bh);
        }else {
            lm = 75;
            rm = 100;
            mx = 220;
            homeButton.frame    = CGRectMake(lm+40*0,tm,bw,bh);            
            prevButton.frame    = CGRectMake(mx+40*0,tm,bw,bh);
            playButton.frame    = CGRectMake(mx+40*1,tm,bw,bh);
            stopButton.frame    = CGRectMake(mx+40*2,tm,bw,bh);
            nextButton.frame    = CGRectMake(mx+40*3,tm,bw,bh);
            
        }
    }else {
        if ([self isPortrait]) {
            bw = 20;
            bh = 20;
            tm = 15;
            lm = 40;
            rm = 68;
            mx = 110;
//            NSString* fn = @"Helvetica";
//            int fs = 12;
            homeButton.frame    = CGRectMake(lm+32*0,tm,bw,bh);
            prevButton.frame    = CGRectMake(mx+40*0,tm,bw,bh);
            playButton.frame    = CGRectMake(mx+40*1,tm,bw,bh);
            stopButton.frame    = CGRectMake(mx+40*2,tm,bw,bh);
            nextButton.frame    = CGRectMake(mx+40*3,tm,bw,bh);
        }else {
            tm = 10;
            lm = 40;
            rm = 70;
            mx = 170;
            homeButton.frame    = CGRectMake(lm+40*0,tm,bw,bh);
            prevButton.frame    = CGRectMake(mx+40*0,tm,bw,bh);
            playButton.frame    = CGRectMake(mx+40*1,tm,bw,bh);
            stopButton.frame    = CGRectMake(mx+40*2,tm,bw,bh);
            nextButton.frame    = CGRectMake(mx+40*3,tm,bw,bh);
        }
    }
    
}


-(void)showMediaUI {
    [prevButton setHidden:NO];
    [playButton setHidden:NO];
    [stopButton setHidden:NO];
    [nextButton setHidden:NO];
    [self.view bringSubviewToFront:prevButton];
    [self.view bringSubviewToFront:playButton];
    [self.view bringSubviewToFront:stopButton];
    [self.view bringSubviewToFront:nextButton];
}

-(void)hideMediaUI {
    [prevButton setHidden:YES];
    [playButton setHidden:YES];
    [stopButton setHidden:YES];
    [nextButton setHidden:YES];
}


-(void)prevPressed0:(id)sender {
    [self playPrev];
}

-(void)playPressed1:(id)sender {
    [self playAndPause];
}

-(void)stopPressed2:(id)sender {
    [self stopPlaying];
}

-(void)nextPressed3:(id)sender {
    [self playNext];
}

-(void)testPressed4:(id)sender {
    autoStartPlayingWhenNewPagesLoaded = !autoStartPlayingWhenNewPagesLoaded;
}

-(void)testPressed5:(id)sender {
    autoMovePageWhenParallesFinished = !autoMovePageWhenParallesFinished;
    
}

-(void)testPressed6:(id)sender {
    isLoop = !isLoop;    
}

-(void)homePressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [ad updateBookPosition:self.bookInformation];
    [fv destroy];   // detroy all objects and release resources in FixedView.
    fv = nil;
}

-(void)makeXIB {
    [self makeBookViewer];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    ad =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
    setting = [ad fetchSetting];
    [self makeXIB];
    [self makeUI];
    [self makeMediaUI];
    isAutoPlaying = YES;
    autoStartPlayingWhenNewPagesLoaded = YES;
    autoMovePageWhenParallesFinished = YES;
    isLoop = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES   withAnimation:UIStatusBarAnimationFade];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [self recalcFrames];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:(BOOL)animated];    // Call the super class implementation.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)fixedViewController:(FixedViewController*)fvc cachingStarted:(int)index {
    isCaching = YES;
}

-(void)fixedViewController:(FixedViewController*)fvc cachingFinished:(int)index {
    isCaching = NO;
}

-(void)fixedViewController:(FixedViewController*)fvc cached:(int)index path:(NSString *)path {
    NSLog(@"PageIndex %d is cached to %@",index,path);
}

// iOS 6 or above....
- (BOOL)shouldAutorotate {
//    if (!isCaching) return YES;
//    else return NO;
//    return [fvc canRotate];
    return YES;
}

// iOS 6 or above....
- (BOOL)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (!isCaching) return YES;
    else return NO;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (![ad isAbove5]) {
        [fv didRotateFromInterfaceOrientation:interfaceOrientation];        
    }
    [self recalcFrames];
}

/* MediaOverlay callbacks */
-(void)fixedViewController:(FixedViewController *)fvc parallelDidStart:(Parallel *)parallel {
    [fvc changeElementColor:@"#F0F000" hash:parallel.hash pageIndex:parallel.pageIndex];
    currentParallel = parallel;
}

-(void)fixedViewController:(FixedViewController *)fvc parallelDidEnd:(Parallel *)parallel {
    [fvc restoreElementColor];
    if (isLoop) {
        [fvc playPrevParallel];
    }
}

-(void)parallesDidEnd:(FixedViewController *)fvc {
    if (autoStartPlayingWhenNewPagesLoaded) isAutoPlaying = YES;
    if (autoMovePageWhenParallesFinished) {
        [fvc gotoNextPage];
    }
}

/* MediaOverlay Utilities */
-(void)playAndPause {
    if ([fv isPlayingPaused]) {
        if (![fv isPlayingStarted]) {
            if (autoStartPlayingWhenNewPagesLoaded) isAutoPlaying = YES;
            [fv playFirstParallel];
        }else {
            if (autoStartPlayingWhenNewPagesLoaded) isAutoPlaying = YES;
            [fv resumePlayingParallel];
        }
        
    }else {
        if (autoStartPlayingWhenNewPagesLoaded) isAutoPlaying = NO;
        [fv pausePlayingParallel];
    }
    
    if ([fv isPlayingPaused]) {
        [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }else {
        [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
    
}

-(void)stopPlaying {
    [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [fv stopPlayingParallel];
    if (autoStartPlayingWhenNewPagesLoaded) isAutoPlaying = NO;
    [fv restoreElementColor];
}


-(void)playPrev {
    [fv restoreElementColor];
    if (currentParallel.parallelIndex==0) {
        if (autoMovePageWhenParallesFinished) [fv gotoPrevPage];
    }else {
        [fv playPrevParallel];
    }
}

-(void)playNext {
    [fv restoreElementColor];
    [fv playNextParallel];
}



@end
