//
//  CommentCell.m
//  GymBro
//
//  Created by Eric Moran on 7/20/22.
//

#import "CommentCell.h"
#import "../API/APIManager.h"

@interface CommentCell ()

- (IBAction)like:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *likeCommentButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;

@end

@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setComment {
    PFUser *currUser = [PFUser currentUser];
    [self.comment fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSString *text = [NSString stringWithFormat:@"%@ %@", self.comment.author, self.comment.text];
        NSMutableAttributedString *postText = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange boldRange = [text rangeOfString:self.comment.author];
        [postText addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:boldRange];
        [self.postTextLabel setAttributedText: postText];
        
        [self setTimestamp];
        self.likeCount.text = [self.comment[@"likeCount"] stringValue];
        self.hasBeenLiked = NO;
        NSArray *likedComments = [[NSMutableArray alloc] initWithArray:currUser[@"likedComments"]];
        for (int i = 0; i < likedComments.count; i++)
        {
            Comment *comment = likedComments[i];
            if ([self.comment.objectId isEqual:comment.objectId])
            {
                self.hasBeenLiked = YES;
                self.likedCommentsIndex = i;
            }
        }
        
        UIImage *likeCommentIcon = [[UIImage alloc] init];
        if (self.hasBeenLiked)
        {
            likeCommentIcon = [UIImage imageNamed:@"liked.png"];
        }
        else
        {
            likeCommentIcon = [UIImage imageNamed:@"like.png"];
        }
        likeCommentIcon = [APIManager resizeImage:likeCommentIcon withSize:CGSizeMake(30, 30)];
        [self.likeCommentButton setTitle:@"" forState:UIControlStateNormal];
        [self.likeCommentButton setImage:likeCommentIcon forState:UIControlStateNormal];
    }];
}

- (void)setTimestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    NSDate *date = self.comment.createdAt;
    // Configure output format
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;

    NSDate *curDate = [NSDate date];
    NSTimeInterval diff = [curDate timeIntervalSinceDate:date];

    NSInteger interval = diff;
    long minutes = (interval / 60) % 60;
    long hours = (interval / 3600);
    long days = hours / 24;
    NSDateComponentsFormatter *formatter2 = [[NSDateComponentsFormatter alloc] init];
        formatter2.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
        
    if (days >= 365)
    {
        formatter2.allowedUnits = NSCalendarUnitYear;
    }
    else if (days >= 31)
    {
        formatter2.allowedUnits = NSCalendarUnitMonth;
    }
    else if (hours >= 24)
    {
        formatter2.allowedUnits = NSCalendarUnitDay;
    }
    else if(hours >= 1) {
        formatter2.allowedUnits = NSCalendarUnitHour;
        
    }
    else if(minutes >= 1) {
        formatter2.allowedUnits = NSCalendarUnitMinute;
    }
    else {
        formatter2.allowedUnits = NSCalendarUnitSecond;
    }
    NSString *elapsed = [formatter2 stringFromDate:date toDate:[NSDate date]];
    self.timestampLabel.text = [NSString stringWithFormat:@"%@ ago", elapsed];
    self.timestampLabel.textColor = [UIColor lightGrayColor];
}

- (IBAction)like:(id)sender {
    NSInteger likes = [self.comment[@"likeCount"] integerValue];
    PFUser *user = [PFUser currentUser];
    NSMutableArray *likedComments = [[NSMutableArray alloc] initWithArray:user[@"likedComments"]];
    if (self.hasBeenLiked) {
        self.hasBeenLiked = NO;
        likes = [self.comment[@"likeCount"] intValue] - 1;
        [likedComments removeObjectAtIndex:self.likedCommentsIndex];
    }
    else {
        self.hasBeenLiked = YES;
        likes = [self.comment[@"likeCount"] intValue] + 1;
        [likedComments addObject:self.comment];
    }
    self.comment[@"likeCount"] = @(likes);
    user[@"likedComments"] = likedComments;
    [self setComment];
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSLog(@"SAVED USER");
        }
    }];
    
    [self.comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error)
        {
            NSLog(@"SAVED COMMENT");
        }
    }];
}
@end
