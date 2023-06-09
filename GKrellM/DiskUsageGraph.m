//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "DiskUsageGraph.h"

@implementation DiskUsageGraph

- (void)updateGraph
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat procentUsed;
    CGFloat procentAvailable;
    if ([self.mount totalBlocks] > 0) {
        procentUsed = (CGFloat)([self.mount totalBlocks] - [self.mount freeBlocks]) / (CGFloat)[self.mount totalBlocks];
        procentAvailable = (CGFloat)[self.mount availableBlocks] / (CGFloat)[self.mount totalBlocks];
        procentUsed *= 100.0f;
        procentAvailable *= 100.0f;
    } else {
        procentUsed = 0.0f;
        procentAvailable = 0.0f;
    }

    UIImage *backgroundImage = [UIImage imageNamed:@"CircleGraphBackground"];
    UIImage *layerImage = [UIImage imageNamed:@"CircleGraphLayer"];

    CGPoint center = CGPointMake(CGRectGetMidX(rect),
                                 CGRectGetMidY(rect));
    
    CGFloat radius = 50.0f;

    CGFloat startAngle = M_PI * 1.5f;
    CGFloat endAngle = startAngle + M_PI / radius * procentUsed;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);

    [backgroundImage drawInRect:rect];

    CGContextMoveToPoint(context, center.x, center.y);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0f green:0.5f blue:0.0f alpha:0.6f].CGColor);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextFlush(context);
    CGContextFillPath(context);

    startAngle = endAngle;
    endAngle = startAngle + M_PI / radius * procentAvailable;

    CGContextMoveToPoint(context, center.x, center.y);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.6f].CGColor);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextFlush(context);
    CGContextFillPath(context);
    
    startAngle = endAngle;
    endAngle = startAngle + M_PI / radius * (100.0f - procentUsed - procentAvailable);

    CGContextMoveToPoint(context, center.x, center.y);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.6f].CGColor);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextFlush(context);
    CGContextFillPath(context);

    [layerImage drawInRect:rect];
    
    if ([self.mount totalBlocks] > 0) {
        NSString *procentText = [NSString stringWithFormat:@"%0.2f%%", procentUsed];

        UIFont *font = [UIFont systemFontOfSize:16];

        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        [paragraphStyle setAlignment:NSTextAlignmentRight];

        NSDictionary *attributes1 = @{ NSFontAttributeName:font,
                                       NSParagraphStyleAttributeName:paragraphStyle,
                                       NSForegroundColorAttributeName:[UIColor lightTextColor]};

        NSDictionary *attributes2 = @{ NSFontAttributeName:font,
                                       NSParagraphStyleAttributeName:paragraphStyle,
                                       NSForegroundColorAttributeName:[UIColor darkTextColor]};

        NSDictionary *attributes3 = @{ NSFontAttributeName:font,
                                       NSParagraphStyleAttributeName:paragraphStyle,
                                       NSForegroundColorAttributeName:[UIColor whiteColor]};

        CGSize stringSize = [procentText sizeWithAttributes:attributes3];
        CGRect stringRect = CGRectMake(center.x - stringSize.width / 2,
                                       center.y - stringSize.height / 2,
                                       stringSize.width,
                                       stringSize.height);

        [procentText drawInRect:CGRectOffset(stringRect, -0.5f, -0.5f)
                 withAttributes:attributes1];
        
        [procentText drawInRect:CGRectOffset(stringRect, 0.5f, 0.5f)
                 withAttributes:attributes2];

        [procentText drawInRect:stringRect
                 withAttributes:attributes3];
    }
}

@end
