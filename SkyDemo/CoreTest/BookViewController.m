//
//  BookViewController.m
//  CoreTest
//
//  Created by Heo Jiung on 2013. 07. 31
//  Copyright (c) 2011 Skytree Corporation. All rights reserved.
//

//  !!!!! IMPORTANT !!!!!
//  The Advanced Demo sources are not the part of SkyEpub SDK.
//  These sources are written only to show how to use SkyEpub SDK.
//  The bugs found in this demo do not mean that SkyEpub SDK has the related bugs
//  Developers should change and modify this Advanced Demo sources and graphics files for their purposes.
//  Any request to add/change/modify the Advanced Demo sources will be refused.


#import "BookViewController.h"
#import "ReflowableViewController.h"
#import "Highlight.h"
#import "FileProvider.h"
#import "EPubProvider.h"
#import "Book.h"
#import <objc/runtime.h>
#import "SetupController.h"
#import <QuartzCore/QuartzCore.h>

#ifdef __IPHONE_6_0
# define ALIGN_CENTER NSTextAlignmentCenter
#else
# define ALIGN_CENTER UITextAlignmentCenter
#endif

#define SEARCHRESULT    0
#define SEARCHMORE      1
#define SEARCHFINISHED  2
#define MAX_NUM_SEARCH = 100

#define UIColorFromRGB(rgbValue) [UIColor \
                                 colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                                 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


// Utility Code
@interface NoteView : UITextView <UITextViewDelegate> {
}
@end

@implementation NoteView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.6f alpha:1.0f];
        self.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:19];
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if ([super canPerformAction:action withSender:sender]) {
        return YES;
    }
    else {
        if (action == @selector(paste:) ||action == @selector(copy:) || action == @selector(select:) || action == @selector(selectAll:))     {
            return [super canPerformAction:action withSender:sender];
        }
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UIMenuController *mc = [UIMenuController sharedMenuController];
    [mc setTargetRect:CGRectMake(0,0,300,80) inView:self];
    [mc setMenuVisible:YES animated:YES];
}

-(void)drawRect:(CGRect)rect {
    @autoreleasepool {
        [super drawRect:rect];
        //Get the current drawing context
        CGContextRef context = UIGraphicsGetCurrentContext();
        //Set the line color and width
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f].CGColor);
        CGContextSetLineWidth(context, 1.0f);
        //Start a new Path
        CGContextBeginPath(context);
        
        //Find the number of lines in our textView + add a bit more height to draw lines in the empty part of the view
        NSUInteger numberOfLines = (self.contentSize.height + self.bounds.size.height) / self.font.leading;
        
        //Set the line offset from the baseline. (I'm sure there's a concrete way to calculate this.)
        CGFloat baselineOffset = 6.0f;
        
        //iterate over numberOfLines and draw each line
        for (int x = 0; x < numberOfLines; x++) {
            //0.5f offset lines up line with pixel boundary
            CGContextMoveToPoint(context, self.bounds.origin.x, self.font.leading*x + 0.5f + baselineOffset);
            CGContextAddLineToPoint(context, self.bounds.size.width, self.font.leading*x + 0.5f + baselineOffset);
        }
        
        //Close our Path and Stroke (draw) it
        CGContextClosePath(context);
        CGContextStrokePath(context);
    }
}

@end


// Utility Code
@interface DottedView : UIView {
    double progress;
    BOOL isProgress;
    UIColor *dotColor,*dotBackColor;
}
@property double progress;
@property BOOL isProgress;
@property (nonatomic,retain) UIColor* dotColor,*dotBackColor;
@end

@implementation DottedView
@synthesize progress,isProgress,dotColor,dotBackColor;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

-(void)drawRect:(CGRect)rect {
    @autoreleasepool {
        [super drawRect:rect];
        
        double dw = 3.0;
        double ds = 8.0;
        double vh = self.frame.size.height;
        double vw = self.frame.size.width;
        
        CGRect borderRect;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1.0);
        for (int x=ds; x<self.frame.size.width-ds; x+=(dw+ds)) {
            borderRect = CGRectMake(x,vh/2-dw/2, dw,dw);
            if (x<vw*progress && isProgress) {
                CGContextSetStrokeColorWithColor(context,[UIColor redColor].CGColor );
                CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            }else {
                CGContextSetStrokeColorWithColor(context,dotBackColor.CGColor );
                CGContextSetFillColorWithColor(context, dotColor.CGColor);
            }
            CGContextFillEllipseInRect (context, borderRect);
            CGContextStrokeEllipseInRect(context, borderRect);
        }
        CGContextFillPath(context);
    }
}

-(void)setProgressValue:(double)value {
    self.progress = value;
    [self setNeedsDisplay];
}

-(void)setProgressMode:(BOOL)value {
    self.isProgress = value;
    [self setNeedsDisplay];
}



@end

@interface Theme : NSObject {
    NSString* name;
    NSString* portraitForPad;
    NSString* landscapeForPad;
    NSString* doublePagedForPad;
    NSString* portraitForPhone;
    NSString* landscapeForPhone;

    CGRect portraitForPadRect;
    CGRect landscapeForPadRect;
    CGRect doublePagedForPadRect;
    CGRect portraitForPhoneRect;
    CGRect landscapeForPhoneRect;
    
    
    UIColor* foregroundColor;
    UIColor* backgroundColor;
    UIColor* controlColor;
    UIColor* blankColor;
    
}
@property (nonatomic,retain) NSString* name,*portraitForPad,*landscapeForPad,*doublePagedForPad,*portraitForPhone,*landscapeForPhone;
@property CGRect portraitForPadRect,landscapeForPadRect,doublePagedForPadRect,portraitForPhoneRect,landscapeForPhoneRect;
@property (nonatomic,copy) UIColor*foregroundColor,*backgroundColor,*controlColor,*blankColor;

@end

@implementation Theme
@synthesize name,portraitForPad,landscapeForPad,doublePagedForPad,portraitForPhone,landscapeForPhone;
@synthesize portraitForPadRect,landscapeForPadRect,doublePagedForPadRect,portraitForPhoneRect,landscapeForPhoneRect;
@synthesize foregroundColor,backgroundColor,controlColor,blankColor;

@end



// Utility Code
@implementation UIColor(Hex)
- (NSUInteger)intValue {
    float red, green, blue;
    if ([self getRed:&red green:&green blue:&blue alpha:NULL]) {
        NSUInteger redInt = (NSUInteger)(red * 255 + 0.5);
        NSUInteger greenInt = (NSUInteger)(green * 255 + 0.5);
        NSUInteger blueInt = (NSUInteger)(blue * 255 + 0.5);
        
        return (redInt << 16) | (greenInt << 8) | blueInt;
    }
    return 0;
}

@end

// Utility Code
@interface UIButton(WCButton)
@property (nonatomic, retain) NSMutableDictionary *backgrounds;
- (void) setBackgroundColor:(UIColor *)bgColor forState:(UIControlState)state;
@end


@implementation UIButton(WCButton)
static char BG_PROPERTY_KEY;
@dynamic backgrounds;

- (void)setBackgrounds:(NSMutableDictionary *)backgrounds {
    objc_setAssociatedObject(self, &BG_PROPERTY_KEY, backgrounds, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)backgrounds {
    return (NSMutableDictionary *)objc_getAssociatedObject(self, &BG_PROPERTY_KEY);
}


- (void) setBackgroundColor:(UIColor *)bgColor forState:(UIControlState)state {
    if([self backgrounds] == NULL) {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        [self setBackgrounds:tmpDict];
    }
    
    [[self backgrounds] setObject:bgColor forKey:[NSNumber numberWithInt:state]];
    
    if(!self.backgroundColor)
        self.backgroundColor = bgColor;
}

- (void)animateBackgroundToColor:(NSNumber *)key {
    UIColor *background = [[self backgrounds] objectForKey:key];
    if(background) {
        [UIView animateWithDuration:0.1f animations:^{
            self.backgroundColor = background;
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self animateBackgroundToColor:[NSNumber numberWithInt:UIControlStateHighlighted]];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self animateBackgroundToColor:[NSNumber numberWithInt:UIControlStateNormal]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self animateBackgroundToColor:[NSNumber numberWithInt:UIControlStateNormal]];
}

@end

// Utility Code
@interface ArrowView : UIView {
    UIColor *color;
    BOOL upSide;
}

@property BOOL upSide;

@end

@implementation ArrowView
@synthesize upSide;


-(void)setColor:(UIColor*)newColor {
    color = newColor;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();    
    if (upSide) {
        CGContextBeginPath(ctx);
        CGContextMoveToPoint   (ctx, CGRectGetMaxX(rect)/2, CGRectGetMinY(rect));  // top left
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // mid right
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));  // bottom left
        CGContextClosePath(ctx);
    }else {
        CGContextBeginPath(ctx);
        CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));  // mid right
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect)/2, CGRectGetMaxY(rect));  // bottom left
        CGContextClosePath(ctx);        
    }
    CGContextSetFillColorWithColor(ctx, [color CGColor]);
    CGContextFillPath(ctx);
}

@end



/** Main code */
@implementation BookViewController
@synthesize bookInformation,setting,isRTL;

// Search Test Routines
-(void)displayNavMap {
    for (int i=0; i<[rv.book.NavMap count]; i++) {
        NavPoint* np = [rv.book.NavMap objectAtIndex:i];
        NSLog(@"%d %@",i,np.text);
    }
}

-(unsigned int)intFromColor:(UIColor*)color {
    CGColorRef colorref = [color CGColor];
    const CGFloat *components = CGColorGetComponents(colorref);
    
    unsigned int hexValue = 0xFF0000*components[0] + 0xFF00*components[1] + 0xFF*components[2];
    return hexValue;
}

-(void)startSearch:(NSString*)key {
    [searchResults removeAllObjects];
    // remove all previous results
    for (UIView*sv in searchResultsView.subviews) {
        [sv removeFromSuperview];
    }
    [rv searchKey:key];
}

-(void)searchMore {
    [rv searchMore];
}

-(void)stopSearch {
    [rv stopSearch];    
}

-(void)reflowableViewController:(ReflowableViewController *)rvc didSearchKey:(SearchResult *)searchResult {
    count++;    
    [self addSearchResult:searchResult mode:SEARCHRESULT];
}

int lastNumberOfSearched = 0;

-(void)reflowableViewController:(ReflowableViewController *)rvc didFinishSearchForChapter:(SearchResult *)searchResult {
    [rvc pauseSearch];
    int cn = searchResult.numberOfSearched - lastNumberOfSearched;
    if (cn > 150) {
        [self addSearchResult:searchResult mode:SEARCHMORE];
        lastNumberOfSearched = searchResult.numberOfSearched;
    }else {
        [rv searchMore];
    }
}

-(void)reflowableViewController:(ReflowableViewController *)rvc didFinishSearchAll:(SearchResult *)searchResult {
    [self addSearchResult:searchResult mode:SEARCHFINISHED];
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
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:(BOOL)animated];    // Call the super class implementation.
    NSLog(@"viewDidDisapper in Bookviewer");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


-(NSString*)getBaseDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *baseDirectory = [NSString stringWithFormat:@"%@/%@",documentsDirectory,@"books"];
	return baseDirectory;
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

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if ([super canPerformAction:action withSender:sender]) {
        return YES;
    }
    else {
        if (action == @selector(paste:) ||action == @selector(copy:) || action == @selector(select:) || action == @selector(selectAll:))     {
            return [super canPerformAction:action withSender:sender];
        }
    }
    return NO;
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

