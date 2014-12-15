//
//  AppDelegate.m
//  CoreTest
//
//  Created by SkyTree on 11. 9. 1..
//  Copyright (c) 2011 Skytree Corporation. All rights reserved.
//

//  !!!!! IMPORTANT !!!!!
//  The Advanced Demo sources are not the part of SkyEpub SDK.
//  These sources are written only to show how to use SkyEpub SDK.
//  The bugs found in this demo do not mean that SkyEpub SDK has the related bugs
//  Developers should change and modify this Advanced Demo sources for their purposes.
//  Any request to add/change/modify the Advanced Demo sources will be refused.


#import "AppDelegate.h"
#import "ZipArchive.h"
#include <sys/time.h>
#import <CommonCrypto/CommonDigest.h>
#import "MainViewController.h"
#import "Highlight.h"
#import "BookInformation.h"
#import "FileProvider.h"
#import "ReflowableViewController.h"
#import "HomeViewController.h"

@implementation Setting
@synthesize bookCode,fontName,fontSize,lineSpace,foreground,background,theme,brightness,transitionType,lockRotation,doublePaged,allow3G,globalPagination;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize setting;
@synthesize isRotationLocked;
@synthesize bis;
@synthesize sortType,key;

-(void)loadSetting {
    setting = [self fetchSetting];
}

-(void)loadBis {
    bis = [self fetchBookInformations:self.sortType key:self.key];
}

-(NSString *)getDocumentsPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;	
}

-(void)createBooksDirectory {
	NSString *docPath = [self getDocumentsPath];
	NSString *booksDir = [docPath stringByAppendingFormat:@"/books"];
	NSFileManager *fm =[NSFileManager defaultManager];
	NSError *error;
	if (![fm fileExistsAtPath:booksDir]) {
		[fm createDirectoryAtPath:booksDir withIntermediateDirectories:NO attributes:nil error:&error];
		
	}
}

-(void)createCoversDirectory {
	NSString *docPath = [self getDocumentsPath];
	NSString *booksDir = [docPath stringByAppendingFormat:@"/covers"];
	NSFileManager *fm =[NSFileManager defaultManager];
	NSError *error;
	if (![fm fileExistsAtPath:booksDir]) {
		[fm createDirectoryAtPath:booksDir withIntermediateDirectories:NO attributes:nil error:&error];
		
	}
}

-(void)createDownloadsDirectory {
	NSString *docPath = [self getDocumentsPath];
	NSString *downloadsDir = [docPath stringByAppendingFormat:@"/downloads"];
	NSFileManager *fm =[NSFileManager defaultManager];
	NSError *error;
	if (![fm fileExistsAtPath:downloadsDir]) {
		[fm createDirectoryAtPath:downloadsDir withIntermediateDirectories:NO attributes:nil error:&error];
	}
}

-(void)createDirectories {
    [self createBooksDirectory];
    [self createDownloadsDirectory];
    [self createCoversDirectory];
}

-(NSString*)getBooksDirectory {
	[self createBooksDirectory];
	NSString *docPath = [self getDocumentsPath];
	NSString *booksDir = [docPath stringByAppendingFormat:@"/books"];
	
	return booksDir;
}

-(NSString*)getCoverPath:(NSString*)coverName {
    NSString* epubDir = [self getEPubDirectory:coverName];
    NSString* coverPath = [NSString stringWithFormat:@"%@/%@",epubDir,coverName];
    return coverPath;    
}

-(NSString*)getCoversDirectory {
	[self createCoversDirectory];
	NSString *docPath = [self getDocumentsPath];
	NSString *coversDir = [docPath stringByAppendingFormat:@"/covers"];
	
	return coversDir;
}


-(NSString*)getDownloadsDirectory {
	[self createDownloadsDirectory];
	NSString *docPath = [self getDocumentsPath];
	NSString *downloadsDir = [docPath stringByAppendingFormat:@"/downloads"];
	
	return downloadsDir;
}


-(void)createEPubDirectory:(NSString *)fileName {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *ePubDir = [self getEPubDirectory:fileName];
	NSError *error;
	if (![fm fileExistsAtPath:ePubDir]) {
		[fm createDirectoryAtPath:ePubDir withIntermediateDirectories:NO attributes:nil error:&error];
	}
}

