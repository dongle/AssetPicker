//
//  DIYAssetPickerController.h
//  DIYAssetPicker
//
//  Created by Jonathan Beilin on 7/30/12.
//  Copyright (c) 2012 DIY, Co. All rights reserved.
//
// Some code based on PhotoPickerPlus

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

// Thanks to P3:
#define THUMB_COUNT_PER_ROW ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 6 : 4)

#define MIN_THUMB_SPACING ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 4 : 1)

#define MAX_THUMB_SIZE 100

#define THUMB_SIZE (MIN(floor((self.assetsTable.frame.size.width-(MIN_THUMB_SPACING*(THUMB_COUNT_PER_ROW+1)))/THUMB_COUNT_PER_ROW),MAX_THUMB_SIZE))

#define THUMB_SPACING (MAX(floor((self.assetsTable.frame.size.width-(THUMB_COUNT_PER_ROW*THUMB_SIZE))/(THUMB_COUNT_PER_ROW+1)),MIN_THUMB_SPACING))
// Endthanks

@class DIYAssetPickerController;

@protocol DIYAssetPickerControllerDelegate <NSObject>
@required
- (void)pickerDidCancel:(DIYAssetPickerController *)picker;
- (void)pickerDidFinishPickingWithInfo:(NSDictionary *)info;
@optional
- (void)pickerDidFinishLoading;
- (BOOL)shouldPickerAutorotate:(UIInterfaceOrientation)toInterfaceOrientation;
@end

UIInterfaceOrientation orientation;

typedef enum {
    DIYAssetPickerPhoto,
    DIYAssetPickerVideo,
    DIYAssetPickerPhotoVideo
} DIYAssetPickerControllerAssetType;

@interface DIYAssetPickerController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    @private ALAssetsLibrary        *_assetsLibrary;
    @private NSMutableArray         *_assetsArray;
    @private UITableView            *_assetsTable;
    @private UINavigationBar        *_header;
    
    @private NSMutableDictionary    *_videoInfo;
    @private AVAssetExportSession   *_exporter;
    @private NSTimer                *_exportDisplayTimer;
}

#pragma mark - Delegate
@property (assign)            id<DIYAssetPickerControllerDelegate>  delegate;

#pragma mark - Options
@property (nonatomic, assign) DIYAssetPickerControllerAssetType     assetType;

@end