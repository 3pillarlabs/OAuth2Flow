//
//  OAFURLRequest.h
//  OAuth2Flow
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OAFURLRequest : NSObject

- (void)configureRequestWithBlock:(void (^)(NSMutableURLRequest * _Nonnull request))configurationBlock;

- (void)startWithStringBlockReponse:(void (^)(NSString * _Nullable response, NSError * _Nullable error))blockResponse;
- (void)startWithJSONBlockReponse:(void (^)(id _Nullable response, NSError * _Nullable error))blockResponse;

@end

NS_ASSUME_NONNULL_END
