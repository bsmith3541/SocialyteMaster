//
//  NSString+JSON.h
//  SICManager
//
//  Created by Hengchu Zhang on 8/16/13.
//  Copyright (c) 2013 edu.yale.hengchu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSON)

+ (NSDictionary *)parseJSON:(NSString *)jsonString;

@end
