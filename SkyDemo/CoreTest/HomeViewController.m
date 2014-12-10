//
//  HomeViewController.m
//  SkyDemo
//
//  Created by 하늘나무 on 2014. 1. 2..
//  Copyright (c) 2014년 Skytree Corporation. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "SetupController.h"
#import "BookViewController.h"
#import "MagazineController.h"

#ifdef __IPHONE_6_0
# define ALIGN_CENTER NSTextAlignmentCenter
#else
# define ALIGN_CENTER UITextAlignmentCenter
#endif

@interface MenuBox : UIView {
    UILabel *menuTitle;
    NSMutableArray* menuButtons;
}

@property (nonatomic,retain) UILabel* menuTitle;
@property (nonatomic,retain) NSMutableArray* menuButtons;

@end

@implementation MenuBox
@synthesize menuButtons,menuTitle;
- (id)init{
    self = [super init];
    if (self) {
        menuButtons = [[NSMutableArray alloc]init];
    }
    return self;
}

@end


@interface ProgressView : UIView {
    double progress;
    UIColor *dotColor,*dotBackColor;
}
@property double progress;
@property (nonatomic,retain) UIColor* dotColor,*dotBackColor;
@end


@implementation ProgressView
@synthesize progress,dotColor,dotBackColor;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}


-(void)drawRect:(CGRect)rect {
    @autoreleasepool {
        [super drawRect:rect];
        
        double dw = 6.0;
        double vh = self.frame.size.height;
        double vw = self.frame.size.width;
        
        double tc = 5;
        int dc = round(tc*progress);
        int ss = (double)vw/(double)tc;
        
        CGRect borderRect;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1.0);
        
        for (int i=0; i<dc; i++) {
            double x = (ss*i)+(ss/2);
            borderRect = CGRectMake(x,vh/2-dw/2, dw,dw);
            CGContextSetStrokeColorWithColor(context,dotBackColor.CGColor );
            CGContextSetFillColorWithColor(context, dotColor.CGColor);
            CGContextFillEllipseInRect (context, borderRect);
            CGContextStrokeEllipseInRect(context, borderRect);
        }
        CGContextFillPath(context);
    }
}

@end



@interface BookCell:UICollectionViewCell {
    int bookCode;
    BOOL isInit;
}
@property int bookCode;
@property BOOL isInit;
@end

@implementation BookCell
@synthesize bookCode,isInit;

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

@end



@interface HomeViewController () {
    BOOL isGridMode; // true grid / false list
    BOOL isClearData;
    NSString *ci;
    
    UIButton *libraryButton;
    UIButton *searchButton;
    UIButton *sortButton;
    UIButton *gridButton;
    UIButton *settingButton;
    
    UISearchBar* searchBar;
    BookInformation* currentBookInformation;
    
    MenuBox* sortBox, *optionBox;
    UIButton* hideButton;
}
@end


@implementation HomeViewController

- (void)collectionView:(UICollectionView *)colView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
}

- (void)collectionView:(UICollectionView *)colView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isGridMode = NO;
    ad =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [ad loadSetting];
    [ad createDirectories];
    [ad loadBis]; // Modify it later according to condition.
    [self makeXIB];
}


-(BOOL)isPad {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }else {
        return NO;
    }
}

-(int)numberOfItemsInRow {
    if ([self isPad]) {
        if ([self isPortrait]) {    // for Pad
            if (isGridMode) {
                return 3;
            }else {
                return 2;
            }
        }else {
            if (isGridMode) {
                return 5;
            }else {
                return 3;
            }
        }
    }else {
        if ([self isPortrait]) {    // for Phone
            if (isGridMode) {
                return 2;
            }else {
                return 1;
            }
        }else {
            if (isGridMode) {
                return 4;
            }else {
                return 2;
            }
        }
    }
}

-(int)cellWidth {
    int ni = [self numberOfItemsInRow];
    int vw = self.view.bounds.size.width;
    double iw = (double)(vw*0.96)/(double)ni;
    return iw;
}

