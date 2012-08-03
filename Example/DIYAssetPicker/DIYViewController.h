//
//  DIYViewController.h
//  DIYAssetPicker
//
//  Created by Jonathan Beilin on 8/1/12.
//  Copyright (c) 2012 Jonathan Beilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIYAssetPickerController.h"

@interface DIYViewController : UIViewController <DIYAssetPickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, retain) DIYAssetPickerController *diyPicker;
//@property (nonatomic, retain) UIImagePickerController *uiPicker;

- (IBAction)assetPickerButtonSelected:(id)sender;

@end
