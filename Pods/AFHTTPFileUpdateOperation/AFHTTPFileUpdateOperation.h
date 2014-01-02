//
//  AFHTTPFileUpdateOperation.h
//
//  Created by Roman Kříž on 19.07.13.
//  Copyright (c) 2013 samnung. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperation.h>

@interface AFHTTPFileUpdateOperation : AFHTTPRequestOperation

@property (nonatomic, strong, readonly) NSString * localPath;

/**
 * Creates instance of this operation.
 *
 * @note Please don't use method initWithRequest:, otherwise this will not work!
 */
- (instancetype) initWithRequest:(NSURLRequest *)urlRequest localPath:(NSString *)path;

- (void) setCompletionBlockWithSuccess:(void (^)(AFHTTPFileUpdateOperation *operation, NSData * data))success failure:(void (^)(AFHTTPFileUpdateOperation *operation, NSError *error))failure;

@end
