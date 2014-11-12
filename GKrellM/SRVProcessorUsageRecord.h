//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRVProcessorUsageRecord : NSObject

@property (assign, nonatomic, readonly) NSInteger  processorId;
@property (assign, nonatomic, readonly) UInt64     userTime;
@property (assign, nonatomic, readonly) UInt64     niceTime;
@property (assign, nonatomic, readonly) UInt64     systemTime;
@property (assign, nonatomic, readonly) UInt64     idleTime;
@property (assign, nonatomic, readonly) UInt64     usedTime;

- (id)init;

- (id)initWithProcessorId:(NSInteger)processorId
                 userTime:(UInt64)userTime
                 niceTime:(UInt64)niceTime
               systemTime:(UInt64)systemTime
                 idleTime:(UInt64)idleTime;

- (void)addUserTime:(UInt64)userTime
           niceTime:(UInt64)niceTime
         systemTime:(UInt64)systemTime
           idleTime:(UInt64)idleTime;

- (UInt64)total;

@end
