//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Units.h"

@implementation NSString(Sizes)

+ (NSString *)stringFromSize:(CGFloat)size
                       units:(FormatSizeUnits)units
{
    const double KB = 1024;
    const double MB = 1024 * 1024;
    const double GB = 1024 * 1024 * 1024;

    double result;
    NSString *unitsText;

    switch (units)
    {
        case FormatSizeUnitsAuto:
        {
            if (size < 10 * KB) {
                result = size;
                unitsText = [NSString stringWithString:NSLocalizedStringFromTable(@"BYTES", @"Units", nil)];
                return [NSString stringWithFormat:@"%0.0f %@", result, unitsText];
            } else if (size < MB) {
                result = size / KB;
                unitsText = [NSString stringWithString:NSLocalizedStringFromTable(@"KB", @"Units", nil)];
                return [NSString stringWithFormat:@"%0.1f %@", result, unitsText];
            } else if (size < GB) {
                result = size / MB;
                unitsText = [NSString stringWithString:NSLocalizedStringFromTable(@"MB", @"Units", nil)];
                return [NSString stringWithFormat:@"%0.1f %@", result, unitsText];
            } else {
                size /= GB;
                if (size < 2048) {
                    result = size;
                    unitsText = [NSString stringWithString:NSLocalizedStringFromTable(@"GB", @"Units", nil)];
                } else {
                    result = size / 1024;
                    unitsText = [NSString stringWithString:NSLocalizedStringFromTable(@"TB", @"Units", nil)];
                }
                return [NSString stringWithFormat:@"%0.2f %@", result, unitsText];
            }
        }

        case FormatSizeUnitsKB:
        {
            result = size / KB;
            unitsText = [NSString stringWithString:NSLocalizedStringFromTable(@"KB", @"Units", nil)];
            return [NSString stringWithFormat:@"%0.0f %@", result, unitsText];
        }

        case FormatSizeUnitsMB:
        {
            result = size / MB;
            unitsText = [NSString stringWithString:NSLocalizedStringFromTable(@"MB", @"Units", nil)];
            return [NSString stringWithFormat:@"%0.0f %@", result, unitsText];
        }

        case FormatSizeUnitsGB:
        {
            result = size / GB;
            unitsText = [NSString stringWithString:NSLocalizedStringFromTable(@"GB", @"Units", nil)];
            return [NSString stringWithFormat:@"%0.0f %@", result, unitsText];
        }
    }
}

@end
