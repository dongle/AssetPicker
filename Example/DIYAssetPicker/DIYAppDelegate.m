//
//  DIYAppDelegate.m
//  DIYAssetPicker
//
//  Created by Jonathan Beilin on 7/30/12.
//  Copyright (c) 2012 Jonathan Beilin. All rights reserved.
//

#import "DIYAppDelegate.h"

@implementation DIYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _viewController = [[DIYViewController alloc] init];
    
    self.window.rootViewController = self.viewController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
