//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "ActiveConnectionCell.h"
#import "ClosedConnectionCell.h"
#import "ConnectionsViewController.h"
#import "Server.h"
#import "ServerPool.h"

#import "SRVConnectionsRecorder.h"
#import "SRVConnectionRecord.h"

@interface ConnectionsViewController () <SRVConnectionsRecorderDelegate>

@property (weak,   nonatomic) Server          *server;
@property (strong, nonatomic) NSMutableArray  *activeRows;
@property (strong, nonatomic) NSMutableArray  *closedRows;
@property (strong, nonatomic) NSMutableArray  *activeQueue;
@property (strong, nonatomic) NSMutableArray  *closedQueue;
@property (strong, nonatomic) NSMutableArray  *movingQueue;
@property (strong, nonatomic) NSLock          *queueLock;
@property (strong, nonatomic) NSTimer         *queueTimer;

@end

#define StepsToRevalidateQueues 12

@implementation ConnectionsViewController
{
    int stepsToRevalidateQueues;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.movingQueue = [NSMutableArray array];
    self.activeRows = [NSMutableArray array];
    self.closedRows = [NSMutableArray array];

    self.activeQueue = [NSMutableArray array];
    self.closedQueue = [NSMutableArray array];

    self.queueLock = [[NSLock alloc] init];

    self.queueTimer =
    [NSTimer scheduledTimerWithTimeInterval:0.25f
                                     target:self
                                   selector:@selector(processQueue)
                                   userInfo:nil
                                    repeats:YES];

    stepsToRevalidateQueues = StepsToRevalidateQueues;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.server = [[ServerPool sharedServerPool] currentServer];
    [[self.server connections] setDelegate:self];

    [self refreshListsWithLock:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[self.server connections] setDelegate:nil];

    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [self.queueLock lock];

    [self.activeQueue removeAllObjects];
    [self.closedQueue removeAllObjects];
    [self.movingQueue removeAllObjects];
    [self.activeRows removeAllObjects];
    [self.closedRows removeAllObjects];

    [self.tableView reloadData];

    [self.queueLock unlock];

    [super viewDidDisappear:animated];
}

- (void)refreshListsWithLock:(BOOL)withLock
{
    if (withLock == YES)
        [self.queueLock lock];

    [self.activeQueue removeAllObjects];
    [self.closedQueue removeAllObjects];
    [self.movingQueue removeAllObjects];
    [self.activeRows removeAllObjects];
    [self.closedRows removeAllObjects];

    SRVConnectionsRecorder *connectionsRecorder = [self.server connections];

    for (SRVConnectionRecord *connection in [connectionsRecorder activeConnections])
        [self.activeRows insertObject:connection
                              atIndex:0];

    for (SRVConnectionRecord *connection in [connectionsRecorder closedConnections])
        [self.closedRows insertObject:connection
                              atIndex:0];

    [self.tableView reloadData];

    if (withLock == YES)
        [self.queueLock unlock];
}

- (BOOL)wide
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (CGRectGetWidth(self.view.bounds) > 664.0f) {
            return YES;
        /*} else if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) == YES) {
            if (CGRectGetWidth(self.view.bounds) > 480.0f) {
                return YES;
            } else {
                return NO;
            }*/
        } else {
            return NO;
        }
    } else {
        return YES;
    }
}

#pragma mark - Service delegate

- (void)connectionsCleared:(SRVConnectionsRecorder *)connectionsRecorder
{
    [self refreshListsWithLock:YES];
}

- (void)connectionsRecorder:(SRVConnectionsRecorder *)connectionsRecorder
         connectionAppeared:(SRVConnectionRecord *)connection
{
    [self.activeQueue addObject:connection];
}

- (void)connectionsRecorder:(SRVConnectionsRecorder *)connectionsRecorder
      connectionDisappeared:(SRVConnectionRecord *)connection
{
    [self.closedQueue addObject:connection];
}

#pragma mark - Queue

- (void)processQueue
{
    if ([self.queueLock tryLock] == NO) {
        NSLog(@"Queue is busy");
        return;
    }

    [self processActiveQueue];
    [self processClosedQueue];
    [self processMovingQueue];

    stepsToRevalidateQueues--;
    if (stepsToRevalidateQueues == 0) {
        [self revalidateQueues];
        stepsToRevalidateQueues = StepsToRevalidateQueues;
    }

    [self.queueLock unlock];
}