-(NSString *)getDownloadPath:(NSString*)fileName {
	NSString *downloadsDirectory = [self getDownloadsDirectory];
	// the path to write file
	NSString *filePath = [downloadsDirectory stringByAppendingPathComponent:fileName];
	return filePath;
}

// copy file from bundle(resource) to downloads folders
-(void)copyFileFromBundleToDownloads:(NSString*)fileName {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	
	NSString *downloadPath = [self getDownloadPath:fileName];
	BOOL success = [fm fileExistsAtPath:downloadPath];
	if (!success) {
		NSString *bundlePath = [[[NSBundle mainBundle] resourcePath]
									   stringByAppendingPathComponent:fileName];
		success = [fm copyItemAtPath:bundlePath toPath:downloadPath error:&error];
	}
}

-(BOOL)fileExists:(NSString*)filePath {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	BOOL success = [fm fileExistsAtPath:filePath];
	if (!success) {
		return NO;
	}else {
        return YES;
    }
}

// returns the path of epub unzipped like "../books/sampleF0"
-(NSString*)getEPubDirectory:(NSString*)fileName {
	NSString *pureName = [fileName stringByDeletingPathExtension];
	NSString *booksDir = [self getBooksDirectory];
	NSString *ePubDir = [booksDir stringByAppendingPathComponent:pureName];
	return ePubDir;
}

-(BOOL)unzipEPub:(NSString*)fileName {
	NSString *filePath;
	filePath = [[self getBooksDirectory] stringByAppendingPathComponent:fileName];
	[self createEPubDirectory:fileName];
	ZipArchive *z = [[ZipArchive alloc] init];
	
	[z UnzipOpenFile:filePath];
	BOOL res = [z UnzipFileTo:[self getEPubDirectory:fileName] overWrite:YES];
	[z UnzipCloseFile];	
	[z release];
	return res;
}


-(void)removeFile:(NSString*)path {
	NSFileManager *fm =[NSFileManager defaultManager];
	if (![fm fileExistsAtPath:path]) {
		return;
	}
	NSError *error;
	[fm removeItemAtPath:path error:&error];	
}


-(NSString *)getValueFromString:(NSString*)str withStartTag:(NSString*)startTag withEndTag:(NSString*)endTag {
	NSMutableString *mstr = [NSMutableString stringWithString:str];
	NSRange startRange,endRange;
	NSString *search = startTag;
	startRange = [mstr rangeOfString:search];	
	search = endTag;
	endRange = [mstr rangeOfString:search];
	NSRange dataRange = NSMakeRange(startRange.location+startRange.length,endRange.location-(startRange.location+startRange.length));
	NSString *res = [mstr substringWithRange:dataRange];
	return res;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self openDatabase];
    
//    viewController = [[HomeViewController alloc]init];
    bookVC = [[BookViewController alloc]init];
    
    highlights = [[NSMutableArray alloc]init];
    
//    [self.window addSubview:bookVC.view];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = bookVC;
    
	return YES;    
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
}

// copy epub from download folder to books folder
-(void)copyFileFromDownloadsToBooks:(NSString*)fileName {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	NSString *sourcePath = [self getDownloadPath:fileName];
	NSString *targetPath = [[self getBooksDirectory] stringByAppendingPathComponent:fileName];
	[fm copyItemAtPath:sourcePath toPath:targetPath error:&error];
}

-(void)copyFileFromDownloadsToCovers:(NSString*)fileName {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	NSString *sourcePath = [self getDownloadPath:fileName];
	NSString *targetPath = [[self getCoversDirectory] stringByAppendingPathComponent:fileName];
	[fm copyItemAtPath:sourcePath toPath:targetPath error:&error];
}


-(NSString*)getBaseDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *baseDirectory = [NSString stringWithFormat:@"%@/%@",documentsDirectory,@"books"];
	return baseDirectory;
}

