//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Banner.h"
#import "MonitorTabBarController.h"
#import "Server.h"
#import "ServerPool.h"

@interface MonitorTabBarController () <CurrentServerDelegate>

@end

@implementation MonitorTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;

    ServerPool *serverPool = [ServerPool sharedServerPool];
    [serverPool setCurrentServerDelegate:self];

    Server *server = [serverPool currentServer];
    if (server != nil) {
        if (self.tabBar.hidden == YES)
            [self.tabBar setHidden:NO];

        [self.navigationItem setTitle:[server serverName]];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    Banner *banner = [Banner sharedBanner];
    if (banner != nil)
        [banner addBannerViewTo:self.view];
}

- (void)serverPool:(ServerPool *)serverPool
currentServerChangedTo:(Server *)server
{
    if (self.tabBar.hidden == YES)
        [self.tabBar setHidden:NO];

    [self.navigationItem setTitle:[server serverName]];
}

@end
