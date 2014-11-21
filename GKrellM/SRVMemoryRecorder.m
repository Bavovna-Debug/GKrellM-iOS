//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Server.h"
#import "ServerPool.h"
#import "SRVMemoryRecorder.h"

@interface SRVMemoryRecorder ()

@property (assign, nonatomic, readwrite) UInt64  total;
@property (assign, nonatomic, readwrite) UInt64  used;
@property (assign, nonatomic, readwrite) UInt64  free;
@property (assign, nonatomic, readwrite) UInt64  shared;
@property (assign, nonatomic, readwrite) UInt64  buffers;
@property (assign, nonatomic, readwrite) UInt64  cached;

@property (weak,   nonatomic)            Server  *server;

@end

@implementation SRVMemoryRecorder

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

- (void)setDelegate:(id<SRVMemoryRecorderDelegate>)delegate
{
    _delegate = delegate;

    if ((delegate != nil) && (self.total != 0))
        [delegate memoryDataArrived:self];
}

#pragma mark - Parse input information

- (void)parseLine:(NSString *)line
{
    NSArray *parts = [line componentsSeparatedByString:@" "];
    if ([parts count] == 5) {
        long long total;
        long long used;
        long long free;
        long long buffers;
        long long cached;
        
        NSScanner *scanner;
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:0]];
        [scanner scanLongLong:&total];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
        [scanner scanLongLong:&used];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:2]];
        [scanner scanLongLong:&free];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:3]];
        [scanner scanLongLong:&buffers];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:4]];
        [scanner scanLongLong:&cached];
        
        self.total = total;
        self.used = used;
        self.free = free;
        self.buffers = buffers;
        self.cached = cached;
    } else if ([parts count] == 6) {
        long long total;
        long long used;
        long long free;
        long long shared;
        long long buffers;
        long long cached;
        
        NSScanner *scanner;
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:0]];
        [scanner scanLongLong:&total];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
        [scanner scanLongLong:&used];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:2]];
        [scanner scanLongLong:&free];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:3]];
        [scanner scanLongLong:&shared];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:4]];
        [scanner scanLongLong:&buffers];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:5]];
        [scanner scanLongLong:&cached];
        
        self.total = total;
        self.used = used;
        self.free = free;
        self.shared = shared;
        self.buffers = buffers;
        self.cached = cached;
    } else {
        return;
    }

#ifdef SCREENSHOTING
#define Factor 16;
    self.total    *= Factor;
    self.used     *= Factor;
    self.free     *= Factor;
    self.shared   *= Factor;
    self.buffers  *= Factor;
    self.cached   *= Factor;

    UInt64 exchanger;
    exchanger    = self.used;
    self.used    = self.cached;
    self.cached  = exchanger;
#endif

    if (self.delegate != nil)
        [self.delegate memoryDataArrived:self];
}

@end
