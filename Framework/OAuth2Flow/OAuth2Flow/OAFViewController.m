//
//  OAFViewController.m
//  OAuth2Flow
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

#import "OAFViewController.h"
#import "OAFAuthConfiguration.h"
#import "OAFAuthHandler.h"
#import "OAFAuthHandler+OAuth2Flow.h"

NS_ASSUME_NONNULL_BEGIN

static NSTimeInterval const kAnimationDuration = 0.3;

@interface OAFViewController () <UIWebViewDelegate, OAFAuthHandlerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *overlayViews;

@property (nonatomic) OAFAuthConfiguration *configuration;
@property (nonatomic) OAFAuthHandler *authHandler;

@end

@implementation OAFViewController

- (nullable instancetype)initWithConfiguration:(OAFAuthConfiguration *)configuration {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"OAuth2FlowResources" ofType:@"bundle"];
    NSBundle *bundle = nil;
    if (bundlePath) {
        bundle = [NSBundle bundleWithPath:bundlePath];
    } else {
        bundle = [NSBundle bundleWithIdentifier:@"com.3PillarGlobal.OAuth2Flow"];
    }
    
    if (!bundle) {
        return nil;
    }
    
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:bundle];
    
    if (self) {
        self.configuration = configuration;
        self.authHandler = [[OAFAuthHandler alloc] initWithConfiguration:configuration];
        self.authHandler.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.webView loadRequest:[self.authHandler authorizeURL]];
}

- (void)showOverlayViews:(BOOL)show {
    [UIView animateWithDuration:kAnimationDuration delay:0. options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         for (UIView *view in self.overlayViews) {
                             view.alpha = (show) ? 1.f : 0.f;
                         }
                     } completion:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self.authHandler containsAuthenticationInfo:request.URL]) {
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (![self.activityIndicator isAnimating]) {
        [self.activityIndicator startAnimating];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([self.activityIndicator isAnimating]) {
        [self.activityIndicator stopAnimating];
    }
}

#pragma mark - OAFAuthHandlerDelegate

- (void)authHandlerWillRequestToken:(OAFAuthHandler *)tokenHandler {
    if (![self.activityIndicator isAnimating]) {
        [self.activityIndicator startAnimating];
    }
    [self showOverlayViews:YES];
}

- (void)authHandlerDidRequestToken:(OAFAuthHandler *)tokenHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.activityIndicator isAnimating]) {
            [self.activityIndicator stopAnimating];
        }
        [self showOverlayViews:NO];
        [self.delegate viewController:self didFinishAuthFlow:self.authHandler];
    });
}

- (void)authHandler:(OAFAuthHandler *)tokenHandler didFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.activityIndicator isAnimating]) {
            [self.activityIndicator stopAnimating];
        }
        [self showOverlayViews:NO];
    });
}

@end

NS_ASSUME_NONNULL_END
