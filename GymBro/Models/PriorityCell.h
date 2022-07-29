//
//  PriorityCell.h
//  GymBro
//
//  Created by Eric Moran on 7/28/22.
//

#import <UIKit/UIKit.h>
#import "../ViewControllers/FilterViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PriorityCell : UITableViewCell <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UILabel *traitLabel;
@property (strong, nonatomic) FilterViewController *filterVC;
@property (nonatomic) BOOL custom;
@property int filterValue;

- (void)setFilter;

@end

NS_ASSUME_NONNULL_END
