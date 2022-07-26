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
+ (NSMutableArray *)fetchUsersWithQuery:(PFUser *)currUser
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" notEqualTo:currUser[@"username"]];
    [query whereKeyExists:@"level"];
    [query whereKeyExists:@"gym"];
    [query orderByDescending:@"createdAt"];
    query.limit = 100;
    
    __block NSMutableArray *result = [[NSMutableArray alloc] init];
    __block NSMutableArray *compatibilityArray = [[NSMutableArray alloc] init];
    __block NSMutableArray *userArray = [[NSMutableArray alloc] init];
    
    NSArray *users = [query findObjects];
    result = [self setScores:currUser ofArray:users];
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


+ (NSMutableArray *)setScores:(PFUser *)currUser ofArray:(NSArray *)users
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
                score += 3;
            }
            
            if ([[user valueForKeyPath:@"workoutTime"] isEqual:currTime])
            {
                score += 2;
            }
            if ([[user valueForKeyPath:@"level"] isEqual:currLevel])
            {
                score += 1;
            }
            long distance = [self getDistance:currUser from:user]*0.00062317;
            
            if (distance <= 1)
            {
                score += 4;
            }
            else if (distance <= 5)
            {
                score += 3;
            }
            else if (distance <= 10)
            {
                score += 2;
            }
            else
            {
                score += 1;
            }
            [userArray addObject:user];
            [compatibilityArray addObject:@(score)];
        }
    }
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
        for (i = 0; i < sortedArray.count; i++)
        {
            long y = [userArray indexOfObject:sortedArray[i]];
            if (compatibilityArray[x] > compatibilityArray[y])
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

+(NSMutableArray *)fetchLocationsWithLat:lat Lon:lon Map:(MKMapView *)mapView
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
