//
//  OAFURLRequest+OAuth2Flow.h
//  OAuth2Flow
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

#import "OAFURLRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface OAFURLRequest (OAuth2Flow)

- (instancetype)initWithBaseURL:(NSString *)baseURL
                    relativeURL:(NSString *)relativeURL
                          query:(BOOL)isQuery;

- (NSURLRequest *)foundationRequest;

- (void)setToken:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
