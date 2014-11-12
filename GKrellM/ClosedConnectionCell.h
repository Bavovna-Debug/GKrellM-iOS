//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SRVConnectionRecord.h"

@interface ClosedConnectionCell : UITableViewCell

@property (strong, nonatomic) SRVConnectionRecord *connection;

- (void)animateAppearance;

@end
