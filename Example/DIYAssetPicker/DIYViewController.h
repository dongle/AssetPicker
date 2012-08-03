//
//  DIYViewController.h
//  DIYAssetPicker
//
//  Created by Jonathan Beilin on 8/1/12.
//  Copyright (c) 2012 Jonathan Beilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIYAssetPickerController.h"

@interface DIYViewController : UIViewController <DIYAssetPickerControllerDelegate>

@property (nonatomic, retain) DIYAssetPickerController *picker;

- (IBAction)assetPickerButtonSelected:(id)sender;

@end
