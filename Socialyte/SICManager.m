//
//  SICManager.m
//  SICManager
//
//  Created by Hengchu Zhang on 8/16/13.
//  Copyright (c) 2013 edu.yale.hengchu. All rights reserved.
//

#import "SICManager.h"
#import "AFNetworking.h"
#import "NSString+JSON.h"

#define SIC_USER @"SIC_USER_KEY"

@implementation SICManager

+ (void)checkUserInfo
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:SIC_USER]) {
        [NSException raise:@"SICManager no user exception" format:@"no user stored"];
    }
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:SIC_USER] objectForKey:@"auth_token"]) {
        [NSException raise:@"SICManager no auth_token exception" format:@"no user auth_token stored"];
    }
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:SIC_USER] objectForKey:@"id"]) {
        [NSException raise:@"SICManager no id exception" format:@"no user id stored"];
    }
}

+ (AFHTTPClient *)SICClient
{
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SIC_URL]];
    [client setParameterEncoding:AFJSONParameterEncoding];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    return client;
}

+ (NSString *)followUserPath
{
    return [NSString stringWithFormat:@"/users/%@/follow_users", [self loginUserID]];
}

+ (NSDictionary *)createUserWithRailsID:(NSNumber *)railsID FID:(NSNumber *)FID AuthToken:(NSString *)authToken UserName:(NSString *)name UsingApp:(NSNumber *)useApp
{
    NSArray *keys = [NSArray arrayWithObjects:@"name", @"FID", @"id", @"using_app", @"auth_token", nil];
    NSArray *objects = [NSArray arrayWithObjects:name, FID, railsID, useApp, authToken, nil];
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}

+ (NSDictionary *)createEventWithRailsID:(NSNumber *)railsID EID:(NSNumber *)EID EventName:(NSString *)name Address:(NSString *)address Description:(NSString *)description time:(NSString *)time latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude FID:(NSNumber *)FID
{
    NSArray *keys = [NSArray arrayWithObjects:@"id", @"EID", @"name", @"address", @"description", @"time", @"latitude", @"longitude", @"FID", nil];
    NSArray *objects = [NSArray arrayWithObjects:railsID, EID, name, address, description, time, latitude, longitude, FID, nil];
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}

+ (NSNumber *)loginUserID
{
    [self checkUserInfo];
    return [[[NSUserDefaults standardUserDefaults] objectForKey:SIC_USER] objectForKey:@"id"];
}

+ (NSNumber *)loginUserFID
{
    [self checkUserInfo];
    return [[[NSUserDefaults standardUserDefaults] objectForKey:SIC_USER] objectForKey:@"FID"];
}

+ (NSString *)loginUserAuthToken
{
    [self checkUserInfo];
    return [[[NSUserDefaults standardUserDefaults] objectForKey:SIC_USER] objectForKey:@"auth_token"];
}

+ (void)saveUserToUserDefaults:(NSDictionary *)user
{
    [[NSUserDefaults standardUserDefaults] setObject:user forKey:SIC_USER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)registerUser:(NSDictionary *)user WithSuccessHandler:(void (^)(id returnedUser))successHandler andFailureHandler:(void (^)(NSString *response, NSError *error))failureHandler
{
    AFHTTPClient *client = [self SICClient];

    [client postPath:@"/users" parameters:user success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [operation responseString];
        id parsedDict = [NSString parseJSON:responseString];
        if ([parsedDict objectForKey:@"auth_token"]) {
            [self saveUserToUserDefaults:parsedDict];
        }
        if (successHandler) successHandler(parsedDict);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *responseString = [operation responseString];
        if (failureHandler) failureHandler(responseString, error);
    }];
}

+ (void)followUsers:(NSArray *)users WithSuccessHandler:(void (^)(id result))successHandler andFailureHandler:(void (^)(NSString *, NSError *))failureHandler
{
    [self checkUserInfo];
    
    AFHTTPClient *client = [self SICClient];
    // the user who is logged in
    NSDictionary *user = [NSDictionary dictionaryWithObjectsAndKeys:[self loginUserFID], @"FID", [self loginUserAuthToken], @"auth_token", nil];
    // create objects array
    NSArray *objects = [NSArray arrayWithObjects:users, user, nil];
    // setup keys
    NSArray *keys = [NSArray arrayWithObjects:@"following", @"user", nil];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [client putPath:[self followUserPath] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [operation responseString];
        id parsedResult = [NSString parseJSON:responseString];
        if (successHandler) successHandler(parsedResult);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *responseString = [operation responseString];
        if (failureHandler) failureHandler(responseString, error);
    }];
}