-(int)getRealFontSize:(int)fontSizeIndex {
    int rs = 0;
    switch (fontSizeIndex) {
        case 0:
            rs = 15;
            break;
        case 1:
            rs = 17;
            break;
        case 2:
            rs = 20;
            break;
        case 3:
            rs = 24;
            break;
        case 4:
            rs = 27;
            break;
        default:
            rs = 20;
    }
    return rs;
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

-(void)makeThemes {
    if (themes!=NULL) return;
    themes = [[NSMutableArray alloc]init];
    
    Theme* whiteTheme = [[Theme alloc]init];
    whiteTheme.name = @"white";
    whiteTheme.foregroundColor = [UIColor blackColor];
    whiteTheme.backgroundColor = [UIColor clearColor];
    whiteTheme.controlColor = [UIColor colorWithRed:94/255.0 green:61/255.0 blue:35/255.00 alpha:1.0];
    whiteTheme.blankColor = [UIColor whiteColor];
    whiteTheme.portraitForPad = @"Pad-Portrait-White.png";
    whiteTheme.portraitForPhone = @"Phone-Portrait-White.png";
    whiteTheme.landscapeForPad = @"Pad-Landscape-White.png";
    whiteTheme.doublePagedForPad = @"Pad-Double-White.png";
    whiteTheme.landscapeForPhone = @"Phone-Landscape-White.png";
    whiteTheme.portraitForPadRect =CGRectMake(0,12,1024-(56*1),1496-(12*2));
    whiteTheme.landscapeForPadRect =CGRectMake(0,12,2048-(56*1),1536-(12*2));
    whiteTheme.doublePagedForPadRect = CGRectMake(56,12,2048-(56*2),1536-(12*2));
    whiteTheme.portraitForPhoneRect = CGRectMake(0,0,1002-(34),1506);
    whiteTheme.landscapeForPhoneRect = CGRectMake(0,0,2004-(34),1506);

    Theme* classicTheme = [[Theme alloc]init];
    classicTheme.name = @"classic";
    classicTheme.foregroundColor = [UIColor blackColor];
    classicTheme.backgroundColor = [UIColor clearColor];
    classicTheme.controlColor = [UIColor colorWithRed:94/255.0 green:61/255.0 blue:35/255.00 alpha:1.0];
    classicTheme.blankColor = [UIColor colorWithRed:236/255.0 green:227/255.0 blue:199/255.00 alpha:1.0];
    classicTheme.portraitForPad = @"Pad-Portrait-Brown.png";
    classicTheme.portraitForPhone = @"Phone-Portrait-Brown.png";
    classicTheme.landscapeForPad = @"Pad-Landscape-Brown.png";
    classicTheme.doublePagedForPad = @"Pad-Double-Brown.png";
    classicTheme.landscapeForPhone = @"Phone-Landscape-Brown.png";
    classicTheme.portraitForPadRect =CGRectMake(0,12,1024-(56*1),1496-(12*2));
    classicTheme.landscapeForPadRect =CGRectMake(0,12,2048-(56*1),1536-(12*2));
    classicTheme.doublePagedForPadRect = CGRectMake(56,12,2048-(56*2),1536-(12*2));
    classicTheme.portraitForPhoneRect = CGRectMake(0,0,1002-(34),1506);
    classicTheme.landscapeForPhoneRect = CGRectMake(0,0,2004-(34),1506);

    Theme* darkTheme = [[Theme alloc]init];
    darkTheme.name = @"dark";
    darkTheme.foregroundColor = [UIColor whiteColor];
    darkTheme.backgroundColor = [UIColor clearColor];
    darkTheme.controlColor = [UIColor whiteColor];
    darkTheme.blankColor = [UIColor colorWithRed:45/255.0 green:45/255.0 blue:45/255.00 alpha:1.0];
    darkTheme.portraitForPad = @"Pad-Portrait-Black.png";
    darkTheme.portraitForPhone = @"Phone-Portrait-Black.png";
    darkTheme.landscapeForPad = @"Pad-Landscape-Black.png";
    darkTheme.doublePagedForPad = @"Pad-Double-Black.png";
    darkTheme.landscapeForPhone = @"Phone-Landscape-Black.png";
    darkTheme.portraitForPadRect =CGRectMake(0,12,1024-(56*1),1496-(12*2));
    darkTheme.landscapeForPadRect =CGRectMake(0,12,2048-(56*1),1536-(12*2));
    darkTheme.doublePagedForPadRect = CGRectMake(56,12,2048-(56*2),1536-(12*2));
    darkTheme.portraitForPhoneRect = CGRectMake(0,0,1002-(34),1506);
    darkTheme.landscapeForPhoneRect = CGRectMake(0,0,2004-(34),1506);
    
    [themes addObject:whiteTheme];
    [themes addObject:classicTheme];
    [themes addObject:darkTheme];
}

-(Theme*)getTheme {
    int themeIndex = ad.setting.theme;
    Theme* theme = [themes objectAtIndex:themeIndex];
    return theme;
}

-(void)makeBookViewer {
    @autoreleasepool {
        Theme* theme = [self getTheme];
        self.view.backgroundColor = [UIColor blackColor];
        rv = [[ReflowableViewController alloc]initWithStartPagePositionInBook:self.bookInformation.position];
/*
        // Delay Times for Innernal Operations of SDK
        // !! DO NOT set these values if there'no issue on your epub reader !!
        // !! To Increse this value too high will cause the performance issue !!
        // !! to Decrese this value too low  will break the stablity of SDK !!
        // !! these routines should be used very carefully with real device !!
        // !! default values for middle, low and fast
        // delay time after recalc
        [rv setDelayTimeForProcessContentInRecalc:0.05];                        // slow machine 0.05        fast machine 0.05
        // detlay time after rotation
        [rv setDelayTimeForProcessContentInRecalcPagesForRotation:1];           // slow machine 1           fast machine 0.5
        // delay time after all process, before showing contentView
        [rv setDelayTimeForShowWebViewInProcessContent:0.25];                   // slow machine 0.25        fast machine 0.1
        // delay time after all process, before showing webView
        [rv setDelayTimeForBringContentViewToFrontInShowWebView:0.25];          // slow machine 0.1         fast machine 0.5
        // delay time after all process, before showing webView while Global Pagination
        [rv setDelayTimeForMakeAndResetPageImagesInShowWebViewForPaing:0.5];    // slow machine 0.5         fast machine 0.2
        // delay time for user interaction
        [rv setDelayTimeForSetPageReadyInShowWebView:0.75];                     // slow machine 1.0         fast machine 0.5
*/
        // for epub3 which has page-progression-direction="rtl", rv.isRTL() will return true.
		// for old RTL epub which does not have <spine toc="ncx" page-progression-direction="rtl"> in opf file.
		// you can enforce RTL mode.
//        [rv setRTL:NO];
        [rv setBlankColor:theme.blankColor];
        rv.book.isFixedLayout = NO;
        if (![setting.fontName isEqualToString:@"Book Fonts"]) {
            rv.book.fontName = setting.fontName;
        }
        rv.book.fontSize = [self getRealFontSize:setting.fontSize];
        rv.book.fileName = bookInformation.fileName;
        rv.book.bookCode = bookInformation.bookCode;
        rv.baseDirectory = [self getBaseDirectory];
        rv.transitionType = setting.transitionType;
        self.isRTL = bookInformation.isRTL;
        if (ad.setting.doublePaged && !self.isRTL && [self isPad]) isDoublePaged = YES;
        else isDoublePaged = NO;
        [rv useDOMHighlight:NO];
        if ([self isPad]) {
            [rv setBackgroundImageForPortrait:[UIImage imageNamed:theme.portraitForPad]             contentRect:theme.portraitForPadRect];
            if (isDoublePaged) {
                [rv setBackgroundImageForLandscape:[UIImage imageNamed:theme.doublePagedForPad]     contentRect:theme.doublePagedForPadRect];
            }else {
                [rv setBackgroundImageForLandscape:[UIImage imageNamed:theme.landscapeForPad]       contentRect:theme.landscapeForPadRect];
            }
            [rv setDoublePagedForLandscape:isDoublePaged];
        }else {
            [rv setBackgroundImageForLandscape:[UIImage imageNamed:theme.landscapeForPhone]         contentRect:theme.landscapeForPhoneRect];
            [rv setBackgroundImageForPortrait:[UIImage imageNamed:theme.portraitForPhone]           contentRect:theme.portraitForPhoneRect];
            [rv setDoublePagedForLandscape:NO];
        }
        [rv setMarkerImage:[UIImage imageNamed:@"marker.jpg"]];
        if ([self isPad]) {
            [rv setVerticalGapRatio:0.16]; // leaves the room for top and bottom icons.
        }else {
            [rv setVerticalGapRatio:0.28]; // leaves the room for top and bottom icons.
        }
        [rv setHorizontalGapRatio:0.3];
        [rv setGlobalPaging:setting.globalPagination];
        [rv showIndicatorWhileLoadingChapter:YES];
        [rv showIndicatorWhilePaging:NO];
        [rv showIndicatorWhileRotating:YES];
        [rv allowPageTransitionFast:YES];
        // if you want to draw highlight by yourself, set YES.
        [rv setCustomDrawHighlight:YES];
        if (ad.setting.theme==2) {
            [rv changeForegroundColor:theme.foregroundColor];
        }
        rv.dataSource = self;
        rv.delegate =self;
        // FileProvide reads the content of epub (which is unzipped) from file system. 
        [rv setContentProviderClass:[FileProvider self]];
        // EpubProvider will read the content of epub without unzipping.
//        [rv setContentProviderClass:[EPubProvider self]];
        [rv setLicenseKey:@"36df-3914-6ed2-9bc6"];
        [self addChildViewController:rv];
        rv.view.frame = self.view.bounds;
        rv.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:rv.view];
        self.view.autoresizesSubviews = YES;
    }
}


-(void)makeMediaUI {
    prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [prevButton setImage:[UIImage imageNamed:@"prev.png"] forState:UIControlStateNormal];
    [prevButton addTarget:self action:@selector(prevPressed0:) forControlEvents:UIControlEventTouchUpInside];
    [rv.customView addSubview:prevButton];
    
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playPressed1:) forControlEvents:UIControlEventTouchUpInside];
    [rv.customView addSubview:playButton];
    
    stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopButton setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(stopPressed2:) forControlEvents:UIControlEventTouchUpInside];
    [rv.customView addSubview:stopButton];
    
    nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextPressed3:) forControlEvents:UIControlEventTouchUpInside];
    [rv.customView addSubview:nextButton];
}

-(void)makeUI {
    homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    homeButton.showsTouchWhenHighlighted = YES;
    if (ad.setting.theme==2) {
        [homeButton setImage:[UIImage imageNamed:@"homewhite.png"] forState:UIControlStateNormal];
    }else {
        [homeButton setImage:[UIImage imageNamed:@"home.png"] forState:UIControlStateNormal];
    }
    [homeButton addTarget:self action:@selector(homePressed:) forControlEvents:UIControlEventTouchUpInside];
    [homeButton setContentMode:UIViewContentModeCenter];
    [rv.customView addSubview:homeButton];
    
    listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    listButton.showsTouchWhenHighlighted = YES;
    if (ad.setting.theme==2) {
        [listButton setImage:[UIImage imageNamed:@"listwhite.png"] forState:UIControlStateNormal];
    }else {
        [listButton setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
    }
    [listButton addTarget:self action:@selector(listPressed:) forControlEvents:UIControlEventTouchUpInside];
    [listButton setContentMode:UIViewContentModeCenter];
    [rv.customView addSubview:listButton];

    
    fontButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fontButton.showsTouchWhenHighlighted = YES;
    if (ad.setting.theme==2) {
        [fontButton setImage:[UIImage imageNamed:@"fontwhite.png"] forState:UIControlStateNormal];
    }else {
        [fontButton setImage:[UIImage imageNamed:@"font.png"] forState:UIControlStateNormal];
    }
    [fontButton addTarget:self action:@selector(fontPressed:) forControlEvents:UIControlEventTouchUpInside];
    [fontButton setContentMode:UIViewContentModeCenter];
    [rv.customView addSubview:fontButton];
    
    
    searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.showsTouchWhenHighlighted = YES;
    if (ad.setting.theme==2) {
        [searchButton setImage:[UIImage imageNamed:@"searchwhite.png"] forState:UIControlStateNormal];
    }else {
        [searchButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    }
    [searchButton addTarget:self action:@selector(searchPressed:) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setContentMode:UIViewContentModeCenter];    
    [rv.customView addSubview:searchButton];

    dotted = [[DottedView alloc]init];
    dotted.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    dotted.userInteractionEnabled = NO;
    dotted.backgroundColor = [UIColor clearColor];
    if (ad.setting.theme!=2) {
        dotted.dotBackColor = [UIColor darkGrayColor];
        dotted.dotColor = [UIColor blackColor];
    }else {
        dotted.dotBackColor = [UIColor grayColor];
        dotted.dotColor = [UIColor whiteColor];
    }
    [dotted setProgressMode:NO];
    [dotted setProgressValue:0.0];

    slider = [[UISlider alloc]init];
    [slider setMinimumTrackImage:[UIImage imageNamed:@"null.png"] forState:UIControlStateNormal];
    [slider setMaximumTrackImage:[UIImage imageNamed:@"null.png"] forState:UIControlStateNormal];
    slider.minimumValue = 0.0;
    slider.maximumValue = 1.0;
    slider.continuous = YES;
    [slider addTarget:self action:@selector(sliderDragStarted:) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderDragEnded:) forControlEvents:UIControlEventTouchUpInside];
    [rv.customView addSubview:dotted];
    [self.view addSubview:slider];
    
    NSString* fn = @"Helvetica-Bold";
    int fs = 13;
    authorLabel = [[UILabel alloc] init];
    authorLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [authorLabel setBackgroundColor:[UIColor clearColor]];
    [authorLabel setTextColor:[self getTheme].controlColor];
    authorLabel.textAlignment=ALIGN_CENTER;
    if ([self isPad]) [rv.customView addSubview:authorLabel];
    
    titleLabel = [[UILabel alloc] init];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[self getTheme].controlColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    titleLabel.textAlignment=ALIGN_CENTER;
    [rv.customView addSubview:titleLabel];

    pageIndexLabel = [[UILabel alloc] init];
    [pageIndexLabel setFont:[UIFont fontWithName:fn size:fs]];
    [pageIndexLabel setBackgroundColor:[UIColor clearColor]];
    [pageIndexLabel setTextColor:[self getTheme].controlColor];
    pageIndexLabel.textAlignment=ALIGN_CENTER;
    [self.view addSubview:pageIndexLabel];
    
    secondaryIndexLabel = [[UILabel alloc] init];
    [secondaryIndexLabel setFont:[UIFont fontWithName:fn size:fs]];
    [secondaryIndexLabel setBackgroundColor:[UIColor clearColor]];
    [secondaryIndexLabel setTextColor:[self getTheme].controlColor];
    secondaryIndexLabel.textAlignment=ALIGN_CENTER;
    if ([self isPad]) [self.view addSubview:secondaryIndexLabel];
    
    hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideButton.frame = self.view.bounds;
    [hideButton addTarget:self action:@selector(hideButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hideButton];
    hideButton.hidden = YES;
 
    [self makeFontBox];
    [self makeMenuBox];
    [self makeHighlightBox];
    [self makeColorBox];
    [self makeNoteBox];
    [self makeSearchBox];
    [self makeListView];
    [self makePIBox];
}

-(UIColor*)getMakerColor:(int)colorIndex {
    switch (colorIndex) {
        case 0:
            return [UIColor colorWithRed:238/255.0f green:230/255.0f blue:142/255.0f alpha:1.0f];
            break;
        case 1:
            return [UIColor colorWithRed:218/255.0f green:244/255.0f blue:160/255.0f alpha:1.0f];
            break;
        case 2:
            return [UIColor colorWithRed:172/255.0f green:201/255.0f blue:246/255.0f alpha:1.0f];
            break;
        case 3:
            return [UIColor colorWithRed:249/255.0f green:182/255.0f blue:214/255.0f alpha:1.0f];
            break;
        default:
            return [UIColor colorWithRed:249/255.0f green:182/255.0f blue:214/255.0f alpha:1.0f];
            break;
    }
}

-(BOOL)color:(UIColor*)color isEqual:(UIColor*)anotherColor {
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    float red = components[0];
    float green = components[1];
    float blue = components[2];
    
    const CGFloat* anothers = CGColorGetComponents(anotherColor.CGColor);
    float ared = anothers[0];
    float agreen = anothers[1];
    float ablue = anothers[2];
    
    if (fabs(red-ared)<0.00001 && fabs(blue-ablue)<0.00001 && fabs(green-agreen)<0.00001) {
        return YES;
    }else {
        return NO;
    }
}

-(UIImage*)getMarkerByColor:(UIColor*)color {
    if ([self color:color isEqual:[UIColor colorWithRed:238/255.0f green:230/255.0f blue:142/255.0f alpha:1.0f]]) {
        return [UIImage imageNamed:@"markeryellow.png"];
    }else if ([self color:color isEqual:[UIColor colorWithRed:218/255.0f green:244/255.0f blue:160/255.0f alpha:1.0f]]) {
        return [UIImage imageNamed:@"markergreen.png"];
    }else if ([self color:color isEqual:[UIColor colorWithRed:172/255.0f green:201/255.0f blue:246/255.0f alpha:1.0f]]) {
        return [UIImage imageNamed:@"markerblue.png"];
    }else if ([self color:color isEqual:[UIColor colorWithRed:249/255.0f green:182/255.0f blue:214/255.0f alpha:1.0f]]) {
        return [UIImage imageNamed:@"markerred.png"];
    }else {
        return [UIImage imageNamed:@"markeryellow.png"];
    }
}

-(int)getMarkerIndexByColor:(unsigned int)highlightColor {
    for (int i=0; i<4; i++) {
        UIColor* mc = [self getMakerColor:i];
        unsigned int uc = [self intFromColor:mc];
        if (highlightColor==uc) return i;
    }
    return 0;    
}

-(UIImage*)getNoteIconImageByIndex:(int)index {
    UIImage* image;
    if (index==0) {
        image = [UIImage imageNamed:@"yellowMemo.png"];
    }else if (index==1) {
        image = [UIImage imageNamed:@"greenMemo.png"];
    }else if (index==2) {
        image = [UIImage imageNamed:@"blueMemo.png"];
    }else if (index==3) {
        image = [UIImage imageNamed:@"redMemo.png"];
    }else {
        image = [UIImage imageNamed:@"yellowMemo.png"];
    }
    return image;
}

-(UIImage*)getNoteIconImageByHighlightColor:(unsigned int)highlightColor {
    int index = [self getMarkerIndexByColor:highlightColor];
    return [self getNoteIconImageByIndex:index];
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


-(void)makeFontBox {
    for (NSString* family in [UIFont familyNames])
    {
//        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
//            NSLog(@"  %@", name);
        }
    }
    
    int y = 0;
	int ih = 40; // The height of font item
    int fontIndex = 0;
	int selectedFontOffsetY = 0;
    
    NSArray *fonts = [NSArray arrayWithObjects:@"Book Fonts",@"Courier",@"Arial",@"Times New Roman",@"American Typewriter",@"Marker Felt",@"Zapfino",@"Mayflower Antique",@"Underwood Champion",nil];  // @"MayflowerAntique",@"UnderwoodChampion" are custom fonts.
    fontBox = [[UIView alloc]initWithFrame:CGRectMake(0,50,320,260)];
    UIImageView* fontBoxImageView = [[UIImageView alloc]initWithFrame:fontBox.bounds];
    fontBoxImageView.image = [UIImage imageNamed:@"fontBox.png"];
    [fontBox addSubview:fontBoxImageView];
    brightSlider = [[UISlider alloc]initWithFrame:CGRectMake(95,34,130,35)];
    [fontBox addSubview:brightSlider];
    brightSlider.minimumValue = 0.0;
    brightSlider.maximumValue = 1.0;
    brightSlider.continuous = YES;
    [brightSlider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
    decreseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [decreseButton addTarget:self action:@selector(decreseDown:) forControlEvents:UIControlEventTouchDown];
    [decreseButton addTarget:self action:@selector(decresePressed:) forControlEvents:UIControlEventTouchUpInside];
    decreseButton.frame = CGRectMake(41,75,113,32);
    [fontBox addSubview:decreseButton];
    increseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [increseButton addTarget:self action:@selector(increseDown:) forControlEvents:UIControlEventTouchDown];
    [increseButton addTarget:self action:@selector(incresePressed:) forControlEvents:UIControlEventTouchUpInside];
    increseButton.frame = CGRectMake(167,75,114,31);
    [fontBox addSubview:increseButton];
    fontScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(43,118,237,108)];
    [fontBox addSubview:fontScrollView];

    for (NSString * fontName in fonts) {
        UIFont * font = [UIFont fontWithName:fontName size:18.0];
        NSString * temp = [NSString stringWithFormat:@"%@", fontName];
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10,y,237,ih)];
        [button setTitle:temp forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:20.0f/255.0f green:40.0f/255.0f blue:230.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
        if ([fontName isEqualToString:setting.fontName]) {
            [button setSelected:YES];
            selectedFontOffsetY = y;
            currentSelectedFontIndex = fontIndex;
            currentSelectedFontButton = button;
        }
        button.titleLabel.font = font;
        button.showsTouchWhenHighlighted = YES;
        [button addTarget:self action:@selector(fontNameButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = fontIndex;
        [fontScrollView addSubview:button];        
        fontIndex++;
        y+=ih;
    }
    
    fontScrollView.contentSize = CGSizeMake(237, y);
	fontScrollView.contentOffset = CGPointMake(0,selectedFontOffsetY-50);
    [self.view addSubview:fontBox];
    fontBox.hidden = YES;
}

-(void)showUIControls {
    homeButton.hidden = NO;
    listButton.hidden = NO;
    fontButton.hidden = NO;
    searchButton.hidden = NO;
    slider.hidden = NO;
    dotted.hidden = NO;
    isUIControlsShown = YES;
    [rv refresh];
}

-(void)hideUIControls {
    homeButton.hidden = YES;
    listButton.hidden = YES;
    fontButton.hidden = YES;
    searchButton.hidden = YES;
    slider.hidden = YES;
    dotted.hidden = YES;
    isUIControlsShown = NO;
    [rv refresh];
}

-(void)makeMenuBox {
    @autoreleasepool {
        menuBox = [[UIView alloc]initWithFrame: CGRectMake(0,0,124,37)];
        menuBox.layer.cornerRadius = 10;
        menuBox.layer.masksToBounds = YES;
        
        UIImageView* bodyView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"body.png"]];
        bodyView.contentMode = UIViewContentModeScaleToFill;
        
        [menuBox addSubview:bodyView];
        
        upArrow = [[ArrowView alloc]init];
        upArrow.backgroundColor = [UIColor clearColor];
        upArrow.upSide = YES;
        upArrow.frame = CGRectMake(0,0,20,20);
        
        downArrow = [[ArrowView alloc]init];
        downArrow.backgroundColor = [UIColor clearColor];
        downArrow.upSide = NO;
        downArrow.frame = CGRectMake(0,0,20,20);
        
        [self.view addSubview:upArrow];
        [self.view addSubview:downArrow];
        upArrow.hidden = YES;
        downArrow.hidden = YES;
        
        int sideWidth = 12;
        
        UIButton* highlightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [highlightButton setTitle:@"Highlight" forState:UIControlStateNormal];
        highlightButton.frame = CGRectMake(0,0,90,36);
        highlightButton.backgroundColor = [UIColor clearColor];
        highlightButton.tag = 21;
        [highlightButton addTarget:self action:@selector(highlightPressed:) forControlEvents:UIControlEventTouchUpInside];
        [menuBox addSubview:highlightButton];
        
        UIButton* noteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [noteButton setTitle:@"Note" forState:UIControlStateNormal];
        noteButton.frame = CGRectMake(0,0,60,36);
        noteButton.backgroundColor = [UIColor clearColor];
        [noteButton addTarget:self action:@selector(notePressed:) forControlEvents:UIControlEventTouchUpInside];
        noteButton.tag = 21;
        [menuBox addSubview:noteButton];
        
        int sx = 13;
        int menuWidth = 0;
        
        UIImageView* seperatorView;
        for (UIView* view in [menuBox subviews]) {
            if (view.tag ==21) {
                UIButton* button = (UIButton*)view;
                view.frame = CGRectMake(sx,0,view.frame.size.width,view.frame.size.height);
                [button setBackgroundColor:[UIColor colorWithRed:20.0f/255.0f green:40.0f/255.0f blue:230.0f/255.0f alpha:0.8f] forState:UIControlStateHighlighted];
                [button setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
                sx = sx+view.frame.size.width;
                seperatorView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"seperator.png"]];
                seperatorView.frame = CGRectMake(sx,0,2,37);
                [menuBox addSubview:seperatorView];
                sx = sx+2;
                menuWidth = sx+sideWidth;
            }
        }
        [seperatorView removeFromSuperview];
        
        CGRect menuFrame = CGRectMake(0,0,menuWidth,37);
        
        menuBox.bounds = menuFrame;
        menuBox.frame = menuBox.bounds;
        bodyView.frame = menuBox.bounds;
        [self.view addSubview:menuBox];
        
        menuBox.hidden = YES;
    }
}

