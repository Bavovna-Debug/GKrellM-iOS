//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SRVMountRecord.h"

@interface DiskUsageGraph : UIView

@property (weak, nonatomic) SRVMountRecord *mount;

- (void)updateGraph;

@end
