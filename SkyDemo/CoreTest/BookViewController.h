//
//  BookViewController.h
//  CoreTest
//
//  Created by 허 지웅 on 11. 12. 21..
//  Copyright (c) 2011년 Skytree Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReflowableViewController.h"
#import "AppDelegate.h"
#import "BookInformation.h"

@class Parallel;
@class ArrowView;
@class NoteView;
@class DottedView;
@interface BookViewController : UIViewController <ReflowableViewControllerDataSource,ReflowableViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate>{
    ReflowableViewController *rv;
    AppDelegate *ad;
    UIActionSheet *as;
    int count;
    BookInformation* bookInformation;
    Setting* setting;
    
    PageInformation* info;
    NSMutableArray* pagings;
    double targetPos;
    
    UIButton* hideButton;
    UIView* fontBox;
    UIButton* decreseButton;
    UIButton* increseButton;
    UISlider* brightSlider;
    UIScrollView* fontScrollView;
    BOOL isUpArrowActive;
    BOOL isKeyboardShown;
    BOOL isUIControlsShown;
    
    CGRect currentStartRect;
    CGRect currentEndRect;    
    
    UIView* menuBox;
    UIView *piBox;
    ArrowView* piArrow;
    UILabel* piLabel;
    UIView* highlightBox;
    UIView* colorBox;
    ArrowView* upArrow;
    ArrowView* downArrow;
    UIView* noteBox;
    CGRect oldNoteFrame;
    NoteView* tv;
    UIView* searchBox;
    UIScrollView* searchResultsView;
    UIButton* searchCancelButton;
    UITextField *searchField;
    int searchResultsHeight;
    NSMutableArray* searchResults;
    BOOL rotationLocked;
    
    UIView *listView;
    UIScrollView* contentsListView;
    UITableView* bookmarkListView;
    UITableView* highlightListView;
    UISegmentedControl* segmentedControl;
    
    
    NSMutableArray* highlightsInPage;
    NSMutableArray* highlights;
    NSMutableArray* bookmarks;
    
    UIColor* currentColor;
    Highlight* currentHighlight;
    
    int currentSelectedFontIndex;
	UIButton *currentSelectedFontButton;

    UIButton* homeButton;
    UIButton* listButton;
    UIButton* fontButton;
    UIButton* searchButton;
    UISlider* slider;
    DottedView* dotted;
    UILabel* authorLabel;
    UILabel* chapterLabel;
    UILabel* titleLabel;
    UILabel* pageIndexLabel;
    UILabel* secondaryIndexLabel;
    
    UIButton* prevButton;
    UIButton* playButton;
    UIButton* stopButton;
    UIButton* nextButton;
    
    UIButton *button0;
    UIButton *button1;
    UIButton *button2;
    UIButton *button3;
    
    UIButton *button4;
    UIButton *button5;
    UIButton *button6;

    BOOL isAutoPlaying;
    BOOL autoStartPlayingWhenNewPagesLoaded;
    BOOL autoMoveChapterWhenParallesFinished;
    BOOL isLoop;
    Parallel* currentParallel;
    
    CGRect bookmarkRect;
    
    BOOL isInitialized;
    NSMutableArray* themes;
    BOOL isDoublePaged;
    BOOL isRTL;
}

@property (nonatomic, retain) BookInformation* bookInformation;
@property (nonatomic, retain) Setting* setting;
@property BOOL isRTL;

@end
