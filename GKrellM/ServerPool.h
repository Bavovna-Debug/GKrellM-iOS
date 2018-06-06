//
//  GKrellM
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#undef SCREENSHOTING
#else
#undef SCREENSHOTING
#endif

@protocol ServerPoolDelegate;
@protocol CurrentServerDelegate;

@interface ServerPool : NSObject

#define ServerListKey      @"Servers"
#define ServerListTarget   @"gkrellm"
#define ServerListVersion  @"1.0"

@property (strong, nonatomic, readwrite) id<ServerPoolDelegate>     delegate;
@property (strong, nonatomic, readwrite) id<CurrentServerDelegate>  currentServerDelegate;

@property (strong, nonatomic, readonly)  NSMutableArray  *serverGroups;
@property (strong, nonatomic, readwrite) Server          *currentServer;

+ (ServerPool *)sharedServerPool;

- (id)init;

- (void)saveServerList;

- (void)loadServerList;

- (void)prepareForBackground;

- (void)addNewServer:(Server *)server;

- (void)serverSatusChanged:(NSObject *)server;

- (Server *)serverById:(NSString *)serverId;

@end

@protocol ServerPoolDelegate <NSObject>

@required

- (void)serverListChanged:(ServerPool *)serverPool;

- (void)serverPool:(ServerPool *)serverPool
serverSatusChanged:(NSObject *)server;

@end

@protocol CurrentServerDelegate <NSObject>

@required

- (void)serverPool:(ServerPool *)serverPool
currentServerChangedTo:(Server *)server;

@end
