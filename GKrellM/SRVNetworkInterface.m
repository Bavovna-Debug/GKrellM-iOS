//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "SRVNetworkInterface.h"

@interface SRVNetworkInterface ()

@property (strong, nonatomic, readwrite) NSString  *interfaceName;
@property (assign, nonatomic, readwrite) UInt64    rxBytesTotal;
@property (assign, nonatomic, readwrite) UInt64    txBytesTotal;
@property (assign, nonatomic, readwrite) UInt64    rxBytesGaging;
@property (assign, nonatomic, readwrite) UInt64    txBytesGaging;
@property (assign, nonatomic, readwrite) Boolean   gaging;
@property (strong, nonatomic, readwrite) NSDate    *gagingBegin;
@property (strong, nonatomic, readwrite) NSDate    *gagingEnd;

@end

@implementation SRVNetworkInterface

@synthesize delegate  = _delegate;
@synthesize gaging    = _gaging;

#pragma mark - Object cunstructors/destructors

- (id)initWithInterfaceName:(NSString *)interfaceName
               rxBytesTotal:(UInt64)rxBytesTotal
               txBytesTotal:(UInt64)txBytesTotal
{
    self = [super init];
    if (self == nil)
        return nil;

    self.interfaceName  = interfaceName;
    self.rxBytesTotal   = rxBytesTotal;
    self.txBytesTotal   = txBytesTotal;
    
    [self setGaging:YES];
    
    return self;
}

#pragma mark - Class specific

- (void)trafficRxBytes:(UInt64)rxBytes
               txBytes:(UInt64)txBytes
{
    BOOL somethingDisChange = NO;

    if (self.gaging) {
        UInt64 rxBytesGagingDelta = rxBytes - self.rxBytesTotal;
        UInt64 txBytesGagingDelta = txBytes - self.txBytesTotal;

        if (rxBytesGagingDelta > 0) {
            self.rxBytesGaging += rxBytesGagingDelta;
            somethingDisChange = YES;
        }

        if (txBytesGagingDelta > 0) {
            self.txBytesGaging += txBytesGagingDelta;
            somethingDisChange = YES;
        }
    }

    if (rxBytes != self.rxBytesTotal) {
        self.rxBytesTotal = rxBytes;
        somethingDisChange = YES;
    }

    if (txBytes != self.txBytesTotal) {
        self.txBytesTotal = txBytes;
        somethingDisChange = YES;
    }

    if (somethingDisChange == YES)
        if (self.delegate != nil)
            [self.delegate networkTrafficChanged:self];
}

- (Boolean)gaging
{
    return _gaging;
}

- (void)setGaging:(Boolean)gaging
{
    if ((_gaging == NO) && (gaging == YES)) {
        self.gagingBegin    = [NSDate date];
        self.rxBytesGaging  = 0;
        self.txBytesGaging  = 0;
        self.gagingEnd      = nil;
    } else if ((_gaging == YES) && (gaging == NO)) {
        self.gagingEnd = [NSDate date];
    }

    _gaging = gaging;
}

@end
