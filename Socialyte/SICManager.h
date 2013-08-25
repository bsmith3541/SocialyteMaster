//
//  SICManager.h
//  SICManager
//
//  Created by Hengchu Zhang on 8/16/13.
//  Copyright (c) 2013 edu.yale.hengchu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SIC_URL @"http://socialyte-rails.herokuapp.com/"
#define SIC_NULL [NSNull null]

@interface SICManager : NSObject

+ (NSDictionary *)createUserWithRailsID:(NSNumber *)railsID FID:(NSNumber *)FID AuthToken:(NSString *)authToken UserName:(NSString *)name UsingApp:(NSNumber*)useApp;
// note that time must be in the format of "yyyy-mm-dd hh:mm"
+ (NSDictionary *)createEventWithRailsID:(NSNumber *)railsID EID:(NSNumber *)EID EventName:(NSString *)name Address:(NSString *)address Description:(NSString *)description time:(NSString *)time latitude:(NSNumber *)latittude longitude:(NSNumber *)longitude FID:(NSNumber *)FID;
+ (void)registerUser:(NSDictionary *)user WithSuccessHandler:(void(^)(id returnedUser))successHandler andFailureHandler:(void(^)(NSString *response, NSError *error))failureHandler;
+ (void)followUsers:(NSArray *)users WithSuccessHandler:(void(^)(id result))successHandler andFailureHandler:(void(^)(NSString *response, NSError *error))failureHandler;
+ (void)postEvents:(NSArray *)events WithSuccessHandler:(void(^)(id result))successHandler andFailureHandler:(void(^)(NSString *response, NSError *error))failureHandler;
+ (void)rsvpEventWithID:(NSNumber *)eventID WithSuccessHandler:(void(^)(id result))successHandler andFailureHandler:(void(^)(NSString *response, NSError *error))failureHandler;
+ (void)checkInEventWithID:(NSNumber *)eventID WithSuccessHandler:(void(^)(id result))successHandler andFailureHandler:(void(^)(NSString *response, NSError *error))failureHandler;
+ (void)checkOutEventWithID:(NSNumber *)eventID WithSuccessHandler:(void(^)(id result))successHandler andFailureHandler:(void(^)(NSString *response, NSError *error))failureHandler;
+ (void)getEventsWithLatestEventID:(NSNumber *)latestID WithSuccessHandler:(void(^)(id result))successHandler andFailureHandler:(void(^)(NSString *response, NSError *error))failureHandler;
+ (void)getFeedsWithLatestFeedID:(NSNumber *)latestID WithSuccessHandler:(void(^)(id result))successHandler andFailureHandler:(void(^)(NSString *response, NSError *error))failureHandler;

// user info methods
+ (NSNumber *)loginUserID;
+ (NSNumber *)loginUserFID;
+ (NSString *)loginUserAuthToken;


@end
