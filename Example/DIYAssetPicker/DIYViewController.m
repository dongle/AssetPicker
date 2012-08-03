//
//  DIYViewController.m
//  DIYAssetPicker
//
//  Created by Jonathan Beilin on 8/1/12.
//  Copyright (c) 2012 Jonathan Beilin. All rights reserved.
//

#import "DIYViewController.h"

@implementation DIYViewController

@synthesize diyPicker = _diyPicker;
//@synthesize uiPicker = _uiPicker;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _diyPicker = [[DIYAssetPickerController alloc] init];
    self.diyPicker.delegate = self;

    /*
    _uiPicker = [[UIImagePickerController alloc] init];
    self.uiPicker.delegate = self;
    self.uiPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                                UIImagePickerControllerSourceTypeCamera];
     */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return true;
}

#pragma mark - UI
-(IBAction)assetPickerButtonSelected:(id)sender
{
    [self presentModalViewController:self.diyPicker animated:true];
    //[self presentModalViewController:self.uiPicker animated:true];
}

#pragma mark - DIYAssetPickerController protocol
- (void)pickerDidCancel:(DIYAssetPickerController *)picker
{
    [self dismissModalViewControllerAnimated:true];
}

- (void)pickerDidFinishPickingWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:true];
    NSLog(@"asset info: %@", info);
}

- (void)pickerDidFinishLoading
{

}

#pragma mark - UIImagePickerController protocol
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"asset info: %@", info);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
}

#pragma mark - Dealloc
- (void)releaseObjects
{
    [_diyPicker release]; _diyPicker = nil;
//    [_uiPicker release]; _uiPicker = nil;
}

- (void)dealloc
{
    [self releaseObjects];
    [super dealloc];
}

@end
