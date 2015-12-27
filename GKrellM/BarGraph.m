//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "BarGraph.h"

@interface BarGraphBlock ()

@property (strong, nonatomic) UILabel *labelView;

@end

@implementation BarGraphBlock

- (void)layoutSubviews
{
    if (self.labelView != nil)
        [self layoutLabel];

    [super layoutSubviews];
}

- (void)layoutLabel
{
    [self.labelView setFrame:[self bounds]];

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];

    NSDictionary *attributes = @{ NSFontAttributeName:[self.labelView font],
                                  NSParagraphStyleAttributeName:paragraphStyle };

    CGSize labelSize = [[self.labelView text] sizeWithAttributes:attributes];

    if (labelSize.width > CGRectGetWidth([self.labelView bounds])) {
        if (self.labelView.hidden == NO)
            [self.labelView setHidden:YES];
    } else {
        if (self.labelView.hidden == YES)
            [self.labelView setHidden:NO];
    }
}

- (void)setLabelColor:(UIColor *)color
{
    self.labelView = [[UILabel alloc] initWithFrame:[self bounds]];
    [self.labelView setBackgroundColor:[UIColor clearColor]];
    [self.labelView setTextColor:color];
    [self.labelView setFont:[UIFont boldSystemFontOfSize:10.0f]];
    [self.labelView setTextAlignment:NSTextAlignmentCenter];
    [self.labelView setText:@""];
    [self addSubview:self.labelView];
}

- (void)setLabel:(NSString *)text
{
    [self.labelView setText:text];
    [self layoutLabel];
}

@end

@interface BarGraph ()

@property (strong, nonatomic, readwrite) NSMutableArray  *blocks;

@property (strong, nonatomic)            UIView          *mainBlock;
@property (strong, nonatomic)            UILabel         *labelView;

@end

@implementation BarGraph

- (id)initWithFrame:(CGRect)frame
          graphType:(BarGraphType)graphType
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;

    self.blocks = [NSMutableArray array];
    self.graphType = graphType;

    [self prepareLayout];

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.blocks = [NSMutableArray array];

    [self prepareLayout];
}

- (void)layoutSubviews
{
    [self layoutBars];

    if (self.labelView != nil)
        [self layoutLabel];

    [super layoutSubviews];
}

- (void)layoutBars
{
    switch (self.graphType)
    {
        case BarGraphHorizontal:
            if ([self.blocks count] > 1)
                [self refreshBlocks:0.0f];
            break;

        case BarGraphVertical:
            for (UIView *subview in self.subviews)
            {
                CGRect subviewFrame = [subview frame];
                subviewFrame.size.width = CGRectGetWidth(self.bounds);
                [subview setFrame:subviewFrame];
            }
            break;
    }
}

- (void)layoutLabel
{
    [self.labelView setFrame:[self bounds]];

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];

    NSDictionary *attributes = @{ NSFontAttributeName:[self.labelView font],
                                  NSParagraphStyleAttributeName:paragraphStyle };

    CGSize labelSize = [[self.labelView text] sizeWithAttributes:attributes];

    if (labelSize.width > CGRectGetWidth([self.labelView bounds])) {
        if (self.labelView.hidden == NO)
            [self.labelView setHidden:YES];
    } else {
        if (self.labelView.hidden == YES)
            [self.labelView setHidden:NO];
    }
}

- (void)prepareLayout
{
    [self.layer setCornerRadius:2.0f];

    self.mainBlock = [[UIView alloc] initWithFrame:[self graphFrame]];
    [self.mainBlock setBackgroundColor:[UIColor clearColor]];
    [self.mainBlock.layer setCornerRadius:2.0f];
    [self addSubview:self.mainBlock];
}

- (void)addGlass
{
    UIImage *backgroundImage;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        backgroundImage = [UIImage imageNamed:@"BarGraphPanelPad"];
    } else {
        backgroundImage = [UIImage imageNamed:@"BarGraphPanelPod"];
    }
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];

    [self addSubview:backgroundView];
}

