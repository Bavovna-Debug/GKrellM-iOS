//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SRVMountRecord.h"

@interface MountCell : UITableViewCell

@property (strong, nonatomic) SRVMountRecord *mount;

- (void)refresh;

- (void)showDiskGraph:(Boolean)show;

@end
