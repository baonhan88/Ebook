//
//  EPubProvider.m
//  SkyEPub
//
//  Created by SkyTree on 12. 10. 29..
//  Copyright (c) 2014년 SkyEpub Corporation. All rights reserved.
//

//  !!!!! IMPORTANT !!!!!
//  The Advanced Demo sources are not the part of SkyEpub SDK.
//  These sources are written only to show how to use SkyEpub SDK.
//  The bugs found in this demo do not mean that SkyEpub SDK has the related bugs
//  Developers should change and modify this Advanced Demo sources for their purposes.
//  Any request to add/change/modify the Advanced Demo sources will be refused.


#import "EPubProvider.h"

#import "zip/Objective-Zip/ZipFile.h"
#import "zip/Objective-Zip/ZipException.h"
#import "zip/Objective-Zip/FileInZipInfo.h"
#import "zip/Objective-Zip/ZipWriteStream.h"
#import "zip/Objective-Zip/ZipReadStream.h"

#define HUGE_TEST_BLOCK_LENGTH             (50000)
#define HUGE_TEST_NUMBER_OF_BLOCKS        (100000)

@implementation EPubProvider

// using path which was passed by engine, extract several infromation from it.
-(void)makePathInfo:(NSString*)path {
    unzipFile = nil;
    NSRange bookRange,prePathRange;
    bookRange = [path rangeOfString:@"books"];
    prePathRange = NSMakeRange(0,bookRange.location+bookRange.length);
    NSString* prePath = [path substringWithRange:prePathRange];
    NSString* lastPath = [path substringFromIndex:bookRange.location+bookRange.length];
    NSArray *components=[lastPath componentsSeparatedByString:@"/"];
    NSString* bookName = components[1];
    zipName = [NSString stringWithFormat:@"%@.epub",components[1]];
    zipPath = [NSString stringWithFormat:@"%@/%@",prePath,zipName];
    contentPath = [path substringFromIndex:(bookRange.location+bookRange.length+1+bookName.length+1)];
    fileOffset = 0;
}

// called by engine
// entry point.
-(void)setContentPath:(NSString *)path {
    [self makePathInfo:path];
    fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    contentLength = [fileHandle seekToEndOfFile];
    [fileHandle seekToFileOffset:0];
    
    unzipFile = [[ZipFile alloc] initWithFileName:zipPath mode:ZipFileModeUnzip];
    if ([unzipFile locateFileInZip:contentPath]) {
        fileInfo = [unzipFile getCurrentFileInZipInfo];
        fileSize = fileInfo.length;
        fileStream = [unzipFile readCurrentFileInZip];
    }
    NSMutableData *buffer= [[NSMutableData alloc] init];
    NSMutableData *data= [[NSMutableData alloc] init];
    // Reset buffer
    [buffer setLength:1024];
    
    // Loop on read stream
    int totalBytesRead= 0;
    do {
        unsigned long bytesRead= [fileStream readDataWithBuffer:buffer];
        if (bytesRead > 0) {
            // Write data
            [buffer setLength:bytesRead];
            totalBytesRead += bytesRead;
            [data appendData:buffer];
            NSLog(@"offset %ld",[fileStream getOffset]);
        }else {
            break;
        }
    } while (YES);
    
    [fileStream finishedReading];
    fileData = [NSData dataWithData:data];
}

//  you should return the length of content(file)
-(long long)lengthOfContent {
    long long length = 0;
    if (fileInfo!=NULL) {
        length = fileInfo.length;
    }
    return length;
}

//  should return the offset of content
-(long long)offsetOfContent {
    return fileOffset;
}

//  offset will be set by skyepub engine
-(void)setOffsetOfContent:(long long)offset {
    fileOffset = offset;
    [fileHandle seekToFileOffset:offset];
}

// should return the NSData for the content of given path with the size of given length.
// this can be invoked times depends the size of content and the size of buffer.
// make nsdata from offset to offset+length, and return it.
-(NSData*)dataForContent:(long long)length {
    long lengthLeft = fileSize - fileOffset;
    long lengthToRead = MIN(length,lengthLeft);
    NSData* part = [NSData dataWithBytesNoCopy:(char *)[fileData bytes] + fileOffset length:lengthToRead freeWhenDone:NO];
    
    if ([part length]==0 || part==nil) {
        return nil;
    }
    else {
        fileOffset+=[part length];
        return part;
    }
}

//  should return whether reading content is finished or not.
-(BOOL)isFinished {
    if (fileOffset>=fileSize) {
        return YES;
    }else {
        return NO;
    }
}

@end
