//
//  AFHTTPFileUpdateOperation.m
//
//  Created by Roman Kříž on 19.07.13.
//  Copyright (c) 2013 samnung. All rights reserved.
//

#import "AFHTTPFileUpdateOperation.h"

// WEAK()
#import <SAMWeak/SAMWeak.h>


#define HTTP_NOT_MODIFIED_CODE 304

@implementation AFHTTPFileUpdateOperation

- (NSString *) formatDate:(NSDate *)date
{
	static dispatch_once_t onceToken;
	static NSDateFormatter * formatter = nil;
	dispatch_once(&onceToken, ^{
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss 'GMT'";
		formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	});

	return [formatter stringFromDate:date];
}

- (dispatch_queue_t) processingQueue
{
	static dispatch_once_t onceToken;
	static dispatch_queue_t queue;
	dispatch_once(&onceToken, ^{
		queue = dispatch_queue_create("com.alamofire.networking.local-file-update.processing", 0);
	});
    return queue;
}

- (instancetype) initWithRequest:(NSURLRequest *)urlRequest localPath:(NSString *)path
{
	NSFileManager * mgr = [NSFileManager defaultManager];

	BOOL dir = NO;

	// needToDownload = file didn't exists and is not a folder
	BOOL needToDownload = ! [mgr fileExistsAtPath:path isDirectory:&dir] && ! dir;
	if ( needToDownload )
	{
		self = [super initWithRequest:urlRequest];
	}
	else if ( dir )
	{
		NSLog(@"Cannot update file at: `%@', is a folder!", path);
		self = nil;
	}
	else
	{
		// --- getting info about file
		NSDictionary * info = [mgr attributesOfItemAtPath:path error:nil];
		NSDate * time = info[NSFileModificationDate];

		// --- add If-Modified-Since header to request
		NSMutableURLRequest * request = urlRequest.mutableCopy;
		[request setValue:[self formatDate:time] forHTTPHeaderField:@"If-Modified-Since"];

		self = [super initWithRequest:request];
	}

	if ( self )
	{
		_localPath = path;
	}

	return self;
}

- (instancetype) initWithRequest:(NSURLRequest *)urlRequest
{
	NSLog(@"Don't use %s in class %@, instead use initWithRequest:localPath: !", __PRETTY_FUNCTION__, [[self class] description]);
	return nil;
}

+ (NSSet *) acceptableContentTypes
{
	return nil;
}

+ (BOOL) canProcessRequest:(NSURLRequest *)request
{
	return YES;
}

+ (NSIndexSet *) acceptableStatusCodes
{
	NSMutableIndexSet * set = [super acceptableStatusCodes].mutableCopy;
	[set addIndex:HTTP_NOT_MODIFIED_CODE];
	return set;
}

- (void) setCompletionBlockWithSuccess:(void (^)(AFHTTPFileUpdateOperation *operation, NSData * data))success failure:(void (^)(AFHTTPFileUpdateOperation *operation, NSError *error))failure
{
	WEAK(self);

    self.completionBlock = ^
	{
        if ( [_self isCancelled] )
            return;

		// not modified
		if ( _self.response.statusCode == HTTP_NOT_MODIFIED_CODE )
		{
			if ( success )
			{
				NSData * data = [NSData dataWithContentsOfFile:_self.localPath options:NSDataReadingMappedIfSafe error:nil];
				dispatch_async( _self.successCallbackQueue ?: dispatch_get_main_queue(), ^{
					success(_self, data);
				});
			}
		}
		else if (_self.error)
		{
            if (failure)
			{
                dispatch_async(_self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                    failure(_self, _self.error);
                });
            }
        }
		else
		{
            dispatch_async([_self processingQueue], ^
			{
                NSData * data = _self.responseData;
				NSError * error = nil;

				if ( ! [data writeToFile:_self.localPath options:NSDataWritingAtomic error:&error] )
				{
					if ( failure )
					{
                        dispatch_async( _self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                            failure(_self, error);
                        });
                    }
				}
				else
				{
                    if ( success )
					{
                        dispatch_async( _self.successCallbackQueue ?: dispatch_get_main_queue(), ^{
                            success(_self, data);
                        });
                    }
                }
            });
        }
    };
}

@end
