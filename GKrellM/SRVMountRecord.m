//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "SRVMountRecord.h"

@interface SRVMountRecord ()

@property (strong, nonatomic, readwrite) NSString    *deviceName;
@property (strong, nonatomic, readwrite) NSString    *mountPoint;
@property (strong, nonatomic, readwrite) NSString    *fileSystem;
@property (assign, nonatomic, readwrite) NSUInteger  blockSize;
@property (assign, nonatomic, readwrite) NSUInteger  totalBlocks;
@property (assign, nonatomic, readwrite) NSUInteger  availableBlocks;
@property (assign, nonatomic, readwrite) NSUInteger  freeBlocks;

@end

@implementation SRVMountRecord

//@synthesize delegate = _delegate;

#pragma mark - Object cunstructors/destructors

- (id)initWithDeviceName:(NSString *)deviceName
              mountPoint:(NSString *)mountPoint
              fileSystem:(NSString *)fileSystem
               blockSize:(NSUInteger)blockSize
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.deviceName  = deviceName;
    self.mountPoint  = mountPoint;
    self.fileSystem  = fileSystem;
    self.blockSize   = blockSize;

    return self;
}

- (void)updateWithTotalBlocks:(NSUInteger)totalBlocks
              availableBlocks:(NSUInteger)availableBlocks
                   freeBlocks:(NSUInteger)freeBlocks;
{
    self.totalBlocks      = totalBlocks;
    self.availableBlocks  = availableBlocks;
    self.freeBlocks       = freeBlocks;

    /*if (self.delegate != nil)
        [self.delegate mountsRecorder:self
                         mountChanged:mount];*/
}

@end
