//
//  OAFViewController.h
//  OAuth2Flow
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class OAFAuthConfiguration;
@class OAFAuthHandler;
@protocol OAFViewControllerDelegate;

@interface OAFViewController : UIViewController

@property (weak, nonatomic) id<OAFViewControllerDelegate> delegate;

- (nullable instancetype)initWithConfiguration:(OAFAuthConfiguration *)configuration;

@end

@protocol OAFViewControllerDelegate <NSObject>

- (void)viewController:(OAFViewController *)viewController didFinishAuthFlow:(OAFAuthHandler *)authHandler;

@end

NS_ASSUME_NONNULL_END
