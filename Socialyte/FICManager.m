//
//  FICManager.m
//  FacebookInterfaceCenter
//
//  Created by Hengchu Zhang on 8/12/13.
//  Copyright (c) 2013 edu.yale.hengchu. All rights reserved.
//

#import "FICManager.h"

@implementation FICManager

+ (BOOL)isLoggedIn
{
    return ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded);
}

+ (void)checkLogin
{
    NSLog(@"%u", [FBSession activeSession].state);
    if ([FBSession activeSession].state != FBSessionStateCreatedTokenLoaded && [FBSession activeSession].state != 513) [NSException raise:@"FICManager: User not logged in exception" format:@"There is no active session"];

}

+ (void)openSessionWithReadPermission:(NSArray *)readPermissions successHandler:(void(^)())successHandler failureHandler:(void(^)())failureHandler
{
    [FBSession openActiveSessionWithReadPermissions:readPermissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      if ([session isOpen]) {
                                          successHandler();
                                      } else {
                                          failureHandler();
                                      }
                                      if (error) NSLog(@"FICManager: %@", error.localizedDescription);
                                  }];
}

#define FQL_EVENTS_COMMAND @"SELECT uid, eid, rsvp_status, start_time FROM event_member WHERE uid = me()"
#define FQL_EVENTS_COMMAND_V2 @"SELECT eid, name, venue, location, description, start_time FROM event WHERE eid IN (SELECT eid from event_member WHERE uid = me())"
#define FQL_EVENTS_COMMAND_FOR_FRIEND(friend) [NSString stringWithFormat:@"SELECT eid, name, venue, location, description, start_time FROM event WHERE eid IN (SELECT eid from event_member WHERE uid = %@)", [friend objectForKey:@"uid"]]

+ (void)getEventsWithCompletionHandler:(void(^)(id result, NSError *error))handler
{
    [self checkLogin];
    NSDictionary *params = [NSDictionary dictionaryWithObject:FQL_EVENTS_COMMAND_V2 forKey:@"q"];
    FBRequest *request = [[FBRequest alloc] initWithSession:[FBSession activeSession] graphPath:@"/fql" parameters:params HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) NSLog(@"%@", error.localizedDescription);
        handler(result, error);
    }];
}

#define FQL_ME_COMMAND @"SELECT uid, name, pic_small FROM user WHERE uid = me()"
+ (void)getMyInformationWithCompletionhandler:(void (^)(id, NSError *))handler
{
    [self checkLogin];
    NSDictionary *params = [NSDictionary dictionaryWithObject:FQL_ME_COMMAND forKey:@"q"];
    FBRequest *request = [[FBRequest alloc] initWithSession:[FBSession activeSession] graphPath:@"/fql" parameters:params HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) NSLog(@"%@", error.localizedDescription);
        handler(result, error);
    }];
}

+ (void)getEventsForFriend:(NSDictionary *)friend WithCompletionHandler:(void(^)(id result, NSError *error))handler
{
    [self checkLogin];
    if (![friend objectForKey:@"uid"]) [NSException raise:@"FICManager: Friend events query exception" format:@"Friend object has no uid field, %@", friend];
    NSDictionary *params = [NSDictionary dictionaryWithObject:FQL_EVENTS_COMMAND_FOR_FRIEND(friend) forKey:@"q"];
    FBRequest *request = [[FBRequest alloc] initWithSession:[FBSession activeSession] graphPath:@"/fql" parameters:params HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) NSLog(@"%@", error.localizedDescription);
        handler(result, error);
    }];
}

#define FQL_FRIENDS_COMMAND @"SELECT uid, name, pic_small FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me())"

+ (void)getFriendsWithCompletionHandler:(void(^)(id result, NSError *error))handler
{
    [self checkLogin];
    NSDictionary *params = [NSDictionary dictionaryWithObject:FQL_FRIENDS_COMMAND forKey:@"q"];
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) NSLog(@"%@", error.localizedDescription);
        handler(result, error);
    }];
}

+ (void)issueFQLRequest:(NSString *)fqlRequest WithCompletionHandler:(void(^)(id result, NSError* error))handler
{
    [self checkLogin];
    NSDictionary *params = [NSDictionary dictionaryWithObject:fqlRequest forKey:@"q"];
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) NSLog(@"%@", error.localizedDescription);
        handler(result, error);
    }];
}

+ (void)destroySession
{
    [[FBSession activeSession] close];
    [[FBSession activeSession] closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
}

@end
