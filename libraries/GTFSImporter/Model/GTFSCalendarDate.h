//
//  CalendarDate.h
//
//  Created by Kevin Conley on 6/25/2013.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"


@interface GTFSCalendarDate : NSObject

@property (nonatomic, strong) NSString * serviceId;
@property (nonatomic, strong) NSString * date;
@property (nonatomic, strong) NSString * exceptionType;

- (id)initWithDB:(FMDatabase *)fmdb;
- (void)addCalendarDate:(GTFSCalendarDate *)calendarDate;
- (void)cleanupAndCreate;
- (void)receiveRecord:(NSDictionary *)aRecord;

@end
