//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "SRVConnectionRecord.h"

@interface SRVConnectionRecord ()

@property (strong, nonatomic, readwrite) NSDate    *openedStamp;
@property (strong, nonatomic, readwrite) NSDate    *closedStamp;
@property (strong, nonatomic, readwrite) NSString  *ipAddress;
@property (assign, nonatomic, readwrite) UInt16    remotePort;
@property (assign, nonatomic, readwrite) UInt16    localPort;

@end

@implementation SRVConnectionRecord

@synthesize delegate = _delegate;

#pragma mark Object cunstructors/destructors

- (id)initWithIpAddress:(NSString *)ipAddress
             remotePort:(UInt16)remotePort
              localPort:(UInt16)localPort
{
    self = [super init];
    if (self == nil)
        return nil;

    self.openedStamp  = [NSDate date];
    self.closedStamp  = nil;

    self.ipAddress    = [NSString stringWithString:ipAddress];
    self.remotePort   = remotePort;
    self.localPort    = localPort;
    
    return self;
}

#pragma mark Class specific

- (Boolean)active
{
    return (self.closedStamp == nil);
}

- (void)flagConnectionClosed
{
    self.closedStamp  = [NSDate date];

    if (self.delegate != nil)
        [self.delegate connectionClosed:self];
}

@end
