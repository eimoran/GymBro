//
//  LoginViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "../API/APIManager.h"

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
    [APIManager signupUserWithController:self withEmail:self.emailField.text withUsername:self.usernameField.text withPassword:self.passwordField.text];
}

- (void)loginUser {
    [APIManager loginUserWithController:self withUsername:self.usernameField.text withPassword:self.passwordField.text];
}


- (IBAction)signup:(id)sender {
    self.emailField.hidden = false;
    if ([self.usernameField isEqual:@""] || self.emailField.text.length == 0 || [self.passwordField isEqual:@""])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Fields"
                                                                       message:@"Please Fill In Missing Fields"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                             {}];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        [self registerUser];
        
    }
}

- (IBAction)login:(id)sender {
    if ([self.usernameField isEqual:@""] || [self.passwordField isEqual:@""])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Fields"
                                                                       message:@"Please Fill In Missing Fields"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                             {}];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        [self loginUser];
    }
}
@end
