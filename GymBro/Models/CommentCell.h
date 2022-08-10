//
//  CommentCell.h
//  GymBro
//
//  Created by Eric Moran on 7/20/22.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *postTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (strong, nonatomic) IBOutlet UIImageView *authorProfilePicView;
@property (nonatomic) BOOL hasBeenLiked;
@property (nonatomic) int likedCommentsIndex;
@property (strong, nonatomic) Comment *comment;

- (void)setComment;

@end

NS_ASSUME_NONNULL_END
