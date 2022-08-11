//
//  MainTabBarController.m
//  GymBro
//
//  Created by Eric Moran on 8/11/22.
//

#import "MainTabBarController.h"
#import "../API/APIManager.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    UITabBar *tabBar = self.tabBar;
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
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
