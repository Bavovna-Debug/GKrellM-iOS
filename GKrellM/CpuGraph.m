//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "CpuGraph.h"
#import "SRVProcessorsRecorder.h"
#import "SRVProcessorUsageRecord.h"

@interface CpuGraph ()

@end

@implementation CpuGraph

@synthesize server = _server;

#pragma mark - Draw

- (void)drawRect:(CGRect)rect
{
    SRVProcessorsRecorder *recorder = [self.server processorsRecorder];

    CGFloat ticksToDrawMust = CGRectGetWidth(self.bounds);
    CGFloat ticksToDraw = ticksToDrawMust;
    
    NSInteger lastRecordNumber = [[recorder history] count] - 1;
    if (lastRecordNumber < 1) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClearRect(context, rect);
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextAddRect(context, rect);
        CGContextFillPath(context);

        return;
    }

    while (lastRecordNumber - ticksToDraw < 0)
        ticksToDraw--;
    
    CGFloat fullLoadRange = [recorder fullLoadRange];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGContextSetRGBStrokeColor(context, 0.0f, 1.0f, 0.0f, 1.0f);
    CGContextSetLineWidth(context, 1.0f);
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    if (ticksToDraw < ticksToDrawMust)
        CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));

    UInt64 lastIdleTime = 0;
    NSMutableArray *records = [recorder history];
    while (ticksToDraw-- > 0)
    {
        NSMutableArray *record = [records objectAtIndex:lastRecordNumber - ticksToDraw];
        SRVProcessorUsageRecord *usageRecord = [record lastObject];
        
        UInt64 thisTime;
        switch (self.graphType) {
            case CpuGraphTypeTotal:
                thisTime = [usageRecord idleTime];
                break;

            case CpuGraphTypeUser:
                thisTime = [usageRecord usedTime] + [usageRecord idleTime] - [usageRecord userTime];
                break;

            case CpuGraphTypeNice:
                thisTime = [usageRecord usedTime] + [usageRecord idleTime] - [usageRecord niceTime];
                break;

            case CpuGraphTypeSystem:
                thisTime = [usageRecord usedTime] + [usageRecord idleTime] - [usageRecord systemTime];
                break;
        }
        
        UInt64 delta = thisTime - lastIdleTime;

        CGPoint tickPoint = CGPointMake(CGRectGetWidth(rect) - ticksToDraw * (CGRectGetWidth(rect) / ticksToDrawMust),
                                        (double)delta / fullLoadRange * CGRectGetHeight(rect));
        
        CGContextAddLineToPoint(context, tickPoint.x, tickPoint.y);
        
        lastIdleTime = thisTime;
    }

    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    
    CGContextFillPath(context);
}

@end
