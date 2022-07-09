//
//  API.m
//  Muslim Utility
//
//  Created by Umran Jameel on 4/1/22.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "API.h"

@implementation API
- (NSString *) get: (NSString *) URL {
    return [[NSString alloc] initWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: URL]] encoding:NSUTF8StringEncoding];
}
@end
