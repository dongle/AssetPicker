//
//  DIYAssetPickerController.m
//  DIYAssetPicker
//
//  Created by Jonathan Beilin on 7/30/12.
//  Copyright (c) 2012 DIY, Co. All rights reserved.
//

#import "DIYAssetPickerController.h"

@interface DIYAssetPickerController ()
@property ALAssetsLibrary      *assetsLibrary;
@property NSMutableArray       *assetsArray;
@property UITableView          *assetsTable;
@property UINavigationBar      *header;

@property NSMutableDictionary  *videoInfo;
@property AVAssetExportSession *exporter;
@property (weak) NSTimer       *exportDisplayTimer;
@property UIView               *exportDisplay;
@property UIProgressView       *exportDisplayProgress;
@end

NSString *const DIYAssetPickerThumbnail = @"DIYAssetPickerThumbnail";

@implementation DIYAssetPickerController

#pragma mark - Init

- (id)init
{
    if (self = [super init]) {
        _assetType = DIYAssetPickerPhotoVideo;
    }
    
    return self;
}

- (void)_setup
{
    // Setup
    [self setTitle:@"Library"];
    
    // Asset library & array
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    _assetsArray = [[NSMutableArray alloc] init];
    [self getAssetsArray];
    
    // Header
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPicking)];
    
    _header = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.header.barStyle = UIBarStyleBlack;
    self.header.translucent = true;
    [self.header setItems:@[ self.navigationItem ]];
    [self.view addSubview:self.header];
    
    // Asset Table
    _assetsTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.assetsTable setContentInset:UIEdgeInsetsMake(self.header.frame.size.height, 0, 0, 0)];
    [self.assetsTable setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.assetsTable setDelegate:self];
    [self.assetsTable setDataSource:self];
    [self.assetsTable setSeparatorColor:[UIColor clearColor]];
    [self.assetsTable setAllowsSelection:NO];
    [self.assetsTable reloadData];
    [self.view addSubview:self.assetsTable];
    
    [self.view bringSubviewToFront:self.header];
    
    // Asset Info
    _videoInfo = [[NSMutableDictionary alloc] init];
    
    // Exporter stuff; don't initialize until needed
    _exporter = nil;
    _exportDisplay = nil;
    _exportDisplayProgress = nil;
    _exportDisplayTimer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _setup];
}

#pragma mark - View lifecycle

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_exportDisplayTimer invalidate]; _exportDisplayTimer = nil;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([self.delegate respondsToSelector:@selector(shouldPickerAutorotate:)]) {
        return [self.delegate shouldPickerAutorotate:toInterfaceOrientation];
    }
    else {
        return false;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.assetsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:true];
}

#pragma mark - UI

- (void)cancelPicking
{
    [self.delegate pickerDidCancel:self];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!self.assetsArray) {
        return 0;
    }
    return ceil([self.assetsArray count]/((float)THUMB_COUNT_PER_ROW));
}

