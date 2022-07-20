//
//  APIManager.m
//  GymBro
//
//  Created by Eric Moran on 7/12/22.
//

#import "APIManager.h"
#import <Parse/Parse.h>

@implementation APIManager

+ (NSMutableArray *)fetchUsersWithQuery:gym
{
    __block NSMutableArray *userArray = nil;
    userArray = [[NSMutableArray alloc] init];
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" notEqualTo:user[@"username"]];
    [query whereKey:@"gymID" equalTo:user[@"gymID"]];
    [query whereKey:@"gymID" equalTo:[gym valueForKeyPath:@"fsq_id"]];
//    [query where]
    query.limit = 100;
    [query orderByDescending:@"createdAt"];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            userArray = users;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    return userArray;
}

+ (NSMutableArray *)fetchPhotosWithQuery:gym
{
    NSMutableArray *gymPhotos = [[NSMutableArray alloc] init];
    NSString *fsq_id = [gym valueForKeyPath:@"fsq_id"];
    NSDictionary *headers = @{ @"Accept": @"application/json",
                               @"Authorization": @"fsq34hUP8/Fm3u/fGWnAv/jMBKdyEQIlaf+ueJvtD52Wn8o=" };
    NSString *requestString = [NSString stringWithFormat:@"https://api.foursquare.com/v3/places/%@/photos?limit=20", fsq_id];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
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
            NSDictionary *photos = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for (NSDictionary *photo in photos)
            {
                NSString *prefix = [photo valueForKeyPath:@"prefix"];
                NSString *suffix = [photo valueForKeyPath:@"suffix"];
                [gymPhotos addObject:[NSString stringWithFormat:@"%@original%@", prefix, suffix]];
            }
        }
    }];
    [dataTask resume];
    return gymPhotos;
}

@end
