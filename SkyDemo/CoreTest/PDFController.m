//
//  PDFController.m
//  CoreTest
//
//  Created by Jiung Heo on 12. 2. 9..
//  Copyright (c) 2012년 Skytree Corporation. All rights reserved.
//

//  !!!!! IMPORTANT !!!!!
//  The Advanced Demo sources are not the part of SkyEpub SDK.
//  These sources are written only to show how to use SkyEpub SDK.
//  The bugs found in this demo do not mean that SkyEpub SDK has the related bugs
//  Developers should change and modify this Advanced Demo sources for their purposes.
//  Any request to add/change/modify the Advanced Demo sources will be rejected.


#import "PDFController.h"
#import "ReflowableViewController.h"

@implementation PDFController

void XLog(NSString * formatString, ...);

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

-(NSString *)getDocumentsPath {
	// 파일패스의 설정
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;	
}

-(NSString*)getBooksDirectory {
	NSString *docPath = [self getDocumentsPath];
	NSString *booksDir = [docPath stringByAppendingFormat:@"/books"];	
	return booksDir;
}

-(NSString*)getPDFPath:(NSString*)pdfName {
    NSString *bookPath = [self getBooksDirectory];
    NSString *pdfPath = [bookPath stringByAppendingPathComponent:pdfName];
    return pdfPath;
}

-(void)writeImage:(UIImage *)image withFilename:(NSString* )filename {
    @autoreleasepool{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) ;    
        NSString *imagePath = [paths objectAtIndex:0] ;    
        NSString *filepath = [NSString stringWithFormat:@"%@/%@", imagePath, filename] ;    
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
        [imageData writeToFile:filepath atomically:YES];   
    }
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

-(void)pdfViewController:(PDFViewController*)fvc pageMoved:(PDFPageInformation*)pdfPageInformation {
    XLog(@"%d/%d = %f",pdfPageInformation.pageIndex,pdfPageInformation.numberOfPages,pdfPageInformation.pagePosition);
}

-(void)pdfViewController:(PDFViewController*)fvc didDetectTapAtPositionInView:(CGPoint)positionInView positionInPage:(CGPoint)positionInPage {
    XLog(@"tap Detected at %f,%f in View and %f,%f in Page",positionInView.x,positionInView.y,positionInPage.x,positionInPage.y);    
}

-(void)testPressed0:(id)sender {
//    [pvc gotoPrevPage];    
    [pvc debug0];
}

-(void)testPressed1:(id)sender {
    [pvc debug1];
}

-(void)testPressed2:(id)sender {
    [pvc debug2];
    //    [pvc searchKey:@"dashcode"];      
//    UIImage *image = [pvc getPageImage:5];
//    [self writeImage:image withFilename:@"Page.png"];
}

-(void)testPressed3:(id)sender {
    [self dismissModalViewControllerAnimated:NO];
}

-(void)pdfViewController:(PDFViewController *)rvc didSearchKey:(SearchResult *)searchResult {
    XLog(@"pi:%d ns:%d",searchResult.pageIndex,searchResult.numberOfSearched);
}

-(void)pdfViewController:(PDFViewController *)rvc didFinishSearchAll:(SearchResult *)searchResult {
    XLog(@"Search Procedure Finished");
}

-(void)makeBookViewer {
    pvc = [[PDFViewController alloc]initWithStartPageIndex:10];
    [self addChildViewController:pvc]; 
    pvc.delegate = self;
    pvc.filePath = [self getPDFPath:@"sampleP1.pdf"];
    pvc.view.frame = self.view.bounds;
    pvc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:pvc.view]; 
    self.view.autoresizesSubviews = YES;
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(30,20,60,35);
    [button addTarget:self action:@selector(testPressed0:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];	
    [self.view bringSubviewToFront:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100,20,60,35);
    [button addTarget:self action:@selector(testPressed1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];	
    [self.view bringSubviewToFront:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(170,20,60,35);
    [button addTarget:self action:@selector(testPressed2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];	
    [self.view bringSubviewToFront:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(240,20,60,35);
    [button addTarget:self action:@selector(testPressed3:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];	
    [self.view bringSubviewToFront:button];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeBookViewer];
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
    return YES;
}

@end
