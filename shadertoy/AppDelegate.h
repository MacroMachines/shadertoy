//
//  AppDelegate.h
//  shadertoy
//
//  Created by open kava on 12-12-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIService.h"


@class ViewController;
@class HomeViewController;
@class OpenGLView;

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)



@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) UINavigationController *navigationController ;

@property (strong, nonatomic)   ViewController *viewController;
@property (strong ,nonatomic)   HomeViewController *homeViewController;


@property (strong, nonatomic) APIService *netDataPost ;
@property (strong ,nonatomic) NSDate *lastCheckUpdateDT;


@end
