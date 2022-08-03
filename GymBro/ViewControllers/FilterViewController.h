//
//  FilterViewController.h
//  GymBro
//
//  Created by Eric Moran on 7/28/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FilterViewControllerDelegate

- (void)setFiltersWithArray:(NSArray *)arr andGenderFilter:(NSInteger) gender;

@end

@interface FilterViewController : UIViewController

@property int workoutType;
@property int workoutTime;
@property int level;
@property int distance;
@property int gender;
@property (strong, nonatomic) id<FilterViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
