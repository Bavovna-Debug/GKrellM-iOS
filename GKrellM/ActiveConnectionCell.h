//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SRVConnectionRecord.h"

@interface ActiveConnectionCell : UITableViewCell

@property (strong, nonatomic) SRVConnectionRecord *connection;

- (void)animateAppearance;

- (void)animateDisappearance;

@end
