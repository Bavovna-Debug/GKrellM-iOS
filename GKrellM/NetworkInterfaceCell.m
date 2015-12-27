//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "NetworkInterfaceCell.h"
#import "Units.h"

@interface NetworkInterfaceCell () <SRVNetworkInterfaceDelegate>

@property (weak, nonatomic) IBOutlet UILabel   *interfaceNameLabel;
@property (weak, nonatomic) IBOutlet UIView    *totalTrafficView;
@property (weak, nonatomic) IBOutlet UILabel   *rxTotalBytesValue;
@property (weak, nonatomic) IBOutlet UILabel   *rxTotalFormattedValue;
@property (weak, nonatomic) IBOutlet UILabel   *txTotalBytesValue;
@property (weak, nonatomic) IBOutlet UILabel   *txTotalFormattedValue;
@property (weak, nonatomic) IBOutlet UIView    *gagingTrafficView;
@property (weak, nonatomic) IBOutlet UILabel   *gagingSinceValue;
@property (weak, nonatomic) IBOutlet UILabel   *rxGagingBytesValue;
@property (weak, nonatomic) IBOutlet UILabel   *txGagingBytesValue;
@property (weak, nonatomic) IBOutlet UIButton  *startGagingButton;
@property (weak, nonatomic) IBOutlet UIButton  *stopGagingButton;

@end

@implementation NetworkInterfaceCell

@synthesize interface = _interface;

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self.totalTrafficView.layer setCornerRadius:2.0f];
    [self.gagingTrafficView.layer setCornerRadius:2.0f];

    [self refreshValues];
}

- (void)setInterface:(SRVNetworkInterface *)interface
{
    _interface = interface;

    [self refreshValues];

    [interface setDelegate:self];
}

- (void)networkTrafficChanged:(SRVNetworkInterface *)interface
{
    [self refreshValues];
}

- (void)refreshValues
{
    [self.interfaceNameLabel setText:[self.interface interfaceName]];
    [self.rxTotalBytesValue setText:[NSString stringWithFormat:@"%llu", [self.interface rxBytesTotal]]];
    [self.txTotalBytesValue setText:[NSString stringWithFormat:@"%llu", [self.interface txBytesTotal]]];

    [self.rxTotalFormattedValue setText:[NSString stringFromSize:[self.interface rxBytesTotal]
                                                           units:FormatSizeUnitsAuto]];
    [self.txTotalFormattedValue setText:[NSString stringFromSize:[self.interface txBytesTotal]
                                                           units:FormatSizeUnitsAuto]];
    
    [self.rxGagingBytesValue setText:[NSString stringWithFormat:@"%llu", [self.interface rxBytesGaging]]];
    [self.txGagingBytesValue setText:[NSString stringWithFormat:@"%llu", [self.interface txBytesGaging]]];
}

- (void)refreshStopwatch
{
    NSTimeInterval timeRange;
    if ([self.interface gaging] == YES) {
        timeRange = [[NSDate date] timeIntervalSinceDate:[self.interface gagingBegin]];
    } else {
        timeRange = [[self.interface gagingEnd] timeIntervalSinceDate:[self.interface gagingBegin]];
    }
    
    NSInteger seconds = (NSInteger)timeRange % 60;
    NSInteger minutes = ((NSInteger)timeRange / 60) % 60;
    NSInteger hours = ((NSInteger)timeRange / 3600);
    NSString *gagingSinceText = [NSString stringWithFormat:@"%0ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];

    [self.gagingSinceValue setText:gagingSinceText];
}

- (IBAction)didTouchStartGagingButton
{
    [self.interface setGaging:YES];

    [self.gagingSinceValue setTextColor:[UIColor darkTextColor]];
    [self.rxGagingBytesValue setTextColor:[UIColor darkTextColor]];
    [self.txGagingBytesValue setTextColor:[UIColor darkTextColor]];

    [self.startGagingButton setEnabled:NO];
    [self.startGagingButton setHidden:YES];

    [self.stopGagingButton setEnabled:YES];
    [self.stopGagingButton setHidden:NO];

    [self refreshValues];
}

- (IBAction)didTouchStopGagingButton
{
    [self.interface setGaging:NO];

    [self.gagingSinceValue setTextColor:[UIColor redColor]];
    [self.rxGagingBytesValue setTextColor:[UIColor redColor]];
    [self.txGagingBytesValue setTextColor:[UIColor redColor]];

    [self.startGagingButton setEnabled:YES];
    [self.startGagingButton setHidden:NO];

    [self.stopGagingButton setEnabled:NO];
    [self.stopGagingButton setHidden:YES];

    [self refreshValues];
}

@end
