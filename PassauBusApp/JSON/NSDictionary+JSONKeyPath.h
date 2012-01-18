//
//  NSDictionary+JSONKeyPath.h
//  Socionical
//
//  Created by Torben Schnuchel on 12.08.11.
//  Copyright 2011 na. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (NSDictionary_JSONKeyPath)

- (id)objectForKeyPath:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

@end
