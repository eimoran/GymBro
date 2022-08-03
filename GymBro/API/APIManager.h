//
//  APIManager.h
//  GymBro
//
//  Created by Eric Moran on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import <Parse/Parse.h>
#import "MapKit/MapKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

// LOGIN
+ (void)signupUserWithController:(UIViewController *)controller withEmail:(NSString *)email withUsername:(NSString *)username withPassword:(NSString *)password;
+ (void)loginUserWithController:(UIViewController *)controller withUsername:(NSString *)username withPassword:(NSString *)password;

// HOME
+ (NSMutableArray *)fetchPostswithTableView:(UITableView *)tableView andRefresh:(UIRefreshControl *)refreshControl;

// MATCHING
+ (NSMutableArray *)fetchUsersWithQuery:(PFUser *)currUser withPriorityArray:(NSArray *)priorityArray withGenderFilter:(int)genderFilter;
+ (long)getDistance:(PFUser *)currUser from:(PFUser *)userOne;
+ (NSMutableArray *)fetchPhotosWithQuery:gym;
+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;

// PROFILE
+ (NSMutableArray *)fetchLocationsWithLat:lat Lon:lon Map:(MKMapView *)mapView;
+ (NSMutableArray *)setScores:(PFUser *)currUser ofArray:(NSArray *)users withPriorityArray:(NSArray *)arr;
+ (NSMutableArray *)compatibilitySort:(NSMutableArray *)userArray withCompatibilityArray:(NSMutableArray *)compatibilityArray;

@end

NS_ASSUME_NONNULL_END