-(void)makeHighlightBox {
    @autoreleasepool {        
        highlightBox = [[UIView alloc]initWithFrame: CGRectMake(0,0,190,37)];
        highlightBox.layer.cornerRadius = 10;
        highlightBox.layer.masksToBounds = YES;
        highlightBox.backgroundColor = currentColor;
        highlightBox.alpha = 0.85f;
        highlightBox.layer.borderColor = [[self darkerColorForColor:currentColor] CGColor];
        highlightBox.layer.borderWidth = 0.5f;

        
        UIButton* colorChooserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [colorChooserButton setImage:[UIImage imageNamed:@"colorChooser.png"] forState:UIControlStateNormal];
        [colorChooserButton addTarget:self action:@selector(colorPressed:) forControlEvents:UIControlEventTouchUpInside];
        [colorChooserButton setContentMode:UIViewContentModeCenter];
        colorChooserButton.showsTouchWhenHighlighted = YES;
        colorChooserButton.adjustsImageWhenHighlighted = YES;
        [highlightBox addSubview:colorChooserButton];
        
        UIButton* trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [trashButton setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
        [trashButton addTarget:self action:@selector(trashPressed:) forControlEvents:UIControlEventTouchUpInside];
        [trashButton setContentMode:UIViewContentModeCenter];
        trashButton.showsTouchWhenHighlighted = YES;
        trashButton.adjustsImageWhenHighlighted = YES;
        [highlightBox addSubview:trashButton];
        
        
        UIButton* memoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [memoButton setImage:[UIImage imageNamed:@"memo.png"] forState:UIControlStateNormal];
        [memoButton addTarget:self action:@selector(noteInHighlightBoxPressed:) forControlEvents:UIControlEventTouchUpInside];
        [memoButton setContentMode:UIViewContentModeCenter];
        memoButton.alpha = 0.95f;
        memoButton.showsTouchWhenHighlighted = YES;
        memoButton.adjustsImageWhenHighlighted = YES;
        [highlightBox addSubview:memoButton];
        
        UIButton* saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [saveButton setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(savePressed:) forControlEvents:UIControlEventTouchUpInside];
        [saveButton setContentMode:UIViewContentModeCenter];
        saveButton.alpha = 0.85f;
        saveButton.showsTouchWhenHighlighted = YES;
        saveButton.adjustsImageWhenHighlighted = YES;
        [highlightBox addSubview:saveButton];
        
        int bs = 30;
        colorChooserButton.frame =      CGRectMake(13+42*0,5,bs,bs);
        trashButton.frame =             CGRectMake(13+42*1,5,bs,bs);
        memoButton.frame =              CGRectMake(13+42*2,7,bs,bs);
        saveButton.frame =              CGRectMake(13+42*3,7,bs,bs);
        highlightBox.hidden = YES;
        
        [self.view addSubview:highlightBox];
    }
}


-(void)makeColorBox {
    @autoreleasepool {
        colorBox = [[UIView alloc]initWithFrame: CGRectMake(0,40,190,37)];
        colorBox.layer.cornerRadius = 10;
        colorBox.layer.masksToBounds = YES;
        colorBox.backgroundColor = currentColor;
        colorBox.alpha = 0.85f;
        colorBox.layer.borderColor = [[self darkerColorForColor:currentColor] CGColor];
        colorBox.layer.borderWidth = 0.5f;

        
        UIImageView* bodyView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"body2.png"]];
        bodyView.contentMode = UIViewContentModeScaleToFill;
        bodyView.alpha = 0.3f;
        
        [colorBox addSubview:bodyView];
        
        UIButton* yellowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [yellowButton setImage:[UIImage imageNamed:@"yellowBox.png"] forState:UIControlStateNormal];
        [yellowButton addTarget:self action:@selector(yellowPressed:) forControlEvents:UIControlEventTouchUpInside];
        [yellowButton setContentMode:UIViewContentModeCenter];
        [colorBox addSubview:yellowButton];
        
        UIButton* greenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [greenButton setImage:[UIImage imageNamed:@"greenBox.png"] forState:UIControlStateNormal];
        [greenButton addTarget:self action:@selector(greenPressed:) forControlEvents:UIControlEventTouchUpInside];
        [greenButton setContentMode:UIViewContentModeCenter];
        [colorBox addSubview:greenButton];
        
        
        UIButton* blueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [blueButton setImage:[UIImage imageNamed:@"blueBox.png"] forState:UIControlStateNormal];
        [blueButton addTarget:self action:@selector(bluePressed:) forControlEvents:UIControlEventTouchUpInside];
        [blueButton setContentMode:UIViewContentModeCenter];
        [colorBox addSubview:blueButton];
        
        UIButton* redButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [redButton setImage:[UIImage imageNamed:@"redBox.png"] forState:UIControlStateNormal];
        [redButton addTarget:self action:@selector(redPressed:) forControlEvents:UIControlEventTouchUpInside];
        [redButton setContentMode:UIViewContentModeCenter];
        [colorBox addSubview:redButton];
        
        int bs = 30;
        yellowButton.frame =    CGRectMake(13+42*0,6,bs,bs);
        greenButton.frame =     CGRectMake(13+42*1,6,bs,bs);
        blueButton.frame =      CGRectMake(13+42*2,6,bs,bs);
        redButton.frame =       CGRectMake(13+42*3,6,bs,bs);
        
        
        colorBox.hidden = YES;
        bodyView.frame = colorBox.frame;
        [self.view addSubview:colorBox];
    }
}

-(void)makeNoteBox {
    @autoreleasepool {
        noteBox = [[UIView alloc]initWithFrame: CGRectMake(10,0,280,230)];
        noteBox.layer.cornerRadius = 10;
        noteBox.layer.masksToBounds = YES;
        noteBox.backgroundColor = currentColor;
        noteBox.alpha = 1.0f;
        noteBox.hidden = YES;
        noteBox.layer.borderColor = [[self darkerColorForColor:currentColor] CGColor];
        noteBox.layer.borderWidth = 0.5f;
        
        tv = [[NoteView alloc]initWithFrame:CGRectMake(10,10,260,210)];
        tv.contentMode = UIViewContentModeRedraw;
        tv.backgroundColor = [UIColor clearColor];
        [tv setDelegate:self];
        tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [noteBox addSubview:tv];
        
        [self.view addSubview:noteBox];
    }
}

