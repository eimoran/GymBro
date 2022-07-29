//
//  PriorityCell.h
//  GymBro
//
//  Created by Eric Moran on 7/28/22.
//

#import <UIKit/UIKit.h>
#import "../ViewControllers/FilterViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PriorityCell : UITableViewCell

@property int row;
@property (weak, nonatomic) IBOutlet UILabel *traitLabel;
@property (strong, nonatomic) FilterViewController *filterVC;

@end

NS_ASSUME_NONNULL_END