-(BOOL)installEPub:(NSString*)fileName {
    BOOL res;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *downloadPath = [self getDownloadPath:fileName];
    BOOL isExists = [fm fileExistsAtPath:downloadPath];
    if (isExists) return NO;

    // copy sampleBook from resource to downloads folder
    [self copyFileFromBundleToDownloads:fileName];
    // copy sampleBook from downloads folder to books folder
	[self copyFileFromDownloadsToBooks:fileName];

	res = [self unzipEPub:fileName];
	if (!res) {
		NSLog(@"Failed to unzip");
		return NO;
	}
    BookInformation* bi= [[BookInformation alloc]initWithBookName:fileName baseDirectory:[self getBaseDirectory] contentProviderClass:[FileProvider self]];
    bi.fileName = fileName;
    [self insertBook:bi];
	return YES;
}


-(BOOL)installPDF:(NSString*)fileName {
    // copy sampleBook from resource to downloads folder
    [self copyFileFromBundleToDownloads:fileName];
    // copy sampleBook from downloads folder to books folder
	[self copyFileFromDownloadsToBooks:fileName];
    return YES;
}

// 현재는 잠시 강제로 값을 세팅한다. 이후에 반드시 복원해야 한다.
-(int)getTransitionType {
    int ret = [[[NSUserDefaults standardUserDefaults] objectForKey:@"transitionType"] intValue];
    if (![self isAbove5] && ret == PageTransitionCurl) return PageTransitionSlide;
    return ret;
}

-(BOOL)isPad {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }else {
        return NO;
    }
}

-(void)dealloc {
    //    [viewController release];
    [window release];
    [super dealloc];
}

-(BOOL)isAbove5 {
    // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
    // class is used as fallback when it isn't available.
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        return YES;
    }else {
        return NO;
    }
}


-(BOOL)executeSQL:(NSString*)sql {
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database,[sql UTF8String],-1,&statement,NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) != SQLITE_DONE) {
            return NO;
        }
    }
    return YES;
}

// fetch 0 based
-(int)getSettingCount {
    int count = 0;
    const char* sqlStatement = "SELECT COUNT(*) FROM Setting";
    sqlite3_stmt *statement;
    
    if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK ) {
        //Loop through all the returned rows (should be just one)
        while( sqlite3_step(statement) == SQLITE_ROW ) {
            count = sqlite3_column_int(statement, 0);
        }
    }else  {
        NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
    }
    
    // Finalize and close database.
    sqlite3_finalize(statement);
    return count;
}

