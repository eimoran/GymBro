//
//  UserCell.m
//  GymBro
//
//  Created by Eric Moran on 7/12/22.
//

#import "UserCell.h"

@interface UserCell ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *workoutTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *workoutTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *gymLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsLabel;

@end

@implementation UserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData
{
    self.usernameLabel.text = self.user[@"username"];
    self.workoutTypeLabel.text = [NSString stringWithFormat:@"Workout Type: %@", self.user[@"workoutSplit"]];
    self.workoutTimeLabel.text = [NSString stringWithFormat:@"Workout Time: %@", self.user[@"workoutTime"]];
    self.genderLabel.text = [NSString stringWithFormat:@"Gender: %@", self.user[@"gender"]];
    self.levelLabel.text = [NSString stringWithFormat:@"Level: %@", self.user[@"level"]];
    self.gymLabel.text = [NSString stringWithFormat:@"Local Gym: %@", [self.user[@"gym"] valueForKeyPath:@"name"]];
    self.friendsLabel.text = [NSString stringWithFormat:@"Friends: %@", [self.user[@"gym"] valueForKeyPath:@"friends"]];
}

@end
