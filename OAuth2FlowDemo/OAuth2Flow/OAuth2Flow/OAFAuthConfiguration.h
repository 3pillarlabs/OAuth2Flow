//
//  OAFAuthConfiguration.h
//  OAuth2Flow
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OAFAuthConfiguration : NSObject

@property (nonatomic) NSString *consumerKey;
@property (nonatomic) NSString *consumerSecret;
@property (nonatomic) NSString *baseURL;
@property (nonatomic) NSString *requestTokenURL;
@property (nonatomic) NSString *authorizeURL;
@property (nonatomic) NSString *callbackURL;

@end

NS_ASSUME_NONNULL_END
