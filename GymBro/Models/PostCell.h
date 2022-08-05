//
//  PostCell.h
//  GymBro
//
//  Created by Eric Moran on 7/19/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Post.h"
#import "../ViewControllers/HomeViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UIImageView *authorProfilePicView;
@property (strong, nonatomic) IBOutlet UILabel *postTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (strong, nonatomic) Post *post;
@property (nonatomic) BOOL hasBeenLiked;
@property (nonatomic) int likedPostsIndex;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
- (IBAction)like:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
- (IBAction)comment:(id)sender;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) HomeViewController *homeVC;

- (void)setPost;
- (void)setPostImage;

@end

NS_ASSUME_NONNULL_END
