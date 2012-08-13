## AssetPicker

DIYAssetPicker is a drop-in replacement for UIImagePickerController. It works in all screen orientations and it packs a convenient thumbnail with the output dictionary.

## Basic Use
```objective-c
DIYAssetPickerController *picker = [[DIYAssetPickerController alloc] init];
picker.delegate = self;
[self presentModalViewController:picker animated:true];
[picker release];
```

## Protocol
__Methods__:
```objective-c
@protocol DIYAssetPickerControllerDelegate <NSObject>
@required
// These are equivalent to the UIImagePickerController delegate methods
- (void)pickerDidCancel:(DIYAssetPickerController *)picker;
- (void)pickerDidFinishPickingWithInfo:(NSDictionary *)info;
@optional
// The picker takes a few hundred milliseconds to load libraries with hundreds of items; use this if you want to do something cute during loading
- (void)pickerDidFinishLoading;
// Hook this up to shouldAutorotateToInterfaceOrientation in the delegate if you want the picker to autorotate
- (BOOL)shouldPickerAutorotate:(UIInterfaceOrientation)toInterfaceOrientation;
@end
```

__Output dictionary keys__:
```objective-c
// Same as Apple's
NSString *const UIImagePickerControllerMediaType;
NSString *const UIImagePickerControllerOriginalImage;
NSString *const UIImagePickerControllerReferenceURL;
NSString *const UIImagePickerControllerMediaURL;

// NEW STUFF
NSString *const DIYAssetPickerThumbnail; // UIImage of the asset's thumbnail
```

Check out the [UIImagePickerControllerDelegate Protocol Reference](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIImagePickerControllerDelegate_Protocol/)


## Properties
```objective-c
@property (assign) id<DIYAssetPickerControllerDelegate> delegate;
// Set assetType to show only photos, only videos, or both. Defaults to both
@property (nonatomic, assign) DIYAssetPickerControllerAssetType assetType;
```

## ARC
ARC is not supported at this time ;_;

## CAVEATS:
- I'm using the new [literals for NSArray and NSDictionary](http://cocoaheads.tumblr.com/post/17757846453/objective-c-literals-for-nsdictionary-nsarray-and). You'll need to use Xcode 4.4 or later to compile the code.

## Credits
Brandon Coston did some smart stuff in [PhotoPickerPlus](https://github.com/chute/photo-picker-plus) to create a gridded table view. I totally copped some ideas and code from that project.
Andrew Sliwinski reviewed the code and pushed me to make it better.