-(void)makeSearchBox {
    @autoreleasepool {
        int searchBoxWidth  = 320;
        int searchBoxHeight = 400;
        int sideMargin = 30;
        int searchCancelButtonWidth = 50;
        
        UIColor* boxColor           = [UIColor colorWithRed:241.0f/255.0f green:238.0f/255.0f blue:229.0f/255.0f alpha:1.0f];
        UIColor* innerBoxColor      = [UIColor colorWithRed:246.0f/255.0f green:244.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
        UIColor* outlineColor       = [UIColor colorWithRed:133.0f/255.0f green:105.0f/255.0f blue:75.0f/255.0f alpha:1.0f];
        UIColor* inlineColor        = [UIColor colorWithRed:133.0f/255.0f green:105.0f/255.0f blue:75.0f/255.0f alpha:0.55f];
        UIColor* searchKeyColor     = [UIColor colorWithRed:50.0f/255.0f green:40.0f/255.0f blue:40.0f/255.0f alpha:1.0f];
        float lineThickness = 2.0f;
        
        
        searchBox = [[UIView alloc]initWithFrame:CGRectMake(0,0,searchBoxWidth,searchBoxHeight)];
        searchBox.backgroundColor = boxColor;
        if ([self isPad] ) {
            searchBox.layer.cornerRadius = 10;
            searchBox.layer.masksToBounds = YES;
            searchBox.layer.borderWidth = 2.2f;
        }
        searchBox.layer.borderColor = [outlineColor CGColor];

        searchBox.alpha = 1.0f;
        searchBox.hidden = YES;
        
        
        searchField= [[UITextField alloc] init];
        if ([self isPad]) {
            searchField.frame = CGRectMake(sideMargin,30,searchBoxWidth-sideMargin*2,31);
        }else {
            searchField.frame = CGRectMake(sideMargin,30,searchBoxWidth-sideMargin*2-searchCancelButtonWidth-10,31);
        }        
        searchField.delegate = self;
        searchField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        searchField.textColor = searchKeyColor;
        searchField.textAlignment = UITextAlignmentLeft;
        searchField.font = [UIFont fontWithName:@"Helvetica" size:15];
        searchField.autocorrectionType = UITextAutocorrectionTypeNo;
        searchField.contentVerticalAlignment =UIControlContentVerticalAlignmentCenter;
        searchField.clearsOnBeginEditing = NO;
        searchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        searchField.autocorrectionType = UITextAutocorrectionTypeNo;
        searchField.keyboardType = UIKeyboardTypeURL;
        searchField.returnKeyType = UIReturnKeySearch;
        searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        searchField.rightViewMode = UITextFieldViewModeUnlessEditing;
        searchField.layer.cornerRadius = 17;
        searchField.placeholder=@"Type Words To Search";
        searchField.borderStyle = UITextBorderStyleRoundedRect;//To change borders to rounded
        searchField.layer.borderWidth = lineThickness; //To hide the square corners
        searchField.layer.borderColor = [inlineColor CGColor]; //assigning the default border color
        searchField.backgroundColor = innerBoxColor;
        
        UILabel *magnifyingGlass = [[UILabel alloc] init];
        [magnifyingGlass setText:[[NSString alloc] initWithUTF8String:"\xF0\x9F\x94\x8D"]];
        [magnifyingGlass sizeToFit];
        magnifyingGlass.backgroundColor = innerBoxColor;
        
        [searchField setLeftView:magnifyingGlass];
        [searchField setLeftViewMode:UITextFieldViewModeAlways];
        
        searchCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [searchCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [searchCancelButton addTarget:self action:@selector(searchCancelPressed:) forControlEvents:UIControlEventTouchUpInside];
        [searchCancelButton setTitleColor:outlineColor forState:UIControlStateNormal];
        [searchCancelButton setBackgroundColor:innerBoxColor forState:UIControlStateNormal];
        [searchCancelButton setBackgroundColor:inlineColor forState:UIControlStateHighlighted];
        searchCancelButton.layer.cornerRadius = 5.0f;
        searchCancelButton.layer.borderWidth = 1.5f;
        searchCancelButton.layer.borderColor = [outlineColor CGColor];
        searchCancelButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [searchBox addSubview:searchCancelButton];

        
        searchResultsView = [[UIScrollView alloc]initWithFrame:CGRectMake(sideMargin,90,searchBoxWidth-sideMargin*2,searchBoxHeight - 120)];
        searchResultsView.backgroundColor = innerBoxColor;        
        searchResultsView.layer.borderColor = [inlineColor CGColor];
        searchResultsView.layer.borderWidth = lineThickness;
        [searchBox addSubview:searchResultsView];        
        if ([self isPad]) {
            searchCancelButton.hidden = YES;
        }
        [searchBox addSubview:searchField];
        [self.view addSubview:searchBox];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString* searchKey = textField.text;
    NSLog(@"SearchKey is %@",textField.text);
    [self showSearchBox:NO];
    lastNumberOfSearched = 0;
    [self startSearch:searchKey];
	[textField resignFirstResponder];
	return YES;
}

-(void)searchCancelPressed:(id)sender {
    [self hideSearchBox];
}


-(void)showSearchBox:(BOOL)isCollapsed {
    hideButton.hidden = NO;
    // prevent Rotation
    rotationLocked = YES;
    
    // remove all previous results
//    for (UIView*sv in searchResultsView.subviews) {
//        [sv removeFromSuperview];
//    }
    
    int sx,sy,sw,sh;
    int rightMargin = 50;
    int topMargin = 60;
    int bottomMargin = 50;
    int sideMargin = 30;
    int searchCancelButtonWidth = 50;

    if (isCollapsed) {
        sh = 90;
        if (searchField.text.length==0) [searchField becomeFirstResponder];
    }else {        
        if ([self isPortrait]) {
            topMargin +=10;
            bottomMargin+=10;
        }
        sh = self.view.bounds.size.height - topMargin - bottomMargin;
    }
    
    if ([self isPad]) {
        sx = self.view.bounds.size.width - searchBox.bounds.size.width - rightMargin;
        sw = 320;
        sy = topMargin;
    }else {
        sx = 0;
        sy = 0;
        sw = self.view.bounds.size.width;
        sh = self.view.bounds.size.height;
    }
    
    if (isCollapsed && [self isPad]) {
        searchResultsView.frame = CGRectMake(sideMargin,120,sw-sideMargin*2,sh - 120);
    }else {
        searchResultsView.frame = CGRectMake(sideMargin,90,sw-sideMargin*2,sh - 120);
    }
    
    searchResultsHeight = 0;
    searchBox.frame = CGRectMake(sx,sy,sw,sh);
    searchCancelButton.frame = CGRectMake(searchField.frame.origin.x + searchField.frame.size.width + 10 ,searchField.frame.origin.y,searchCancelButtonWidth,searchField.frame.size.height);

    searchBox.hidden = NO;
}

-(void)hideSearchBox {
    // hide searchBox
    [searchField resignFirstResponder];
    hideButton.hidden = YES;
    [rv stopSearch];
    searchBox.hidden = YES;
    rotationLocked = NO;    
}


-(void)addSearchResult:(SearchResult*)searchResult mode:(int)mode{
    NSString *headerText = @"";
    NSString *contentText = @"";
        
    if (mode==SEARCHRESULT) {
        int ci = searchResult.chapterIndex;
        if ([rv isRTL]) {
            ci = [rv getNumberOfChaptersInBook]-ci-1;
        }
        NSString* chapterTitle = [rv.book getChapterTitle:ci];
        if (chapterTitle==NULL || chapterTitle.length==0) {
            headerText = [NSString stringWithFormat:@"Chapter %d Page %d/%d",ci,searchResult.pageIndex+1,searchResult.numberOfPagesInChapter];
        }else {
            headerText = [NSString stringWithFormat:@"%@ Page %d/%d",chapterTitle,searchResult.pageIndex+1,searchResult.numberOfPagesInChapter];
        }
        contentText = searchResult.text;
        [searchResults addObject:searchResult];
    }else if (mode==SEARCHMORE){
        headerText = @"Search More...";
        contentText = [NSString stringWithFormat:@"%d matches",searchResult.numberOfSearched];
    }else if (mode==SEARCHFINISHED) {
        headerText = @"Search Finished";
        contentText = [NSString stringWithFormat:@"%d matches",searchResult.numberOfSearched];
    }
    
    UIColor* inlineColor        = [UIColor colorWithRed:133.0f/255.0f green:105.0f/255.0f blue:75.0f/255.0f alpha:0.35f];
    UIColor* resultHeadColor    = [UIColor colorWithRed:94.0f/255.0f green:61.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
    UIColor* resultTextColor    = [UIColor colorWithRed:50.0f/255.0f green:40.0f/255.0f blue:40.0f/255.0f alpha:1.0f];

    int rx,ry,rw,rh;
    rx = 0;
    ry = searchResultsHeight;
    rw = searchResultsView.bounds.size.width;
    rh = 90;
    int hx,hy,hw,hh;
    hx = 0;
    hy = 0;
    hw = rw;
    hh = 25;
    int cx,cy,cw,ch;
    cx = 0;
    cy = 25;
    cw = rw;
    ch = 65;
    
    int sm = 15;
    int tm = 5;
    
    UIView *resultView = [[UIView alloc]initWithFrame:CGRectMake(rx,ry,rw,rh)];
    resultView.backgroundColor = [UIColor clearColor];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(hx,hy,hw,hh)];
    headerView.backgroundColor = [UIColor clearColor];    
    UILabel* headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(sm,tm+5,hw-2*sm,hh-tm*2)];
    headerLabel.font = [UIFont systemFontOfSize:13.0];
    headerLabel.text = headerText;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = resultHeadColor;
    [headerView addSubview:headerLabel];
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(cx,cy,cw,ch)];
    contentView.backgroundColor = [UIColor clearColor];
    UILabel* contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(sm,tm,cw-2*sm,ch-tm*2)];
    contentLabel.text = contentText;
    [contentLabel setNumberOfLines:3];
    [contentLabel setLineBreakMode:UILineBreakModeWordWrap];
    [contentView addSubview:contentLabel];
    contentLabel.font = [UIFont systemFontOfSize:13.0];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = resultTextColor;
    
    UIView* lineView = [[UIView alloc]initWithFrame:CGRectMake(rx,cy+ch,rw,1)];
    lineView.backgroundColor = inlineColor;
    
    UIButton* gotoSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gotoSearchButton addTarget:self action:@selector(gotoSearchPressed:) forControlEvents:UIControlEventTouchUpInside];
    gotoSearchButton.frame = resultView.bounds;
    if (mode==SEARCHMORE) {
        gotoSearchButton.tag = -2;
        headerLabel.font = [UIFont systemFontOfSize:17.0];
        contentLabel.font =[UIFont systemFontOfSize:14.0];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.textAlignment = NSTextAlignmentCenter;
        resultView.backgroundColor = [UIColor colorWithRed:0.1 green:0 blue:0 alpha:0.06f];
        
    }else if (mode==SEARCHFINISHED) {
        gotoSearchButton.tag = -1;
        headerLabel.font = [UIFont systemFontOfSize:17.0];
        contentLabel.font =[UIFont systemFontOfSize:14.0];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.textAlignment = NSTextAlignmentCenter;
        resultView.backgroundColor = [UIColor colorWithRed:0.1 green:0.02 blue:0 alpha:0.04f];
    }else {
        gotoSearchButton.tag = [searchResults count]-1;
    }    
    [gotoSearchButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
    [gotoSearchButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.03f] forState:UIControlStateHighlighted];
    
    [resultView addSubview:headerView];
    [resultView addSubview:contentView];
    [resultView addSubview:lineView];
    [resultView addSubview:gotoSearchButton];

    
    [searchResultsView addSubview:resultView];
    searchResultsHeight+=rh;
    searchResultsView.contentSize = CGSizeMake(rw,searchResultsHeight);
    int co = searchResultsHeight-searchResultsView.bounds.size.height;
    if (co<=0) co = 0;    
    searchResultsView.contentOffset  = CGPointMake(0,co);
}

-(void)gotoSearchPressed:(id)sender {
    UIButton* gotoSearchButton = (UIButton*)sender;
    if (gotoSearchButton.tag==-1) {
        [self hideSearchBox];
    }else if (gotoSearchButton.tag==-2) {
        searchResultsHeight-=gotoSearchButton.bounds.size.height;
        searchResultsView.contentSize = CGSizeMake(gotoSearchButton.bounds.size.width,searchResultsHeight);
        [gotoSearchButton removeFromSuperview];
        [rv searchMore];
    }else {
        [self hideSearchBox];
        SearchResult* sr = [searchResults objectAtIndex:gotoSearchButton.tag];
        [rv performSelector:@selector(gotoPageBySearchResult:) withObject:sr afterDelay:0.5f];
    }
}

-(void)yellowPressed:(id)sender {
    UIColor* color = [self getMakerColor:0];
    [self highlightColorChanged:color];
}

-(void)greenPressed:(id)sender {
    UIColor* color = [self getMakerColor:1];
    [self highlightColorChanged:color];
}

-(void)bluePressed:(id)sender {
    UIColor* color = [self getMakerColor:2];
    [self highlightColorChanged:color];
}

-(void)redPressed:(id)sender {
    UIColor* color = [self getMakerColor:3];
    [self highlightColorChanged:color];
}

-(void)highlightColorChanged:(UIColor*)color {
    currentColor = color;
    highlightBox.backgroundColor = color;
    colorBox.backgroundColor = color;
    [rv changeHighlight:currentHighlight color:color];
    [self hideColorBox];    
}

-(void)showMenuBox:(CGRect)startRect endRect:(CGRect)endRect calcOnly:(BOOL)calcOnly{
    menuBox.hidden = NO;
    int offset = 50;
    int topHegith = 50;
    int bottomHeight = 50;
    int menuX = 0;
    int arrowX = 0;
    int arrowWidth = 20;
    int arrowHeight = 20;
    CGRect menuFrame;
    
    downArrow.hidden = YES;
    upArrow.hidden = YES;
    // check upper room for menubox
    if (startRect.origin.y-offset < topHegith) {
        if (endRect.origin.y+endRect.size.height+ 50>bottomHeight) { // there's no enough room. 
            menuX = (endRect.size.width-menuBox.frame.size.width)/2+endRect.origin.x;
            arrowX = (endRect.size.width-arrowWidth)/2+endRect.origin.x;
            upArrow.hidden = NO;
            isUpArrowActive = YES;
            menuFrame = CGRectMake(menuX,endRect.origin.y+endRect.size.height+25,menuBox.bounds.size.width,menuBox.bounds.size.height);
        }
    }else {
        arrowX = (startRect.size.width-arrowWidth)/2+startRect.origin.x;
        menuX = (startRect.size.width-menuBox.frame.size.width)/2+startRect.origin.x;
        menuFrame = CGRectMake(menuX,startRect.origin.y-55,menuBox.bounds.size.width,menuBox.bounds.size.height);
        downArrow.hidden = NO;
        isUpArrowActive = NO;
    }

    
    [upArrow setColor:[UIColor darkGrayColor]];
    [downArrow setColor:[UIColor darkGrayColor]];
    
    if (menuFrame.origin.x < self.view.bounds.size.width*0.1) {
        menuFrame.origin.x = self.view.bounds.size.width*0.1;
    }else if ((menuFrame.origin.x + menuFrame.size.width) > self.view.bounds.size.width*0.9) {
        menuFrame.origin.x = self.view.bounds.size.width*0.9-menuFrame.size.width;
    }
    
    if (arrowX<menuFrame.origin.x+20) arrowX = menuFrame.origin.x+20;
    if (arrowX>menuFrame.origin.x+menuBox.bounds.size.width-40) arrowX = menuFrame.origin.x+menuBox.bounds.size.width-40;

    if (isUpArrowActive) {
        upArrow.frame = CGRectMake(arrowX,menuFrame.origin.y-arrowHeight+4,arrowWidth,arrowHeight);
    }else {
        downArrow.frame = CGRectMake(arrowX,menuFrame.origin.y+menuFrame.size.height-4,arrowWidth,arrowHeight);
    }   

    menuBox.frame = menuFrame;
    if (calcOnly) {
        downArrow.hidden = YES;
        upArrow.hidden = YES;
        menuBox.hidden = YES;
    }

}

