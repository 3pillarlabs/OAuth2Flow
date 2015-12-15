//
//  OAFURLParameterPair.h
//  OAuth2Flow
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OAFURLParameterPair : NSObject

@property (nonatomic) NSString *key;
@property (nonatomic) NSString *object;

+ (nullable instancetype)URLParameterPairFromString:(NSString *)string;
+ (NSArray<OAFURLParameterPair *> *)URLParametersFromDictionary:(NSDictionary<NSString *, NSString *> *)dictionary;

- (NSString *)stringFromPair;

@end

@interface NSArray (OAFURLParameterPair)

- (NSString *)joinedURLParameterPairs;

@end

@interface NSString (OAFURLParameterPair)

- (NSArray<OAFURLParameterPair *> *)URLParameterPairsSeparated;

@end

NS_ASSUME_NONNULL_END
