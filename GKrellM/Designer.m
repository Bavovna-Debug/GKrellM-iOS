//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "Designer.h"

@implementation RoundCornerView

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self.layer setCornerRadius:2.0f];
}

@end

@implementation ResizableView

#define Margin 4.0f

- (void)layoutSubviews
{
    NSUInteger numberOfSubviews = [self.subviews count];
    CGFloat subviewWidth;
    subviewWidth = CGRectGetWidth(self.frame) / numberOfSubviews;
    if (subviewWidth > CGRectGetWidth(self.frame) / 4)
        subviewWidth = CGRectGetWidth(self.frame) / 4;
    subviewWidth -= Margin;

    CGRect subviewFrame = CGRectMake(0.0f, 0.0f, subviewWidth, CGRectGetHeight(self.frame));

    for (UIView *subview in self.subviews)
    {
        [subview setFrame:subviewFrame];
        subviewFrame = CGRectOffset(subviewFrame, CGRectGetWidth(subviewFrame) + Margin, 0.0f);
    }

    [super layoutSubviews];
}

@end

@implementation RecolorizedView

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];

    UIColor *color = [self tintColor];

    [self.layer setBorderWidth:2.0f];
    [self.layer setBorderColor:[color CGColor]];
    [self.layer setCornerRadius:2.0f];

    for (UIView *subview in [self subviews])
    {
        if ([subview isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)subview;
            [label setTextColor:color];
        }
    }
}

@end
