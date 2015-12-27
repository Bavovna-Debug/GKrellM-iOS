//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "ClosedConnectionCell.h"
#import "Server.h"
#import "ServerPool.h"

#import "SRVConnectionRecord.h"

@interface ClosedConnectionCell ()

@property (strong, nonatomic)          UIColor *originalBackgroundColor;
@property (weak,   nonatomic) IBOutlet UILabel *localPortLabel;
@property (weak,   nonatomic) IBOutlet UILabel *remoteHostLabel;
@property (weak,   nonatomic) IBOutlet UILabel *openedTimestampLabel;
@property (weak,   nonatomic) IBOutlet UILabel *closedTimestampLabel;
@end

@implementation ClosedConnectionCell

@synthesize connection = _connection;

- (BOOL)wide
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (CGRectGetWidth(self.contentView.bounds) > 664.0f) {
            return YES;
        /*} else if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) == YES) {
            if (CGRectGetWidth(self.contentView.bounds) > 480.0f) {
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

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.openedTimestampLabel setHidden:
     CGRectGetWidth(self.contentView.bounds) < CGRectGetMaxX(self.openedTimestampLabel.frame)];

    [self.closedTimestampLabel setHidden:
     CGRectGetWidth(self.contentView.bounds) < CGRectGetMaxX(self.closedTimestampLabel.frame)];
}

- (void)didMoveToSuperview
{
    self.originalBackgroundColor = self.backgroundColor;

    [super didMoveToSuperview];
}

- (void)setConnection:(SRVConnectionRecord *)connection
{
    _connection = connection;

    NSString *ipAddress = [connection ipAddress];
    UInt16 remotePort = [connection remotePort];
    UInt16 localPort = [connection localPort];
    NSString *openedTimestampText = [NSDateFormatter localizedStringFromDate:[connection openedStamp]
                                                                   dateStyle:NSDateFormatterShortStyle
                                                                   timeStyle:NSDateFormatterMediumStyle];
    NSString *closedTimestampText = [NSDateFormatter localizedStringFromDate:[connection closedStamp]
                                                                   dateStyle:NSDateFormatterShortStyle
                                                                   timeStyle:NSDateFormatterMediumStyle];

#ifdef SCREENSHOTING
    if ([ipAddress containsString:@"195"] == YES)
        ipAddress = @"::ffff:217.110.62.18";
    if ([ipAddress compare:@"78.47.11.62"] == NSOrderedSame)
        ipAddress = @"193.0.4.3";
    if ([ipAddress compare:@"5.56.223.137"] == NSOrderedSame)
        ipAddress = @"192.168.1.12";
    if ([ipAddress compare:@"::ffff:5.56.223.137"] == NSOrderedSame)
        ipAddress = @"192.168.1.18";
    if (localPort == 993)
        localPort = 5432;
    if (localPort == 9090)
        localPort = 48100;
    if (localPort == 19150)
        localPort = 443;
#endif

    [self.localPortLabel setText:[NSString stringWithFormat:@"%d", localPort]];
    [self.remoteHostLabel setText:[NSString stringWithFormat:@"%@ (%d)", ipAddress, remotePort]];
    [self.openedTimestampLabel setText:openedTimestampText];
    [self.closedTimestampLabel setText:closedTimestampText];

    NSDate *now = [NSDate date];
    NSTimeInterval sinceClose = [now timeIntervalSinceDate:[self.connection closedStamp]];
    if (sinceClose < 3.0f)
        [self animateAppearance];
}

- (void)animateAppearance
{
    [self setBackgroundColor:[UIColor colorWithRed:1.000f green:0.471f blue:0.400f alpha:1.0f]];

    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:1.5f];

    [self setBackgroundColor:self.originalBackgroundColor];

    [UIView commitAnimations];
}

@end

