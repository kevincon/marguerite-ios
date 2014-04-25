//
//  DataDownloader.m
//  SNLaunchPad
//
//  Created by Ashok Kunaparaju on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataDownloader.h"

#define HTTP_NOT_MODIFIED_CODE 304

@interface DataDownloader()

@property(nonatomic, strong) NSURLConnection* connection;
@property(nonatomic, strong) NSMutableData *activeDownloadDataBuffer;
@property(nonatomic, strong) NSData* downloadedData;
@property(nonatomic, strong) NSURL* urlToDownloadFrom;
@property(nonatomic, assign) BOOL notifiedDelegate;
@property(nonatomic, strong, readonly) NSString * localPath;
@property(nonatomic, strong) NSHTTPURLResponse* httpURLResponse;
@property(nonatomic, weak) NSObject<DataDownloadDone>* dataDownloadDelegate;

@end

@implementation DataDownloader

@synthesize httpURLResponse;
@synthesize downloadedData;
@synthesize urlToDownloadFrom;
@synthesize activeDownloadDataBuffer;
@synthesize dataDownloadDelegate;
@synthesize connection;
@synthesize notifiedDelegate;
@synthesize localPath;

- (NSDateFormatter*)dateFormatter {
    static dispatch_once_t onceToken;
	static NSDateFormatter * formatter = nil;
	dispatch_once(&onceToken, ^{
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss 'GMT'";
		formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	});
    return formatter;
}

- (NSString *) formatDate:(NSDate *)date
{
	return [[self dateFormatter] stringFromDate:date];
}

- (NSDate *) dateFromStr:(NSString *)dateStr
{
	return [[self dateFormatter] dateFromString:dateStr];
}

- (id) initWithURL:(NSURL*)url localPath:(NSString*)path downloadDelegate:(NSObject<DataDownloadDone>*)delegate {
    self = [super init];
    if (self) {
        urlToDownloadFrom = url;
        dataDownloadDelegate = delegate;
        localPath = path;
    }
    return self;
}

- (void)startDownload
{
    notifiedDelegate = NO;
    self.activeDownloadDataBuffer = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL: urlToDownloadFrom];
    [self setIfModifiedSinceHeaderOnRequest:urlRequest];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    self.connection = conn;
}

- (void) setIfModifiedSinceHeaderOnRequest:(NSMutableURLRequest*)urlRequest {
    NSFileManager * mgr = [NSFileManager defaultManager];
    NSDictionary * info = [mgr attributesOfItemAtPath:localPath error:nil];
    NSDate * time = info[NSFileModificationDate];
    /* for testing*/  //time = [self dateFromStr:@"WED, 16 APR 2014 17:12:38 GMT"];
    [urlRequest setValue:[self formatDate:time] forHTTPHeaderField:@"If-Modified-Since"];
    NSLog(@"If-Modified-Since is %@", time);
}

- (void)cancelDownload
{
    self.dataDownloadDelegate = nil;
    [self.connection cancel];
    self.connection = nil;
    self.activeDownloadDataBuffer = nil;
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.httpURLResponse = (NSHTTPURLResponse*)response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownloadDataBuffer appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownloadDataBuffer = nil;
    // Release the connection now that it's finished
    self.connection = nil;
    NSLog(@"error downloading data: %@",[error localizedDescription]);
    [dataDownloadDelegate dataDownloadFailed:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.downloadedData = activeDownloadDataBuffer;
    self.activeDownloadDataBuffer = nil;
    if (!dataDownloadDelegate || ![dataDownloadDelegate isKindOfClass:[NSObject class]]) {
        NSLog(@"delegate is nil or not pointing to correct address!");
    } else  {
        if (!notifiedDelegate) {
            if ( httpURLResponse.statusCode == HTTP_NOT_MODIFIED_CODE ) {
                NSLog(@"File was not modified, loading local file.");
                NSData * data = [NSData dataWithContentsOfFile:localPath options:NSDataReadingMappedIfSafe error:nil];
                [dataDownloadDelegate cachedDataDownloadDone:data];
            } else {
                NSError * error = nil;
                if ( ! [downloadedData writeToFile:localPath options:NSDataWritingAtomic error:&error] ) {
                    NSLog(@"Error while writing data downloaded from server : %@",[error localizedDescription]);
                    [dataDownloadDelegate dataDownloadFailed:error];
                } else {
                    [dataDownloadDelegate dataDownloadDone:downloadedData];
                }
            }
            notifiedDelegate = YES;
        }
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

@end
