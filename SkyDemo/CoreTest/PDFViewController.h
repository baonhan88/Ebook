//
//  PdfViewController.h
//  CoreTest
//
//  Created by Jiung Heo on 12. 2. 9..
//  Copyright (c) 2012년 Skytree Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;
@class PDFViewController;

@interface PDFPageInformation :NSObject{
    NSInteger pageIndex;
    NSInteger numberOfPages;
    double pagePosition;
}
@property NSInteger pageIndex;
@property NSInteger numberOfPages;
@property double pagePosition;
@end

@protocol PDFViewControllerDelegate <NSObject>
@optional
-(void)pdfViewController:(PDFViewController*)pvc didDetectTapAtPositionInView:(CGPoint)positionInView positionInPage:(CGPoint)positionInPage;
-(void)pdfViewController:(PDFViewController*)pvc pageMoved:(PDFPageInformation*)pdfPageInformation;
-(void)pdfViewController:(PDFViewController*)pvc didSearchKey:(SearchResult*)searchResult;
-(void)pdfViewController:(PDFViewController*)pvc didFinishSearchAll:(SearchResult*)searchResult;
@end


@interface PDFViewController :UIViewController {
    NSString *filePath; // full path for pdf file to be opened
    NSString* version;
    id <PDFViewControllerDelegate>  delegate;
    int transitionType;
}
@property (nonatomic,retain) NSString* version;
@property (nonatomic,retain) NSString* filePath;
@property (nonatomic,retain) id <PDFViewControllerDelegate>   delegate;
@property int transitionType;

-(id)initWithStartPageIndex:(int)pageIndex;
-(void)gotoPageByPageIndex:(int)pageIndex;
-(void)gotoPrevPage;
-(void)gotoNextPage;
-(UIImage*)getPageImage:(int)pageIndex;
-(UIImage*)getThumbImage:(int)pageIndex;
-(void)searchKey:(NSString*)key;
-(int)getNumberOfPages;
-(void)debug0;
-(void)debug1;
-(void)debug2;
@end
