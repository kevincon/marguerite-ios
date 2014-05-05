//
//  GTFSDatabaseAutoUpdater.h
//  marguerite
//
//

#import <Foundation/Foundation.h>

@interface GTFSUnarchiver : NSObject

- (BOOL) unzipTransitZipFile;
+ (NSString*) fullPathToDownloadedTransitUnzipDir;
+ (NSString*) fullPathToDownloadedTransitZippedFile;

@end
