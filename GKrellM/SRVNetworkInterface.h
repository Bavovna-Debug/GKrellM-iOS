//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SRVNetworkInterfaceDelegate;

@interface SRVNetworkInterface : NSObject

@property (weak,   nonatomic, readwrite) id<SRVNetworkInterfaceDelegate> delegate;

@property (strong, nonatomic, readonly)  NSString  *interfaceName;
@property (assign, nonatomic, readonly)  UInt64    rxBytesTotal;
@property (assign, nonatomic, readonly)  UInt64    txBytesTotal;
@property (assign, nonatomic, readonly)  UInt64    rxBytesGaging;
@property (assign, nonatomic, readonly)  UInt64    txBytesGaging;
@property (assign, nonatomic, readonly)  Boolean   gaging;
@property (strong, nonatomic, readonly)  NSDate    *gagingBegin;
@property (strong, nonatomic, readonly)  NSDate    *gagingEnd;

- (id)initWithInterfaceName:(NSString *)interfaceName
               rxBytesTotal:(UInt64)rxBytesTotal
               txBytesTotal:(UInt64)txBytesTotal;

- (void)trafficRxBytes:(UInt64)rxBytes
               txBytes:(UInt64)txBytes;

- (Boolean)gaging;

- (void)setGaging:(Boolean)gaging;

@end

@protocol SRVNetworkInterfaceDelegate <NSObject>

@required

- (void)networkTrafficChanged:(SRVNetworkInterface *)interface;

@end
