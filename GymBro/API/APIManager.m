//
//  APIManager.m
//  GymBro
//
//  Created by Eric Moran on 7/12/22.
//

#import "APIManager.h"
#import <Parse/Parse.h>
#import "../Models/GymPointAnnotation.h"
#import "../Models/GymDetailsButton.h"
@implementation APIManager


// GENERAL

+ (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

// LOGIN
+ (void)signupUserWithController:(UIViewController *)controller withEmail:(NSString *)email withUsername:(NSString *)username withPassword:(NSString *)password
{
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = username;
    newUser.email = email;
    newUser.password = password;
    newUser[@"level"] = @"Novice";
    newUser[@"gender"] = @"Male";
    newUser[@"workoutSplit"] = @"Whole Body Split";
    newUser[@"workoutTime"] = @"Morning (6am - 12pm)";
    newUser[@"friends"] = @[];
    newUser[@"pendingFriends"] = @[];
    newUser[@"friendRequests"] = @[];
    newUser[@"rejectedUsers"] = @[];
    newUser[@"likedPosts"] = @[];
    newUser[@"genderFilter"] = @0;
    newUser[@"distanceFilter"] = @62;
    newUser[@"bio"] = @"";
    newUser[@"priorityArray"] = @[@5,@3,@1];
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            controller.view.window.rootViewController = tabBarController;
            
            UITabBar *tabBar=tabBarController.tabBar;
            UITabBarItem *tabBarItem1=[[tabBar items] objectAtIndex:0];
            UIImage *homeIcon = [UIImage imageNamed:@"gym.png"];
            homeIcon = [homeIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            homeIcon = [APIManager resizeImage:homeIcon withSize:CGSizeMake(45, 45)];
            [tabBarItem1 setImage:homeIcon];
            [tabBarItem1 setTitle:@""];
            
            UITabBarItem *tabBarItem2=[[tabBar items] objectAtIndex:1];
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
    }];
}

+ (void)loginUserWithController:(UIViewController *)controller withUsername:(NSString *)username withPassword:(NSString *)password
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login Failed"
                                                                           message:@"Please Check The Information You Entered"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                 {}];
            [alert addAction:ok];
            [controller presentViewController:alert animated:YES completion:nil];
        } else {
            NSLog(@"User logged in successfully");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            controller.view.window.rootViewController = tabBarController;
            
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
        }
    }];
}

// HOME
+ (NSMutableArray *)fetchPostswithTableView:(UITableView *)tableView andRefresh:(UIRefreshControl *)refreshControl
{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    query.limit = 200;

    return [query findObjects];
}

// MATCHING
+ (NSMutableArray *)fetchUsersWithQuery:(PFUser *)currUser withPriorityArray:(NSArray *)priorityArray withGenderFilter:(int)genderFilter
{
    NSArray *rejectedUsers = currUser[@"rejectedUsers"];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" notEqualTo:currUser[@"username"]];
    [query whereKeyExists:@"level"];
    [query whereKeyExists:@"gym"];
    [query whereKeyExists:@"profileImages"];
    [query whereKey:@"bio" notEqualTo:@""];
    if (rejectedUsers.count > 0)
    {
        [query whereKey:@"username" notContainedIn:rejectedUsers];
    }
    switch ([currUser[@"genderFilter"] intValue])
    {
        case 0:
            break;
        case 1:
            [query whereKey:@"gender" equalTo:@"Male"];
            break;
        case 2:
            [query whereKey:@"gender" equalTo:@"Female"];
    }
    [query orderByDescending:@"createdAt"];
    query.limit = 100;
    
    __block NSMutableArray *result = [[NSMutableArray alloc] init];
    __block NSMutableArray *compatibilityArray = [[NSMutableArray alloc] init];
    __block NSMutableArray *userArray = [[NSMutableArray alloc] init];
    
    NSArray *userObjects = [query findObjects];
    NSMutableArray * users = [[NSMutableArray alloc] init];
    for (PFUser *user in userObjects)
    {
        if (([self getDistance:currUser from:user] * 0.00062317) <= [currUser[@"distanceFilter"] intValue])
        {
            [users addObject:user];
        }
    }
    result = [self setScores:currUser ofArray:users withPriorityArray:priorityArray];
    compatibilityArray = result[1];
    userArray = result[0];
    userArray = [self compatibilitySort:userArray withCompatibilityArray:compatibilityArray];
    return userArray;
}

+ (long)getDistance:(PFUser *)currUser from:(PFUser *)userOne
{
    double latitude = [[currUser[@"gym"] valueForKeyPath:@"geocodes.main.latitude"] doubleValue];
    double longitude = [[currUser[@"gym"] valueForKeyPath:@"geocodes.main.longitude"] doubleValue];
    CLLocation *userLoc = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    double latitudeOne = [[userOne[@"gym"] valueForKeyPath:@"geocodes.main.latitude"] doubleValue];
    double longitudeOne = [[userOne[@"gym"] valueForKeyPath:@"geocodes.main.longitude"] doubleValue];
    CLLocation *userOneLoc = [[CLLocation alloc] initWithLatitude:latitudeOne longitude:longitudeOne];
    
    return [userLoc distanceFromLocation:userOneLoc];
}


