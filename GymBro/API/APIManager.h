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

+ (NSMutableArray *)fetchPostswithTableView:(UITableView *)tableView andRefresh:(UIRefreshControl *)refreshControl;
+ (NSMutableArray *)fetchUsersWithQuery:(PFUser *)currUser;
+ (long)getDistance:(PFUser *)currUser from:(PFUser *)userOne;
+ (NSMutableArray *)fetchPhotosWithQuery:gym;
+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;
+ (NSMutableArray *)fetchLocationsWithLat:lat Lon:lon Map:(MKMapView *)mapView;

@end

NS_ASSUME_NONNULL_END