-(int)cellHeight {
    return 200;
}

-(BOOL)isPortrait {
    return UIDeviceOrientationIsPortrait(self.interfaceOrientation);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// for iOS7 only
-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)makeXIB {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation: UIStatusBarAnimationSlide];

    [self makeTopView];
    [self makeMainView];
    [self makeHideButton];
    [self makeSortBox];
    [self makeOptionBox];
}

-(void)makeTopView {
    self.view.backgroundColor = [UIColor lightGrayColor];
    topView = [[UIView alloc]init];
    topView.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    topView.frame = CGRectMake(0,0,self.view.bounds.size.width,38);
    topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:topView];
    UIImageView* topImageView = [[UIImageView alloc]init];
    topImageView.image = [UIImage imageNamed:@"topblue.png"];
    topImageView.frame = topView.bounds;
    topImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    topImageView.contentMode = UIViewContentModeScaleToFill;
    [topView addSubview:topImageView];
    
    int bw = 42;
    int bh = 42;
    int vw = self.view.bounds.size.width;
    int is = 8;
    int ty = 0;
    
    libraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [libraryButton setImage:[UIImage imageNamed:@"library.png"] forState:UIControlStateNormal];
    [libraryButton addTarget:self action:@selector(libraryPressed:) forControlEvents:UIControlEventTouchUpInside];
    [libraryButton setContentMode:UIViewContentModeCenter];
    libraryButton.frame = CGRectMake(15,ty,bw,bh);
    libraryButton.showsTouchWhenHighlighted = YES;
    UIEdgeInsets libraryInsets = {
        .top    = 7,
        .left   = 7,
        .bottom = 7,
        .right  = 7
    };
    libraryButton.imageEdgeInsets =libraryInsets;
    [topView addSubview:libraryButton];
    
    searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setImage:[UIImage imageNamed:@"searchwhite.png"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchPressed:) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setContentMode:UIViewContentModeCenter];
    searchButton.frame = CGRectMake(vw-185,ty,bw,bh);
    searchButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    UIEdgeInsets searchInsets = {
        .top    = is,
        .left   = is,
        .bottom = is,
        .right  = is
    };
    searchButton.imageEdgeInsets =searchInsets;
    searchButton.showsTouchWhenHighlighted = YES;
    [topView addSubview:searchButton];
    
    sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sortButton setImage:[UIImage imageNamed:@"sort.png"] forState:UIControlStateNormal];
    [sortButton addTarget:self action:@selector(sortPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sortButton setContentMode:UIViewContentModeCenter];
    sortButton.frame = CGRectMake(vw-140,ty,bw,bh);
    sortButton.showsTouchWhenHighlighted = YES;
    sortButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    UIEdgeInsets sortInsets = {
        .top    = is,
        .left   = is,
        .bottom = is,
        .right  = is
    };
    sortButton.imageEdgeInsets =sortInsets;
    [topView addSubview:sortButton];
    
    gridButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *name = @"grid-shelf.png";
    if (isGridMode) name = @"grid-shelf.png";
    else            name = @"list-shelf.png";
    [gridButton setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [gridButton addTarget:self action:@selector(gridPressed:) forControlEvents:UIControlEventTouchUpInside];
    [gridButton setContentMode:UIViewContentModeCenter];
    gridButton.frame = CGRectMake(vw-95,ty,bw,bh);
    gridButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    UIEdgeInsets gridInsets = {
        .top    = is,
        .left   = is,
        .bottom = is,
        .right  = is
    };
    gridButton.showsTouchWhenHighlighted = YES;
    gridButton.imageEdgeInsets =gridInsets;
    [topView addSubview:gridButton];
    
    
    settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(settingPressed:) forControlEvents:UIControlEventTouchUpInside];
    [settingButton setContentMode:UIViewContentModeCenter];
    settingButton.frame = CGRectMake(vw-50,ty,bw,bh);
    settingButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    settingButton.showsTouchWhenHighlighted = YES;
    UIEdgeInsets settingInsets = {
        .top    = is,
        .left   = is,
        .bottom = is,
        .right  = is
    };
    settingButton.imageEdgeInsets =settingInsets;
    [topView addSubview:settingButton];
    
    CGRect sr;
    sr = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40);
    searchBar = [[UISearchBar alloc] initWithFrame:sr];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.delegate = self;
    searchBar.hidden = YES;
    
    [topView addSubview:searchBar];
    
}

