//
//  UserCell.m
//  GymBro
//
//  Created by Eric Moran on 7/12/22.
//

#import "UserCell.h"

@interface UserCell ()

@property (weak, nonatomic) IBOutlet UILabel *username;

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
    self.username.text = self.user[@"username"];
    NSLog(@"%@", self.username.text);
}

@end