-(void)showHighlightBox {
    int hx = (menuBox.frame.size.width - highlightBox.frame.size.width)/2+menuBox.frame.origin.x;
    CGRect highlightFrame = CGRectMake(hx,menuBox.frame.origin.y,highlightBox.frame.size.width,highlightBox.frame.size.height);
    highlightBox.backgroundColor = currentColor;
    highlightBox.frame = highlightFrame;
    highlightBox.hidden = NO;
    if (isUpArrowActive) {
        upArrow.hidden = NO;
        [upArrow setColor:currentColor];
    }else {
        downArrow.hidden = NO;
        [downArrow setColor:currentColor];
    }
}

-(void)showHighlightBox:(CGRect)startRect endRect:(CGRect)endRect {
    [self showMenuBox:startRect endRect:endRect calcOnly:YES];
    [self showHighlightBox];
}

-(void)showColorBox {
    colorBox.frame = highlightBox.frame;
    highlightBox.hidden = YES;
    colorBox.backgroundColor = currentColor;    
    colorBox.hidden = NO;
    if (isUpArrowActive) {
        upArrow.hidden = NO;
        [upArrow setColor:currentColor];
    }else {
        downArrow.hidden = NO;
        [downArrow setColor:currentColor];
    }
}

-(void)highlightPressed:(id)sender {
    [self hideMenuBox];
    [self showHighlightBox];
    [rv makeSelectionHighlight:currentColor];
}

// called from the button in black menuBox
-(void)notePressed:(id)sender {
    [self hideMenuBox];
    [rv makeSelectionHighlight:currentColor];
    [self showNoteBox];
}


-(void)showNoteBox {
    [rv setMenuControllerEnabled:YES];
    CGRect startRect = [rv getStartRectFromHighlight:currentHighlight];
    CGRect endRect = [rv getEndRectFromHighlight:currentHighlight];
    hideButton.frame = self.view.bounds;
    hideButton.hidden = NO;
    int topHegith = 50;
    int bottomHeight = 50;
    int noteX,noteY,noteWidth,noteHeight;
    noteWidth = 280;
    noteHeight= 230;
    int arrowWidth = 20;
    int arrowHeight = 20;
    int arrowX,arrowY;
    CGRect noteFrame;
    
    upArrow.hidden = YES;
    downArrow.hidden = YES;
    [upArrow setColor:currentColor];
    [downArrow setColor:currentColor];

    int delta = 60;
    
    if ([self isPad]) { // iPad
        BOOL toDownSide;
        CGRect targetRect;
        // detect there's room in top side
        if ((startRect.origin.y - noteHeight)<topHegith) {
            toDownSide = YES;  // reverse case
            targetRect = endRect;
            upArrow.hidden = NO;
        }else {
            toDownSide = NO;   // normal case
            targetRect = startRect;
            downArrow.hidden = NO;
        }
        
        if (![self isPortrait]) { // landscape mode
            if ([rv isDoublePaged]) { // double Paged mode
                // detect whether highlight is on left side or right side.
                if (targetRect.origin.x < self.view.bounds.size.width/2) {
                    noteX = (self.view.bounds.size.width/2-noteWidth)/2;
                }else {
                    noteX = (self.view.bounds.size.width/2-noteWidth)/2 + self.view.bounds.size.width/2  ;
                }
            }else {
                noteX = (targetRect.size.width-noteWidth)/2+targetRect.origin.x;
            }
        }else { // portrait mode
            noteX = (targetRect.size.width-noteWidth)/2+targetRect.origin.x;
        }
        if (noteX+noteWidth>self.view.bounds.size.width*0.9) noteX = self.view.bounds.size.width*0.9 - noteWidth;
        if (noteX<self.view.bounds.size.width*.1) noteX = self.view.bounds.size.width*.1;
        arrowX = (targetRect.size.width-arrowWidth)/2+targetRect.origin.x;
        if (arrowX<noteX+10) arrowX = noteX+10;
        if (arrowX>noteX+noteWidth-40) arrowX = noteX+noteWidth-40;
        // set noteY according to isDownSide flag.
        if (!toDownSide) { // normal case - test ok
            noteY = targetRect.origin.y - noteHeight-10;
            arrowY = noteY + noteHeight-5;
            downArrow.frame = CGRectMake(arrowX,arrowY,arrowWidth,arrowHeight);
        }else { // normal case
            noteY = targetRect.origin.y + delta;
            arrowY = noteY-20;
            upArrow.frame = CGRectMake(arrowX,arrowY,arrowWidth,arrowHeight);
        }
    }else { // in case of iPhone, coordinates are fixed.
        if ([self isPortrait]) {
            noteY = (self.view.bounds.size.height - noteBox.frame.size.height)/2;
        }else {
            noteY = (self.view.bounds.size.height - noteBox.frame.size.height)/2;
            noteHeight = 150;
            noteWidth = 500;
        }
        noteX = (self.view.bounds.size.width - noteWidth)/2;
    }    

    noteFrame = CGRectMake(noteX,noteY,noteWidth,noteHeight);
    noteBox.frame = noteFrame;
    noteBox.backgroundColor = currentColor;
    noteBox.hidden = NO;
}

-(void)keyFrameChanged:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    CGRect keyboardEndFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
//    NSLog(@"keyFrameChanged");
    isKeyboardShown = !isKeyboardShown;
    // Animate view with keyboardEndFrame data
}

-(void)keyboardWillShow:(NSNotification *)notification {
//    NSLog(@"Keyboard Show");
    isKeyboardShown = YES;
    oldNoteFrame = noteBox.frame;
    CGRect noteFrame = noteBox.frame;
    if (![self isPad]) {
        if ([self isPortrait]) {
            if (noteFrame.origin.y+noteFrame.size.height>(self.view.bounds.size.height-216)) {            
            noteFrame = CGRectMake(noteFrame.origin.x,(self.view.bounds.size.height-noteFrame.size.height-216-20),noteFrame.size.width,noteFrame.size.height);
            }
        }else {
            if (noteFrame.origin.y+noteFrame.size.height>(self.view.bounds.size.height-162)) {
            noteFrame = CGRectMake(noteFrame.origin.x,(self.view.bounds.size.height-noteFrame.size.height-162-20),noteFrame.size.width,noteFrame.size.height);
            }
        }
    }else {
        if ([self isPortrait]) {
            if (noteFrame.origin.y+noteFrame.size.height>(self.view.bounds.size.height-264)) {
                noteFrame = CGRectMake(noteFrame.origin.x,(self.view.bounds.size.height-noteFrame.size.height-264-20),noteFrame.size.width,noteFrame.size.height);
            }
        }else {
            if (noteFrame.origin.y+noteFrame.size.height<(self.view.bounds.size.height-352)) {
                noteFrame = CGRectMake(noteFrame.origin.x,(self.view.bounds.size.height-noteFrame.size.height-352-20),noteFrame.size.width,noteFrame.size.height);
            }
        }
        
    }
    noteBox.frame = noteFrame;
}

-(void)keyboardWillHide:(NSNotification *)notification {
    isKeyboardShown = NO;
//    NSLog(@"Keyboard Hide");
    noteBox.frame = oldNoteFrame;
}

-(void)saveNote {
    if (tv.text!=nil || tv.text!=0) {
        int uc = currentHighlight.highlightColor;
        UIColor* hc;
        if (uc==0) {
            hc = [self getMakerColor:0];
        }else {
            hc = UIColorFromRGB(currentHighlight.highlightColor);
        }
        currentHighlight.note = tv.text;
        currentHighlight.isNote = YES;
        [rv changeHighlight:currentHighlight color:hc note:tv.text];
    }
}


-(void)hideNoteBox {
    noteBox.hidden = YES;
    upArrow.hidden = YES;
    downArrow.hidden = YES;
    [self saveNote];
    tv.text = nil;
    [tv resignFirstResponder];
    [rv setMenuControllerEnabled:NO];
}

-(void)hideNoteBoxWithoutSave {
    noteBox.hidden = YES;
    upArrow.hidden = YES;
    downArrow.hidden = YES;
    tv.text = nil;
}

-(void)colorPressed:(id)sender {
    [self hideHighlightBox];
    [self showColorBox];    
}

-(void)trashPressed:(id)sender {
    [rv deleteHightlight:currentHighlight];
    [self hideHighlightBox];
}

// the note button inside highlightBox is pressed
-(void)noteInHighlightBoxPressed:(id)sender {
    [self hideHighlightBox];
    tv.text = currentHighlight.note;
    [self showNoteBox];
}

-(void)savePressed:(id)sender {
    
}

-(void)showFontBox {
    hideButton.frame = self.view.bounds;
    hideButton.hidden = NO;
    fontBox.hidden = NO;
    
    brightSlider.value = self.setting.brightness;
}

-(void)hideButtonPressed:(id)sender {
    NSLog(@"hideButtonPressed");
    [self hideFontBox];
    if (!noteBox.hidden) {
        if (isKeyboardShown) {
            [self.view endEditing:YES];
            return;
        }else {
            [self hideNoteBox];
        }
    }
    if (!searchBox.hidden) {
        [self hideSearchBox];
    }
    hideButton.hidden = YES;
}

-(void)hideFontBox {
    if (!fontBox.hidden) fontBox.hidden = YES;
}

-(void)hideMenuBox {
    if (!menuBox.hidden) {
        menuBox.hidden = YES;
        upArrow.hidden = YES;
        downArrow.hidden = YES;
    }
}

-(void)hideHighlightBox {
    if (!highlightBox.hidden) {
        highlightBox.hidden = YES;
        upArrow.hidden = YES;
        downArrow.hidden = YES;
    }
}

-(void)hideColorBox {
    if (!colorBox.hidden) {
        colorBox.hidden = YES;
        upArrow.hidden = YES;
        downArrow.hidden = YES;
    }
}

-(void)fontNameButtonClick:(id)sender {
	[currentSelectedFontButton setSelected:NO];
	UIButton *button = (UIButton*)sender;
	[button setSelected:YES];
	
	NSString *fontName = button.titleLabel.text;
	setting.fontName = fontName;
	currentSelectedFontButton = button;
	currentSelectedFontIndex = button.tag;
    if ([fontName isEqualToString:@"Book Fonts"]) fontName = @"";
    [rv changeFontName:fontName fontSize:[self getRealFontSize:setting.fontSize]];
}

-(IBAction)brightnessChanged:(UISlider *)sender {
    setting.brightness = sender.value;
    [[UIScreen mainScreen] setBrightness: setting.brightness];
}


-(void)decreseDown:(id)sender {
    decreseButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1];
}

-(void)decresePressed:(id)sender {
    decreseButton.backgroundColor = [UIColor clearColor];
    [self decreseFontSize];
}

-(void)increseDown:(id)sender {
    increseButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1];
}

-(void)incresePressed:(id)sender {
    increseButton.backgroundColor = [UIColor clearColor];
    [self increseFontSize];
}

-(void)increseFontSize {
    NSString* fontName = setting.fontName;
    if ([fontName isEqualToString:@"Book Fonts"]) fontName = @"";
    if (self.setting.fontSize!=4) {
        self.setting.fontSize++;
        [rv changeFontName:fontName fontSize:[self getRealFontSize:setting.fontSize]];
    }
}

-(void)decreseFontSize {
    NSString* fontName = setting.fontName;
    if ([fontName isEqualToString:@"Book Fonts"]) fontName = @"";
    if (self.setting.fontSize!=0) {
        self.setting.fontSize--;
        [rv changeFontName:fontName fontSize:[self getRealFontSize:setting.fontSize]];
    }
}

-(void)homePressed:(id)sender {
    if (!isInitialized) return;
    [ad updateBookPosition:self.bookInformation];
    [ad updateSetting:self.setting];
    rv.dataSource = nil;
    rv.delegate = nil;
    [rv removeFromParentViewController];
    [self dismissModalViewControllerAnimated:YES];
    [rv destroy];   // destroy rv explicitly.
    rv = nil;
}

BOOL bookHidden = NO;
-(void)listPressed:(id)sender {
    if (listView.hidden) [self showListView];
    else [self hideListView];
    
    
//    [rv gotoPageByChapterIndex:19 hashLocation:@"JOB-CH18"];
}

-(void)dumpHighlights {
    PageInformation*pi = [rv getPageInformation];
    highlightsInPage = pi.highlightsInPage;
    for (int i=0; i<[highlightsInPage count]; i++) {
        Highlight* highlight = [highlightsInPage objectAtIndex:i];
        if (highlight.isNote && highlight.note.length!=0) {
            NSLog(@"highlight is Note %@",highlight.note);
        }
    }
}


-(void)fontPressed:(id)sender {
    NSLog(@"fontPressed");
    [self showFontBox];
}


-(void)searchPressed:(id)sender {
    [self showSearchBox:YES];
}


-(void)bookmarkPressed:(id)sender {
    NSLog(@"bookmarkPressed");
}

-(void)showPIBox {
    piBox.hidden = NO;
    piArrow.hidden = NO;
    
}

-(void)hidePIBox {
    piBox.hidden = YES;
    piArrow.hidden = YES;
}

-(void)makePIBox {
    piBox = [[UIView alloc]init];
    piBox.frame = CGRectMake(0,0,220,57);
    UIView* guideView = [[UIView alloc]initWithFrame: CGRectMake(0,0,piBox.frame.size.width,37)];
    guideView.backgroundColor = [UIColor darkGrayColor];
    guideView.layer.cornerRadius = 10;
    guideView.layer.masksToBounds = YES;
    
    guideView.layer.borderColor = [[UIColor darkGrayColor]CGColor];
    guideView.layer.borderWidth = 0.5f;
    
    piLabel = [[UILabel alloc]init];
    piLabel.textColor = [UIColor whiteColor];
    piLabel.frame = CGRectMake(5,0,piBox.frame.size.width-10,37);
    piLabel.font = [UIFont systemFontOfSize:13.0];
    piLabel.backgroundColor = [UIColor clearColor];
    piLabel.textAlignment = NSTextAlignmentCenter;

    
    piArrow = [[ArrowView alloc]init];
    piArrow.backgroundColor = [UIColor clearColor];
    piArrow.upSide = NO;
    piArrow.frame = CGRectMake(piBox.frame.origin.x+guideView.frame.size.width/2,piBox.frame.origin.y+guideView.frame.size.height,20,20);
    [piArrow setColor:[UIColor darkGrayColor]];
    piArrow.hidden = YES;
    [piBox addSubview:guideView];
    [self.view addSubview:piBox];
    [self.view addSubview:piArrow];
    [piBox addSubview:piLabel];    
    piBox.hidden = YES;
}