-(void)makeMainView {
    int th = 38;
    mainView = [[UIView alloc]init];
    mainView.backgroundColor = [UIColor lightGrayColor];
    mainView.frame = CGRectMake(0,th, self.view.bounds.size.width,self.view.bounds.size.height-th);
    mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    UIImageView* backgroundView = [[UIImageView alloc]init];
    backgroundView.image = [UIImage imageNamed:@"homeground.png"];
    backgroundView.frame = mainView.bounds;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    backgroundView.contentMode = UIViewContentModeScaleToFill;
    [mainView addSubview:backgroundView];
    [self.view addSubview:mainView];
    
    ci = @"bookCell";
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    collectionView=[[UICollectionView alloc] initWithFrame:mainView.bounds collectionViewLayout:layout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [collectionView registerClass:[BookCell class] forCellWithReuseIdentifier:ci];
    [collectionView setBackgroundColor:[UIColor clearColor]];
    UILongPressGestureRecognizer * longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressed:)];
    longPressGestureRecognizer.minimumPressDuration = .5; //seconds
    longPressGestureRecognizer.delegate = self;
    [collectionView addGestureRecognizer:longPressGestureRecognizer];
    [mainView addSubview:collectionView];
}


-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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


-(void)libraryPressed:(id)sender {
    [self installSamples];
    [self reload];
}

-(void)searchPressed:(id)sender {
    searchBar.hidden = NO;
    [searchBar becomeFirstResponder];
}

-(void)sortPressed:(id)sender {
    [self showSortBox];
}

