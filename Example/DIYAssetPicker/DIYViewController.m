//
//  DIYViewController.m
//  DIYAssetPicker
//
//  Created by Jonathan Beilin on 8/1/12.
//  Copyright (c) 2012 Jonathan Beilin. All rights reserved.
//

#import "DIYViewController.h"

@implementation DIYViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    DIYAssetPickerController *picker = [[DIYAssetPickerController alloc] init];
    picker.delegate = self;
    [self presentModalViewController:picker animated:true];
    [picker release];
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

}

- (void)dealloc
{
    [self releaseObjects];
    [super dealloc];
}

@end