-(void)movePIBox {
    PageInformation* pi = [rv getPageInformationAtPagePositionInBook:slider.value];
    int ci = pi.chapterIndex;
    NSString *caption;
    if ([rv isRTL]) {
        ci = pi.numberOfChaptersInBook-ci-1;
        caption = [rv.book getChapterTitle:ci];
    }else {
        caption = [NSString stringWithFormat:@"%@",pi.chapterTitle];
    }
    if (slider.value==1.0f && ![rv isRTL]) {
        piLabel.text = @"The End";
    }else if (slider.value==0.0f && [rv isRTL]) {
        piLabel.text = @"The End";
    }else if (pi.chapterTitle==nil) {
        piLabel.text = [NSString stringWithFormat:@"Chapter %dth",ci];
    }else {
        piLabel.text = caption;
    }
    int tx,delta;
    int px,py,pw,ph;
    int sx = [self xPositionFromSlider:slider];
    pw = piBox.frame.size.width;
    ph = piBox.frame.size.height;
    py = slider.frame.origin.y-50;
    px = (sx-pw/2);
    tx = px;
    
    
    if (px<self.view.bounds.size.width*0.01) {
        px = self.view.bounds.size.width*.01;
        piArrow.frame = CGRectMake(tx,piArrow.frame.origin.y,piArrow.frame.size.width,piArrow.frame.size.height);
    }
    
    if (px+pw>self.view.bounds.size.width*.99) {
        px = self.view.bounds.size.width*.99 - pw;
        delta = tx-px;
    }
    
    piBox.frame = CGRectMake(px, py, pw, ph);
    piArrow.frame = CGRectMake(sx-10,py+30,20,20);
    
}

-(float)xPositionFromSlider:(UISlider *)aSlider; {
    float sliderRange = aSlider.frame.size.width - aSlider.currentThumbImage.size.width;
    float sliderOrigin = aSlider.frame.origin.x + (aSlider.currentThumbImage.size.width / 2.0);
    
    float sliderValueToPixels = (((aSlider.value-aSlider.minimumValue)/(aSlider.maximumValue-aSlider.minimumValue)) * sliderRange) + sliderOrigin;
    
    return sliderValueToPixels;
}

-(void)sliderDragStarted:(id)sender {
    [self showPIBox];
    [self movePIBox];
}

-(IBAction)sliderValueChanged:(UISlider *)sender {
    UISlider* sld = (UISlider*)sender;
    [self movePIBox];
}

-(void)sliderDragEnded:(id)sender {
    UISlider* sld = (UISlider*)sender;    
    [self hidePIBox];
    [rv gotoPageByPagePositionInBook:sld.value animated:NO];
}



- (void)dragMoving:(UIControl *)c withEvent:ev {
//    UITouch *touch = [[ev allTouches] anyObject];
//    CGPoint touchPoint = [touch locationInView:self.view];
//    sliderLabe.frame = CGRectMake(touchPoint.x,250, 270, 40);
//
}

-(void)recalcFrames {
    hideButton.frame = self.view.bounds;
    float bw = 42,bh = 42;
    float vw = self.view.bounds.size.width;
    float vh = self.view.bounds.size.height;
    float lm = 50;
    float rm = 100;
    float tm = 25;
    float bm = vh*.085f;
    
    float mx = 170;
    
    if ([self isPad]) {
        if ([self isPortrait]) {
            homeButton.frame    = CGRectMake(lm+40*0-5,tm,bw,bh);
            listButton.frame    = CGRectMake(lm+40*1,tm,bw,bh);
            fontButton.frame    = CGRectMake(vw-rm-40*2,tm,bw,bh);
            searchButton.frame  = CGRectMake(vw-rm-40*1,tm,bw,bh);
            bookmarkRect= CGRectMake(vw-rm-40*0+13,tm+4,bw,bh);
            
            authorLabel.hidden = YES;
            secondaryIndexLabel.hidden = YES;
            dotted.frame =      CGRectMake(lm,vh-bm,vw-lm-rm,12);
            slider.frame =      CGRectMake(lm,vh-bm-11,vw-lm-rm,35);
            titleLabel.frame = CGRectMake(vw/2.9, tm,vw/4,30);
            pageIndexLabel.frame =      CGRectMake(vw/2.9,        vh-bm*.9,vw/4,30);
            
            fontBox.frame = CGRectMake(vw-fontBox.bounds.size.width-50,tm+30,fontBox.frame.size.width,fontBox.frame.size.height);
        }else {
            lm = 75;
            rm = 100;
            mx = 200;
            homeButton.frame    = CGRectMake(lm+40*0,tm,bw,bh);
            listButton.frame    = CGRectMake(lm+40*1,tm,bw,bh);
            fontButton.frame    = CGRectMake(vw-rm-40*2,tm,bw,bh);
            searchButton.frame  = CGRectMake(vw-rm-40*1,tm,bw,bh);
            bookmarkRect= CGRectMake(vw-rm-40*0-6,tm+4,bw,bh);
            
            dotted.frame =      CGRectMake(lm,vh-bm,vw-lm-rm,12);
            slider.frame =      CGRectMake(lm,vh-bm-11,vw-lm-rm,35);
            
            authorLabel.hidden = NO;
            if (ad.setting.doublePaged) {
                secondaryIndexLabel.hidden = NO;
                authorLabel.hidden = NO;
                authorLabel.frame = CGRectMake(vw/8, tm,vw/4,30);
                titleLabel.frame = CGRectMake(vw/2+vw/9, tm,vw/4,30);
                pageIndexLabel.frame =      CGRectMake(vw/8,        vh-bm*.9,vw/4,30);
                secondaryIndexLabel.frame = CGRectMake(vw/2+vw/9,   vh-bm*.9,vw/4,30);
            }else {
                secondaryIndexLabel.hidden = YES;
                authorLabel.hidden = YES;
                titleLabel.frame = CGRectMake(vw/2.9, tm,vw/4,30);
                pageIndexLabel.frame =      CGRectMake(vw/2.9,        vh-bm*.9,vw/4,30);
            }
            fontBox.frame = CGRectMake(vw-fontBox.bounds.size.width-60,tm+33,fontBox.frame.size.width,fontBox.frame.size.height);
        }
        prevButton.frame    = CGRectMake(mx+40*0,tm,bw,bh);
        playButton.frame    = CGRectMake(mx+40*1,tm,bw,bh);
        stopButton.frame    = CGRectMake(mx+40*2,tm,bw,bh);
        nextButton.frame    = CGRectMake(mx+40*3,tm,bw,bh);

    }else {
        if ([self isPortrait]) {
            tm = 15;
            lm = 18;
            rm = 50;
            NSString* fn = @"Helvetica";
            int fs = 13;
            homeButton.frame    = CGRectMake(lm+38*0    ,tm ,bw ,bh);
            listButton.frame    = CGRectMake(lm+38*1    ,tm+1 ,bw ,bh);
            fontButton.frame    = CGRectMake(vw-rm-38*2 ,tm ,bw ,bh);
            searchButton.frame  = CGRectMake(vw-rm-38*1 ,tm ,bw ,bh);
            bookmarkRect= CGRectMake(vw-rm-38*0+9 ,tm+12 ,bw ,bh);
            
            authorLabel.hidden = YES;
            secondaryIndexLabel.hidden = YES;
            dotted.frame =   CGRectMake(lm,vh-bm-10,vw-lm-rm+10,12);
            slider.frame =   CGRectMake(lm,vh-bm-20,vw-lm-rm+10,35);
            titleLabel.frame = CGRectMake(vw/2.9, tm+2,vw/4,bh);
            pageIndexLabel.frame =      CGRectMake(vw/2.7,        vh-bm*.9,vw/4,30);
            
            prevButton.frame    = CGRectMake(lm+38*0    ,tm+bh-2,bw,bh);
            playButton.frame    = CGRectMake(lm+38*1    ,tm+bh-2,bw,bh);
            stopButton.frame    = CGRectMake(lm+38*2    ,tm+bh-2,bw,bh);
            nextButton.frame    = CGRectMake(lm+38*3    ,tm+bh-2,bw,bh);
            
            fontBox.frame = CGRectMake(vw-fontBox.bounds.size.width,tm+30,fontBox.frame.size.width,fontBox.frame.size.height);
        }else {
            tm = 10;
            lm = 30;
            rm = 60;
            homeButton.frame    = CGRectMake(lm+40*0,tm,bw,bh);
            listButton.frame    = CGRectMake(lm+40*1,tm+1,bw,bh);
            fontButton.frame    = CGRectMake(vw-rm-40*2,tm,bw,bh);
            searchButton.frame  = CGRectMake(vw-rm-40*1,tm,bw,bh);
            bookmarkRect= CGRectMake(vw-rm-40*0+7,tm+10,bw,bh);
            
            dotted.frame =   CGRectMake(lm,vh-bm-10,vw-lm-rm+10,12);
            slider.frame =   CGRectMake(lm,vh-bm-20,vw-lm-rm+10,35);
            
            authorLabel.hidden = YES;
            secondaryIndexLabel.hidden = YES;
            authorLabel.frame = CGRectMake(vw/8, tm,vw/4,bh);
            titleLabel.frame = CGRectMake(vw/2.9, tm+2,vw/4,bh);
            pageIndexLabel.frame =      CGRectMake(vw/2.7,        vh-bm,vw/4,30);
            
            prevButton.frame    = CGRectMake(mx+40*0,tm,bw,bh);
            playButton.frame    = CGRectMake(mx+40*1,tm,bw,bh);
            stopButton.frame    = CGRectMake(mx+40*2,tm,bw,bh);
            nextButton.frame    = CGRectMake(mx+40*3,tm,bw,bh);
            
            fontBox.frame = CGRectMake(vw-fontBox.bounds.size.width,tm+23,fontBox.frame.size.width,fontBox.frame.size.height);
        }
    }
    [dotted setNeedsDisplay];
}

-(void)displayTitles {
    int nc = [rv getNumberOfChaptersInBook];
    for (int i=0; i<nc; i++) {
        NSString* title = [rv.book getChapterTitle:i];
        NSLog(@"%@ for %d",title,i);
    }
}

// called when Bookmark image is tapped 
-(void)reflowableViewController:(ReflowableViewController *)rvc didHitBookmark:(PageInformation *)pageInformation isBookmarked:(BOOL)isBookmarked {
    NSLog(@"didHitBookmark");
    [ad toggleBookmark:pageInformation];
    [rvc refresh];
}

-(void)reflowableViewController:(ReflowableViewController *)rvc didHitLink:(NSString*)urlString {
    NSLog(@"Link:%@ is Hit",urlString);
}

-(void)reflowableViewController:(ReflowableViewController*)rvc didHitLinkForLinearNo:(NSString*)urlString; {
    NSLog(@"Link for ItemRef is linear='no' :%@ is Hit",urlString);
}


-(void)reflowableViewController:(ReflowableViewController *)rvc didHitImage:(NSString*)urlString {
    NSLog(@"Image:%@ is Hit",urlString);
}


-(BOOL)reflowableViewController:(ReflowableViewController*)rvc isBookmarked:(PageInformation*)pageInformation {
    BOOL ret = [ad isBookmarked:pageInformation];
    return ret;
}

/** should return the bookmarked image for rendering */
-(UIImage*)bookmarkImage:(ReflowableViewController*)rvc isBookmarked:(BOOL)isBookmarked{
    if (isBookmarked) {
        return [UIImage imageNamed:@"bookmarked.png"];
    }else {
        if (ad.setting.theme!=2) {
            return [UIImage imageNamed:@"bookmark.png"];
        }else {
            return [UIImage imageNamed:@"bookmarkwhite.png"];
        }
    }
    
}
/** should return the CGRect of the bookmarked image for rendering */
-(CGRect)bookmarkRect:(ReflowableViewController*)rvc isBookmarked:(BOOL)isBookmarked{
    if (isBookmarked) {
        return CGRectMake(bookmarkRect.origin.x-3,bookmarkRect.origin.y-3,24,46);
    }else {
        return CGRectMake(bookmarkRect.origin.x-3,bookmarkRect.origin.y-3,24,24);
    }
}


-(void)viewDidAppear:(BOOL)animated {
    [self recalcFrames];
}


-(void)showMediaUI {
    if ([self isPortrait]) {
        titleLabel.hidden = YES;
    }else {
        if ([self isPad]) {
            authorLabel.hidden = YES;
        }else {
            titleLabel.hidden = YES;
        }        
    }
    [prevButton setHidden:NO];
    [playButton setHidden:NO];
    [stopButton setHidden:NO];
    [nextButton setHidden:NO];
}

-(void)hideMediaUI {
//    authorLabel.hidden = NO;
    titleLabel.hidden = NO;
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

-(void)makeListView {
    listView = [[UIView alloc]init];    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Contents", @"Bookmarks", @"Highlights",nil]];
    segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.tintColor = [UIColor blackColor];
    [segmentedControl addTarget:self
                         action:@selector(segmentSwitch:)
               forControlEvents:UIControlEventValueChanged];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont systemFontOfSize:13.0f], UITextAttributeFont,
                                [UIColor blackColor], UITextAttributeTextColor,
                                nil];
    [[UISegmentedControl appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [listView addSubview:segmentedControl];
    
    [self makeContentsListView];
    [self makeBookmarkListView];
    [self makeHighlightListView];
    
    [self.view addSubview:listView];
    listView.hidden = YES;
}

-(void)makeContentsListView {
    contentsListView = [[UIScrollView alloc]init];
    [listView addSubview:contentsListView];
}


-(void)makeBookmarkListView {
    bookmarkListView = [[UITableView alloc]init];
    bookmarkListView.tag = 100;
    bookmarkListView.dataSource = self;
    bookmarkListView.delegate = self;
    [listView addSubview:bookmarkListView];    
}

-(void)makeHighlightListView {
    highlightListView = [[UITableView alloc]init];
    highlightListView.tag = 101;
    highlightListView.dataSource = self;
    highlightListView.delegate = self;
    [listView addSubview:highlightListView];    
}

-(void)reloadHighlights {
    highlights = [ad fetchAllHighlights:self.bookInformation.bookCode];    
}

-(void)reloadBookmarks {
    bookmarks = [ad fetchAllBookmarks:self.bookInformation.bookCode];
}

-(void)showListView {
    [self hideBoxes];
    [rv hidePages];
    [self hideNoteIcons];
    
    [self reloadBookmarks];
    [self reloadHighlights];
    
    NSLog(@"hi count %d",[highlights count]);
    NSLog(@"bm count %d",[bookmarks count]);
    
    fontButton.hidden = YES;
    searchButton.hidden = YES;
    slider.hidden = YES;
    dotted.hidden = YES;
    
    pageIndexLabel.hidden = YES;
    secondaryIndexLabel.hidden = YES;
    
    int tm = 60;
    int bm = 60;
    listView.frame = CGRectMake(0, tm, self.view.bounds.size.width,self.view.bounds.size.height-(tm+bm));
    if ([self isPad]) {
        if ([rv isDoublePaged]) {
            listView.frame = CGRectMake(self.view.bounds.size.width/2, tm, self.view.bounds.size.width/2,self.view.bounds.size.height-(tm+bm));
        }
    }else {
        tm = 50;
        bm = 20;
        listView.frame = CGRectMake(0, tm, self.view.bounds.size.width,self.view.bounds.size.height-(tm+bm));
    }
    
    NSLog(@"listView %f %f %f %f",listView.frame.origin.x,listView.frame.origin.y,listView.frame.size.width,listView.frame.size.height);
    
    int sw = 250;
    int sy = 10;
    int sh = 30;
    segmentedControl.frame = CGRectMake((listView.frame.size.width-sw)/2,sy,sw, sh);
    segmentedControl.hidden = NO;
    
    listView.hidden = NO;
    [self segmentSwitch:segmentedControl];
}

-(void)showContentsListView {
    int tm = segmentedControl.frame.origin.y+segmentedControl.frame.size.height + 10;
    int bm = 10;
    int lm = 50;
    int rm = 50;
    if (![self isPad]) {
        lm = 15;
        rm = 15;
    }
    contentsListView.frame = CGRectMake(lm,tm,listView.frame.size.width-(lm+rm),listView.frame.size.height-(tm+bm));
    
    for (UIView* view in contentsListView.subviews) {
        [view removeFromSuperview];
    }
    
    int nx = 0;
    int ny;
    int nw = listView.frame.size.width-(lm+rm);
    int nh = 35;

    for (int i=0; i<[rv.book.NavMap count]; i++) {
        NavPoint* np = [rv.book.NavMap objectAtIndex:i];
        ny = nh*i;
        nx = np.depth*30;
        nw = nw - nx;
        UIView* navPointView = [[UIView alloc]initWithFrame:CGRectMake(nx,ny,listView.frame.size.width,nh)];
        navPointView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UILabel* textLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,10,navPointView.frame.size.width-20*2,20)];
        textLabel.text = np.text;
        textLabel.backgroundColor = [UIColor clearColor];
        UIView* lineView = [[UIView alloc]initWithFrame:CGRectMake(0,nh-1,nw,2)];
        lineView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.04];
        UIButton* navPointButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [navPointButton addTarget:self action:@selector(navPointPressed:) forControlEvents:UIControlEventTouchUpInside];
        navPointButton.highlighted  =YES;
        [navPointButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        navPointButton.tag = i;
        NSLog(@"navPointButton tag %d",navPointButton.tag);
        navPointButton.frame = navPointView.bounds;
        [navPointView addSubview:lineView];
        [navPointView addSubview:textLabel];
        [navPointView addSubview:navPointButton];        
        [contentsListView addSubview:navPointView];
    }

    contentsListView.contentSize = CGSizeMake(contentsListView.frame.size.width,nh*[rv.book.NavMap count]);
    contentsListView.hidden = NO;
    bookmarkListView.hidden = YES;
    highlightListView.hidden = YES;
}

