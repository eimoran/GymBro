//
//  SceneDelegate.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "SceneDelegate.h"
#import <Parse/Parse.h>
#import "API/APIManager.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

        configuration.applicationId = @"sdhQay3CsZ8mOLs5iIuvrSHkPtabXqHesQ7diKqY";
        configuration.clientKey = @"TCRiRrtUWmmtI1khFzvJdmRinX1N2tg7kaYrV304";
        configuration.server = @"https://parseapi.back4app.com";
    }];

    [Parse initializeWithConfiguration:config];
    
    if ([PFUser currentUser]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        
        UITabBar *tabBar = tabBarController.tabBar;
        UITabBarItem *tabBarItem1 = [[tabBar items] objectAtIndex:0];
        UIImage *homeIcon = [UIImage imageNamed:@"gym.png"];
        homeIcon = [homeIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        homeIcon = [APIManager resizeImage:homeIcon withSize:CGSizeMake(45, 45)];
        [tabBarItem1 setImage:homeIcon];
        [tabBarItem1 setTitle:@""];
        
        UITabBarItem *tabBarItem2 = [[tabBar items] objectAtIndex:1];
        UIImage *matchingIcon = [UIImage imageNamed:@"matching.png"];
        matchingIcon = [matchingIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        matchingIcon = [APIManager resizeImage:matchingIcon withSize:CGSizeMake(45, 45)];
        [tabBarItem2 setImage:matchingIcon];
        [tabBarItem2 setTitle:@""];
        
        UITabBarItem *tabBarItem3 = [[tabBar items] objectAtIndex:2];
        UIImage *profileIcon = [UIImage imageNamed:@"profile.png"];
        profileIcon = [profileIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        profileIcon = [APIManager resizeImage:profileIcon withSize:CGSizeMake(45, 45)];
        [tabBarItem3 setImage:profileIcon];
        [tabBarItem3 setTitle:@""];
        
        self.window.rootViewController = tabBarController;
    }
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
