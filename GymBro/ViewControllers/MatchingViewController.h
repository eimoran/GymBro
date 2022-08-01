//
//  MatchingViewController.h
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MatchingViewController : UIViewController

- (void)setFiltersWithArray:(NSArray *)arr andGenderFilter:(NSInteger) gender;

@end

NS_ASSUME_NONNULL_END
