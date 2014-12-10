//
//  MainViewController.h
//  CoreTest
//
//  Created by 허 지웅 on 11. 9. 6..
//  Copyright (c) 2011 Skytree Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReflowableViewController;
@class FixedViewController;
@class BookViewController;
@class AppDelegate;

@interface MainViewController : UIViewController {
    ReflowableViewController *rvc;
    FixedViewController *fvc;
    AppDelegate* ad;    
    int numberOfBooks;
    NSMutableArray *bookInformations;
}

@property int numberOfBooks;

-(IBAction)test00Click:(id)sender;
-(IBAction)test01Click:(id)sender;
-(IBAction)test02Click:(id)sender;
-(IBAction)test03Click:(id)sender;
-(IBAction)test04Click:(id)sender;

-(IBAction)testSpecial00:(id)sender;
-(IBAction)testSpecial01:(id)sender;
-(IBAction)testSpecial02:(id)sender;
-(IBAction)testSpecial03:(id)sender;

-(void)installSample:(NSString*)name;
-(void)installPDF:(NSString*)name;


@end
