//
//  UserCell.m
//  GymBro
//
//  Created by Eric Moran on 7/12/22.
//

#import "UserCell.h"
#import "UIImageView+AFNetworking.h"


@interface UserCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImagesView;
@property (strong, nonatomic) NSMutableArray *profileImages;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicView;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *workoutTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *workoutTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *gymLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
- (IBAction)previousImage:(id)sender;
- (IBAction)nextImage:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *previousImageButton;
@property (weak, nonatomic) IBOutlet UIButton *nextImageButton;

@end

@implementation UserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.previousImageButton.imageView.transform = CGAffineTransformMakeScale(-1, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setData
{
    self.profileImages = self.user[@"profileImages"];
    if (self.profileImages.count > 0)
    {
        PFFileObject *imageObj = self.profileImages[0];
        NSURL *url = [NSURL URLWithString:imageObj.url];
        [self.profileImagesView setImageWithURL:url];
    }
    
    if (self.user[@"profilePic"])
    {
        self.profilePicView.layer.cornerRadius = self.profilePicView.frame.size.height/2.0;
        PFFileObject *profilePicObj = self.user[@"profilePic"];
        NSURL *url2 = [NSURL URLWithString:profilePicObj.url];
        [self.profilePicView setImageWithURL:url2];
    }
    else
    {
        self.profilePicView.image = [UIImage imageNamed:@"profile-Icon.png"];
    }
    
    self.usernameLabel.text = self.user[@"username"];
    self.bioLabel.text = self.user[@"bio"];
    self.workoutTypeLabel.text = [NSString stringWithFormat:@"· %@", self.user[@"workoutSplit"]];
    self.workoutTimeLabel.text = [NSString stringWithFormat:@"· %@", self.user[@"workoutTime"]];
    self.genderLabel.text = [NSString stringWithFormat:@"· %@", self.user[@"gender"]];
    self.levelLabel.text = [NSString stringWithFormat:@"· %@", self.user[@"level"]];
    self.gymLabel.text = [NSString stringWithFormat:@"· %@", [self.user[@"gym"] valueForKeyPath:@"name"]];
    self.distanceLabel.text = [NSString stringWithFormat:@"· %.2f mi away", self.distanceFromUser * 0.00062317];
}

- (void)swipedLeft
{
    if (self.currPhotoIndex == self.profileImages.count - 1)
    {}
    else
    {
        self.currPhotoIndex++;
        PFFileObject *imageObj = self.user[@"profileImages"][self.currPhotoIndex];
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageObj.url]];
        self.profileImagesView.image = [UIImage imageWithData:data];
    }
}

- (void)swipedRight
{
    if (self.currPhotoIndex == 0)
    {}
    else
    {
        self.currPhotoIndex--;
        PFFileObject *imageObj = self.user[@"profileImages"][self.currPhotoIndex];
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageObj.url]];
        self.profileImagesView.image = [UIImage imageWithData:data];
    }
}

- (IBAction)nextImage:(id)sender {
    if (self.currPhotoIndex == self.profileImages.count - 1)
    {}
    else
    {
        self.currPhotoIndex++;
        PFFileObject *imageObj = self.user[@"profileImages"][self.currPhotoIndex];
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageObj.url]];
        self.profileImagesView.image = [UIImage imageWithData:data];
    }
}

- (IBAction)previousImage:(id)sender {
    if (self.currPhotoIndex == 0)
    {}
    else
    {
        self.currPhotoIndex--;
        PFFileObject *imageObj = self.user[@"profileImages"][self.currPhotoIndex];
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageObj.url]];
        self.profileImagesView.image = [UIImage imageWithData:data];
    }
}
@end
