//
//  EPubProvider.h
//  SkyEPub
//
//  Created by SkyTree on 14. 11. 13..
//  Copyright (c) 2014년 SkyEpub Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentProvider.h"

#import "zip/Objective-Zip/ZipFile.h"
#import "zip/Objective-Zip/ZipException.h"
#import "zip/Objective-Zip/FileInZipInfo.h"
#import "zip/Objective-Zip/ZipWriteStream.h"
#import "zip/Objective-Zip/ZipReadStream.h"

@interface EPubProvider : NSObject <ContentProvider> {
    long long contentLength;
    NSFileHandle *fileHandle;
    
    NSString *zipName;
    NSString *zipPath;
    NSString *contentPath;
    uLong fileSize;
    uLong fileOffset;
    
    ZipFile* unzipFile;
    FileInZipInfo *fileInfo;
    ZipReadStream *fileStream;
    
    NSData* fileData;
}

@end
