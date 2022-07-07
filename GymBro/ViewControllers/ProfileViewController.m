//
//  ProfileViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "ProfileViewController.h"
#import "ProfileFormViewController.h"
#import "Parse/Parse.h"

@interface ProfileViewController () <ProfileFormViewControllerDelegate>
- (IBAction)updateInfo:(id)sender;
@property (strong, nonatomic) NSString *workoutSplit;
@property (strong, nonatomic) NSString *workoutTime;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *gym;
@property (strong, nonatomic) IBOutlet UILabel *workoutPlanLabel;
@property (strong, nonatomic) IBOutlet UILabel *workoutTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *genderLabel;
@property (strong, nonatomic) IBOutlet UILabel *gymlabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getProfile];
    [self displayInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"APPEARED");
//    [self displayInfo];
}

- (void)getProfile
{
    PFUser *user = [PFUser currentUser];
    self.workoutSplit = user[@"workoutSplit"];
    self.workoutTime = user[@"workoutTime"];
    self.gender = user[@"gender"];
}

- (void)updateProfile:(NSString *)split :(NSString *)time :(NSString *)gender
{
    NSLog(@"UPDATING PROFILE");
    [self displayInfo];
//    self.workoutSplit = split;
//    self.workoutTime = time;
//    self.gender = gender;
}

- (void)displayInfo
{
    NSLog(@"DISPLAYING INFO");
    PFUser *user = [PFUser currentUser];
//    [self updateProfile:user[@"workoutSplit"] :user[@"workoutTime"] :user[@"gender"]];
    self.workoutPlanLabel.text = [NSString stringWithFormat:@"Workout Split: %@", user[@"workoutSplit"]];
    self.workoutTimeLabel.text = [NSString stringWithFormat:@"Time you workout: %@", user[@"workoutTime"]];
    self.genderLabel.text = [NSString stringWithFormat:@"Gender: %@", user[@"gender"]];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)updateInfo:(id)sender {
    [self performSegueWithIdentifier:@"profileForm" sender:self];
//    [self displayInfo];
}

@end
