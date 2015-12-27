//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
#import <UIKit/UIKit.h>

@interface Banner : NSObject

+ (Banner *)sharedBanner;

- (void)addBannerViewTo:(UIView *)view;

- (void)alertLimitationOnNumberOfServers;

@end
