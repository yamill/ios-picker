//
//  ViewController.m
//  FPPicker iOS Demo
//
//  Created by Ruben Nine on 13/06/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "ViewController.h"

@import FPPicker;

@interface ViewController () <FPPickerControllerDelegate,
                              FPSaveControllerDelegate>

@property (nonatomic, strong) FPSaveController *fpSave;
@property (nonatomic, strong) UIPopoverController *myPopoverController;
@property (nonatomic, strong) NSMutableArray *displayedImages;

@end

@implementation ViewController

#pragma mark - Accessors

- (NSMutableArray *)displayedImages
{
    if (!_displayedImages)
    {
        _displayedImages = [NSMutableArray array];
    }

    return _displayedImages;
}

#pragma mark - Actions

- (IBAction)pickerAction:(id)sender
{
    /*
     * Create the object
     */
    FPPickerController *fpController = [FPPickerController new];

    /*
     * Set the delegate
     */
    fpController.fpdelegate = self;

    /*
     * Ask for specific data types. (Optional) Default is all files.
     */
    fpController.dataTypes = @[@"image/*"];

    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //fpController.sourceNames = [[NSArray alloc] initWithObjects: FPSourceImagesearch, nil];

    /*
     * Enable multselect (Optional) Default is single select
     */
    fpController.selectMultiple = YES;

    /*
     * Specify the maximum number of files (Optional) Default is 0, no limit
     */
    fpController.maxFiles = 5;

    /*
     * Display it.
     */
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:fpController];

    self.myPopoverController = popoverController;
    self.myPopoverController.popoverContentSize = CGSizeMake(320, 520);

    [self.myPopoverController presentPopoverFromRect:[sender frame]
                                              inView:self.view
                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                            animated:YES];
}

- (IBAction)pickerModalAction:(id)sender
{
    /*
     * Create the object
     */
    FPPickerController *fpController = [FPPickerController new];

    /*
     * Set the delegate
     */
    fpController.fpdelegate = self;

    /*
     * Ask for specific data types. (Optional) Default is all files.
     */
    fpController.dataTypes = @[@"image/*"];

    /*
     * Should file be uploaded? Default is YES.
     */
    fpController.shouldUpload = YES;

    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //fpController.sourceNames = @[FPSourceImagesearch];

    /*
     * Enable multselect (Optional) Default is single select
     */
    fpController.selectMultiple = YES;

    /*
     * Specify the maximum number of files (Optional) Default is 0, no limit
     */
    fpController.maxFiles = 10;
    

    fpController.modalPresentationStyle = UIModalPresentationPopover;
    
    /*
     * If controller will show in popover set popover size (iPad)
     */
    fpController.preferredContentSize = CGSizeMake(400, 500);

    UIPopoverPresentationController *presentationController = fpController.popoverPresentationController;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    presentationController.sourceView = sender;
    presentationController.sourceRect = [sender bounds];

    /*
     * Display it.
     */
    [self presentViewController:fpController
                       animated:YES
                     completion:nil];
}

- (IBAction)savingAction:(id)sender
{
    if (self.displayedImages.count == 0)
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Nothing to Save"
                                                          message:@"Select an image first."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];

        [message show];

        return;
    }

    UIImage *firstImage = self.displayedImages[0];
    NSData *imgData = UIImagePNGRepresentation(firstImage);

    /*
     * Create the object
     */
    self.fpSave = [FPSaveController new];

    /*
     * Set the delegate
     */
    self.fpSave.fpdelegate = self;

    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //self.fpSave.sourceNames = @[FPSourceDropbox, FPSourceFacebook, FPSourceBox];

    /*
     * Set the data and data type to be saved.
     */
    self.fpSave.data = imgData;
    self.fpSave.dataType = @"image/png";

    self.fpSave.modalPresentationStyle = UIModalPresentationPopover;
    
    /*
     * If controller will show in popover set popover size (iPad)
     */
    self.fpSave.preferredContentSize = CGSizeMake(400, 500);
    
    UIPopoverPresentationController *presentationController = self.fpSave.popoverPresentationController;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    presentationController.sourceView = sender;
    presentationController.sourceRect = [sender bounds];

    /*
     * Display it.
     */
    [self presentViewController:self.fpSave
                       animated:YES
                     completion:nil];
}

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.

    self.imageView.frame = self.view.bounds;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
    else
    {
        return YES;
    }
}

#pragma mark - FPPickerControllerDelegate Methods

- (void)fpPickerController:(FPPickerController *)pickerController
      didPickMediaWithInfo:(FPMediaInfo *)info
{
}

- (void)       fpPickerController:(FPPickerController *)pickerController
    didFinishPickingMediaWithInfo:(FPMediaInfo *)info
{
    NSLog(@"FILE CHOSEN: %@", info);

    if (info)
    {
        if (info.containsImageAtMediaURL)
        {
            UIImage *image = [UIImage imageWithContentsOfFile:info.mediaURL.path];

            [self.displayedImages removeAllObjects];
            [self.displayedImages addObject:image];

            self.imageView.image = image;
        }

        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
    else
    {
        NSLog(@"Nothing was picked.");
    }
}

- (void)                  fpPickerController:(FPPickerController *)pickerController
    didFinishPickingMultipleMediaWithResults:(NSArray *)results
{
    NSLog(@"FILES CHOSEN: %@", results);

    if (results.count == 0)
    {
        NSLog(@"Nothing was picked.");

        return;
    }

    [self dismissViewControllerAnimated:YES
                             completion:nil];

    // Making a little carousel effect with the images

    [self.displayedImages removeAllObjects];

    for (FPMediaInfo *info in results)
    {
        // Check if uploaded file is an image to add it to carousel

        if (info.containsImageAtMediaURL)
        {
            UIImage *image = [UIImage imageWithContentsOfFile:info.mediaURL.path];

            [self.displayedImages addObject:image];
        }
    }

    self.imageView.animationImages = self.displayedImages;
    self.imageView.animationRepeatCount = 100.f;
    self.imageView.animationDuration = 2.f * self.displayedImages.count; // 2 seconds per image

    [self.imageView startAnimating];
}

- (void)fpPickerControllerDidCancel:(FPPickerController *)pickerController
{
    NSLog(@"FP Cancelled Open");

    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
}

#pragma mark - FPSaveControllerDelegate Methods

- (void)        fpSaveController:(FPSaveController *)saveController
    didFinishSavingMediaWithInfo:(FPMediaInfo *)info
{
    NSLog(@"FP finished saving with info %@", info);

    [self.fpSave dismissViewControllerAnimated:YES
                                    completion:nil];

}

- (void)fpSaveControllerDidCancel:(FPSaveController *)saveController
{
    NSLog(@"FP Cancelled Save");

    [self.fpSave dismissViewControllerAnimated:YES
                                    completion:nil];
}

- (void)fpSaveController:(FPSaveController *)saveController
                didError:(NSError *)error
{
    NSLog(@"FP Error: %@", error);
}

@end
