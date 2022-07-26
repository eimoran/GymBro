//
//  SearchBarCell.m
//  GymBro
//
//  Created by Eric Moran on 7/26/22.
//

#import "SearchBarCell.h"

@implementation SearchBarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInfo
{
    self.gymNameLabel.text = [self.gym valueForKeyPath:@"place.name"];
    self.addressLabel.text = [self.gym valueForKeyPath:@"place.location.formatted_address"];
}

@end
