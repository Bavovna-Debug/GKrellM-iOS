//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "ApplicationDelegate.h"
#import "Banner.h"
#import "ServerListViewController.h"
#import "MonitorTabBarController.h"
#import "ServerEditViewController.h"
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

@end
