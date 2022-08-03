//
//  LevelCell.m
//  GymBro
//
//  Created by Eric Moran on 7/7/22.
//

#import "LevelCell.h"

@interface LevelCell () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) NSString *level;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@end

@implementation LevelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.picker.delegate = self;
    self.picker.dataSource = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)picker numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = nil;
    switch(row) {
        case 0:
            title = @"Novice";
            break;
        case 1:
            title = @"Intermediate";
            break;
        case 2:
            title = @"Advanced";
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
            self.level = @"Novice";
            break;
        case 1:
            self.level = @"Intermediate";
            break;
        case 2:
            self.level = @"Advanced";
            break;
    }
    
    self.controller.level = self.level;
}

@end

