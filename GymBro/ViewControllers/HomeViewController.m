//
//  HomeViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "HomeViewController.h"
#import "../Models/UserCell.h"

@interface HomeViewController ()

@property (strong, nonatomic) NSArray *userArray;

- (IBAction)seeFriends:(id)sender;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//}

- (IBAction)seeFriends:(id)sender {
}
@end
