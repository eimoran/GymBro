//
//  ProfileFormCell.h
//  GymBro
//
//  Created by Eric Moran on 8/5/22.
//

#import <UIKit/UIKit.h>
#import "../ViewControllers/ProfileFormViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileFormCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (strong, nonatomic) ProfileFormViewController *controller;
@property int traitValue;
- (void)setTraits;

@end

NS_ASSUME_NONNULL_END
