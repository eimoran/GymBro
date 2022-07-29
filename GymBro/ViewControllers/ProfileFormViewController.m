//
//  ProfileFormViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "ProfileFormViewController.h"
#import "../Models/WorkoutSplitCell.h"
#import "../Models/WorkoutTimeCell.h"
#import "../Models/GenderCell.h"
#import "../Models/Post.h"
#import "UIImageView+AFNetworking.h"
#import "Parse/Parse.h"


@interface ProfileFormViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)submit:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *imageControl;
@property (weak, nonatomic) IBOutlet UIImageView *profileImagesView;
@property (strong, nonatomic) NSMutableArray *profileImages;
- (IBAction)switchImages:(id)sender;

@end

@implementation ProfileFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view.
    self.tableView.rowHeight = 200;
    
    PFUser *user = [PFUser currentUser];
    self.profileImages = [[NSMutableArray alloc] initWithArray:user[@"profileImages"]];
    if (user[@"profileImages"])
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
    CGSize size = CGSizeMake(500, 700);
    self.profileImagesView.image = [self resizeImage:info[UIImagePickerControllerOriginalImage] withSize:size];
    
    if (self.profileImages.count == 0 || self.imageControl.selectedSegmentIndex == self.profileImages.count)
    {
        NSLog(@"ADDING");
        [self.profileImages addObject:[Post getPFFileFromImage:self.profileImagesView.image]];
    }
    else
    {
        NSLog(@"REPLACING");
        [self.profileImages replaceObjectAtIndex:self.imageControl.selectedSegmentIndex withObject:[Post getPFFileFromImage:self.profileImagesView.image]];
    }
    user[@"profileImages"] = self.profileImages;
    [[PFUser currentUser] saveInBackground];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (indexPath.row == 0)
    {
        WorkoutSplitCell *splitCell = [tableView dequeueReusableCellWithIdentifier:@"WorkoutSplitCell" forIndexPath:indexPath];
        splitCell.controller = self;
        return splitCell;
    }
    else if (indexPath.row == 1)
    {
        WorkoutTimeCell *workoutTimeCell = [tableView dequeueReusableCellWithIdentifier:@"WorkoutTimeCell" forIndexPath:indexPath];
        workoutTimeCell.controller = self;
        return workoutTimeCell;
    }
    else if (indexPath.row == 2)
    {
        GenderCell *genderCell = [tableView dequeueReusableCellWithIdentifier:@"GenderCell" forIndexPath:indexPath];
        genderCell.controller = self;
        return genderCell;
    }
    else if (indexPath.row == 3)
    {
        GenderCell *gymMapCell = [tableView dequeueReusableCellWithIdentifier:@"LevelCell" forIndexPath:indexPath];
        gymMapCell.controller = self;
        return gymMapCell;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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
    // Update User Info
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
    user[@"profileImages"] = self.profileImages;
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
- (IBAction)switchImages:(id)sender {
    self.profileImages = [[NSMutableArray alloc] initWithArray:[PFUser currentUser][@"profileImages"]];
    if (self.imageControl.selectedSegmentIndex > self.profileImages.count)
    {
        self.imageControl.selectedSegmentIndex = 0;
    }
    if (self.imageControl.selectedSegmentIndex == self.profileImages.count)
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
@end
