//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "Banner.h"

#define AdBannerHeight 50.0f

@interface Banner () <ADBannerViewDelegate>

@property (strong, nonatomic) ADBannerView *bannerView;

@end

@implementation Banner

#pragma mark - Object cunstructors/destructors

+ (Banner *)sharedBanner
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundleIdentifier = [bundle bundleIdentifier];
    if ([[bundleIdentifier substringFromIndex:[bundleIdentifier length] - 4] compare:@"Lite"] != NSOrderedSame)
        return nil;

    static dispatch_once_t onceToken;
    static Banner *banner;

    dispatch_once(&onceToken, ^{
        banner = [[Banner alloc] init];
    });

    return banner;
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;

    self.bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    [self.bannerView setDelegate:self];

    return self;
}

- (void)addBannerViewTo:(UIView *)view
{
    CGRect frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(view.frame), AdBannerHeight);

    if (self.bannerView.superview != view) {
        [self.bannerView removeFromSuperview];
        [self.bannerView setFrame:frame];
        [view addSubview:self.bannerView];
    } else {
        [self.bannerView setFrame:frame];
    }
}

#pragma mark - Ad banner delegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
#ifdef DEBUG
    NSLog(@"Ad banner loaded");
#endif

    if ([self.bannerView alpha] != 1.0f)
        [self.bannerView setAlpha:1.0f];
}

- (void)bannerView:(ADBannerView *)banner
didFailToReceiveAdWithError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"Failed to retrieve ad: %@", error);
#endif

    if ([self.bannerView alpha] != 0.0f)
        [self.bannerView setAlpha:0.0f];
}

#pragma mark - Alerts

- (void)alertLimitationOnNumberOfServers
{
    NSString *title = NSLocalizedString(@"ALERT_TITLE_LITE_VERSION", nil);
    NSString *message = NSLocalizedString(@"ALERT_YOU_ARE_USING_LITE_VERSION", nil);
    NSString *cancelButton = NSLocalizedString(@"ALERT_BUTTON_OK", nil);

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:cancelButton
                                              otherButtonTitles:nil];

    [alertView setAlertViewStyle:UIAlertViewStyleDefault];
    [alertView show];
}

@end