-(void)gridPressed:(id)sender {
    isGridMode=!isGridMode;
    NSString *name = @"grid-shelf.png";
    if (isGridMode) name = @"grid-shelf.png";
    else            name = @"list-shelf.png";
    [gridButton setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [self reload];
}

-(void)settingPressed:(id)sender {
    SetupController *cvc = [[SetupController alloc]init];
    [self presentModalViewController:cvc animated:YES];
}




- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    ad.key = aSearchBar.text;
    [self reload];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
    [aSearchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar {
    [aSearchBar setText:@""];
    [aSearchBar setShowsCancelButton:NO animated:YES];
    [aSearchBar resignFirstResponder];
    searchBar.hidden = YES;
    ad.key=@"";
    [self reload];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [ad.bis count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([self cellWidth],[self cellHeight]);
}

- (BookCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;


    BookCell *cell=[aCollectionView dequeueReusableCellWithReuseIdentifier:ci forIndexPath:indexPath];
    
    BookInformation* bi = [ad.bis objectAtIndex:row];
    
    if (cell.isInit && cell.bookCode == bi.bookCode) {
//        NSLog(@"cell row %d bookCode %d isInit %d just   returned",row,cell.bookCode,cell.isInit);
        return cell;
    }else {
//        NSLog(@"cell row %d bookCode %d isInit %d will be created",row,cell.bookCode,cell.isInit);
    }
    
    
    for (UIView* view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }

    
    if (isGridMode) {
        UIView*masterView= [self makeMasterView:bi];
        int mx = [self cellWidth]/2.0-masterView.bounds.size.width/2.0;
        masterView.frame = CGRectMake(mx,0,masterView.bounds.size.width,masterView.bounds.size.height);
        [self addShadow:masterView rect:CGRectMake(0,0,122,162) size:CGSizeMake(15.0f, 20.0f)];
        [cell.contentView addSubview:masterView];
    }else {
        UIView*masterDetailView= [self makeMasterDetailView:bi];
        masterDetailView.frame = CGRectMake(0,0,masterDetailView.bounds.size.width,masterDetailView.bounds.size.height);
        [cell.contentView addSubview:masterDetailView];
    }
    cell.tag = row;
    cell.bookCode = bi.bookCode;
    cell.isInit = YES;
    return cell;
}

-(void)addShadow:(UIView*)view rect:(CGRect)rect size:(CGSize)size{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:rect];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = size;
    view.layer.shadowOpacity = 0.1f;
    view.layer.shadowPath = shadowPath.CGPath;
}

// the masterview in which cover exists.
-(UIView*)makeMasterView:(BookInformation*)bi {
    float ch = [self cellHeight];
    float cw = ch*(3.0f/4.0f);
    float ih = ch*0.8f;
    float iw = ih*(3.0f/4.0f);
    float hs = ih*0.1;
    float vs = iw*0.1;
    UIView* masterView = [[UIView alloc]init];
    UIImageView* coverView = [[UIImageView alloc]init];

    CGRect ir = CGRectMake(vs,hs,iw,ih);
    coverView.frame = ir;
    
    NSString* coverName = [bi.fileName stringByReplacingOccurrencesOfString:@"epub" withString:@"jpg"];
    NSString* coverPath = [ad getCoverPath:coverName];
    if (![ad fileExists:coverPath]) {
        if (bi.isFixedLayout) {
            coverView.image = [UIImage imageNamed:@"greencover.png"];
        }else {
            coverView.image = [UIImage imageNamed:@"bluecover.png"];
        }
        UILabel* titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(hs*2, vs*3, iw-hs*2 ,80)];
        titleLabel.text = bi.title;
        titleLabel.shadowColor = [UIColor blackColor];
        titleLabel.shadowOffset = CGSizeMake(0,-1);
        [titleLabel setNumberOfLines:5];
        [titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        titleLabel.font = [UIFont systemFontOfSize:13.0];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = ALIGN_CENTER;
        [masterView addSubview:titleLabel];
        
        
        UILabel* authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(hs*2, ih-vs*2, iw-hs*2 ,20)];
        authorLabel.text = bi.creator;
        [authorLabel setNumberOfLines:2];
        [authorLabel setLineBreakMode:UILineBreakModeWordWrap];
        authorLabel.shadowColor = [UIColor blackColor];
        authorLabel.shadowOffset = CGSizeMake(0,-1);
        authorLabel.font = [UIFont systemFontOfSize:9.0];
        authorLabel.textColor = [UIColor whiteColor];
        authorLabel.textAlignment = ALIGN_CENTER;
        authorLabel.backgroundColor = [UIColor clearColor];
        
        masterView.tag = 100;
        [masterView addSubview:authorLabel];

    }else {
        UIImage* image = [UIImage imageWithContentsOfFile:coverPath];
        coverView.image = image;
        [coverView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [coverView.layer setBorderWidth: 3.0];
    }
    
    coverView.contentMode = UIViewContentModeScaleToFill;
    [masterView addSubview:coverView];
    
    
    ProgressView* progressView  = [[ProgressView alloc]init];
    progressView.backgroundColor = [UIColor clearColor];
    progressView.dotBackColor = [UIColor blackColor];
    progressView.dotColor = [UIColor lightGrayColor];
    progressView.progress = bi.position;
    progressView.frame = CGRectMake(hs*2, ih-vs*2.5, iw-hs*3 ,20);
    [masterView addSubview:progressView];
    

    masterView.bounds = CGRectMake(0,0,cw,ch);
    return masterView;
}

-(UIView*)makeDetailView:(BookInformation*)bi {
    UIView* detailView = [[UIView alloc]init];
    detailView.backgroundColor = [UIColor clearColor];
    float ch = [self cellHeight];
    float cw = [self cellWidth];
    float mw = ch*(2.0/3.0);
    float dw = cw-mw;

    float hs = 0; // horizontal leading space.
    float vs = 25; // vertical leading space.

    
    UILabel* titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(hs, vs, dw-25 ,80)];
    titleLabel.text = bi.title;
    [titleLabel setNumberOfLines:5];
    [titleLabel setLineBreakMode:UILineBreakModeWordWrap];
    titleLabel.shadowColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.1];
    titleLabel.shadowOffset = CGSizeMake(1,1);
    titleLabel.font = [UIFont systemFontOfSize:13.0];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = ALIGN_CENTER;
    titleLabel.backgroundColor = [UIColor clearColor];
    [detailView addSubview:titleLabel];
    
    NSString *text;
    if (bi.subject !=NULL) text = bi.subject;
    else text = bi.publisher;
    UILabel* subjectLabel = [[UILabel alloc]initWithFrame:CGRectMake(hs, ch*0.6, dw-25 ,20)];
    subjectLabel.text = text;
    [subjectLabel setNumberOfLines:1];
    [subjectLabel setLineBreakMode:UILineBreakModeWordWrap];
    subjectLabel.font = [UIFont systemFontOfSize:10.0];
    subjectLabel.textColor = [UIColor blackColor];
    subjectLabel.textAlignment = ALIGN_CENTER;
    subjectLabel.backgroundColor = [UIColor clearColor];
    subjectLabel.shadowColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.1];
    subjectLabel.shadowOffset = CGSizeMake(1,1);

    [detailView addSubview:subjectLabel];

    UILabel* authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(hs, ch*0.7f, dw-25 ,20)];
    authorLabel.text = bi.creator;
    [authorLabel setNumberOfLines:2];
    [authorLabel setLineBreakMode:UILineBreakModeWordWrap];
    authorLabel.font = [UIFont systemFontOfSize:12.0];
    authorLabel.textColor = [UIColor blackColor];
    authorLabel.textAlignment = ALIGN_CENTER;
    authorLabel.backgroundColor = [UIColor clearColor];
    authorLabel.shadowColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.1];
    authorLabel.shadowOffset = CGSizeMake(0,1);
    [detailView addSubview:authorLabel];
 
    return detailView;
}

