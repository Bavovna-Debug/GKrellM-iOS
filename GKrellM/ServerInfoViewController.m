//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "ServerInfoViewController.h"

@interface ServerInfoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *serverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *systemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *uptimeLabel;

@end

@implementation ServerInfoViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.serverNameLabel setText:[self.server serverName]];
    [self.hostNameLabel setText:[self.server serverToldHostname]];
    [self.systemNameLabel setText:[self.server serverToldSystemName]];
    [self.versionLabel setText:[self.server serverToldVersion]];
    [self.uptimeLabel setText:[self formattedServerUptime:[self.server serverUptime]]];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSString *)formattedServerUptime:(NSUInteger)serverUptime
{
    NSString *uptimeText = [NSString stringWithString:NSLocalizedString(@"UPTIME_PREFIX", nil)];

    NSUInteger uptime = serverUptime;
    NSUInteger days = uptime / (24 * 60);
    NSUInteger hours = (uptime - (days * (24 * 60))) / 60;
    NSUInteger minutes = uptime % 60;

    if (uptime < 24 * 60) {
        uptimeText = [uptimeText stringByAppendingFormat:@" %02lu:%02lu",
                      (unsigned long)hours,
                      (unsigned long)minutes];
    } else {
        NSString *daysText = [NSString stringWithString:NSLocalizedString(@"UPTIME_DAYS", nil)];

        uptimeText = [uptimeText stringByAppendingFormat:@" %lu %@ %02lu:%02lu",
                      (unsigned long)days,
                      daysText,
                      (unsigned long)hours,
                      (unsigned long)minutes];
    }

    return uptimeText;
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
