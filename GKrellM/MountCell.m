//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "DiskUsageGraph.h"
#import "MountCell.h"
#import "Units.h"

@interface MountCell ()

@property (weak, nonatomic) IBOutlet UILabel         *mountPointLabel;
@property (weak, nonatomic) IBOutlet UILabel         *deviceNameLabel;

@property (weak, nonatomic) IBOutlet UILabel         *totalFormattedValue;
@property (weak, nonatomic) IBOutlet UILabel         *totalBytesValue;

@property (weak, nonatomic) IBOutlet UILabel         *usedFormattedValue;
@property (weak, nonatomic) IBOutlet UILabel         *usedBytesValue;
@property (weak, nonatomic) IBOutlet UILabel         *usedPercentValue;

@property (weak, nonatomic) IBOutlet UILabel         *availableFormattedValue;
@property (weak, nonatomic) IBOutlet UILabel         *availableBytesValue;
@property (weak, nonatomic) IBOutlet UILabel         *availablePercentValue;

@property (weak, nonatomic) IBOutlet UILabel         *reservedFormattedValue;
@property (weak, nonatomic) IBOutlet UILabel         *reservedBytesValue;
@property (weak, nonatomic) IBOutlet UILabel         *reservedPercentValue;

@property (weak, nonatomic) IBOutlet DiskUsageGraph  *diskUsageGraph;

@end

@implementation MountCell

@synthesize mount = _mount;

- (void)awakeFromNib
{
    [super awakeFromNib];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [self showDetailedInformation:NO];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (CGRectGetWidth(self.contentView.bounds) > 621.0f) {
            [self.diskUsageGraph setAlpha:1.0f];
            [self showDetailedInformation:YES];
        } else if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) == YES) {
            if (CGRectGetWidth(self.contentView.bounds) > 480.0f) {
                [self.diskUsageGraph setAlpha:1.0f];
                [self showDetailedInformation:YES];
            } else {
                [self.diskUsageGraph setAlpha:1.0f];
                [self showDetailedInformation:NO];
            }
        } else {
            [self.diskUsageGraph setAlpha:1.0f];
            [self showDetailedInformation:NO];
        }
    }
}

- (void)showDetailedInformation:(Boolean)show
{
    [self.totalBytesValue        setHidden:!show];
    [self.usedBytesValue         setHidden:!show];
    [self.availableBytesValue    setHidden:!show];
    [self.reservedBytesValue     setHidden:!show];
    [self.usedPercentValue       setHidden:!show];
    [self.availablePercentValue  setHidden:!show];
    [self.reservedPercentValue   setHidden:!show];
}

- (void)showDiskGraph:(Boolean)show
{
    [self refresh];

    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:1.0f];

    [self showDetailedInformation:!show];

    [self.diskUsageGraph setAlpha:(show) ? 1.0f : 0.0f];

    [UIView commitAnimations];
}

- (void)setMount:(SRVMountRecord *)mount
{
    if (mount != nil) {
        _mount = mount;
        [self.diskUsageGraph setMount:mount];
    }

    CGFloat totalSize = [self.mount totalBlocks];
    CGFloat usedSize = [self.mount totalBlocks] - [self.mount freeBlocks];
    CGFloat availableSize = [self.mount availableBlocks];
    CGFloat reservedSize;
    
    totalSize *= [self.mount blockSize];
    usedSize *= [self.mount blockSize];
    availableSize *= [self.mount blockSize];
    reservedSize = totalSize - usedSize - availableSize;

    [self.mountPointLabel          setText:[self.mount mountPoint]];
    [self.deviceNameLabel          setText:[self.mount deviceName]];

    [self.totalFormattedValue      setText:[NSString stringFromSize:totalSize units:FormatSizeUnitsAuto]];
    [self.totalBytesValue          setText:[NSString stringWithFormat:@"%0.0f", totalSize]];

    [self.usedFormattedValue       setText:[NSString stringFromSize:usedSize units:FormatSizeUnitsAuto]];
    [self.usedBytesValue           setText:[NSString stringWithFormat:@"%0.0f", usedSize]];
    [self.usedPercentValue         setText:[NSString stringWithFormat:@"%0.2f %%", usedSize / totalSize * 100]];

    [self.availableFormattedValue  setText:[NSString stringFromSize:availableSize units:FormatSizeUnitsAuto]];
    [self.availableBytesValue      setText:[NSString stringWithFormat:@"%0.0f", availableSize]];
    [self.availablePercentValue    setText:[NSString stringWithFormat:@"%0.2f %%", availableSize / totalSize * 100]];

    [self.reservedFormattedValue   setText:[NSString stringFromSize:reservedSize units:FormatSizeUnitsAuto]];
    [self.reservedBytesValue       setText:[NSString stringWithFormat:@"%0.0f", reservedSize]];
    [self.reservedPercentValue     setText:[NSString stringWithFormat:@"%0.2f %%", reservedSize / totalSize * 100]];

    [self.diskUsageGraph updateGraph];
}

- (void)refresh
{
    [self setMount:nil];

    UIColor *originalBackgroundColor = self.backgroundColor;

    [self setBackgroundColor:[UIColor colorWithRed:1.000f green:0.800f blue:0.400f alpha:1.0f]];

    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:0.5f];

    [self setBackgroundColor:originalBackgroundColor];

    [UIView commitAnimations];
}

@end
