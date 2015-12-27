//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "ServerEditCell.h"

@implementation ServerEditCell

- (void)layoutSubviews
{
    [super layoutSubviews];
/*
    UILabel *descriptionLabel = (UILabel *)[self descriptionLabel];
    [descriptionLabel setNumberOfLines:0];

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:descriptionLabel.textAlignment];
    [paragraphStyle setLineBreakMode:descriptionLabel.lineBreakMode];

    NSDictionary *attributes = @{ NSFontAttributeName:descriptionLabel.font,
                                  NSParagraphStyleAttributeName:paragraphStyle };


    CGRect textRect = [descriptionLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(descriptionLabel.bounds), CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:attributes
                                                          context:nil];

    CGRect descriptionFrame = [descriptionLabel frame];
    descriptionFrame.size.height += ceil(CGRectGetHeight(textRect)) - CGRectGetHeight(descriptionLabel.bounds);
    [descriptionLabel setFrame:descriptionFrame];
*/
}

- (UIView *)descriptionLabel
{
    for (UIView *subview in self.contentView.subviews)
        if (subview.tag == 1)
            return subview;

    return nil;
}

@end
