//
//  AppDelegate.m
//  shadertoy
//
//  Created by open kava on 12-12-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "SimpleOpenGLView.h"


@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

#undef DEBUG_ME
    
//#define DEBUG_ME
    
#ifdef DEBUG_ME
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    SimpleOpenGLView *v = [[SimpleOpenGLView alloc] initWithFrame:screenBounds] ;
     //self.window.rootViewController =v;
     [self.window addSubview:v];
    [self.window makeKeyAndVisible];

#else 
    
   //主界面
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.homeViewController = [[HomeViewController alloc] init];
    } else {
        self.homeViewController = [[HomeViewController alloc] init];
    }
    self.window.rootViewController = self.homeViewController;
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController] ;
   self.navigationController.toolbarHidden = YES;
    self.navigationController.navigationBarHidden = YES;

    if ([self.window respondsToSelector:@selector(setRootViewController:)]) {
        self.window.rootViewController = self.navigationController;
    } else {
        [self.window addSubview:self.navigationController.view];
    }
    
    [self.window makeKeyAndVisible];
    
    [self.netDataPost useCache];
    self.netDataPost = [[APIService alloc] initWithHostName:GLSL_WWW_ROOT customHeaderFields:nil];

#endif

    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
