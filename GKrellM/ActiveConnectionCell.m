//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "ActiveConnectionCell.h"
#import "Server.h"
#import "ServerPool.h"

#import "SRVConnectionRecord.h"

@interface ActiveConnectionCell () <SRVConnectionRecordDelegate>

@property (strong, nonatomic)          UIColor      *originalBackgroundColor;
@property (weak,   nonatomic) IBOutlet UIImageView  *appearanceSymbol;
@property (weak,   nonatomic) IBOutlet UILabel      *localPortLabel;
@property (weak,   nonatomic) IBOutlet UILabel      *remoteHostLabel;
@property (weak,   nonatomic) IBOutlet UILabel      *timestampLabel;

@end

@implementation ActiveConnectionCell

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

    [self.timestampLabel setHidden:
     CGRectGetWidth(self.contentView.bounds) < CGRectGetMaxX(self.timestampLabel.frame)];
}

- (void)didMoveToSuperview
{
    self.originalBackgroundColor = self.backgroundColor;

    [super didMoveToSuperview];
}

- (void)setConnection:(SRVConnectionRecord *)connection
{
    _connection = connection;

    //[connection setDelegate:self];

    NSString *ipAddress = [connection ipAddress];
    UInt16 remotePort = [connection remotePort];
    UInt16 localPort = [connection localPort];
    NSString *timestampText = [NSDateFormatter localizedStringFromDate:[connection openedStamp]
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
    [self.timestampLabel setText:timestampText];

    if ([connection closedStamp] != nil) {
        [self animateDisappearance];
    } else {
        NSDate *now = [NSDate date];
        NSTimeInterval sinceOpen = [now timeIntervalSinceDate:[connection openedStamp]];
        if (sinceOpen < 1.0f)
            [self animateAppearance];
    }
}

- (void)animateAppearance
{
    [self setBackgroundColor:[UIColor colorWithRed:0.498f green:0.498f blue:0.498f alpha:1.0f]];
    
    [self.appearanceSymbol setImage:[UIImage imageNamed:@"InetConnectionAppeared"]];
    [self.appearanceSymbol setAlpha:1.0f];
    
    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:1.5f];

    [self setBackgroundColor:self.originalBackgroundColor];
    
    [UIView commitAnimations];

    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:10.0f];
    
    [self setBackgroundColor:self.originalBackgroundColor];
    [self.appearanceSymbol setAlpha:0.0f];
    
    [UIView commitAnimations];
}

- (void)animateDisappearance
{
    [self.appearanceSymbol setImage:[UIImage imageNamed:@"InetConnectionDisappeared"]];
    [self.appearanceSymbol setAlpha:0.0f];
 
    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:0.4f];
    
    [self.appearanceSymbol setAlpha:1.0f];
    
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:2.0f];
    
    [self setBackgroundColor:[UIColor colorWithRed:1.000f green:0.471f blue:0.400f alpha:1.0f]];

    [UIView commitAnimations];
}

#pragma mark Connection record delegate

- (void)connectionClosed:(SRVConnectionRecord *)connectionRecord
{
    [self animateDisappearance];
}

@end

