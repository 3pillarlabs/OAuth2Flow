//
//  OAFAuthHandler.m
//  OAuth2Flow
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

#import "OAFAuthHandler.h"
#import "OAFAuthConfiguration.h"
#import "OAFURLParameterPair.h"
#import "OAFURLRequest.h"
#import "OAFAuthHandler+OAuth2Flow.h"
#import "OAFURLRequest+OAuth2Flow.h"

NS_ASSUME_NONNULL_BEGIN

static NSTimeInterval const kTimeout = 10.;

static NSString * const kHTTPMethodPost = @"POST";

@interface OAFAuthHandler () <NSURLSessionDelegate>

@property (nonatomic) OAFAuthConfiguration *configuration;
@property (nonatomic, nullable) NSString *code;
@property (nonatomic, nullable) NSString *refreshToken;
@property (nonatomic, nullable) NSString *token;

@property (weak, nonatomic, nullable) id<OAFAuthHandlerDelegate> delegate;

@end

@implementation OAFAuthHandler

- (instancetype)initWithConfiguration:(OAFAuthConfiguration *)configuration {
    self = [super init];
    
    if (self) {
        self.configuration = configuration;
    }
    
    return self;
}

- (void)refreshTokensFromDictionary:(NSDictionary *)dictionary {
    self.refreshToken = dictionary[@"refresh_token"];
    NSNumber *timeIntervalNumber = dictionary[@"expires_in"];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fmax(timeIntervalNumber.doubleValue - kTimeout, kTimeout) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf updateToken];
    });
}

#pragma mark - Request Handling

- (OAFURLRequest *)requestWithRelativeURL:(NSString *)relativeURL {
    NSAssert(self.configuration.baseURL && self.configuration.baseURL.length, @"Auth configuration doesn't have base URL");
    OAFURLRequest *request = [[OAFURLRequest alloc] initWithBaseURL:self.configuration.baseURL relativeURL:relativeURL query:NO];
    [request configureRequestWithBlock:^(NSMutableURLRequest * _Nonnull request) {
        NSString *tokenValue = [NSString stringWithFormat:@"Bearer %@", self.token];
        [request setValue:tokenValue forHTTPHeaderField:@"Authorization"];
    }];
    return request;
}

- (OAFURLRequest *)tokenRequestURL {
    NSAssert(self.configuration.consumerSecret && self.configuration.consumerSecret.length, @"Auth configuration doesn't have consumer secret");
    NSAssert(self.configuration.requestTokenURL && self.configuration.requestTokenURL.length, @"Auth configuration doesn't have request token URL");
    OAFURLRequest *URLRequest = [[OAFURLRequest alloc] initWithBaseURL:self.configuration.requestTokenURL relativeURL:@"" query:NO];
    [URLRequest configureRequestWithBlock:^(NSMutableURLRequest * _Nonnull request) {
        [request setHTTPMethod:kHTTPMethodPost];
        
        NSDictionary<NSString *, NSString *> *parameters = @{@"client_id" : self.configuration.consumerKey,
                                                             @"client_secret" : self.configuration.consumerSecret,
                                                             @"grant_type" : @"authorization_code",
                                                             @"code" : self.code,
                                                             @"redirect_uri" : [self.configuration.callbackURL stringByRemovingPercentEncoding]};
        NSArray<OAFURLParameterPair *> *pairs = [OAFURLParameterPair URLParametersFromDictionary:parameters];
        NSString *body = [pairs joinedURLParameterPairs];
        [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    return URLRequest;
}

- (OAFURLRequest *)refreshTokenURL {
    if (!self.refreshToken) {
        return nil;
    }
    OAFURLRequest *URLRequest = [[OAFURLRequest alloc] initWithBaseURL:self.configuration.requestTokenURL relativeURL:@"" query:NO];
    [URLRequest configureRequestWithBlock:^(NSMutableURLRequest * _Nonnull request) {
        [request setHTTPMethod:kHTTPMethodPost];
        
        NSDictionary<NSString *, NSString *> *parameters = @{@"client_id" : self.configuration.consumerKey,
                                                             @"client_secret" : self.configuration.consumerSecret,
                                                             @"grant_type" : @"refresh_token",
                                                             @"refresh_token" : self.refreshToken};
        NSArray<OAFURLParameterPair *> *pairs = [OAFURLParameterPair URLParametersFromDictionary:parameters];
        NSString *body = [pairs joinedURLParameterPairs];
        [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    return URLRequest;
}

- (void)requestToken {
    [self.delegate authHandlerWillRequestToken:self];
    OAFURLRequest *tokenRequest = [self tokenRequestURL];
    [tokenRequest startWithJSONBlockReponse:^(id _Nullable response, NSError * _Nullable error) {
        if (error) {
            if ([self.delegate respondsToSelector:@selector(authHandler:didFailWithError:)]) {
                [self.delegate authHandler:self didFailWithError:error];
            }
            return;
        }
        NSDictionary *JSON = response;
        self.token = JSON[@"access_token"];
        if (!self.token) {
            if ([self.delegate respondsToSelector:@selector(authHandler:didFailWithError:)]) {
                NSError *accessTokenError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                                code:-1
                                                            userInfo:@{NSLocalizedDescriptionKey: @"Failed to retrieve access token."}];
                [self.delegate authHandler:self didFailWithError:accessTokenError];
            }
            return;
        }
        self.code = nil;
        [self refreshTokensFromDictionary:JSON];
        [self.delegate authHandlerDidRequestToken:self];
    }];
}

- (void)updateToken {
    OAFURLRequest *refreshTokenRequest = [self refreshTokenURL];
    [refreshTokenRequest startWithJSONBlockReponse:^(id  _Nullable response, NSError * _Nullable error) {
        [self refreshTokensFromDictionary:response];
    }];
}

#pragma mark - OAuth2Flow

- (BOOL)containsAuthenticationInfo:(NSURL *)URL {
    BOOL containsCallback = [[URL.absoluteString lowercaseString] hasPrefix:[self.configuration.callbackURL lowercaseString]];
    if (containsCallback) {
        NSString *parameters = [URL.absoluteString substringFromIndex:self.configuration.callbackURL.length + 1];
        NSArray *values = [parameters componentsSeparatedByString:@"="];
        self.code = [values lastObject];
        [self requestToken];
    }
    return containsCallback;
}

- (NSURLRequest *)authorizeURL {
    NSAssert(self.configuration.consumerKey && self.configuration.consumerKey.length, @"Auth configuration doesn't have consumer key");
    NSAssert(self.configuration.callbackURL && self.configuration.callbackURL.length, @"Auth configuration doesn't have callback URL");
    NSAssert(self.configuration.authorizeURL && self.configuration.authorizeURL.length, @"Auth configuration doesn't have authorize URL");
    NSDictionary<NSString *, NSString *> *parameters = @{@"client_id" : self.configuration.consumerKey,
                                                         @"response_type" : @"code",
                                                         @"redirect_uri" : self.configuration.callbackURL};
    NSArray<OAFURLParameterPair *> *pairs = [OAFURLParameterPair URLParametersFromDictionary:parameters];
    OAFURLRequest *request = [[OAFURLRequest alloc] initWithBaseURL:self.configuration.authorizeURL
                                                        relativeURL:[pairs joinedURLParameterPairs]
                                                              query:YES];
    return [request foundationRequest];
}

@end

NS_ASSUME_NONNULL_END
