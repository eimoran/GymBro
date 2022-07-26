//
//  SearchBarCell.h
//  GymBro
//
//  Created by Eric Moran on 7/26/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchBarCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *gymNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) NSDictionary *gym;

- (void)setInfo;

@end

NS_ASSUME_NONNULL_END
