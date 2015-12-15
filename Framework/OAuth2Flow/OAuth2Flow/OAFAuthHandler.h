//
//  OAFAuthHandler.h
//  OAuth2Flow
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OAFAuthConfiguration;
@class OAFURLRequest;

@interface OAFAuthHandler : NSObject

- (instancetype)initWithConfiguration:(OAFAuthConfiguration *)configuration;

- (OAFURLRequest *)requestWithRelativeURL:(NSString *)relativeURL;

@end

NS_ASSUME_NONNULL_END

