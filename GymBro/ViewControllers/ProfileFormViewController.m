//
//  ProfileFormViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "ProfileFormViewController.h"
#import "../Models/ProfileFormCell.h"
#import "../Models/Post.h"
#import "../API/APIManager.h"
#import "UIImageView+AFNetworking.h"
#import "Parse/Parse.h"


@interface ProfileFormViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)submit:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *imageControl;
@property (weak, nonatomic) IBOutlet UIImageView *profileImagesView;
@property (strong, nonatomic) NSMutableArray *profileImages;
@property (strong, nonatomic) PFUser *currUser;
- (IBAction)switchImages:(id)sender;
- (IBAction)goBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation ProfileFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currUser = [PFUser currentUser];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 200;
    
    UIImage *backIcon = [UIImage imageNamed:@"back.png"];
    backIcon = [APIManager resizeImage:backIcon withSize:CGSizeMake(40,30)];
    [self.backButton setTitle:@"" forState:UIControlStateNormal];
    [self.backButton setImage:backIcon forState:UIControlStateNormal];
    
    PFUser *user = [PFUser currentUser];
    self.profileImages = [[NSMutableArray alloc] initWithArray:user[@"profileImages"]];
    if (self.profileImages.count > 0)
    {
        PFFileObject *pic = self.profileImages[0];
        NSURL *url = [NSURL URLWithString:pic.url];
        [self.profileImagesView setImageWithURL:url];
    }
    else
    {
        self.profileImagesView.image = [UIImage imageNamed:@"camera-icon.png"];
    }
    
    UITapGestureRecognizer *profileImageChange = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseProfilePic)];
    [profileImageChange setDelegate:self];
    [self.profileImagesView addGestureRecognizer:profileImageChange];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self selector:@selector(keyboardWillShow:) name:
    UIKeyboardWillShowNotification object:nil];

    [nc addObserver:self selector:@selector(keyboardWillHide:) name:
    UIKeyboardWillHideNotification object:nil];

    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
    action:@selector(didTapAnywhere:)];
}


- (void)chooseProfilePic
{
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    PFUser *user = [PFUser currentUser];
    CGSize size = CGSizeMake(400, 400);
    self.profileImagesView.image = [APIManager resizeImage:info[UIImagePickerControllerOriginalImage] withSize:size];
    
    if (self.profileImages.count == 0 || self.imageControl.selectedSegmentIndex == self.profileImages.count)
    {
        [self.profileImages addObject:[Post getPFFileFromImage:self.profileImagesView.image]];
    }
    else
    {
        [self.profileImages replaceObjectAtIndex:self.imageControl.selectedSegmentIndex withObject:[Post getPFFileFromImage:self.profileImagesView.image]];
    }
    user[@"profileImages"] = self.profileImages;
    [[PFUser currentUser] saveInBackground];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (indexPath.row == 0)
    {
        ProfileFormCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileFormBio"];
        cell.controller = self;
        self.bio = self.currUser[@"bio"];
        cell.bioTextView.text = self.currUser[@"bio"];
        [cell setTraits];
        return cell;
    }
    if (indexPath.row == 1)
    {
        ProfileFormCell *splitCell = [tableView dequeueReusableCellWithIdentifier:@"ProfileFormSplit" forIndexPath:indexPath];
        splitCell.controller = self;
        NSArray *splitOptions = [[NSArray alloc] initWithObjects:@"Whole Body Split", @"Upper And Lower Body Split", @"Push/Pull/Legs",  @"Four Day Split", @"Five Day Split", @"Yoga", @"Other", nil];
        splitCell.traitValue = (int)[splitOptions indexOfObject:self.currUser[@"workoutSplit"]];
        [splitCell setTraits];
        return splitCell;
    }
    else if (indexPath.row == 2)
    {
        ProfileFormCell *workoutTimeCell = [tableView dequeueReusableCellWithIdentifier:@"ProfileFormTime" forIndexPath:indexPath];
        workoutTimeCell.controller = self;
        NSArray *timeOptions = [[NSArray alloc] initWithObjects:@"Morning (6am - 12pm)", @"Afternoon (12 - 5pm)", @"Evening (5 - 9pm)", @"Late Night (past 9pm)", nil];
        workoutTimeCell.traitValue = (int)[timeOptions indexOfObject:self.currUser[@"workoutTime"]];
        [workoutTimeCell setTraits];
        return workoutTimeCell;
    }
    else if (indexPath.row == 3)
    {
        ProfileFormCell *genderCell = [tableView dequeueReusableCellWithIdentifier:@"ProfileFormGender" forIndexPath:indexPath];
        genderCell.controller = self;
        NSArray *genderOptions = [[NSArray alloc] initWithObjects:@"Male", @"Female", nil];
        genderCell.traitValue = (int)[genderOptions indexOfObject:self.currUser[@"gender"]];
        [genderCell setTraits];
        return genderCell;
    }
    else if (indexPath.row == 4)
    {
        ProfileFormCell *levelCell = [tableView dequeueReusableCellWithIdentifier:@"ProfileFormLevel" forIndexPath:indexPath];
        levelCell.controller = self;
        NSArray *levelOptions = [[NSArray alloc] initWithObjects:@"Novei", @"Intermediate", @"Advanced", nil];
        levelCell.traitValue = (int)[levelOptions indexOfObject:self.currUser[@"level"]];
        [levelCell setTraits];
        return levelCell;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submit:(id)sender {
    PFUser *user = [PFUser currentUser];
    if (!self.split)
    {
        user[@"workoutSplit"] = @"Whole Body Split";
    }
    else
    {
        user[@"workoutSplit"] = self.split;
    }
    if (!self.time)
    {
        user[@"workoutTime"] = @"Morning (6am - 12pm)";
    }
    else
    {
        user[@"workoutTime"] = self.time;
    }
    if (!self.gender)
    {
        user[@"gender"] = @"Male";
    }
    else
    {
        user[@"gender"] = self.gender;
    }
    if (!self.level)
    {
        user[@"level"] = @"Novice";
    }
    else
    {
        user[@"level"] = self.level;
    }
    user[@"bio"] = self.bio;
    if (self.profileImages.count > 0)
    {
        user[@"profileImages"] = self.profileImages;
    }
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            [self dismissViewControllerAnimated:true completion:^{
                [self.delegate displayInfo];
            }];
        }
        else
        {
            NSLog(@"Error Updating Profile: %@", error.localizedDescription);
        }
    }];
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchImages:(id)sender {
    self.profileImages = [[NSMutableArray alloc] initWithArray:[PFUser currentUser][@"profileImages"]];
    if (self.imageControl.selectedSegmentIndex > self.profileImages.count)
    {
        self.imageControl.selectedSegmentIndex = 0;
        PFFileObject *pic = self.profileImages[self.imageControl.selectedSegmentIndex];
        NSURL *url = [NSURL URLWithString:pic.url];
        [self.profileImagesView setImageWithURL:url];
    }
    else if (self.imageControl.selectedSegmentIndex == self.profileImages.count)
    {
        self.profileImagesView.image = [UIImage imageNamed:@"camera-icon.png"];
    }
    else
    {
        PFFileObject *pic = self.profileImages[self.imageControl.selectedSegmentIndex];
        NSURL *url = [NSURL URLWithString:pic.url];
        [self.profileImagesView setImageWithURL:url];
    }
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
