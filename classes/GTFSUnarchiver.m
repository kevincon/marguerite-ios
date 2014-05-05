//
//  GTFSDatabaseAutoUpdater.m
//  marguerite
//
//

#import "GTFSUnarchiver.h"
#import <SSZipArchive.h>
#import "secrets.h"
#import "GTFSDatabase.h"
#import "Util.h"

NSString* const TRANSIT_ZIP_FILE_NAME = @"transit.zip";
NSString* const TRANSIT_UNZIP_TO_DIR = @"TransitFilesUnzipped";

@interface GTFSUnarchiver()

@end

@implementation GTFSUnarchiver

#pragma mark public methods

+ (NSString*) fullPathToDownloadedTransitUnzipDir {
    NSString* documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* localTransitUnzipDirFullPath = [documentsDirectoryPath stringByAppendingPathComponent:TRANSIT_UNZIP_TO_DIR];
    return localTransitUnzipDirFullPath;
}

+ (NSString*) fullPathToDownloadedTransitZippedFile {
    NSString* documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* localTransitZipFileFullPath = [documentsDirectoryPath stringByAppendingPathComponent:TRANSIT_ZIP_FILE_NAME];
    return localTransitZipFileFullPath;
}

- (BOOL) unzipTransitZipFile {
    //first clean all previously unzipped files
    NSString* unzipDirFullPath = [GTFSUnarchiver fullPathToDownloadedTransitUnzipDir];
    if ([self deleteAndRecreateUnzipDir:unzipDirFullPath]) {
        NSString* zipFileFullPath = [GTFSUnarchiver fullPathToDownloadedTransitZippedFile];
        NSError* error;
        BOOL unzipSuccess = [SSZipArchive unzipFileAtPath:zipFileFullPath toDestination:unzipDirFullPath overwrite:YES password:nil error:&error];
//for testing [self logUnzippedDirContents];
        NSLog(@"Unzip result : %@. %@",unzipSuccess?@"success":@"fail", unzipSuccess?@"":[error localizedDescription]);
        return unzipSuccess;
    }
    return NO;
}

#pragma mark private methods

- (BOOL) deleteAndRecreateUnzipDir:(NSString*)unzipDirFullPath {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    if ([fileManager fileExistsAtPath:unzipDirFullPath]) {
        BOOL dirCleanSuccess = [fileManager removeItemAtPath:unzipDirFullPath error:&error];
        NSLog(@"Deleting unzip dir result : %@. %@",dirCleanSuccess?@"success":@"fail", dirCleanSuccess?@"":[error localizedDescription]);
        if (dirCleanSuccess) {
            BOOL dirCreateSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:unzipDirFullPath withIntermediateDirectories:YES attributes:Nil error:&error];
            NSLog(@"Creating unzip dir result : %@. %@",dirCreateSuccess?@"success":@"fail", dirCreateSuccess?@"":[error localizedDescription]);
        }
        return dirCleanSuccess;
    }
    return YES;
}

- (void) logUnzippedDirContents {
    NSString* localTransitZipFileUnzipDirFullPath = [GTFSUnarchiver fullPathToDownloadedTransitUnzipDir];
    NSError* error;
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localTransitZipFileUnzipDirFullPath error:&error];
    if (!contents) {
        NSLog(@"Could not list contents of unzip directory! Error : %@",[error localizedDescription]);
    } else {
        for (NSString* contentPath in contents) {
            NSLog(@"Unzip dir content : %@",contentPath);
        }
    }
}

@end
