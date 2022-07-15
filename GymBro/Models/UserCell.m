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
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
- (IBAction)addFriend:(id)sender;

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
    self.distanceLabel.text = [NSString stringWithFormat:@"Distance From Your Gym: %.2f mi", self.distanceFromUser*0.00062137];
}

- (IBAction)addFriend:(id)sender {
    PFUser *user = [PFUser currentUser];
    NSMutableArray *friendsArray = [[NSMutableArray alloc] initWithArray:user[@"friends"]];
    [friendsArray addObject:self.user];
    user[@"friends"] = friendsArray;
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            self.addFriendButton.hidden = true;
        }
        else
        {
            NSLog(@"Error Updating Profile: %@", error.localizedDescription);
        }
    }];
}
@end
