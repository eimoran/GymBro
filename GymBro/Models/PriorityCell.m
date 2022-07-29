//
//  PriorityCell.m
//  GymBro
//
//  Created by Eric Moran on 7/28/22.
//

#import "PriorityCell.h"

@interface PriorityCell() <UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@end

@implementation PriorityCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.picker.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)picker numberOfRowsInComponent:(NSInteger)component {
    return 5;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = nil;
    switch(row) {
        case 0:
            title = @"5";
            break;
        case 1:
            title = @"4";
            break;
        case 2:
            title = @"3";
            break;
        case 3:
            title = @"2";
            break;
        case 4:
            title = @"1";
            break;
    }
    return title;
}

- (void)pickerView:(UIPickerView *)picker
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    
    //Here, like the table view you can get the each section of each row if you've multiple sections
    switch (self.row) {
        case 0:
            self.filterVC.workoutType = (int)(5 - row);
            break;
        case 1:
            self.filterVC.workoutTime = (int)(5 - row);
            break;
        case 2:
            self.filterVC.level = (int)(5 - row);
            break;
        case 3:
            self.filterVC.distance1 = (int)(5 - row);
            break;
        case 4:
            self.filterVC.distance2 = (int)(5 - row);
            break;
        case 5:
            self.filterVC.distance3 = (int)(5 - row);
            break;
            
        default:
            break;
    }
}

@end