-(UIView*)makeMasterDetailView:(BookInformation*)bi {
    UIView* masterDetailView = [[UIView alloc]init];
    
    UIView* masterView = [self makeMasterView:bi];
    UIView* detailView = [self makeDetailView:bi];
    
    masterView.frame = CGRectMake(10,0,masterView.bounds.size.width,masterView.bounds.size.height);
    [self addShadow:masterView rect:CGRectMake(0,0,122,162) size:CGSizeMake(15.0f, 20.0f)];
    detailView.frame = CGRectMake(masterView.bounds.size.width,0,[self cellWidth]-masterView.bounds.size.width,masterView.bounds.size.height);
    
    [masterDetailView addSubview:masterView];
    [masterDetailView addSubview:detailView];
    
    masterDetailView.tag = 100;
    
    return masterDetailView;
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [collectionView reloadData];
}


-(void)reload {
    [ad loadBis];
    [collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCell *cell = (BookCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setHighlighted:YES];
    int index = cell.tag;
    BookInformation* bi = [ad.bis objectAtIndex:index];
    [self openBook:bi];
}

-(void)openBook:(BookInformation*)bi {
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

-(void)longPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:collectionView];
    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:p];
    BookCell *cell = (BookCell *)[collectionView cellForItemAtIndexPath:indexPath];
    int index = cell.tag;
    BookInformation* bi = [ad.bis objectAtIndex:index];
    currentBookInformation = bi;
    [self showOptionBox];
}

-(void)viewDidAppear:(BOOL)animated {
    [self reload];
}

