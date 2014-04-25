//
//  DataDownloader.h
//  SNLaunchPad
//
//  Created by Ashok Kunaparaju on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataDownloadDone <NSObject>

- (void) dataDownloadDone:(NSData*)data;
- (void) cachedDataDownloadDone:(NSData*)data;
- (void) dataDownloadFailed:(NSError*)error;

@end

@interface DataDownloader : NSObject<NSURLConnectionDelegate> {

}

- (id) initWithURL:(NSURL*)url localPath:(NSString *)path downloadDelegate:(NSObject<DataDownloadDone>*)delegate;
- (void) startDownload;
- (void) cancelDownload;

@end