// insert is 1 based
-(void)insertBook:(BookInformation *)bi {
    sqlite3_stmt *statement;
    char *sql = "INSERT INTO Book (Title,Author,Publisher,Subject,Type,Date,Language,Filename,IsFixedLayout,IsRTL,Position,Spread) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";
    if (sqlite3_prepare_v2(database,sql,-1,&statement,NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement,1,[bi.title UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement,2,[bi.creator UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement,3,[bi.publisher UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement,4,[bi.subject UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement,5,[bi.type UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement,6,[bi.date UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement,7,[bi.language UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement,8,[bi.fileName UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement,9, bi.isFixedLayout);
        sqlite3_bind_int(statement,10, bi.isRTL);
        double position = 0.0f;
        if (bi.isRTL) position = 1.0f;
        sqlite3_bind_double(statement,11, position);
        sqlite3_bind_int(statement,12, bi.spread);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Error");
        }
    }
    sqlite3_finalize(statement);
}

-(NSString *)getColumnText:(sqlite3_stmt*) statement columnIndex:(int)columnIndex {
    char *raw = sqlite3_column_text(statement,columnIndex);
    if (raw==NULL) return nil;
    else return  [NSString stringWithUTF8String:raw];
}

// fetch is 0 based
-(NSMutableArray*)fetchBookInformations:(int)sortType key:(NSString*)key {
    NSLog(@"fetchBIS");
    NSMutableArray* bis = [[NSMutableArray alloc]init];
    NSString* orderBy;
    if (sortType==3)        orderBy = @"";
    else if (sortType==0) 	orderBy = @" ORDER BY Title";
    else if (sortType==1)	orderBy = @" ORDER BY Author";
    else if (sortType==2)	orderBy = @" ORDER BY LastRead DESC";
    
    NSString* condition = @"";
    if (!(key==NULL || key.length==0)) {
        condition = [NSString stringWithFormat:@" WHERE Title like '%%%@%%' OR Author like '%%%@%%'",key,key];
    }
    sqlite3_stmt *selectStatement;
    NSString* baseSql = @"SELECT * FROM Book";
    NSString* sql = [NSString stringWithFormat:@"%@ %@ %@",baseSql,condition,orderBy];
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
        while (sqlite3_step(selectStatement)==SQLITE_ROW) {
            BookInformation* bi = [[BookInformation alloc]init];
            bi.bookCode = sqlite3_column_int(selectStatement, 0);
            bi.title =      [self getColumnText:selectStatement columnIndex:1];
            bi.creator =    [self getColumnText:selectStatement columnIndex:2];
            bi.publisher =  [self getColumnText:selectStatement columnIndex:3];
            bi.subject =    [self getColumnText:selectStatement columnIndex:4];
            bi.type =       [self getColumnText:selectStatement columnIndex:5];
            bi.date =       [self getColumnText:selectStatement columnIndex:6];
            bi.language =   [self getColumnText:selectStatement columnIndex:7];
            bi.fileName =   [self getColumnText:selectStatement columnIndex:8];
            bi.position =   sqlite3_column_double(selectStatement, 9);
            bi.isFixedLayout = sqlite3_column_int(selectStatement, 10);
            bi.isGlobalPagination = sqlite3_column_int(selectStatement, 11);
            bi.isDownloaded = sqlite3_column_int(selectStatement, 12);
            bi.fileSize = sqlite3_column_int(selectStatement, 13);
            bi.customOrder = sqlite3_column_int(selectStatement, 14);
            bi.url = [self getColumnText:selectStatement columnIndex:15];
            bi.coverUrl = [self getColumnText:selectStatement columnIndex:16];
            bi.downSize = sqlite3_column_int(selectStatement, 17);
            bi.isRead = sqlite3_column_int(selectStatement, 18);
            bi.lastRead = [self getColumnText:selectStatement columnIndex:19];
            bi.isRTL = sqlite3_column_int(selectStatement, 20);
            bi.isVerticalWriting = sqlite3_column_int(selectStatement, 21);
            bi.spread = sqlite3_column_int(selectStatement, 22);
            [bis addObject:bi];
        }
    }
    sqlite3_finalize(selectStatement);    
    return bis;
}



// Database Routines
-(BOOL)openDatabase {
    NSLog(@"openDatabase");
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    if (sqlite3_open([dbPath UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        return NO;
    }
    BOOL res = [self createDatabase];
    if ([self getSettingCount]==0) {
        [self executeSQL:@"INSERT INTO Setting(BookCode,FontName,FontSize,LineSpacing,Foreground,Background,Theme,Brightness,TransitionType,LockRotation,DoublePaged,Allow3G,GlobalPagination) VALUES(0,'Book Fonts',2,-1,-1,-1,0,1,2,1,1,0,0)"];
    }
    return res;
}

-(BOOL)updateBookPosition:(BookInformation*)bi {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [timeFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSString *dateString = [timeFormatter stringFromDate:[[NSDate alloc]init] ];
    NSString *sql = [NSString stringWithFormat:@"UPDATE Book SET Position=%f,LastRead='%@',IsRead=%d where BookCode=%d",bi.position,dateString,1,bi.bookCode];
    BOOL res = [self executeSQL:sql];
    return res;
}

-(BOOL)createDatabase {
    NSString *ddlPath = [[NSBundle mainBundle] pathForResource:@"/Books" ofType:@"sql"];
    NSString *ddl = [NSString stringWithContentsOfFile:ddlPath encoding:NSUTF8StringEncoding error:NULL];
    if (sqlite3_exec(database, [ddl UTF8String], nil,nil,nil) != SQLITE_OK) {
        sqlite3_close(database);
        return NO;
    }
    return YES;
}

// fetch is 0 based
-(Setting*)fetchSetting {
    NSLog(@"fetchSetting");
    sqlite3_stmt *selectStatement;
    Setting *aSetting;
    char *selectSql = "SELECT * FROM Setting where BookCode=0";
    if (sqlite3_prepare_v2(database, selectSql, -1, &selectStatement, NULL) == SQLITE_OK) {
        while (sqlite3_step(selectStatement)==SQLITE_ROW) {
            aSetting = [[Setting alloc]init];
            aSetting.bookCode =      sqlite3_column_int(selectStatement, 0);
            aSetting.fontName =      [self getColumnText:selectStatement columnIndex:1];
            aSetting.fontSize =      sqlite3_column_int(selectStatement, 2);
            aSetting.lineSpace=      sqlite3_column_int(selectStatement, 3);
            aSetting.foreground=     sqlite3_column_int(selectStatement, 4);
            aSetting.background=     sqlite3_column_int(selectStatement, 5);
            aSetting.theme  =        sqlite3_column_int(selectStatement, 6);
            aSetting.brightness =    sqlite3_column_double(selectStatement, 7);
            aSetting.transitionType= sqlite3_column_int(selectStatement, 8);
            aSetting.lockRotation =  sqlite3_column_int(selectStatement, 9);
            aSetting.doublePaged  =  sqlite3_column_int(selectStatement, 10);
            aSetting.allow3G  =      sqlite3_column_int(selectStatement, 11);
            aSetting.globalPagination  =  sqlite3_column_int(selectStatement, 12);
        }
    }
    sqlite3_finalize(selectStatement);
    return aSetting;
}

-(void)updateSetting:(Setting*)aSetting {
    NSString *sql = [NSString stringWithFormat:@"UPDATE Setting SET FontName='%@', FontSize=%d , LineSpacing=%d , Foreground=%d , Background=%d , Theme=%d , Brightness=%f, TransitionType=%d , LockRotation=%d , DoublePaged=%d,Allow3G=%d,GlobalPagination=%d where BookCode=0",aSetting.fontName,aSetting.fontSize,aSetting.lineSpace,aSetting.foreground,aSetting.background,aSetting.theme,aSetting.brightness,aSetting.transitionType,aSetting.lockRotation,aSetting.doublePaged,aSetting.allow3G,aSetting.globalPagination];
    [self executeSQL:sql];
}


// Bookmark routines
-(void)insertBookmark:(PageInformation *)pi{
    double ppb = pi.pagePositionInBook;
    double ppc = pi.pagePositionInChapter;
    int ci = pi.chapterIndex;
    int bc = pi.bookCode;
    
    NSDate* currentDate = [NSDate date];
    NSString* dateInString = [currentDate descriptionWithLocale:[NSLocale currentLocale]];
    NSString* sql = [NSString stringWithFormat:@"INSERT INTO Bookmark (BookCode,ChapterIndex,PagePositionInChapter,PagePositionInBook,CreatedDate) VALUES(%d,%d,%f,%f,'%@')",bc,ci,ppc,ppb,dateInString];
    [self executeSQL:sql];
}

-(void)deleteBookmarkByCode:(int)code{
    NSString* sql = [NSString stringWithFormat:@"DELETE FROM Bookmark where Code = %d",code];
    [self executeSQL:sql];
}

-(void)deleteBookmark:(PageInformation*)pi {
    int code = pi.code;
    [self deleteBookmarkByCode:code];
}

// fetch 0 based
-(int)getBookmarkCode:(PageInformation*)pi{
    sqlite3_stmt *selectStatement;
    double pageDelta = 1.0f/pi.numberOfPagesInChapter;
    double target = pi.pagePositionInChapter;
    int bookCode = pi.bookCode;
    NSString* selectSql = [NSString stringWithFormat:@"SELECT Code,PagePositionInChapter from Bookmark where BookCode=%d and ChapterIndex=%d",bookCode,pi.chapterIndex];
    if (sqlite3_prepare_v2(database, [selectSql UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
        while (sqlite3_step(selectStatement)==SQLITE_ROW) {
            double ppc = sqlite3_column_double(selectStatement, 1);
            int code = sqlite3_column_int(selectStatement, 0);
            if (target>=(ppc-pageDelta/2) && target<=(ppc+pageDelta/2.0f)) {
                return code;
            }
        }
    }
    sqlite3_finalize(selectStatement);
    return -1;
}

// zero base
-(NSMutableArray *)fetchAllBookmarks:(int)bookCode{
    NSMutableArray *results = [[NSMutableArray alloc]init];
    sqlite3_stmt *selectStatement;
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM Bookmark where BookCode=%d ORDER BY ChapterIndex,PagePositionInBook",bookCode];
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
        while (sqlite3_step(selectStatement)==SQLITE_ROW) {
            PageInformation* pageInformation = [[PageInformation alloc]init];
            pageInformation.bookCode = bookCode;
            pageInformation.code = sqlite3_column_int(selectStatement, 1);
            pageInformation.chapterIndex = sqlite3_column_int(selectStatement, 2);
            pageInformation.pagePositionInChapter = sqlite3_column_double(selectStatement, 3);
            pageInformation.pagePositionInBook = sqlite3_column_double(selectStatement, 4);
            pageInformation.pageDescription = [self getColumnText:selectStatement columnIndex:6];
            [results addObject:pageInformation];
        }
    }
    sqlite3_finalize(selectStatement);
    return results;
}


-(BOOL)isBookmarked:(PageInformation*)pageInformation{
    int code = [self getBookmarkCode:pageInformation];
    if (code==-1) {
        return NO;
    }else {
        return YES;
    }
}

-(void)toggleBookmark:(PageInformation*)pi{
    int code = [self getBookmarkCode:pi];
    if (code == -1) { // if not exist
        [self insertBookmark:pi];
    }else {
        [self deleteBookmarkByCode:code]; // if exist, delete it
    }
}


// Highlight Routines

// fetch is 0 based
-(NSMutableArray *)fetchHighlights:(int)bookCode chapterIndex:(int)chapterIndex {
    NSMutableArray *results = [[NSMutableArray alloc]init];
    sqlite3_stmt *selectStatement;
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM Highlight where BookCode=%d and ChapterIndex=%d",bookCode,chapterIndex];
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
        while (sqlite3_step(selectStatement)==SQLITE_ROW) {
            Highlight* highlight = [[Highlight alloc]init];
            highlight.bookCode = bookCode;
            highlight.code = sqlite3_column_int(selectStatement, 1);
            highlight.chapterIndex = chapterIndex;
            highlight.startIndex    = sqlite3_column_int(selectStatement, 3);
            highlight.startOffset   = sqlite3_column_int(selectStatement, 4);
            highlight.endIndex      = sqlite3_column_int(selectStatement, 5);
            highlight.endOffset     = sqlite3_column_int(selectStatement, 6);
            highlight.highlightColor= sqlite3_column_int(selectStatement, 7);
            highlight.text =        [self getColumnText:selectStatement columnIndex:8];
            highlight.note =        [self getColumnText:selectStatement columnIndex:9];
            highlight.isNote =      sqlite3_column_int(selectStatement, 10);
            highlight.datetime =      [self getColumnText:selectStatement columnIndex:11];
            [results addObject:highlight];
        }
    }
    sqlite3_finalize(selectStatement);
    return results;
}

-(NSMutableArray *)fetchAllHighlights:(int)bookCode{
    NSMutableArray *results = [[NSMutableArray alloc]init];
    sqlite3_stmt *selectStatement;
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM Highlight where BookCode=%d ORDER BY ChapterIndex,StartIndex,StartOffset,EndIndex,EndOffset",bookCode];
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
        while (sqlite3_step(selectStatement)==SQLITE_ROW) {
            Highlight* highlight = [[Highlight alloc]init];
            highlight.bookCode = bookCode;
            highlight.code = sqlite3_column_int(selectStatement, 1);
            highlight.chapterIndex =  sqlite3_column_int(selectStatement, 2);
            highlight.startIndex    = sqlite3_column_int(selectStatement, 3);
            highlight.startOffset   = sqlite3_column_int(selectStatement, 4);
            highlight.endIndex      = sqlite3_column_int(selectStatement, 5);
            highlight.endOffset     = sqlite3_column_int(selectStatement, 6);
            highlight.highlightColor= sqlite3_column_int(selectStatement, 7);
            highlight.text =        [self getColumnText:selectStatement columnIndex:8];
            highlight.note =        [self getColumnText:selectStatement columnIndex:9];
            highlight.isNote =      sqlite3_column_int(selectStatement, 10);
            highlight.datetime =      [self getColumnText:selectStatement columnIndex:11];            
            [results addObject:highlight];
        }
    }
    sqlite3_finalize(selectStatement);
    return results;
}


// Insert is 1 based
-(void)insertHighlight:(Highlight*)highlight {
    sqlite3_stmt *statement;
    char *sql = "INSERT INTO Highlight (BookCode,ChapterIndex,StartIndex,StartOffset,EndIndex,EndOffset,Color,Text,Note,IsNote,CreatedDate) VALUES(?,?,?,?,?,?,?,?,?,?,?)";
    if (sqlite3_prepare_v2(database,sql,-1,&statement,NULL) == SQLITE_OK) {
        sqlite3_bind_int(statement,1, highlight.bookCode);
        sqlite3_bind_int(statement,2, highlight.chapterIndex);
        sqlite3_bind_int(statement,3, highlight.startIndex);
        sqlite3_bind_int(statement,4, highlight.startOffset);
        sqlite3_bind_int(statement,5, highlight.endIndex);
        sqlite3_bind_int(statement,6, highlight.endOffset);
        sqlite3_bind_int(statement,7, highlight.highlightColor);
        sqlite3_bind_text(statement,8,[highlight.text UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement,9,[highlight.note UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement,10, highlight.isNote);
        NSDate* currentDate = [NSDate date];
        NSString* dateInString = [currentDate descriptionWithLocale:[NSLocale currentLocale]];
        sqlite3_bind_text(statement,11,[dateInString UTF8String],-1, SQLITE_TRANSIENT);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Error");
        }
    }
    sqlite3_finalize(statement);
}

-(void)deleteHighlight:(Highlight*)highlight {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM Highlight where BookCode=%d and ChapterIndex=%d and StartIndex=%d and StartOffset=%d and EndIndex=%d and EndOffset=%d",highlight.bookCode,highlight.chapterIndex,highlight.startIndex,highlight.startOffset,highlight.endIndex,highlight.endOffset];
    [self executeSQL:sql];
}

// Update is 1 Based
-(void)updateHighlight:(Highlight*)highlight {
    sqlite3_stmt *statement;
    char *sql = "UPDATE Highlight SET StartIndex=?,StartOffset=?,EndIndex=?,EndOffset=?,Color=?,Text=?,Note=?,IsNote=?,CreatedDate=? where BookCode=? and ChapterIndex=? and StartIndex=? and StartOffset=? and EndIndex=? and EndOffset=?";
    if (sqlite3_prepare_v2(database,sql,-1,&statement,NULL) == SQLITE_OK) {
        sqlite3_bind_int(statement,1, highlight.startIndex);
        sqlite3_bind_int(statement,2, highlight.startOffset);
        sqlite3_bind_int(statement,3, highlight.endIndex);
        sqlite3_bind_int(statement,4, highlight.endOffset);
        sqlite3_bind_int(statement,5, highlight.highlightColor);
        sqlite3_bind_text(statement,6,[highlight.text UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement,7,[highlight.note UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement,8, highlight.isNote);
        NSDate* currentDate = [NSDate date];
        NSString* dateInString = [currentDate descriptionWithLocale:[NSLocale currentLocale]];
        sqlite3_bind_text(statement,9,[dateInString UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement,10, highlight.bookCode);
        sqlite3_bind_int(statement,11, highlight.chapterIndex);
        sqlite3_bind_int(statement,12, highlight.startIndex);
        sqlite3_bind_int(statement,13, highlight.startOffset);
        sqlite3_bind_int(statement,14, highlight.endIndex);
        sqlite3_bind_int(statement,15, highlight.endOffset);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Error");
        }
    }
    sqlite3_finalize(statement);    
}

-(PagingInformation*)fetchPagingInformation:(PagingInformation*)pgi {
    sqlite3_stmt *selectStatement;
    PagingInformation *pg = NULL;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Paging WHERE BookCode=%d AND ChapterIndex=%d AND FontName='%@' AND FontSize=%d AND LineSpacing=%d AND Width=%d AND Height=%d AND HorizontalGapRatio=%f AND VerticalGapRatio=%f AND IsPortrait=%d AND IsDoublePagedForLandscape=%d",
                               pgi.bookCode,	pgi.chapterIndex,		pgi.fontName,		pgi.fontSize,		pgi.lineSpacing,	pgi.width,		pgi.height,		pgi.horizontalGapRatio,		pgi.verticalGapRatio,		pgi.isPortrait ? 1:0,	pgi.isDoublePagedForLandscape?1:0];
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
        while (sqlite3_step(selectStatement)==SQLITE_ROW) {
            pg = [[PagingInformation alloc]init];
            pg.bookCode = sqlite3_column_int(selectStatement, 0);
            pg.code = sqlite3_column_int(selectStatement, 1);
            pg.chapterIndex = sqlite3_column_int(selectStatement, 2);
            pg.numberOfPagesInChapter = sqlite3_column_int(selectStatement, 3);
            pg.fontName = [self getColumnText:selectStatement columnIndex:4];
            pg.fontSize = sqlite3_column_int(selectStatement, 5);
            pg.lineSpacing = sqlite3_column_int(selectStatement, 6);
            pg.width = sqlite3_column_int(selectStatement, 7);
            pg.height = sqlite3_column_int(selectStatement, 8);
            pg.verticalGapRatio = sqlite3_column_double(selectStatement, 9);
            pg.horizontalGapRatio = sqlite3_column_double(selectStatement, 10);
            pg.isPortrait = sqlite3_column_int(selectStatement, 11);
            pg.isDoublePagedForLandscape =  sqlite3_column_int(selectStatement, 12);
        }
    }
    sqlite3_finalize(selectStatement);
    return pg;
}

-(void)deletePagingInformation:(PagingInformation*)pgi {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM Paging WHERE BookCode=%d AND ChapterIndex=%d AND FontName='%@' AND FontSize=%d AND LineSpacing=%d AND Width=%d AND Height=%d AND HorizontalGapRatio=%f AND VerticalGapRatio=%f AND IsPortrait=%d AND IsDoublePagedForLandscape=%d",pgi.bookCode,	pgi.chapterIndex,		pgi.fontName,		pgi.fontSize,		pgi.lineSpacing,	pgi.width,		pgi.height,		pgi.horizontalGapRatio,		pgi.verticalGapRatio,		pgi.isPortrait ? 1:0,	pgi.isDoublePagedForLandscape?1:0];
    [self executeSQL:sql];
}

-(void)insertPagingInformation:(PagingInformation *)pgi {
    PagingInformation* tgi = [self fetchPagingInformation:pgi];
    if (tgi!=NULL) {
        [self deletePagingInformation:tgi];
    }
    sqlite3_stmt *statement;
    char *sql = "INSERT INTO Paging (BookCode,ChapterIndex,NumberOfPagesInChapter,FontName,FontSize,LineSpacing,Width,height,VerticalGapRatio,HorizontalGapRatio,IsPortrait,IsDoublePagedForLandscape) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
    if (sqlite3_prepare_v2(database,sql,-1,&statement,NULL) == SQLITE_OK) {
        sqlite3_bind_int(statement,1,pgi.bookCode);
        sqlite3_bind_int(statement,2,pgi.chapterIndex);
        sqlite3_bind_int(statement,3,pgi.numberOfPagesInChapter);
        sqlite3_bind_text(statement,4,[pgi.fontName UTF8String],-1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement,5,pgi.fontSize);
        sqlite3_bind_int(statement,6,pgi.lineSpacing);
        sqlite3_bind_int(statement,7,pgi.width);
        sqlite3_bind_int(statement,8,pgi.height);
        sqlite3_bind_double(statement,9,pgi.verticalGapRatio);
        sqlite3_bind_double(statement,10,pgi.horizontalGapRatio);
        sqlite3_bind_int(statement,11,pgi.isPortrait);
        sqlite3_bind_int(statement,12,pgi.isDoublePagedForLandscape);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Error");
        }
    }
    sqlite3_finalize(statement);
}

-(void)deleteBookByCode:(int)bookCode{
    NSString* sql = [NSString stringWithFormat:@"DELETE FROM Book where BookCode = %d",bookCode];
    [self executeSQL:sql];
}



@end