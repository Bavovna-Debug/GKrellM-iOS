//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Server.h"
#import "ServerGroup.h"

@implementation ServerGroup

+ (ServerGroup *)serverGroupWithName:(NSString *)name
{
    ServerGroup *serverGroup = [[ServerGroup alloc] initWithName:name];
    return serverGroup;
}

+ (ServerGroup *)serverGroupFromXML:(XMLElement *)groupElement
{
    NSString *name = [groupElement.attributes objectForKey:@"name"];
    ServerGroup *serverGroup = [ServerGroup serverGroupWithName:name];

    for (XMLElement *serverElement in [groupElement elements])
    {
        Server *server = [Server serverFromXML:serverElement];
        [serverGroup.servers addObject:server];
    }

    return serverGroup;
}

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self == nil)
        return nil;

    self.name = name;
    self.servers = [NSMutableArray array];

    return self;
}

#pragma mark - XML

- (XMLElement *)saveToXML
{
    XMLElement *group = [XMLElement elementWithName:@"group"];

    [group.attributes setObject:self.name
                         forKey:@"name"];

    for (Server *server in self.servers)
    {
        XMLElement *serverXML = [server saveToXML];
        [group addElement:serverXML];
    }

    return group;
}

@end
