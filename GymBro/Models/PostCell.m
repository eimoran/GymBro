//
//  PostCell.m
//  GymBro
//
//  Created by Eric Moran on 7/19/22.
//

#import "PostCell.h"
#import "Post.h"
#import "UIImageView+AFNetworking.h"
#import <Parse/Parse.h>
#import "../API/APIManager.h"

@interface PostCell ()

@end

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setPost {
    [self.post fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:self.post[@"author"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count > 0)
            {
                PFUser *author = objects[0];
                if (author[@"profilePic"])
                {
                    self.authorProfilePicView.layer.cornerRadius = self.authorProfilePicView.frame.size.height/2.0;
                    PFFileObject *profilePicObj = author[@"profilePic"];
                    NSURL *url = [NSURL URLWithString:profilePicObj.url];
                    [self.authorProfilePicView setImageWithURL:url];
                }
                else
                {
                    self.authorProfilePicView.image = [UIImage imageNamed:@"profile-Icon.png"];
                }
            }
        }];
        PFUser *user = [PFUser currentUser];
        self.postTextLabel.text = [NSString stringWithFormat:@"%@ %@", self.post.author, self.post.text];
        NSMutableAttributedString *postText = [[NSMutableAttributedString alloc] initWithString:self.postTextLabel.text];
        NSRange boldRange = [self.postTextLabel.text rangeOfString:self.post.author];
        [postText addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:boldRange];
        [self.postTextLabel setAttributedText: postText];
        
        [self setTimestamp:self.timestampLabel ofPost:self.post];
        
        
        self.likeCountLabel.text = [self.post[@"likeCount"] stringValue];
        
        NSArray *comments = self.post[@"comments"];
        self.commentCountLabel.text = [[NSNumber numberWithLong:comments.count] stringValue];;
        
        UIImage *favoriteIcon;
        self.hasBeenLiked = NO;
        NSArray *likedPosts = user[@"likedPosts"];
        for (int x = 0; x < likedPosts.count; x++)
        {
            Post *post = likedPosts[x];
            if ([post.objectId isEqual:self.post.objectId])
            {
                self.likedPostsIndex = x;
                self.hasBeenLiked = YES;
            }
        }
        if (self.hasBeenLiked)
        {
            favoriteIcon = [UIImage imageNamed:@"liked.png"];
        }
        else{
            favoriteIcon = [UIImage imageNamed:@"like.png"];
        }
        favoriteIcon = [APIManager resizeImage:favoriteIcon withSize:CGSizeMake(30, 30)];
        [self.likeButton setImage:favoriteIcon forState:UIControlStateNormal];
        
        UIImage *commentIcon = [UIImage imageNamed:@"comment.png"];
        commentIcon = [APIManager resizeImage:commentIcon withSize:CGSizeMake(30, 30)];
        [self.commentButton setImage:commentIcon forState:UIControlStateNormal];
    }];
}

- (void)setPostImage
{
    self.postTextLabel.hidden = true;
    self.timestampLabel.hidden = true;
    
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.post.image.url]];
    self.postImageView.image = [UIImage imageWithData:imageData];
}

- (void)setTimestamp:(UILabel *)label ofPost:(Post *)post{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    NSDate *date = post.createdAt;
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
    label.text = [NSString stringWithFormat:@"%@ ago", elapsed];
    label.textColor = [UIColor lightGrayColor];
}

- (IBAction)like:(id)sender {
    PFUser *user = [PFUser currentUser];
    NSMutableArray *likedPosts = [[NSMutableArray alloc] initWithArray:user[@"likedPosts"]];
    if (self.hasBeenLiked) {
        self.hasBeenLiked = NO;
        self.post.likeCount = [NSNumber numberWithInt:[self.post.likeCount intValue] - 1];
        [likedPosts removeObjectAtIndex:self.likedPostsIndex];
    }
    else {
        self.hasBeenLiked = YES;
        self.post.likeCount = [NSNumber numberWithInt:[self.post.likeCount intValue] + 1];
        [likedPosts addObject:self.post];
    }
    user[@"likedPosts"] = likedPosts;
    [self setPost];
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSLog(@"SAVED USER");
        }
    }];
    
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error)
        {
            NSLog(@"SAVED POST");
        }
    }];
}

- (IBAction)comment:(id)sender {
    [self.homeVC performSegueWithIdentifier:@"postDetails" sender:nil];
}


@end
