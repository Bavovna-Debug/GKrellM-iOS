//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Server.h"

@interface CpuGraph : UIView

typedef enum
{
    CpuGraphTypeTotal,
    CpuGraphTypeUser,
    CpuGraphTypeNice,
    CpuGraphTypeSystem
} CpuGraphType;

@property (weak,   nonatomic) Server        *server;
@property (assign, nonatomic) CpuGraphType  graphType;

@end
