//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

//@protocol SRVMountRecordDelegate;

@interface SRVMountRecord : NSObject

//@property (weak,   nonatomic, readwrite) id<SRVMountRecordDelegate> delegate;

@property (strong, nonatomic, readonly)  NSString    *deviceName;
@property (strong, nonatomic, readonly)  NSString    *mountPoint;
@property (strong, nonatomic, readonly)  NSString    *fileSystem;
@property (assign, nonatomic, readonly)  NSUInteger  blockSize;
@property (assign, nonatomic, readonly)  NSUInteger  totalBlocks;
@property (assign, nonatomic, readonly)  NSUInteger  availableBlocks;
@property (assign, nonatomic, readonly)  NSUInteger  freeBlocks;

- (id)initWithDeviceName:(NSString *)deviceName
              mountPoint:(NSString *)mountPoint
              fileSystem:(NSString *)fileSystem
               blockSize:(NSUInteger)blockSize;

- (void)updateWithTotalBlocks:(NSUInteger)totalBlocks
              availableBlocks:(NSUInteger)availableBlocks
                   freeBlocks:(NSUInteger)freeBlocks;

@end

/*
@protocol SRVMountRecordDelegate <NSObject>

@required

- (void)mountsRecorder:(SRVMountsRecorder *)mountsRecorder
          mountChanged:(SRVMountRecord *)mount;

@end
*/
