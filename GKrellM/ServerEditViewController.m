//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Server.h"
#import "ServerEditViewController.h"
#import "ServerGroup.h"
#import "ServerPool.h"

@interface ServerEditViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem    *saveButton;

@property (strong, nonatomic) IBOutlet UITextField      *serverNameValue;
@property (strong, nonatomic) IBOutlet UITextField      *dnsNameValue;
@property (strong, nonatomic) IBOutlet UITextField      *portNumberValue;

@end

@implementation ServerEditViewController

@synthesize server = _server;

#pragma mark - UI events

- (void)awakeFromNib
{
    [super awakeFromNib];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self setClearsSelectionOnViewWillAppear:NO];
        [self setPreferredContentSize:CGSizeMake(640.0f, 640.0f)];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    /*[self.serverNameValue setInputAccessoryView:self.inputView];
    [self.dnsNameValue setInputAccessoryView:self.inputView];
    [self.portNumberValue setInputAccessoryView:self.inputView];*/
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.server == nil)
    {
        [self.portNumberValue setText:[NSString stringWithFormat:@"%d", DefaultPortNumber]];
    }
    else
    {
        [self.serverNameValue setText:[self.server serverName]];
        [self.dnsNameValue setText:[self.server dnsName]];
        [self.portNumberValue setText:[NSString stringWithFormat:@"%d", [self.server portNumber]]];
    }

    [self validateValues];

    [super viewWillAppear:animated];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - UIButton events

- (IBAction)didTouchCancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)didTouchSubmitButton:(id)sender
{
    NSString *serverName = [self.serverNameValue text];
    NSString *dnsName = [self.dnsNameValue text];
    UInt16 portNumber = [[self.portNumberValue text] intValue];

    if (self.server == nil)
    {
        ServerPool *serverPool = [ServerPool sharedServerPool];
        Server *server = [Server serverWithId:nil
                                   serverName:serverName
                                      dnsName:dnsName
                                   portNumber:portNumber];

        [serverPool addNewServer:server];

        [serverPool saveServerList];
    }
    else
    {
        ServerPool *serverPool = [ServerPool sharedServerPool];
        Server *server = self.server;

        [server setServerName:serverName];
        [server setDnsName:dnsName];
        [server setPortNumber:portNumber];

        [serverPool saveServerList];
    }

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)editingChanged:(id)sender
{
    [self validateValues];
}

- (void)validateValues
{
    BOOL allowSave = YES;

    NSString *serverName = [self.serverNameValue text];
    NSString *dnsName = [self.dnsNameValue text];
    int portNumber = [[self.portNumberValue text] intValue];

    if ([serverName length] == 0)
    {
        allowSave = NO;
    }
    else if ([dnsName length] == 0)
    {
        allowSave = NO;
    }
    else if ((portNumber < 0) || (portNumber > UINT16_MAX))
    {
        allowSave = NO;
    }

    if (self.saveButton.enabled != allowSave)
    {
        [self.saveButton setEnabled:allowSave];
    }
}

@end
