//
//  DIYViewController.m
//  DIYAssetPicker
//
//  Created by Jonathan Beilin on 8/1/12.
//  Copyright (c) 2012 Jonathan Beilin. All rights reserved.
//

#import "DIYViewController.h"

@interface DIYViewController ()

@end

@implementation DIYViewController

@synthesize picker = _picker;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _picker = [[DIYAssetPickerController alloc] init];
    self.picker.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UI
-(IBAction)assetPickerButtonSelected:(id)sender
{
    [self presentModalViewController:self.picker animated:true];
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

#pragma mark - Dealloc
- (void)releaseObjects
{
    [_picker release]; _picker = nil;
}

- (void)dealloc
{
    [self releaseObjects];
    [super dealloc];
}

@end
