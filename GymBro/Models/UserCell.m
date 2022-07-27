//
//  UserCell.m
//  GymBro
//
//  Created by Eric Moran on 7/12/22.
//

#import "UserCell.h"


@interface UserCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *workoutTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *workoutTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *gymLabel;
@property (weak, nonatomic) IBOutlet UIButton *friendRequestButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptFriendRequestButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
- (IBAction)sendFriendRequest:(id)sender;
- (IBAction)acceptFriendRequest:(id)sender;


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

- (IBAction)acceptFriendRequest:(id)sender {
    PFUser *user = [PFUser currentUser];
    NSMutableArray *friendsArray = [[NSMutableArray alloc] initWithArray:user[@"friends"]];
    [friendsArray addObject:[self.user valueForKeyPath:@"username"]];
    user[@"friends"] = friendsArray;
    
    NSMutableArray *friendRequestsArray = [[NSMutableArray alloc] initWithArray:user[@"friendRequests"]];
    [friendRequestsArray removeObjectIdenticalTo:[self.user valueForKeyPath:@"username"]];
    user[@"friendRequests"] = friendRequestsArray;
    
    NSMutableArray *otherFriendsArray = [[NSMutableArray alloc] initWithArray:self.user[@"friends"]];
    [otherFriendsArray addObject:[user valueForKeyPath:@"username"]];
    
    NSMutableArray *otherPendingFriendsArray = [[NSMutableArray alloc] initWithArray:self.user[@"pendingFriends"]];
    [otherPendingFriendsArray removeObjectIdenticalTo:[user valueForKeyPath:@"username"]];
    
    NSDictionary *params = @{@"username": [self.user valueForKeyPath:@"username"],
                             @"friends": otherFriendsArray,
                             @"pendingFriends": otherPendingFriendsArray};
    
    [PFCloud callFunctionInBackground:@"acceptFriendRequest" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
    }];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            self.acceptFriendRequestButton.hidden = true;
            
            UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"Success!" message:@"Successfully Accepted Friend Request!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok1 = [UIAlertAction actionWithTitle:@"Ok" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {}];
            [alert1 addAction:ok1];
            [self.controller presentViewController:alert1 animated:YES completion:nil];
        }
        else
        {
            NSLog(@"Error Sending Friend Request: %@", error.localizedDescription);
        }
    }];
    
}

- (IBAction)sendFriendRequest:(id)sender {
    PFUser *user = [PFUser currentUser];
    NSMutableArray *pendingFriendsArray = [[NSMutableArray alloc] initWithArray:user[@"pendingFriends"]];
    [pendingFriendsArray addObject:[self.user valueForKeyPath:@"username"]];
    user[@"pendingFriends"] = pendingFriendsArray;
    
    NSMutableArray *otherUserFriendRequestArray = [[NSMutableArray alloc] initWithArray:user[@"friendRequests"]];
    [otherUserFriendRequestArray addObject:[user valueForKeyPath:@"username"]];
    self.user[@"friendRequests"] = otherUserFriendRequestArray;
    
    NSDictionary *params = @{@"username": [self.user valueForKeyPath:@"username"],
                             @"friendRequests": otherUserFriendRequestArray};
    
    [PFCloud callFunctionInBackground:@"sendFriendRequest" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
    }];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            self.friendRequestButton.hidden = true;
            UIAlertController *alert2 = [UIAlertController alertControllerWithTitle:@"Success!"
                                                                           message:@"Successfully Sent Friend Request"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok2 = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
            [alert2 addAction:ok2];
            [self.controller presentViewController:alert2 animated:YES completion:nil];
        }
        else
        {
            NSLog(@"Error Sending Friend Request: %@", error.localizedDescription);
        }
    }];
}
@end