// Thanks to PhotoPickerPlus:
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PickerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for (UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            for (UIView *view in cell.contentView.subviews){
                [view removeFromSuperview];
            }
            UIView *v = [self tableView:tableView viewForIndexPath:indexPath];
            [cell.contentView addSubview:v];
        });
    });
    
    return cell;
}
//Endthanks

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return THUMB_SPACING + THUMB_SIZE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UIView *)tableView:(UITableView *)tableView viewForIndexPath:(NSIndexPath *)indexPath
{
    // This is the view that will be returned as the contentView for each cell
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.assetsTable.frame.size.width, [self tableView:self.assetsTable heightForRowAtIndexPath:indexPath])];
    
    // Layout variables
    int initialThumbOffset = ((int)self.assetsTable.frame.size.width+THUMB_SPACING-(THUMB_COUNT_PER_ROW*(THUMB_SIZE+THUMB_SPACING)))/2;
    CGRect rect = CGRectMake(initialThumbOffset, THUMB_SPACING/2, THUMB_SIZE, THUMB_SIZE);
    
    // Range variables
    int index = indexPath.row * (THUMB_COUNT_PER_ROW);
    int maxIndex = index + ((THUMB_COUNT_PER_ROW)-1);
    int x = THUMB_COUNT_PER_ROW;
    if (maxIndex >= [self.assetsArray count]) {
        x = x - (maxIndex - [self.assetsArray count]) - 1;
    }
    
    // Add x thumbnails to the view
    for (int i = 0; i < x; i++) {
        
        ALAsset *asset = [self.assetsArray objectAtIndex:index+i];
        
        // Make a UIImageView for the thumbnail image; attach thumbnail image
        UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
        [image setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
        
        // Set a tag on the imageView so it can be identified later
        // tag corresponds to placement in the assetsArray
        // Also have the imageView listen for taps
        [image setTag:index+i];
        [image setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getAssetFromGesture:)];
        [image addGestureRecognizer:tap];
        
        // finally add the thumbnail to the view
        [view addSubview:image];
        
        // Add video info view to video assets
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            // This is the transparent black bar at the bottom of the thumbnail
            UIView *videoBar = [[UIView alloc] initWithFrame:CGRectMake(0, THUMB_SIZE - 18, THUMB_SIZE, 18)];
            videoBar.backgroundColor = [UIColor blackColor];
            videoBar.alpha = 0.75f;
            [image addSubview:videoBar];
            
            // This is the tiny video icon in the lower left of the thumbnail
            UIImageView *videoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui_icon_tinyvideo@2x.png"]];
            videoIcon.frame = CGRectMake(6, THUMB_SIZE - 13, videoIcon.frame.size.width/2.0f, videoIcon.frame.size.height/2.0f);
            [image addSubview:videoIcon];
            
            // Calculate the duration of the video
            // Note that NSTimeInterval is a double
            NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
            int minutes = duration/60;
            int seconds = duration - (minutes * 60);
            
            // Make a UILabel with the duration on it
            // Needs to be in this GCD block otherwise the view will take a few
            // seconds to appear.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(THUMB_SIZE/2.0f, THUMB_SIZE - 14, (THUMB_SIZE/2.0f) - 6, 12)];
                    lengthLabel.text = [NSString stringWithFormat:@"%i:%02i", minutes, seconds];
                    lengthLabel.textAlignment = UITextAlignmentRight;
                    lengthLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0f];
                    lengthLabel.textColor = [UIColor whiteColor];
                    lengthLabel.backgroundColor = [UIColor clearColor];
                    [image addSubview:lengthLabel];
                });
            });
        }
        
        rect = CGRectMake((rect.origin.x+THUMB_SIZE+THUMB_SPACING), rect.origin.y, rect.size.width, rect.size.height);
    }
    return view;
}

#pragma mark - Overridden setters and getters

- (void)setAssetType:(DIYAssetPickerControllerAssetType)assetType
{
    self->_assetType = assetType;
    [self getAssetsArray];
    [self.assetsTable reloadData];
}

#pragma mark - Utility

- (void)getAssetsArray
{
    [self.assetsArray removeAllObjects];
    
    [self.assetsLibrary
     enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         if (self.assetType == DIYAssetPickerPhoto) {
             [group setAssetsFilter:[ALAssetsFilter allPhotos]];
         }
         else if (self.assetType == DIYAssetPickerVideo) {
             [group setAssetsFilter:[ALAssetsFilter allVideos]];
         }
         else {
             [group setAssetsFilter:[ALAssetsFilter allAssets]];
         }
         [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
             if (result != nil) {
                 [self.assetsArray addObject:result];
             }
             else {
                 [self.assetsTable reloadData];
                 if ([self.delegate respondsToSelector:@selector(pickerDidFinishLoading)]) {
                     [self.delegate pickerDidFinishLoading];
                 }
             }
         }];
     }
     failureBlock:^(NSError *error) {
         NSInteger code = [error code];
         if (code == ALAssetsLibraryAccessUserDeniedError || code == ALAssetsLibraryAccessGloballyDeniedError) {
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:@"Error"
                                   message:@"Can't access photos - please allow access via the settings app. On iOS 5, enable 'location data' for this app. On iOS 6, go to privacy and enable photo access for this app."
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
             [alert show];
         }
         else {
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:@"Error"
                                   message:@"Something's busted."
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
             [alert show];
         }
         
         [self.delegate pickerDidCancel:self];
     }];
}

- (void)getAssetFromGesture:(UIGestureRecognizer *)gesture
{
    UIImageView *view = (UIImageView *)[gesture view];
    ALAsset *asset = [self.assetsArray objectAtIndex:[view tag]];
    BOOL isPhoto = [asset valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto;
    
    if (isPhoto) {
        NSDictionary *photoInfo = @{ UIImagePickerControllerMediaType : [[asset defaultRepresentation] UTI],
        UIImagePickerControllerOriginalImage : [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage] scale:1 orientation:(UIImageOrientation)[[asset defaultRepresentation] orientation]],
        UIImagePickerControllerReferenceURL : [[asset defaultRepresentation] url],
        DIYAssetPickerThumbnail : [UIImage imageWithCGImage:[asset aspectRatioThumbnail]],
        };
        [self.delegate pickerDidFinishPickingWithInfo:photoInfo];
    }
    else {
        [self.videoInfo addEntriesFromDictionary: @{ UIImagePickerControllerMediaType : [[asset defaultRepresentation] UTI],
            UIImagePickerControllerReferenceURL : [[asset defaultRepresentation] url],
         }];
        [self exportAsset:asset];
    }
}

