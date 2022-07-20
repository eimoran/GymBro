//
//  PostDetailsViewController.h
//  GymBro
//
//  Created by Eric Moran on 7/20/22.
//

#import <UIKit/UIKit.h>
#import "../Models/Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostDetailsViewController : UIViewController

@property (strong, nonatomic) Post *post;

@end

NS_ASSUME_NONNULL_END
