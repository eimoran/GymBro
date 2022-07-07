//
//  ProfileFormViewController.h
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ProfileFormViewControllerDelegate

- (void)updateProfile:(NSString *)split :(NSString *)time :(NSString *)gender;

@end

@interface ProfileFormViewController : UIViewController

@property (nonatomic, weak) id <ProfileFormViewControllerDelegate> delegate;
@property (weak, nonatomic) NSString *split;
@property (weak, nonatomic) NSString *time;
@property (weak, nonatomic) NSString *gender;
@property (weak, nonatomic) NSString *gym;

@end

NS_ASSUME_NONNULL_END