-(void)sortButtonPressed:(id)sender {
    UIButton* button = (UIButton*)sender;
    int index = button.tag;
    ad.sortType = index;
    [self selectSortButton];
    [self reload];
    [self hideSortBox];
}

-(UIButton*)makeMenuButton:(NSString*)title rect:(CGRect)rect action:(SEL)action tag:(int)tag borderColor:(UIColor*)borderColor backColor:(UIColor*)backColor{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.frame = rect;
    [button.layer setBorderColor: [borderColor CGColor]];
    [button.layer setBorderWidth: 1.0];
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    button.showsTouchWhenHighlighted = YES;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    button.tag = tag;
    return button;
}

-(void)setMenuButton:(UIButton*)button select:(BOOL)isSelected {
    UIColor* selectColor = [UIColor colorWithRed:0.0 green:130.0/255.0 blue:1.0 alpha:1.0];
    UIColor* normalColor = [UIColor whiteColor];
    if (isSelected) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = selectColor;
    }else {
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.backgroundColor = normalColor;
    }
}

-(UILabel *)makeMenuLabel:(NSString*)text rect:(CGRect)rect numberOfLines:(int)numberOfLines fontSize:(int)fontSize textColor:(UIColor*)textColor {
    UILabel* label = [[UILabel alloc]initWithFrame:rect];
    label.text = text;
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0,-1);
    [label setNumberOfLines:numberOfLines];
    [label setLineBreakMode:UILineBreakModeWordWrap];
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = ALIGN_CENTER;
    return label;
}

-(void)selectSortButton {
    for (UIButton* button in sortBox.menuButtons) {
        [self setMenuButton:button select:NO];
    }
    [self setMenuButton:[sortBox.menuButtons objectAtIndex:ad.sortType] select:YES];
}

-(void)makeSortBox {
    int vw = self.view.frame.size.width;
    int vh = self.view.frame.size.height;
    int tm = 160;
    int lm = 50;
    sortBox = [[MenuBox alloc]init];
    sortBox.frame = CGRectMake(lm,tm,vw-lm*2,vh-tm*2);
    sortBox.backgroundColor = [UIColor whiteColor];
    UIColor* borderColor = [UIColor colorWithRed:0.0 green:130.0/255.0 blue:1.0 alpha:1.0];
    [sortBox.layer setBorderColor:[borderColor CGColor]];
    [sortBox.layer setBorderWidth: 1.0];
    sortBox.layer.cornerRadius = 5;
    sortBox.layer.masksToBounds = YES;
    sortBox.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self addShadow:sortBox rect:sortBox.bounds size:CGSizeMake(10,10)];

    int blm = 20;
    int sbw = sortBox.frame.size.width;
    int bso = 60;
    int bh = 38;
    int bs = 5;

    UILabel* titleLabel = [self makeMenuLabel:@"Sort Books" rect:CGRectMake(blm,10,sbw-blm*2,40) numberOfLines:1 fontSize:18 textColor:[UIColor blackColor]];
    [sortBox addSubview:titleLabel];
    
    [sortBox.menuButtons addObject:[self makeMenuButton:@"By Title" rect:CGRectMake(blm,bso,sbw-blm*2,bh) action:@selector(sortButtonPressed:) tag:0 borderColor:borderColor backColor:[UIColor whiteColor]]];
    [sortBox.menuButtons addObject:[self makeMenuButton:@"By Author" rect:CGRectMake(blm,bso+((bh+bs)*1),sbw-blm*2,bh) action:@selector(sortButtonPressed:) tag:1 borderColor:borderColor backColor:[UIColor whiteColor]]];
    [sortBox.menuButtons addObject:[self makeMenuButton:@"By Last Read" rect:CGRectMake(blm,bso+((bh+bs)*2),sbw-blm*2,bh)  action:@selector(sortButtonPressed:) tag:2 borderColor:borderColor backColor:[UIColor whiteColor]]];
    [sortBox.menuButtons addObject:[self makeMenuButton:@"No Sort" rect:CGRectMake(blm,bso+((bh+bs)*3),sbw-blm*2,bh) action:@selector(sortButtonPressed:) tag:3 borderColor:borderColor backColor:[UIColor whiteColor]]];

    for (UIButton* button in sortBox.menuButtons) {
        [sortBox addSubview:button];
    }
    [self setMenuButton:[sortBox.menuButtons objectAtIndex:ad.sortType] select:YES];

    [self selectSortButton];
    [self.view addSubview:sortBox];
    sortBox.hidden = YES;
}

