//
//  WorkoutSplitCell.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "WorkoutSplitCell.h"

@interface WorkoutSplitCell () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) NSString *split;
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
    return 5;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = nil;
    switch(row) {
        case 0:
            title = @"Whole-Body Split";
            break;
        case 1:
            title = @"Upper- And Lower-Body Split";
            break;
        case 2:
            title = @"Push/Pull/Legs";
            break;
        case 3:
            title = @"Four-Day Split";
            break;
        case 4:
            title = @"Five-Day Split";
            break;
    }
    return title;
}

- (void)pickerView:(UIPickerView *)picker
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    
    //Here, like the table view you can get the each section of each row if you've multiple sections
//    NSLog(@"%@", self.split);
    switch(row) {
        case 0:
            self.split = @"Whole Body Split";
            break;
        case 1:
            self.split = @"Upper And Lower Body Split";
            break;
        case 2:
            self.split = @"Push/Pull/Legs";
            break;
        case 3:
            self.split = @"Four Day Split";
            break;
        case 4:
            self.split = @"Five Day Split";
            break;
    }
    
    self.controller.split = self.split;
}

@end
