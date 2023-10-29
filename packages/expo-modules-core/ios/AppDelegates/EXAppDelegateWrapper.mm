// Copyright 2018-present 650 Industries. All rights reserved.

#import <ExpoModulesCore/EXAppDelegateWrapper.h>
#import <ExpoModulesCore/EXReactDelegateWrapper+Private.h>
#import <ExpoModulesCore/Swift.h>


@interface EXAppDelegateWrapper()

@property (nonatomic, strong) EXReactDelegateWrapper *reactDelegate;

@end

@implementation EXAppDelegateWrapper {
  EXExpoAppDelegate *_expoAppDelegate;
}

// Synthesize window, so the AppDelegate can synthesize it too.
@synthesize window = _window;

- (instancetype)init
{
  if (self = [super init]) {
    _expoAppDelegate = [[EXExpoAppDelegate alloc] init];
    _reactDelegate = [[EXReactDelegateWrapper alloc] initWithExpoReactDelegate:_expoAppDelegate.reactDelegate];
  }
  return self;
}

// This needs to be implemented, otherwise forwarding won't be called.
// When the app starts, `UIApplication` uses it to check beforehand
// which `UIApplicationDelegate` selectors are implemented.
- (BOOL)respondsToSelector:(SEL)selector
{
  return [super respondsToSelector:selector]
    || [_expoAppDelegate respondsToSelector:selector];
}

// Forwards all invocations to `ExpoAppDelegate` object.
- (id)forwardingTargetForSelector:(SEL)selector
{
  return _expoAppDelegate;
}

#if __has_include(<React-RCTAppDelegate/RCTAppDelegate.h>) || __has_include(<React_RCTAppDelegate/RCTAppDelegate.h>)

- (UIView *)findRootView:(UIApplication *)application
{
#if TARGET_OS_OSX
  return [[[[NSApplication sharedApplication] keyWindow] contentViewController] view];
#else
  UIWindow *mainWindow = application.delegate.window;
  if (mainWindow == nil) {
    return nil;
  }
  UIViewController *rootViewController = mainWindow.rootViewController;
  if (rootViewController == nil) {
    return nil;
  }
  UIView *rootView = rootViewController.view;
  return rootView;
#endif
}

#if !TARGET_OS_OSX
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [super application:application didFinishLaunchingWithOptions:launchOptions];
  [_expoAppDelegate application:application didFinishLaunchingWithOptions:launchOptions];
  return YES;
}
#endif // !TARGET_OS_OSX

- (RCTBridge *)createBridgeWithDelegate:(id<RCTBridgeDelegate>)delegate launchOptions:(NSDictionary *)launchOptions
{
  return [self.reactDelegate createBridgeWithDelegate:delegate launchOptions:launchOptions];
}

- (UIView *)createRootViewWithBridge:(RCTBridge *)bridge
                          moduleName:(NSString *)moduleName
                           initProps:(NSDictionary *)initProps
{
  BOOL enableFabric = NO;
#if RN_FABRIC_ENABLED
  enableFabric = self.fabricEnabled;
#endif

  return [self.reactDelegate createRootViewWithBridge:bridge
                                         moduleName:moduleName
                                    initialProperties:initProps
                                        fabricEnabled:enableFabric];
}

- (UIViewController *)createRootViewController
{
  return [self.reactDelegate createRootViewController];
}
#endif // __has_include(<React-RCTAppDelegate/RCTAppDelegate.h>)

@end