-(void)showBookmarkListView {
    int tm = segmentedControl.frame.origin.y+segmentedControl.frame.size.height + 10;
    int bm = 10;
    int lm = 50;
    int rm = 50;
    if (![self isPad]) {
        lm = 15;
        rm = 15;
    } 
    bookmarkListView.frame = CGRectMake(lm,tm,listView.frame.size.width-(lm+rm),listView.frame.size.height-(tm+bm));
    bookmarkListView.backgroundColor = [UIColor clearColor];
    contentsListView.hidden = YES;
    bookmarkListView.hidden = NO;
    highlightListView.hidden = YES;
    
    [bookmarkListView reloadData];
}

-(void)showHighlightListView {
    int tm = segmentedControl.frame.origin.y+segmentedControl.frame.size.height + 10;
    int bm = 10;
    int lm = 50;
    int rm = 50;
    if (![self isPad]) {
        lm = 15;
        rm = 15;
    }
    highlightListView.frame = CGRectMake(lm,tm,listView.frame.size.width-(lm+rm),listView.frame.size.height-(tm+bm));
    highlightListView.backgroundColor = [UIColor clearColor];                                         
    
    contentsListView.hidden = YES;
    bookmarkListView.hidden = YES;
    highlightListView.hidden = NO;
    
    [highlightListView reloadData];
}

-(void)hideListView {
    listView.hidden = YES;
    fontButton.hidden = NO;
    searchButton.hidden = NO;
    slider.hidden = NO;
    dotted.hidden = NO;    
    pageIndexLabel.hidden = NO;
//    secondaryIndexLabel.hidden = NO;
    [rv showPages];
    [self showNoteIcons];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    if (tableView.tag==100) {
        return [bookmarks count];
    }else {
        return [highlights count];
    }    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    int index = [indexPath row];
    if (tableView.tag==100) {
        PageInformation* pi = [bookmarks objectAtIndex:index];
        [ad deleteBookmark:pi];
        [self reloadBookmarks];
        [tableView reloadData];        
    }else {
        Highlight* ht = [highlights objectAtIndex:index];
        [ad deleteHighlight:ht];
        [self reloadHighlights];
        [tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


-(void)segmentSwitch:(id)sender {
    if (listView.hidden) return;
    UISegmentedControl *sc = (UISegmentedControl *) sender;
    NSInteger selectedSegment = sc.selectedSegmentIndex;
    if (selectedSegment == 0) {
        [self showContentsListView];
    }else if (selectedSegment ==1){
        [self showBookmarkListView];
    }else {
        [self showHighlightListView];
    }
}

-(UIColor *)darkerColorForColor:(UIColor *)color {
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.4, 0.0)
                               green:MAX(g - 0.4, 0.0)
                                blue:MAX(b - 0.4, 0.0)
                               alpha:a];
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag==100) {
        return 75;
    }else {
        
        int height = 95;
        
        Highlight* highlight = [highlights objectAtIndex:[indexPath row]];
        if (!highlight.isNote) {
            return height;
        }else {
            CGSize maximumLabelSize = CGSizeMake(tableView.frame.size.width-(20*2),100);
            UIFont* font = [UIFont systemFontOfSize:13.0];
            CGSize expectedLabelSize = [highlight.note sizeWithFont:font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
            height+=expectedLabelSize.height;
            return height;
        }
    }    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *cid;
    cid =  [NSString stringWithFormat:@"%d-%d",tableView.tag,[indexPath row]];
//    cell = [tableView dequeueReusableCellWithIdentifier:cid];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid];
    cell.backgroundColor = [UIColor clearColor];
    
    if (tableView.tag==100) {
        PageInformation* pi = [bookmarks objectAtIndex:[indexPath row]];
        UIView* cellView = [[UIView alloc]init];
        cellView.tag = 77;
        cellView.backgroundColor = [UIColor clearColor];
        UILabel* headerLabel = [[UILabel alloc]init];
        int ci = pi.chapterIndex;
        if ([rv isRTL]) {
            ci = [rv getNumberOfChaptersInBook]-ci-1;
        }
        NSString* title = [rv.book getChapterTitle:ci];
        headerLabel.text = [NSString stringWithFormat:@"%@",title];
        headerLabel.frame = CGRectMake(60,10,tableView.frame.size.width-60,16);
        headerLabel.font = [UIFont systemFontOfSize:14.0];
        headerLabel.backgroundColor = [UIColor clearColor];
        [cellView addSubview:headerLabel];
        int bw = 30; int bh = 60;        
        UIImageView* bookmarkedView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bookmarked.png"]];
        bookmarkedView.frame = CGRectMake(10,10,bw,bh);
        [cellView addSubview:bookmarkedView];
        UILabel *dateLabel = [[UILabel alloc]init];
        dateLabel.font = [UIFont systemFontOfSize:13.0];
        dateLabel.textColor = [UIColor darkGrayColor];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.text = pi.pageDescription;
        dateLabel.frame = CGRectMake(tableView.frame.size.width*.60,52,tableView.frame.size.width,16);
        [cellView addSubview:dateLabel];

        [cell addSubview:cellView];
    }else {
        Highlight* highlight = [highlights objectAtIndex:[indexPath row]];
        UIView* cellView = [[UIView alloc]init];
        cellView.tag = 77;
        cellView.backgroundColor = [UIColor clearColor];
        UILabel* headerLabel = [[UILabel alloc]init];
        int ci = highlight.chapterIndex;
        if ([rv isRTL]) {
            ci = [rv getNumberOfChaptersInBook]-ci-1;
        }
        NSString* title = [rv.book getChapterTitle:ci];
        headerLabel.text = [NSString stringWithFormat:@"%@",title];
        headerLabel.frame = CGRectMake(20,10,tableView.frame.size.width-20*2,16);
        headerLabel.font = [UIFont systemFontOfSize:14.0];
        headerLabel.backgroundColor = [UIColor clearColor];
        [cellView addSubview:headerLabel];
        UILabel* textLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,30,tableView.frame.size.width-(20*2),34)];
        textLabel.text = highlight.text;
        [textLabel setNumberOfLines:2];
        [textLabel setLineBreakMode:UILineBreakModeWordWrap];
        textLabel.font = [UIFont systemFontOfSize:13.0];
        textLabel.backgroundColor = UIColorFromRGB(highlight.highlightColor);
        textLabel.textColor = [UIColor blackColor];
        [cellView addSubview:textLabel];
        UILabel* noteLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        if (highlight.isNote) {
            noteLabel.text = highlight.note;
            noteLabel.font = [UIFont systemFontOfSize:13.0];
            [noteLabel setLineBreakMode:UILineBreakModeWordWrap];
            [noteLabel setNumberOfLines:10];
            CGSize maximumLabelSize = CGSizeMake(tableView.frame.size.width-(20*2),100);
            CGSize expectedLabelSize = [highlight.note sizeWithFont:noteLabel.font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
            NSLog(@"expectedLabelSize is %f %f",expectedLabelSize.width,expectedLabelSize.height);
            noteLabel.frame = CGRectMake(20,70,tableView.frame.size.width-(20*2),expectedLabelSize.height);
            noteLabel.backgroundColor = [UIColor clearColor];
            noteLabel.textColor = [self darkerColorForColor:UIColorFromRGB(highlight.highlightColor)];
            [cellView addSubview:noteLabel];
        }
        UILabel *dateLabel = [[UILabel alloc]init];
        dateLabel.font = [UIFont systemFontOfSize:13.0];
        dateLabel.text = highlight.datetime;
        if (highlight.isNote) {
            dateLabel.frame = CGRectMake(tableView.frame.size.width*.60,noteLabel.frame.origin.y+noteLabel.frame.size.height + 5,tableView.frame.size.width,16);
        }else {
            dateLabel.frame = CGRectMake(tableView.frame.size.width*.60,textLabel.frame.origin.y+textLabel.frame.size.height + 5,tableView.frame.size.width,16);
        }
        [cellView addSubview:dateLabel];
        dateLabel.textColor = [UIColor darkGrayColor];
        dateLabel.backgroundColor = [UIColor clearColor];
        
        cellView.frame = CGRectMake(0,0,tableView.frame.size.width,dateLabel.frame.origin.y + dateLabel.frame.size.height+5);
        [cell addSubview:cellView];        
    }
    return cell;
}

-(void)navPointPressed:(id)sender {
    UIView* iv = (UIView*)sender;
    int index = iv.tag;
    NavPoint* np = NULL;
    np = [rv getNavPoint:index];
    if (np!=NULL) {
        [rv gotoPageByNavPoint:np];
        [self hideListView];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [indexPath row];
    if (tableView.tag==100) {
        PageInformation* pi = [bookmarks objectAtIndex:index];
        [rv gotoPageByPagePositionInBook:pi.pagePositionInBook animated:NO];
        [self hideListView];
    }else {
        Highlight* ht = [highlights objectAtIndex:index];
        [rv gotoPageByHighlight:ht];
        [self hideListView];
    }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)viewDidLoad
{
    [super viewDidLoad];
    @autoreleasepool {
        ad =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
        currentColor = [self getMakerColor:0];
        self.setting = [ad fetchSetting];
        pagings = [[NSMutableArray alloc]init];
        highlightsInPage = [[NSMutableArray alloc]init];
        searchResults = [[NSMutableArray alloc]init];
        [self makeThemes];
        [self hideStatusBar];
        [self makeBookViewer];
        [self makeUI];
        [self makeMediaUI];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
        [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
        isAutoPlaying = YES;
        autoStartPlayingWhenNewPagesLoaded  = YES;
        autoMoveChapterWhenParallesFinished  = YES;
        isLoop = NO;
        [self becomeFirstResponder];
    }
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
    if (rotationLocked || setting.lockRotation) {
        return NO;
    }
    return YES;
}

// iOS 6.0 or Above
- (BOOL)shouldAutorotate {
    if (rotationLocked || setting.lockRotation) {
        return NO;
    }
    return YES;
}


-(void)hideBoxes {
    [self hideMenuBox];
    [self hideFontBox];
    [self hideNoteBoxWithoutSave];
    [self hideHighlightBox];
    [self hideColorBox];
//    [self hideSearchBox];
    [self hideListView];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [self hideListView];
    if (![ad isAbove5]) {
        [rv didRotateFromInterfaceOrientation:interfaceOrientation];
    }
    [self recalcFrames];
    [self hideBoxes];
}

-(NSMutableArray*)reflowableViewController:(ReflowableViewController*)rvc highlightsForChapter:(NSInteger)chapterIndex {
    highlights = [ad fetchHighlights:bookInformation.bookCode chapterIndex:chapterIndex];
    return highlights;
}

-(NSString*)script {
    NSString *script;
    NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"/script" ofType:@"js"];
    script = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:NULL];
    //    script = [NSString stringWithString:@"function changePColor() {\
    var elements=document.getElementsByTagName('p');\
    for (var i=0; i<elements.length; i++) {\
    elements[i].style.color = '#ff0000';\
    }\
    }\
    changePColor();\
    "];
    
    return script;
}

-(NSString*)style {
    NSString* style = @"";
    //    NSString *stylePath = [[NSBundle mainBundle] pathForResource:@"/custom" ofType:@"css"];
    //    style = [NSString stringWithContentsOfFile:stylePath encoding:NSUTF8StringEncoding error:NULL];
    return style;
}

-(NSString*)reflowableViewController:(ReflowableViewController*)rvc scriptForChapter:(NSInteger)chapterIndex {
    return [self script];    
}


-(NSString*)reflowableViewController:(ReflowableViewController*)rvc styleForChapter:(NSInteger)chapterIndex {
    return [self style];
}


-(void)reflowableViewController:(ReflowableViewController*)rvc 
    insertHighlight:(Highlight*)highlight {
    NSLog(@"insert color %d",highlight.highlightColor);
    [ad insertHighlight:highlight];
    currentHighlight = highlight;
}

-(void)reflowableViewController:(ReflowableViewController*)rvc deleteHighlight:(Highlight*)highlight {
    [ad deleteHighlight:highlight];
    [self processNoteIcons];
    [rvc refresh];
}

-(void)reflowableViewController:(ReflowableViewController*)rvc updateHighlight:(Highlight*)highlight {
    [ad updateHighlight:highlight];
    NSLog(@"update color %d",highlight.highlightColor);
    [self processNoteIcons];
    [rvc refresh];
}

