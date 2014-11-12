//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "SRVMountRecord.h"
#import "SRVResourceRecorder.h"

@protocol SRVMountsRecorderDelegate;

@interface SRVMountsRecorder : SRVResourceRecorder

@property (weak,   nonatomic, readwrite) id<SRVMountsRecorderDelegate> delegate;

@property (strong, nonatomic, readonly)  NSMutableArray  *mounts;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol SRVMountsRecorderDelegate <NSObject>

@required

- (void)mountsReset:(SRVMountsRecorder *)mountsRecorder;

- (void)mountsRecorder:(SRVMountsRecorder *)mountsRecorder
         mountDetected:(SRVMountRecord *)mount;

- (void)mountsRecorder:(SRVMountsRecorder *)mountsRecorder
          mountChanged:(SRVMountRecord *)mount;

@end