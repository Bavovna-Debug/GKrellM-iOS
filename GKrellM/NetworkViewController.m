//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "NetworkInterfaceCell.h"
#import "NetworkViewController.h"
#import "Server.h"
#import "ServerPool.h"

#import "SRVNetworkInterface.h"
#import "SRVNetworkRecorder.h"

@interface NetworkViewController () <SRVNetworkRecorderDelegate>

@property (weak,   nonatomic) Server *server;
@property (strong, nonatomic) NSTimer *stopwatchTimer;

@end

@implementation NetworkViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.server = [[ServerPool sharedServerPool] currentServer];
    [[self.server networkRecorder] setDelegate:self];

    self.stopwatchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                           target:self
                                                         selector:@selector(hearthbeatStopwatch)
                                                         userInfo:nil
                                                          repeats:YES];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[self.server networkRecorder] setDelegate:nil];

    if (self.stopwatchTimer != nil) {
        NSTimer *timer = self.stopwatchTimer;
        self.stopwatchTimer = nil;
        [timer invalidate];
    }

    [super viewDidDisappear:animated];
}

- (void)networkInterfacesReset
{
    [self.tableView reloadData];
}

- (void)networkInterfaceDetected:(SRVNetworkInterface *)interface
{
    [self.tableView reloadData];
}

- (void)hearthbeatStopwatch
{
    if ([self.server monitoring] == NO)
        return;

    for (int section = 0; section < [self.tableView numberOfSections]; section++)
    {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            NetworkInterfaceCell *cell = (NetworkInterfaceCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell refreshStopwatch];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[self.server networkRecorder] interfaces] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NetworkInterfaceCell *cell;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NetworkInterfaceCellPhone"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NetworkInterfaceCellPad"];
    }
    [cell setInterface:[[[self.server networkRecorder] interfaces] objectAtIndex:indexPath.row]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 196.0f;
    } else {
        return 120.0f;
    }
}

@end
