//
//  NSDictionary+JSONKeyPath.m
//  Socionical
//
//  Created by Torben Schnuchel on 12.08.11.
//  Copyright 2011 na. All rights reserved.
//

#import "NSDictionary+JSONKeyPath.h"


@implementation NSDictionary (NSDictionary_JSONKeyPath)

- (id)objectForKeyPath:(id)firstKey, ... {
    
    id result = self;
    va_list keys;
    va_start(keys, firstKey);
    for (id key = firstKey; key != nil; key = va_arg(keys, id))
    {
        
        // next is NSDictionary it contains the key
        BOOL isDictContainingKey = [result isKindOfClass:[NSDictionary class]] && [[result allKeys] containsObject:key];
        // next is NSArray containing index
        BOOL isArrayContainingIndex = [result isKindOfClass:[NSArray class]] && ([result count] > [key intValue]);
        
        if (isDictContainingKey) {
            result = [result objectForKey:key];
        } else if(isArrayContainingIndex){
            result = [result objectAtIndex:[key intValue]];
        } else {
            result = nil;
            break;
        }
    }
    va_end(keys);
    
    return result;
}

@end

































