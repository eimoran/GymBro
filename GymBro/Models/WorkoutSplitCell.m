//
//  WorkoutSplitCell.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "WorkoutSplitCell.h"

@interface WorkoutSplitCell () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@end

@implementation WorkoutSplitCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.picker.delegate = self;
    self.picker.dataSource = self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)picker numberOfRowsInComponent:(NSInteger)component {
    return 7;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = nil;
    switch(row) {
        case 0:
            title = @"Whole Body Split";
            break;
        case 1:
            title = @"Upper/Lower Body Split";
            break;
        case 2:
            title = @"Push/Pull/Legs";
            break;
        case 3:
            title = @"Four Day Split";
            break;
        case 4:
            title = @"Five Day Split";
            break;
        case 5:
            title = @"Yoga";
            break;
        case 6:
            title = @"Other";
            break;
    }
    return title;
}

- (void)pickerView:(UIPickerView *)picker
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    
    //Here, like the table view you can get the each section of each row if you've multiple sections
    switch(row) {
        case 0:
            self.controller.split = @"Whole Body Split";
            break;
        case 1:
            self.controller.split = @"Upper And Lower Body Split";
            break;
        case 2:
            self.controller.split = @"Push/Pull/Legs";
            break;
        case 3:
            self.controller.split = @"Four Day Split";
            break;
        case 4:
            self.controller.split = @"Five Day Split";
            break;
        case 5:
            self.controller.split = @"Yoga";
            break;
        case 6:
            self.controller.split = @"Other";
            break;
    }
}

@end
