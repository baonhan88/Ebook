//
//  main.m
//  CoreTest
//
//  Created by 허 지웅 on 11. 9. 1..
//  Copyright (c) 2011 Skytree Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    
    @autoreleasepool {
        int retVal = -1;
        @try {
            retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException* exception) {
            NSLog(@"Uncaught exception: %@", exception.description);
            NSLog(@"Stack trace: %@", [exception callStackSymbols]);
        }
        return retVal;
    }
}