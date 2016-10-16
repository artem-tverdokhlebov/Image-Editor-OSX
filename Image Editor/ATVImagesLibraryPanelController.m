//
//  ATVImagesLibraryPanelController.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/20/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVImagesLibraryPanelController.h"
#import "ATVDocument.h"

#import "ATVCanvasImageElement.h"

@interface ATVImagesLibraryPanelController () <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, NSDraggingDestination>
{
@private
    NSArray<NSString *> *_standardImagesPaths;
    NSMutableArray<NSString *> *_userImagesPaths;
}

@property (copy) NSArray<NSString *> *standardImagesPaths;
@property (copy) NSArray<NSString *> *userImagesPaths;

@property (copy, readonly) NSArray<NSString *> *imagesPaths;

@property (copy) NSString *appSupportFolderPath;

@property (assign) IBOutlet NSTableView *tableView;

@end

@implementation ATVImagesLibraryPanelController

- (instancetype)init
{
    self = [super initWithWindowNibName:@"ATVImagesLibraryPanel"];
    if (self)
    {
        
    }
    
    return self;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    NSPasteboard *draggingPasteboard = info.draggingPasteboard;
    
    NSArray* acceptedTypes = @[(NSString*) kUTTypeImage];
    
    NSArray* urls = [draggingPasteboard readObjectsForClasses:@[[NSURL class]] options:@{ NSPasteboardURLReadingFileURLsOnlyKey : @YES, NSPasteboardURLReadingContentsConformToTypesKey : acceptedTypes}];
    
    if (urls.count != 1)
    {
        return NSDragOperationNone;
    }
    
    return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    NSPasteboard *draggingPasteboard = info.draggingPasteboard;
    
    NSURL *imageURL = [NSURL URLFromPasteboard:draggingPasteboard];
    NSString *imagePath = imageURL.path;
    
    NSError *fileCopyError = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager copyItemAtPath:imagePath toPath:[self.appSupportFolderPath stringByAppendingPathComponent:[imagePath lastPathComponent]] error:&fileCopyError];
    
    if (!fileCopyError)
    {
        [self reloadUserImages];
        [tableView reloadData];
        
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
 
    self.standardImagesPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Standard Images"];
    
    [self reloadUserImages];
    
    [self.tableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:YES];
    
    [self.tableView setDraggingDestinationFeedbackStyle:NSTableViewDraggingDestinationFeedbackStyleSourceList];
    [self.tableView registerForDraggedTypes:@[NSFilenamesPboardType]];
}

- (void)reloadUserImages
{
    NSError *appSupportDirError = nil;
    NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&appSupportDirError];
    
    if (!appSupportDirError)
    {
        NSError *appFolderError = nil;
        NSString *appFolderPath = [appSupportDir URLByAppendingPathComponent:@"Image Editor"].path;
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:appFolderPath isDirectory:nil])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:appFolderPath withIntermediateDirectories:YES attributes:nil error:&appFolderError];
        }
        
        if (!appFolderError)
        {
            NSMutableArray *files = [NSMutableArray array];
            
            for(NSString *fileName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appFolderPath error:&appFolderError])
            {
                CFStringRef fileExtension = (CFStringRef) [fileName pathExtension];
                CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
                
                if (UTTypeConformsTo(fileUTI, kUTTypeImage))
                {
                    [files addObject:[appFolderPath stringByAppendingPathComponent:fileName]];
                }
                
                CFRelease(fileUTI);
            }
            
            self.appSupportFolderPath = appFolderPath;
            self.userImagesPaths = files;
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.imagesPaths count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];
    
    if ([tableColumn.identifier isEqualToString:@"imageCell"])
    {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:self.imagesPaths[row]];
        cellView.imageView.image = image;
        [image release];
    }
    else if ([tableColumn.identifier isEqualToString:@"nameCell"])
    {
        cellView.textField.stringValue = [[self.imagesPaths[row] lastPathComponent] stringByDeletingPathExtension];
        
        if (row > self.standardImagesPaths.count)
        {
            [cellView.textField setEditable:YES];
            cellView.textField.delegate = self;
        }
    }
    
    return cellView;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    NSInteger row = [self.tableView rowForView:control];
    
    NSString *fileExtension = [self.imagesPaths[row] pathExtension];
    NSString *newFilePath = [[[self.imagesPaths[row] stringByDeletingLastPathComponent] stringByAppendingPathComponent:[fieldEditor string]] stringByAppendingPathExtension:fileExtension];
    
    NSError *fileMoveError = nil;
    [[NSFileManager defaultManager] moveItemAtPath:self.imagesPaths[row] toPath:newFilePath error:&fileMoveError];
    
    if (fileMoveError)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (IBAction)doubleClick:(NSTableView *)sender
{
    NSUInteger selectedRow = sender.selectedRow;
    
    if (selectedRow != -1)
    {
        ATVDocument *currentDocument = [[NSDocumentController sharedDocumentController] currentDocument];
        
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:self.imagesPaths[selectedRow]];
        
        ATVCanvasImageElement *imageElement = [ATVCanvasImageElement canvasImageElementWithImage:image frameOrigin:NSMakePoint(20, 20)];
        
        [image release];
        
        imageElement.delegate = currentDocument.windowController;
        
        [currentDocument.windowController addCanvasElement:imageElement];
    }
}

- (void)tooglePanel
{
    if (self.window.visible)
    {
        [[self window] close];
    }
    else
    {
        [[self window] orderFront:self];
    }
}

#pragma mark Drag & Drop

- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
    return [[[NSImage alloc] initWithContentsOfFile:self.imagesPaths[row]] autorelease];
}

- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(NSIndexSet *)rowIndexes
{
    [session enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationConcurrent forView:nil classes:@[[NSImage class]] searchOptions:@{} usingBlock:
     ^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop)
     {
         NSUInteger selectedRow = rowIndexes.firstIndex;
         
         NSImage *image = [[[NSImage alloc] initWithContentsOfFile:self.imagesPaths[selectedRow]] autorelease];
         
         [draggingItem setDraggingFrame:NSMakeRect(session.draggingLocation.x - (image.size.width / 2), session.draggingLocation.y - (image.size.height / 2), image.size.width, image.size.height) contents:image];
     }];
}

- (NSArray<NSString *> *)imagesPaths
{
    return [self.standardImagesPaths arrayByAddingObjectsFromArray:self.userImagesPaths];
}

- (void)dealloc
{
    [_standardImagesPaths release];
    [_userImagesPaths release];
    [_appSupportFolderPath release];
    [super dealloc];
}

@end