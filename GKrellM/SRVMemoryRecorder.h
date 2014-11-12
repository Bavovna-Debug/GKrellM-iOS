//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "SRVResourceRecorder.h"

@protocol SRVMemoryRecorderDelegate;

@interface SRVMemoryRecorder : SRVResourceRecorder

@property (weak,   nonatomic, readwrite) id<SRVMemoryRecorderDelegate> delegate;

@property (assign, nonatomic, readonly)  UInt64  total;
@property (assign, nonatomic, readonly)  UInt64  used;
@property (assign, nonatomic, readonly)  UInt64  free;
@property (assign, nonatomic, readonly)  UInt64  shared;
@property (assign, nonatomic, readonly)  UInt64  buffers;
@property (assign, nonatomic, readonly)  UInt64  cached;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol SRVMemoryRecorderDelegate <NSObject>

@required

- (void)memoryDataArrived:(SRVMemoryRecorder *)recorder;

@end