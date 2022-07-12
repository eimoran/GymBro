//
//  GymDetailsViewController.h
//  GymBro
//
//  Created by Eric Moran on 7/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GymDetailsViewControllerDelegate

- (void)displayInfo;

@end

@interface GymDetailsViewController : UIViewController

@property (weak, nonatomic) id<GymDetailsViewControllerDelegate> delegate;
@property (weak, nonatomic) NSDictionary *gym;

@end

NS_ASSUME_NONNULL_END
