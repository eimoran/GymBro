//
//  ProfileViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()
- (IBAction)updateInfo:(id)sender;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
}
@end
