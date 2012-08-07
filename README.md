## AssetPicker

DIYAssetPicker is an almost drop-in replacement for UIImagePickerController. It works in all screen orientations and it doesn't leak memory all over.

#### CAVEATS:
- UIImagePickerController returns a filesystem path for videos. I couldn't figure out how to get that path; StackOverflow suggests that it is impossible without using private APIs.

#### TO DO:
- The property assetType is intended to tell the AssetPicker to pull only certain types of assets. It currently does nothing.
- The property numberColumns also does not currently do anything.

## Basic Use
DIYAssetPickerController *picker = [[DIYAssetPickerController alloc] init];
picker.delegate = self;
[self presentModalViewController:picker animated:true];
[picker release];

## Protocol
@protocol DIYAssetPickerControllerDelegate <NSObject>
@required
// These are equivalent to the UIImagePickerController delegate methods
- (void)pickerDidCancel:(DIYAssetPickerController *)picker;
- (void)pickerDidFinishPickingWithInfo:(NSDictionary *)info;
@optional
// The picker takes a few hundred milliseconds to load libraries with hundreds of items; use this if you want to do something cute if you want to
- (void)pickerDidFinishLoading;
// Hook this up to shouldAutorotateToInterfaceOrientation in the delegate if you want the picker to autorotate
- (BOOL)shouldPickerAutorotate:(UIInterfaceOrientation)toInterfaceOrientation;
@end

## Properties
@property (assign) id<DIYAssetPickerControllerDelegate> delegate;

## ARC
ARC is not supported at this time ;_;

## Credits
Brandon Coston did some smart stuff in [PhotoPickerPlus](https://github.com/chute/photo-picker-plus) to create a gridded table view. I totally copped some ideas from that project.