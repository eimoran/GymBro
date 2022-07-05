//
//  LoginViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)login:(id)sender;
- (IBAction)signup:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Hide email field unless user is trying to sign up
    self.emailField.hidden = true;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)registerUser {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.email = self.emailField.text;
    newUser.password = self.passwordField.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *tabViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            self.view.window.rootViewController = tabViewController;
        }
    }];
}

- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else {
            NSLog(@"User logged in successfully");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *tabViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            self.view.window.rootViewController = tabViewController;
        }
    }];
}


- (IBAction)signup:(id)sender {
    self.emailField.hidden = false;
    if ([self.usernameField isEqual:@""] || [self.emailField isEqual:@""] || [self.passwordField isEqual:@""])
    {
        // Place alert controller
    }
    else{
        [self registerUser];
        
    }
}

- (IBAction)login:(id)sender {
    if ([self.usernameField isEqual:@""] || [self.passwordField isEqual:@""])
    {
        // Place alert controller
    }
    else{
        [self loginUser];
    }
}
@end