- (void)processActiveQueue
{
    do {
        SRVConnectionRecord *connection = [self.activeQueue firstObject];
        if (connection == nil)
            break;

        [self.activeQueue removeObject:connection];

        NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithObjects:
                                      [NSIndexPath indexPathForRow:0 inSection:0],
                                      nil];

        [self.tableView beginUpdates];

        @try
        {
            [self.activeRows insertObject:connection
                                  atIndex:0];

            [self.tableView insertRowsAtIndexPaths:indexPaths
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
        @catch (NSException *exception)
        {
            NSLog(@"Inconsistency by cell insert: %@", exception);
            [self refreshListsWithLock:NO];
        }

        [self.tableView endUpdates];
    } while ([self.activeQueue count] > 0);
}

- (void)processClosedQueue
{
    do {
        SRVConnectionRecord *connection = [self.closedQueue firstObject];
        if (connection == nil)
            break;

        [self.closedQueue removeObject:connection];
        [self.movingQueue addObject:connection];
    } while ([self.closedQueue count] > 0);
}

- (void)processMovingQueue
{
    NSDate *now = [NSDate date];

    Boolean movedAny;
    do {
        movedAny = NO;

        for (SRVConnectionRecord *connection in self.movingQueue)
        {
            NSTimeInterval sinceClose = [now timeIntervalSinceDate:[connection closedStamp]];
            if (sinceClose >= 2.0f) {
                [self.movingQueue removeObject:connection];

                [connection setDelegate:nil];

                NSUInteger rowIndex = [self.activeRows indexOfObject:connection];
                NSMutableArray *activeIndexPaths = [[NSMutableArray alloc] initWithObjects:
                                                    [NSIndexPath indexPathForRow:rowIndex inSection:0],
                                                    nil];
                NSMutableArray *closedIndexPaths = [[NSMutableArray alloc] initWithObjects:
                                                    [NSIndexPath indexPathForRow:0 inSection:1],
                                                    nil];
                [self.tableView beginUpdates];

                @try
                {
                    [self.activeRows removeObject:connection];

                    [self.tableView deleteRowsAtIndexPaths:activeIndexPaths
                                          withRowAnimation:UITableViewRowAnimationFade];

                    [self.closedRows insertObject:connection
                                          atIndex:0];

                    [self.tableView insertRowsAtIndexPaths:closedIndexPaths
                                          withRowAnimation:UITableViewRowAnimationFade];
                }
                @catch (NSException *exception)
                {
                    NSLog(@"Inconsistency by cell move: %@", exception);
                    [self refreshListsWithLock:NO];
                }

                [self.tableView endUpdates];

                movedAny = YES;

                break;
            }
        }
    } while (movedAny == YES);
}

- (void)revalidateQueues
{
    for (SRVConnectionRecord *connection in self.activeRows)
        if ([connection active] == NO)
            [self.closedQueue addObject:connection];
}

#pragma mark - UITableView delegate

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"CONNECTIONS_HEADER_ACTIVE", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"CONNECTIONS_HEADER_CLOSED", nil);
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.activeRows count];
    } else if (section == 1) {
        return [self.closedRows count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try
    {
        if (indexPath.section == 0) {
            SRVConnectionRecord *connection = [self.activeRows objectAtIndex:indexPath.row];

            ActiveConnectionCell *cell;

            /*cell = (ActiveConnectionCell *)[connection delegate];

            if (cell == nil) {*/
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"ActiveConnectionCell"];

                [cell setConnection:connection];
            //}

            if ([cell connection] != connection)
                [self.closedQueue addObject:connection];

            return cell;
        } else if (indexPath.section == 1) {
            SRVConnectionRecord *connection = [self.closedRows objectAtIndex:indexPath.row];

            ClosedConnectionCell *cell;

            //cell = (ClosedConnectionCell *)[connection delegate];

            if (cell == nil) {
                if ([self wide] == YES)
                    cell = [self.tableView dequeueReusableCellWithIdentifier:@"ClosedConnectionCellWide"];
                else
                    cell = [self.tableView dequeueReusableCellWithIdentifier:@"ClosedConnectionCellNarrow"];

                [cell setConnection:connection];
            }

            return cell;
        } else {
            NSLog(@"Section number out of range");
            [self.tableView reloadData];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Cell number out of range");
        [self.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 28.0f;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 22.0f;
    } else if (indexPath.section == 1) {
        if ([self wide] == YES) {
            return 22.0f;
        } else {
            return 32.0f;
        }
    } else {
        return 0.0f;
    }
}

@end
