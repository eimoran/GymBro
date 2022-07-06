//
//  GenderCell.m
//  GymBro
//
//  Created by Eric Moran on 7/6/22.
//

#import "GenderCell.h"
@interface GenderCell () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) NSString *gender;

@end

@implementation GenderCell

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
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = nil;
    switch(row) {
        case 0:
            title = @"Male";
            break;
        case 1:
            title = @"Female";
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
            self.gender = @"Male";
            break;
        case 1:
            self.gender = @"Female";
            break;
    }
    self.controller.gender = self.gender;
}

@end
