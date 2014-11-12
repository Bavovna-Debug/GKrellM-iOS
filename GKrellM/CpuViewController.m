//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "BarGraph.h"
#import "CpuGraph.h"
#import "CpuViewController.h"
#import "Server.h"
#import "ServerPool.h"
#import "Units.h"

#import "SRVMemoryRecorder.h"
#import "SRVProcessorsRecorder.h"
#import "SRVProcessorUsageRecord.h"
#import "SRVSwapRecorder.h"

@interface CpuViewController () <SRVProcessorsRecorderDelegate, SRVMemoryRecorderDelegate, SRVSwapRecorderDelegate>

@property (weak,   nonatomic) Server *server;

@property (weak,   nonatomic) IBOutlet UIView          *cpuGraphPanel;
@property (weak,   nonatomic) IBOutlet CpuGraph        *cpuGraph;

@property (weak,   nonatomic) IBOutlet UIView          *cpuBars;

@property (weak,   nonatomic) IBOutlet UILabel         *cpuUsageIdle;
@property (weak,   nonatomic) IBOutlet UILabel         *cpuUsageUser;
@property (weak,   nonatomic) IBOutlet UILabel         *cpuUsageNice;
@property (weak,   nonatomic) IBOutlet UILabel         *cpuUsageSystem;

@property (weak,   nonatomic) IBOutlet UILabel         *memoryBuffers;
@property (weak,   nonatomic) IBOutlet UILabel         *memoryCached;
@property (weak,   nonatomic) IBOutlet UILabel         *memoryUsed;
@property (weak,   nonatomic) IBOutlet UILabel         *memoryFree;

@property (strong, nonatomic) IBOutlet BarGraph        *memoryBar;
@property (strong, nonatomic)          BarGraphBlock   *memoryBuffersBlock;
@property (strong, nonatomic)          BarGraphBlock   *memoryCachedBlock;
@property (strong, nonatomic)          BarGraphBlock   *memoryUsedBlock;
@property (strong, nonatomic)          BarGraphBlock   *memoryFreeBlock;

@property (weak, nonatomic) IBOutlet UILabel *swapUsed;
@property (weak, nonatomic) IBOutlet UILabel *swapFree;

@property (strong, nonatomic) IBOutlet BarGraph        *swapBar;
@property (strong, nonatomic)          BarGraphBlock   *swapUsedBlock;
@property (strong, nonatomic)          BarGraphBlock   *swapFreeBlock;

@end

@implementation CpuViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self.cpuGraphPanel.layer setCornerRadius:2.0f];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self prepareMemoryBar];
    [self prepareSwapBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.server = [[ServerPool sharedServerPool] currentServer];

    [self.cpuGraph setServer:self.server];

    [[self.server processorsRecorder] setDelegate:self];
    [[self.server memoryRecorder] setDelegate:self];
    [[self.server swapRecorder] setDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[self.server processorsRecorder] setDelegate:nil];
    [[self.server memoryRecorder] setDelegate:nil];
    [[self.server swapRecorder] setDelegate:nil];

    [super viewDidDisappear:animated];
}

- (void)createCpuBars:(SRVProcessorsRecorder *)recorder
{
    UIColor *cpuUsageIdleColor    = [[self.cpuUsageIdle superview] backgroundColor];
    UIColor *cpuUsageUserColor    = [[self.cpuUsageUser superview] backgroundColor];
    UIColor *cpuUsageNiceColor    = [[self.cpuUsageNice superview] backgroundColor];
    UIColor *cpuUsageSystemColor  = [[self.cpuUsageSystem superview] backgroundColor];

    NSUInteger numberOfProcessors = [recorder numberOfProcessors];

    CGRect barFrame = [self.cpuBars bounds];
    barFrame.size.width /= numberOfProcessors;
    barFrame.size.width -= 4.0f;

    for (NSUInteger cpuNumber = 0; cpuNumber < numberOfProcessors; cpuNumber++)
    {
        BarGraph *bar = [[BarGraph alloc] initWithFrame:barFrame
                                                graphType:BarGraphVertical];
        [bar setBackgroundColor:cpuUsageIdleColor];
        [bar setTranslatesAutoresizingMaskIntoConstraints:NO];

        [bar addBlockWithColor:cpuUsageUserColor];
        [bar addBlockWithColor:cpuUsageNiceColor];
        [bar addBlockWithColor:cpuUsageSystemColor];

        [bar setLabelColor:[UIColor whiteColor]];
        [bar setLabel:[NSString stringWithFormat:@"Cpu%lu", (unsigned long)cpuNumber]];

        [self.cpuBars addSubview:bar];
    }
}

