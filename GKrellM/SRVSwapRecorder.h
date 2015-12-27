//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "SRVResourceRecorder.h"

@protocol SRVSwapRecorderDelegate;

@interface SRVSwapRecorder : SRVResourceRecorder

@property (weak,   nonatomic, readwrite) id<SRVSwapRecorderDelegate> delegate;

@property (assign, nonatomic, readonly)  UInt64  total;
@property (assign, nonatomic, readonly)  UInt64  used;
@property (assign, nonatomic, readonly)  UInt64  free;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol SRVSwapRecorderDelegate <NSObject>

@required

- (void)swapDataArrived:(SRVSwapRecorder *)recorder;

@end