#pragma mark - Exporter

- (void)exportAsset:(ALAsset *)alAsset
{
    NSString *directory = NSTemporaryDirectory();
    NSString *assetName = [NSString stringWithFormat:@"%@.mov", [[NSProcessInfo processInfo] globallyUniqueString]];
    NSString *assetPath = [directory stringByAppendingPathComponent:assetName];
    NSURL *assetURL = [NSURL fileURLWithPath:assetPath];
    [self.videoInfo setValue:assetURL forKey:UIImagePickerControllerMediaURL];
    [self.videoInfo setValue:[UIImage imageWithCGImage:[alAsset aspectRatioThumbnail]] forKey:DIYAssetPickerThumbnail];
    
    AVAsset *avAsset = [AVAsset assetWithURL:[[alAsset defaultRepresentation] url]];
    _exporter = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
    self.exporter.outputFileType = AVFileTypeQuickTimeMovie;
    self.exporter.outputURL = assetURL;
    self.exporter.shouldOptimizeForNetworkUse = true;
    [self.exporter exportAsynchronouslyWithCompletionHandler:^(void) {
        switch (self.exporter.status) {
            case AVAssetExportSessionStatusCompleted:
                [self.delegate performSelectorOnMainThread:@selector(pickerDidFinishPickingWithInfo:) withObject:self.videoInfo waitUntilDone:true];
                break;
            case AVAssetExportSessionStatusFailed:
                // What is a better thing to do in this case?
                [self.videoInfo setValue:@"" forKey:UIImagePickerControllerMediaURL];
                [self.delegate performSelectorOnMainThread:@selector(pickerDidFinishPickingWithInfo:) withObject:self.videoInfo waitUntilDone:true];
                break;
            default:
                break;
        }
    }];
    
    // Run a timer to do progressbar stuff
    _exportDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateExportDisplay) userInfo:nil repeats:YES];
    [self toggleExportDisplay];
}

- (void)updateExportDisplay
{
    self.exportDisplayProgress.progress = self.exporter.progress;
    
    if (self.exporter.progress > .99) {
        [self.exportDisplayTimer invalidate];
        _exportDisplayTimer = nil;
    }
}

- (void)toggleExportDisplay
{
    CGSize size = self.view.frame.size;
    CGSize apply = (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) ? CGSizeMake(size.width, size.height) : CGSizeMake(size.height, size.width);
    CGFloat offset = 60;
    
    CGRect exportViewFrame = CGRectMake(0, apply.width - offset, apply.height, offset);
    CGRect blockingViewFrame = CGRectMake(0, 0, apply.height, apply.width);
    
    // Create a view to block input
    UIView *blockingView = [[UIView alloc] initWithFrame:blockingViewFrame];
    blockingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    blockingView.backgroundColor = [UIColor blackColor];
    blockingView.alpha = 0.0f;
    [self.view addSubview:blockingView];
    
    // Container view for the progressview and the label
    _exportDisplay = [[UIView alloc] initWithFrame:exportViewFrame];
    self.exportDisplay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.exportDisplay.backgroundColor = [UIColor blackColor];
    self.exportDisplay.alpha = 0.0f;
    
    // Label for the export progress view
    UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.exportDisplay.frame.size.width, 20)];
    progressLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.textColor = [UIColor whiteColor];
    progressLabel.textAlignment = UITextAlignmentCenter;
    progressLabel.text = @"Exporting video …";
    [self.exportDisplay addSubview:progressLabel];
    
    // Progress view
    _exportDisplayProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.exportDisplayProgress.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.exportDisplayProgress.frame = CGRectMake(0, progressLabel.frame.origin.y + 25, self.exportDisplayProgress.frame.size.width, self.exportDisplayProgress.frame.size.height);
    self.exportDisplayProgress.center = CGPointMake(self.exportDisplay.center.x, self.exportDisplayProgress.center.y);
    self.exportDisplayProgress.progress = self.exporter.progress;
    [self.exportDisplay addSubview:self.exportDisplayProgress];
    
    [self.view addSubview:self.exportDisplay];
    
    // Make cute animations for the transition
    [UIView animateWithDuration:0.2f animations:^{
        blockingView.alpha = 0.75f;
        self.exportDisplay.alpha = 1.0f;
    }];
}

@end
