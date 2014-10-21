//
//  FPPickerController.m
//  FPPicker
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPPickerController.h"
#import "FPInternalHeaders.h"
#import "FPDialogController.h"
#import "FPFileDownloadController.h"

@interface FPPickerController () <FPDialogControllerDelegate,
                                  FPFileTransferControllerDelegate>

@property (nonatomic, strong) FPDialogController *dialogController;

@end

@implementation FPPickerController

#pragma mark - Accessors

- (FPDialogController *)dialogController
{
    if (!_dialogController)
    {
        _dialogController = [[FPDialogController alloc] initWithWindowNibName:@"FPPickerController"];

        _dialogController.delegate = self;
    }

    return _dialogController;
}

#pragma mark - Public Methods

- (void)open
{
    [self.dialogController open];
}

#pragma mark - FPDialogControllerDelegate Methods

- (void)dialogControllerDidLoadWindow:(FPDialogController *)dialogController
{
    [self.dialogController setupDialogForOpening];
    [self.dialogController setupSourceListWithSourceNames:self.sourceNames
                                             andDataTypes:self.dataTypes];
}

- (void)dialogControllerPressedActionButton:(FPDialogController *)dialogController
{
    // Validate selection by looking for directories

    NSArray *selectedItems = [self.dialogController selectedItems];

    if (!selectedItems)
    {
        return;
    }

    for (NSDictionary *item in selectedItems)
    {
        if ([item[@"is_dir"] boolValue])
        {
            // Display alert with error

            NSError *error = [FPUtils errorWithCode:200
                              andLocalizedDescription:@"Selection must not contain any directories."];

            [FPUtils presentError:error
                  withMessageText:@"Invalid selection"];

            return;
        }
    }

    [self.dialogController close];

    FPFileDownloadController *fileDownloadController = [[FPFileDownloadController alloc] initWithItems:selectedItems];

    fileDownloadController.delegate = self;
    fileDownloadController.sourceController = [self.dialogController selectedSourceController];
    fileDownloadController.shouldDownloadData = self.shouldDownload;

    [fileDownloadController process];
}

- (void)dialogControllerPressedCancelButton:(FPDialogController *)dialogController
{
    [self.dialogController close];
}

#pragma mark - FPFileTransferControllerDelegate Methods

- (void)FPFileTransferControllerDidFinish:(FPFileTransferController *)transferController
                                     info:(id)info
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(FPPickerController:didFinishPickingMultipleMediaWithResults:)])
    {
        [self.delegate FPPickerController:self
         didFinishPickingMultipleMediaWithResults:info];
    }
}

- (void)FPFileTransferControllerDidFail:(FPFileTransferController *)transferController
                                  error:(NSError *)error
{
    DLog(@"Error downloading: %@", error);
}

- (void)FPFileTransferControllerDidCancel:(FPFileTransferController *)transferController
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(FPPickerControllerDidCancel:)])
    {
        [self.delegate FPPickerControllerDidCancel:self];
    }
}

@end
