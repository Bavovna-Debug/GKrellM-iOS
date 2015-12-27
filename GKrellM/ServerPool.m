//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "Banner.h"
#import "ServerGroup.h"
#import "ServerPool.h"
#import "XML.h"

@interface ServerPool ()

@property (strong, nonatomic, readwrite) NSMutableArray *serverGroups;

@end

@implementation ServerPool

@synthesize delegate               = _delegate;
@synthesize currentServerDelegate  = _currentServerDelegate;
@synthesize currentServer          = _currentServer;

#pragma mark - Object cunstructors/destructors

+ (ServerPool *)sharedServerPool
{
    static dispatch_once_t onceToken;
    static ServerPool *pool;
    
    dispatch_once(&onceToken, ^{
        pool = [[ServerPool alloc] init];
    });

    return pool;
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.serverGroups = [NSMutableArray array];

    return self;
}

- (void)setCurrentServer:(Server *)currentServer
{
    _currentServer = currentServer;

    if (self.currentServerDelegate != nil)
        [self.currentServerDelegate serverPool:self
                        currentServerChangedTo:currentServer];
}

#pragma mark - Server list

- (void)saveServerList
{
    if ([Banner sharedBanner] != nil)
        return;

    XMLDocument *document = [XMLDocument documentWithTarget:ServerListTarget
                                                    version:ServerListVersion];

    XMLElement *servers = [XMLElement elementWithName:@"servers"];

    [document setForest:servers];

    for (ServerGroup *group in self.serverGroups)
    {
        XMLElement *groupXML = [group saveToXML];
        [servers addElement:groupXML];
    }

    NSData *serversData = [document xmlData];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:serversData
                 forKey:ServerListKey];
    [defaults synchronize];

    NSLog(@"Server list saved.");

    if (self.delegate != nil)
        [self.delegate serverListChanged:self];
}

- (void)loadServerList
{
#ifdef SCREENSHOTING
    NSString *path = [[NSBundle mainBundle] bundlePath];
    path = [path stringByAppendingPathComponent:@"Servers.xml"];
    NSData *serversData = [[NSData alloc] initWithContentsOfFile:path];
#else
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *serversData = [defaults objectForKey:ServerListKey];
#endif
    XMLDocument *document = [XMLDocument documentFromData:serversData];

    XMLElement *servers = [document forest];
    for (XMLElement *groupElement in [servers elements])
    {
        ServerGroup *serverGroup = [ServerGroup serverGroupFromXML:groupElement];
        [self.serverGroups addObject:serverGroup];
    }

    NSLog(@"Server list loaded.");
}

#pragma mark - Events

- (void)prepareForBackground
{
    for (ServerGroup *group in self.serverGroups)
    {
        for (Server *server in group.servers)
        {
            [server pauseMonitoring];
        }
    }
}

- (void)serverSatusChanged:(NSObject *)server
{
    if (self.delegate != nil)
        [self.delegate serverPool:self
               serverSatusChanged:server];
}

#pragma mark - API

- (void)addNewServer:(Server *)server
{
    ServerGroup *serverGroup;
    if ([self.serverGroups count] == 0) {
        Banner *banner = [Banner sharedBanner];
        if (banner != nil) {
            serverGroup = [ServerGroup serverGroupWithName:@"Demo"];
            [self.serverGroups addObject:serverGroup];
        } else {
            serverGroup = [ServerGroup serverGroupWithName:@"Office"];
            [self.serverGroups addObject:serverGroup];
            [self.serverGroups addObject:[ServerGroup serverGroupWithName:@"Private"]];
            [self.serverGroups addObject:[ServerGroup serverGroupWithName:@"Mobile"]];
            [self.serverGroups addObject:[ServerGroup serverGroupWithName:@"Test"]];
        }
    } else {
        serverGroup = [self.serverGroups firstObject];

        Banner *banner = [Banner sharedBanner];
        if (banner != nil) {
            if ([serverGroup.servers count] > 0) {
                [banner alertLimitationOnNumberOfServers];
                return;
            }
        }
    }

    [[serverGroup servers] insertObject:server
                                atIndex:0];
}

- (Server *)serverById:(NSString *)serverId
{
    for (ServerGroup *group in self.serverGroups)
    {
        for (Server *server in group.servers)
        {
            if ([server.serverId isEqualToString:serverId] == YES)
                return server;
        }
    }

    return nil;
}

@end
