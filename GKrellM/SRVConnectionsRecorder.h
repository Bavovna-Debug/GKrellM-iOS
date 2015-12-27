//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "SRVConnectionRecord.h"
#import "SRVResourceRecorder.h"

@protocol SRVConnectionsRecorderDelegate;

@interface SRVConnectionsRecorder : SRVResourceRecorder

@property (weak,   nonatomic, readwrite) id<SRVConnectionsRecorderDelegate> delegate;

@property (strong, nonatomic, readonly)  NSMutableArray  *activeConnections;
@property (strong, nonatomic, readonly)  NSMutableArray  *closedConnections;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol SRVConnectionsRecorderDelegate <NSObject>

@required

- (void)connectionsCleared:(SRVConnectionsRecorder *)connectionsRecorder;

- (void)connectionsRecorder:(SRVConnectionsRecorder *)connectionsRecorder
         connectionAppeared:(SRVConnectionRecord *)connection;

- (void)connectionsRecorder:(SRVConnectionsRecorder *)connectionsRecorder
      connectionDisappeared:(SRVConnectionRecord *)connection;

@end