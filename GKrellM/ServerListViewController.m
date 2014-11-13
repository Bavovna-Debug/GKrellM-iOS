//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Banner.h"
#import "MonitorTabBarController.h"
#import "ServerListViewController.h"
#import "Server.h"
#import "ServerEditViewController.h"
#import "ServerGroup.h"
#import "ServerInfoViewController.h"
#import "ServerPool.h"

@interface ServerListViewController () <UIAlertViewDelegate, ServerPoolDelegate>

@property (strong, nonatomic) UIBarButtonItem *addServerButton;
@property (strong, nonatomic) UIBarButtonItem *showServerGroupsButton;

@end

@implementation ServerListViewController
{
    Server *serverUnderCursor;
}

#pragma mark UI events

- (void)awakeFromNib
{
    [super awakeFromNib];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self setClearsSelectionOnViewWillAppear:NO];
        [self setPreferredContentSize:CGSizeMake(320.0f, CGRectGetHeight(self.view.frame))];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f)
            [self.splitViewController setMaximumPrimaryColumnWidth:320.0f];
    }

    [self.tableView setEditing:NO];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    //self.editButtonItem.tag = 20;

    self.addServerButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                  target:self
                                                  action:@selector(openServerEditForm:)];

    self.showServerGroupsButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BAR_BUTTON_GROUPS", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(openServerEditForm:)];

    self.navigationItem.rightBarButtonItem = self.addServerButton;

    [[ServerPool sharedServerPool] setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        Banner *banner = [Banner sharedBanner];
        if (banner != nil)
            [banner addBannerViewTo:self.view];
    }
}

- (void)openServerEditForm:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ServerEditForm"
                                                        bundle:nil];
    ServerEditViewController *serverEditForm = [storyboard instantiateInitialViewController];

    [self presentViewController:serverEditForm
                       animated:YES
                     completion:nil];
}

- (void)openServerEditFormForServer:(Server *)server
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ServerEditForm"
                                                         bundle:nil];
    ServerEditViewController *serverEditForm = [storyboard instantiateInitialViewController];

    [serverEditForm setServer:server];

    [self presentViewController:serverEditForm
                       animated:YES
                     completion:nil];
}

- (void)askForServerDeleteConfirmation:(Server *)server
{
    NSString *title = NSLocalizedString(@"ALERT_TITLE_CONFIRMATION", nil);
    NSString *message = NSLocalizedString(@"ALERT_DELETE_SERVER_MESSAGE", nil);
    NSString *cancelButton = NSLocalizedString(@"ALERT_BUTTON_NO", nil);
    NSString *submitButton = NSLocalizedString(@"ALERT_BUTTON_YES", nil);

    message = [NSString stringWithFormat:message, [server serverName]];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelButton
                                              otherButtonTitles:submitButton, nil];

    serverUnderCursor = server;

    [alertView setAlertViewStyle:UIAlertViewStyleDefault];
    [alertView show];
}

- (void)openServerInfoPanel:(Server *)server
{
    NSArray* xibContents = [[NSBundle mainBundle] loadNibNamed:@"ServerInfoPanel"
                                                         owner:nil
                                                       options:nil];
    ServerInfoViewController *serverInfoPanel = [xibContents firstObject];

    [serverInfoPanel setServer:server];

    CGSize panelSize = CGSizeMake(300.0f, 180.0f);

    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f) {
        CGRect panelFrame = CGRectMake(([UIScreen mainScreen].applicationFrame.size.height / 2) - (panelSize.width / 2),
                                       ([UIScreen mainScreen].applicationFrame.size.width / 2) - (panelSize.height / 2),
                                       panelSize.width,
                                       panelSize.height);

        [serverInfoPanel.view.superview setFrame:panelFrame];
        [serverInfoPanel.view.superview setBounds:CGRectMake(0.0f, 0.0f, panelSize.width, panelSize.height)];
    } else {
        [serverInfoPanel setPreferredContentSize:panelSize];
    }

    [self presentViewController:serverInfoPanel
                       animated:YES
                     completion:nil];
}

- (Server *)serverForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServerPool *serverPool = [ServerPool sharedServerPool];
    ServerGroup *serverGroup = [serverPool.serverGroups objectAtIndex:indexPath.section];
    Server *server = [serverGroup.servers objectAtIndex:indexPath.row];

    return server;
}

- (NSIndexPath *)indexPathForServer:(Server *)server
{
    ServerPool *serverPool = [ServerPool sharedServerPool];
    for (ServerGroup *serverGroup in [serverPool serverGroups])
    {
        NSUInteger serverIndex = [[serverGroup servers] indexOfObject:server];
        if (serverIndex != NSNotFound) {
            NSUInteger serverGroupIndex = [[serverPool serverGroups] indexOfObject:serverGroup];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:serverIndex
                                                        inSection:serverGroupIndex];
            return indexPath;
        }
    }

    return nil;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showServer"]) {
        NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
        ServerPool *serverPool = [ServerPool sharedServerPool];
        ServerGroup *serverGroup = [serverPool.serverGroups objectAtIndex:selection.section];
        Server *server = [serverGroup.servers objectAtIndex:selection.row];
        [serverPool setCurrentServer:server];

        /*MonitorTabBarController *monitor = (MonitorTabBarController *)[[segue destinationViewController] topViewController];
        monitor.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        monitor.navigationItem.leftItemsSupplementBackButton = YES;

        [monitor.navigationItem setTitle:[server serverName]];
        [monitor.tabBar setHidden:NO];*/

        if ([server monitoring] == NO)
            [server startMonitoring];
    }
}

