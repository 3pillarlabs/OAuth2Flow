//
//  OAFAuthHandler+OAuthFlow.h
//  OAuth2Flow
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

#import <OAuth2Flow/OAFAuthHandler.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OAFAuthHandlerDelegate;

@interface OAFAuthHandler (OAuth2Flow)

@property (weak, nonatomic, nullable) id<OAFAuthHandlerDelegate> delegate;

- (NSURLRequest *)authorizeURL;
- (BOOL)containsAuthenticationInfo:(NSURL *)URL;

@end

@protocol OAFAuthHandlerDelegate <NSObject>

- (void)authHandlerWillRequestToken:(OAFAuthHandler *)tokenHandler;
- (void)authHandlerDidRequestToken:(OAFAuthHandler *)tokenHandler;

@optional
- (void)authHandler:(OAFAuthHandler *)tokenHandler didFailWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
