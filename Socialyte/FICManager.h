//
//  FICManager.h
//  FacebookInterfaceCenter
//
//  Created by Hengchu Zhang on 8/12/13.
//  Copyright (c) 2013 edu.yale.hengchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FICManager : NSObject

// use this command to check whether FICManager has logged in user info or not
+ (BOOL)isLoggedIn;
// get the information for the user logged in
+ (void)getMyInformationWithCompletionhandler:(void(^)(id result, NSError *error))handler;
// use this command to login a user, handle view changes in success/failureHandler
+ (void)openSessionWithReadPermission:(NSArray *)readPermissions successHandler:(void(^)())successHandler failureHandler:(void(^)())failureHandler;
// get a list of all events for the user logged in
+ (void)getEventsWithCompletionHandler:(void(^)(id result, NSError *error))handler;
// get a list of all events for a friend of the user
// the user must be in the form of an NSDictionary with a field named uid, which contains the uid of the user
// returned from a FQL request, otherwise the program will crash
+ (void)getEventsForFriend:(NSDictionary *)friend WithCompletionHandler:(void(^)(id result, NSError *error))handler;
// get a list of all the friends for the user logged in
+ (void)getFriendsWithCompletionHandler:(void(^)(id result, NSError *error))handler;
// log the user out
+ (void)destroySession;

@end