-(void)reflowableViewController:(ReflowableViewController*)rvc didSelectRange:(Highlight*)highlight startRect:(CGRect)startRect endRect:(CGRect)endRect{
    currentHighlight = highlight;
    currentStartRect = startRect;
    currentEndRect = endRect;
    [self showMenuBox:startRect endRect:endRect calcOnly:NO];
}


-(void)reflowableViewController:(ReflowableViewController*)rvc didSelectionCanceled:(NSString*)lastSelectedText {
    [self hideMenuBox];
    [self hideHighlightBox];
}

-(void)reflowableViewController:(ReflowableViewController*)rvc didSelectionChanged:(NSString*)selectedText {
    [self hideMenuBox];    
}


-(void)reflowableViewController:(ReflowableViewController*)rvc didDetectTapAtPosition:(CGPoint)position{
    NSLog(@"tap detected");
    if (isUIControlsShown && (menuBox.hidden && colorBox.hidden && highlightBox.hidden)) {
        [self hideUIControls];
    } else {
        [self showUIControls];
    }
    [self hideHighlightBox];
    [self hideColorBox];
}
    

-(void)reflowableViewController:(ReflowableViewController*)rvc didDetectDoubleTapAtPosition:(CGPoint)position{
}

-(void)reflowableViewController:(ReflowableViewController*)rvc didHitHighlight:(Highlight*)highlight atPosition:(CGPoint)position startRect:(CGRect)startRect endRect:(CGRect)endRect{
    currentHighlight = highlight;
    currentColor = UIColorFromRGB(highlight.highlightColor);
    [self showHighlightBox:startRect endRect:endRect];
}


// if [rv setCustomDrawHighlight:YES] then you can draw the highlight.
// since 4.0
-(void)reflowableViewController:(ReflowableViewController*)rvc drawHighlightRect:(CGRect)highlightRect context:(CGContextRef)context highlightColor:(UIColor*)highlightColor highlight:(Highlight*)highlight {
    
    // If you want to draw a just rectangle, uncomment belows
    //    CGRect rectangle = highlightRect;
    //    CGContextSetFillColorWithColor(context, [highlightColor CGColor]);
    //    CGContextFillRect(context, rectangle);
    
    // If you want to draw brush mark, use below.
    UIImage* markerImage = [self getMarkerByColor:highlightColor];
    CGContextDrawImage(context, highlightRect, markerImage.CGImage);
}


-(void)changePageLabels:(PageInformation*)pageInformation{
    int pi,pn;
    if (ad.setting.globalPagination) {
        pi = pageInformation.pageIndexInBook;
        pn = pageInformation.numberOfPagesInBook;
    }else {
        pi = pageInformation.pageIndex;
        pn = pageInformation.numberOfPagesInChapter;
    }
    
    if (isDoublePaged && ![self isPortrait]) { // in case of double paged
        pageIndexLabel.text = [NSString stringWithFormat:@"%d/%d",      (pi*2)+1,(pn)*2];
        secondaryIndexLabel.text = [NSString stringWithFormat:@"%d/%d", (pi*2)+2,(pn)*2];
    }else {
        if (![rv isRTL]) {
            pageIndexLabel.text = [NSString stringWithFormat:@"%d/%d",      pi+1,pn];
        }else {
            pageIndexLabel.text = [NSString stringWithFormat:@"%d/%d",      (pn-pi),pn];
        }
    }
}

-(void)reflowableViewController:(ReflowableViewController*)rvc pageMoved:(PageInformation*)pageInformation{
    info = pageInformation;
    [rvc unselect];
    [self hideListView];
    [self hideFontBox];
    [self hideHighlightBox];
    [self hideColorBox];
    [self hideMenuBox];
    
    double ppb = pageInformation.pagePositionInBook;
    double pageDelta = ((1.0f/pageInformation.numberOfChaptersInBook)/pageInformation.numberOfPagesInChapter);
    if ([rv isRTL]) {
        ppb +=pageDelta;
    }
    slider.value = ppb;

    if (rvc.book.creator.length > 15) {
        rvc.book.creator = [rvc.book.creator substringToIndex:15];
        rvc.book.creator = [rvc.book.creator stringByAppendingString:@".."];
    }
    if (rvc.book.title.length > 15) {
        rvc.book.title = [rvc.book.title substringToIndex:15];
        rvc.book.title = [rvc.book.title stringByAppendingString:@".."];
    }
    authorLabel.text = rvc.book.creator;
    titleLabel.text = rvc.book.title;

    [self changePageLabels:pageInformation];
    [self performSelector:@selector(processNoteIcons) withObject:nil afterDelay:0.0];
    
    self.bookInformation.position = pageInformation.pagePositionInBook;
    
    if (!isInitialized) {
        [self performSelector:@selector(processInitialization) withObject:nil afterDelay:1.0f];
    }

    if (pageInformation.firstCharacterOffsetInPage==NSNotFound) {
        NSLog(@"firstChar... not found");
    }
//    NSLog(@"first char offset %d text length in page%d",pageInformation.firstCharacterOffsetInPage,pageInformation.textLengthInPage);
//    NSLog(@"%@",pageInformation.pageDescription);
//    NSLog(@"chapter Index  %d %@ numberOfPagesInChapter %d numberOfPagesInBook %d",pageInformation.chapterIndex,pageInformation.chapterTitle,pageInformation.numberOfPagesInChapter,pageInformation.numberOfPagesInBook);
    
//    NSString* coverPath = [rv getCoverURL];
//    NSLog(@"%@",coverPath);
}

-(void)processInitialization {
    isInitialized = true;
}

-(void)pageTransitionStarted:(ReflowableViewController*)rvc {
    [self removeNoteIcons];
}

-(void)pageTransitionEnded:(ReflowableViewController*)rvc {
}

-(void)removeNoteIcons {
    [highlightsInPage removeAllObjects];
    for (UIView*view in [self.view subviews]) {
        if (view.tag>=10000) {
            [view removeFromSuperview];
        }
    }
    for (UIView*view in [rv.customView subviews]) {
        if (view.tag>=20000) {
            [view removeFromSuperview];
        }
    }
}

-(void)hideNoteIcons {
    for (UIView*view in [self.view subviews]) {
        if (view.tag>=10000) {
            view.hidden = YES;
        }
    }
    for (UIView*view in [rv.customView subviews]) {
        if (view.tag>=20000) {
            view.hidden = YES;
        }
    }
}

-(void)showNoteIcons {
    for (UIView*view in [self.view subviews]) {
        if (view.tag>=10000) {
            view.hidden =  NO;
        }
    }
    for (UIView*view in [rv.customView subviews]) {
        if (view.tag>=20000) {
            view.hidden = NO;
        }
    }
}


-(void)noteIconPressed:(id)sender {
    [self hideBoxes];
    UIButton* noteIcon = (UIButton*)sender;
    int index = noteIcon.tag - 10000;
    NSLog(@"index %d",index);
    Highlight* highlight = [highlightsInPage objectAtIndex:index];
    currentHighlight = highlight;
    currentColor = UIColorFromRGB(highlight.highlightColor);
    tv.text = highlight.note;
    currentStartRect = [rv getStartRectFromHighlight:highlight];
    currentEndRect = [rv getEndRectFromHighlight:highlight];
    [self showNoteBox];
}


-(UIButton*)getNoteIcon:(Highlight*)highlight index:(int)index{
    UIButton* noteIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* iconImage = [self getNoteIconImageByHighlightColor:highlight.highlightColor];
    [noteIcon setImage:iconImage forState:UIControlStateNormal];
    [noteIcon addTarget:self action:@selector(noteIconPressed:) forControlEvents:UIControlEventTouchUpInside];
    [noteIcon setContentMode:UIViewContentModeCenter];
    int mx,my;
    int mw = 32;
    int mh = 32;
    mx = self.view.bounds.size.width - 10 - mw;
    my = highlight.top-5;
    if ([self isPad]) {
        if (![self isPortrait]) { // doublePaged mode, landscape
            if ([rv isDoublePaged]) {
                if (highlight.left <self.view.bounds.size.width/2) {
                    mx = 50;
                    my = highlight.top+3;
                }else {
                    mx = self.view.bounds.size.width - 50 - mw;
                    my = highlight.top+3;
                }
            }
        }else { // portriat mode
            mx = self.view.bounds.size.width - 60 - mw;
            my = highlight.top + 5;
        }
    }
    CGRect mf = CGRectMake(mx,my,mw,mh);
    noteIcon.tag = 10000 + index;
    noteIcon.frame = mf;
    
    return noteIcon;
}

-(UIImageView*)getNoteIconImageView:(Highlight*)highlight index:(int)index{
    UIImage* iconImage = [self getNoteIconImageByHighlightColor:highlight.highlightColor];
    UIImageView* iconImageView = [[UIImageView alloc]initWithImage:iconImage];
    [iconImageView setContentMode:UIViewContentModeCenter];
    int mx,my;
    int mw = 32;
    int mh = 32;
    mx = self.view.bounds.size.width - 10 - mw;
    my = highlight.top-5;
    if ([self isPad]) {
        if (![self isPortrait]) { // doublePaged mode, landscape
            if ([rv isDoublePaged]) {
                if (highlight.left <self.view.bounds.size.width/2) {
                    mx = 60;
                    my = highlight.top+3;
                }else {
                    mx = self.view.bounds.size.width - 60 - mw;
                    my = highlight.top+3;
                }
            }
        }else { // portriat mode
            mx = self.view.bounds.size.width - 70 - mw;
            my = highlight.top + 5;
        }
    }
    CGRect mf = CGRectMake(mx,my,mw,mh);
    iconImageView.tag = 20000 + index;
    iconImageView.frame = mf;
    
    return iconImageView;
}

-(void)processNoteIcons {
    [self removeNoteIcons];
    PageInformation*pi = [rv getPageInformation];
    highlightsInPage = pi.highlightsInPage;
    for (int i=0; i<[highlightsInPage count]; i++) {
        Highlight* highlight = [highlightsInPage objectAtIndex:i];
        if (highlight.isNote && highlight.note.length!=0) {
            UIButton* memoIcon = [self getNoteIcon:highlight index:i];
            UIImageView* memoImageView = [self getNoteIconImageView:highlight index:i];
            [self.view addSubview:memoIcon];
//            [rvc.customView addSubview:memoImageView];
            [self.view bringSubviewToFront:memoIcon];
        }        
    }
    if ([highlightsInPage count]!=0) [rv refresh];
}

-(void)disableControlBeforePagination {
    slider.hidden = YES;
    
    listButton.hidden = YES;
    searchButton.hidden = YES;
    fontButton.hidden = YES;
    
    pageIndexLabel.hidden = YES;
    secondaryIndexLabel.hidden = YES;
    [dotted setProgressMode:YES];
}

-(void)enableControlAfterPagination {
    slider.hidden = NO;
    
    listButton.hidden = NO;
    searchButton.hidden = NO;
    fontButton.hidden = NO;

    pageIndexLabel.hidden = NO;
    secondaryIndexLabel.hidden = NO;
    [dotted setProgressMode:NO];
}

-(void)reflowableViewController:(ReflowableViewController*)rvc didStartPaging:(int)code {
    [self disableControlBeforePagination];
}


-(void)reflowableViewController:(ReflowableViewController*)rvc didPaging:(PagingInformation *)pagingInformation {
    int ci = pagingInformation.chapterIndex;
    int cn = [rvc getNumberOfChaptersInBook];
    double value = (double)ci/(double)cn;
    [dotted setProgressValue:value];
    if (pagingInformation.fontName==nil) pagingInformation.fontName = @"Book Fonts";

    [ad insertPagingInformation:pagingInformation];
    
}

-(NSInteger)reflowableViewController:(ReflowableViewController*)rvc numberOfPagesForPagingInformation:(PagingInformation *)pagingInformation{
    if (pagingInformation.fontName==nil) pagingInformation.fontName = @"Book Fonts";
    PagingInformation* pgi = [ad fetchPagingInformation:pagingInformation];
    int nc = 0;
    if (pgi==NULL) nc=0;
    else nc=pgi.numberOfPagesInChapter;
    return nc;
}

-(void)reflowableViewController:(ReflowableViewController*)rvc didFinishPaging:(int)code {
    PageInformation* pg = [[PageInformation alloc]init];
    pg.pageIndexInBook = [rvc getPageIndexInBook];
    pg.numberOfPagesInBook = [rvc getNumberOfPagesInBook];
    [self changePageLabels:pg];
    [self enableControlAfterPagination];
}


/* MediaOverlay callbacks */
-(void)reflowableViewController:(ReflowableViewController *)rvc parallelDidStart:(Parallel *)parallel {
    currentParallel = parallel;
    [rvc changeElementColor:@"#F0F000" hash:parallel.hash];
    if ([rvc pageIndexInChapter]!=parallel.pageIndex) {
        if (autoMoveChapterWhenParallesFinished) [rvc gotoPageInChapter:parallel.pageIndex];
    }
}

-(void)reflowableViewController:(ReflowableViewController *)rvc parallelDidEnd:(Parallel *)parallel {
    [rvc restoreElementColor];
    if (isLoop) {
        [rvc playPrevParallel];
    }
}

-(void)parallesDidEnd:(ReflowableViewController *)rvc {
    [rvc restoreElementColor];
    if (autoStartPlayingWhenNewPagesLoaded) isAutoPlaying = YES;
    if (autoMoveChapterWhenParallesFinished) {
//        [rvc gotoNextPageInChapter];
        [rvc gotoNextChapter];
    }
}

-(void)reflowableViewController:(ReflowableViewController*)rvc didChapterLoad:(int)chapterIndex {
    if ([rvc isMediaOverlayAvailable]) {
        [self showMediaUI];
        if (autoStartPlayingWhenNewPagesLoaded) {
            if (isAutoPlaying) {
                [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
                [rvc playFirstParallelInPage];
            }
        }
    }else {
        [self hideMediaUI];
    }
}


/* MediaOverlay Utilities */
-(void)playAndPause {
    if ([rv isPlayingPaused]) {
        if (![rv isPlayingStarted]) {
            [rv playFirstParallelInPage];
            if (autoStartPlayingWhenNewPagesLoaded) isAutoPlaying = YES;
        }else {
            [rv resumePlayingParallel];
            if (autoStartPlayingWhenNewPagesLoaded) isAutoPlaying = YES;
        }        
    
    }else {
        [rv pausePlayingParallel];
        if (autoStartPlayingWhenNewPagesLoaded) isAutoPlaying = NO;
    }
    
    if ([rv isPlayingPaused]) {
        [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }else {
        [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }

}

-(void)stopPlaying {
    [button1 setTitle:@"Play" forState:UIControlStateNormal];
    [rv stopPlayingParallel];
    [rv restoreElementColor];
    if (autoStartPlayingWhenNewPagesLoaded) isAutoPlaying = NO;
}


-(void)playPrev {
    [rv playPrevParallel];
}

-(void)playNext {
    [rv playNextParallel];
}


@end