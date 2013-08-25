//
//  NSString+JSON.m
//  SICManager
//
//  Created by Hengchu Zhang on 8/16/13.
//  Copyright (c) 2013 edu.yale.hengchu. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)

+ (NSDictionary *)parseJSON:(NSString *)jsonString
{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *parsedDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    return parsedDict;
}

@end
