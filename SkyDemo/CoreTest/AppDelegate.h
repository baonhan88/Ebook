//
//  AppDelegate.h
//  CoreTest
//
//  Created by 허 지웅 on 11. 9. 1..
//  Copyright (c) 2011 Skytree Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Book.h"
#import "sqlite3.h"
#import "BookInformation.h"

#define PageTransitionNone  0
#define PageTransitionSlide 1
#define PageTransitionCurl  2

@class PageInformation;
@interface Setting : NSObject {
    int bookCode;
    NSString *fontName;
    int fontSize;
    int lineSpacing;
    int foreground;
    int background;
    int theme;
    double brightness;
    int transitionType;
    BOOL lockRotation;
    BOOL doublePaged;
    BOOL allow3G;
    BOOL globalPagination;
}
@property (nonatomic,retain) NSString* fontName;
@property int foreground;
@property int background;
@property int transitionType;
@property int bookCode,fontSize,lineSpace,theme;
@property BOOL lockRotation,doublePaged,allow3G,globalPagination;
@property double brightness;

@end


@class HomeViewController;
@class BookViewController;

@class Highlight;
@class Setting;
@class PagingInformation;
@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *window;
	BOOL isRotationLocked;
    
    HomeViewController *viewController;
    BookViewController *bookVC;
    
    NSMutableArray *highlights;
    Setting *setting;
    sqlite3 *database;
    NSMutableArray* bis;
    int sortType;
    NSString* key;
}

-(int)getTransitionType;
-(BOOL)copyScripts;
-(BOOL)isAbove5;
-(BOOL)unzipEPub:(NSString*)fileName;
-(void)removeFile:(NSString*)path;
-(BOOL)installEPub:(NSString*)fileName;
-(BOOL)installPDF:(NSString*)fileName;
-(BOOL)isPad;
-(NSMutableArray *)fetchHighlights:(int)bookCode chapterIndex:(int)chapterIndex;
-(void)insertHighlight:(Highlight*)highlight;
-(void)deleteHighlight:(Highlight*)highlight;
-(NSMutableArray*)fetchBookInformations;
-(BOOL)updateBookPosition:(BookInformation*)bi;
-(Setting*)fetchSetting;
-(void)updateSetting:(Setting*)setting;
-(void)updateHighlight:(Highlight*)highlight;
-(void)toggleBookmark:(PageInformation*)pi;
-(BOOL)isBookmarked:(PageInformation*)pageInformation;
-(NSMutableArray *)fetchAllBookmarks:(int)bookCode;
-(NSMutableArray *)fetchAllHighlights:(int)bookCode;
-(void)deleteBookmark:(PageInformation*)pi;
-(void)insertPagingInformation:(PagingInformation *)pgi;
-(void)deletePagingInformation:(PagingInformation*)pgi;
-(PagingInformation*)fetchPagingInformation:(PagingInformation*)pgi;
-(void)loadSetting;
-(void)createDirectories;
-(void)loadBis;
-(void)deleteBookByCode:(int)bookCode;
-(BOOL)installEPub:(NSString*)fileName;
-(NSString *)getDownloadPath:(NSString*)fileName;
-(BOOL)fileExists:(NSString*)filePath;
-(NSString*)getCoverPath:(NSString*)coverName;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property BOOL isRotationLocked;
@property (nonatomic, retain) Setting* setting;
@property (nonatomic, retain) NSMutableArray* bis;
@property int sortType;
@property (nonatomic,retain) NSString* key;


@end
