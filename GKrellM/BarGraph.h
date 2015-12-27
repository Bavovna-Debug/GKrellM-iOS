//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarGraphBlock : UIView

@property (assign, nonatomic) CGFloat value;

- (void)setLabelColor:(UIColor *)color;

- (void)setLabel:(NSString *)text;

@end

@interface BarGraph : UIView

typedef enum
{
    BarGraphHorizontal,
    BarGraphVertical
} BarGraphType;

@property (assign, nonatomic, readwrite) BarGraphType    graphType;
@property (assign, nonatomic, readwrite) CGFloat         maxValue;
@property (strong, nonatomic, readonly)  NSMutableArray  *blocks;

- (id)initWithFrame:(CGRect)frame
          graphType:(BarGraphType)graphType;

- (BarGraphBlock *)addBlockWithColor:(UIColor *)blockColor;

- (void)setLabelColor:(UIColor *)color;

- (void)setLabel:(NSString *)text;

- (void)refreshBlocks:(CGFloat)animationDuration;

@end
