# OAuth2Flow

A library which facilitates the OAuth v2 authentication to services. It is available starting with iOS 6 and later, Objective-C or Swift.

**Project Rationale**

The purpose of the library/framework is to provide an user friendly experience when authentication is done with Facebook, Twitter or any other service which provides OAuth v2 authentication. By using a view controller instead Safari app you solve 2 problems:

1. Remove the need to switch back and forth between Safari and your app (not the best user experience in the world).
2. Because your app doesn't need to receive input from Safari, you don't need handle possible security issues from interprocess communication.

## Installation

Prior to iOS 8.0 you need to link your app with the static library (libOAuth2FlowLibrary) and add the resources bundle(OAuth2FlowResources) to 'Copy Bundle Resources'.
Please read [Apple's documentation](https://developer.apple.com/library/ios/technotes/iOSStaticLibraries/Articles/configuration.html) if you don't know how to link your project against the library.

iOS 8.0 and later is recommended to use the framework (OAuth2Flow). Make sure that the framework is added to 'Embedded framework' list.

## Usage

Configure authentication.

**Objective-C**

```objective-c
@import OAuth2Flow; 
// #import "OAuth2FlowLibrary.h" for static library

// some code ...

OAFAuthConfiguration *authConf = [OAFAuthConfiguration new];
authConf.authorizeURL = @"AUTHORIZATION_URL"; // e.g.: https://api.imgur.com/oauth2/authorize
authConf.requestTokenURL = "TOKEN_URL"; // e.g.: https://api.imgur.com/oauth2/token
authConf.consumerKey = @"YOUR_CONSUMER_KEY";
authConf.consumerSecret = @"YOUR_CONSUMER_SECRET";
authConf.callbackURL = @"CALLBACK_USED_AT_APPLICATION_REGISTRATION";
```

**Swift**

```swift
import OAuth2Flow 

// some code ...

let authConf: OAFAuthConfiguration
authConf.authorizeURL = "AUTHORIZATION_URL" // e.g.: https://api.imgur.com/oauth2/authorize
authConf.requestTokenURL = "TOKEN_URL" // e.g.: https://api.imgur.com/oauth2/token
authConf.consumerKey = "YOUR_CONSUMER_KEY"
authConf.consumerSecret = "YOUR_CONSUMER_SECRET"
authConf.callbackURL = "CALLBACK_USED_AT_APPLICATION_REGISTRATION"
```

Initialize and show on screen the view controller (note that the view controller's initializer can return nil).

**Objective-C**

```objective-c
OAFViewController *authVC = [[OAFViewController alloc] initWithConfiguration: authConf];
if (authVC) {
	authVC.delegate = self
	
	// present the view controller in the way that it makes sense in your application
}
```

**Swift**

```swift
if let authVC: OAFViewController = OAFViewController(configuration: authConf) {
	authVC.delegate = self
	
	// present the view controller in the way that it makes sense in your application
}
```

Through OAFViewController's delegation you will receive an instance of OAFAuthHandler. This handler is refreshing automatically the token when expires. Moreover you're able to do authorized requests.

**Objective-C**

```objective-c
authConf.baseURL = "https://api.imgur.com" // baseURL is required at configuration


// some code ...

OAFURLRequest *request = [authHandler requestWithRelativeURL:@"some/relative/URL"]; // e.g. viral photos from imgur: @"3/gallery/hot/viral/0.json"

[request startWithJSONBlockReponse:^(id _Nullable response, NSError * _Nullable error) {
	// cast json to NSDictionary or NSArray as needed
	// use the data sent by server
}];
```

**Swift**

```swift
authConf.baseURL = "https://api.imgur.com" // baseURL is required at configuration

// some code ...

let request = self.authHandler?.requestWithRelativeURL("some/relative/URL") // e.g. viral photos from imgur: "3/gallery/hot/viral/0.json" 

request?.startWithJSONBlockReponse({ (json: AnyObject?, error: NSError?) -> Void in
	// cast json to Dictionary or Array as needed
	// use the data sent by server
})
```

## License

OAuth2Flow is released under MIT license. See [LICENSE](LICENSE) for details.  
OAuth logo is under [Creative Commons Attribution ShareAlike 3.0 license](http://creativecommons.org/licenses/by-sa/3.0/)

## About this project

![3Pillar Global] (http://www.3pillarglobal.com/wp-content/themes/base/library/images/logo_3pg.png)

**OAuth2Flow** is developed and maintained by [3Pillar Global](http://www.3pillarglobal.com/).
