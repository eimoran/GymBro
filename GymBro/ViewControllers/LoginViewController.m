//
//  LoginViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "../API/APIManager.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)login:(id)sender;
- (IBAction)signup:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Hide email field unless user is trying to sign up
    self.emailField.hidden = true;
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.emailField.delegate = self;
    
    UIImage *loginIcon = [UIImage imageNamed:@"login.png"];
    loginIcon = [APIManager resizeImage:loginIcon withSize:CGSizeMake(45,45)];
    [self.loginButton setTitle:@"" forState:UIControlStateNormal];
    [self.loginButton setImage:loginIcon forState:UIControlStateNormal];
    
    UIImage *signupIcon = [UIImage imageNamed:@"signup.png"];
    signupIcon = [APIManager resizeImage:signupIcon withSize:CGSizeMake(45,45)];
    [self.signupButton setTitle:@"" forState:UIControlStateNormal];
    [self.signupButton setImage:signupIcon forState:UIControlStateNormal];
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self selector:@selector(keyboardWillShow:) name:
    UIKeyboardWillShowNotification object:nil];

    [nc addObserver:self selector:@selector(keyboardWillHide:) name:
    UIKeyboardWillHideNotification object:nil];

    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
    action:@selector(didTapAnywhere:)];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    [self.view endEditing:YES];
}

-(void) keyboardWillShow:(NSNotification *) note {
    [self.view addGestureRecognizer:self.tapRecognizer];
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.view removeGestureRecognizer:self.tapRecognizer];
}
@end
