//
//  ViewController.m
//  Socialyte
//
//  Created by Brandon Smith on 8/25/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if(![FICManager isLoggedIn]) {
        NSLog(@"HELLOOOO");
        [self performLogin:Nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)performLogin:(id)sender {
    NSLog(@"Hellooooo");
    NSArray *permissions = [NSArray arrayWithObjects:@"basic_info", @"user_events", @"user_birthday", @"user_about_me",@"user_location", @"user_likes", nil];
    NSLog(@"Perrmisions: %@", permissions);
    
    //FBLoginView *loginView = [[FBLoginView alloc] init];
    //[self.view addSubview:loginView];
    
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      /* handle success + failure in block */
                                      NSLog(@"Session: %@", session);
                                      NSLog(@"Status: %u", status);
                                      NSLog(@"Error: %@", error);
                                      
                                      [FBRequestConnection
                                       startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                                                         id<FBGraphUser> user,
                                                                         NSError *error) {
                                           if (!error) {
                                               NSString *userInfo = @"";
                                               
                                               // Example: typed access (name)
                                               // - no special permissions required
                                               userInfo = [userInfo
                                                           stringByAppendingString:
                                                           [NSString stringWithFormat:@"Name: %@\n\n",
                                                            user.name]];
                                               
                                               // Example: typed access, (birthday)
                                               // - requires user_birthday permission
                                               userInfo = [userInfo
                                                           stringByAppendingString:
                                                           [NSString stringWithFormat:@"Birthday: %@\n\n",
                                                            user.birthday]];
                                               
                                               // Example: partially typed access, to location field,
                                               // name key (location)
                                               // - requires user_location permission
                                               userInfo = [userInfo
                                                           stringByAppendingString:
                                                           [NSString stringWithFormat:@"Location: %@\n\n",
                                                            user.location[@"name"]]];
                                               
                                               // Example: access via key (locale)
                                               // - no special permissions required
                                               userInfo = [userInfo
                                                           stringByAppendingString:
                                                           [NSString stringWithFormat:@"Locale: %@\n\n",
                                                            user[@"locale"]]];
                                               
                                               // Example: access via key for array (languages)
                                               // - requires user_likes permission
                                               if (user[@"languages"]) {
                                                   NSArray *languages = user[@"languages"];
                                                   NSMutableArray *languageNames = [[NSMutableArray alloc] init];
                                                   for (int i = 0; i < [languages count]; i++) {
                                                       languageNames[i] = languages[i][@"name"];
                                                   }   
                                                   userInfo = [userInfo
                                                               stringByAppendingString:
                                                               [NSString stringWithFormat:@"Languages: %@\n\n",
                                                                languageNames]];
                                               }
                                               NSLog(@"userInfo: %@", userInfo);
                                           }
                                       }];
                                  }];
//    [FICManager openSessionWithReadPermission:permissions successHandler:^(FBSession *session, FBSessionState status, NSError *error){
//        // do better stuff
//    }failureHandler:^{
//       // do stuff
//    }];
}

- (void)successfulLogin
{
    
}
@end