+ (NSMutableArray *)setScores:(PFUser *)currUser ofArray:(NSArray *)users withPriorityArray:(NSArray *)arr
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *friends = currUser[@"friends"];
    NSArray *pendingFriends = currUser[@"pendingFriends"];
    __block BOOL isValid;
    __block BOOL isValidPendingFriend;
    NSMutableArray *compatibilityArray = [[NSMutableArray alloc] init];
    NSMutableArray *userArray = [[NSMutableArray alloc] init];
    NSString *currSplit = currUser[@"workoutSplit"];
    NSString *currTime = currUser[@"workoutTime"];
    NSString *currLevel = currUser[@"level"];
    for (PFUser *user in users)
    {
        isValid = YES;
        isValidPendingFriend = YES;
        for (NSString *friend in friends)
        {
            if ([user[@"username"] isEqual:friend])
            {
                isValid = NO;
            }
        }
        for (NSString *pendingFriend in pendingFriends)
        {
            if ([user[@"username"] isEqual:pendingFriend])
            {
                isValid = NO;
            }
        }
        if (isValid)
        {
            NSInteger score = 0;
            if ([[user valueForKeyPath:@"workoutSplit"] isEqual:currSplit])
            {
                score += [arr[0] integerValue];;
            }
            
            if ([[user valueForKeyPath:@"workoutTime"] isEqual:currTime])
            {
                score += [arr[1] integerValue];
            }
            if ([[user valueForKeyPath:@"level"] isEqual:currLevel])
            {
                score += [arr[2] integerValue];
            }
            float distance = [self getDistance:currUser from:user] * 0.00062317;
            
            // Don't let user customize these values, have them filter distance as a whole
            if (distance <= 1)
            {
                score += 5;
            }
            else if (distance <= 5)
            {
                score += 3;
            }
            else if (distance <= 10)
            {
                score += 1;
            }
            [userArray addObject:user];
            [compatibilityArray addObject:@(score)];
        }
    }
    // Make dictionary of these arrays and sort the dictionary
    [result addObject:userArray];
    [result addObject:compatibilityArray];
    return result;
}

+ (NSMutableArray *)compatibilitySort:(NSMutableArray *)userArray withCompatibilityArray:(NSMutableArray *)compatibilityArray
{
    NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
    int i = 0;
    for (int x = 0; x < userArray.count; x++)
    {
        PFUser *user = userArray[x];
        NSInteger currUser = [compatibilityArray[x] integerValue];
        for (i = 0; i < sortedArray.count; i++)
        {
            long y = [userArray indexOfObject:sortedArray[i]];
            NSInteger sortedUser = [compatibilityArray[y] integerValue];
            if (currUser > sortedUser)
            {
                [sortedArray insertObject:user atIndex:i];
                break;
            }
        }
        if (i == sortedArray.count)
        {
            [sortedArray addObject:user];
        }
    }
    userArray = sortedArray;
    return userArray;
}

// PROFILE

+ (long)fetchPostCountOfUser:(PFUser *)user
{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"author" equalTo:user[@"username"]];
    query.limit = 200;
    NSArray *posts = [query findObjects];
    return posts.count;
}


+ (NSMutableArray *)fetchLocationsWithLat:lat Lon:lon Map:(MKMapView *)mapView
{
    __block NSMutableArray *result = [[NSMutableArray alloc] init];
    __block NSMutableArray *gyms = [[NSMutableArray alloc] init];
    NSDictionary *headers = @{ @"Accept": @"application/json",
                               @"Authorization": @"fsq34hUP8/Fm3u/fGWnAv/jMBKdyEQIlaf+ueJvtD52Wn8o=" };
    NSString *queryString = [NSString stringWithFormat:@"https://api.foursquare.com/v3/places/search?&ll=%@,%@&radius=50000&categories=18021", lat, lon];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            gyms = [[NSMutableArray alloc] init];
            for (NSDictionary *gym in [responseDictionary valueForKeyPath:@"results"])
            {
                [gyms addObject:gym];
                GymPointAnnotation *annotation = [[GymPointAnnotation alloc] init];
                double latitude = [[gym valueForKeyPath:@"geocodes.main.latitude"] doubleValue];
                double longitude = [[gym valueForKeyPath:@"geocodes.main.longitude"] doubleValue];
                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                annotation.title = [gym valueForKeyPath:@"name"];
                annotation.gym = gym;
                
                [mapView addAnnotation:annotation];
            }
            [result addObject:gyms];
        }
    }];
    [dataTask resume];
    return gyms;
}

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}



@end
