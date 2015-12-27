//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "MountCell.h"
#import "MountsViewController.h"
#import "Server.h"
#import "ServerPool.h"

#import "SRVMountsRecorder.h"

@interface MountsViewController () <SRVMountsRecorderDelegate>

@property (weak, nonatomic) Server *server;

@end

@implementation MountsViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UISwipeGestureRecognizer *swipeLeftGesture =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(cellSwipeLeft:)];
        [swipeLeftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.tableView addGestureRecognizer:swipeLeftGesture];
        
        UISwipeGestureRecognizer *swipeRightGesture =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(cellSwipeRight:)];
        [swipeRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.tableView addGestureRecognizer:swipeRightGesture];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.server = [[ServerPool sharedServerPool] currentServer];
    [[self.server mountsRecorder] setDelegate:self];

    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[self.server mountsRecorder] setDelegate:nil];

    [super viewDidDisappear:animated];
}

#pragma mark - Service delegate

- (void)mountsReset:(SRVMountsRecorder *)mountsRecorder
{
    [self.tableView reloadData];
}

- (void)mountsRecorder:(SRVMountsRecorder *)mountsRecorder
         mountDetected:(SRVMountRecord *)mount
{
    [self.tableView reloadData];
}

-(void)mountsRecorder:(SRVMountsRecorder *)mountsRecorder
         mountChanged:(SRVMountRecord *)mount
{
    for (int section = 0; section < [self.tableView numberOfSections]; section++)
    {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            MountCell *cell = (MountCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            if ([cell mount] == mount)
                [cell refresh];
        }
    }
}

#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[self.server mountsRecorder] mounts] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MountCell"];
    [cell setMount:[[[self.server mountsRecorder] mounts] objectAtIndex:indexPath.row]];

    return cell;
}

#pragma mark - Swipe

- (void)cellSwipeLeft:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    MountCell *cell = (MountCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell showDiskGraph:YES];
}

- (void)cellSwipeRight:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    MountCell *cell = (MountCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell showDiskGraph:NO];
}

@end