- (void)prepareMemoryBar
{
    [self.memoryBar setGraphType:BarGraphHorizontal];

    UIColor *memoryBuffersColor  = [[self.memoryBuffers superview] tintColor];
    UIColor *memoryCachedColor   = [[self.memoryCached superview] tintColor];
    UIColor *memoryUsedColor     = [[self.memoryUsed superview] tintColor];
    UIColor *memoryFreeColor     = [[self.memoryFree superview] tintColor];

    self.memoryBuffersBlock  = [self.memoryBar addBlockWithColor:memoryBuffersColor];
    self.memoryCachedBlock   = [self.memoryBar addBlockWithColor:memoryCachedColor];
    self.memoryUsedBlock     = [self.memoryBar addBlockWithColor:memoryUsedColor];
    self.memoryFreeBlock     = [self.memoryBar addBlockWithColor:memoryFreeColor];

    [self.memoryBuffersBlock  setLabelColor:[UIColor whiteColor]];
    [self.memoryCachedBlock   setLabelColor:[UIColor whiteColor]];
    [self.memoryUsedBlock     setLabelColor:[UIColor whiteColor]];
    [self.memoryFreeBlock     setLabelColor:[UIColor whiteColor]];
}

- (void)prepareSwapBar
{
    [self.swapBar setGraphType:BarGraphHorizontal];

    UIColor *swapUsedColor = [[self.swapUsed superview] tintColor];
    UIColor *swapFreeColor = [[self.swapFree superview] tintColor];

    self.swapUsedBlock = [self.swapBar addBlockWithColor:swapUsedColor];
    self.swapFreeBlock = [self.swapBar addBlockWithColor:swapFreeColor];

    [self.swapUsedBlock setLabelColor:[UIColor whiteColor]];
    [self.swapFreeBlock setLabelColor:[UIColor whiteColor]];
}

#pragma mark Service delegate

- (void)processorDataArrived:(SRVProcessorsRecorder *)recorder
{
    [self.cpuGraph setNeedsDisplay];

    if ([self.cpuBars.subviews count] == 0)
        [self createCpuBars:recorder];

    [self refreshProcessorCharts:recorder];

    [self refreshProcessorValues:recorder];
}


- (void)memoryDataArrived:(SRVMemoryRecorder *)recorder
{
    [self.memoryBuffers  setText:[NSString stringFromSize:[recorder buffers]
                                                    units:FormatSizeUnitsMB]];
    [self.memoryCached   setText:[NSString stringFromSize:[recorder cached]
                                                    units:FormatSizeUnitsMB]];
    [self.memoryUsed     setText:[NSString stringFromSize:[recorder used]
                                                    units:FormatSizeUnitsMB]];
    [self.memoryFree     setText:[NSString stringFromSize:[recorder free]
                                                    units:FormatSizeUnitsMB]];

    [self.memoryBuffersBlock  setValue:[recorder buffers]];
    [self.memoryCachedBlock   setValue:[recorder cached]];
    [self.memoryUsedBlock     setValue:[recorder used]];
    [self.memoryFreeBlock     setValue:[recorder free]];

    NSUInteger buffersProcent  = lround((double)[recorder buffers]  / (double)[recorder total] * 100);
    NSUInteger cachedProcent   = lround((double)[recorder cached]   / (double)[recorder total] * 100);
    NSUInteger usedProcent     = lround((double)[recorder used]     / (double)[recorder total] * 100);
    NSUInteger freeProcent     = lround((double)[recorder free]     / (double)[recorder total] * 100);

    [self.memoryBuffersBlock  setLabel:[NSString stringWithFormat:@"%lu %%", (unsigned long)buffersProcent]];
    [self.memoryCachedBlock   setLabel:[NSString stringWithFormat:@"%lu %%", (unsigned long)cachedProcent]];
    [self.memoryUsedBlock     setLabel:[NSString stringWithFormat:@"%lu %%", (unsigned long)usedProcent]];
    [self.memoryFreeBlock     setLabel:[NSString stringWithFormat:@"%lu %%", (unsigned long)freeProcent]];

    [self.memoryBar setMaxValue:[recorder total]];
    [self.memoryBar refreshBlocks:1.0f];
}

