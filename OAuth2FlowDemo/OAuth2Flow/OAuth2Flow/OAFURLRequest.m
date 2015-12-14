//
//  OAFURLRequest.m
//  OAuth2Flow
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

#import "OAFURLRequest.h"
#import "OAFURLRequest+OAuth2Flow.h"

NS_ASSUME_NONNULL_BEGIN

@interface OAFURLRequest ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSMutableURLRequest *internalRequest;

@end

@implementation OAFURLRequest

- (void)configureRequestWithBlock:(void (^)(NSMutableURLRequest * _Nonnull))configurationBlock {
    if (configurationBlock) {
        configurationBlock(self.internalRequest);
    }
}

- (void)startWithStringBlockReponse:(void (^)(NSString * _Nullable, NSError * _Nullable))blockResponse {
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:self.internalRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (blockResponse) {
                blockResponse(nil, error);
            }
            return;
        }
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (blockResponse) {
            blockResponse(string, nil);
        }
    }];
    [dataTask resume];
}

- (void)startWithJSONBlockReponse:(void (^)(id _Nullable, NSError * _Nullable))blockResponse {
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:self.internalRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (blockResponse) {
                blockResponse(nil, error);
            }
            return;
        }
        NSError *JSONSerializationError = nil;
        id JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONSerializationError];
        if (blockResponse) {
            blockResponse(JSON, JSONSerializationError);
        }
    }];
    [dataTask resume];
}

#pragma mark - OAuth2Flow

- (instancetype)initWithBaseURL:(NSString *)baseURL
                    relativeURL:(NSString *)relativeURL
                          query:(BOOL)isQuery {
    self = [super init];
    
    if (self) {
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSString *stringURL = [NSString stringWithFormat:@"%@%@%@", baseURL, (isQuery) ? @"?": @"/", relativeURL];
        self.internalRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:stringURL]];
    }
    
    return self;
}

- (NSURLRequest *)foundationRequest {
    return self.internalRequest;
}

@end

NS_ASSUME_NONNULL_END
