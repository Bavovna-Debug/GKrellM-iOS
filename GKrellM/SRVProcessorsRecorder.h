//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SRVResourceRecorder.h"

@protocol SRVProcessorsRecorderDelegate;

@interface SRVProcessorsRecorder : SRVResourceRecorder

@property (weak,   nonatomic, readwrite) id<SRVProcessorsRecorderDelegate> delegate;

@property (assign, nonatomic, readonly)  NSUInteger      numberOfProcessors;
@property (strong, nonatomic, readonly)  NSMutableArray  *history;
@property (assign, nonatomic, readonly)  CGFloat         fullLoadRange;

- (id)initWithServer:(NSObject *)server;

- (void)parseIntroductionLine:(NSString *)line;

- (void)nextRecord;

- (void)parseLine:(NSString *)line;

- (void)recalculateRange;

@end

@protocol SRVProcessorsRecorderDelegate <NSObject>

@required

- (void)processorDataArrived:(SRVProcessorsRecorder *)recorder;

@end