+ (void)postEvents:(NSArray *)events WithSuccessHandler:(void (^)(id))successHandler andFailureHandler:(void (^)(NSString *, NSError *))failureHandler
{
    [self checkUserInfo];
    
    AFHTTPClient *client = [self SICClient];
    NSDictionary *user = [NSDictionary dictionaryWithObjectsAndKeys:[self loginUserFID], @"FID", [self loginUserAuthToken], @"auth_token", nil];
    NSArray *objects = [NSArray arrayWithObjects:events, user, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"events", @"user", nil];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    [client postPath:@"/events/populate" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString =[operation responseString];
        id parsedResult = [NSString parseJSON:responseString];
        if (successHandler) successHandler(parsedResult);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *respnseString = [operation responseString];
        if (failureHandler) failureHandler(respnseString, error);
    }];
}

+ (void)rsvpEventWithID:(NSNumber *)eventID WithSuccessHandler:(void (^)(id))successHandler andFailureHandler:(void (^)(NSString *, NSError *))failureHandler
{
    [self checkUserInfo];
    
    AFHTTPClient *client = [self SICClient];
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"RSVP", nil];
    NSDictionary *user = [NSDictionary dictionaryWithObjectsAndKeys:[self loginUserFID], @"FID", [self loginUserAuthToken], @"auth_token", nil];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:event, @"event", user, @"user", nil];
    [client putPath:[NSString stringWithFormat:@"/events/%@/rsvp", eventID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [operation responseString];
        id result = [NSString parseJSON:responseString];
        if (successHandler) successHandler(result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *responseString = [operation responseString];
        if (failureHandler) failureHandler(responseString, error);
    }];
}

+ (void)checkInEventWithID:(NSNumber *)eventID WithSuccessHandler:(void (^)(id))successHandler andFailureHandler:(void (^)(NSString *, NSError *))failureHandler
{
    [self checkUserInfo];
    
    AFHTTPClient *client = [self SICClient];
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"check_in", nil];
    NSDictionary *user = [NSDictionary dictionaryWithObjectsAndKeys:[self loginUserFID], @"FID", [self loginUserAuthToken], @"auth_token", nil];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:event, @"event", user, @"user", nil];
    [client putPath:[NSString stringWithFormat:@"/events/%@/checkin", eventID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [operation responseString];
        id result = [NSString parseJSON:responseString];
        if (successHandler) successHandler(result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *responseString = [operation responseString];
        if (failureHandler) failureHandler(responseString, error);
    }];
}

+ (void)checkOutEventWithID:(NSNumber *)eventID WithSuccessHandler:(void (^)(id))successHandler andFailureHandler:(void (^)(NSString *, NSError *))failureHandler
{
    [self checkUserInfo];
    
    AFHTTPClient *client = [self SICClient];
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"check_in", nil];
    NSDictionary *user = [NSDictionary dictionaryWithObjectsAndKeys:[self loginUserFID], @"FID", [self loginUserAuthToken], @"auth_token", nil];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:event, @"event", user, @"user", nil];
    [client putPath:[NSString stringWithFormat:@"/events/%@/checkout", eventID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [operation responseString];
        id result = [NSString parseJSON:responseString];
        if (successHandler) successHandler(result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *responseString = [operation responseString];
        if (failureHandler) failureHandler(responseString, error);
    }];
}

+ (void)getEventsWithLatestEventID:(NSNumber *)latestID WithSuccessHandler:(void (^)(id))successHandler andFailureHandler:(void (^)(NSString *, NSError *))failureHandler
{
    [self checkUserInfo];
    
    AFHTTPClient *client = [self SICClient];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:latestID, @"last_event_id", [self loginUserAuthToken], @"auth_token", nil];
    [client getPath:@"/events/latest" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [operation responseString];
        id parsedResult = [NSString parseJSON:responseString];
        if (successHandler) successHandler(parsedResult);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *responseString = [operation responseString];
        if (failureHandler) failureHandler(responseString, error);
    }];
}

+ (void)getFeedsWithLatestFeedID:(NSNumber *)latestID WithSuccessHandler:(void (^)(id))successHandler andFailureHandler:(void (^)(NSString *, NSError *))failureHandler
{
    [self checkUserInfo];
    
    AFHTTPClient *client = [self SICClient];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:latestID, @"last_feed_id", [self loginUserAuthToken], @"auth_token", nil];
    [client getPath:@"/feeds/latest" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [operation responseString];
        id parsedResult = [NSString parseJSON:responseString];
        if (successHandler) successHandler(parsedResult);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *responseString = [operation responseString];
        if (failureHandler) failureHandler(responseString, error);
    }];
}

@end
