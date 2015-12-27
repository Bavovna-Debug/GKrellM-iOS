//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "Server.h"
#import "SRVSwapRecorder.h"

@interface SRVSwapRecorder ()

@property (assign, nonatomic, readwrite) UInt64  total;
@property (assign, nonatomic, readwrite) UInt64  used;

@property (weak,   nonatomic)            Server  *server;

@end

@implementation SRVSwapRecorder

@synthesize delegate = _delegate;

#pragma mark - Object cunstructors/destructors

- (id)initWithServer:(Server *)server
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.server = server;
    
    return self;
}

- (void)setDelegate:(id<SRVSwapRecorderDelegate>)delegate
{
    _delegate = delegate;

    if ((delegate != nil) && (self.total != 0))
        [delegate swapDataArrived:self];
}

#pragma mark - Parse input information

- (void)parseLine:(NSString *)line
{
    NSArray *parts = [line componentsSeparatedByString:@" "];
    if ([parts count] == 4) {
        long long total;
        long long used;
        
        NSScanner *scanner;
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:0]];
        [scanner scanLongLong:&total];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
        [scanner scanLongLong:&used];
        
        self.total = total;
        self.used = used;

        if (self.delegate != nil)
            [self.delegate swapDataArrived:self];
    }
}

- (UInt64)free
{
    return self.total - self.used;
}

@end
