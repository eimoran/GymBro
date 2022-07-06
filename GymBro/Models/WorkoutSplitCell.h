//
//  WorkoutSplitCell.h
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import <UIKit/UIKit.h>
#import "../ViewControllers/ProfileFormViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutSplitCell : UITableViewCell

@property (weak, nonatomic) ProfileFormViewController *controller;

@end

NS_ASSUME_NONNULL_END
