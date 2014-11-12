//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SRVNetworkInterface.h"

@interface NetworkInterfaceCell : UITableViewCell

@property (strong, nonatomic) SRVNetworkInterface *interface;

- (void)refreshStopwatch;

@end
