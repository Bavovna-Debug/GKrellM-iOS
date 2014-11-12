//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XML.h"

@interface ServerGroup : NSObject

@property (strong, nonatomic) NSString        *name;
@property (strong, nonatomic) NSMutableArray  *servers;

+ (ServerGroup *)serverGroupWithName:(NSString *)name;

+ (ServerGroup *)serverGroupFromXML:(XMLElement *)groupElement;

- (id)initWithName:(NSString *)name;

- (XMLElement *)saveToXML;

@end
