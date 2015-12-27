//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "SRVNetworkInterface.h"
#import "SRVResourceRecorder.h"

@protocol SRVNetworkRecorderDelegate;

@interface SRVNetworkRecorder : SRVResourceRecorder

@property (weak,   nonatomic, readwrite) id<SRVNetworkRecorderDelegate> delegate;

@property (strong, nonatomic, readonly)  NSMutableArray  *interfaces;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol SRVNetworkRecorderDelegate <NSObject>

@required

- (void)networkInterfacesReset;

- (void)networkInterfaceDetected:(SRVNetworkInterface *)interface;

@end