-(void)showSortBox {
    hideButton.hidden = NO;
    sortBox.hidden = NO;
}

-(void)hideSortBox {
    hideButton.hidden = YES;
    sortBox.hidden = YES;
}

-(void)hideBoxes {
    [self hideSortBox];
    [self hideOptionBox];
}

-(void)makeHideButton {
    hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideButton.frame = self.view.frame;
    hideButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [hideButton addTarget:self action:@selector(hidePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hideButton];
    hideButton.hidden = YES;
}

-(void)hidePressed:(id)sender {
    [self hideBoxes];
}

-(void)makeOptionBox {
    int vw = self.view.frame.size.width;
    int vh = self.view.frame.size.height;
    int tm = 180;
    int lm = 50;
    optionBox = [[MenuBox alloc]init];
    optionBox.frame = CGRectMake(lm,tm,vw-lm*2,vh-tm*2);
    optionBox.backgroundColor = [UIColor whiteColor];
    UIColor* borderColor = [UIColor colorWithRed:0.0 green:130.0/255.0 blue:1.0 alpha:1.0];
    [optionBox.layer setBorderColor:[borderColor CGColor]];
    [optionBox.layer setBorderWidth: 1.0];
    optionBox.layer.cornerRadius = 5;
    optionBox.layer.masksToBounds = YES;
    optionBox.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self addShadow:optionBox rect:optionBox.bounds size:CGSizeMake(10,10)];
    
    int blm = 20;
    int sbw = sortBox.frame.size.width;
    int bso = 90;
    int bh = 38;
    int bs = 5;
    
    optionBox.menuTitle = [self makeMenuLabel:currentBookInformation.title rect:CGRectMake(blm,10,sbw-blm*2,60) numberOfLines:3 fontSize:18 textColor:[UIColor blackColor]];
    [optionBox addSubview:optionBox.menuTitle];
    
    [optionBox addSubview:[self makeMenuButton:@"Open" rect:CGRectMake(blm,bso,sbw-blm*2,bh) action:@selector(optionButtonPressed:) tag:0 borderColor:borderColor backColor:[UIColor whiteColor]]];
    [optionBox addSubview:[self makeMenuButton:@"Delete" rect:CGRectMake(blm,bso+((bh+bs)*1),sbw-blm*2,bh) action:@selector(optionButtonPressed:) tag:1 borderColor:borderColor backColor:[UIColor whiteColor]]];
    
    [self.view addSubview:optionBox];
    optionBox.hidden = YES;
}

-(void)showOptionBox {
    [optionBox.menuTitle setText:currentBookInformation.title];
    hideButton.hidden = NO;
    optionBox.hidden = NO;
}

-(void)hideOptionBox {
    hideButton.hidden = YES;
    optionBox.hidden = YES;
}

-(void)optionButtonPressed:(id)sender {
    UIButton* button = (UIButton*)sender ;
    int buttonIndex = button.tag;
    if (buttonIndex==0) {
        [self openBook:currentBookInformation];
    }else if (buttonIndex==1) {
        [ad deleteBookByCode:currentBookInformation.bookCode];
        [self reload];
    }
    [self hideOptionBox];
}


-(void)installSamples {
    [ad installEPub:@"UCC.epub"];

//    [ad installEPub:@"Alice.epub"];
//    [ad installEPub:@"Saadi.epub"];
//    [ad installEPub:@"Doctor.epub"];
}

@end
