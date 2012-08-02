//
//  DIYAssetPickerController.m
//  DIYAssetPicker
//
//  Created by Jonathan Beilin on 7/30/12.
//  Copyright (c) 2012 Jonathan Beilin. All rights reserved.
//

#import "DIYAssetPickerController.h"

@interface DIYAssetPickerController ()
@property (nonatomic, retain) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, copy) NSMutableArray *allAssets;
@property (nonatomic, retain) UITableView *assetsTable;
@property (nonatomic, retain) UINavigationBar *header;
@end

@implementation DIYAssetPickerController

@synthesize assetsLibrary = _assetsLibrary;
@synthesize allAssets = _allAssets;
@synthesize assetsTable = _assetsTable;
@synthesize header = _header;

@synthesize delegate = _delegate;
@synthesize numberColumns = _numberColumns;
@synthesize assetType = _assetType;
@synthesize validOrientation = _validOrientation;

#pragma mark - Init

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup
    [self setTitle:@"Asset Picker"];
    
    // Header
    CGRect headerFrame = self.view.bounds;
    _header = [[UINavigationBar alloc] initWithFrame:headerFrame];
    headerFrame.size = [self.header sizeThatFits:headerFrame.size];
    self.header.frame = headerFrame;
    self.header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.header.barStyle = UIBarStyleBlack;
    self.header.translucent = true;
    [self.header setItems:@[ self.navigationItem ]];
    [self.view addSubview:self.header];
    
    // Asset library & array
    self.assetsLibrary = [[[ALAssetsLibrary alloc] init] autorelease];
    
    self.allAssets = [self getAssetsArray];
    
    // Asset Table
    _assetsTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.assetsTable setContentInset:UIEdgeInsetsMake(self.header.frame.size.height, 0, 0, 0)];
    [self.assetsTable setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.assetsTable setDelegate:self];
    [self.assetsTable setDataSource:self];
    [self.assetsTable setSeparatorColor:[UIColor clearColor]];
    [self.assetsTable setAllowsSelection:NO];
    //[self.view addSubview:self.assetsTable];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self releaseObjects];
}

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
    if(!photos) {
        return 0;
    }
    return ceil([photos count]/((float)THUMB_COUNT_PER_ROW));
     */
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: borrowed code; refactor if necessary
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    [cell.textLabel setText:@" "];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        UIView *v = [self tableView:tableView viewForIndexPath:indexPath];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if(v){
                for(UIView *view in cell.contentView.subviews){
                    [view removeFromSuperview];
                }
                [cell.contentView addSubview:v];
            }
            else{
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setEditingAccessoryType:UITableViewCellAccessoryNone];
            }
        });
    });
    return cell;
}

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
    // TODO: put actual stuff in here
    
    return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.assetsTable.frame.size.width, [self tableView:self.assetsTable heightForRowAtIndexPath:indexPath])] autorelease];
}

#pragma mark - Utility

- (NSArray *)getAssetsArray {
    NSMutableArray *assets = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.assetsLibrary
         enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
         usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
             [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                 if (result) {
                     [self.allAssets addObject:result];
                 }
             }];
         }
         failureBlock:^(NSError *error) {
             // This is where I handle the case where the user has denied access
         }];
    });
    return assets;
}

#pragma mark - Dealloc

- (void)releaseObjects
{
    [_allAssets release]; _allAssets = nil;
    [_assetsLibrary release]; _assetsLibrary = nil;
    [_assetsTable release]; _assetsTable = nil;
    [_header release]; _header = nil;
    
    _delegate = nil;
}

- (void)dealloc
{
    [super dealloc];
}

@end
