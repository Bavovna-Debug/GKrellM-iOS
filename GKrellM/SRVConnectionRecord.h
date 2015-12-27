//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SRVConnectionRecordDelegate;

@interface SRVConnectionRecord : NSObject

@property (weak,   nonatomic, readwrite) id<SRVConnectionRecordDelegate> delegate;

@property (strong, nonatomic, readonly)  NSDate    *openedStamp;
@property (strong, nonatomic, readonly)  NSDate    *closedStamp;
@property (strong, nonatomic, readonly)  NSString  *ipAddress;
@property (assign, nonatomic, readonly)  UInt16    remotePort;
@property (assign, nonatomic, readonly)  UInt16    localPort;

- (id)initWithIpAddress:(NSString *)ipAddress
             remotePort:(UInt16)remotePort
              localPort:(UInt16)localPort;

- (Boolean)active;

- (void)flagConnectionClosed;

@end

@protocol SRVConnectionRecordDelegate <NSObject>

@required

- (void)connectionClosed:(SRVConnectionRecord *)connectionRecord;

@end
