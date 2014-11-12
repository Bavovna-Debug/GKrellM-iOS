//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Server.h"

@interface NSString(Sizes)

typedef enum {
    FormatSizeUnitsAuto,
    FormatSizeUnitsKB,
    FormatSizeUnitsMB,
    FormatSizeUnitsGB
} FormatSizeUnits;

+ (NSString *)stringFromSize:(CGFloat)size
                       units:(FormatSizeUnits)units;

@end
