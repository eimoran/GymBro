//
//  PostCell.m
//  GymBro
//
//  Created by Eric Moran on 7/19/22.
//

#import "PostCell.h"
#import <Parse/Parse.h>

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
    if (self.post.photoExists)
    {
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.post.image.url]];
        UIImageView *postImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
        [postImageView setFrame:CGRectMake(50, 0, 300, 300)];
        [self addSubview:postImageView];
        
        UILabel *postTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 310, self.frame.size.width - 40, 50)];
        postTextLabel.text =[NSString stringWithFormat:@"%@ %@", self.post.author, self.post.text];
        NSMutableAttributedString *postText = [[NSMutableAttributedString alloc] initWithString:postTextLabel.text];
        NSRange boldRange = [postTextLabel.text rangeOfString:self.post.author];
        [postText addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:boldRange];
        [postTextLabel setAttributedText: postText];
        [self addSubview:postTextLabel];
        
        UILabel *timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 370, self.frame.size.width - 40, 20)];
        [self setTimestamp:timestampLabel ofPost:self.post];
        [self addSubview:timestampLabel];
    }
    else
    {
        UILabel *postTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width - 40, 50)];
        postTextLabel.text =[NSString stringWithFormat:@"%@ %@", self.post.author, self.post.text];
        NSMutableAttributedString *postText = [[NSMutableAttributedString alloc] initWithString:postTextLabel.text];
        NSRange boldRange = [postTextLabel.text rangeOfString:self.post.author];
        [postText addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:boldRange];
        [postTextLabel setAttributedText: postText];
        [self addSubview:postTextLabel];
        
        UILabel *timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, self.frame.size.width - 40, 20)];
        [self setTimestamp:timestampLabel ofPost:self.post];
        [self addSubview:timestampLabel];
        self.postImageView.hidden = YES;
    }
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
}

@end
