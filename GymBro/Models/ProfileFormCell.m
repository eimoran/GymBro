//
//  ProfileFormCell.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "ProfileFormCell.h"

@interface ProfileFormCell () <UIPickerViewDelegate, UIPickerViewDataSource>
@end

@implementation ProfileFormCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIPickerView * picker = [UIPickerView new];
    picker.delegate = self;
    picker.dataSource = self;
//    picker.showsSelectionIndicator = YES;
    [self addSubview:picker];
//    self.planPicker.delegate = self;
//    self.planPicker.dataSource = self;
//    self.planPicker.showsSelectionIndicator = YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = nil;
    switch(row) {
            case 0:
                title = @"a";
                break;
            case 1:
                title = @"b";
                break;
            case 2:
                title = @"c";
                break;
    }
    return title;
}
@end
