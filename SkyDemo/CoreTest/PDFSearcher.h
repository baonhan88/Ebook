//
//  PDFSearch.h
//  CoreTest
//
//  Created by 허 지웅 on 12. 2. 14..
//  Copyright (c) 2012년 Skytree Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PDFSearcher : NSObject {
    CGPDFOperatorTableRef table;
    NSMutableString *currentData;
}
@property (nonatomic, retain) NSMutableString * currentData;
-(id)init;
-(BOOL)page:(CGPDFPageRef)inPage containsString:(NSString *)inSearchString;
@end
