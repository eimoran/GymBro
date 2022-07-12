//
//  UserCell.h
//  GymBro
//
//  Created by Eric Moran on 7/12/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *user;
- (void) setData;

@end

NS_ASSUME_NONNULL_END
