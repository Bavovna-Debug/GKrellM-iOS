//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import "InterfaceController.h"
#import "Server.h"

@interface InterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *serverNameLabel;

@end

static id staticInterfaceController;

@implementation InterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];

    staticInterfaceController = self;

    [self registerForNotificationsWithIdentifier:@"startMonitoring"];
}

- (void)willActivate
{
    [super willActivate];

    //[self registerForNotificationsWithIdentifier:@"startMonitoring"];
}

- (void)didDeactivate
{
    //[self unregisterForNotificationsWithIdentifier:@"startMonitoring"];

    [super didDeactivate];
}

- (IBAction)upButton
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.Zeppelinium.GKrellM"];
    [defaults synchronize];
    NSString *serverName = [defaults objectForKey:@"test"];
    [self.serverNameLabel setText:serverName];

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:@"content" forKey:@"key1"];
    [userInfo setObject:@"getData" forKey:@"request"];

    [WKInterfaceController openParentApplication:userInfo
                                           reply:^(NSDictionary *replyInfo, NSError *error) {
                                               NSLog(@"In Watch");
                                           }];
}

- (void)registerForNotificationsWithIdentifier:(nullable NSString *)identifier
{
    [self unregisterForNotificationsWithIdentifier:identifier];

    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)identifier;
    CFNotificationCenterAddObserver(center,
                                    (__bridge const void *)(self),
                                    wormholeNotificationCallback,
                                    str,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDrop);
}

- (void)unregisterForNotificationsWithIdentifier:(nullable NSString *)identifier
{
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)identifier;
    CFNotificationCenterRemoveObserver(center,
                                       (__bridge const void *)(self),
                                       str,
                                       NULL);
}

void wormholeNotificationCallback(CFNotificationCenterRef center,
                                  void *observer,
                                  CFStringRef name,
                                  const void *object,
                                  CFDictionaryRef userInfo)
{
    NSMutableDictionary *options = (__bridge NSMutableDictionary *)userInfo;
    for (NSString *key in options.allKeys)
        NSLog(@"KEY: %@", key);
    NSString *serverName = [options objectForKey:@"serverName"];
    NSLog(@"SERVER2: %@", name);

    InterfaceController *interfaceController = (InterfaceController *)staticInterfaceController;
    [interfaceController.serverNameLabel setText:serverName];
}

@end



