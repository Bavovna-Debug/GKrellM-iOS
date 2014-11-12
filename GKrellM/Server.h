//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "GCDAsyncSocket.h"

#import "SRVConnectionsRecorder.h"
#import "SRVMemoryRecorder.h"
#import "SRVMountsRecorder.h"
#import "SRVNetworkRecorder.h"
#import "SRVProcessorsRecorder.h"
#import "SRVSwapRecorder.h"
#import "XML.h"

#define DefaultPortNumber 19150

@protocol ServerConnectionDelegate;
@protocol ServerMonitoringDelegate;

@interface Server : NSObject

@property (weak,   nonatomic, readwrite) id<ServerConnectionDelegate>  connectionDelegate;
@property (weak,   nonatomic, readwrite) id<ServerMonitoringDelegate>  monitoringDelegate;

@property (strong, nonatomic, readonly)  NSString                *serverId;
@property (strong, nonatomic, readwrite) NSString                *serverName;
@property (strong, nonatomic, readwrite) NSString                *dnsName;
@property (assign, nonatomic, readwrite) UInt16                  portNumber;
@property (assign, nonatomic, readwrite) Boolean                 reconnectImmediately;
@property (assign, nonatomic, readwrite) NSTimeInterval          connectionTimeout;

@property (strong, nonatomic, readonly)  NSString                *serverToldVersion;
@property (strong, nonatomic, readonly)  NSString                *serverToldHostname;
@property (strong, nonatomic, readonly)  NSString                *serverToldSystemName;
@property (assign, nonatomic, readonly)  CGFloat                 serverToldIOTimeout;
@property (assign, nonatomic, readonly)  CGFloat                 serverToldReconnectTimeout;
@property (assign, nonatomic, readonly)  NSUInteger              serverUptime;

@property (strong, nonatomic, readonly)  SRVProcessorsRecorder   *processorsRecorder;
@property (strong, nonatomic, readonly)  SRVMemoryRecorder       *memoryRecorder;
@property (strong, nonatomic, readonly)  SRVSwapRecorder         *swapRecorder;
@property (strong, nonatomic, readonly)  SRVMountsRecorder       *mountsRecorder;
@property (strong, nonatomic, readonly)  SRVNetworkRecorder      *networkRecorder;
@property (strong, nonatomic, readonly)  SRVConnectionsRecorder  *connections;

+ (Server *)serverWithId:(NSString *)serverId
              serverName:(NSString *)serverName
                 dnsName:(NSString *)dnsName
              portNumber:(UInt16)portNumber;

+ (Server *)serverFromXML:(XMLElement *)serverElement;

- (id)initWithId:(NSString *)serverId
      serverName:(NSString *)serverName
         dnsName:(NSString *)dnsName;

- (XMLElement *)saveToXML;

- (void)setServerName:(NSString *)serverName;

- (void)setDnsName:(NSString *)dnsName;

- (void)setPortNumber:(UInt16)portNumber;

- (Boolean)monitoring;

- (void)startMonitoring;

- (void)stopMonitoring;

- (void)pauseMonitoring;

@end

@protocol ServerConnectionDelegate <NSObject>

@required

- (void)serverParameterChanged;

- (void)connectedToServer;

- (void)disconnectedFromServer;

@end

@protocol ServerMonitoringDelegate <NSObject>

@optional

- (void)clock;

- (void)serverUptimeReported;

@end
