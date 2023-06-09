//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "ApplicationDelegate.h"
#import "Banner.h"
#import "ServerListViewController.h"
#import "MonitorTabBarController.h"
#import "ServerPool.h"

@interface ApplicationDelegate () <UISplitViewControllerDelegate>

@end

@implementation ApplicationDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[ServerPool sharedServerPool] loadServerList];

    [Banner sharedBanner];

    [application setIdleTimerDisabled:YES];

    [application setStatusBarHidden:YES];

    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    UINavigationItem *navigationItem = navigationController.topViewController.navigationItem;
    navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;

    [splitViewController setDelegate:self];

    [[UITableViewCell appearance] setBackgroundColor:[UIColor clearColor]];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[ServerPool sharedServerPool] prepareForBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[ServerPool sharedServerPool] prepareForBackground];
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    return [[ServerPool sharedServerPool] currentServer] == nil;
}

- (void)application:(UIApplication *)application
handleWatchKitExtensionRequest:(NSDictionary *)userInfo
              reply:(void (^)(NSDictionary *))reply
{
    NSLog(@"In iOS");

    NSString *title = [userInfo objectForKey:@"key1"];
    NSString *message = [userInfo objectForKey:@"request"];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"CANCEL"
                                              otherButtonTitles:nil];

    [alertView setAlertViewStyle:UIAlertViewStyleDefault];
    [alertView show];

    __block UIBackgroundTaskIdentifier watchKitHandler;
    watchKitHandler = [[UIApplication sharedApplication]
                       beginBackgroundTaskWithName:@"backgroundTask"
                       expirationHandler:^{
                           watchKitHandler = UIBackgroundTaskInvalid;
                       }];

    if ([[userInfo objectForKey:@"request"] isEqualToString:@"getData"]) {
        reply(nil);
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC * 1), dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UIApplication sharedApplication] endBackgroundTask:watchKitHandler];
    });
}

@end