- (CGRect)graphFrame
{
    switch (self.graphType)
    {
        case BarGraphHorizontal:
            return CGRectInset([self bounds], 4.0f, 4.0f);

        case BarGraphVertical:
            return CGRectInset([self bounds], 1, 1);
    }
}

- (BarGraphBlock *)addBlockWithColor:(UIColor *)blockColor
{
    CGRect graphFrame = [self graphFrame];
    CGRect blockFrame;

    switch (self.graphType)
    {
        case BarGraphHorizontal:
            blockFrame = CGRectMake(0,
                                    0,
                                    0,
                                    CGRectGetHeight(graphFrame));
            break;

        case BarGraphVertical:
            blockFrame = CGRectMake(1,
                                    CGRectGetHeight(graphFrame) - 1,
                                    CGRectGetWidth(graphFrame) - 2,
                                    0);
            break;
    }

    BarGraphBlock *block = [[BarGraphBlock alloc] init];
    [block setFrame:blockFrame];
    [block setBackgroundColor:blockColor];

    [self.mainBlock addSubview:block];
    [self.blocks addObject:block];

    return block;
}

- (void)setLabelColor:(UIColor *)color
{
    self.labelView = [[UILabel alloc] initWithFrame:[self bounds]];
    [self.labelView setBackgroundColor:[UIColor clearColor]];
    [self.labelView setTextColor:color];
    [self.labelView setFont:[UIFont boldSystemFontOfSize:9.0f]];
    [self.labelView setTextAlignment:NSTextAlignmentCenter];
    [self.labelView setText:@""];
    [self addSubview:self.labelView];
}

- (void)setLabel:(NSString *)text
{
    [self.labelView setText:text];
    [self layoutLabel];
}

- (void)refreshBlocks:(CGFloat)animationDuration
{
    CGRect graphFrame = [self graphFrame];
    CGRect blockFrame;
    CGFloat totalSize;

    switch (self.graphType)
    {
        case BarGraphHorizontal:
            blockFrame = CGRectMake(1,
                                    1,
                                    0,
                                    CGRectGetHeight(graphFrame) - 2);
            totalSize = CGRectGetWidth(graphFrame) - 2;
            break;

        case BarGraphVertical:
            blockFrame = CGRectMake(1,
                                    CGRectGetHeight(graphFrame) - 1,
                                    CGRectGetWidth(graphFrame) - 2,
                                    0);
            totalSize = CGRectGetHeight(graphFrame) - 2;
            break;
    }

    if (animationDuration > 0.0f) {
        [UIView beginAnimations:nil
                        context:nil];
        [UIView setAnimationDuration:animationDuration];
    }

    for (BarGraphBlock *block in [self blocks])
    {
        @try
        {
            switch (self.graphType)
            {
                case BarGraphHorizontal:
                    blockFrame.size.width = totalSize * ([block value] / [self maxValue]);
                    [block setFrame:blockFrame];
                    blockFrame = CGRectOffset(blockFrame, CGRectGetWidth(blockFrame), 0);
                    break;

                case BarGraphVertical:
                    blockFrame.size.height = totalSize * ([block value] / [self maxValue]);
                    blockFrame = CGRectOffset(blockFrame, 0, -CGRectGetHeight(blockFrame));
                    [block setFrame:blockFrame];
                    break;
            }
        }
        @catch (NSException *exception)
        {
#ifdef DEBUG
            NSLog(@"BarGraph: (%f x %f) (%f x %f)",
                  CGRectGetMinX(blockFrame),
                  CGRectGetMinY(blockFrame),
                  CGRectGetWidth(blockFrame),
                  CGRectGetHeight(blockFrame));
#endif
        }
    }

    if (animationDuration > 0.0f)
        [UIView commitAnimations];
}

@end
