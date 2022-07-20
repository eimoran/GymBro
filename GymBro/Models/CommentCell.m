//
//  CommentCell.m
//  GymBro
//
//  Created by Eric Moran on 7/20/22.
//

#import "CommentCell.h"

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
    self.postTextLabel.text = [NSString stringWithFormat:@"%@ %@", self.comment.author, self.comment.text];
    
    NSMutableAttributedString *postText = [[NSMutableAttributedString alloc] initWithString:self.postTextLabel.text];
    NSRange boldRange = [self.postTextLabel.text rangeOfString:self.comment.author];
    [postText addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:boldRange];
    [self.postTextLabel setAttributedText: postText];
    
    [self setTimestamp];
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
        
    if (days > 364)
    {
        formatter2.allowedUnits = NSCalendarUnitYear;
    }
    else if (days > 30)
    {
        formatter2.allowedUnits = NSCalendarUnitMonth;
    }
    else if (hours > 24)
    {
        formatter2.allowedUnits = NSCalendarUnitDay;
    }
    else if(hours >= 1) {
        formatter2.allowedUnits = NSCalendarUnitHour;
        
    }
    else if(minutes > 1) {
        formatter2.allowedUnits = NSCalendarUnitMinute;
    }
    else {
        formatter2.allowedUnits = NSCalendarUnitSecond;
    }
    NSString *elapsed = [formatter2 stringFromDate:date toDate:[NSDate date]];
    self.timestampLabel.text = [NSString stringWithFormat:@"%@ ago", elapsed];
}

@end
