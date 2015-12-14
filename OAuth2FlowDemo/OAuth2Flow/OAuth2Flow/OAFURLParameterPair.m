//
//  OAFURLParameterPair.m
//  OAuth2Flow
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

#import "OAFURLParameterPair.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kURLParameterPairComponentsSeparator = @"=";
static NSString * const kURLParameterPairsSeparator = @"&";

@implementation OAFURLParameterPair

+ (nullable instancetype)URLParameterPairFromString:(NSString *)string {
    NSArray<NSString *> *pairComponents = [string componentsSeparatedByString:kURLParameterPairComponentsSeparator];
    if (pairComponents.count == 2) {
        OAFURLParameterPair *URLParameterPair = [[OAFURLParameterPair alloc] init];
        URLParameterPair.key = [pairComponents firstObject];
        URLParameterPair.object = [pairComponents lastObject];
        return URLParameterPair;
    }
    return nil;
}

+ (NSArray<OAFURLParameterPair *> *)URLParametersFromDictionary:(NSDictionary<NSString *,NSString *> *)dictionary {
    NSMutableArray *pairs = [[NSMutableArray alloc] init];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        OAFURLParameterPair *URLParameterPair = [[OAFURLParameterPair alloc] init];
        URLParameterPair.key = key;
        URLParameterPair.object = obj;
        [pairs addObject:URLParameterPair];
    }];
    return pairs;
}

- (NSString *)stringFromPair {
    return [NSString stringWithFormat:@"%@%@%@", self.key, kURLParameterPairComponentsSeparator, self.object];
}

@end

@implementation NSArray (OAFURLParameterPair)

- (NSString *)joinedURLParameterPairs {
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    for (OAFURLParameterPair *parameterPair in self) {
        [mutableString appendFormat:@"%@%@%@", parameterPair.key, kURLParameterPairComponentsSeparator, parameterPair.object];
        if (parameterPair != [self lastObject]) {
            [mutableString appendString:kURLParameterPairsSeparator];
        }
    }
    return mutableString;
}

@end

@implementation NSString (OAFURLParameterPair)

- (NSArray<OAFURLParameterPair *> *)URLParameterPairsSeparated {
    NSArray<NSString *> *stringURLParameterPairs = [self componentsSeparatedByString:kURLParameterPairsSeparator];
    NSMutableArray *URLParameterPairs = [[NSMutableArray alloc] init];
    for (NSString *stringPair in stringURLParameterPairs) {
        OAFURLParameterPair *URLParameterPair = [OAFURLParameterPair URLParameterPairFromString:stringPair];
        [URLParameterPairs addObject:URLParameterPair];
    }
    return URLParameterPairs;
}

@end

NS_ASSUME_NONNULL_END