- (void)swapDataArrived:(SRVSwapRecorder *)recorder
{
    [self.swapUsed setText:[NSString stringFromSize:[recorder used]
                                              units:FormatSizeUnitsMB]];
    [self.swapFree setText:[NSString stringFromSize:[recorder total] - [recorder used]
                                              units:FormatSizeUnitsMB]];

    [self.swapUsedBlock setValue:[recorder used]];
    [self.swapFreeBlock setValue:[recorder free]];

    NSUInteger usedProcent     = lround((double)[recorder used] / (double)[recorder total] * 100);
    NSUInteger freeProcent     = lround((double)[recorder free] / (double)[recorder total] * 100);

    [self.swapUsedBlock setLabel:[NSString stringWithFormat:@"%lu %%", (unsigned long)usedProcent]];
    [self.swapFreeBlock setLabel:[NSString stringWithFormat:@"%lu %%", (unsigned long)freeProcent]];

    [self.swapBar setMaxValue:[recorder total]];
    [self.swapBar refreshBlocks:1.0f];
}

#pragma mark Refresh

- (void)refreshProcessorCharts:(SRVProcessorsRecorder *)recorder
{
    for (NSUInteger cpuNumber = 0; cpuNumber < [self.cpuBars.subviews count]; cpuNumber++)
    {
        if ([[recorder history] count] < 2)
            return;

        NSUInteger currentRecordNumber = [[recorder history] count];

        NSMutableArray *currentLine = [[recorder history] objectAtIndex:currentRecordNumber - 1];
        NSMutableArray *previousLine = [[recorder history] objectAtIndex:currentRecordNumber - 2];

        SRVProcessorUsageRecord *currentRecord = [currentLine objectAtIndex:cpuNumber];
        SRVProcessorUsageRecord *previousRecord = [previousLine objectAtIndex:cpuNumber];

        UInt64 totalTime   = [currentRecord total]       - [previousRecord total];
        UInt64 userTime    = [currentRecord userTime]    - [previousRecord userTime];
        UInt64 niceTime    = [currentRecord niceTime]    - [previousRecord niceTime];
        UInt64 systemTime  = [currentRecord systemTime]  - [previousRecord systemTime];

        BarGraph *bar = [self.cpuBars.subviews objectAtIndex:cpuNumber];
        BarGraphBlock *userBlock    = [bar.blocks objectAtIndex:0];
        BarGraphBlock *niceBlock    = [bar.blocks objectAtIndex:1];
        BarGraphBlock *systemBlock  = [bar.blocks objectAtIndex:2];

        [bar setMaxValue:totalTime];
        [userBlock setValue:userTime];
        [niceBlock setValue:niceTime];
        [systemBlock setValue:systemTime];
        
        [bar refreshBlocks:0.25f];
    }
}

- (void)refreshProcessorValues:(SRVProcessorsRecorder *)recorder
{
    if ([[recorder history] count] < 2)
        return;

    NSUInteger currentRecordNumber = [[recorder history] count];

    NSMutableArray *currentLine = [[recorder history] objectAtIndex:currentRecordNumber - 1];
    NSMutableArray *previousLine = [[recorder history] objectAtIndex:currentRecordNumber - 2];

    SRVProcessorUsageRecord *currentRecord = [currentLine lastObject];
    SRVProcessorUsageRecord *previousRecord = [previousLine lastObject];

    UInt64 totalTime   = [currentRecord total]       - [previousRecord total];
    UInt64 idleTime    = [currentRecord idleTime]    - [previousRecord idleTime];
    UInt64 userTime    = [currentRecord userTime]    - [previousRecord userTime];
    UInt64 niceTime    = [currentRecord niceTime]    - [previousRecord niceTime];
    UInt64 systemTime  = [currentRecord systemTime]  - [previousRecord systemTime];

    [self.cpuUsageIdle setText:[NSString stringWithFormat:@"%0.1f %%",
                                ((double)idleTime / (double)totalTime) * 100]];
    [self.cpuUsageUser setText:[NSString stringWithFormat:@"%0.1f %%",
                                ((double)userTime / (double)totalTime) * 100]];
    [self.cpuUsageNice setText:[NSString stringWithFormat:@"%0.1f %%",
                                ((double)niceTime / (double)totalTime) * 100]];
    [self.cpuUsageSystem setText:[NSString stringWithFormat:@"%0.1f %%",
                                  ((double)systemTime / (double)totalTime) * 100]];
}

@end