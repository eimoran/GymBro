//
//  UserCell.h
//  GymBro
//
//  Created by Eric Moran on 7/12/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "GymDetailsButton.h"
#import <SWTableViewCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserCell : SWTableViewCell

@property (strong, nonatomic) UIViewController *controller;
@property (strong, nonatomic) PFUser *user;
@property (nonatomic) double distanceFromUser;
@property (nonatomic) int currPhotoIndex;
- (void) setData;

@end

NS_ASSUME_NONNULL_END