#pragma mark UITableView delegate

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    ServerPool *serverPool = [ServerPool sharedServerPool];
    ServerGroup *serverGroup = [serverPool.serverGroups objectAtIndex:section];
    return [serverGroup name];
}

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    ServerPool *serverPool = [ServerPool sharedServerPool];
    return [[serverPool serverGroups] count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    ServerPool *serverPool = [ServerPool sharedServerPool];
    ServerGroup *serverGroup = [serverPool.serverGroups objectAtIndex:section];
    return [[serverGroup servers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServerPool *serverPool = [ServerPool sharedServerPool];
    ServerGroup *serverGroup = [serverPool.serverGroups objectAtIndex:indexPath.section];
    Server *server = [serverGroup.servers objectAtIndex:indexPath.row];

    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"ServerListCell"];

    NSString *detailText = (server.portNumber == DefaultPortNumber)
        ? [server dnsName]
        : [NSString stringWithFormat:@"%@:%d", server.dnsName, server.portNumber];
    [cell.textLabel setText:[server serverName]];
    [cell.detailTextLabel setText:detailText];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    ServerPool *serverPool = [ServerPool sharedServerPool];

    ServerGroup *sourceServerGroup = [[serverPool serverGroups] objectAtIndex:sourceIndexPath.section];
    ServerGroup *destinationServerGroup = [[serverPool serverGroups] objectAtIndex:destinationIndexPath.section];

    Server *server = [[sourceServerGroup servers] objectAtIndex:sourceIndexPath.row];

    [[sourceServerGroup servers] removeObjectAtIndex:sourceIndexPath.row];
    [[destinationServerGroup servers] insertObject:server
                                           atIndex:destinationIndexPath.row];
    [serverPool saveServerList];

    [tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if ([tableView isEditing] == NO) {
        [self.navigationItem setRightBarButtonItem:self.addServerButton];
    } else {
        [self.navigationItem setRightBarButtonItem:self.showServerGroupsButton];
    }*/

    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView
editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Server *server = [self serverForRowAtIndexPath:indexPath];
    if ([server monitoring] == NO) {
        UITableViewRowAction *editAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                           title:NSLocalizedString(@"SERVER_LIST_ACTION_EDIT", nil)
                                         handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
         {
             Server *server = [self serverForRowAtIndexPath:indexPath];
             [self openServerEditFormForServer:server];
         }];
        [editAction setBackgroundColor:[UIColor colorWithRed:0.000f green:0.816f blue:0.000f alpha:1.0f]];

        UITableViewRowAction *deleteAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                           title:NSLocalizedString(@"SERVER_LIST_ACTION_DELETE", nil)
                                         handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
         {
             Server *server = [self serverForRowAtIndexPath:indexPath];
             [self askForServerDeleteConfirmation:server];
         }];
        [deleteAction setBackgroundColor:[UIColor colorWithRed:1.000f green:0.000f blue:0.000f alpha:1.0f]];

        return @[deleteAction, editAction];
    } else {
        UITableViewRowAction *stopAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                           title:NSLocalizedString(@"SERVER_LIST_ACTION_STOP", nil)
                                         handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
         {
             Server *server = [self serverForRowAtIndexPath:indexPath];
             [server stopMonitoring];
         }];
        [stopAction setBackgroundColor:[UIColor colorWithRed:1.000f green:0.800f blue:0.400f alpha:1.0f]];

        return @[stopAction];
    }
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{ }

- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Server *server = [self serverForRowAtIndexPath:indexPath];
    [self openServerInfoPanel:server];
}

#pragma mark Server pool delegate

- (void)serverListChanged:(ServerPool *)serverPool
{
    [self.tableView reloadData];

    for (ServerGroup *serverGroup in serverPool.serverGroups)
    {
        for (Server *server in serverGroup.servers)
        {
            NSIndexPath *indexPath = [self indexPathForServer:(Server *)server];
            if (indexPath != nil) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                if ([(Server *)server monitoring] == NO) {
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                } else {
                    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
                }
            }
        }
    }
}

- (void)serverPool:(ServerPool *)serverPool
serverSatusChanged:(NSObject *)server
{
    NSIndexPath *indexPath = [self indexPathForServer:(Server *)server];
    if (indexPath != nil) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([(Server *)server monitoring] == NO) {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        }
    }
}

#pragma mark Alert delegate

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        ServerPool *serverPool = [ServerPool sharedServerPool];
        for (ServerGroup *serverGroup in serverPool.serverGroups)
        {
            for (Server *server in serverGroup.servers)
            {
                if (server == serverUnderCursor)
                {
                    serverUnderCursor = nil;
                    [serverGroup.servers removeObject:server];
                    [serverPool saveServerList];
                    return;
                }
            }
        }
    }
}

@end