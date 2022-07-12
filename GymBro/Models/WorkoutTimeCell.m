//
//  WorkoutTimeCell.m
//  GymBro
//
//  Created by Eric Moran on 7/6/22.
//

#import "WorkoutTimeCell.h"

@interface WorkoutTimeCell () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (nonatomic) NSString *workoutTime;

@end

@implementation WorkoutTimeCell

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
    return 4;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = nil;
    switch(row) {
        case 0:
            title = @"Morning (6am - 12pm)";
            break;
        case 1:
            title = @"Afternoon (12 - 5pm)";
            break;
        case 2:
            title = @"Evening (5 - 9pm)";
            break;
        case 3:
            title = @"Late Night (past 9pm)";
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
            self.workoutTime = @"Morning (6am - 12pm)";
            break;
        case 1:
            self.workoutTime = @"Afternoon (12 - 5pm)";
            break;
        case 2:
            self.workoutTime = @"Evening (5 - 9pm)";
            break;
        case 3:
            self.workoutTime = @"Late Night (past 9pm)";
            break;
    }
    self.controller.time = self.workoutTime;
}

@end

